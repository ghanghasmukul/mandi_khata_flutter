-- interest_postings and the khata entries that point at them: tenant
-- isolation, loans.manage to post, entries.reverse to waive, append-only,
-- idempotent period keys, interest / waiver entries must match their posting.
begin;
create extension if not exists pgtap with schema extensions;
select plan(20);

-- Fixtures (as postgres). Business 1: owner, accountant, munshi. Business 2.
insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'owner2@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'acct1@test.local'),
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
  ('dddddddd-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000003', 'W2', 'windows'),
  ('dddddddd-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'A1', 'android');

insert into public.parties (id, tenant_id, code, name) values
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Farmer One'),
  ('cccccccc-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'F-3', 'Farmer Three'),
  ('cccccccc-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'F-1', 'Farmer Two');

create function pg_temp.today() returns date language sql as $$
  select (now() at time zone 'Asia/Kolkata')::date;
$$;

-- A khata posting for Farmer One, 100 days ending today.
create function pg_temp.post(
  p_id uuid, p_amount bigint, p_device uuid,
  p_kind text default 'interest', p_party uuid default 'cccccccc-0000-4000-8000-000000000001',
  p_tenant uuid default '11111111-1111-4111-8111-111111111111',
  p_key text default null, p_to date default null
) returns void language sql as $$
  insert into public.interest_postings (id, tenant_id, party_id, kind,
    period_from, period_to, amount_paise, rate_pa, method, reason, period_key,
    device_id)
  values (p_id, p_tenant, p_party, p_kind,
    case when p_kind = 'interest' then coalesce(p_to, pg_temp.today()) - 100
         else coalesce(p_to, pg_temp.today()) end,
    coalesce(p_to, pg_temp.today()),
    p_amount,
    case when p_kind = 'interest' then '18' end,
    case when p_kind = 'interest' then 'simple' end,
    case when p_kind = 'waiver' then 'Diwali discount' end,
    coalesce(p_key, case p_kind
      when 'interest' then 'interest:khata:' || p_party::text || ':'
        || coalesce(p_to, pg_temp.today())::text
      else 'waiver:' || p_id::text end),
    p_device);
$$;

create function pg_temp.led(
  p_ref text, p_side text, p_amount bigint, p_ref_id uuid, p_device uuid
) returns void language sql as $$
  insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side,
    amount_paise, ref_type, ref_id, device_id)
  values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
    'cccccccc-0000-4000-8000-000000000001', pg_temp.today(), p_side, p_amount,
    p_ref, p_ref_id, p_device);
$$;

set local role authenticated;

-- ---------------------------------------------------------------------------
-- The owner of business 1 posts interest
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select lives_ok(
  $$select pg_temp.post('40000000-0000-4000-8000-000000000001', 493151,
    'dddddddd-0000-4000-8000-000000000001')$$,
  'the owner posts interest');
select throws_ok(
  $$select pg_temp.post(gen_random_uuid(), 100,
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23505', null, 'the same account cannot be posted twice up to the same day');
select throws_ok(
  $$select pg_temp.post(gen_random_uuid(), 100,
    'dddddddd-0000-4000-8000-000000000001', 'interest',
    'cccccccc-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111', 'interest:khata:made-up:2027-01-01')$$,
  '23514', null, 'the period key must follow the posting');
select throws_ok(
  $$select pg_temp.post(gen_random_uuid(), 0,
    'dddddddd-0000-4000-8000-000000000001', 'interest',
    'cccccccc-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111', null, pg_temp.today() - 1)$$,
  '23514', null, 'the amount is positive');
select throws_ok(
  $$select pg_temp.post(gen_random_uuid(), 100,
    'dddddddd-0000-4000-8000-000000000001', 'interest',
    'cccccccc-0000-4000-8000-000000000002')$$,
  '23503', null, 'the party must be one of this business');
select throws_ok(
  $$select pg_temp.post(gen_random_uuid(), 100,
    'dddddddd-0000-4000-8000-000000000003', 'interest',
    'cccccccc-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111', null, pg_temp.today() - 5)$$,
  '42501', null, 'a posting must come from the poster''s own device');

-- The interest entry: udhaar, pointing at its posting.
select lives_ok(
  $$select pg_temp.led('interest', 'udhaar', 493151,
    '40000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000001')$$,
  'the interest entry matches its posting');
select throws_ok(
  $$select pg_temp.led('interest', 'udhaar', 493150,
    '40000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'an interest entry of another amount is refused');
select throws_ok(
  $$select pg_temp.led('interest', 'jama', 493151,
    '40000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'interest is always udhaar');
select throws_ok(
  $$select pg_temp.led('interest', 'udhaar', 493151, gen_random_uuid(),
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'an interest entry with no posting is refused');

-- A waiver: posting + jama journal entry.
select lives_ok(
  $$select pg_temp.post('40000000-0000-4000-8000-000000000002', 93151,
    'dddddddd-0000-4000-8000-000000000001', 'waiver')$$,
  'the owner records a waiver');
select lives_ok(
  $$select pg_temp.led('journal', 'jama', 93151,
    '40000000-0000-4000-8000-000000000002',
    'dddddddd-0000-4000-8000-000000000001')$$,
  'the waiver entry matches its posting');
select throws_ok(
  $$select pg_temp.led('journal', 'jama', 93000,
    '40000000-0000-4000-8000-000000000002',
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a waiver entry of another amount is refused');

-- Append-only.
select throws_ok(
  $$update public.interest_postings set amount_paise = 1
    where id = '40000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a posting cannot be edited');
select throws_ok(
  $$delete from public.interest_postings
    where id = '40000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a posting cannot be deleted');

-- ---------------------------------------------------------------------------
-- Roles: the munshi may not post
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select throws_ok(
  $$select pg_temp.post(gen_random_uuid(), 100,
    'dddddddd-0000-4000-8000-000000000004', 'interest',
    'cccccccc-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111', null, pg_temp.today() - 7)$$,
  '42501', null, 'a munshi cannot post interest');
select is(
  (select count(*)::int from public.interest_postings), 2,
  'a munshi can read the postings of the business');

-- ---------------------------------------------------------------------------
-- The owner of business 2 sees and posts nothing in business 1
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);

select is(
  (select count(*)::int from public.interest_postings), 0,
  'another business sees no postings');
select throws_ok(
  $$select pg_temp.post(gen_random_uuid(), 100,
    'dddddddd-0000-4000-8000-000000000002', 'interest',
    'cccccccc-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111')$$,
  '42501', null, 'another business cannot post into this one');

reset role;
select is(
  (select count(*)::int from public.ledger_entries where ref_type = 'interest'), 1,
  'one interest entry exists');

select * from finish();
rollback;
