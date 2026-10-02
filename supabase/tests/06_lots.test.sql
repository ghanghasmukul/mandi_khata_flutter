-- lots: tenant isolation, same-business parties and crop, status rules
-- (open → posted → reversed, cancel), frozen posted lots, who may reverse,
-- no deletes; a lot posts with its ledger entries in one upload.
begin;
create extension if not exists pgtap with schema extensions;
select plan(23);

-- Fixtures (as postgres). Business 1: owner 1, accountant 1, munshi 1.
-- Business 2: owner 2.
insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'owner2@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'accountant1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'munshi1@test.local');

insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Business One'),
  ('22222222-2222-4222-8222-222222222222', 'Business Two');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000003', 'accountant'),
  ('bbbbbbbb-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'munshi');

insert into public.devices (id, tenant_id, user_id, device_code, platform) values
  ('dddddddd-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000003', 'W2', 'windows'),
  ('dddddddd-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'A1', 'android');

insert into public.parties (id, tenant_id, code, name) values
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Farmer One'),
  ('cccccccc-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'B-1', 'Buyer One'),
  ('cccccccc-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'F-1', 'Farmer Two');

-- Wheat of business 1 (seeded; id = UUID v5 of tenant|code).
-- '60776cdf-4643-5e45-ae83-c04307fcd84c'

-- ---------------------------------------------------------------------------
-- As munshi 1: records arrivals, posts lots, cannot reverse them
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select lives_ok(
  $$insert into public.lots (id, tenant_id, lot_no, entry_date, farmer_id, crop_id, bags)
    values ('f0000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
      'L-A1-0001', '2026-04-10', 'cccccccc-0000-4000-8000-000000000001',
      '60776cdf-4643-5e45-ae83-c04307fcd84c', 18)$$,
  'a munshi records an arrival');
select lives_ok(
  $$update public.lots set qtl_milli = 8640, rate_paise_per_qtl = 242500, status = 'sold'
    where id = 'f0000000-0000-4000-8000-000000000001'$$,
  'an open lot can be weighed and sold');
select throws_ok(
  $$update public.lots set lot_no = 'L-A1-0099'
    where id = 'f0000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a lot number never changes');
select throws_ok(
  $$insert into public.lots (id, tenant_id, lot_no, entry_date, farmer_id, crop_id)
    values ('f0000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
      'L-A1-0002', '2026-04-10', 'cccccccc-0000-4000-8000-000000000002',
      extensions.uuid_generate_v5('3d8f2a6e-4c1b-4f0a-9b7e-5a2c8d1e6f30'::uuid,
        '22222222-2222-4222-8222-222222222222|wheat'))$$,
  '42501', null, 'no lots in another business');
select throws_ok(
  $$insert into public.lots (id, tenant_id, lot_no, entry_date, farmer_id, crop_id)
    values ('f0000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
      'L-A1-0003', '2026-04-10', 'cccccccc-0000-4000-8000-000000000002',
      '60776cdf-4643-5e45-ae83-c04307fcd84c')$$,
  '23503', null, 'the farmer must be in the same business');
select throws_ok(
  $$insert into public.lots (id, tenant_id, lot_no, entry_date, farmer_id, crop_id, buyer_party_id)
    values ('f0000000-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
      'L-A1-0004', '2026-04-10', 'cccccccc-0000-4000-8000-000000000001',
      '60776cdf-4643-5e45-ae83-c04307fcd84c', 'cccccccc-0000-4000-8000-000000000001')$$,
  '23514', null, 'the buyer cannot be the farmer');
select throws_ok(
  $$insert into public.lots (id, tenant_id, lot_no, entry_date, farmer_id, crop_id, status, posted_at)
    values ('f0000000-0000-4000-8000-000000000005', '11111111-1111-4111-8111-111111111111',
      'L-A1-0005', '2026-04-10', 'cccccccc-0000-4000-8000-000000000001',
      '60776cdf-4643-5e45-ae83-c04307fcd84c', 'posted', now())$$,
  '23514', null, 'a posted lot needs its weight, rate, snapshot and amounts');
select throws_ok(
  $$insert into public.lots (id, tenant_id, lot_no, entry_date, farmer_id, crop_id, status)
    values ('f0000000-0000-4000-8000-000000000006', '11111111-1111-4111-8111-111111111111',
      'L-A1-0006', '2026-04-10', 'cccccccc-0000-4000-8000-000000000001',
      '60776cdf-4643-5e45-ae83-c04307fcd84c', 'reversed')$$,
  '23514', null, 'a lot cannot be created reversed');
select throws_ok(
  $$insert into public.lots (id, tenant_id, lot_no, entry_date, farmer_id, crop_id)
    values ('f0000000-0000-4000-8000-000000000007', '11111111-1111-4111-8111-111111111111',
      'L-A1-0001', '2026-04-10', 'cccccccc-0000-4000-8000-000000000001',
      '60776cdf-4643-5e45-ae83-c04307fcd84c')$$,
  '23505', null, 'lot numbers are unique per business');

-- Posting: lot + farmer jama + buyer udhaar in one upload.
select lives_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PUT","table":"lots","id":"f0000000-0000-4000-8000-000000000010",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111","lot_no":"L-A1-0010",
             "entry_date":"2026-04-10","farmer_id":"cccccccc-0000-4000-8000-000000000001",
             "crop_id":"60776cdf-4643-5e45-ae83-c04307fcd84c","bags":18,"qtl_milli":8640,
             "rate_paise_per_qtl":242500,"buyer_party_id":"cccccccc-0000-4000-8000-000000000003",
             "status":"posted","charges_snapshot":{"commission_pct":"2.5"},
             "gross":2095200,"commission":52380,"net_to_farmer":1983276,"buyer_total":2095200,
             "posted_at":"2026-04-10T06:00:00Z","device_id":"dddddddd-0000-4000-8000-000000000004"}},
    {"op":"PUT","table":"ledger_entries","id":"eeeeeeee-0000-4000-8000-000000000010",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111",
             "party_id":"cccccccc-0000-4000-8000-000000000001","entry_date":"2026-04-10","created_at":"2026-04-10T06:00:00Z",
             "side":"jama","amount_paise":1983276,"ref_type":"arrival",
             "ref_id":"f0000000-0000-4000-8000-000000000010",
             "device_id":"dddddddd-0000-4000-8000-000000000004"}},
    {"op":"PUT","table":"ledger_entries","id":"eeeeeeee-0000-4000-8000-000000000011",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111",
             "party_id":"cccccccc-0000-4000-8000-000000000003","entry_date":"2026-04-10","created_at":"2026-04-10T06:00:00Z",
             "side":"udhaar","amount_paise":2095200,"ref_type":"arrival",
             "ref_id":"f0000000-0000-4000-8000-000000000010",
             "device_id":"dddddddd-0000-4000-8000-000000000004"}}
  ]'::jsonb)$$,
  'a munshi posts a lot with its ledger entries in one upload');
