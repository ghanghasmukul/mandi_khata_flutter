-- Phase 5 (5.1 + 5.3): plans, entitlements, lifecycle, write lock, limits.
-- The worked examples mirror packages/khata_core test/entitlements_test.dart
-- and test/lifecycle_test.dart.
begin;
create extension if not exists pgtap with schema extensions;
select plan(58);

insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'owner2@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'munshi1@test.local');

insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Business One'),
  ('22222222-2222-4222-8222-222222222222', 'Business Two');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000003', 'munshi');

-- ---- Seeds and mirror ------------------------------------------------------
select is((select count(*)::int from public.plans), 5, 'five plans are seeded');
select is((select count(*)::int from public.plan_addons), 2, 'two add-ons are seeded');
select is((select plan_code from public.tenant_subscriptions
  where tenant_id = '11111111-1111-4111-8111-111111111111'), 'trial',
  'a new business starts on the trial plan');
select is((select status from public.tenant_subscriptions
  where tenant_id = '11111111-1111-4111-8111-111111111111'), 'trial', 'in trial');
select ok((select trial_ends_at > now() + interval '13 days'
  from public.tenant_subscriptions where tenant_id = '11111111-1111-4111-8111-111111111111'),
  'the trial is 14 days (platform setting)');
select is((select grace_days from public.tenant_subscriptions
  where tenant_id = '11111111-1111-4111-8111-111111111111'), 7, 'grace comes from the platform setting');

update public.platform_settings set value = '30' where key = 'trial_days';
insert into public.tenants (id, name) values ('33333333-3333-4333-8333-333333333333', 'Three');
select ok((select trial_ends_at > now() + interval '29 days'
  from public.tenant_subscriptions where tenant_id = '33333333-3333-4333-8333-333333333333'),
  'changing the platform setting changes the next trial');
update public.platform_settings set value = '14' where key = 'trial_days';

update public.tenant_subscriptions set plan_code = 'mandi_basic', status = 'active',
  current_period_end = now() + interval '30 days'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
select is((select plan_code || '/' || status from public.tenants
  where id = '11111111-1111-4111-8111-111111111111'), 'mandi_basic/active',
  'tenants mirrors plan and status');

-- ---- Entitlements (same examples as khata_core) ----------------------------
select is(private.tenant_entitlements('11111111-1111-4111-8111-111111111111')
  -> 'limits' ->> 'users', '2', 'mandi_basic: 2 users from max_users');
select is(private.tenant_entitlements('11111111-1111-4111-8111-111111111111')
  -> 'limits' ->> 'parties', '2000', 'parties limit from the limits column');
select is(private.tenant_module_on('11111111-1111-4111-8111-111111111111', 'shop'), false,
  'a module the plan lacks is off');
select is(private.tenant_module_on('11111111-1111-4111-8111-111111111111', 'arrivals'), true,
  'a module in the plan is on');

update public.tenant_subscriptions set addons = '[{"code":"extra_user","qty":3},{"code":"extra_device","qty":2}]'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
select is(private.tenant_limit('11111111-1111-4111-8111-111111111111', 'users'), 5::bigint,
  '3 extra users add to the limit');
select is(private.tenant_limit('11111111-1111-4111-8111-111111111111', 'devices'), 4::bigint,
  '2 extra devices add to the limit');

insert into public.plan_addons (code, name, grants_limits, max_quantity)
  values ('capped', 'Capped', '{"devices":1}', 3);
update public.tenant_subscriptions set addons = '[{"code":"capped","qty":10}]'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
select is(private.tenant_limit('11111111-1111-4111-8111-111111111111', 'devices'), 5::bigint,
  'quantity is capped by the add-on maximum');

insert into public.plan_addons (code, name, grants_modules)
  values ('karza_pack', 'Karza', '{"karza":true}');
update public.tenant_subscriptions set addons = '[{"code":"karza_pack","qty":1}]'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
select is(private.tenant_module_on('11111111-1111-4111-8111-111111111111', 'karza'), true,
  'a module add-on switches the module on');

update public.tenant_subscriptions
  set overrides = '{"modules":{"karza":false,"shop":true},"limits":{"users":10,"devices":null}}'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
select is(private.tenant_module_on('11111111-1111-4111-8111-111111111111', 'karza'), false,
  'an override beats the add-on, to off');
