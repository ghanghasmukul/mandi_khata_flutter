-- Role defaults from docs/domain/ledger-and-mandi.md: a munshi and an
-- accountant cannot do owner-only things; custom_permissions override roles.
begin;
create extension if not exists pgtap with schema extensions;
select plan(26);

-- Fixtures: business 1 with an owner, an accountant and a munshi.
insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'accountant1@test.local'),
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

insert into public.parties (id, tenant_id, code, name) values
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Party One');

insert into public.audit_log (id, tenant_id, table_name, row_id, action, user_id) values
  ('ffffffff-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'parties',
   'cccccccc-0000-4000-8000-000000000001', 'insert', 'aaaaaaaa-0000-4000-8000-000000000001');

-- ---- Munshi ----------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select lives_ok(
  $$insert into public.parties (id, tenant_id, code, name) values
    ('cccccccc-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
     'F-3', 'Added by munshi')$$,
  'munshi can add a party');
select throws_ok(
  $$update public.parties set deleted_at = now()
    where id = 'cccccccc-0000-4000-8000-000000000001'$$,
  '42501', null, 'munshi cannot delete a party');
select throws_ok(
  $$insert into public.settings (id, tenant_id, scope, key, value) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'tenant',
     'mandi.commission_pct', '3')$$,
  '42501', null, 'munshi cannot change business-wide settings');
select throws_ok(
  $$insert into public.settings (id, tenant_id, scope, scope_id, key, value) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'party',
     'cccccccc-0000-4000-8000-000000000001', 'interest.rate_pa', '24')$$,
  '42501', null, 'munshi cannot change a party''s interest rate');
select lives_ok(
  $$insert into public.settings (id, tenant_id, scope, scope_id, key, value) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'party',
     'cccccccc-0000-4000-8000-000000000001', 'mandi.bag_weight_kg', '50')$$,
  'munshi can set a non-interest party setting');
select throws_ok(
  $$insert into public.tenant_members (id, tenant_id, user_id, role) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'aaaaaaaa-0000-4000-8000-000000000004', 'owner')$$,
  '42501', null, 'munshi cannot add members');
select is((select count(*)::int from public.audit_log), 0,
  'munshi cannot read the audit log');
select ok(not private.has_permission('11111111-1111-4111-8111-111111111111', 'entries.reverse'),
  'munshi cannot reverse entries');
select ok(private.has_permission('11111111-1111-4111-8111-111111111111', 'payments.create'),
  'munshi can create payments');

-- Hidden by RLS (no admin.manage), so nothing changes.
update public.tenants set name = 'Renamed by munshi'
  where id = '11111111-1111-4111-8111-111111111111';
update public.tenant_members set role = 'owner'
  where id = 'bbbbbbbb-0000-4000-8000-000000000004';

reset role;
select is((select name from public.tenants
  where id = '11111111-1111-4111-8111-111111111111'), 'Business One',
  'munshi cannot rename the business');
select is((select role from public.tenant_members
  where id = 'bbbbbbbb-0000-4000-8000-000000000004'), 'munshi',
  'munshi cannot promote themselves');

-- ---- Accountant ------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);

select throws_ok(
  $$update public.parties set deleted_at = now()
    where id = 'cccccccc-0000-4000-8000-000000000001'$$,
  '42501', null, 'accountant cannot delete a party');
select ok(private.has_permission('11111111-1111-4111-8111-111111111111', 'entries.reverse'),
  'accountant can reverse entries');
select ok(private.has_permission('11111111-1111-4111-8111-111111111111', 'finance.view'),
  'accountant can see finance');
select ok(not private.has_permission('11111111-1111-4111-8111-111111111111', 'loans.manage'),
  'accountant cannot issue karza or change interest');

-- ---- Owner -----------------------------------------------------------------
reset role;
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select lives_ok(
  $$update public.parties set deleted_at = now()
    where id = 'cccccccc-0000-4000-8000-000000000001'$$,
  'owner can delete a party');
select lives_ok(
  $$insert into public.settings (id, tenant_id, scope, key, value) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'tenant',
     'interest.rate_pa', '18')$$,
  'owner can change business-wide settings');
select is((select count(*)::int from public.audit_log), 1,
  'owner can read the audit log');
select throws_ok(
  $$update public.tenants set status = 'active'
    where id = '11111111-1111-4111-8111-111111111111'$$,
  '42501', null, 'owner cannot change plan status (billing only)');
select lives_ok(
  $$update public.tenants set mandi_name = 'Mansa'
    where id = '11111111-1111-4111-8111-111111111111'$$,
  'owner can edit business details');
select throws_ok(
  $$update public.tenant_members set role = 'accountant'
    where id = 'bbbbbbbb-0000-4000-8000-000000000001'$$,
  'P0001', null, 'the last owner cannot demote themselves');
select lives_ok(
  $$update public.tenant_members set custom_permissions = '{"master.delete": true}'
    where id = 'bbbbbbbb-0000-4000-8000-000000000004'$$,
  'owner can grant a custom permission');

-- ---- Munshi with a custom permission ---------------------------------------
reset role;
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select lives_ok(
  $$update public.parties set deleted_at = now()
    where id = 'cccccccc-0000-4000-8000-000000000003'$$,
  'custom master.delete lets the munshi delete a party');
select ok(not private.has_permission('22222222-2222-4222-8222-222222222222', 'parties.manage'),
  'no permissions in a business they do not belong to');

-- ---- Deactivated member ----------------------------------------------------
reset role;
update public.tenant_members set is_active = false
  where id = 'bbbbbbbb-0000-4000-8000-000000000004';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select is((select count(*)::int from public.parties), 0,
  'a deactivated member sees nothing');
select ok(not private.has_permission('11111111-1111-4111-8111-111111111111', 'parties.manage'),
  'a deactivated member has no permissions');

select * from finish();
rollback;
