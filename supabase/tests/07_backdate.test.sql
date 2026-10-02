-- Back-dated khata entries (business.backdate_days): a munshi posts within
-- the window of the day an entry was recorded; older or future-dated entries
-- need entries.reverse (accountant / owner).
begin;
create extension if not exists pgtap with schema extensions;
select plan(11);

-- Fixtures (as postgres). Business 1: owner, accountant, munshi. Business 2.
insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'acct1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'munshi1@test.local');

insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Business One'),
  ('22222222-2222-4222-8222-222222222222', 'Business Two');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner'),
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
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Party One');

-- Business 2's wide window must not widen business 1's.
insert into public.settings (id, tenant_id, scope, key, value) values
  (gen_random_uuid(), '22222222-2222-4222-8222-222222222222', 'tenant',
   'business.backdate_days', '30');

-- A payment by the munshi dated p_days_ago (India time), recorded now.
create function pg_temp.munshi_payment(p_days_ago int) returns void
language sql as $$
  insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id)
  values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001',
     (now() at time zone 'Asia/Kolkata')::date - p_days_ago,
     'udhaar', 10000, 'payment', 'dddddddd-0000-4000-8000-000000000004');
$$;

set local role authenticated;

-- ---------------------------------------------------------------------------
-- As munshi 1, default window (3 days)
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select lives_ok($$select pg_temp.munshi_payment(0)$$, 'munshi: dated today');
select lives_ok($$select pg_temp.munshi_payment(3)$$, 'munshi: 3 days back');
select throws_ok($$select pg_temp.munshi_payment(4)$$,
  '42501', null, 'munshi: 4 days back needs entries.reverse');
select throws_ok($$select pg_temp.munshi_payment(-1)$$,
  '42501', null, 'munshi: a future date needs entries.reverse');
select lives_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id, created_at)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', '2026-04-08', 'udhaar', 10000, 'payment',
      'dddddddd-0000-4000-8000-000000000004', '2026-04-08T18:00:00Z')$$,
  'munshi: recorded on its date offline, synced later — not back-dated');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id, created_at)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', '2026-04-08', 'udhaar', 10000, 'payment',
      'dddddddd-0000-4000-8000-000000000004', '2026-04-11T18:31:00Z')$$,
  '42501', null, 'munshi: India date decides (00:01 IST on 12 Apr is 4 days late)');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id, created_at)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001',
      (now() at time zone 'Asia/Kolkata')::date + 5, 'udhaar', 10000, 'payment',
      'dddddddd-0000-4000-8000-000000000004', now() + interval '5 days')$$,
  '23514', null, 'created_at cannot be ahead of the server clock');

-- ---------------------------------------------------------------------------
-- As the accountant: back-dating allowed
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);

select lives_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', '2025-04-01', 'udhaar', 10000, 'payment',
      'dddddddd-0000-4000-8000-000000000003')$$,
  'accountant: back-dated a year');

-- ---------------------------------------------------------------------------
-- The business's own setting decides
-- ---------------------------------------------------------------------------
reset role;
insert into public.settings (id, tenant_id, scope, key, value) values
  ('99999999-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'tenant', 'business.backdate_days', '0');
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select lives_ok($$select pg_temp.munshi_payment(0)$$, 'window 0: today');
select throws_ok($$select pg_temp.munshi_payment(1)$$,
  '42501', null, 'window 0: yesterday needs entries.reverse');

reset role;
update public.settings set value = '"x"'
  where id = '99999999-0000-4000-8000-000000000001';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select lives_ok($$select pg_temp.munshi_payment(3)$$,
  'an invalid stored value falls back to 3 days');

select * from finish();
rollback;
