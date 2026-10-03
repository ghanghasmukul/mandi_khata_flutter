-- Step 1.8: invites, member safety, device revoke, and the documented
-- permission table (docs/domain/ledger-and-mandi.md).
begin;
create extension if not exists pgtap with schema extensions;
select plan(49);

insert into auth.users (id, aud, role, email, phone) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner@t.local', '919000000001'),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'acct@t.local', '919000000002'),
  ('aaaaaaaa-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'munshi@t.local', '919000000003'),
  ('aaaaaaaa-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'other@t.local', '919000000004'),
  ('aaaaaaaa-0000-4000-8000-000000000005', 'authenticated', 'authenticated', 'newbie@t.local', '919000000005'),
  ('aaaaaaaa-0000-4000-8000-000000000006', 'authenticated', 'authenticated', 'late@t.local', '919000000006');

insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Business One'),
  ('22222222-2222-4222-8222-222222222222', 'Business Two');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'aaaaaaaa-0000-4000-8000-000000000001', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'aaaaaaaa-0000-4000-8000-000000000002', 'accountant'),
  ('bbbbbbbb-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'aaaaaaaa-0000-4000-8000-000000000003', 'munshi'),
  ('bbbbbbbb-0000-4000-8000-000000000004', '22222222-2222-4222-8222-222222222222', 'aaaaaaaa-0000-4000-8000-000000000004', 'owner');

insert into public.devices (id, tenant_id, user_id, device_code, platform) values
  ('dddddddd-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'aaaaaaaa-0000-4000-8000-000000000001', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'aaaaaaaa-0000-4000-8000-000000000003', 'A1', 'android');

-- An invite that already ran out, and one for another business.
insert into public.member_invites (id, tenant_id, phone, role, expires_at) values
  ('11110000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', '919000000006', 'munshi', now() - interval '1 day'),
  ('11110000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', '919000000007', 'munshi', now() + interval '1 day');

-- ---- The documented permission table (role defaults) -----------------------
select is(
  (select array_agg(p order by p) from unnest(array[
    'parties.manage','arrivals.manage','payments.create','entries.reverse',
    'loans.manage','finance.view','admin.manage','master.delete',
    'settings.manage','audit.view']) p
   where private.role_allows('accountant', p)),
  array['arrivals.manage','entries.reverse','finance.view','parties.manage','payments.create'],
  'accountant defaults');
select is(
  (select array_agg(p order by p) from unnest(array[
    'parties.manage','arrivals.manage','payments.create','entries.reverse',
    'loans.manage','finance.view','admin.manage','master.delete',
    'settings.manage','audit.view']) p
   where private.role_allows('munshi', p)),
  array['arrivals.manage','parties.manage','payments.create'],
  'munshi defaults');
select is(
  (select count(*)::int from unnest(array[
    'parties.manage','arrivals.manage','payments.create','entries.reverse',
    'loans.manage','finance.view','admin.manage','master.delete',
    'settings.manage','audit.view']) p
   where private.role_allows('custom', p)),
  0, 'a custom role starts with nothing');
select is(private.ledger_post_permission('reversal', null), 'entries.reverse',
  'posting a reversal needs entries.reverse');

-- ---- Munshi ----------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);

select throws_ok(
  $$select public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '9814022110', 'munshi')$$,
  '42501', null, 'a munshi cannot invite');
select is((select count(*)::int from public.member_invites), 0,
  'a munshi sees no invites');
select throws_ok(
  $$insert into public.member_invites (id, tenant_id, phone, role) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', '919814022110', 'munshi')$$,
  '42501', null, 'clients cannot insert invites directly');
select lives_ok(
  $$update public.tenant_members set role = 'owner'
    where id = 'bbbbbbbb-0000-4000-8000-000000000003'$$,
  'a munshi''s attempt to make themselves owner changes nothing (no policy)');
select throws_ok(
  $$update public.devices set revoked_at = now()
    where id = 'dddddddd-0000-4000-8000-000000000003'$$,
  '42501', null, 'a munshi cannot revoke even their own device');
select throws_ok(
  $$insert into public.tenant_members (id, tenant_id, user_id, role) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'aaaaaaaa-0000-4000-8000-000000000004', 'munshi')$$,
  '42501', null, 'clients cannot add members directly');

