-- Step 3.4: expense categories (seeded, with accounts), expenses, recurring
-- months, the bills bucket, permissions and tenant isolation.
begin;
create extension if not exists pgtap with schema extensions;
select plan(20);

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

insert into public.bank_accounts (id, tenant_id, kind, name) values
  ('ffffffff-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'bank', 'SBI');

create temp table ids as
select (select id from public.bank_accounts
        where tenant_id = '11111111-1111-4111-8111-111111111111' and kind = 'cash') cash,
  private.chart_id('11111111-1111-4111-8111-111111111111', 'expense_category', 'salary') salary,
  private.chart_id('11111111-1111-4111-8111-111111111111', 'expense', (
    private.chart_id('11111111-1111-4111-8111-111111111111', 'expense_category', 'salary')
  )::text) salary_acct,
  private.chart_id('11111111-1111-4111-8111-111111111111', 'group', 'indirect_expenses') ind,
  private.chart_id('11111111-1111-4111-8111-111111111111', 'group', 'direct_expenses') dir;
grant select on ids to authenticated;

create function pg_temp.expense(p_id uuid, p_no text, p_device uuid, p_mode text,
  p_account uuid, p_recurring uuid default null, p_period text default null,
  p_date date default (now() at time zone 'Asia/Kolkata')::date)
returns void language plpgsql as $$
begin
  insert into public.expenses (id, tenant_id, expense_no, entry_date, category_id,
    amount_paise, mode, bank_account_id, recurring_id, period, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', p_no, p_date,
    (select salary from ids), 1200000, p_mode, p_account, p_recurring, p_period, p_device);
end;
$$;

select is(
  (select count(*)::int from public.expense_categories
   where tenant_id = '22222222-2222-4222-8222-222222222222'), 8,
  'a business starts with 8 expense categories');
select is(
  (select group_id from public.accounts where id = (select salary_acct from ids)),
  (select ind from ids), 'Salary''s account is in Indirect Expenses, with the v5 id');

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select lives_ok(
  $$insert into public.expense_categories (id, tenant_id, name, group_code)
    values ('80000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
      'Diesel', 'direct_expenses')$$,
  'the owner adds a category');
select is(
  (select name from public.accounts
   where expense_category_id = '80000000-0000-4000-8000-000000000001'), 'Diesel',
  'and the server gives it an account');
select lives_ok(
  $$update public.expense_categories set name = 'Diesel / fuel', group_code = 'indirect_expenses'
    where id = '80000000-0000-4000-8000-000000000001'$$,
  'renaming / regrouping a category');
select results_eq(
  $$select name, group_id from public.accounts
    where expense_category_id = '80000000-0000-4000-8000-000000000001'$$,
  $$select 'Diesel / fuel'::text, (select ind from ids)$$,
  'moves and renames its account');
select throws_ok(
  $$update public.accounts set name = 'x'
    where expense_category_id = '80000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'the account itself follows the category');
select throws_ok(
  $$insert into public.expense_categories (id, tenant_id, code, name)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'fake', 'Fake')$$,
  '42501', null, 'clients do not create seeded categories');

select lives_ok(
  $$select pg_temp.expense('81000000-0000-4000-8000-000000000001', 'EX-W1-0001',
    'dddddddd-0000-4000-8000-000000000001', 'cash', (select cash from ids))$$,
  'the owner records a cash expense');
select throws_ok(
  $$select pg_temp.expense(gen_random_uuid(), 'EX-W1-0002',
    'dddddddd-0000-4000-8000-000000000001', 'bank', (select cash from ids))$$,
  '23514', null, 'a bank expense cannot use the Cash account');
select throws_ok(
  $$update public.expenses set amount_paise = 1
    where id = '81000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a posted expense is frozen');
select lives_ok(
  $$update public.expenses set bill_path = '11111111-1111-4111-8111-111111111111/x/bill.jpg'
    where id = '81000000-0000-4000-8000-000000000001'$$,
  'its bill can be attached once');
select throws_ok(
  $$update public.expenses set bill_path = 'other'
    where id = '81000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'but not replaced');

-- Recurring: one month once.
insert into public.recurring_expenses (id, tenant_id, category_id, amount_paise, mode,
  bank_account_id, day_of_month, start_date)
values ('82000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
  (select salary from ids), 1200000, 'cash', (select cash from ids), 1, '2027-01-01');
select lives_ok(
  $$select pg_temp.expense(gen_random_uuid(), 'EX-W1-0003',
    'dddddddd-0000-4000-8000-000000000001', 'cash', (select cash from ids),
    '82000000-0000-4000-8000-000000000001', '2027-04')$$,
  'a recurring month is posted');
select throws_ok(
  $$select pg_temp.expense(gen_random_uuid(), 'EX-W1-0004',
    'dddddddd-0000-4000-8000-000000000001', 'cash', (select cash from ids),
    '82000000-0000-4000-8000-000000000001', '2027-04')$$,
  '23505', null, 'and never twice');

-- Bills bucket: own business folder only.
select lives_ok(
  $$insert into storage.objects (bucket_id, name, owner)
    values ('bills', '11111111-1111-4111-8111-111111111111/x/bill.jpg',
      'aaaaaaaa-0000-4000-8000-000000000001')$$,
  'a bill goes into the business''s folder');
select throws_ok(
  $$insert into storage.objects (bucket_id, name, owner)
    values ('bills', '22222222-2222-4222-8222-222222222222/x/bill.jpg',
      'aaaaaaaa-0000-4000-8000-000000000001')$$,
  '42501', null, 'never into another business''s folder');

-- The munshi: cash only, no reversal.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);
select throws_ok(
  $$select pg_temp.expense(gen_random_uuid(), 'EX-A1-0001',
    'dddddddd-0000-4000-8000-000000000004', 'bank', 'ffffffff-0000-4000-8000-000000000002')$$,
  '42501', null, 'a munshi cannot record a bank expense');
select throws_ok(
  $$select pg_temp.expense(gen_random_uuid(), 'EX-A1-0002',
    'dddddddd-0000-4000-8000-000000000004', 'cash', (select cash from ids),
    p_date => (now() at time zone 'Asia/Kolkata')::date - 30)$$,
  '42501', null, 'nor a back-dated one');

-- Another business.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.expenses
   where tenant_id = '11111111-1111-4111-8111-111111111111')
  + (select count(*)::int from storage.objects where bucket_id = 'bills'), 0,
  'another business sees none of the expenses or bills');

select * from finish();
rollback;
