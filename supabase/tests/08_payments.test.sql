-- bank_accounts, payments, cash_bank_entries: tenant isolation, the Cash
-- account for everyone and bank accounts for finance.view, the munshi
-- payment limit, cheque status moves (a bounce needs entries.reverse),
-- frozen payments, append-only book lines.
begin;
create extension if not exists pgtap with schema extensions;
select plan(38);

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
  ('dddddddd-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000003', 'W2', 'windows'),
  ('dddddddd-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'A1', 'android');

insert into public.parties (id, tenant_id, code, name) values
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Farmer One'),
  ('cccccccc-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'F-1', 'Farmer Two');

-- A bank account of business 2 (as postgres).
insert into public.bank_accounts (id, tenant_id, kind, name) values
  ('e3000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'bank', 'SBI Two');

-- Cash accounts are seeded for every business.
select is(
  (select count(*)::int from public.bank_accounts where kind = 'cash'
    and tenant_id in ('11111111-1111-4111-8111-111111111111',
      '22222222-2222-4222-8222-222222222222')),
  2, 'every business has a Cash account');

create function pg_temp.cash1() returns uuid language sql as $$
  select extensions.uuid_generate_v5('3d8f2a6e-4c1b-4f0a-9b7e-5a2c8d1e6f30'::uuid,
    '11111111-1111-4111-8111-111111111111|account|cash');
$$;

create function pg_temp.pay(
  p_id uuid, p_no text, p_dir text, p_mode text, p_amount bigint,
  p_account uuid, p_device uuid, p_cheque_no text default null
) returns void language sql as $$
  insert into public.payments (id, tenant_id, receipt_no, entry_date, party_id,
    direction, mode, amount_paise, bank_account_id, cheque_no, cheque_date,
    cheque_status, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', p_no,
    (now() at time zone 'Asia/Kolkata')::date,
    'cccccccc-0000-4000-8000-000000000001', p_dir, p_mode, p_amount, p_account,
    p_cheque_no,
    case when p_cheque_no is not null then (now() at time zone 'Asia/Kolkata')::date end,
    case when p_cheque_no is not null then 'pending' end,
    p_device);
$$;

create function pg_temp.led(
  p_ref text, p_side text, p_amount bigint, p_device uuid, p_ref_id uuid
) returns void language sql as $$
  insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side,
    amount_paise, ref_type, ref_id, device_id)
  values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
    'cccccccc-0000-4000-8000-000000000001',
    (now() at time zone 'Asia/Kolkata')::date, p_side, p_amount, p_ref, p_ref_id,
    p_device);
$$;

create function pg_temp.book(
  p_id uuid, p_account uuid, p_kind text, p_dir text, p_amount bigint,
  p_payment uuid, p_device uuid, p_reverses uuid default null
) returns void language sql as $$
  insert into public.cash_bank_entries (id, tenant_id, account_id, account_kind,
    entry_date, direction, amount_paise, payment_id, reverses_id, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', p_account, p_kind,
    (now() at time zone 'Asia/Kolkata')::date, p_dir, p_amount, p_payment,
    p_reverses, p_device);
$$;

set local role authenticated;

-- ---------------------------------------------------------------------------
-- As the accountant: bank accounts
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);

select lives_ok(
  $$insert into public.bank_accounts (id, tenant_id, kind, name, bank_name, account_last4, ifsc)
    values ('e3000000-0000-4000-8000-000000000001',
      '11111111-1111-4111-8111-111111111111', 'bank', 'SBI Current',
      'State Bank of India', '7890', 'SBIN0001234')$$,
  'accountant adds a bank account');
select throws_ok(
  $$insert into public.bank_accounts (id, tenant_id, kind, name)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'cash', 'Cash 2')$$,
  '42501', null, 'clients never add a cash account');
select throws_ok(
  $$insert into public.bank_accounts (id, tenant_id, kind, name, account_last4)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'bank', 'X', '12345678')$$,
  '23514', null, 'only the last 4 digits of an account number are stored');