-- ---- Other business's owner ------------------------------------------------
reset role;
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select throws_ok(
  $$select public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '9814022110', 'munshi')$$,
  '42501', null, 'another business''s owner cannot invite into this one');
select is((select count(*)::int from public.member_invites), 1,
  'an owner sees only their own business''s invites');
select lives_ok(
  $$update public.devices set revoked_at = now()
    where id = 'dddddddd-0000-4000-8000-000000000003'$$,
  'another business''s owner cannot revoke our device (row not visible)');

-- ---- Owner: invites --------------------------------------------------------
reset role;
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is(
  (select (public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '98140 22110', 'munshi', '{"entries.reverse": true}', 'Gate munshi',
    'dddddddd-0000-4000-8000-000000000001')).phone),
  '919814022110', 'an owner invites a number (normalised to 91 + 10 digits)');
select is(
  (select count(*)::int from public.audit_log
   where table_name = 'member_invites' and action = 'insert'
     and user_id = 'aaaaaaaa-0000-4000-8000-000000000001'
     and device_id = 'dddddddd-0000-4000-8000-000000000001'),
  1, 'the invite is audited with the device');
select throws_ok(
  $$select public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '9814022110', 'accountant')$$,
  'P0001', 'already_invited', 'one open invite per number');
select throws_ok(
  $$select public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '12345', 'munshi')$$,
  '22023', 'invalid_phone', 'a bad number is rejected');
select throws_ok(
  $$select public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '9814022111', 'owner')$$,
  '22023', 'invalid_role', 'owners are not created by invite');
select throws_ok(
  $$select public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '9000000003', 'munshi')$$,
  'P0001', 'already_member', 'an active member cannot be invited again');
select lives_ok(
  $$select public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '9000000006', 'munshi')$$,
  'an expired invite does not block a new one');
select is(
  (select status from public.member_invites
   where id = '11110000-0000-4000-8000-000000000001'),
  'expired', 'the old invite is marked expired');

select lives_ok(
  $$update public.member_invites set status = 'cancelled'
    where phone = '919000000006' and status = 'pending'$$,
  'an owner can cancel a pending invite');
select throws_ok(
  $$update public.member_invites set role = 'accountant'
    where phone = '919814022110'$$,
  '42501', null, 'an invite cannot be edited, only cancelled');

-- ---- Accepting -------------------------------------------------------------
reset role;
insert into public.member_invites (id, tenant_id, phone, role, custom_permissions) values
  ('11110000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   '919000000005', 'custom', '{"parties.manage": true}');

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000005","role":"authenticated"}', true);

select is((select count(*)::int from public.accept_member_invites()), 1,
  'signing in with the invited number joins the business');
select is((select role from public.tenant_members
           where user_id = 'aaaaaaaa-0000-4000-8000-000000000005'),
  'custom', 'with the invited role');
select ok(private.has_permission('11111111-1111-4111-8111-111111111111', 'parties.manage'),
  'and the invited permissions');
select ok(not private.has_permission('11111111-1111-4111-8111-111111111111', 'payments.create'),
  'and nothing else (custom starts empty)');
select is((select count(*)::int from public.accept_member_invites()), 0,
  'accepting twice does nothing');

reset role;
select is((select status from public.member_invites
           where id = '11110000-0000-4000-8000-000000000003'),
  'accepted', 'the invite is marked accepted');
select is(
  (select count(*)::int from public.audit_log
   where table_name = 'tenant_members' and action = 'insert'
     and user_id = 'aaaaaaaa-0000-4000-8000-000000000005'
     and after ->> 'via' = 'invite'),
  1, 'joining by invite is audited');

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000006","role":"authenticated"}', true);
select is((select count(*)::int from public.accept_member_invites()), 0,
  'an expired invite is not accepted');
select is((select count(*)::int from public.tenant_members
           where user_id = 'aaaaaaaa-0000-4000-8000-000000000006'),
  0, 'so no membership is created');

select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);
select is((select count(*)::int from public.accept_member_invites()), 0,
  'an invite for another number is not accepted');

