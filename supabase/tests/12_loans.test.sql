-- loans, loan_rate_changes, payments.loan_id and the loan khata entries:
-- tenant isolation, owner-only issue / rate change / close, frozen loans,
-- append-only rate changes, repayments by a munshi, closed loans take no
-- payments, loan entries must point at a real loan.
begin;
create extension if not exists pgtap with schema extensions;
select plan(37);

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

create function pg_temp.cash1() returns uuid language sql as $$
  select extensions.uuid_generate_v5('3d8f2a6e-4c1b-4f0a-9b7e-5a2c8d1e6f30'::uuid,
    '11111111-1111-4111-8111-111111111111|account|cash');
$$;

create function pg_temp.today() returns date language sql as $$
  select (now() at time zone 'Asia/Kolkata')::date;
$$;

create function pg_temp.loan(
  p_id uuid, p_no text, p_party uuid, p_amount bigint, p_device uuid,
  p_guarantor uuid default null, p_due date default null,
  p_tenant uuid default '11111111-1111-4111-8111-111111111111'
) returns void language sql as $$
  insert into public.loans (id, tenant_id, loan_no, party_id, issue_date,
    principal_paise, due_date, guarantor_party_id, interest_config_snapshot,
    device_id)
  values (p_id, p_tenant, p_no, p_party, pg_temp.today(), p_amount, p_due,
    p_guarantor, '{"rate_pa":"18"}'::jsonb, p_device);
$$;

create function pg_temp.loan_pay(
  p_id uuid, p_no text, p_dir text, p_amount bigint, p_loan uuid,
  p_device uuid, p_party uuid default 'cccccccc-0000-4000-8000-000000000001'
) returns void language sql as $$
  insert into public.payments (id, tenant_id, receipt_no, entry_date, party_id,
    direction, mode, amount_paise, bank_account_id, loan_id, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', p_no, pg_temp.today(),
    p_party, p_dir, 'cash', p_amount, pg_temp.cash1(), p_loan, p_device);
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
-- As the owner of business 1
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select lives_ok(
  $$select pg_temp.loan('10000000-0000-4000-8000-000000000001', 'KZ-W1-0001',
    'cccccccc-0000-4000-8000-000000000001', 10000000,
    'dddddddd-0000-4000-8000-000000000001', null, pg_temp.today() + 90)$$,
  'the owner issues a loan');
