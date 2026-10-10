-- Step 6.3: party documents and KYC. Rules: docs/domain/documents-kyc.md.
--
-- party_documents  one row per stored file (Aadhaar, PAN, passbook, cheque,
--                  J-form, loan agreement, other). Master data: soft delete.
--                  Identity documents (aadhaar, pan) are OWNER ONLY; the
--                  others need parties.manage. id_masked holds the masked
--                  number (XXXX XXXX 1234): the full number is never stored.
-- storage buckets  'kyc-docs'   identity documents, owner only
--                  'party-docs' other documents, parties.manage
--                  path <tenant>/<party>/<document>/<file>; the first folder
--                  is the business. Thumbnails sit next to the file.

create table public.party_documents (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  party_id uuid not null,
  doc_type text not null check (doc_type in (
    'aadhaar', 'pan', 'passbook', 'cheque', 'j_form', 'loan_agreement', 'other'
  )),
  title text,
  -- Masked identity number shown on screen; only for aadhaar / pan.
  id_masked text,
  file_path text not null check (length(trim(file_path)) > 0),
  thumb_path text,
  content_type text not null,
  size_bytes bigint not null check (size_bytes > 0 and size_bytes <= 10485760),
  notes text,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint party_documents_id_tenant_unique unique (id, tenant_id),
  constraint party_documents_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  -- Only identity documents carry a masked number, and it never looks like a
  -- full Aadhaar (12 digits) or PAN.
  constraint party_documents_masked_only_identity check (
    id_masked is null or doc_type in ('aadhaar', 'pan')
  ),
  constraint party_documents_masked_shape check (
    id_masked is null or id_masked ~ '^X{4,6}[ X]*[0-9A-Z]{4}$'
  ),
  -- The file is in this business's folder.
  constraint party_documents_path_tenant check (
    split_part(file_path, '/', 1) = tenant_id::text
  )
);

create index party_documents_party_idx
  on public.party_documents (tenant_id, party_id) where deleted_at is null;
create index party_documents_party_fk_idx on public.party_documents (party_id, tenant_id);

create trigger party_documents_set_updated_at before update on public.party_documents
  for each row execute function private.set_updated_at();
create trigger party_documents_set_created_by before insert on public.party_documents
  for each row execute function private.set_created_by();
create trigger party_documents_keep_tenant_id before update on public.party_documents
  for each row execute function private.keep_tenant_id();

-- Who may touch which kind: identity = owner, the rest = parties.manage.
create or replace function private.can_use_party_document(p_tenant_id uuid, p_doc_type text)
returns boolean
language sql
stable
set search_path = ''
as $$
  select case
    when p_doc_type in ('aadhaar', 'pan') then private.is_owner(p_tenant_id)
    else private.has_permission(p_tenant_id, 'parties.manage')
  end;
$$;

revoke execute on function private.can_use_party_document(uuid, text) from public, anon;
grant execute on function private.can_use_party_document(uuid, text) to authenticated;

-- A document's identity (type, file, party) never changes; only the title,
-- notes, thumbnail and soft delete do. Deleting needs master.delete.
create or replace function private.guard_party_document()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('authenticated', 'anon') then
    if tg_op = 'UPDATE' then
      if new.doc_type is distinct from old.doc_type
        or new.party_id is distinct from old.party_id
        or new.file_path is distinct from old.file_path
        or new.content_type is distinct from old.content_type
        or new.size_bytes is distinct from old.size_bytes
        or new.id_masked is distinct from old.id_masked then
        raise exception 'a document keeps its type, party and file; delete it and add a new one'
          using errcode = '42501';
      end if;
      if old.thumb_path is not null and new.thumb_path is distinct from old.thumb_path then
        raise exception 'a thumbnail is set once' using errcode = '42501';
      end if;
      if new.deleted_at is distinct from old.deleted_at
        and not (select private.has_permission(new.tenant_id, 'master.delete')) then
        raise exception 'deleting a document needs the master.delete permission'
          using errcode = '42501';
      end if;
    end if;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_party_document() from public, anon, authenticated;

create trigger party_documents_guard before insert or update on public.party_documents
  for each row execute function private.guard_party_document();

alter table public.party_documents enable row level security;

create policy party_documents_select on public.party_documents
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids())
    and (select private.can_use_party_document(tenant_id, doc_type)));
create policy party_documents_insert on public.party_documents
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.can_use_party_document(tenant_id, doc_type)));
create policy party_documents_update on public.party_documents
  for update to authenticated
  using ((select private.can_use_party_document(tenant_id, doc_type)))
  with check ((select private.can_use_party_document(tenant_id, doc_type)));

revoke all on public.party_documents from anon;
revoke delete, truncate on public.party_documents from authenticated;

-- ---------------------------------------------------------------------------
-- Storage
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('kyc-docs', 'kyc-docs', false, 10485760,
    array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf']),
  ('party-docs', 'party-docs', false, 10485760,
    array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf'])
on conflict (id) do nothing;

create policy kyc_docs_select on storage.objects
  for select to authenticated
  using (bucket_id = 'kyc-docs'
    and (select private.is_owner(((storage.foldername(name))[1])::uuid)));
create policy kyc_docs_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'kyc-docs'
    and (select private.is_owner(((storage.foldername(name))[1])::uuid)));

create policy party_docs_select on storage.objects
  for select to authenticated
  using (bucket_id = 'party-docs'
    and (select private.has_permission(((storage.foldername(name))[1])::uuid, 'parties.manage')));
create policy party_docs_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'party-docs'
    and (select private.has_permission(((storage.foldername(name))[1])::uuid, 'parties.manage')));

alter publication powersync add table public.party_documents;
