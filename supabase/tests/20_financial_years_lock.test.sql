-- Step 3.5: financial years (owner only, in order, stay closed) and the
-- lock of a closed year on every money table.
begin;
create extension if not exists pgtap with schema extensions;
select plan(13);

insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'acct1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'munshi1@test.local');

insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Business One');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000003', 'accountant'),
  ('bbbbbbbb-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'munshi');

insert into public.devices (id, tenant_id, user_id, device_code, platform) values
  ('dddddddd-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000003', 'W2', 'windows'),
  ('dddddddd-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'A1', 'android');

insert into public.parties (id, tenant_id, code, name) values
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Farmer One');

create temp table acct as
select private.chart_id('11111111-1111-4111-8111-111111111111', 'party',
  'cccccccc-0000-4000-8000-000000000001') farmer,
  private.chart_id('11111111-1111-4111-8111-111111111111', 'account', 'khata_adjustments') adj;
grant select on acct to authenticated;

-- A manual khata entry and its journal entry dated 2026-06-01, with or
-- without a reason.
create function pg_temp.manual(p_id uuid, p_device uuid, p_reason text) returns void
language plpgsql as $$
begin
  insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side, amount_paise,
    ref_type, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', 'cccccccc-0000-4000-8000-000000000001',
    '2026-06-01', 'udhaar', 100, 'journal', p_device);
  insert into public.journal_entries (id, tenant_id, source_key, source_type, entry_date,
    device_id, lock_reason)
  values (p_id, '11111111-1111-4111-8111-111111111111', 'entry:' || p_id, 'entry',
    '2026-06-01', p_device, p_reason);
  insert into public.journal_lines (id, tenant_id, journal_entry_id, line_no, account_id,
    debit_paise, credit_paise)
  values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', p_id, 0,
     (select farmer from acct), 100, 0),
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', p_id, 1,
     (select adj from acct), 0, 100);
  set constraints all immediate;
  set constraints all deferred;
end;
$$;

set local role authenticated;

-- Accountant: cannot close.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);
select lives_ok(
  $$select pg_temp.manual('60000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000003', null)$$,
  'before the close an accountant posts into 2026-27');
select throws_ok(
  $$insert into public.financial_years (id, tenant_id, start_date, end_date, status, closed_at,
      device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', '2026-04-01',
      '2027-03-31', 'closed', now(), 'dddddddd-0000-4000-8000-000000000003')$$,
  '42501', null, 'only the owner closes a year');

-- Owner closes 2026-27 (after 2025-26 is closed first).
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
insert into public.financial_years (id, tenant_id, start_date, end_date, status)
values ('61000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
  '2025-04-01', '2026-03-31', 'open');
select throws_ok(
  $$insert into public.financial_years (id, tenant_id, start_date, end_date, status, closed_at)
    values ('61000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111',
      '2026-04-01', '2027-03-31', 'closed', now())$$,
  '23514', null, 'years close in order');
select lives_ok(
  $$update public.financial_years set status = 'closed', closed_at = now()
    where id = '61000000-0000-4000-8000-000000000001'$$,
  'the earlier year closes');
select lives_ok(
  $$insert into public.financial_years (id, tenant_id, start_date, end_date, status, closed_at)
    values ('61000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111',
      '2026-04-01', '2027-03-31', 'closed', now())$$,
  'then 2026-27');
select throws_ok(
  $$update public.financial_years set status = 'open', closed_at = null
    where id = '61000000-0000-4000-8000-000000000002'$$,
  '42501', null, 'a closed year stays closed');
select throws_ok(
  $$insert into public.financial_years (id, tenant_id, start_date, end_date)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', '2027-05-01',
      '2028-04-30')$$,
  '23514', null, 'a financial year starts on 1 April');

-- The lock.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);
select throws_ok(
  $$select pg_temp.manual('60000000-0000-4000-8000-000000000002',
    'dddddddd-0000-4000-8000-000000000003', 'typo')$$,
  '42501', null, 'an accountant cannot post into a closed year, even with a reason');
select ok(
  not private.date_locked('11111111-1111-4111-8111-111111111111', '2027-04-01'),
  'the next year is open');

select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select throws_ok(
  $$select pg_temp.manual('60000000-0000-4000-8000-000000000003',
    'dddddddd-0000-4000-8000-000000000001', '  ')$$,
  '23514', null, 'the owner needs a reason');
select lives_ok(
  $$select pg_temp.manual('60000000-0000-4000-8000-000000000004',
    'dddddddd-0000-4000-8000-000000000001', 'CA found a missed entry')$$,
  'and posts with one');

-- The munshi sees the closed years (the app must refuse dates there).
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.financial_years where status = 'closed'), 2,
  'every member sees the closed years');
select throws_ok(
  $$insert into public.payments (id, tenant_id, receipt_no, entry_date, party_id, direction,
      mode, amount_paise, bank_account_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'R-A1-0001',
      '2027-01-10', 'cccccccc-0000-4000-8000-000000000001', 'from_party', 'cash', 100,
      (select id from public.bank_accounts
       where tenant_id = '11111111-1111-4111-8111-111111111111' and kind = 'cash'),
      'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'payments dated in a closed year are refused too');

select * from finish();
rollback;
