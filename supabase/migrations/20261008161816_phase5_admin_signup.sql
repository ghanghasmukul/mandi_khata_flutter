-- Phase 5 (steps 5.4 + 5.5): super-admin data and self-serve signup.
-- Rules: docs/domain/saas-rules.md sections 4 to 6.
--
-- Admin tables have RLS on and NO client policy: only the service role
-- (the `admin-api` Edge Function, after it checks platform_admins) touches
-- them. Customers read announcements and the support sessions about them.

-- ---------------------------------------------------------------------------
-- Super-admin identity and audit
-- ---------------------------------------------------------------------------

create table public.platform_admins (
  user_id uuid primary key references auth.users (id) on delete cascade,
  email text,
  created_at timestamptz not null default now()
);

create table public.admin_audit_log (
  id uuid primary key default gen_random_uuid(),
  admin_user_id uuid not null,
  admin_email text,
  action text not null,
  target_tenant_id uuid,
  target_type text,
  target_id text,
  before jsonb,
  after jsonb,
  note text,
  created_at timestamptz not null default now()
);

create index admin_audit_log_tenant_idx
  on public.admin_audit_log (target_tenant_id, created_at desc);
create index admin_audit_log_created_idx on public.admin_audit_log (created_at desc);

create trigger admin_audit_log_append_only before update or delete on public.admin_audit_log
  for each row execute function private.reject_change();

alter table public.platform_admins enable row level security;
alter table public.admin_audit_log enable row level security;
revoke all on public.platform_admins, public.admin_audit_log from anon, authenticated;

-- ---------------------------------------------------------------------------
-- Templates: crop master, state presets, referral codes, announcements
-- ---------------------------------------------------------------------------

create table public.crop_master (
  code text primary key check (code ~ '^[a-z][a-z0-9_]*$' and length(code) <= 24),
  name_en text not null check (length(trim(name_en)) > 0),
  name_hi text,
  name_pa text,
  msp_or_std_rate bigint check (msp_or_std_rate is null or msp_or_std_rate >= 0),
  sort_order integer not null default 0,
  is_active boolean not null default true,
  updated_at timestamptz not null default now()
);

create trigger crop_master_set_updated_at before update on public.crop_master
  for each row execute function private.set_updated_at();

-- The crops every new business starts with: the former hard-coded seed,
-- now data the super-admin edits.
insert into public.crop_master (code, name_en, name_hi, name_pa, msp_or_std_rate, sort_order) values
  ('wheat',        'Wheat',               'गेहूं',             'ਕਣਕ',             258500, 10),
  ('paddy_pr126',  'Paddy PR-126',        'धान PR-126',       'ਝੋਨਾ PR-126',       236900, 20),
  ('paddy_1509',   'Paddy 1509 (Basmati)', 'धान 1509 (बासमती)', 'ਝੋਨਾ 1509 (ਬਾਸਮਤੀ)', null,   30),
  ('paddy_1121',   'Paddy 1121 (Basmati)', 'धान 1121 (बासमती)', 'ਝੋਨਾ 1121 (ਬਾਸਮਤੀ)', null,   40),
  ('mustard',      'Mustard',             'सरसों',             'ਸਰ੍ਹੋਂ',             620000, 50),
  ('cotton_narma', 'Cotton (Narma)',      'कपास (नरमा)',       'ਕਪਾਹ (ਨਰਮਾ)',       771000, 60),
  ('guar',         'Guar',                'ग्वार',              'ਗੁਆਰਾ',            null,   70),
  ('bajra',        'Bajra',               'बाजरा',             'ਬਾਜਰਾ',            277500, 80),
  ('moong',        'Moong',               'मूंग',               'ਮੂੰਗੀ',             876800, 90),
  ('chana',        'Chana',               'चना',               'ਛੋਲੇ',              587500, 100),
  ('maize',        'Maize',               'मक्का',              'ਮੱਕੀ',              240000, 110);