select is(private.tenant_module_on('11111111-1111-4111-8111-111111111111', 'shop'), true,
  'an override switches a module on');
select is(private.tenant_limit('11111111-1111-4111-8111-111111111111', 'users'), 10::bigint,
  'an override replaces a limit');
select is(private.tenant_limit('11111111-1111-4111-8111-111111111111', 'devices'), null,
  'an override can make a limit unlimited');
update public.tenant_subscriptions set overrides = '{}', addons = '[]'
  where tenant_id = '11111111-1111-4111-8111-111111111111';

-- ---- Lifecycle by date (same examples as khata_core) -----------------------
update public.tenant_subscriptions set status = 'trial', trial_ends_at = '2027-05-15'
  where tenant_id = '33333333-3333-4333-8333-333333333333';
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-05-01'), 'full',
  'trial running');
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-05-16'), 'read_only',
  'trial ended: read-only');

update public.tenant_subscriptions set status = 'active', trial_ends_at = null,
  current_period_end = '2027-06-01', grace_days = 7, grace_until = null
  where tenant_id = '33333333-3333-4333-8333-333333333333';
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-06-01'), 'full',
  'the period end moment is still active');
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-06-03'), 'full',
  'overdue inside grace: full');
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-06-09'), 'read_only',
  'grace over: read-only');
update public.tenant_subscriptions set status = 'past_due'
  where tenant_id = '33333333-3333-4333-8333-333333333333';
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-06-09'), 'read_only',
  'past_due behaves the same by date');
update public.tenant_subscriptions set grace_until = '2027-06-30'
  where tenant_id = '33333333-3333-4333-8333-333333333333';
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-06-20'), 'full',
  'grace_until extends grace');
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-07-01'), 'read_only',
  'and ends at that moment');
update public.tenant_subscriptions set status = 'active', current_period_end = null, grace_until = null
  where tenant_id = '33333333-3333-4333-8333-333333333333';
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2030-01-01'), 'full',
  'active with no period end never expires');
update public.tenant_subscriptions set status = 'locked'
  where tenant_id = '33333333-3333-4333-8333-333333333333';
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-01-01'), 'read_only',
  'locked by the vendor');
update public.tenant_subscriptions set status = 'cancelled', cancelled_at = '2027-01-01'
  where tenant_id = '33333333-3333-4333-8333-333333333333';
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-03-01'), 'read_only',
  'cancelled: read-only for 90 days');
select is(private.tenant_access('33333333-3333-4333-8333-333333333333', '2027-04-02'), 'export_only',
  'then export-only');

-- ---- A member: reads own subscription, cannot change anything ---------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is((select count(*)::int from public.tenant_subscriptions), 1,
  'an owner sees only their own subscription');
select is((select count(*)::int from public.plans), 5, 'plans are readable');
select is((select count(*)::int from public.platform_settings where not is_public), 0,
  'private platform settings are hidden');
select throws_ok(
  $$update public.tenant_subscriptions set plan_code = 'combo'
    where tenant_id = '11111111-1111-4111-8111-111111111111'$$,
  '42501', null, 'an owner cannot change their plan');
select throws_ok(
  $$insert into public.plans (code, name) values ('mine', 'Mine')$$,
  '42501', null, 'clients cannot create plans');

select lives_ok(
  $$insert into public.plan_requests (id, tenant_id, requested_plan_code, billing_cycle)
    values ('99999999-0000-4000-8000-000000000001',
      '11111111-1111-4111-8111-111111111111', 'combo', 'yearly')$$,
  'an owner asks for a plan change');
select throws_ok(
  $$insert into public.plan_requests (id, tenant_id, requested_plan_code, status)
    values ('99999999-0000-4000-8000-000000000002',
      '11111111-1111-4111-8111-111111111111', 'combo', 'done')$$,
  '42501', null, 'a request cannot start as done');
select throws_ok(
  $$update public.plan_requests set status = 'done'$$,
  '42501', null, 'a client cannot handle a request');

-- ---- Module gate: shop and karza are not in mandi_basic --------------------
select throws_ok(
  $$insert into public.loans (id, tenant_id) values
    ('77777777-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111')$$,
  '42501', 'module_not_in_plan', 'karza tables need the module');
