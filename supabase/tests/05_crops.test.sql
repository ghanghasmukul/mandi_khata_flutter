-- crops: default seed per business, tenant isolation, owner-only changes,
-- immutable code, no deletes.
begin;
create extension if not exists pgtap with schema extensions;
select plan(19);

insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'owner2@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'munshi1@test.local');

insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Business One'),
  ('22222222-2222-4222-8222-222222222222', 'Business Two');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'munshi');

-- ---- Seed ------------------------------------------------------------------
select is((select count(*)::int from public.crops
  where tenant_id = '11111111-1111-4111-8111-111111111111'),
  11, 'a new business gets the 11 default crops');
select is((select id from public.crops
  where tenant_id = '11111111-1111-4111-8111-111111111111' and code = 'wheat'),
  '60776cdf-4643-5e45-ae83-c04307fcd84c'::uuid,
  'seeded ids are the same UUID v5 the app computes (CropsRepository.idFor)');
select is((select msp_or_std_rate from public.crops
  where tenant_id = '11111111-1111-4111-8111-111111111111' and code = 'wheat'),
  258500::bigint, 'wheat MSP is stored in paise per qtl');
select lives_ok($$select private.seed_default_crops('11111111-1111-4111-8111-111111111111')$$,
  'seeding again is a no-op');

-- ---- Owner of business 1 ---------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is((select count(*)::int from public.crops), 11,
  'an owner sees only their own business''s crops');

select lives_ok(
  $$insert into public.crops (id, tenant_id, code, name_en)
    values ('c0000000-0000-4000-8000-000000000001',
      '11111111-1111-4111-8111-111111111111', 'sunflower', 'Sunflower')$$,
  'owner adds a crop');
select lives_ok(
  $$update public.crops set name_hi = 'सूरजमुखी', msp_or_std_rate = 772100, is_active = false
    where id = 'c0000000-0000-4000-8000-000000000001'$$,
  'owner edits and switches off a crop');
select throws_ok(
  $$update public.crops set code = 'sun_flower'
    where id = 'c0000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a crop code cannot change');
select throws_ok(
  $$update public.crops set tenant_id = '22222222-2222-4222-8222-222222222222'
    where id = 'c0000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a crop cannot move to another business');
select throws_ok(
  $$delete from public.crops where id = 'c0000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'clients cannot delete crops');
select throws_ok(
  $$insert into public.crops (id, tenant_id, code, name_en)
    values ('c0000000-0000-4000-8000-000000000002',
      '11111111-1111-4111-8111-111111111111', 'Paddy-1718', 'Paddy 1718')$$,
  '23514', null, 'a code must be a lowercase identifier');
select throws_ok(
  $$insert into public.crops (id, tenant_id, code, name_en)
    values ('c0000000-0000-4000-8000-000000000003',
      '11111111-1111-4111-8111-111111111111', 'wheat', 'Wheat again')$$,
  '23505', null, 'codes are unique per business');
select throws_ok(
  $$insert into public.crops (id, tenant_id, code, name_en)
    values ('c0000000-0000-4000-8000-000000000004',
      '22222222-2222-4222-8222-222222222222', 'jowar', 'Jowar')$$,
  '42501', null, 'no insert into another business');

update public.crops set name_en = 'Hacked'
  where tenant_id = '22222222-2222-4222-8222-222222222222';
reset role;
select is((select count(*)::int from public.crops
  where tenant_id = '22222222-2222-4222-8222-222222222222' and name_en = 'Hacked'),
  0, 'no update of another business''s crops');

-- ---- Munshi of business 1 --------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select is((select count(*)::int from public.crops), 12,
  'a munshi reads every crop of their business');
select throws_ok(
  $$insert into public.crops (id, tenant_id, code, name_en)
    values ('c0000000-0000-4000-8000-000000000005',
      '11111111-1111-4111-8111-111111111111', 'jowar', 'Jowar')$$,
  '42501', null, 'a munshi cannot add crops (settings.manage)');

update public.crops set msp_or_std_rate = 1
  where tenant_id = '11111111-1111-4111-8111-111111111111' and code = 'wheat';
reset role;
select is((select msp_or_std_rate from public.crops
  where tenant_id = '11111111-1111-4111-8111-111111111111' and code = 'wheat'),
  258500::bigint, 'a munshi cannot change crops');

-- ---- Anonymous ---------------------------------------------------------------
set local role anon;
select throws_ok($$select count(*) from public.crops$$, '42501', null,
  'anon has no access');
reset role;

select ok((select count(*) = 1 from pg_publication_tables
  where pubname = 'powersync' and tablename = 'crops'),
  'crops are in the powersync publication');

select * from finish();
rollback;