select throws_ok(
  $$update public.bank_accounts set is_active = false where id = pg_temp.cash1()$$,
  '42501', null, 'the Cash account cannot be switched off');
select throws_ok(
  $$update public.bank_accounts set kind = 'cash' where id = 'e3000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'an account kind cannot change');
select is(
  (select count(*)::int from public.bank_accounts), 2,
  'accountant sees Cash and the bank account of business 1 only');

-- ---------------------------------------------------------------------------
-- As munshi 1: Cash only, payments within the rules
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select is(
  (select array_agg(kind) from public.bank_accounts), array['cash'],
  'munshi sees only the Cash account');
select throws_ok(
  $$insert into public.bank_accounts (id, tenant_id, kind, name)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'bank', 'Mine')$$,
  '42501', null, 'munshi cannot add a bank account');

select lives_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000001', 'V-A1-0001',
      'to_party', 'cash', 1000000, pg_temp.cash1(),
      'dddddddd-0000-4000-8000-000000000004')$$,
  'munshi pays a farmer in cash');
select lives_ok(
  $$select pg_temp.led('payment', 'udhaar', 1000000,
      'dddddddd-0000-4000-8000-000000000004', 'e1000000-0000-4000-8000-000000000001')$$,
  '… with its khata entry');
select lives_ok(
  $$select pg_temp.book('e2000000-0000-4000-8000-000000000001', pg_temp.cash1(),
      'cash', 'out', 1000000, 'e1000000-0000-4000-8000-000000000001',
      'dddddddd-0000-4000-8000-000000000004')$$,
  '… and its cash book line');
select throws_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000002', 'V-A1-0002',
      'to_party', 'bank', 1000000, 'e3000000-0000-4000-8000-000000000001',
      'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'munshi cannot pay by bank');
select throws_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000002', 'V-A1-0002',
      'to_party', 'cash', 1000000, 'e3000000-0000-4000-8000-000000000001',
      'dddddddd-0000-4000-8000-000000000004')$$,
  '23514', null, 'cash cannot point at a bank account, even one the munshi cannot see');
select throws_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000002', 'V-A1-0001',
      'to_party', 'cash', 1000000, pg_temp.cash1(),
      'dddddddd-0000-4000-8000-000000000004')$$,
  '23505', null, 'a receipt number is unique per business');
select throws_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000002', 'V-A1-0002',
      'to_party', 'cash', 1000000, pg_temp.cash1(),
      'dddddddd-0000-4000-8000-000000000003')$$,
  '42501', null, 'payments must come from the uploader''s own device');
select throws_ok(
  $$delete from public.payments where id = 'e1000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'payments are never deleted');
select throws_ok(
  $$update public.payments set amount_paise = 1 where id = 'e1000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a posted payment cannot change');
select throws_ok(
  $$update public.payments set status = 'reversed', reversed_at = now()
    where id = 'e1000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'munshi cannot reverse a payment');
select throws_ok(
  $$update public.cash_bank_entries set amount_paise = 1
    where id = 'e2000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'book lines are append-only');

-- ---------------------------------------------------------------------------
-- The payment limit (business.munshi_payment_limit, paise)
-- ---------------------------------------------------------------------------
reset role;
insert into public.settings (id, tenant_id, scope, key, value) values
  ('99999999-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'tenant', 'business.munshi_payment_limit', '5000000');
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select lives_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000003', 'V-A1-0003',
      'to_party', 'cash', 5000000, pg_temp.cash1(),
      'dddddddd-0000-4000-8000-000000000004')$$,
  'munshi: a payment at the limit');
select throws_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000004', 'V-A1-0004',
      'to_party', 'cash', 5000001, pg_temp.cash1(),
      'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'munshi: a payment above the limit needs entries.reverse');
select throws_ok(
  $$select pg_temp.led('payment', 'udhaar', 5000001,
      'dddddddd-0000-4000-8000-000000000004', null)$$,
  '42501', null, 'munshi: nor can the khata entry be posted alone');
select lives_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000005', 'R-A1-0005',
      'from_party', 'cash', 90000000, pg_temp.cash1(),
      'dddddddd-0000-4000-8000-000000000004')$$,
  'munshi: receipts are never limited');

