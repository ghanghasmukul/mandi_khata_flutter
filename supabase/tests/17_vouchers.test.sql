-- Step 3.2: vouchers. Who may post, frozen once posted, reversal, the
-- voucher's journal / khata / book lines, own accounts, tenant isolation.
begin;
create extension if not exists pgtap with schema extensions;
select plan(21);

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
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Farmer One');

create temp table acct as
select 'farmer'::text k, private.chart_id('11111111-1111-4111-8111-111111111111', 'party',
  'cccccccc-0000-4000-8000-000000000001') id
union all select 'cash', private.chart_id('11111111-1111-4111-8111-111111111111', 'book',
  (select id::text from public.bank_accounts
   where tenant_id = '11111111-1111-4111-8111-111111111111' and kind = 'cash'))
union all select 'sales', private.chart_id('11111111-1111-4111-8111-111111111111', 'account',
  'sales');
grant select on acct to authenticated;

create temp table ids as
select (select id from public.bank_accounts
        where tenant_id = '11111111-1111-4111-8111-111111111111' and kind = 'cash') cash,
  private.chart_id('11111111-1111-4111-8111-111111111111', 'group', 'indirect_expenses') ind,
  private.chart_id('11111111-1111-4111-8111-111111111111', 'group', 'sundry_debtors') debtors;
grant select on ids to authenticated;

-- A sales voucher for cash: Dr Cash, Cr Sales; one book line; as one upload.
create function pg_temp.vpost(p_id uuid, p_device uuid, p_no text) returns void
language plpgsql as $$
begin
  insert into public.vouchers (id, tenant_id, voucher_type, voucher_no, entry_date,
    total_paise, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', 'sales', p_no,
    (now() at time zone 'Asia/Kolkata')::date, 90000, p_device);
  insert into public.journal_entries (id, tenant_id, source_key, source_type, voucher_id,
    entry_date, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', 'voucher:' || p_id, 'voucher', p_id,
    (now() at time zone 'Asia/Kolkata')::date, p_device);
  insert into public.journal_lines (id, tenant_id, journal_entry_id, line_no, account_id,
    debit_paise, credit_paise)
  values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', p_id, 0,
     (select id from acct where k = 'cash'), 90000, 0),
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', p_id, 1,
     (select id from acct where k = 'sales'), 0, 90000);
  insert into public.cash_bank_entries (id, tenant_id, account_id, account_kind,
    entry_date, direction, amount_paise, voucher_id, device_id)
  values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', (select cash from ids),
    'cash', (now() at time zone 'Asia/Kolkata')::date, 'in', 90000, p_id, p_device);
  set constraints all immediate;
  set constraints all deferred;
end;
$$;

select is(
  (select count(*)::int from public.accounts
   where tenant_id = '22222222-2222-4222-8222-222222222222'
     and system_code in ('sales', 'purchase', 'capital', 'profit_and_loss', 'cash_short_excess')),
  5, 'every business gets Sales, Purchase, Capital, P&L and Cash Short / Excess');
select is(
  (select g.code from public.accounts a join public.account_groups g
     on g.id = a.group_id and g.tenant_id = a.tenant_id
   where a.id = (select id from acct where k = 'sales')), 'sales_accounts',
  'Sales is in Sales Accounts');

set local role authenticated;

-- ---------------------------------------------------------------------------
-- Accountant
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);

select lives_ok(
  $$select pg_temp.vpost('70000000-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000003', 'SV-W2-0001')$$,
  'an accountant posts a voucher with its journal entry and book line');
select is(
  (select voucher_id::text from public.journal_entries
   where id = '70000000-0000-4000-8000-000000000001'),
  '70000000-0000-4000-8000-000000000001', 'the journal entry points at the voucher');
select throws_ok(
  $$insert into public.journal_entries (id, tenant_id, source_key, source_type, entry_date,
      device_id)
    values ('70000000-0000-4000-8000-0000000000f1', '11111111-1111-4111-8111-111111111111',
      'voucher:x', 'voucher', current_date, 'dddddddd-0000-4000-8000-000000000003')$$,
  '23514', null, 'a voucher journal entry must name its voucher');
select throws_ok(
  $$select pg_temp.vpost('70000000-0000-4000-8000-000000000002',
    'dddddddd-0000-4000-8000-000000000003', 'SV-W2-0001')$$,
  '23505', null, 'voucher numbers are unique in a business');