create or replace function private.seed_default_crops(p_tenant_id uuid)
returns void
language sql
set search_path = ''
as $$
  insert into public.crops (id, tenant_id, code, name_en, name_hi, name_pa,
    msp_or_std_rate, sort_order)
  select
    extensions.uuid_generate_v5(
      '3d8f2a6e-4c1b-4f0a-9b7e-5a2c8d1e6f30'::uuid, p_tenant_id::text || '|' || c.code),
    p_tenant_id, c.code, c.name_en, c.name_hi, c.name_pa, c.msp_or_std_rate, c.sort_order
  from public.crop_master c
  where c.is_active
  on conflict (tenant_id, code) do nothing;
$$;

revoke execute on function private.seed_default_crops(uuid) from public, anon, authenticated;

-- Adds crops the master has and a business lacks (optionally refreshing the
-- reference rate of crops it has). Never removes or renames a business's own
-- crop. Returns how many crops were added. Service role only.
create or replace function public.push_crop_master(p_update_rates boolean default false)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_before integer;
  v_after integer;
  t record;
begin
  select count(*) into v_before from public.crops;
  for t in select id from public.tenants loop
    perform private.seed_default_crops(t.id);
  end loop;
  if p_update_rates then
    update public.crops c set msp_or_std_rate = m.msp_or_std_rate
      from public.crop_master m
      where m.code = c.code and m.is_active
        and m.msp_or_std_rate is distinct from c.msp_or_std_rate;
  end if;
  select count(*) into v_after from public.crops;
  return v_after - v_before;
end;
$$;

revoke execute on function public.push_crop_master(boolean) from public, anon, authenticated;
grant execute on function public.push_crop_master(boolean) to service_role;

-- Settings copied into a new business of a state (docs: saas-rules.md 5).
-- Values are validated by the app when it reads them: an invalid value
-- counts as "inherit". Fee schedules differ by year and commodity, so the
-- seeded presets are empty until the super-admin fills them in.
create table public.state_presets (
  state_code text primary key check (state_code ~ '^[0-9]{2}$'),
  name text not null check (length(trim(name)) > 0),
  settings jsonb not null default '{}'::jsonb check (jsonb_typeof(settings) = 'object'),
  is_active boolean not null default true,
  updated_at timestamptz not null default now()
);

create trigger state_presets_set_updated_at before update on public.state_presets
  for each row execute function private.set_updated_at();

insert into public.state_presets (state_code, name) values
  ('03', 'Punjab'), ('06', 'Haryana'), ('08', 'Rajasthan');

create table public.referral_codes (
  code text primary key check (code = upper(code) and code ~ '^[A-Z0-9_-]{3,24}$'),
  owner_name text not null,
  commission_pct numeric(5, 2) not null default 0 check (commission_pct between 0 and 100),
  is_active boolean not null default true,
  note text,
  created_at timestamptz not null default now()
);

create table public.announcements (
  id uuid primary key default gen_random_uuid(),
  title_en text not null check (length(trim(title_en)) > 0),
  title_hi text,
  title_pa text,
  body_en text not null default '',
  body_hi text,
  body_pa text,
  severity text not null default 'info' check (severity in ('info', 'warning', 'critical')),
  -- null = every customer; else only customers on one of these plans.
  -- Announcements are visible to every customer's device: never put private
  -- information in one.
  plan_codes text[],
  starts_at timestamptz,
  ends_at timestamptz,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger announcements_set_updated_at before update on public.announcements
  for each row execute function private.set_updated_at();

-- Read-only support access to a business, recorded where the customer can see it.
create table public.support_sessions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id),
  admin_user_id uuid not null,
  admin_label text not null,
  reason text not null check (length(trim(reason)) > 0),
  started_at timestamptz not null default now(),
  ended_at timestamptz
);

create index support_sessions_tenant_idx
  on public.support_sessions (tenant_id, started_at desc);

alter table public.crop_master enable row level security;
alter table public.state_presets enable row level security;
alter table public.referral_codes enable row level security;
alter table public.announcements enable row level security;
alter table public.support_sessions enable row level security;

create policy announcements_select on public.announcements
  for select to authenticated using (is_active);
create policy support_sessions_select on public.support_sessions
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

