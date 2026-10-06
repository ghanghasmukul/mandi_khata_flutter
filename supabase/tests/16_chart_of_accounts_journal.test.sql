-- Step 3.1: chart of accounts and journal: seeding, party / bank accounts,
-- tenant isolation, finance.view to read, the permission of the document to
-- post, balance and mirror checks, one reversal, entries do not grow later.
begin;
create extension if not exists pgtap with schema extensions;
select plan(23);

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


insert into public.party_roles (id, tenant_id, party_id, role) values
  ('eeeeeeee-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'cccccccc-0000-4000-8000-000000000001', 'farmer'),
  ('eeeeeeee-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   'cccccccc-0000-4000-8000-000000000003', 'farmer');

-- The Cash account is seeded with the business; add one bank account.
insert into public.bank_accounts (id, tenant_id, kind, name) values
  ('ffffffff-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111',
   'bank', 'SBI');

-- Account ids as the app derives them (UUID v5), looked up as postgres.
create temp table acct as
select 'farmer'::text k, private.chart_id('11111111-1111-4111-8111-111111111111', 'party',
  'cccccccc-0000-4000-8000-000000000001') id
union all select 'farmer3', private.chart_id('11111111-1111-4111-8111-111111111111', 'party',
  'cccccccc-0000-4000-8000-000000000003')
union all select 'cash', private.chart_id('11111111-1111-4111-8111-111111111111', 'book',
  (select id::text from public.bank_accounts
   where tenant_id = '11111111-1111-4111-8111-111111111111' and kind = 'cash'))
union all select 'sbi', private.chart_id('11111111-1111-4111-8111-111111111111', 'book',
  'ffffffff-0000-4000-8000-000000000002')
union all select 'interest', private.chart_id('11111111-1111-4111-8111-111111111111', 'account',
  'interest_income')
union all select 'foreign', private.chart_id('22222222-2222-4222-8222-222222222222', 'party',
  'cccccccc-0000-4000-8000-000000000002');
grant select on acct to authenticated;

-- One entry with its lines, checked at the end like an upload does. p_lines:
-- [{"a": "<acct key>", "d": paise, "c": paise}].
create function pg_temp.jpost(
  p_id uuid, p_key text, p_type text, p_device uuid, p_lines jsonb,
  p_reverses uuid default null
) returns void language plpgsql as $$
begin
  insert into public.journal_entries (id, tenant_id, source_key, source_type,
    entry_date, device_id, reverses_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', p_key, p_type,
    (now() at time zone 'Asia/Kolkata')::date, p_device, p_reverses);
  insert into public.journal_lines (id, tenant_id, journal_entry_id, line_no,
    account_id, debit_paise, credit_paise)
  select gen_random_uuid(), '11111111-1111-4111-8111-111111111111', p_id,
    (row_number() over ())::int - 1,
    (select id from acct where k = l.a), coalesce(l.d, 0), coalesce(l.c, 0)
  from jsonb_to_recordset(p_lines) as l(a text, d bigint, c bigint);
  set constraints all immediate;
  set constraints all deferred;
end;
$$;

-- ---------------------------------------------------------------------------
-- Seeding (as postgres, before any role switch)
-- ---------------------------------------------------------------------------
select is(
  (select count(*)::int from public.account_groups
   where tenant_id = '11111111-1111-4111-8111-111111111111'), 14,
  'a business gets its 14 account groups');
select is(
  (select count(*)::int from public.accounts
   where tenant_id = '11111111-1111-4111-8111-111111111111' and is_system), 13,
  'and its 13 system accounts');
-- The Dart app computes the same ids (apps/mandi_khata_app/test/features/
-- accounts/chart_consistency_test.dart asserts these constants).
select is(
  private.chart_id('11111111-1111-4111-8111-111111111111', 'account', 'commission_income')::text
  || ' ' || private.chart_id('11111111-1111-4111-8111-111111111111', 'party',
       'f0000000-0000-4000-8000-000000000001')::text
  || ' ' || private.chart_id('11111111-1111-4111-8111-111111111111', 'book',
       'a0000000-0000-4000-8000-000000000001')::text
  || ' ' || private.chart_id('11111111-1111-4111-8111-111111111111', 'group',
       'sundry_debtors')::text,
  'dd8ccca6-8be7-537b-afb1-ba337008b796 3dee5529-6ccf-5c01-934d-b49c64136380 '
  '22aa4ef0-39a4-576b-b6d8-64d8d4d0bcc2 c335cbd3-7ca9-5fb3-87ce-bbc8e13608d2',
  'account ids are the UUID v5 values the app computes');
select is(
  (select g.code from public.accounts a join public.account_groups g
     on g.id = a.group_id and g.tenant_id = a.tenant_id
   where a.id = (select id from acct where k = 'farmer')), 'sundry_creditors',
  'a farmer''s account starts in Sundry Creditors');

insert into public.party_roles (id, tenant_id, party_id, role) values
  ('eeeeeeee-0000-4000-8000-0000000000a1', '11111111-1111-4111-8111-111111111111',
   'cccccccc-0000-4000-8000-000000000001', 'buyer');
select is(
  (select g.code from public.accounts a join public.account_groups g
     on g.id = a.group_id and g.tenant_id = a.tenant_id
   where a.id = (select id from acct where k = 'farmer')), 'sundry_debtors',
  'a farmer who is also a buyer moves to Sundry Debtors');

update public.parties set name = 'Farmer One Renamed'
where id = 'cccccccc-0000-4000-8000-000000000001';
select is(
  (select name from public.accounts where id = (select id from acct where k = 'farmer')),
  'Farmer One Renamed', 'renaming a party renames its account');
select is(
  (select g.code from public.accounts a join public.account_groups g
     on g.id = a.group_id and g.tenant_id = a.tenant_id
   where a.id = (select id from acct where k = 'cash')), 'cash_in_hand',
  'the Cash book account is in Cash-in-hand');
select is(
  (select g.code from public.accounts a join public.account_groups g
     on g.id = a.group_id and g.tenant_id = a.tenant_id
   where a.id = (select id from acct where k = 'sbi')), 'bank_accounts',
  'a bank account is in Bank Accounts');

set local role authenticated;

-- ---------------------------------------------------------------------------
-- The owner posts
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select lives_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-000000000001', 'payment:p1', 'payment',
    'dddddddd-0000-4000-8000-000000000001',
    '[{"a":"farmer","d":500000},{"a":"cash","c":500000}]')$$,
  'the owner posts a balanced entry');
