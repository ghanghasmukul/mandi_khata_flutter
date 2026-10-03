-- Step 1.8: users, roles, invites, device revoke.
--
--  * member_invites: an owner invites a phone number with a role and
--    permission overrides; the invite turns into a tenant_members row when
--    that number signs in (accept_member_invites()).
--  * devices.revoked_at: an owner can revoke a device. A revoked device cannot
--    register again, and no write from it is accepted (audit_log and ledger
--    guards), so its queued offline changes are rejected.
--  * tenant_members hardening: only owners can create / change / switch off
--    an owner; nobody changes their own access unless they are an owner;
--    clients no longer insert members (invites do).
--  * device_limit default 2 -> 5 and enforced by register_device().

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Whether the signed-in user is an active owner of the business.
create or replace function private.is_owner(p_tenant_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.tenant_members m
    where m.tenant_id = p_tenant_id
      and m.user_id = (select auth.uid())
      and m.role = 'owner'
      and m.is_active
  );
$$;

revoke execute on function private.is_owner(uuid) from public, anon;
grant execute on function private.is_owner(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- tenant_members: owner safety
-- ---------------------------------------------------------------------------

alter table public.tenant_members alter column device_limit set default 5;
update public.tenant_members set device_limit = 5 where device_limit = 2;

-- Members are created by invites (accept_member_invites) or by the service
-- role; the app never inserts them directly.
drop policy tenant_members_insert on public.tenant_members;

create or replace function private.guard_tenant_members()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.user_id is distinct from old.user_id then
    raise exception 'user_id cannot be changed' using errcode = '42501';
  end if;

  -- Owner rows and the owner role are for owners only; and nobody but an
  -- owner changes their own access.
  if current_user in ('authenticated', 'anon')
     and not private.is_owner(old.tenant_id) then
    if old.role = 'owner' or new.role = 'owner' then
      raise exception 'only an owner can change an owner'
        using errcode = '42501';
    end if;
    if old.user_id = (select auth.uid()) and (
      new.role is distinct from old.role
      or new.custom_permissions is distinct from old.custom_permissions
      or new.is_active is distinct from old.is_active
      or new.device_limit is distinct from old.device_limit
    ) then
      raise exception 'you cannot change your own access'
        using errcode = '42501';
    end if;
  end if;

  if old.role = 'owner' and old.is_active
     and (new.role <> 'owner' or not new.is_active)
     and not exists (
       select 1 from public.tenant_members m
       where m.tenant_id = old.tenant_id
         and m.id <> old.id
         and m.role = 'owner'
         and m.is_active
     ) then
    raise exception 'a business needs at least one active owner'
      using errcode = 'P0001';
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- devices: revoke
-- ---------------------------------------------------------------------------

alter table public.devices
  add column revoked_at timestamptz,
  add column revoked_by uuid references public.app_users (id);

create or replace function private.guard_devices()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('authenticated', 'anon') then
    if new.id is distinct from old.id
       or new.user_id is distinct from old.user_id
       or new.device_code is distinct from old.device_code
       or new.platform is distinct from old.platform then
      raise exception 'device identity cannot be changed' using errcode = '42501';
    end if;
    if (new.revoked_at is distinct from old.revoked_at
        or new.revoked_by is distinct from old.revoked_by) then
      if not private.has_permission(new.tenant_id, 'admin.manage') then
        raise exception 'only the owner can revoke a device'
          using errcode = '42501';
      end if;
      if old.revoked_at is not null then
        raise exception 'a revoked device stays revoked (register a new one)'
          using errcode = '42501';
      end if;
      new.revoked_by := (select auth.uid());
      new.revoked_at := coalesce(new.revoked_at, now());
    end if;
  end if;
  return new;
end;
$$;

-- Owners (admin.manage) can revoke any device of the business.
create policy devices_update_admin on public.devices
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'admin.manage')))
  with check ((select private.has_permission(tenant_id, 'admin.manage')));