select throws_ok(
  $$insert into public.products (id, tenant_id) values
    ('77777777-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111')$$,
  '42501', 'module_not_in_plan', 'shop tables need the module');

-- ---- Party limit -----------------------------------------------------------
reset role;
update public.tenant_subscriptions set overrides = '{"limits":{"parties":1}}'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select lives_ok(
  $$insert into public.parties (id, tenant_id, code, name) values
    ('88888888-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'P-1', 'One')$$,
  'the first party fits');
select throws_ok(
  $$insert into public.parties (id, tenant_id, code, name) values
    ('88888888-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'P-2', 'Two')$$,
  'P0001', 'limit_reached:parties', 'the second party is over the limit');

-- ---- User limit (members + open invites) -----------------------------------
reset role;
update public.tenant_subscriptions set overrides = '{"limits":{"users":2}}'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select throws_ok(
  $$select public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '9814022110', 'munshi')$$,
  'P0001', 'limit_reached:users', 'owner + munshi fill 2 seats: no invite');

reset role;
update public.tenant_subscriptions set overrides = '{"limits":{"users":3}}'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select lives_ok(
  $$select public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '9814022110', 'munshi')$$,
  'a third seat is free: the invite is made');
select throws_ok(
  $$select public.create_member_invite('11111111-1111-4111-8111-111111111111',
    '9814022111', 'munshi')$$,
  'P0001', 'limit_reached:users', 'an open invite reserves its seat');

-- ---- Device limit ----------------------------------------------------------
reset role;
insert into public.devices (id, tenant_id, user_id, device_code, platform) values
  ('dddddddd-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'W1', 'windows');
update public.tenant_subscriptions set overrides = '{"limits":{"devices":1}}'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select throws_ok(
  $$select public.register_device('dddddddd-0000-4000-8000-000000000002',
    '11111111-1111-4111-8111-111111111111', 'android', 'Phone')$$,
  'P0001', 'device_limit_reached', 'a second device is over the plan limit');
select lives_ok(
  $$select public.register_device('dddddddd-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111', 'windows', 'PC')$$,
  'the known device still registers');

-- ---- Write lock ------------------------------------------------------------
reset role;
update public.tenant_subscriptions set overrides = '{}', status = 'locked'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select throws_ok(
  $$insert into public.parties (id, tenant_id, code, name) values
    ('88888888-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'P-3', 'Three')$$,
  '42501', 'subscription_locked', 'a locked business cannot add');
select throws_ok(
  $$update public.parties set name = 'Renamed'
    where id = '88888888-0000-4000-8000-000000000001'$$,
  '42501', 'subscription_locked', 'nor change');
select is((select count(*)::int from public.parties), 1, 'but can still read');
select lives_ok(
  $$insert into public.plan_requests (id, tenant_id, requested_plan_code)
    values ('99999999-0000-4000-8000-000000000003',
      '11111111-1111-4111-8111-111111111111', 'mandi_pro')$$,
  'a locked owner can still ask for a plan');
select lives_ok(
  $$insert into public.audit_log (id, tenant_id, table_name, row_id, action, user_id)
    values ('55555555-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
      'plan_requests', '99999999-0000-4000-8000-000000000003', 'insert',
      'aaaaaaaa-0000-4000-8000-000000000001')$$,
  'audit rows are not blocked');

-- The service role (no signed-in user) is never locked out.
reset role;
select set_config('request.jwt.claims', '{"role":"service_role"}', true);
select lives_ok(
  $$insert into public.parties (id, tenant_id, code, name) values
    ('88888888-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111', 'P-4', 'Four')$$,
  'the platform can still write for a locked business');

-- Paying brings the business back.
update public.tenant_subscriptions set status = 'active',
  current_period_end = now() + interval '30 days'
  where tenant_id = '11111111-1111-4111-8111-111111111111';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select lives_ok(
  $$update public.parties set name = 'Renamed'
    where id = '88888888-0000-4000-8000-000000000001'$$,
  'after renewal the owner can write again');

-- ---- Another business -------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select is((select count(*)::int from public.plan_requests), 0,
  'another business sees none of these requests');
select is((select plan_code from public.tenant_subscriptions), 'trial',
  'and its own subscription is untouched');

select * from finish();
rollback;