select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);
select lives_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000006', 'V-W2-0006',
      'to_party', 'cash', 6000000, pg_temp.cash1(),
      'dddddddd-0000-4000-8000-000000000003')$$,
  'accountant: above the limit is fine');

-- ---------------------------------------------------------------------------
-- Cheques: pending → cleared / bounced
-- ---------------------------------------------------------------------------
select lives_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000007', 'V-W2-0007',
      'to_party', 'cheque', 200000, 'e3000000-0000-4000-8000-000000000001',
      'dddddddd-0000-4000-8000-000000000003', '004512')$$,
  'accountant pays by cheque');
select throws_ok(
  $$update public.payments set cheque_status = 'bounced'
    where id = 'e1000000-0000-4000-8000-000000000007'$$,
  '23514', null, 'a bounce also reverses the payment (check constraint)');
select lives_ok(
  $$update public.payments set cheque_status = 'cleared'
    where id = 'e1000000-0000-4000-8000-000000000007'$$,
  'a pending cheque clears');
select throws_ok(
  $$update public.payments set cheque_status = 'pending'
    where id = 'e1000000-0000-4000-8000-000000000007'$$,
  '23514', null, 'a cleared cheque is final');

select lives_ok(
  $$select pg_temp.pay('e1000000-0000-4000-8000-000000000008', 'V-W2-0008',
      'to_party', 'cheque', 300000, 'e3000000-0000-4000-8000-000000000001',
      'dddddddd-0000-4000-8000-000000000003', '004513')$$,
  'a second cheque');
select lives_ok(
  $$select pg_temp.book('e2000000-0000-4000-8000-000000000008',
      'e3000000-0000-4000-8000-000000000001', 'bank', 'out', 300000,
      'e1000000-0000-4000-8000-000000000008', 'dddddddd-0000-4000-8000-000000000003')$$,
  'its bank book line');
select throws_ok(
  $$select pg_temp.book('e2000000-0000-4000-8000-000000000009',
      'e3000000-0000-4000-8000-000000000001', 'bank', 'in', 299999,
      'e1000000-0000-4000-8000-000000000008', 'dddddddd-0000-4000-8000-000000000003',
      'e2000000-0000-4000-8000-000000000008')$$,
  '23514', null, 'a book reversal must mirror the line');
select lives_ok(
  $$update public.payments set cheque_status = 'bounced', status = 'reversed',
      reversed_at = now() where id = 'e1000000-0000-4000-8000-000000000008'$$,
  'accountant bounces the cheque');
select lives_ok(
  $$select pg_temp.book('e2000000-0000-4000-8000-000000000009',
      'e3000000-0000-4000-8000-000000000001', 'bank', 'in', 300000,
      'e1000000-0000-4000-8000-000000000008', 'dddddddd-0000-4000-8000-000000000003',
      'e2000000-0000-4000-8000-000000000008')$$,
  '… and reverses the book line');
select throws_ok(
  $$select pg_temp.book('e2000000-0000-4000-8000-00000000000a',
      'e3000000-0000-4000-8000-000000000001', 'bank', 'in', 300000,
      'e1000000-0000-4000-8000-000000000008', 'dddddddd-0000-4000-8000-000000000003',
      'e2000000-0000-4000-8000-000000000008')$$,
  '23505', null, 'a book line is reversed once');
select throws_ok(
  $$update public.payments set narration = 'x'
    where id = 'e1000000-0000-4000-8000-000000000008'$$,
  '42501', null, 'a reversed payment never changes');

-- ---------------------------------------------------------------------------
-- Isolation
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);

select is(
  (select count(*)::int from public.payments), 0,
  'owner 2 sees no payments of business 1');
select is(
  (select count(*)::int from public.bank_accounts where tenant_id = '11111111-1111-4111-8111-111111111111'),
  0, 'owner 2 sees no accounts of business 1');

select * from finish();
rollback;