-- register_device: refuses revoked devices, enforces the member's limit.
create or replace function public.register_device(
  p_device_id uuid,
  p_tenant_id uuid,
  p_platform text,
  p_name text default null
)
returns public.devices
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_device public.devices;
  v_limit integer;
  v_prefix text;
  v_next integer;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  select m.device_limit into v_limit
    from public.tenant_members m
    where m.tenant_id = p_tenant_id and m.user_id = v_uid and m.is_active;
  if not found then
    raise exception 'not a member of this business' using errcode = '42501';
  end if;

  select * into v_device from public.devices d where d.id = p_device_id;
  if found then
    if v_device.tenant_id <> p_tenant_id or v_device.user_id <> v_uid then
      raise exception 'device is registered to another user or business'
        using errcode = '42501';
    end if;
    if v_device.revoked_at is not null then
      raise exception 'device_revoked' using errcode = '42501';
    end if;
    update public.devices d
      set last_seen_at = now(), name = coalesce(p_name, d.name)
      where d.id = p_device_id
      returning * into v_device;
    return v_device;
  end if;

  v_prefix := case p_platform
    when 'windows' then 'W'
    when 'android' then 'A'
    when 'macos' then 'M'
    when 'web' then 'B'
  end;
  if v_prefix is null then
    raise exception 'unknown platform %', p_platform using errcode = '22023';
  end if;

  perform pg_advisory_xact_lock(hashtextextended(p_tenant_id::text, 0));
  if (
    select count(*) from public.devices d
    where d.tenant_id = p_tenant_id and d.user_id = v_uid and d.revoked_at is null
  ) >= v_limit then
    raise exception 'device_limit_reached' using errcode = 'P0001';
  end if;

  select coalesce(max(substring(d.device_code from 2)::integer), 0) + 1
    into v_next
    from public.devices d
    where d.tenant_id = p_tenant_id and left(d.device_code, 1) = v_prefix;

  insert into public.devices (
    id, tenant_id, user_id, device_code, platform, name, last_seen_at, created_by
  )
  values (
    p_device_id, p_tenant_id, v_uid, v_prefix || v_next, p_platform, p_name,
    now(), v_uid
  )
  returning * into v_device;
  return v_device;
end;
$$;

revoke execute on function public.register_device(uuid, uuid, text, text) from public, anon;
grant execute on function public.register_device(uuid, uuid, text, text) to authenticated;

-- A revoked device's writes are refused: every business write carries an
-- audit row, and the upload is one transaction, so rejecting the audit row
-- rejects the whole change.
drop policy audit_log_insert on public.audit_log;

create policy audit_log_insert on public.audit_log
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and tenant_id in (select private.auth_tenant_ids())
    and not exists (
      select 1 from public.devices d
      where d.id = audit_log.device_id and d.revoked_at is not null
    )
  );

-- Ledger entries come from one of the uploader's devices, not a revoked one.
create or replace function private.guard_ledger_entry()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_original public.ledger_entries;
begin
  new.received_at := now();

  if new.created_at > now() + interval '1 day' then
    raise exception 'created_at is in the future'
      using errcode = '23514';
  end if;

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
      and d.revoked_at is null
  ) then
    raise exception 'ledger entries must come from one of your devices in this business'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- member_invites
-- ---------------------------------------------------------------------------

create table public.member_invites (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- 91 + 10 digits, the form auth.users.phone uses.
  phone text not null check (phone ~ '^91[6-9][0-9]{9}$'),
  full_name text,
  role text not null check (role in ('accountant', 'munshi', 'custom')),
  custom_permissions jsonb not null default '{}'::jsonb
    check (jsonb_typeof(custom_permissions) = 'object'),
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'cancelled', 'expired')),
  expires_at timestamptz not null default now() + interval '14 days',
  accepted_by uuid references public.app_users (id),
  accepted_at timestamptz,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.member_invites is
  'Pending / past invitations. Created only by create_member_invite(), accepted only by accept_member_invites().';

-- One open invite per number per business.
create unique index member_invites_open_idx
  on public.member_invites (tenant_id, phone) where status = 'pending';
create index member_invites_phone_idx
  on public.member_invites (phone) where status = 'pending';
create index member_invites_accepted_by_idx
  on public.member_invites (accepted_by) where accepted_by is not null;

create trigger member_invites_set_updated_at before update on public.member_invites
  for each row execute function private.set_updated_at();
create trigger member_invites_keep_tenant_id before update on public.member_invites
  for each row execute function private.keep_tenant_id();

-- The app may only cancel a pending invite.
create or replace function private.guard_member_invites()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('authenticated', 'anon') then
    if old.status <> 'pending' or new.status <> 'cancelled'
       or (to_jsonb(new) - 'status' - 'updated_at')
          is distinct from (to_jsonb(old) - 'status' - 'updated_at') then
      raise exception 'an invite can only be cancelled' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

create trigger member_invites_guard before update on public.member_invites
  for each row execute function private.guard_member_invites();

alter table public.member_invites enable row level security;

create policy member_invites_select on public.member_invites
  for select to authenticated
  using ((select private.has_permission(tenant_id, 'admin.manage')));

create policy member_invites_update on public.member_invites
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'admin.manage')))
  with check ((select private.has_permission(tenant_id, 'admin.manage')));

revoke all on public.member_invites from anon;
revoke insert, delete, truncate on public.member_invites from authenticated;

alter publication powersync add table public.member_invites;