select is(
  (select count(*)::int from public.ledger_entries
   where ref_id = 'f0000000-0000-4000-8000-000000000010'),
  2, 'both entries landed');
select throws_ok(
  $$update public.lots set rate_paise_per_qtl = 250000
    where id = 'f0000000-0000-4000-8000-000000000010'$$,
  '42501', null, 'a posted lot is frozen');
select throws_ok(
  $$update public.lots set status = 'sold'
    where id = 'f0000000-0000-4000-8000-000000000010'$$,
  '42501', null, 'a posted lot cannot go back to open');
select throws_ok(
  $$update public.lots set status = 'reversed'
    where id = 'f0000000-0000-4000-8000-000000000010'$$,
  '42501', null, 'a munshi cannot reverse a posted lot');
select lives_ok(
  $$update public.lots set status = 'reversed'
    where id = 'f0000000-0000-4000-8000-000000000001'$$,
  'a munshi cancels an open lot');
select throws_ok(
  $$update public.lots set notes = 'again'
    where id = 'f0000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a cancelled lot never changes');
select throws_ok(
  $$delete from public.lots where id = 'f0000000-0000-4000-8000-000000000010'$$,
  '42501', null, 'clients cannot delete lots');

-- ---------------------------------------------------------------------------
-- As owner 2: sees nothing of business 1
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);

select is((select count(*)::int from public.lots), 0,
  'another business sees none of these lots');
select lives_ok(
  $$update public.lots set notes = 'x'
    where id = 'f0000000-0000-4000-8000-000000000010'$$,
  'an update of another business''s lot runs…');

-- ---------------------------------------------------------------------------
-- As accountant 1: may reverse
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);

select is(
  (select notes from public.lots where id = 'f0000000-0000-4000-8000-000000000010'),
  null, '…but changed nothing');
select lives_ok(
  $$update public.lots set status = 'reversed'
    where id = 'f0000000-0000-4000-8000-000000000010'$$,
  'an accountant reverses a posted lot');
select throws_ok(
  $$update public.lots set status = 'posted'
    where id = 'f0000000-0000-4000-8000-000000000010'$$,
  '42501', null, 'a reversed lot stays reversed');
select is(
  (select count(*)::int from public.lots
   where tenant_id = '11111111-1111-4111-8111-111111111111'),
  2, 'the accountant sees the business''s lots');

select * from finish();
rollback;
