-- Step 1.1: ledger_entries — every party's khata, append-only.
--
-- Balance = Σ jama − Σ udhaar. Nothing is ever updated or deleted: an edit is
-- a reversal (opposite side, same amount, reverses_id) plus a replacement
-- (replaces_id), both in one upload. See docs/domain/ledger-and-mandi.md.

create table public.ledger_entries (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  party_id uuid not null,
  -- Business date in the tenant's local calendar.
  entry_date date not null,
  side text not null check (side in ('udhaar', 'jama')),
  amount_paise bigint not null check (amount_paise > 0),
  ref_type text not null check (ref_type in (
    'arrival', 'payment', 'receipt', 'shop_sale', 'shop_return', 'purchase',
    'loan_disbursal', 'loan_repayment', 'interest', 'expense', 'journal',
    'opening_balance', 'reversal'
  )),
  -- The document that posted it (arrival, payment…); no FK, documents live
  -- in their own tables.
  ref_id uuid,
  narration text,
  reverses_id uuid,
  replaces_id uuid,
  device_id uuid references public.devices (id),
  created_by uuid,
  -- When it was recorded on the device (may be long before it synced).
  created_at timestamptz not null default now(),
  -- When the server received it; set here, never by the client.
  received_at timestamptz not null default now(),
  constraint ledger_entries_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint ledger_entries_id_tenant_unique unique (id, tenant_id),
  constraint ledger_entries_reverses_fk foreign key (reverses_id, tenant_id)
    references public.ledger_entries (id, tenant_id),
  constraint ledger_entries_replaces_fk foreign key (replaces_id, tenant_id)
    references public.ledger_entries (id, tenant_id),
  -- A reversal (and only a reversal) says what it reverses.
  constraint ledger_entries_reversal_link
    check ((ref_type = 'reversal') = (reverses_id is not null)),
  -- An entry is reversed at most once, even by two devices offline.
  constraint ledger_entries_reversed_once unique (reverses_id)
);

create index ledger_entries_party_date_idx
  on public.ledger_entries (tenant_id, party_id, entry_date);
create index ledger_entries_tenant_date_idx
  on public.ledger_entries (tenant_id, entry_date);
create index ledger_entries_ref_idx
  on public.ledger_entries (tenant_id, ref_id) where ref_id is not null;
create index ledger_entries_replaces_idx
  on public.ledger_entries (replaces_id, tenant_id) where replaces_id is not null;
create index ledger_entries_device_idx
  on public.ledger_entries (device_id) where device_id is not null;

-- Who may post which kind of entry. Mirrors khata_core
-- `LedgerPosting.requiredPermission`; null = any active member.
create or replace function private.ledger_post_permission(
  p_ref_type text,
  p_replaces_id uuid
)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when p_replaces_id is not null
      or p_ref_type in ('reversal', 'journal', 'opening_balance')
      then 'entries.reverse'
    when p_ref_type = 'arrival' then 'arrivals.manage'
    when p_ref_type in ('payment', 'receipt', 'loan_repayment')
      then 'payments.create'
    when p_ref_type in ('loan_disbursal', 'interest') then 'loans.manage'
    else null
  end;
$$;

-- Checks what RLS cannot see: a reversal mirrors its original, the device
-- belongs to the uploader, and the server time is the server's.
create or replace function private.guard_ledger_entry()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_original public.ledger_entries;
begin
  new.received_at := now();

  if new.reverses_id is not null then
    select * into v_original from public.ledger_entries e
    where e.id = new.reverses_id and e.tenant_id = new.tenant_id;
    if found and (
      v_original.ref_type = 'reversal'
      or v_original.party_id <> new.party_id
      or v_original.side = new.side
      or v_original.amount_paise <> new.amount_paise
    ) then
      raise exception 'a reversal must mirror the entry it reverses'
        using errcode = '23514';
    end if;
  end if;

  if (select auth.uid()) is not null and not exists (
    select 1 from public.devices d
    where d.id = new.device_id
      and d.tenant_id = new.tenant_id
      and d.user_id = (select auth.uid())
  ) then
    raise exception 'ledger entries must come from one of your devices in this business'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

create trigger ledger_entries_guard before insert on public.ledger_entries
  for each row execute function private.guard_ledger_entry();
create trigger ledger_entries_set_created_by before insert on public.ledger_entries
  for each row execute function private.set_created_by();
-- Append-only for everyone, including the service role.
create trigger ledger_entries_append_only before update or delete on public.ledger_entries
  for each row execute function private.reject_change();

alter table public.ledger_entries enable row level security;

create policy ledger_entries_select on public.ledger_entries
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy ledger_entries_insert on public.ledger_entries
  for insert to authenticated
  with check (
    tenant_id in (select private.auth_tenant_ids())
    and (
      private.ledger_post_permission(ref_type, replaces_id) is null
      or (select private.has_permission(
        tenant_id, private.ledger_post_permission(ref_type, replaces_id)
      ))
    )
  );

revoke all on public.ledger_entries from anon;
revoke update, delete, truncate on public.ledger_entries from authenticated;
revoke execute on function private.ledger_post_permission(text, uuid) from public, anon;
grant execute on function private.ledger_post_permission(text, uuid) to authenticated;

alter publication powersync add table public.ledger_entries;