-- Owner (admin.manage) invites a phone number. Called by the invite-member
-- Edge Function with the owner's own JWT, so RLS-level checks stay in force.
create or replace function public.create_member_invite(
  p_tenant_id uuid,
  p_phone text,
  p_role text,
  p_custom_permissions jsonb default '{}'::jsonb,
  p_full_name text default null,
  p_device_id uuid default null
)
returns public.member_invites
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_phone text := regexp_replace(coalesce(p_phone, ''), '\D', '', 'g');
  v_invite public.member_invites;
  v_device uuid;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not private.has_permission(p_tenant_id, 'admin.manage') then
    raise exception 'only the owner can invite people' using errcode = '42501';
  end if;
  if length(v_phone) = 10 then
    v_phone := '91' || v_phone;
  end if;
  if v_phone !~ '^91[6-9][0-9]{9}$' then
    raise exception 'invalid_phone' using errcode = '22023';
  end if;
  if p_role not in ('accountant', 'munshi', 'custom') then
    raise exception 'invalid_role' using errcode = '22023';
  end if;
  if jsonb_typeof(coalesce(p_custom_permissions, '{}'::jsonb)) <> 'object' then
    raise exception 'invalid_permissions' using errcode = '22023';
  end if;

  if exists (
    select 1
    from public.tenant_members m
    join public.app_users u on u.id = m.user_id
    where m.tenant_id = p_tenant_id and m.is_active
      and regexp_replace(coalesce(u.phone, ''), '\D', '', 'g') = v_phone
  ) then
    raise exception 'already_member' using errcode = 'P0001';
  end if;

  update public.member_invites i set status = 'expired'
    where i.tenant_id = p_tenant_id and i.phone = v_phone
      and i.status = 'pending' and i.expires_at <= now();

  if exists (
    select 1 from public.member_invites i
    where i.tenant_id = p_tenant_id and i.phone = v_phone and i.status = 'pending'
  ) then
    raise exception 'already_invited' using errcode = 'P0001';
  end if;

  insert into public.member_invites (
    id, tenant_id, phone, full_name, role, custom_permissions, created_by
  )
  values (
    gen_random_uuid(), p_tenant_id, v_phone, nullif(trim(p_full_name), ''),
    p_role, coalesce(p_custom_permissions, '{}'::jsonb), v_uid
  )
  returning * into v_invite;

  select d.id into v_device from public.devices d
    where d.id = p_device_id and d.tenant_id = p_tenant_id
      and d.user_id = v_uid and d.revoked_at is null;

  insert into public.audit_log (
    id, tenant_id, table_name, row_id, action, after, user_id, device_id
  )
  values (
    gen_random_uuid(), p_tenant_id, 'member_invites', v_invite.id, 'insert',
    jsonb_build_object(
      'phone', v_invite.phone, 'role', v_invite.role,
      'custom_permissions', v_invite.custom_permissions
    ),
    v_uid, v_device
  );
  return v_invite;
end;
$$;

revoke execute on function public.create_member_invite(uuid, text, text, jsonb, text, uuid)
  from public, anon;
grant execute on function public.create_member_invite(uuid, text, text, jsonb, text, uuid)
  to authenticated;

-- Turns every open invite for the signed-in user's phone number into a
-- membership. Safe to call on every sign-in. Returns the business ids joined.
create or replace function public.accept_member_invites()
returns setof uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_phone text;
  v_invite public.member_invites;
  v_member_id uuid;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  select regexp_replace(coalesce(u.phone, ''), '\D', '', 'g') into v_phone
    from public.app_users u where u.id = v_uid;
  if v_phone is null or v_phone = '' then
    return;
  end if;

  for v_invite in
    select * from public.member_invites i
    where i.phone = v_phone and i.status = 'pending' and i.expires_at > now()
    order by i.created_at
    for update
  loop
    v_member_id := null;
    insert into public.tenant_members (
      id, tenant_id, user_id, role, custom_permissions, created_by
    )
    values (
      gen_random_uuid(), v_invite.tenant_id, v_uid, v_invite.role,
      v_invite.custom_permissions, v_invite.created_by
    )
    on conflict (tenant_id, user_id) do update
      set role = excluded.role,
          custom_permissions = excluded.custom_permissions,
          is_active = true
      where public.tenant_members.role <> 'owner'
    returning id into v_member_id;

    update public.member_invites i
      set status = 'accepted', accepted_by = v_uid, accepted_at = now()
      where i.id = v_invite.id;

    if v_member_id is not null then
      insert into public.audit_log (
        id, tenant_id, table_name, row_id, action, after, user_id
      )
      values (
        gen_random_uuid(), v_invite.tenant_id, 'tenant_members', v_member_id,
        'insert',
        jsonb_build_object(
          'role', v_invite.role,
          'custom_permissions', v_invite.custom_permissions,
          'via', 'invite'
        ),
        v_uid
      );
      return next v_invite.tenant_id;
    end if;
  end loop;
end;
$$;

revoke execute on function public.accept_member_invites() from public, anon;
grant execute on function public.accept_member_invites() to authenticated;
