-- Super-admin user management functions.
begin;
create extension if not exists pgtap with schema extensions;
select plan(13);

insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'munshi1@test.local'),
  ('aaaaaaaa-0000-4000-8000-0000000000ad', 'authenticated', 'authenticated', 'admin@test.local');
insert into public.tenants (id, name) values ('11111111-1111-4111-8111-111111111111', 'One');
insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner');

-- add a user to a business
select is((select role from public.admin_set_member_access(
  'aaaaaaaa-0000-4000-8000-0000000000ad', 'admin@test.local',
  '11111111-1111-4111-8111-111111111111', 'aaaaaaaa-0000-4000-8000-000000000004',
  'munshi', '{"payments.create": false, "finance.view": true}', null, null, 'new staff')),
  'munshi', 'adds a member');
select is((select custom_permissions ->> 'finance.view' from public.tenant_members
  where user_id = 'aaaaaaaa-0000-4000-8000-000000000004'), 'true', 'with feature overrides');

-- the overrides are what has_permission reads
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);
select ok((select private.has_permission('11111111-1111-4111-8111-111111111111', 'finance.view')),
  'a granted feature is allowed');
select ok(not (select private.has_permission('11111111-1111-4111-8111-111111111111', 'payments.create')),
  'a withheld role default is denied');
select ok((select private.has_permission('11111111-1111-4111-8111-111111111111', 'parties.manage')),
  'untouched role defaults stay');
reset role;

-- change it
select is((select (custom_permissions ->> 'payments.create')::boolean
  from public.admin_set_member_access('aaaaaaaa-0000-4000-8000-0000000000ad', 'a',
  '11111111-1111-4111-8111-111111111111', 'aaaaaaaa-0000-4000-8000-000000000004',
  null, '{"payments.create": true}', null, null, null)), true, 'updates the overrides');
select is((select role from public.tenant_members where user_id = 'aaaaaaaa-0000-4000-8000-000000000004'),
  'munshi', 'and keeps the role when none is given');

-- validation
select throws_ok($$select public.admin_set_member_access('aaaaaaaa-0000-4000-8000-0000000000ad', 'a',
  '11111111-1111-4111-8111-111111111111', 'aaaaaaaa-0000-4000-8000-000000000004',
  null, '{"made.up": true}')$$, '22023', null, 'unknown permission keys are refused');
select throws_ok($$select public.admin_set_member_access('aaaaaaaa-0000-4000-8000-0000000000ad', 'a',
  '11111111-1111-4111-8111-111111111111', 'aaaaaaaa-0000-4000-8000-000000000004',
  'king')$$, '22023', null, 'unknown roles are refused');
select throws_ok($$select public.admin_set_member_access('aaaaaaaa-0000-4000-8000-0000000000ad', 'a',
  '11111111-1111-4111-8111-111111111111', 'aaaaaaaa-0000-4000-8000-000000000001',
  null, null, false)$$, 'P0001', null, 'the last owner cannot be switched off');

-- audit
select is((select count(*)::int from public.admin_audit_log
  where action in ('add_member', 'update_member_access')), 2, 'every change is audited');

-- listing
select is((select jsonb_array_length(memberships) from public.admin_users()
  where email = 'munshi1@test.local'), 1, 'admin_users lists memberships');
select is((select is_platform_admin from public.admin_users() where email = 'owner1@test.local'),
  false, 'and whether a user is a platform admin');

select * from finish();
rollback;
