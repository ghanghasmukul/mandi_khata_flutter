-- Append-only audit log, no client deletes, server-set columns, device codes
-- and number series.
begin;
create extension if not exists pgtap with schema extensions;
select plan(21);

insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'munshi1@test.local');

insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Business One'),
  ('22222222-2222-4222-8222-222222222222', 'Business Two');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'munshi');

insert into public.devices (id, tenant_id, user_id, device_code, platform) values
  ('dddddddd-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'A1', 'android');

insert into public.parties (id, tenant_id, code, name) values
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Party One');

insert into public.audit_log (id, tenant_id, table_name, row_id, action, user_id) values
  ('ffffffff-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'parties',
   'cccccccc-0000-4000-8000-000000000001', 'insert', 'aaaaaaaa-0000-4000-8000-000000000001');

-- ---- Append-only audit log, even for the database owner ---------------------
select throws_ok(
  $$update public.audit_log set action = 'update'
    where id = 'ffffffff-0000-4000-8000-000000000001'$$,
  '42501', null, 'audit log rows cannot be edited');
select throws_ok(
  $$delete from public.audit_log where id = 'ffffffff-0000-4000-8000-000000000001'$$,
  '42501', null, 'audit log rows cannot be deleted');

-- ---- Owner -----------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select throws_ok(
  $$delete from public.parties where id = 'cccccccc-0000-4000-8000-000000000001'$$,
  '42501', null, 'clients cannot hard-delete parties');

insert into public.parties (id, tenant_id, code, name, created_by) values
  ('cccccccc-0000-4000-8000-000000000005', '11111111-1111-4111-8111-111111111111',
   'F-5', 'Spoofed', 'aaaaaaaa-0000-4000-8000-000000000004');
select is((select created_by from public.parties
  where id = 'cccccccc-0000-4000-8000-000000000005'),
  'aaaaaaaa-0000-4000-8000-000000000001'::uuid,
  'created_by is always the signed-in user');

insert into public.settings (id, tenant_id, scope, key, value) values
  ('eeeeeeee-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'tenant', 'mandi.commission_pct', '2.5');
select throws_ok(
  $$insert into public.settings (id, tenant_id, scope, key, value) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'tenant',
     'mandi.commission_pct', '3')$$,
  '23505', null, 'one value per tenant-scope key');
select throws_ok(
  $$insert into public.settings (id, tenant_id, scope, scope_id, key, value) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'tenant',
     'cccccccc-0000-4000-8000-000000000001', 'mandi.tulai_per_qtl', '300')$$,
  '23514', null, 'tenant scope has no scope_id');

select is((public.register_device('eeeeeeee-0000-4000-8000-00000000000a',
  '11111111-1111-4111-8111-111111111111', 'windows', 'Counter PC')).device_code, 'W1',
  'first Windows device gets W1');
select is((public.register_device('eeeeeeee-0000-4000-8000-00000000000a',
  '11111111-1111-4111-8111-111111111111', 'windows')).device_code, 'W1',
  'registering the same device again returns the same code');
select is((public.register_device('eeeeeeee-0000-4000-8000-00000000000b',
  '11111111-1111-4111-8111-111111111111', 'windows')).device_code, 'W2',
  'second Windows device gets W2');
select is((public.register_device('eeeeeeee-0000-4000-8000-00000000000c',
  '11111111-1111-4111-8111-111111111111', 'android')).device_code, 'A2',
  'Android codes continue after the existing A1');
select throws_ok(
  $$select public.register_device('eeeeeeee-0000-4000-8000-00000000000d',
    '11111111-1111-4111-8111-111111111111', 'ios')$$,
  '22023', null, 'unknown platforms are rejected');

select lives_ok(
  $$insert into public.number_series (id, tenant_id, series, device_code, next_value) values
    ('99999999-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
     'R', 'W1', 3008)$$,
  'a user can create a series for their own device');
select throws_ok(
  $$insert into public.number_series (id, tenant_id, series, device_code) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'R', 'A1')$$,
  '42501', null, 'a user cannot create a series for someone else''s device');
select throws_ok(
  $$update public.number_series set next_value = 3000
    where id = '99999999-0000-4000-8000-000000000001'$$,
  '42501', null, 'a number series cannot go backwards');
select lives_ok(
  $$update public.number_series set next_value = 3009
    where id = '99999999-0000-4000-8000-000000000001'$$,
  'a number series can move forward');

-- ---- Munshi ----------------------------------------------------------------
reset role;
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select throws_ok(
  $$select public.register_device('eeeeeeee-0000-4000-8000-00000000000a',
    '11111111-1111-4111-8111-111111111111', 'windows')$$,
  '42501', null, 'cannot take over another user''s device');
select throws_ok(
  $$select public.register_device(gen_random_uuid(),
    '22222222-2222-4222-8222-222222222222', 'android')$$,
  '42501', null, 'cannot register a device in a business they do not belong to');

insert into public.audit_log (id, tenant_id, table_name, row_id, action, user_id, role) values
  ('ffffffff-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111', 'parties',
   'cccccccc-0000-4000-8000-000000000001', 'update',
   'aaaaaaaa-0000-4000-8000-000000000004', 'owner');
select throws_ok(
  $$insert into public.audit_log (id, tenant_id, table_name, row_id, action, user_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'parties',
     'cccccccc-0000-4000-8000-000000000001', 'update',
     'aaaaaaaa-0000-4000-8000-000000000001')$$,
  '42501', null, 'cannot write audit rows as another user');

select lives_ok(
  $$update public.devices set name = 'Gate phone'
    where id = 'dddddddd-0000-4000-8000-000000000004'$$,
  'can rename their own device');
select throws_ok(
  $$update public.devices set device_code = 'A9'
    where id = 'dddddddd-0000-4000-8000-000000000004'$$,
  '42501', null, 'cannot change a device code');

reset role;
select is((select role from public.audit_log
  where id = 'ffffffff-0000-4000-8000-000000000004'), 'munshi',
  'audit role is the member''s real role, not what the client sent');

select * from finish();
rollback;
