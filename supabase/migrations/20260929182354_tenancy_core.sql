-- Step 0.3 (1/2): tenancy core — tenants, users, memberships, devices, and the
-- helper functions every RLS policy uses.
--
-- Conventions for every business table (see CLAUDE.md):
--   * uuid primary keys supplied by the client (no default);
--   * tenant_id not null, and it can never change after insert;
--   * created_by is forced to the signed-in user; updated_at kept by trigger;
--   * RLS on, policies for `authenticated` only, and no client deletes.

create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Shared trigger functions
-- ---------------------------------------------------------------------------

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- created_by always records the real caller, whatever the client sent.
create or replace function private.set_created_by()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (select auth.uid()) is not null then
    new.created_by := (select auth.uid());
  end if;
  return new;
end;
$$;

-- A row never moves to another business.
create or replace function private.keep_tenant_id()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.tenant_id is distinct from old.tenant_id then
    raise exception 'tenant_id cannot be changed'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- tenants — one row per business (arhtiya / input shop)
-- ---------------------------------------------------------------------------

create table public.tenants (
  id uuid primary key,
  name text not null check (length(trim(name)) > 0),
  legal_name text,
  gstin text check (gstin is null or gstin ~ '^[0-9]{2}[A-Z0-9]{13}$'),
  address text,
  -- GST state code, e.g. 03 Punjab, 06 Haryana, 08 Rajasthan.
  state_code text check (state_code is null or state_code ~ '^[0-9]{2}$'),
  mandi_name text,
  phone text,
  plan_code text not null default 'trial',
  status text not null default 'trial'
    check (status in ('trial', 'active', 'grace', 'locked', 'cancelled')),
  trial_ends_at timestamptz,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.tenants is
  'A subscribing business. Created by the service role (signup / admin), never by app clients.';

-- Billing fields belong to the SaaS layer (Razorpay webhooks, super-admin),
-- never to the app.
create or replace function private.guard_tenant_billing()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('authenticated', 'anon') and (
    new.id is distinct from old.id
    or new.plan_code is distinct from old.plan_code
    or new.status is distinct from old.status
    or new.trial_ends_at is distinct from old.trial_ends_at
  ) then
    raise exception 'plan and status can only be changed by billing'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger tenants_guard_billing before update on public.tenants
  for each row execute function private.guard_tenant_billing();
create trigger tenants_set_updated_at before update on public.tenants
  for each row execute function private.set_updated_at();
create trigger tenants_set_created_by before insert on public.tenants
  for each row execute function private.set_created_by();

-- ---------------------------------------------------------------------------
-- app_users — profile for each auth user (created automatically)
-- ---------------------------------------------------------------------------

create table public.app_users (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text,
  full_name text,
  preferred_language text not null default 'en'
    check (preferred_language in ('en', 'hi', 'pa')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger app_users_set_updated_at before update on public.app_users
  for each row execute function private.set_updated_at();

create or replace function private.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.app_users (id, phone, full_name)
  values (new.id, new.phone, new.raw_user_meta_data ->> 'full_name')
  on conflict (id) do nothing;
  return new;
end;
$$;

revoke execute on function private.handle_new_auth_user() from public, anon, authenticated;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function private.handle_new_auth_user();

-- ---------------------------------------------------------------------------
-- tenant_members — which users belong to which business, and their role
-- ---------------------------------------------------------------------------

create table public.tenant_members (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  user_id uuid not null references public.app_users (id),
  role text not null check (role in ('owner', 'accountant', 'munshi', 'custom')),
  -- {"permission.key": true|false} overrides the role default.
  custom_permissions jsonb not null default '{}'::jsonb
    check (jsonb_typeof(custom_permissions) = 'object'),
  is_active boolean not null default true,
  device_limit integer not null default 2 check (device_limit between 1 and 50),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, user_id)
);

-- auth_tenant_ids() and has_permission() look members up by user.
create index tenant_members_user_id_idx
  on public.tenant_members (user_id, tenant_id);

create trigger tenant_members_set_updated_at before update on public.tenant_members
  for each row execute function private.set_updated_at();
create trigger tenant_members_set_created_by before insert on public.tenant_members
  for each row execute function private.set_created_by();
create trigger tenant_members_keep_tenant_id before update on public.tenant_members
  for each row execute function private.keep_tenant_id();

-- A business must always keep at least one active owner, and a membership
-- never changes hands.
create or replace function private.guard_tenant_members()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.user_id is distinct from old.user_id then
    raise exception 'user_id cannot be changed' using errcode = '42501';
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

create trigger tenant_members_guard before update on public.tenant_members
  for each row execute function private.guard_tenant_members();

-- ---------------------------------------------------------------------------
-- Access helpers used by every policy
-- ---------------------------------------------------------------------------

-- Businesses the signed-in user is an active member of.
create or replace function private.auth_tenant_ids()
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select m.tenant_id
  from public.tenant_members m
  where m.user_id = (select auth.uid())
    and m.is_active;
$$;

-- Role defaults from docs/domain/ledger-and-mandi.md ("Roles & permissions").
-- Owners have every permission. The app mirrors this table in step 0.6.
create or replace function private.role_allows(p_role text, p_permission text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case p_role
    when 'owner' then true
    when 'accountant' then p_permission in (
      'parties.manage', 'arrivals.manage', 'payments.create',
      'entries.reverse', 'finance.view'
    )
    when 'munshi' then p_permission in (
      'parties.manage', 'arrivals.manage', 'payments.create'
    )
    else false
  end;
$$;

-- Whether the signed-in user may do `p_permission` in `p_tenant_id`:
-- owner → always; else a boolean in custom_permissions wins; else the role
-- default. Non-members and inactive members get false.
create or replace function private.has_permission(p_tenant_id uuid, p_permission text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select case
      when m.role = 'owner' then true
      when jsonb_typeof(m.custom_permissions -> p_permission) = 'boolean'
        then (m.custom_permissions ->> p_permission)::boolean
      else private.role_allows(m.role, p_permission)
    end
    from public.tenant_members m
    where m.tenant_id = p_tenant_id
      and m.user_id = (select auth.uid())
      and m.is_active
  ), false);
$$;

revoke execute on function private.auth_tenant_ids() from public, anon;
revoke execute on function private.role_allows(text, text) from public, anon;
revoke execute on function private.has_permission(uuid, text) from public, anon;
grant execute on function private.auth_tenant_ids() to authenticated;
grant execute on function private.role_allows(text, text) to authenticated;
grant execute on function private.has_permission(uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- devices — each install gets a short per-business code (W1, A3, M2, B1)
-- used in offline document numbers: <series>-<deviceCode>-<counter>.
-- ---------------------------------------------------------------------------

create table public.devices (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  user_id uuid not null references public.app_users (id),
  device_code text not null check (device_code ~ '^[A-Z][0-9]{1,3}$'),
  platform text not null check (platform in ('android', 'windows', 'macos', 'web')),
  name text,
  last_seen_at timestamptz,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, device_code)
);

create index devices_user_id_idx on public.devices (user_id);

create or replace function private.guard_devices()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('authenticated', 'anon') and (
    new.id is distinct from old.id
    or new.user_id is distinct from old.user_id
    or new.device_code is distinct from old.device_code
    or new.platform is distinct from old.platform
  ) then
    raise exception 'device identity cannot be changed' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger devices_guard before update on public.devices
  for each row execute function private.guard_devices();
create trigger devices_keep_tenant_id before update on public.devices
  for each row execute function private.keep_tenant_id();
create trigger devices_set_updated_at before update on public.devices
  for each row execute function private.set_updated_at();
create trigger devices_set_created_by before insert on public.devices
  for each row execute function private.set_created_by();

-- Registers this install for the signed-in user, or returns the existing row.
-- Codes are allocated here, under a per-business lock, so two devices can
-- never get the same code. Needs a connection (first launch is online).
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
  v_prefix text;
  v_next integer;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.tenant_members m
    where m.tenant_id = p_tenant_id and m.user_id = v_uid and m.is_active
  ) then
    raise exception 'not a member of this business' using errcode = '42501';
  end if;

  select * into v_device from public.devices d where d.id = p_device_id;
  if found then
    if v_device.tenant_id <> p_tenant_id or v_device.user_id <> v_uid then
      raise exception 'device is registered to another user or business'
        using errcode = '42501';
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

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table public.tenants enable row level security;
alter table public.app_users enable row level security;
alter table public.tenant_members enable row level security;
alter table public.devices enable row level security;

-- tenants: members read; only owners (admin.manage) edit business details.
-- No insert policy: businesses are created by the service role.
create policy tenants_select on public.tenants
  for select to authenticated
  using (id in (select private.auth_tenant_ids()));

create policy tenants_update on public.tenants
  for update to authenticated
  using ((select private.has_permission(id, 'admin.manage')))
  with check ((select private.has_permission(id, 'admin.manage')));

-- app_users: see yourself and people you work with; edit only yourself.
create policy app_users_select on public.app_users
  for select to authenticated
  using (
    id = (select auth.uid())
    or id in (
      select m.user_id from public.tenant_members m
      where m.tenant_id in (select private.auth_tenant_ids())
    )
  );

create policy app_users_update on public.app_users
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- tenant_members: members see the team; only owners manage it.
create policy tenant_members_select on public.tenant_members
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy tenant_members_insert on public.tenant_members
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'admin.manage')));

create policy tenant_members_update on public.tenant_members
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'admin.manage')))
  with check ((select private.has_permission(tenant_id, 'admin.manage')));

-- devices: members see the business's devices; created only through
-- register_device(); a user may rename / touch only their own device.
create policy devices_select on public.devices
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy devices_update on public.devices
  for update to authenticated
  using (
    user_id = (select auth.uid())
    and tenant_id in (select private.auth_tenant_ids())
  )
  with check (
    user_id = (select auth.uid())
    and tenant_id in (select private.auth_tenant_ids())
  );

-- Defence in depth: anonymous callers get nothing, and nobody deletes.
revoke all on public.tenants, public.app_users, public.tenant_members, public.devices
  from anon;
revoke delete, truncate on public.tenants, public.app_users, public.tenant_members,
  public.devices from authenticated;
