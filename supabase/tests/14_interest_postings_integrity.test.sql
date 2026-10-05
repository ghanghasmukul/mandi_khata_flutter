-- Phase 2 review findings 3 and 6: overlapping periods are refused, one entry
-- per posting, entry dates, waiver cap, a posting needs its khata entry.
begin;
create extension if not exists pgtap with schema extensions;
select plan(15);

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
    'cccccccc-0000-4000-8000-000000000001',
    -- An interest entry is dated the last day interest ran (period_to - 1).
    case when p_ref = 'interest' then pg_temp.today() - 1 else pg_temp.today() end,
    p_side, p_amount, p_ref, p_ref_id, p_device);
$$;


create function pg_temp.entry(
  p_ref text, p_side text, p_amount bigint, p_ref_id uuid, p_date date
) returns void language sql as $$
  insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side,
    amount_paise, ref_type, ref_id, device_id)
  values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
    'cccccccc-0000-4000-8000-000000000001', p_date, p_side, p_amount,
    p_ref, p_ref_id, 'dddddddd-0000-4000-8000-000000000001');
$$;

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

-- ---------------------------------------------------------------------------
-- Finding 3: no overlapping periods on one account
-- ---------------------------------------------------------------------------
select lives_ok(
  $$select pg_temp.post('40000000-0000-4000-8000-000000000001', 500000,
    'dddddddd-0000-4000-8000-000000000001')$$,
  'the owner posts 100 days of interest');
select throws_ok(
  $$select pg_temp.post(gen_random_uuid(), 100,
    'dddddddd-0000-4000-8000-000000000001', 'interest',
    'cccccccc-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111', null, pg_temp.today() - 30)$$,
  '23P01', null, 'another device posting up to a different day overlaps and is refused');
select lives_ok(
  $$select pg_temp.post('40000000-0000-4000-8000-000000000003', 100,
    'dddddddd-0000-4000-8000-000000000001', 'interest',
    'cccccccc-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111', null, pg_temp.today() + 100)$$,
  'the next period starts where the last ended: not an overlap');
select lives_ok(
  $$select pg_temp.entry('interest', 'udhaar', 100,
    '40000000-0000-4000-8000-000000000003', pg_temp.today() + 99)$$,
  'and it gets its entry');

-- ---------------------------------------------------------------------------
-- Finding 6: one entry per posting, with the right date
-- ---------------------------------------------------------------------------
select throws_ok(
  $$select pg_temp.entry('interest', 'udhaar', 500000,
    '40000000-0000-4000-8000-000000000001', pg_temp.today())$$,
  '23514', null, 'an interest entry is dated the last day interest ran');
select lives_ok(
  $$select pg_temp.entry('interest', 'udhaar', 500000,
    '40000000-0000-4000-8000-000000000001', pg_temp.today() - 1)$$,
  'the interest entry on its date is accepted');
select throws_ok(
  $$select pg_temp.entry('interest', 'udhaar', 500000,
    '40000000-0000-4000-8000-000000000001', pg_temp.today() - 1)$$,
  '23505', null, 'a second interest entry for the same posting is refused');

-- Waivers: capped at the interest posted, one entry, dated the waiver day.
select lives_ok(
  $$select pg_temp.post('40000000-0000-4000-8000-000000000002', 300000,
    'dddddddd-0000-4000-8000-000000000001', 'waiver')$$,
  'a waiver within the interest posted is accepted');
select throws_ok(
  $$select pg_temp.post(gen_random_uuid(), 200101,
    'dddddddd-0000-4000-8000-000000000001', 'waiver')$$,
  '23514', null, 'waivers beyond the interest posted are refused');
select throws_ok(
  $$select pg_temp.entry('journal', 'jama', 300000,
    '40000000-0000-4000-8000-000000000002', pg_temp.today() - 1)$$,
  '23514', null, 'a waiver entry is dated the waiver day');
select lives_ok(
  $$select pg_temp.entry('journal', 'jama', 300000,
    '40000000-0000-4000-8000-000000000002', pg_temp.today())$$,
  'the waiver entry on its day is accepted');
select throws_ok(
  $$select pg_temp.entry('journal', 'jama', 300000,
    '40000000-0000-4000-8000-000000000002', pg_temp.today())$$,
  '23505', null, 'a waiver posting has one entry only');

-- A reversed posting no longer counts: its period can be posted again.
reset role;
insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side,
  amount_paise, ref_type, reverses_id, device_id)
select gen_random_uuid(), e.tenant_id, e.party_id, e.entry_date, 'jama',
  e.amount_paise, 'reversal', e.id, e.device_id
from public.ledger_entries e
where e.ref_id = '40000000-0000-4000-8000-000000000001' and e.ref_type = 'interest';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select lives_ok(
  $$select pg_temp.post('40000000-0000-4000-8000-000000000004', 100,
    'dddddddd-0000-4000-8000-000000000001', 'interest',
    'cccccccc-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111', null, pg_temp.today() - 30)$$,
  'after the posting was reversed its period can be posted again');
select lives_ok(
  $$select pg_temp.entry('interest', 'udhaar', 100,
    '40000000-0000-4000-8000-000000000004', pg_temp.today() - 31)$$,
  'and it gets its entry');

-- A posting without its khata entry is refused at the end of the upload.
set constraints public.interest_postings_has_entry immediate;
select throws_ok(
  $$select pg_temp.post(gen_random_uuid(), 100,
    'dddddddd-0000-4000-8000-000000000001', 'interest',
    'cccccccc-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111', null, pg_temp.today() + 300)$$,
  '23514', null, 'a posting with no khata entry is refused');
set constraints public.interest_postings_has_entry deferred;

select * from finish();
rollback;
