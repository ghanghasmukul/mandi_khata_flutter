-- Local development data only. Applied by `supabase db reset`; never pushed to
-- the dev or prod projects.
--
-- Sign in locally with any of these (password: password123):
--   owner1@mandikhata.test / accountant1@… / munshi1@…   → Gupta Trading Co.
--   owner2@mandikhata.test / accountant2@… / munshi2@…   → Sharma Arhat Agency

-- ---------------------------------------------------------------------------
-- Users (auth.users → app_users is filled by trigger)
-- ---------------------------------------------------------------------------

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  phone, phone_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token,
  email_change_token_new, email_change
)
select
  '00000000-0000-0000-0000-000000000000', u.id, 'authenticated', 'authenticated',
  u.email, extensions.crypt('password123', extensions.gen_salt('bf')), now(),
  u.phone, now(), '{"provider":"email","providers":["email","phone"]}'::jsonb,
  jsonb_build_object('full_name', u.full_name), now(), now(), '', '', '', ''
from (values
  ('0a000000-0000-4000-8000-000000000001'::uuid, 'owner1@mandikhata.test', '919814022110', 'Naresh Gupta'),
  ('0a000000-0000-4000-8000-000000000002'::uuid, 'accountant1@mandikhata.test', '919814022111', 'Meena Devi'),
  ('0a000000-0000-4000-8000-000000000003'::uuid, 'munshi1@mandikhata.test', '919814022112', 'Rajinder Kumar'),
  ('0a000000-0000-4000-8000-000000000004'::uuid, 'owner2@mandikhata.test', '919896033220', 'Suresh Sharma'),
  ('0a000000-0000-4000-8000-000000000005'::uuid, 'accountant2@mandikhata.test', '919896033221', 'Pooja Rani'),
  ('0a000000-0000-4000-8000-000000000006'::uuid, 'munshi2@mandikhata.test', '919896033222', 'Mahavir Singh')
) as u (id, email, phone, full_name);

insert into auth.identities (
  id, user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at
)
select
  gen_random_uuid(), u.id, u.id::text, 'email',
  jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
  now(), now(), now()
from auth.users u
where u.email like '%@mandikhata.test';

update public.app_users set preferred_language = 'pa'
  where id = '0a000000-0000-4000-8000-000000000003';
update public.app_users set preferred_language = 'hi'
  where id in ('0a000000-0000-4000-8000-000000000004', '0a000000-0000-4000-8000-000000000006');

-- ---------------------------------------------------------------------------
-- Businesses and members
-- ---------------------------------------------------------------------------

