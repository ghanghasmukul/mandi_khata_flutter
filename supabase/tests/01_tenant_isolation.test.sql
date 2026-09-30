-- A member of business 1 can neither read nor write business 2's rows.
begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

-- Fixtures (as postgres). Owner 1 runs business 1, owner 2 runs business 2.
insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'owner2@test.local');

insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Business One'),
  ('22222222-2222-4222-8222-222222222222', 'Business Two');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'owner');

insert into public.parties (id, tenant_id, code, name) values
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Party One'),
  ('cccccccc-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'F-1', 'Party Two');

insert into public.devices (id, tenant_id, user_id, device_code, platform) values
  ('dddddddd-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'W1', 'windows');

insert into public.settings (id, tenant_id, scope, key, value) values
  ('eeeeeeee-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'tenant', 'mandi.commission_pct', '2.5');

insert into public.audit_log (id, tenant_id, table_name, row_id, action, user_id) values
  ('ffffffff-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'parties',
   'cccccccc-0000-4000-8000-000000000002', 'insert', 'aaaaaaaa-0000-4000-8000-000000000002');

insert into public.number_series (id, tenant_id, series, device_code) values
  ('99999999-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'R', 'W1');

-- Act as owner 1.
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is((select count(*)::int from public.tenants), 1,
  'sees only their own business');
select is((select count(*)::int from public.parties
  where tenant_id = '11111111-1111-4111-8111-111111111111'), 1,
  'reads own parties');
select is((select count(*)::int from public.parties
  where tenant_id = '22222222-2222-4222-8222-222222222222'), 0,
  'cannot read another business''s parties');
select is((select count(*)::int from public.tenant_members
  where tenant_id = '22222222-2222-4222-8222-222222222222'), 0,
  'cannot read another business''s members');
select is((select count(*)::int from public.devices
  where tenant_id = '22222222-2222-4222-8222-222222222222'), 0,
  'cannot read another business''s devices');
select is((select count(*)::int from public.settings
  where tenant_id = '22222222-2222-4222-8222-222222222222'), 0,
  'cannot read another business''s settings');
select is((select count(*)::int from public.audit_log
  where tenant_id = '22222222-2222-4222-8222-222222222222'), 0,
  'cannot read another business''s audit log');
select is((select count(*)::int from public.number_series
  where tenant_id = '22222222-2222-4222-8222-222222222222'), 0,
  'cannot read another business''s number series');
select is((select count(*)::int from public.app_users
  where id = 'aaaaaaaa-0000-4000-8000-000000000002'), 0,
  'cannot see users of another business');

select throws_ok(
  $$insert into public.parties (id, tenant_id, code, name) values
    (gen_random_uuid(), '22222222-2222-4222-8222-222222222222', 'F-9', 'Intruder')$$,
  '42501', null, 'cannot add a party to another business');
select throws_ok(
  $$insert into public.settings (id, tenant_id, scope, scope_id, key, value) values
    (gen_random_uuid(), '22222222-2222-4222-8222-222222222222', 'party',
     'cccccccc-0000-4000-8000-000000000002', 'mandi.commission_pct', '1')$$,
  '42501', null, 'cannot write another business''s settings');
select throws_ok(
  $$insert into public.audit_log (id, tenant_id, table_name, row_id, action, user_id) values
    (gen_random_uuid(), '22222222-2222-4222-8222-222222222222', 'parties',
     'cccccccc-0000-4000-8000-000000000002', 'update',
     'aaaaaaaa-0000-4000-8000-000000000001')$$,
  '42501', null, 'cannot write another business''s audit log');
select throws_ok(
  $$update public.parties set tenant_id = '22222222-2222-4222-8222-222222222222'
    where id = 'cccccccc-0000-4000-8000-000000000001'$$,
  '42501', null, 'cannot move a party into another business');
select lives_ok(
  $$insert into public.parties (id, tenant_id, code, name) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'F-2', 'New Party')$$,
  'can add a party to own business');

-- RLS hides the row, so this update silently touches nothing.
update public.parties set name = 'Hacked'
  where id = 'cccccccc-0000-4000-8000-000000000002';

reset role;
select is((select name from public.parties
  where id = 'cccccccc-0000-4000-8000-000000000002'), 'Party Two',
  'another business''s party is unchanged after an update attempt');
select is((select count(*)::int from public.app_users
  where id in ('aaaaaaaa-0000-4000-8000-000000000001', 'aaaaaaaa-0000-4000-8000-000000000002')), 2,
  'app_users rows are created automatically for new auth users');

select * from finish();
rollback;
