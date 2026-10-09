-- Phase 5 (5.4 + 5.5): signup, state presets, crop master, admin tables.
begin;
create extension if not exists pgtap with schema extensions;
select plan(41);

insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'new1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'new2@test.local');

-- ---- Crop master -----------------------------------------------------------
select is((select count(*)::int from public.crop_master), 11, 'crop master has the 11 defaults');
insert into public.tenants (id, name) values ('33333333-3333-4333-8333-333333333333', 'Existing');
select is((select count(*)::int from public.crops
  where tenant_id = '33333333-3333-4333-8333-333333333333'), 11,
  'a new business gets the crops of the master');
select is((select id from public.crops
  where tenant_id = '33333333-3333-4333-8333-333333333333' and code = 'wheat'),
  extensions.uuid_generate_v5('3d8f2a6e-4c1b-4f0a-9b7e-5a2c8d1e6f30',
    '33333333-3333-4333-8333-333333333333|wheat'),
  'crop ids are the same UUID v5 the app computes');

insert into public.crop_master (code, name_en, msp_or_std_rate) values ('jowar', 'Jowar', 300000);
select is(public.push_crop_master(), (select count(*)::int from public.tenants), 'pushing the master adds the new crop to each business');
select is(public.push_crop_master(), 0, 'pushing again adds nothing');
update public.crops set msp_or_std_rate = 1 where code = 'wheat';
select is(public.push_crop_master(false), 0, 'rates are left alone by default');
select is((select msp_or_std_rate from public.crops where code = 'wheat'
  and tenant_id = '33333333-3333-4333-8333-333333333333'), 1::bigint,
  'a business''s own rate survives');
select is(public.push_crop_master(true), 0, 'refreshing rates adds no crop');
select is((select msp_or_std_rate from public.crops where code = 'wheat'
  and tenant_id = '33333333-3333-4333-8333-333333333333'), 258500::bigint,
  'but resets the reference rate when asked');
update public.crop_master set is_active = false where code = 'jowar';

-- ---- Signup ---------------------------------------------------------------
update public.state_presets set settings = '{"mandi.commission_pct":"2.5","mandi.mandi_fee_pct":"1"}'
  where state_code = '03';
insert into public.referral_codes (code, owner_name, commission_pct) values ('DEALER-1', 'A dealer', 10);

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is(public.signup_business('44444444-4444-4444-8444-444444444444', ' Sandhu Traders ',
    '03', 'Khanna', 'arhtiya', '9814022110', 'dealer-1'),
  '44444444-4444-4444-8444-444444444444'::uuid, 'signup returns the new business');
select is((select name from public.tenants where id = '44444444-4444-4444-8444-444444444444'),
  'Sandhu Traders', 'the name is trimmed');
select is((select role from public.tenant_members
  where tenant_id = '44444444-4444-4444-8444-444444444444'), 'owner', 'the signer is the owner');
select is((select plan_code || '/' || status from public.tenant_subscriptions
  where tenant_id = '44444444-4444-4444-8444-444444444444'), 'trial/trial',
  'the trial starts on the trial plan');
select ok((select referral_valid and referral_code = 'DEALER-1' from public.tenants
  where id = '44444444-4444-4444-8444-444444444444'),
  'a known referral code is stored upper-case and marked valid');
select is((select count(*)::int from public.crops
  where tenant_id = '44444444-4444-4444-8444-444444444444'), 11, 'with the default crops');
select is((select value #>> '{}' from public.settings
  where tenant_id = '44444444-4444-4444-8444-444444444444' and key = 'mandi.commission_pct'),
  '2.5', 'the state preset is copied into the business settings');
select is((select id from public.settings
  where tenant_id = '44444444-4444-4444-8444-444444444444' and key = 'mandi.mandi_fee_pct'),
  extensions.uuid_generate_v5('6f1c0a52-3b0e-4f7e-9d58-2f3c1c6a9e41',
    '44444444-4444-4444-8444-444444444444|tenant||mandi.mandi_fee_pct'),
  'its row id is the one the app would compute');
select is((select value from public.settings
  where tenant_id = '44444444-4444-4444-8444-444444444444' and key = 'app.modules.shop'),
  'false'::jsonb, 'an arhtiya has the shop module switched off');
select is((select count(*)::int from public.audit_log
  where tenant_id = '44444444-4444-4444-8444-444444444444' and table_name = 'tenants'
    and action = 'insert'), 1, 'signup is audited');