select throws_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-000000000002', 'payment:p2', 'payment',
    'dddddddd-0000-4000-8000-000000000001',
    '[{"a":"farmer","d":500000},{"a":"cash","c":499999}]')$$,
  '23514', null, 'an unbalanced entry is refused');
select throws_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-000000000003', 'payment:p3', 'payment',
    'dddddddd-0000-4000-8000-000000000001', '[{"a":"farmer","d":500000}]')$$,
  '23514', null, 'an entry needs two lines');
select throws_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-000000000004', 'payment:p4', 'payment',
    'dddddddd-0000-4000-8000-000000000001',
    '[{"a":"farmer","d":100,"c":100},{"a":"cash","c":100,"d":100}]')$$,
  '23514', null, 'a line is a debit or a credit, not both');

-- A reversal: the mirror, once.
select lives_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-000000000005', 'reversal:payment:p1',
    'reversal', 'dddddddd-0000-4000-8000-000000000001',
    '[{"a":"farmer","c":500000},{"a":"cash","d":500000}]',
    '90000000-0000-4000-8000-000000000001')$$,
  'a reversal that mirrors the entry is accepted');
select throws_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-000000000006', 'reversal:payment:p1b',
    'reversal', 'dddddddd-0000-4000-8000-000000000001',
    '[{"a":"farmer","c":500000},{"a":"cash","d":500000}]',
    '90000000-0000-4000-8000-000000000001')$$,
  '23505', null, 'an entry is reversed once');
select lives_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-000000000007', 'payment:p7', 'payment',
    'dddddddd-0000-4000-8000-000000000001',
    '[{"a":"farmer","d":700},{"a":"sbi","c":700}]')$$,
  'another entry to reverse wrongly');
select throws_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-000000000008', 'reversal:payment:p7',
    'reversal', 'dddddddd-0000-4000-8000-000000000001',
    '[{"a":"farmer","c":700},{"a":"cash","d":700}]',
    '90000000-0000-4000-8000-000000000007')$$,
  '23514', null, 'a reversal on other accounts than the original is refused');

-- An entry cannot grow in a later transaction (simulated: forget the marker).
select set_config('mk.journal_new', '', true);
select throws_ok(
  $$insert into public.journal_lines (id, tenant_id, journal_entry_id, line_no,
      account_id, debit_paise)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '90000000-0000-4000-8000-000000000001', 9,
      (select id from acct where k = 'cash'), 1)$$,
  '23514', null, 'lines cannot be added to an old entry');

-- Append-only and a foreign business's account.
select throws_ok(
  $$update public.journal_entries set narration = 'x'
    where id = '90000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'an entry cannot be edited');
select throws_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-000000000009', 'payment:p9', 'payment',
    'dddddddd-0000-4000-8000-000000000001',
    '[{"a":"foreign","d":100},{"a":"cash","c":100}]')$$,
  '23503', null, 'a line cannot use another business''s account');

-- ---------------------------------------------------------------------------
-- Roles: the munshi posts a lot / payment entry but cannot read or post a bare one
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select lives_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-00000000000a', 'payment:pm', 'payment',
    'dddddddd-0000-4000-8000-000000000004',
    '[{"a":"farmer3","c":900},{"a":"cash","d":900}]')$$,
  'a munshi posts the journal entry of a payment (payments.create)');
select throws_ok(
  $$select pg_temp.jpost('90000000-0000-4000-8000-00000000000b', 'entry:xx', 'entry',
    'dddddddd-0000-4000-8000-000000000004',
    '[{"a":"farmer3","c":900},{"a":"cash","d":900}]')$$,
  '42501', null, 'but not a manual entry (entries.reverse)');
select is(
  (select count(*)::int from public.accounts), 0,
  'a munshi cannot read the chart of accounts (finance.view)');

-- ---------------------------------------------------------------------------
-- Another business sees nothing
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);

select is(
  (select count(*)::int from public.journal_entries
   where tenant_id = '11111111-1111-4111-8111-111111111111')
  + (select count(*)::int from public.accounts
     where tenant_id = '11111111-1111-4111-8111-111111111111'), 0,
  'another business sees no accounts and no entries of this one');

select * from finish();
rollback;