select throws_ok(
  $$update public.vouchers set total_paise = 1
    where id = '70000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a posted voucher cannot be edited');
select lives_ok(
  $$update public.vouchers set status = 'reversed', reversed_at = now()
    where id = '70000000-0000-4000-8000-000000000001'$$,
  'it can be marked reversed');
select throws_ok(
  $$update public.vouchers set status = 'posted', reversed_at = null
    where id = '70000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'and a reversed voucher never changes again');
select throws_ok(
  $$insert into public.vouchers (id, tenant_id, voucher_type, voucher_no, entry_date,
      total_paise, device_id, status, reversed_at)
    values ('70000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
      'journal', 'JV-W2-0001', current_date, 1, 'dddddddd-0000-4000-8000-000000000003',
      'reversed', now())$$,
  '23514', null, 'a voucher is created posted');
select throws_ok(
  $$insert into public.vouchers (id, tenant_id, voucher_type, voucher_no, entry_date,
      total_paise, device_id)
    values ('70000000-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
      'journal', 'JV-W2-0002', current_date, 1, 'dddddddd-0000-4000-8000-000000000001')$$,
  '42501', null, 'a voucher comes from one of the uploader''s devices');

-- Khata entries of type voucher.
select lives_ok(
  $$insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side,
      amount_paise, ref_type, ref_id, device_id)
    values ('70000000-0000-4000-8000-0000000000a1', '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', (now() at time zone 'Asia/Kolkata')::date,
      'udhaar', 500, 'voucher', '70000000-0000-4000-8000-000000000001',
      'dddddddd-0000-4000-8000-000000000003')$$,
  'a voucher line posts to a party''s khata');

-- Own accounts.
select lives_ok(
  $$insert into public.accounts (id, tenant_id, group_id, name)
    values ('70000000-0000-4000-8000-0000000000b1', '11111111-1111-4111-8111-111111111111',
      (select ind from ids), 'Rent')$$,
  'an accountant adds an account of their own');
select throws_ok(
  $$insert into public.accounts (id, tenant_id, group_id, name, party_id)
    values ('70000000-0000-4000-8000-0000000000b2', '11111111-1111-4111-8111-111111111111',
      (select debtors from ids), 'Fake', 'cccccccc-0000-4000-8000-000000000001')$$,
  '42501', null, 'but not one that owns a party');
select throws_ok(
  $$insert into public.cash_bank_entries (id, tenant_id, account_id, account_kind,
      entry_date, direction, amount_paise, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', (select cash from ids),
      'cash', current_date, 'in', 1, 'dddddddd-0000-4000-8000-000000000003')$$,
  '23514', null, 'a book line belongs to a payment or a voucher');

-- ---------------------------------------------------------------------------
-- Munshi
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select throws_ok(
  $$select pg_temp.vpost('70000000-0000-4000-8000-000000000005',
    'dddddddd-0000-4000-8000-000000000004', 'SV-A1-0001')$$,
  '42501', null, 'a munshi cannot post a voucher');
select throws_ok(
  $$insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side,
      amount_paise, ref_type, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', (now() at time zone 'Asia/Kolkata')::date,
      'udhaar', 500, 'voucher', 'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'nor a voucher khata entry');
select is(
  (select count(*)::int from public.vouchers), 1,
  'a munshi sees the business''s vouchers (their khata / cash lines sync anyway)');
update public.vouchers set narration = 'munshi'
where id = '70000000-0000-4000-8000-000000000001';
select is(
  (select count(*)::int from public.vouchers where narration = 'munshi'), 0,
  'and cannot change one (RLS: entries.reverse)');

-- ---------------------------------------------------------------------------
-- Another business
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.vouchers), 0,
  'another business sees no vouchers of this one');
select throws_ok(
  $$insert into public.vouchers (id, tenant_id, voucher_type, voucher_no, entry_date,
      total_paise, device_id)
    values ('70000000-0000-4000-8000-000000000006', '11111111-1111-4111-8111-111111111111',
      'journal', 'JV-W1-0009', current_date, 1, 'dddddddd-0000-4000-8000-000000000002')$$,
  '42501', null, 'nor posts into it');

select * from finish();
rollback;
