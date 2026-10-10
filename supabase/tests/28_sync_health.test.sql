-- Step 6.6: sync health numbers for the admin console.
begin;
create extension if not exists pgtap with schema extensions;
select plan(6);

insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local');
insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Busy'),
  ('22222222-2222-4222-8222-222222222222', 'Quiet');
insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner');
insert into public.devices (id, tenant_id, user_id, device_code, platform, last_seen_at) values
  ('dddddddd-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'W1', 'windows', now() - interval '2 days');
insert into public.parties (id, tenant_id, code, name) values
  ('90000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'G');

-- Four entries received now, created 10 s, 60 s, 2 h and 5 h earlier; one with a
-- device clock ahead of the server (negative lag, must be ignored).
create function pg_temp.entry(p_id uuid, p_created interval) returns void language plpgsql as $$
begin
  insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side,
    amount_paise, ref_type, device_id, created_at)
  values (p_id, '11111111-1111-4111-8111-111111111111',
    '90000000-0000-4000-8000-000000000001', current_date, 'jama', 100, 'journal',
    'dddddddd-0000-4000-8000-000000000001', now() - p_created);
end; $$;
select pg_temp.entry('e1000000-0000-4000-8000-000000000001', interval '10 seconds');
select pg_temp.entry('e1000000-0000-4000-8000-000000000002', interval '60 seconds');
select pg_temp.entry('e1000000-0000-4000-8000-000000000003', interval '2 hours');
select pg_temp.entry('e1000000-0000-4000-8000-000000000004', interval '5 hours');
select pg_temp.entry('e1000000-0000-4000-8000-000000000005', interval '-1 hour');

select is((select entries from public.admin_sync_health() where name = 'Busy'), 5::bigint,
  'counts the entries received in the window');
select is((select late_entries from public.admin_sync_health() where name = 'Busy'), 2::bigint,
  'two waited more than an hour on the device');
select is((select lag_max_seconds from public.admin_sync_health() where name = 'Busy'), 18000,
  'the longest wait is 5 hours');
select is((select lag_p50_seconds from public.admin_sync_health() where name = 'Busy'), 3630,
  'the median ignores the future-dated entry');
select is((select active_devices from public.admin_sync_health() where name = 'Busy'), 1::bigint,
  'active devices');
select is((select entries from public.admin_sync_health() where name = 'Quiet'), 0::bigint,
  'a business with no entries is listed with zeros');

select * from finish();
rollback;
