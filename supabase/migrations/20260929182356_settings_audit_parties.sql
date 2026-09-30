-- Step 0.3 (2/2): settings cascade, audit log, parties, number series.
-- Relies on the helpers from the tenancy_core migration.

-- ---------------------------------------------------------------------------
-- settings — one value per (tenant, scope, scope_id, key); see
-- docs/domain/settings-cascade.md. A null value means "inherit".
-- ---------------------------------------------------------------------------

create table public.settings (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  scope text not null
    check (scope in ('tenant', 'party_group', 'party', 'loan', 'lot', 'invoice')),
  scope_id uuid,
  key text not null check (key ~ '^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$'),
  value jsonb,
  updated_by uuid,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint settings_scope_id_matches_scope
    check ((scope = 'tenant') = (scope_id is null)),
  constraint settings_one_value_per_key
    unique nulls not distinct (tenant_id, scope, scope_id, key)
);

create or replace function private.set_updated_by()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (select auth.uid()) is not null then
    new.updated_by := (select auth.uid());
  end if;
  return new;
end;
$$;

create trigger settings_set_updated_at before update on public.settings
  for each row execute function private.set_updated_at();
create trigger settings_set_created_by before insert on public.settings
  for each row execute function private.set_created_by();
create trigger settings_set_updated_by before insert or update on public.settings
  for each row execute function private.set_updated_by();
create trigger settings_keep_tenant_id before update on public.settings
  for each row execute function private.keep_tenant_id();

