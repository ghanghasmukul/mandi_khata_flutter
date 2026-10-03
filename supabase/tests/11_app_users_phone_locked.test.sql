-- Phase 1 review H1: a user cannot change app_users.phone, so they cannot
-- claim someone else's pending invite.

begin;
select plan(5);

insert into auth.users (id, aud, role, email, phone) values
  ('aaaaaaaa-1100-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner@phone.local', '919811100001'),
  ('aaaaaaaa-1100-4000-8000-000000000002', 'authenticated', 'authenticated', 'attacker@phone.local', '919811100002');

insert into public.tenants (id, name) values
  ('bbbbbbbb-1100-4000-8000-000000000001', 'Phone lock business');
insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('cccccccc-1100-4000-8000-000000000001', 'bbbbbbbb-1100-4000-8000-000000000001', 'aaaaaaaa-1100-4000-8000-000000000001', 'owner');
insert into public.member_invites (id, tenant_id, phone, role) values
  ('dddddddd-1100-4000-8000-000000000001', 'bbbbbbbb-1100-4000-8000-000000000001', '919811100099', 'accountant');

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-1100-4000-8000-000000000002","role":"authenticated"}', true);

select throws_ok(
  $$update public.app_users set phone = '919811100099'
    where id = 'aaaaaaaa-1100-4000-8000-000000000002'$$,
  '42501', 'phone_is_read_only', 'a user cannot change their own phone');

select lives_ok(
  $$update public.app_users set full_name = 'Renamed'
    where id = 'aaaaaaaa-1100-4000-8000-000000000002'$$,
  'other profile fields stay editable');

select is_empty(
  $$select * from public.accept_member_invites()$$,
  'accepting finds no invite for the attacker');

reset role;
select is(
  (select phone from public.app_users where id = 'aaaaaaaa-1100-4000-8000-000000000002'),
  '919811100002', 'the stored phone is unchanged');
select is(
  (select count(*)::int from public.tenant_members
    where user_id = 'aaaaaaaa-1100-4000-8000-000000000002'),
  0, 'the attacker joined no business');

select * from finish();
rollback;