revoke all on public.crop_master, public.state_presets, public.referral_codes,
  public.announcements, public.support_sessions from anon;
revoke all on public.crop_master, public.state_presets, public.referral_codes
  from authenticated;
revoke insert, update, delete, truncate on public.announcements,
  public.support_sessions from authenticated;

-- ---------------------------------------------------------------------------
-- Businesses: how they signed up
-- ---------------------------------------------------------------------------

alter table public.tenants
  add column business_type text check (business_type in ('arhtiya', 'shop', 'both')),
  add column referral_code text,
  add column referral_valid boolean not null default false;

create index tenants_referral_code_idx on public.tenants (referral_code)
  where referral_code is not null;

-- Referral and business type are decided at signup; owners edit neither.
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
    or new.business_type is distinct from old.business_type
    or new.referral_code is distinct from old.referral_code
    or new.referral_valid is distinct from old.referral_valid
  ) then
    raise exception 'plan and status can only be changed by billing'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Self-serve signup (step 5.5)
-- ---------------------------------------------------------------------------

create or replace function public.signup_business(
  p_tenant_id uuid,
  p_name text,
  p_state_code text,
  p_mandi_name text,
  p_business_type text,
  p_phone text default null,
  p_referral_code text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_name text := nullif(trim(p_name), '');
  v_ref text := nullif(upper(trim(coalesce(p_referral_code, ''))), '');
  v_plan text;
  v_max integer;
  v_owned integer;
  v_ns constant uuid := '6f1c0a52-3b0e-4f7e-9d58-2f3c1c6a9e41'::uuid;
  s record;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_tenant_id is null then
    raise exception 'tenant id is required' using errcode = '22023';
  end if;

  -- A retry of the same signup returns the same business.
  if exists (
    select 1 from public.tenant_members m
    where m.tenant_id = p_tenant_id and m.user_id = v_uid and m.role = 'owner'
  ) then
    return p_tenant_id;
  end if;
  if exists (select 1 from public.tenants t where t.id = p_tenant_id) then
    raise exception 'business id is taken' using errcode = '42501';
  end if;

  if private.platform_setting('signup_enabled', 'true'::jsonb) <> 'true'::jsonb then
    raise exception 'signup_closed' using errcode = 'P0001';
  end if;
  if v_name is null then
    raise exception 'business name is required' using errcode = '22023';
  end if;
  if p_business_type is null or p_business_type not in ('arhtiya', 'shop', 'both') then
    raise exception 'business type must be arhtiya, shop or both' using errcode = '22023';
  end if;
  if p_state_code is null or p_state_code !~ '^[0-9]{2}$' then
    raise exception 'state code must be two digits' using errcode = '22023';
  end if;

  v_max := (private.platform_setting('max_businesses_per_user', '3'::jsonb))::text::int;
  select count(*) into v_owned from public.tenant_members m
    where m.user_id = v_uid and m.role = 'owner';
  if v_owned >= v_max then
    raise exception 'signup_limit' using errcode = 'P0001';
  end if;

  select p.code into v_plan from public.plans p
    where p.code = trim(both '"' from private.platform_setting(
      'signup.trial_plan.' || p_business_type, '"trial"'::jsonb)::text)
      and p.is_active;
  v_plan := coalesce(v_plan, 'trial');

  insert into public.tenants (
    id, name, state_code, mandi_name, phone, plan_code, status,
    business_type, referral_code, referral_valid
  )
  values (
    p_tenant_id, v_name, p_state_code, nullif(trim(coalesce(p_mandi_name, '')), ''),
    nullif(trim(coalesce(p_phone, '')), ''), v_plan, 'trial', p_business_type, v_ref,
    v_ref is not null and exists (
      select 1 from public.referral_codes r where r.code = v_ref and r.is_active)
  );

  insert into public.tenant_members (id, tenant_id, user_id, role, created_by)
  values (gen_random_uuid(), p_tenant_id, v_uid, 'owner', v_uid);

  -- State preset: copied once into the business's own settings, which it
  -- then owns. Business type: switch off the modules it will not use.
  for s in
    select e.key, e.value from public.state_presets sp,
      jsonb_each(sp.settings) e
    where sp.state_code = p_state_code and sp.is_active
  loop
    insert into public.settings (id, tenant_id, scope, scope_id, key, value, updated_by, created_by)
    values (
      extensions.uuid_generate_v5(v_ns, p_tenant_id::text || '|tenant||' || s.key),
      p_tenant_id, 'tenant', null, s.key, s.value, v_uid, v_uid)
    on conflict do nothing;
  end loop;

  for s in
    select k as key from unnest(case p_business_type
      when 'arhtiya' then array['app.modules.shop']
      when 'shop' then array['app.modules.arrivals', 'app.modules.karza']
      else array[]::text[] end) k
  loop
    insert into public.settings (id, tenant_id, scope, scope_id, key, value, updated_by, created_by)
    values (
      extensions.uuid_generate_v5(v_ns, p_tenant_id::text || '|tenant||' || s.key),
      p_tenant_id, 'tenant', null, s.key, 'false'::jsonb, v_uid, v_uid)
    on conflict do nothing;
  end loop;

  insert into public.audit_log (id, tenant_id, table_name, row_id, action, after, user_id, role)
  values (
    gen_random_uuid(), p_tenant_id, 'tenants', p_tenant_id, 'insert',
    jsonb_build_object('name', v_name, 'business_type', p_business_type,
      'plan_code', v_plan, 'referral_code', v_ref, 'via', 'signup'),
    v_uid, 'owner');

  return p_tenant_id;
end;
$$;

revoke execute on function public.signup_business(uuid, text, text, text, text, text, text)
  from public, anon;
grant execute on function public.signup_business(uuid, text, text, text, text, text, text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- Admin overview: one row per business (service role only)
-- ---------------------------------------------------------------------------

create or replace function public.admin_tenant_overview()
returns table (
  tenant_id uuid,
  name text,
  state_code text,
  business_type text,
  referral_code text,
  created_at timestamptz,
  plan_code text,
  billing_cycle text,
  status text,
  access text,
  trial_ends_at timestamptz,
  current_period_end timestamptz,
  users bigint,
  devices bigint,
  parties bigint,
  ledger_entries bigint,
  last_seen_at timestamptz,
  mrr_paise bigint
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    t.id, t.name, t.state_code, t.business_type, t.referral_code, t.created_at,
    s.plan_code, s.billing_cycle, s.status, private.tenant_access(t.id),
    s.trial_ends_at, s.current_period_end,
    (select count(*) from public.tenant_members m where m.tenant_id = t.id and m.is_active),
    (select count(*) from public.devices d where d.tenant_id = t.id and d.revoked_at is null),
    (select count(*) from public.parties p where p.tenant_id = t.id and p.deleted_at is null),
    (select count(*) from public.ledger_entries e where e.tenant_id = t.id),
    (select max(d.last_seen_at) from public.devices d where d.tenant_id = t.id),
    case when s.status = 'active' then
      round((
        (case s.billing_cycle when 'yearly' then p2.price_yearly_paise / 12.0
           else p2.price_monthly_paise end)
        + coalesce((
          select sum((case s.billing_cycle when 'yearly' then a.price_yearly_paise / 12.0
              else a.price_monthly_paise end) * least(
                coalesce((i ->> 'qty')::int, 0), coalesce(a.max_quantity, 1000000)))
          from jsonb_array_elements(s.addons) i
          join public.plan_addons a on a.code = i ->> 'code'), 0)
      ) * (1 - s.discount_pct / 100))::bigint
    else 0 end
  from public.tenants t
  join public.tenant_subscriptions s on s.tenant_id = t.id
  join public.plans p2 on p2.code = s.plan_code
  order by t.created_at desc;
$$;

revoke execute on function public.admin_tenant_overview() from public, anon, authenticated;
grant execute on function public.admin_tenant_overview() to service_role;

-- ---------------------------------------------------------------------------
-- Sync
-- ---------------------------------------------------------------------------

alter publication powersync add table public.announcements, public.support_sessions;
