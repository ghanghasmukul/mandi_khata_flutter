-- Phase 5 (5.4): the audited admin functions behind the admin console.
begin;
create extension if not exists pgtap with schema extensions;
select plan(21);

insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-0000000000ad', 'authenticated', 'authenticated', 'admin@test.local');
insert into public.tenants (id, name) values ('11111111-1111-4111-8111-111111111111', 'One');
insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner');

-- ---- update_subscription ---------------------------------------------------
select is((select plan_code from public.admin_update_subscription(
  'aaaaaaaa-0000-4000-8000-0000000000ad', 'admin@test.local',
  '11111111-1111-4111-8111-111111111111',
  '{"plan_code":"mandi_pro","status":"active","current_period_end":"2027-06-01T00:00:00Z","discount_pct":10,"discount_note":"friend"}',
  'upgrade')), 'mandi_pro', 'the plan changes');
select is((select status || '/' || discount_pct::text from public.tenant_subscriptions
  where tenant_id = '11111111-1111-4111-8111-111111111111'), 'active/10.00',
  'status and discount are saved');
select is((select plan_code from public.tenants where id = '11111111-1111-4111-8111-111111111111'),
  'mandi_pro', 'and mirrored to the business');
select is((select count(*)::int from public.admin_audit_log
  where action = 'update_subscription' and note = 'upgrade'), 1, 'the change is audited');
select is((select before ->> 'plan_code' from public.admin_audit_log
  where action = 'update_subscription'), 'trial', 'with before');
select is((select after ->> 'plan_code' from public.admin_audit_log
  where action = 'update_subscription'), 'mandi_pro', 'and after');

select throws_ok($$select public.admin_update_subscription(
  'aaaaaaaa-0000-4000-8000-0000000000ad', 'a', '11111111-1111-4111-8111-111111111111',
  '{"tenant_id":"22222222-2222-4222-8222-222222222222"}')$$,
  '22023', null, 'only whitelisted fields can change');
select throws_ok($$select public.admin_update_subscription(
  'aaaaaaaa-0000-4000-8000-0000000000ad', 'a', '99999999-9999-4999-8999-999999999999',
  '{"status":"active"}')$$, 'P0002', null, 'a business without a subscription is an error');

select lives_ok($$select public.admin_update_subscription(
  'aaaaaaaa-0000-4000-8000-0000000000ad', 'a', '11111111-1111-4111-8111-111111111111',
  '{"status":"cancelled"}')$$, 'cancelling');
select ok((select cancelled_at is not null from public.tenant_subscriptions
  where tenant_id = '11111111-1111-4111-8111-111111111111'), 'stamps the cancel date');
select lives_ok($$select public.admin_update_subscription(
  'aaaaaaaa-0000-4000-8000-0000000000ad', 'a', '11111111-1111-4111-8111-111111111111',
  '{"status":"active","overrides":{"modules":{"shop":true}}}')$$, 'reactivating');
select ok((select cancelled_at is null from public.tenant_subscriptions
  where tenant_id = '11111111-1111-4111-8111-111111111111'), 'clears the cancel date');
select is(public.admin_tenant_entitlements('11111111-1111-4111-8111-111111111111')
  -> 'modules' ->> 'shop', 'true', 'an override reaches the entitlements');

-- ---- set_tenant_setting ----------------------------------------------------
select lives_ok($$select public.admin_set_tenant_setting(
  'aaaaaaaa-0000-4000-8000-0000000000ad', 'a', '11111111-1111-4111-8111-111111111111',
  'interest.method', '"compound"', 'asked on phone')$$, 'support sets a default');
select is((select id from public.settings where key = 'interest.method'
  and tenant_id = '11111111-1111-4111-8111-111111111111'),
  extensions.uuid_generate_v5('6f1c0a52-3b0e-4f7e-9d58-2f3c1c6a9e41',
    '11111111-1111-4111-8111-111111111111|tenant||interest.method'),
  'with the row id the app would use');
select is((select count(*)::int from public.audit_log
  where tenant_id = '11111111-1111-4111-8111-111111111111' and role = 'support'), 1,
  'the customer''s own audit log shows the change');
select throws_ok($$select public.admin_set_tenant_setting(
  'aaaaaaaa-0000-4000-8000-0000000000ad', 'a', '11111111-1111-4111-8111-111111111111',
  'Bad Key', '1')$$, '22023', null, 'a bad key is refused');

-- ---- support sessions --------------------------------------------------------
select throws_ok($$select public.admin_start_support_session(
  'aaaaaaaa-0000-4000-8000-0000000000ad', 'a', '11111111-1111-4111-8111-111111111111', '  ')$$,
  '22023', null, 'a reason is required');
create temp table s as select public.admin_start_support_session(
  'aaaaaaaa-0000-4000-8000-0000000000ad', 'a', '11111111-1111-4111-8111-111111111111', 'Fix a report') as id;
select is((select jsonb_typeof(public.admin_support_snapshot('11111111-1111-4111-8111-111111111111')
  -> 'counts')), 'object', 'the snapshot has counts');

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select is((select count(*)::int from public.support_sessions), 1,
  'the owner can see the support session');
select throws_ok($$select public.admin_support_snapshot('11111111-1111-4111-8111-111111111111')$$,
  '42501', null, 'a customer cannot call the admin functions');

select * from finish();
rollback;
