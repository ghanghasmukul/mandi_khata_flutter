-- Phase 5 (steps 5.1 + 5.3): plans, add-ons, subscriptions, platform
-- settings, plan requests, and the server side of entitlements and the
-- trial / grace / lock lifecycle. Rules: docs/domain/saas-rules.md.
--
-- Everything commercial is DATA here (plans, prices, limits, add-ons, trial
-- and grace lengths): the super-admin edits it with the service role, clients
-- only read it. The lifecycle functions mirror khata_core `Lifecycle` and
-- `Entitlements`; the same worked examples are tested on both sides.

-- ---------------------------------------------------------------------------
-- plans
-- ---------------------------------------------------------------------------

create table public.plans (
  code text primary key check (code ~ '^[a-z][a-z0-9_]*$' and length(code) <= 32),
  -- PowerSync needs an `id` column on every synced table.
  id uuid not null unique default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  description text,
  price_monthly_paise bigint not null default 0 check (price_monthly_paise >= 0),
  price_yearly_paise bigint not null default 0 check (price_yearly_paise >= 0),
  -- null = unlimited
  max_users integer check (max_users is null or max_users >= 1),
  max_devices integer check (max_devices is null or max_devices >= 1),
  modules jsonb not null default '{}'::jsonb check (jsonb_typeof(modules) = 'object'),
  limits jsonb not null default '{}'::jsonb check (jsonb_typeof(limits) = 'object'),
  default_settings jsonb not null default '{}'::jsonb
    check (jsonb_typeof(default_settings) = 'object'),
  is_public boolean not null default false,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.plans is
  'Commercial plans. Edited by the platform (service role); clients read only.';

create trigger plans_set_updated_at before update on public.plans
  for each row execute function private.set_updated_at();

create table public.plan_addons (
  code text primary key check (code ~ '^[a-z][a-z0-9_]*$' and length(code) <= 32),
  id uuid not null unique default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  description text,
  -- per unit bought: {"users": 1}
  grants_limits jsonb not null default '{}'::jsonb
    check (jsonb_typeof(grants_limits) = 'object'),
  -- {"karza": true}
  grants_modules jsonb not null default '{}'::jsonb
    check (jsonb_typeof(grants_modules) = 'object'),
  price_monthly_paise bigint not null default 0 check (price_monthly_paise >= 0),
  price_yearly_paise bigint not null default 0 check (price_yearly_paise >= 0),
  max_quantity integer check (max_quantity is null or max_quantity >= 1),
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger plan_addons_set_updated_at before update on public.plan_addons
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- platform_settings: trial length, grace, signup defaults, ...
-- ---------------------------------------------------------------------------

create table public.platform_settings (
  key text primary key,
  id uuid not null unique default gen_random_uuid(),
  value jsonb not null,
  -- Public keys are readable (and synced) by every signed-in user.
  is_public boolean not null default false,
  description text,
  updated_at timestamptz not null default now()
);

create trigger platform_settings_set_updated_at before update on public.platform_settings
  for each row execute function private.set_updated_at();

create or replace function private.platform_setting(p_key text, p_default jsonb)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select s.value from public.platform_settings s where s.key = p_key),
    p_default);
$$;