select is(public.signup_business('44444444-4444-4444-8444-444444444444', 'Again',
    '03', null, 'arhtiya'),
  '44444444-4444-4444-8444-444444444444'::uuid, 'a retry returns the same business');
select is((select count(*)::int from public.tenant_members
  where tenant_id = '44444444-4444-4444-8444-444444444444'), 1, 'and adds no second owner');

select throws_ok(
  $$select public.signup_business('55555555-5555-4555-8555-555555555555', 'X', '03', null, 'farmer')$$,
  '22023', null, 'a business type must be known');
select throws_ok(
  $$select public.signup_business('55555555-5555-4555-8555-555555555555', ' ', '03', null, 'shop')$$,
  '22023', null, 'a name is required');
select throws_ok(
  $$select public.signup_business('55555555-5555-4555-8555-555555555555', 'X', '3', null, 'shop')$$,
  '22023', null, 'a state code is two digits');

select lives_ok(
  $$select public.signup_business('55555555-5555-4555-8555-555555555555', 'Shop One',
    '06', null, 'shop', null, 'nobody')$$,
  'a second business of the same person');
select ok((select not referral_valid and referral_code = 'NOBODY' from public.tenants
  where id = '55555555-5555-4555-8555-555555555555'),
  'an unknown referral code is kept but not valid, and never blocks signup');
select is((select count(*)::int from public.settings
  where tenant_id = '55555555-5555-4555-8555-555555555555'
    and key in ('app.modules.arrivals', 'app.modules.karza') and value = 'false'::jsonb), 2,
  'a shop has arrivals and karza switched off');

reset role;
update public.platform_settings set value = '2' where key = 'max_businesses_per_user';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select throws_ok(
  $$select public.signup_business('66666666-6666-4666-8666-666666666666', 'Third', '03', null, 'both')$$,
  'P0001', 'signup_limit', 'the per-person business limit is a platform setting');

reset role;
update public.platform_settings set value = 'false' where key = 'signup_enabled';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select throws_ok(
  $$select public.signup_business('77777777-7777-4777-8777-777777777777', 'Closed', '03', null, 'shop')$$,
  'P0001', 'signup_closed', 'signup can be switched off');

reset role;
update public.platform_settings set value = 'true' where key = 'signup_enabled';
update public.platform_settings set value = '"shop"' where key = 'signup.trial_plan.shop';
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select lives_ok(
  $$select public.signup_business('77777777-7777-4777-8777-777777777777', 'Plan test', '03', null, 'shop')$$,
  'signup picks the trial plan from the platform setting');
select is((select plan_code from public.tenant_subscriptions
  where tenant_id = '77777777-7777-4777-8777-777777777777'), 'shop',
  'the trial plan is configurable per business type');
select throws_ok(
  $$select public.signup_business('44444444-4444-4444-8444-444444444444', 'Steal', '03', null, 'shop')$$,
  '42501', null, 'a business id owned by another person cannot be reused');

-- ---- What clients can and cannot see ---------------------------------------
select throws_ok($$select * from public.referral_codes$$, '42501', null,
  'referral codes are not readable');
select throws_ok($$select * from public.crop_master$$, '42501', null,
  'the crop master is not readable by clients');
select throws_ok($$select * from public.admin_audit_log$$, '42501', null,
  'the admin audit log is not readable by clients');
select throws_ok($$select * from public.platform_admins$$, '42501', null,
  'the admin list is not readable by clients');
select throws_ok($$select * from public.admin_tenant_overview()$$, '42501', null,
  'the admin overview is service role only');
select throws_ok($$update public.tenants set referral_code = 'MINE'
  where id = '77777777-7777-4777-8777-777777777777'$$, '42501', null,
  'an owner cannot edit their referral code');

reset role;
select set_config('request.jwt.claims', '{"role":"service_role"}', true);
insert into public.announcements (title_en, is_active) values ('Hello', true), ('Hidden', false);
insert into public.support_sessions (tenant_id, admin_user_id, admin_label, reason) values
  ('44444444-4444-4444-8444-444444444444', 'aaaaaaaa-0000-4000-8000-000000000002', 'Support', 'Fix');
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select is((select count(*)::int from public.announcements), 1, 'only active announcements are read');
select is((select count(*)::int from public.support_sessions), 0,
  'support sessions of another business are invisible');
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select is((select count(*)::int from public.support_sessions), 1,
  'the customer sees support access to their business');

select * from finish();
rollback;
