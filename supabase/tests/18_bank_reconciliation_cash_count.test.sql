-- Step 3.3: bank statement lines, reconciliations, cash counts.
begin;
create extension if not exists pgtap with schema extensions;
select plan(17);

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

insert into public.devices (id, tenant_id, user_id, device_code, platform) values
  ('dddddddd-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'A1', 'android');

insert into public.parties (id, tenant_id, code, name) values
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Farmer One');

insert into public.bank_accounts (id, tenant_id, kind, name) values
  ('ffffffff-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'bank', 'SBI');

-- A bank receipt with its book line (as postgres: fixtures).
insert into public.payments (id, tenant_id, receipt_no, entry_date, party_id, direction,
  mode, amount_paise, bank_account_id, reference)
values ('99999999-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
  'R-W1-0001', current_date, 'cccccccc-0000-4000-8000-000000000001', 'from_party', 'bank',
  2500000, 'ffffffff-0000-4000-8000-000000000002', 'UTR123456');
insert into public.cash_bank_entries (id, tenant_id, account_id, account_kind, entry_date,
  direction, amount_paise, payment_id)
values ('98888888-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
  'ffffffff-0000-4000-8000-000000000002', 'bank', current_date, 'in', 2500000,
  '99999999-0000-4000-8000-000000000001');

create temp table ids as
select (select id from public.bank_accounts
        where tenant_id = '11111111-1111-4111-8111-111111111111' and kind = 'cash') cash;
grant select on ids to authenticated;

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

-- Statement lines.
select lives_ok(
  $$insert into public.bank_statement_lines (id, tenant_id, bank_account_id, txn_date,
      direction, amount_paise, reference, import_batch, device_id)
    values ('97777777-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
      'ffffffff-0000-4000-8000-000000000002', current_date, 'in', 2500000, 'UTR123456',
      gen_random_uuid(), 'dddddddd-0000-4000-8000-000000000001')$$,
  'the owner imports a statement line');
select throws_ok(
  $$insert into public.bank_statement_lines (id, tenant_id, bank_account_id, txn_date,
      direction, amount_paise, import_batch, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', (select cash from ids),
      current_date, 'in', 1, gen_random_uuid(), 'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'statement lines are for bank accounts only');
select throws_ok(
  $$update public.bank_statement_lines set amount_paise = 1
    where id = '97777777-0000-4000-8000-000000000001'$$,
  '42501', null, 'statement lines are append-only');

-- Reconciliations.
select throws_ok(
  $$insert into public.bank_reconciliations (id, tenant_id, bank_account_id, book_line_id,
      statement_line_id, reconciled_on, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'ffffffff-0000-4000-8000-000000000002', '98888888-0000-4000-8000-000000000001',
      (select id from (values ('97777777-0000-4000-8000-000000000009'::uuid)) v(id)),
      current_date, 'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a missing statement line is refused');
select lives_ok(
  $$insert into public.bank_reconciliations (id, tenant_id, bank_account_id, book_line_id,
      statement_line_id, reconciled_on, device_id)
    values ('96666666-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
      'ffffffff-0000-4000-8000-000000000002', '98888888-0000-4000-8000-000000000001',
      '97777777-0000-4000-8000-000000000001', current_date,
      'dddddddd-0000-4000-8000-000000000001')$$,
  'a book line and its statement line are reconciled');
select throws_ok(
  $$insert into public.bank_reconciliations (id, tenant_id, bank_account_id, book_line_id,
      reconciled_on, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'ffffffff-0000-4000-8000-000000000002', '98888888-0000-4000-8000-000000000001',
      current_date, 'dddddddd-0000-4000-8000-000000000001')$$,
  '23505', null, 'a book line is reconciled once at a time');
select throws_ok(
  $$update public.bank_reconciliations set reconciled_on = current_date - 1
    where id = '96666666-0000-4000-8000-000000000001'$$,
  '42501', null, 'a reconciliation can only be undone');
select lives_ok(
  $$update public.bank_reconciliations set deleted_at = now()
    where id = '96666666-0000-4000-8000-000000000001'$$,
  'it is undone with deleted_at');
select lives_ok(
  $$insert into public.bank_reconciliations (id, tenant_id, bank_account_id, book_line_id,
      reconciled_on, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'ffffffff-0000-4000-8000-000000000002', '98888888-0000-4000-8000-000000000001',
      current_date, 'dddddddd-0000-4000-8000-000000000001')$$,
  'and can then be reconciled again');

-- Cash counts.
select throws_ok(
  $$insert into public.cash_counts (id, tenant_id, count_date, bank_account_id,
      denominations, counted_paise, book_paise, difference_paise, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', current_date,
      (select cash from ids), '{"500": 2}', 100000, 90000, 1, 'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'the difference must be counted minus book');
select throws_ok(
  $$insert into public.cash_counts (id, tenant_id, count_date, bank_account_id,
      denominations, counted_paise, book_paise, difference_paise, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', current_date,
      'ffffffff-0000-4000-8000-000000000002', '{}', 0, 0, 0,
      'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a cash count is of the Cash account');

-- The munshi.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);
select lives_ok(
  $$insert into public.cash_counts (id, tenant_id, count_date, bank_account_id,
      denominations, counted_paise, book_paise, difference_paise, device_id)
    values ('95555555-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
      current_date, (select cash from ids), '{"500": 2}', 100000, 100500, -500,
      'dddddddd-0000-4000-8000-000000000004')$$,
  'a munshi records a cash count');
select is(
  (select count(*)::int from public.bank_statement_lines)
  + (select count(*)::int from public.bank_reconciliations), 0,
  'but sees no statement lines or reconciliations (finance.view)');
select throws_ok(
  $$insert into public.bank_statement_lines (id, tenant_id, bank_account_id, txn_date,
      direction, amount_paise, import_batch, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'ffffffff-0000-4000-8000-000000000002', current_date, 'in', 1, gen_random_uuid(),
      'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'and cannot import a statement');
update public.cash_counts set note = 'x' where id = '95555555-0000-4000-8000-000000000001';
select is(
  (select note from public.cash_counts where id = '95555555-0000-4000-8000-000000000001'),
  null, 'nor change a count');

-- Another business.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.cash_counts)
  + (select count(*)::int from public.bank_statement_lines)
  + (select count(*)::int from public.bank_reconciliations), 0,
  'another business sees none of it');
select throws_ok(
  $$insert into public.cash_counts (id, tenant_id, count_date, bank_account_id,
      denominations, counted_paise, book_paise, difference_paise, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', current_date,
      (select cash from ids), '{}', 0, 0, 0, 'dddddddd-0000-4000-8000-000000000002')$$,
  '42501', null, 'nor writes into it');

select * from finish();
rollback;