insert into public.tenants (id, name, legal_name, address, state_code, mandi_name, phone,
                            plan_code, status, trial_ends_at) values
  ('0e000000-0000-4000-8000-000000000001', 'Gupta Trading Co.', 'Gupta Trading Company',
   'Shop 14, New Grain Market, Mansa', '03', 'Mansa Mandi', '9814022110',
   'trial', 'trial', now() + interval '30 days'),
  ('0e000000-0000-4000-8000-000000000002', 'Sharma Arhat Agency', 'Sharma Arhat Agency',
   'Shop 7, Anaj Mandi, Sirsa', '06', 'Sirsa Mandi', '9896033220',
   'trial', 'trial', now() + interval '30 days');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('0b000000-0000-4000-8000-000000000001', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000001', 'owner'),
  ('0b000000-0000-4000-8000-000000000002', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000002', 'accountant'),
  ('0b000000-0000-4000-8000-000000000003', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000003', 'munshi'),
  ('0b000000-0000-4000-8000-000000000004', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000004', 'owner'),
  ('0b000000-0000-4000-8000-000000000005', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000005', 'accountant'),
  ('0b000000-0000-4000-8000-000000000006', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000006', 'munshi');

-- Counter PC (W1) for each owner, gate phone (A1) for each munshi.
insert into public.devices (id, tenant_id, user_id, device_code, platform, name) values
  ('0d000000-0000-4000-8000-000000000001', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000001', 'W1', 'windows', 'Counter PC'),
  ('0d000000-0000-4000-8000-000000000002', '0e000000-0000-4000-8000-000000000001', '0a000000-0000-4000-8000-000000000003', 'A1', 'android', 'Gate phone'),
  ('0d000000-0000-4000-8000-000000000003', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000004', 'W1', 'windows', 'Counter PC'),
  ('0d000000-0000-4000-8000-000000000004', '0e000000-0000-4000-8000-000000000002', '0a000000-0000-4000-8000-000000000006', 'A1', 'android', 'Gate phone');

insert into public.number_series (id, tenant_id, series, device_code, next_value)
select md5('seed-series-' || t.id || s.series || d.code)::uuid, t.id, s.series, d.code, 1
from (values ('0e000000-0000-4000-8000-000000000001'::uuid),
             ('0e000000-0000-4000-8000-000000000002'::uuid)) as t (id)
cross join (values ('R'), ('L')) as s (series)
cross join (values ('W1'), ('A1')) as d (code);

-- A few business-wide settings (the rest fall back to system defaults).
insert into public.settings (id, tenant_id, scope, key, value) values
  (md5('seed-setting-1')::uuid, '0e000000-0000-4000-8000-000000000001', 'tenant', 'mandi.commission_pct', '2.5'),
  (md5('seed-setting-2')::uuid, '0e000000-0000-4000-8000-000000000001', 'tenant', 'interest.rate_pa', '18'),
  (md5('seed-setting-3')::uuid, '0e000000-0000-4000-8000-000000000002', 'tenant', 'mandi.commission_pct', '2'),
  (md5('seed-setting-4')::uuid, '0e000000-0000-4000-8000-000000000002', 'tenant', 'interest.method', '"compound"');

-- ---------------------------------------------------------------------------
-- Parties (12 per business) and their roles
-- ---------------------------------------------------------------------------

insert into public.parties (id, tenant_id, code, name, father_or_husband_name, relation,
                            village, district, state, mobile)
select md5('seed-party-' || p.tenant_id || p.code)::uuid, p.tenant_id::uuid, p.code, p.name,
       p.father, p.relation, p.village, p.district, p.state, p.mobile
from (values
  ('0e000000-0000-4000-8000-000000000001', 'F-101', 'Gurpreet Singh', 'Harbans Singh', 's_o', 'Bhikhi', 'Mansa', 'Punjab', '9814100101'),
  ('0e000000-0000-4000-8000-000000000001', 'F-102', 'Balwinder Kaur', 'Jagtar Singh', 'w_o', 'Budhlada', 'Mansa', 'Punjab', '9872341876'),
  ('0e000000-0000-4000-8000-000000000001', 'F-103', 'Amrik Singh', 'Kartar Singh', 's_o', 'Sardulgarh', 'Mansa', 'Punjab', '9915510432'),
  ('0e000000-0000-4000-8000-000000000001', 'F-104', 'Harjit Kaur', 'Mohan Singh', 'd_o', 'Joga', 'Mansa', 'Punjab', '9815277009'),
  ('0e000000-0000-4000-8000-000000000001', 'F-105', 'Sukhdev Singh', 'Gurdev Singh', 's_o', 'Bareta', 'Mansa', 'Punjab', '9876012345'),
  ('0e000000-0000-4000-8000-000000000001', 'F-106', 'Ramesh Kumar', 'Sita Ram', 's_o', 'Jhunir', 'Mansa', 'Punjab', '9417055321'),
  ('0e000000-0000-4000-8000-000000000001', 'F-107', 'Jaswinder Singh', 'Bakhtawar Singh', 's_o', 'Khiala Kalan', 'Mansa', 'Punjab', '9855123456'),
  ('0e000000-0000-4000-8000-000000000001', 'F-108', 'Kulwant Kaur', 'Nirmal Singh', 'w_o', 'Bhikhi', 'Mansa', 'Punjab', '9779012233'),
  ('0e000000-0000-4000-8000-000000000001', 'F-109', 'Manjit Singh', 'Ajmer Singh', 's_o', 'Budhlada', 'Mansa', 'Punjab', '9814455667'),
  ('0e000000-0000-4000-8000-000000000001', 'F-110', 'Paramjit Singh', 'Darshan Singh', 's_o', 'Sardulgarh', 'Mansa', 'Punjab', '9463123987'),
  ('0e000000-0000-4000-8000-000000000001', 'B-201', 'Punjab Agro Mills', null, 'prop', 'Mansa', 'Mansa', 'Punjab', '9814600601'),
  ('0e000000-0000-4000-8000-000000000001', 'S-301', 'Kisan Seeds & Pesticides', null, 'prop', 'Mansa', 'Mansa', 'Punjab', '9814700701'),
  ('0e000000-0000-4000-8000-000000000002', 'F-101', 'Rajbir Singh', 'Surjeet Singh', 's_o', 'Rania', 'Sirsa', 'Haryana', '9896100101'),
  ('0e000000-0000-4000-8000-000000000002', 'F-102', 'Om Prakash', 'Ram Kumar', 's_o', 'Ellenabad', 'Sirsa', 'Haryana', '9416200202'),
  ('0e000000-0000-4000-8000-000000000002', 'F-103', 'Santosh Devi', 'Ramesh Chand', 'w_o', 'Kalanwali', 'Sirsa', 'Haryana', '9812300303'),
  ('0e000000-0000-4000-8000-000000000002', 'F-104', 'Jagdish Chander', 'Hari Ram', 's_o', 'Odhan', 'Sirsa', 'Haryana', '9728400404'),
  ('0e000000-0000-4000-8000-000000000002', 'F-105', 'Baljeet Kaur', 'Gurnam Singh', 'd_o', 'Dabwali', 'Sirsa', 'Haryana', '9896500505'),
  ('0e000000-0000-4000-8000-000000000002', 'F-106', 'Mahender Singh', 'Chandgi Ram', 's_o', 'Nathusari Chopta', 'Sirsa', 'Haryana', '9416600606'),
  ('0e000000-0000-4000-8000-000000000002', 'F-107', 'Satbir Singh', 'Dhan Singh', 's_o', 'Rania', 'Sirsa', 'Haryana', '9812700707'),
  ('0e000000-0000-4000-8000-000000000002', 'F-108', 'Kamla Devi', 'Rajender Singh', 'w_o', 'Ellenabad', 'Sirsa', 'Haryana', '9728800808'),
  ('0e000000-0000-4000-8000-000000000002', 'F-109', 'Dharampal', 'Mange Ram', 's_o', 'Kalanwali', 'Sirsa', 'Haryana', '9896900909'),
  ('0e000000-0000-4000-8000-000000000002', 'F-110', 'Vikram Singh', 'Balwan Singh', 's_o', 'Odhan', 'Sirsa', 'Haryana', '9416010110'),
  ('0e000000-0000-4000-8000-000000000002', 'B-201', 'Haryana Rice & Dal Mills', null, 'prop', 'Sirsa', 'Sirsa', 'Haryana', '9812011211'),
  ('0e000000-0000-4000-8000-000000000002', 'S-301', 'Shiv Krishi Kendra', null, 'prop', 'Sirsa', 'Sirsa', 'Haryana', '9728012312')
) as p (tenant_id, code, name, father, relation, village, district, state, mobile);

-- F- codes are farmers (a few also buy inputs on credit), B- buyers, S- suppliers.
insert into public.party_roles (id, tenant_id, party_id, role)
select md5('seed-role-' || p.id || r.role)::uuid, p.tenant_id, p.id, r.role
from public.parties p
cross join lateral (
  select 'farmer' as role where p.code like 'F-%'
  union all select 'customer' where p.code in ('F-101', 'F-103', 'F-106')
  union all select 'buyer' where p.code like 'B-%'
  union all select 'supplier' where p.code like 'S-%'
) as r
where p.tenant_id in ('0e000000-0000-4000-8000-000000000001', '0e000000-0000-4000-8000-000000000002');