-- Business-wide values (tenant / party group scope) are owner-only
-- (settings.manage). Interest terms at any scope need loans.manage
-- ("Issue karza, change interest" in the roles table).
create or replace function private.can_write_setting(
  p_tenant_id uuid,
  p_scope text,
  p_key text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_tenant_id in (select private.auth_tenant_ids())
    and (
      p_scope not in ('tenant', 'party_group')
      or private.has_permission(p_tenant_id, 'settings.manage')
    )
    and (
      p_key not like 'interest.%'
      or private.has_permission(p_tenant_id, 'loans.manage')
    );
$$;

revoke execute on function private.can_write_setting(uuid, text, text) from public, anon;
grant execute on function private.can_write_setting(uuid, text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- audit_log — append-only record of every business write
-- ---------------------------------------------------------------------------

create table public.audit_log (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  table_name text not null,
  row_id uuid not null,
  action text not null
    check (action in ('insert', 'update', 'reverse', 'soft_delete', 'restore')),
  before jsonb,
  after jsonb,
  user_id uuid not null,
  device_id uuid references public.devices (id),
  role text,
  -- When the change happened on the device (may be before it synced).
  created_at timestamptz not null default now()
);

create index audit_log_tenant_created_idx on public.audit_log (tenant_id, created_at desc);
create index audit_log_row_idx on public.audit_log (tenant_id, table_name, row_id);
create index audit_log_device_id_idx on public.audit_log (device_id);

create or replace function private.reject_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception '% is append-only', tg_table_name using errcode = '42501';
end;
$$;

create trigger audit_log_append_only before update or delete on public.audit_log
  for each row execute function private.reject_change();

-- The role stored is the member's real role, not whatever the client sent.
create or replace function private.fill_audit_role()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is not null then
    new.role := (
      select m.role from public.tenant_members m
      where m.tenant_id = new.tenant_id and m.user_id = (select auth.uid())
    );
  end if;
  return new;
end;
$$;

revoke execute on function private.fill_audit_role() from public, anon, authenticated;

create trigger audit_log_fill_role before insert on public.audit_log
  for each row execute function private.fill_audit_role();

-- ---------------------------------------------------------------------------
-- parties — farmers, customers, suppliers… one khata each (master data,
-- soft-deleted only)
-- ---------------------------------------------------------------------------

create table public.parties (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  code text not null check (length(trim(code)) > 0),
  name text not null check (length(trim(name)) > 0),
  father_or_husband_name text,
  relation text check (relation in ('s_o', 'd_o', 'w_o', 'prop')),
  village text,
  district text,
  state text,
  -- 10-digit Indian mobile, no +91 / spaces (the app normalises input).
  mobile text check (mobile is null or mobile ~ '^[6-9][0-9]{9}$'),
  alt_mobile text check (alt_mobile is null or alt_mobile ~ '^[6-9][0-9]{9}$'),
  aadhaar_last4 text check (aadhaar_last4 is null or aadhaar_last4 ~ '^[0-9]{4}$'),
  bank_name text,
  bank_account_masked text,
  ifsc text check (ifsc is null or ifsc ~ '^[A-Z]{4}0[A-Z0-9]{6}$'),
  gstin text check (gstin is null or gstin ~ '^[0-9]{2}[A-Z0-9]{13}$'),
  notes text,
  -- Party groups (settings scope `party_group`) get their own table later.
  party_group_id uuid,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint parties_code_unique unique (tenant_id, code),
  -- Lets child tables prove their party is in the same business.
  constraint parties_id_tenant_unique unique (id, tenant_id)
);

create index parties_tenant_name_idx on public.parties (tenant_id, name)
  where deleted_at is null;

create trigger parties_set_updated_at before update on public.parties
  for each row execute function private.set_updated_at();
create trigger parties_set_created_by before insert on public.parties
  for each row execute function private.set_created_by();
create trigger parties_keep_tenant_id before update on public.parties
  for each row execute function private.keep_tenant_id();

-- Deleting (or restoring) master data is owner-only (master.delete).
create or replace function private.guard_soft_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('authenticated', 'anon')
     and new.deleted_at is distinct from old.deleted_at
     and not (select private.has_permission(new.tenant_id, 'master.delete')) then
    raise exception 'deleting % needs the master.delete permission', tg_table_name
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger parties_guard_soft_delete before update on public.parties
  for each row execute function private.guard_soft_delete();

-- ---------------------------------------------------------------------------
-- party_roles — one party can be farmer and customer and buyer…
-- ---------------------------------------------------------------------------

create table public.party_roles (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  party_id uuid not null,
  role text not null
    check (role in ('farmer', 'customer', 'supplier', 'vendor', 'agency', 'buyer')),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint party_roles_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint party_roles_unique unique (party_id, role)
);

create index party_roles_tenant_role_idx on public.party_roles (tenant_id, role);
create index party_roles_party_tenant_idx on public.party_roles (party_id, tenant_id);

create trigger party_roles_set_updated_at before update on public.party_roles
  for each row execute function private.set_updated_at();
create trigger party_roles_set_created_by before insert on public.party_roles
  for each row execute function private.set_created_by();
create trigger party_roles_keep_tenant_id before update on public.party_roles
  for each row execute function private.keep_tenant_id();

-- ---------------------------------------------------------------------------
-- number_series — per business, per series (R, L, SI…), per device counter
-- so offline numbers never collide: R-W1-3008.
-- ---------------------------------------------------------------------------

create table public.number_series (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  series text not null check (series ~ '^[A-Z]{1,4}$'),
  device_code text not null,
  next_value bigint not null default 1 check (next_value > 0),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint number_series_unique unique (tenant_id, series, device_code),
  constraint number_series_device_fk foreign key (tenant_id, device_code)
    references public.devices (tenant_id, device_code)
);

create index number_series_device_idx on public.number_series (tenant_id, device_code);

-- A counter only moves forward; going back would reissue numbers.
create or replace function private.guard_number_series()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.next_value < old.next_value then
    raise exception 'number series cannot go backwards' using errcode = '42501';
  end if;
  if new.series is distinct from old.series
     or new.device_code is distinct from old.device_code then
    raise exception 'number series identity cannot be changed' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger number_series_guard before update on public.number_series
  for each row execute function private.guard_number_series();
create trigger number_series_keep_tenant_id before update on public.number_series
  for each row execute function private.keep_tenant_id();
create trigger number_series_set_updated_at before update on public.number_series
  for each row execute function private.set_updated_at();
create trigger number_series_set_created_by before insert on public.number_series
  for each row execute function private.set_created_by();

-- Only the device's own user advances its counters.
create or replace function private.owns_device(p_tenant_id uuid, p_device_code text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.devices d
    where d.tenant_id = p_tenant_id
      and d.device_code = p_device_code
      and d.user_id = (select auth.uid())
  )
  and p_tenant_id in (select private.auth_tenant_ids());
$$;

revoke execute on function private.owns_device(uuid, text) from public, anon;
grant execute on function private.owns_device(uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table public.settings enable row level security;
alter table public.audit_log enable row level security;
alter table public.parties enable row level security;
alter table public.party_roles enable row level security;
alter table public.number_series enable row level security;

create policy settings_select on public.settings
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy settings_insert on public.settings
  for insert to authenticated
  with check ((select private.can_write_setting(tenant_id, scope, key)));

create policy settings_update on public.settings
  for update to authenticated
  using ((select private.can_write_setting(tenant_id, scope, key)))
  with check ((select private.can_write_setting(tenant_id, scope, key)));

-- audit_log: anyone in the business writes their own rows; reading the log
-- is owner-only (audit.view).
create policy audit_log_select on public.audit_log
  for select to authenticated
  using ((select private.has_permission(tenant_id, 'audit.view')));

create policy audit_log_insert on public.audit_log
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and tenant_id in (select private.auth_tenant_ids())
  );

create policy parties_select on public.parties
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy parties_insert on public.parties
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'parties.manage')));

create policy parties_update on public.parties
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'parties.manage')))
  with check ((select private.has_permission(tenant_id, 'parties.manage')));

create policy party_roles_select on public.party_roles
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy party_roles_insert on public.party_roles
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'parties.manage')));

create policy party_roles_update on public.party_roles
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'parties.manage')))
  with check ((select private.has_permission(tenant_id, 'parties.manage')));

create policy number_series_select on public.number_series
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy number_series_insert on public.number_series
  for insert to authenticated
  with check ((select private.owns_device(tenant_id, device_code)));

create policy number_series_update on public.number_series
  for update to authenticated
  using ((select private.owns_device(tenant_id, device_code)))
  with check ((select private.owns_device(tenant_id, device_code)));

revoke all on public.settings, public.audit_log, public.parties, public.party_roles,
  public.number_series from anon;
revoke delete, truncate on public.settings, public.audit_log, public.parties,
  public.party_roles, public.number_series from authenticated;
-- The audit log is never edited, not even through RLS.
revoke update on public.audit_log from authenticated;