revoke execute on function private.platform_setting(text, jsonb) from public, anon;
grant execute on function private.platform_setting(text, jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- tenant_subscriptions: one row per business
-- ---------------------------------------------------------------------------

alter table public.tenants drop constraint tenants_status_check;
alter table public.tenants add constraint tenants_status_check
  check (status in ('trial', 'active', 'past_due', 'grace', 'locked', 'cancelled'));

create table public.tenant_subscriptions (
  tenant_id uuid primary key references public.tenants (id),
  id uuid not null unique default gen_random_uuid(),
  plan_code text not null references public.plans (code),
  billing_cycle text not null default 'monthly'
    check (billing_cycle in ('monthly', 'yearly')),
  status text not null default 'trial'
    check (status in ('trial', 'active', 'past_due', 'grace', 'locked', 'cancelled')),
  trial_ends_at timestamptz,
  current_period_start timestamptz,
  -- null on an active plan = no end (a complimentary account)
  current_period_end timestamptz,
  grace_days integer not null default 7 check (grace_days between 0 and 365),
  -- set by the super-admin to extend grace to an exact moment
  grace_until timestamptz,
  cancelled_at timestamptz,
  cancelled_readonly_days integer not null default 90
    check (cancelled_readonly_days between 0 and 3650),
  -- [{"code": "extra_user", "qty": 2}]
  addons jsonb not null default '[]'::jsonb check (jsonb_typeof(addons) = 'array'),
  -- {"modules": {"shop": true}, "limits": {"users": 10, "parties": null}}
  overrides jsonb not null default '{}'::jsonb check (jsonb_typeof(overrides) = 'object'),
  discount_pct numeric(5, 2) not null default 0 check (discount_pct between 0 and 100),
  discount_note text,
  -- empty until Razorpay is wired (step 5.2, deferred)
  razorpay_customer_id text,
  razorpay_subscription_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index tenant_subscriptions_plan_code_idx
  on public.tenant_subscriptions (plan_code);

create trigger tenant_subscriptions_set_updated_at
  before update on public.tenant_subscriptions
  for each row execute function private.set_updated_at();

-- tenants.plan_code / status / trial_ends_at mirror the subscription (the
-- billing fields only this layer may change).
create or replace function private.mirror_subscription_to_tenant()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.tenants t
    set plan_code = new.plan_code,
        status = new.status,
        trial_ends_at = new.trial_ends_at
    where t.id = new.tenant_id
      and (t.plan_code, t.status, t.trial_ends_at)
        is distinct from (new.plan_code, new.status, new.trial_ends_at);
  return new;
end;
$$;

revoke execute on function private.mirror_subscription_to_tenant()
  from public, anon, authenticated;

create trigger tenant_subscriptions_mirror
  after insert or update on public.tenant_subscriptions
  for each row execute function private.mirror_subscription_to_tenant();

-- Every new business gets a subscription row (service role, signup, seeds).
create or replace function private.create_subscription_for_new_tenant()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_plan text;
  v_status text := coalesce(new.status, 'trial');
begin
  select p.code into v_plan from public.plans p where p.code = coalesce(new.plan_code, 'trial');
  insert into public.tenant_subscriptions (
    tenant_id, plan_code, status, trial_ends_at, grace_days, cancelled_readonly_days
  )
  values (
    new.id,
    coalesce(v_plan, 'trial'),
    v_status,
    case when v_status = 'trial' then coalesce(
      new.trial_ends_at,
      now() + make_interval(days => (private.platform_setting('trial_days', '14'::jsonb))::text::int)
    ) else new.trial_ends_at end,
    (private.platform_setting('grace_days', '7'::jsonb))::text::int,
    (private.platform_setting('cancelled_readonly_days', '90'::jsonb))::text::int
  )
  on conflict (tenant_id) do nothing;
  return new;
end;
$$;

revoke execute on function private.create_subscription_for_new_tenant()
  from public, anon, authenticated;

create trigger tenants_zz_subscription after insert on public.tenants
  for each row execute function private.create_subscription_for_new_tenant();

-- ---------------------------------------------------------------------------
-- plan_requests: an owner asks for a plan change (manual billing for now)
-- ---------------------------------------------------------------------------

create table public.plan_requests (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  requested_plan_code text references public.plans (code),
  billing_cycle text check (billing_cycle in ('monthly', 'yearly')),
  -- [{"code": "extra_user", "qty": 1}]
  addons jsonb not null default '[]'::jsonb check (jsonb_typeof(addons) = 'array'),
  note text,
  status text not null default 'pending'
    check (status in ('pending', 'done', 'rejected')),
  handled_note text,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index plan_requests_tenant_idx on public.plan_requests (tenant_id, created_at desc);
create index plan_requests_plan_idx on public.plan_requests (requested_plan_code);

create trigger plan_requests_set_updated_at before update on public.plan_requests
  for each row execute function private.set_updated_at();
create trigger plan_requests_set_created_by before insert on public.plan_requests
  for each row execute function private.set_created_by();
create trigger plan_requests_keep_tenant_id before update on public.plan_requests
  for each row execute function private.keep_tenant_id();

-- An owner may only create pending requests; only the platform handles them.
create or replace function private.guard_plan_requests()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is not null then
    if tg_op = 'INSERT' and new.status <> 'pending' then
      raise exception 'a request starts as pending' using errcode = '42501';
    end if;
    if tg_op = 'UPDATE' then
      raise exception 'requests are handled by the platform' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_plan_requests() from public, anon, authenticated;
create trigger plan_requests_guard before insert or update on public.plan_requests
  for each row execute function private.guard_plan_requests();

-- ---------------------------------------------------------------------------
-- Lifecycle and entitlements (mirror khata_core Lifecycle / Entitlements)
-- ---------------------------------------------------------------------------

-- 'full' | 'read_only' | 'export_only' at p_now. No subscription row = full
-- (never brick a business over missing data).
create or replace function private.tenant_access(p_tenant_id uuid, p_now timestamptz default now())
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select case s.status
      when 'trial' then
        case when s.trial_ends_at is not null and p_now < s.trial_ends_at
          then 'full' else 'read_only' end
      when 'locked' then 'read_only'
      when 'cancelled' then
        case when s.cancelled_at is not null
          and p_now < s.cancelled_at + make_interval(days => s.cancelled_readonly_days)
          then 'read_only' else 'export_only' end
      else -- active, past_due, grace
        case
          when s.status = 'active'
            and (s.current_period_end is null or p_now <= s.current_period_end)
            then 'full'
          when coalesce(
            s.grace_until,
            s.current_period_end + make_interval(days => s.grace_days)
          ) is null then 'full'
          when p_now < coalesce(
            s.grace_until,
            s.current_period_end + make_interval(days => s.grace_days)
          ) then 'full'
          else 'read_only'
        end
    end
    from public.tenant_subscriptions s
    where s.tenant_id = p_tenant_id
  ), 'full');
$$;

revoke execute on function private.tenant_access(uuid, timestamptz) from public, anon;
grant execute on function private.tenant_access(uuid, timestamptz) to authenticated;

-- {"modules": {...}, "limits": {...}} for a business: plan, then add-ons,
-- then overrides. A missing module is off, a missing limit unlimited.
create or replace function private.tenant_entitlements(p_tenant_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  s public.tenant_subscriptions;
  p public.plans;
  v_modules jsonb;
  v_limits jsonb;
  v_item jsonb;
  v_addon public.plan_addons;
  v_qty int;
  e record;
begin
  select * into s from public.tenant_subscriptions where tenant_id = p_tenant_id;
  if not found then
    return jsonb_build_object('modules', '{}'::jsonb, 'limits', '{}'::jsonb);
  end if;
  select * into p from public.plans where code = s.plan_code;
  if not found then
    return jsonb_build_object('modules', '{}'::jsonb, 'limits', '{}'::jsonb);
  end if;

  v_modules := p.modules;
  v_limits := p.limits;
  if p.max_users is not null then
    v_limits := v_limits || jsonb_build_object('users', p.max_users);
  elsif not (v_limits ? 'users') then
    v_limits := v_limits || jsonb_build_object('users', null);
  end if;
  if p.max_devices is not null then
    v_limits := v_limits || jsonb_build_object('devices', p.max_devices);
  elsif not (v_limits ? 'devices') then
    v_limits := v_limits || jsonb_build_object('devices', null);
  end if;

  for v_item in select value from jsonb_array_elements(s.addons) loop
    select * into v_addon from public.plan_addons a where a.code = v_item ->> 'code';
    if not found then continue; end if;
    begin
      v_qty := (v_item ->> 'qty')::int;
    exception when others then
      v_qty := 0;
    end;
    if v_qty is null or v_qty <= 0 then continue; end if;
    if v_addon.max_quantity is not null and v_qty > v_addon.max_quantity then
      v_qty := v_addon.max_quantity;
    end if;
    for e in select key, value from jsonb_each(v_addon.grants_modules) loop
      if e.value = 'true'::jsonb then
        v_modules := v_modules || jsonb_build_object(e.key, true);
      end if;
    end loop;
    for e in select key, value from jsonb_each(v_addon.grants_limits) loop
      if v_limits ? e.key and jsonb_typeof(v_limits -> e.key) = 'number'
         and jsonb_typeof(e.value) = 'number' then
        v_limits := v_limits || jsonb_build_object(
          e.key, (v_limits ->> e.key)::bigint + (e.value #>> '{}')::bigint * v_qty);
      end if;
    end loop;
  end loop;

  for e in select key, value from jsonb_each(coalesce(s.overrides -> 'modules', '{}'::jsonb)) loop
    if jsonb_typeof(e.value) = 'boolean' then
      v_modules := v_modules || jsonb_build_object(e.key, e.value);
    end if;
  end loop;
  for e in select key, value from jsonb_each(coalesce(s.overrides -> 'limits', '{}'::jsonb)) loop
    if jsonb_typeof(e.value) = 'null'
       or (jsonb_typeof(e.value) = 'number' and (e.value #>> '{}')::numeric >= 0) then
      v_limits := v_limits || jsonb_build_object(e.key, e.value);
    end if;
  end loop;

  return jsonb_build_object('modules', v_modules, 'limits', v_limits);
end;
$$;

revoke execute on function private.tenant_entitlements(uuid) from public, anon;
grant execute on function private.tenant_entitlements(uuid) to authenticated;

-- null = unlimited
create or replace function private.tenant_limit(p_tenant_id uuid, p_key text)
returns bigint
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when jsonb_typeof(private.tenant_entitlements(p_tenant_id) -> 'limits' -> p_key) = 'number'
      then (private.tenant_entitlements(p_tenant_id) -> 'limits' ->> p_key)::bigint
    else null
  end;
$$;

create or replace function private.tenant_module_on(p_tenant_id uuid, p_module text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (private.tenant_entitlements(p_tenant_id) -> 'modules' ->> p_module)::boolean,
    false);
$$;

revoke execute on function private.tenant_limit(uuid, text) from public, anon;
revoke execute on function private.tenant_module_on(uuid, text) from public, anon;
grant execute on function private.tenant_limit(uuid, text) to authenticated;
grant execute on function private.tenant_module_on(uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Write lock + module gate on every business table
-- ---------------------------------------------------------------------------

-- Which module a table belongs to (data, not code). Tables not listed are
-- base khata and need only a writable subscription.
create table private.module_tables (
  table_name text primary key,
  module text not null
);

insert into private.module_tables (table_name, module) values
  ('lots', 'arrivals'),
  ('loans', 'karza'),
  ('loan_rate_changes', 'karza'),
  ('interest_postings', 'karza'),
  ('vouchers', 'accounting'),
  ('expenses', 'accounting'),
  ('recurring_expenses', 'accounting'),
  ('bank_statement_lines', 'accounting'),
  ('bank_reconciliations', 'accounting'),
  ('product_categories', 'shop'),
  ('products', 'shop'),
  ('batches', 'shop'),
  ('stock_movements', 'shop'),
  ('purchases', 'shop'),
  ('purchase_lines', 'shop'),
  ('purchase_returns', 'shop'),
  ('purchase_return_lines', 'shop'),
  ('shop_sales', 'shop'),
  ('shop_sale_lines', 'shop'),
  ('shop_returns', 'shop'),
  ('shop_return_lines', 'shop');

revoke all on private.module_tables from public, anon, authenticated;

-- Refuses a signed-in user's insert / update when the business is read-only
-- or the table's module is not in the plan. Work done by other triggers
-- (seeds, caches: trigger depth > 1) and by the service role is left alone.
create or replace function private.guard_subscription_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_module text;
begin
  if (select auth.uid()) is null or pg_trigger_depth() > 1 then
    return new;
  end if;
  if private.tenant_access(new.tenant_id) <> 'full' then
    raise exception 'subscription_locked' using errcode = '42501';
  end if;
  select m.module into v_module from private.module_tables m
    where m.table_name = tg_table_name;
  if v_module is not null and not private.tenant_module_on(new.tenant_id, v_module) then
    raise exception 'module_not_in_plan' using errcode = '42501',
      detail = v_module;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_subscription_write() from public, anon, authenticated;

do $$
declare
  t record;
begin
  for t in
    select c.table_name
    from information_schema.columns c
    join information_schema.tables tb
      on tb.table_schema = c.table_schema and tb.table_name = c.table_name
    where c.table_schema = 'public'
      and c.column_name = 'tenant_id'
      and tb.table_type = 'BASE TABLE'
      and c.table_name not in (
        'tenants', 'tenant_members', 'devices', 'member_invites', 'audit_log',
        'number_series', 'plan_requests', 'tenant_subscriptions'
      )
  loop
    execute format(
      'create trigger %I before insert or update on public.%I '
      'for each row execute function private.guard_subscription_write()',
      'aa_' || t.table_name || '_subscription_guard', t.table_name);
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Limits: users, devices, parties
-- ---------------------------------------------------------------------------

create or replace function private.guard_user_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_limit bigint;
  v_used bigint;
begin
  if (select auth.uid()) is null then
    return new;
  end if;
  if tg_table_name = 'tenant_members' then
    -- Only adding or re-activating a member takes a seat.
    if not new.is_active then
      return new;
    end if;
    if tg_op = 'UPDATE' then
      if old.is_active then
        return new;
      end if;
    end if;
  end if;
  v_limit := private.tenant_limit(new.tenant_id, 'users');
  if v_limit is null then
    return new;
  end if;
  -- A member being added counts; for a new invite the open invites count
  -- too (they reserve a seat). An accepted invite is no longer open.
  select
    (select count(*) from public.tenant_members m
       where m.tenant_id = new.tenant_id and m.is_active
         and m.id is distinct from new.id)
    + case when tg_table_name = 'member_invites' then
        (select count(*) from public.member_invites i
           where i.tenant_id = new.tenant_id and i.status = 'pending'
             and i.expires_at > now() and i.id is distinct from new.id)
      else 0 end
  into v_used;
  if v_used >= v_limit then
    raise exception 'limit_reached:users' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_user_limit() from public, anon, authenticated;

create trigger tenant_members_user_limit before insert or update on public.tenant_members
  for each row execute function private.guard_user_limit();
create trigger member_invites_user_limit before insert on public.member_invites
  for each row execute function private.guard_user_limit();

create or replace function private.guard_device_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_limit bigint := private.tenant_limit(new.tenant_id, 'devices');
begin
  if (select auth.uid()) is null or v_limit is null then
    return new;
  end if;
  if (select count(*) from public.devices d
      where d.tenant_id = new.tenant_id and d.revoked_at is null) >= v_limit then
    raise exception 'device_limit_reached' using errcode = 'P0001',
      detail = 'plan';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_device_limit() from public, anon, authenticated;
create trigger devices_plan_limit before insert on public.devices
  for each row execute function private.guard_device_limit();

create or replace function private.guard_party_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_limit bigint;
begin
  if (select auth.uid()) is null or pg_trigger_depth() > 1 then
    return new;
  end if;
  v_limit := private.tenant_limit(new.tenant_id, 'parties');
  if v_limit is null then
    return new;
  end if;
  if (select count(*) from public.parties p
      where p.tenant_id = new.tenant_id and p.deleted_at is null) >= v_limit then
    raise exception 'limit_reached:parties' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_party_limit() from public, anon, authenticated;
create trigger parties_plan_limit before insert on public.parties
  for each row execute function private.guard_party_limit();

-- ---------------------------------------------------------------------------
-- RLS: clients read, the platform writes
-- ---------------------------------------------------------------------------

alter table public.plans enable row level security;
alter table public.plan_addons enable row level security;
alter table public.platform_settings enable row level security;
alter table public.tenant_subscriptions enable row level security;
alter table public.plan_requests enable row level security;

create policy plans_select on public.plans
  for select to authenticated using (true);
create policy plan_addons_select on public.plan_addons
  for select to authenticated using (true);
create policy platform_settings_select on public.platform_settings
  for select to authenticated using (is_public);

create policy tenant_subscriptions_select on public.tenant_subscriptions
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy plan_requests_select on public.plan_requests
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));
create policy plan_requests_insert on public.plan_requests
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'admin.manage')));

revoke all on public.plans, public.plan_addons, public.platform_settings,
  public.tenant_subscriptions, public.plan_requests from anon;
revoke insert, update, delete, truncate on public.plans, public.plan_addons,
  public.platform_settings, public.tenant_subscriptions from authenticated;
revoke update, delete, truncate on public.plan_requests from authenticated;

-- ---------------------------------------------------------------------------
-- Seeds (placeholders; the super-admin edits every value)
-- ---------------------------------------------------------------------------

insert into public.platform_settings (key, value, is_public, description) values
  ('trial_days', '14', false, 'Length of a new business''s trial'),
  ('grace_days', '7', false, 'Full access after a renewal date passes'),
  ('cancelled_readonly_days', '90', false, 'Read-only days after cancelling, then export only'),
  ('offline_tolerance_days', '7', true, 'A device that could not sync keeps working this long past the lock'),
  ('max_businesses_per_user', '3', false, 'Businesses one person may create'),
  ('signup_enabled', 'true', true, 'Self-serve signup on or off'),
  ('signup.trial_plan.arhtiya', '"trial"', false, 'Plan code for the trial of an arhtiya'),
  ('signup.trial_plan.shop', '"trial"', false, 'Plan code for the trial of an input shop'),
  ('signup.trial_plan.both', '"trial"', false, 'Plan code for the trial of both')
on conflict (key) do nothing;

insert into public.plans (code, name, description, max_users, max_devices, modules,
  limits, is_public, sort_order) values
  ('trial', 'Free trial', 'Everything, for a few days', 5, 5,
   '{"khata":true,"arrivals":true,"karza":true,"accounting":true,"shop":true}',
   '{}', false, 0),
  ('mandi_basic', 'Mandi Basic', 'Khata, arrivals and payments', 2, 2,
   '{"khata":true,"arrivals":true}', '{"parties":2000}', true, 10),
  ('mandi_pro', 'Mandi Pro', 'Adds karza and byaj, and accounting', 5, 5,
   '{"khata":true,"arrivals":true,"karza":true,"accounting":true}', '{}', true, 20),
  ('shop', 'Input Shop', 'Point of sale, stock and GST for an input shop', 3, 3,
   '{"khata":true,"shop":true}', '{}', true, 30),
  ('combo', 'Combo', 'Everything', 8, 8,
   '{"khata":true,"arrivals":true,"karza":true,"accounting":true,"shop":true}',
   '{}', true, 40)
on conflict (code) do nothing;

insert into public.plan_addons (code, name, description, grants_limits, sort_order) values
  ('extra_user', 'Extra user', 'One more person on the account', '{"users":1}', 10),
  ('extra_device', 'Extra device', 'One more phone or computer', '{"devices":1}', 20)
on conflict (code) do nothing;

-- Existing businesses get a subscription (a fresh trial window for those
-- still on trial; the plan keeps its name).
insert into public.tenant_subscriptions (
  tenant_id, plan_code, status, trial_ends_at, grace_days, cancelled_readonly_days
)
select t.id,
  case when exists (select 1 from public.plans p where p.code = t.plan_code)
    then t.plan_code else 'trial' end,
  t.status,
  case when t.status = 'trial'
    then coalesce(t.trial_ends_at, now() + interval '14 days') else t.trial_ends_at end,
  7, 90
from public.tenants t
on conflict (tenant_id) do nothing;

-- ---------------------------------------------------------------------------
-- Sync
-- ---------------------------------------------------------------------------

alter publication powersync add table public.plans, public.plan_addons,
  public.platform_settings, public.tenant_subscriptions, public.plan_requests;
