-- Step 1.2: crops master. One list per business, seeded with the common
-- Punjab / Haryana / Rajasthan crops. A crop's code is also the suffix of its
-- per-crop settings (`mandi.commission_pct.<code>`), so it can never change.
-- Crops are switched off (is_active), never deleted.

create extension if not exists "uuid-ossp" with schema extensions;

create table public.crops (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- Same rule as khata_core CropRules.isValidCode.
  code text not null check (code ~ '^[a-z][a-z0-9_]*$' and length(code) <= 24),
  name_en text not null check (length(trim(name_en)) > 0),
  name_hi text,
  name_pa text,
  unit text not null default 'qtl' check (unit in ('qtl')),
  -- MSP or the business's usual rate, paise per unit. A reference only;
  -- the rate of a lot is entered per lot.
  msp_or_std_rate bigint check (msp_or_std_rate is null or msp_or_std_rate >= 0),
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint crops_code_unique unique (tenant_id, code),
  -- Lets lots prove their crop is in the same business.
  constraint crops_id_tenant_unique unique (id, tenant_id)
);

create trigger crops_set_updated_at before update on public.crops
  for each row execute function private.set_updated_at();
create trigger crops_set_created_by before insert on public.crops
  for each row execute function private.set_created_by();
create trigger crops_keep_tenant_id before update on public.crops
  for each row execute function private.keep_tenant_id();

-- Per-crop settings are keyed by the code.
create or replace function private.keep_crop_code()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.code is distinct from old.code then
    raise exception 'a crop code cannot be changed'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.keep_crop_code() from public, anon, authenticated;

create trigger crops_keep_code before update on public.crops
  for each row execute function private.keep_crop_code();

-- ---------------------------------------------------------------------------
-- Default crops for every business. Ids are UUID v5 of "<tenant>|<code>" in
-- the same namespace the app uses (CropsRepository.idFor), so a device that
-- adds a crop with the same code offline writes the same row.
-- MSP values (₹/qtl): wheat, mustard, chana RMS 2026-27; paddy (common),
-- cotton (medium staple), bajra, moong, maize KMS 2025-26. Reference only —
-- each business edits them.
-- ---------------------------------------------------------------------------

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
    p_tenant_id, c.code, c.name_en, c.name_hi, c.name_pa, c.msp, c.sort_order
  from (values
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
    ('maize',        'Maize',               'मक्का',              'ਮੱਕੀ',              240000, 110)
  ) as c(code, name_en, name_hi, name_pa, msp, sort_order)
  on conflict (tenant_id, code) do nothing;
$$;

revoke execute on function private.seed_default_crops(uuid) from public, anon, authenticated;

-- Runs as the function owner: the business is new, so its creator is not a
-- member yet and could not insert crops through RLS.
create or replace function private.seed_crops_for_new_tenant()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.seed_default_crops(new.id);
  return new;
end;
$$;

revoke execute on function private.seed_crops_for_new_tenant() from public, anon, authenticated;

create trigger tenants_seed_crops after insert on public.tenants
  for each row execute function private.seed_crops_for_new_tenant();

select private.seed_default_crops(id) from public.tenants;

-- ---------------------------------------------------------------------------
-- Row level security: every member reads; adding or changing a crop is
-- business-wide configuration (settings.manage). No client deletes.
-- ---------------------------------------------------------------------------

alter table public.crops enable row level security;

create policy crops_select on public.crops
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy crops_insert on public.crops
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'settings.manage')));

create policy crops_update on public.crops
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'settings.manage')))
  with check ((select private.has_permission(tenant_id, 'settings.manage')));

revoke all on public.crops from anon;
revoke delete, truncate on public.crops from authenticated;

alter publication powersync add table public.crops;