select throws_ok(
  $$select pg_temp.loan(gen_random_uuid(), 'KZ-W1-0001',
    'cccccccc-0000-4000-8000-000000000001', 500000,
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23505', null, 'a loan number is unique within a business');
select throws_ok(
  $$select pg_temp.loan(gen_random_uuid(), 'KZ-W1-0009',
    'cccccccc-0000-4000-8000-000000000001', 500000,
    'dddddddd-0000-4000-8000-000000000001',
    'cccccccc-0000-4000-8000-000000000001')$$,
  '23514', null, 'the borrower cannot be their own guarantor');
select throws_ok(
  $$select pg_temp.loan(gen_random_uuid(), 'KZ-W1-0009',
    'cccccccc-0000-4000-8000-000000000001', 500000,
    'dddddddd-0000-4000-8000-000000000001', null, pg_temp.today() - 1)$$,
  '23514', null, 'a loan cannot fall due before it was issued');
select throws_ok(
  $$select pg_temp.loan(gen_random_uuid(), 'KZ-W1-0009',
    'cccccccc-0000-4000-8000-000000000001', 0,
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'the principal is positive');
select throws_ok(
  $$select pg_temp.loan(gen_random_uuid(), 'KZ-W1-0009',
    'cccccccc-0000-4000-8000-000000000002', 500000,
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23503', null, 'the borrower must be a party of the same business');

-- The disbursal: payment out + khata entry, both tied to the loan.
select lives_ok(
  $$select pg_temp.loan_pay('20000000-0000-4000-8000-000000000001', 'V-W1-0001',
    'to_party', 10000000, '10000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000001')$$,
  'the disbursal payment is recorded against the loan');
select throws_ok(
  $$select pg_temp.loan_pay(gen_random_uuid(), 'V-W1-0002', 'to_party', 5000,
    '10000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a disbursal must be the loan principal');
select throws_ok(
  $$select pg_temp.loan_pay(gen_random_uuid(), 'V-W1-0003', 'to_party', 10000000,
    '10000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000001',
    'cccccccc-0000-4000-8000-000000000003')$$,
  '23514', null, 'a loan payment must be with the borrower');
select lives_ok(
  $$select pg_temp.led('loan_disbursal', 'udhaar', 10000000,
    '10000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000001')$$,
  'the disbursal entry matches the loan');
select throws_ok(
  $$select pg_temp.led('loan_disbursal', 'udhaar', 9999999,
    '10000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a disbursal of another amount is refused');
select throws_ok(
  $$select pg_temp.led('loan_disbursal', 'udhaar', 10000000, gen_random_uuid(),
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a disbursal of no loan is refused');

-- Rate changes: append-only, effective on or after the issue date.
select lives_ok(
  $$insert into public.loan_rate_changes (id, tenant_id, loan_id, effective_date,
      rate_pa, reason, device_id)
    values ('30000000-0000-4000-8000-000000000001',
      '11111111-1111-4111-8111-111111111111',
      '10000000-0000-4000-8000-000000000001', pg_temp.today() + 10, '24',
      'Season changed', 'dddddddd-0000-4000-8000-000000000001')$$,
  'the owner changes the rate');
select throws_ok(
  $$insert into public.loan_rate_changes (id, tenant_id, loan_id, effective_date,
      rate_pa, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '10000000-0000-4000-8000-000000000001', pg_temp.today() - 1, '24',
      'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a rate cannot change before the loan was issued');
select throws_ok(
  $$insert into public.loan_rate_changes (id, tenant_id, loan_id, effective_date,
      rate_pa, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '10000000-0000-4000-8000-000000000001', pg_temp.today(), '100.5',
      'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a rate is at most 100');
select throws_ok(
  $$update public.loan_rate_changes set rate_pa = '30'
    where id = '30000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'rate changes cannot be edited');
select throws_ok(
  $$delete from public.loan_rate_changes
    where id = '30000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'rate changes cannot be deleted');

-- A loan is frozen except for its notes and closing.
select throws_ok(
  $$update public.loans set principal_paise = 1
    where id = '10000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'the principal of an issued loan cannot change');
select throws_ok(
  $$update public.loans set interest_config_snapshot = '{"rate_pa":"1"}'::jsonb
    where id = '10000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'the interest snapshot cannot be edited');
select lives_ok(
  $$update public.loans set notes = 'Needs it for diesel'
    where id = '10000000-0000-4000-8000-000000000001'$$,
  'notes can be edited while the loan is active');

-- ---------------------------------------------------------------------------
-- As the munshi: repays, cannot issue / change / close
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select throws_ok(
  $$select pg_temp.loan(gen_random_uuid(), 'KZ-A1-0001',
    'cccccccc-0000-4000-8000-000000000001', 500000,
    'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'a munshi cannot issue a loan');
select throws_ok(
  $$insert into public.loan_rate_changes (id, tenant_id, loan_id, effective_date,
      rate_pa, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '10000000-0000-4000-8000-000000000001', pg_temp.today(), '12',
      'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'a munshi cannot change a rate');
select is_empty(
  $$update public.loans set status = 'closed', closed_on = pg_temp.today()
    where id = '10000000-0000-4000-8000-000000000001' returning id$$,
  'a munshi cannot close a loan');
select throws_ok(
  $$select pg_temp.loan_pay(gen_random_uuid(), 'V-A1-0001', 'to_party', 10000000,
    '10000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'a munshi cannot disburse a loan');
select lives_ok(
  $$select pg_temp.loan_pay('20000000-0000-4000-8000-000000000002', 'R-A1-0001',
    'from_party', 2000000, '10000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000004')$$,
  'a munshi records a repayment');
select lives_ok(
  $$select pg_temp.led('loan_repayment', 'jama', 2000000,
    '20000000-0000-4000-8000-000000000002',
    'dddddddd-0000-4000-8000-000000000004')$$,
  'the repayment entry points at the repayment payment');
select throws_ok(
  $$select pg_temp.led('loan_repayment', 'jama', 2000000, gen_random_uuid(),
    'dddddddd-0000-4000-8000-000000000004')$$,
  '23514', null, 'a repayment of nothing is refused');

-- ---------------------------------------------------------------------------
-- As the accountant
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);

select throws_ok(
  $$select pg_temp.loan(gen_random_uuid(), 'KZ-W2-0001',
    'cccccccc-0000-4000-8000-000000000001', 500000,
    'dddddddd-0000-4000-8000-000000000003')$$,
  '42501', null, 'an accountant cannot issue a loan');

-- ---------------------------------------------------------------------------
-- The owner closes a loan; closed loans are frozen and take no payments
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select throws_ok(
  $$update public.loans set status = 'written_off', closed_on = pg_temp.today()
    where id = '10000000-0000-4000-8000-000000000001'$$,
  '23514', null, 'a write-off needs a reason');
select lives_ok(
  $$update public.loans set status = 'written_off', closed_on = pg_temp.today(),
      close_reason = 'Farmer passed away'
    where id = '10000000-0000-4000-8000-000000000001'$$,
  'the owner writes a loan off with a reason');
select throws_ok(
  $$update public.loans set notes = 'again'
    where id = '10000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a written-off loan cannot change');
select throws_ok(
  $$insert into public.loan_rate_changes (id, tenant_id, loan_id, effective_date,
      rate_pa, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '10000000-0000-4000-8000-000000000001', pg_temp.today(), '12',
      'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a closed loan has no rate changes');
select throws_ok(
  $$select pg_temp.loan_pay(gen_random_uuid(), 'R-W1-0001', 'from_party', 100,
    '10000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a closed loan takes no payments');
select throws_ok(
  $$select pg_temp.led('loan_repayment', 'jama', 100,
    '10000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a closed loan takes no repayment entries');

-- ---------------------------------------------------------------------------
-- Business 2 cannot see or touch business 1's loans
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);

select is_empty($$select id from public.loans$$, 'another business sees no loans');
select is_empty($$select id from public.loan_rate_changes$$,
  'another business sees no rate changes');
select throws_ok(
  $$select pg_temp.loan(gen_random_uuid(), 'KZ-W1-0001',
    'cccccccc-0000-4000-8000-000000000001', 500000,
    'dddddddd-0000-4000-8000-000000000002',
    null, null, '11111111-1111-4111-8111-111111111111')$$,
  '42501', null, 'nor issue a loan in business 1');

select * from finish();
rollback;