-- ---- Accountant given admin.manage: still cannot touch owners --------------
reset role;
update public.tenant_members set custom_permissions = '{"admin.manage": true}'
  where id = 'bbbbbbbb-0000-4000-8000-000000000002';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);

select ok(private.has_permission('11111111-1111-4111-8111-111111111111', 'admin.manage'),
  'the override gives the accountant admin.manage');
select throws_ok(
  $$update public.tenant_members set role = 'owner'
    where id = 'bbbbbbbb-0000-4000-8000-000000000002'$$,
  '42501', null, 'a delegated admin cannot make themselves owner');
select throws_ok(
  $$update public.tenant_members set is_active = false
    where id = 'bbbbbbbb-0000-4000-8000-000000000001'$$,
  '42501', null, 'a delegated admin cannot deactivate the owner');
select throws_ok(
  $$update public.tenant_members set custom_permissions = '{"audit.view": true}'
    where id = 'bbbbbbbb-0000-4000-8000-000000000002'$$,
  '42501', null, 'a delegated admin cannot widen their own access');
select lives_ok(
  $$update public.tenant_members set role = 'accountant'
    where id = 'bbbbbbbb-0000-4000-8000-000000000003'$$,
  'but can manage other non-owner members');

-- ---- Owner: devices --------------------------------------------------------
reset role;
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is((select role from public.tenant_members
           where id = 'bbbbbbbb-0000-4000-8000-000000000003'),
  'accountant', 'only the delegated admin''s change landed (munshi never became owner)');
select ok((select revoked_at is null from public.devices
           where id = 'dddddddd-0000-4000-8000-000000000003'),
  'the outsider''s revoke attempt changed nothing');

select lives_ok(
  $$update public.devices set revoked_at = now()
    where id = 'dddddddd-0000-4000-8000-000000000003'$$,
  'an owner revokes a device');
select is(
  (select revoked_by from public.devices where id = 'dddddddd-0000-4000-8000-000000000003'),
  'aaaaaaaa-0000-4000-8000-000000000001'::uuid, 'who revoked it is recorded');
select throws_ok(
  $$update public.devices set revoked_at = null
    where id = 'dddddddd-0000-4000-8000-000000000003'$$,
  '42501', null, 'a revoked device stays revoked');
select throws_ok(
  $$update public.devices set device_code = 'W9'
    where id = 'dddddddd-0000-4000-8000-000000000003'$$,
  '42501', null, 'device identity still cannot change');

-- ---- The revoked device ----------------------------------------------------
reset role;
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);

select throws_ok(
  $$select public.register_device('dddddddd-0000-4000-8000-000000000003',
    '11111111-1111-4111-8111-111111111111', 'android')$$,
  '42501', 'device_revoked', 'a revoked device cannot register again');
select throws_ok(
  $$insert into public.audit_log (id, tenant_id, table_name, row_id, action, user_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'parties',
      gen_random_uuid(), 'insert', 'aaaaaaaa-0000-4000-8000-000000000003',
      'dddddddd-0000-4000-8000-000000000003')$$,
  '42501', null, 'writes (their audit rows) from a revoked device are refused');
select lives_ok(
  $$insert into public.audit_log (id, tenant_id, table_name, row_id, action, user_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'parties',
      gen_random_uuid(), 'insert', 'aaaaaaaa-0000-4000-8000-000000000003')$$,
  'audit rows without a device still work (server-side writers)');

-- ---- Device limit ----------------------------------------------------------
reset role;
update public.tenant_members set device_limit = 1
  where id = 'bbbbbbbb-0000-4000-8000-000000000001';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select throws_ok(
  $$select public.register_device(gen_random_uuid(),
    '11111111-1111-4111-8111-111111111111', 'android')$$,
  'P0001', 'device_limit_reached', 'the device limit is enforced');
select lives_ok(
  $$select public.register_device('dddddddd-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111', 'windows')$$,
  'an already registered device keeps working at the limit');

select * from finish();
rollback;
