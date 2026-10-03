-- Step 1.10: a munshi (no audit.view) can upload changes, which carry audit
-- rows, and still cannot read the business audit log.

begin;
select plan(7);

insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-1000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner@audit.local'),
  ('aaaaaaaa-1000-4000-8000-000000000002', 'authenticated', 'authenticated', 'munshi@audit.local'),
  ('aaaaaaaa-1000-4000-8000-000000000003', 'authenticated', 'authenticated', 'accountant@audit.local');

insert into public.tenants (id, name) values
  ('bbbbbbbb-1000-4000-8000-000000000001', 'Audit test business');
insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('cccccccc-1000-4000-8000-000000000001', 'bbbbbbbb-1000-4000-8000-000000000001', 'aaaaaaaa-1000-4000-8000-000000000001', 'owner'),
  ('cccccccc-1000-4000-8000-000000000002', 'bbbbbbbb-1000-4000-8000-000000000001', 'aaaaaaaa-1000-4000-8000-000000000002', 'munshi'),
  ('cccccccc-1000-4000-8000-000000000003', 'bbbbbbbb-1000-4000-8000-000000000001', 'aaaaaaaa-1000-4000-8000-000000000003', 'accountant');

-- As the munshi: upload a party with its audit row, the way the app does.
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-1000-4000-8000-000000000002","role":"authenticated"}', true);

select lives_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PUT","table":"parties","id":"dddddddd-1000-4000-8000-000000000001",
     "data":{"tenant_id":"bbbbbbbb-1000-4000-8000-000000000001","code":"P-A1-0001","name":"Gurmeet"}},
    {"op":"PUT","table":"audit_log","id":"ffffffff-1000-4000-8000-000000000001",
     "data":{"tenant_id":"bbbbbbbb-1000-4000-8000-000000000001","table_name":"parties",
             "row_id":"dddddddd-1000-4000-8000-000000000001","action":"insert",
             "user_id":"aaaaaaaa-1000-4000-8000-000000000002"}}
  ]'::jsonb)$$,
  'a munshi uploads a change together with its audit row');

select lives_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PUT","table":"audit_log","id":"ffffffff-1000-4000-8000-000000000001",
     "data":{"tenant_id":"bbbbbbbb-1000-4000-8000-000000000001","table_name":"parties",
             "row_id":"dddddddd-1000-4000-8000-000000000001","action":"insert",
             "user_id":"aaaaaaaa-1000-4000-8000-000000000002"}}
  ]'::jsonb)$$,
  'retrying the same upload is skipped, not an error');

select is((select count(*)::int from public.audit_log), 1,
  'the munshi reads only the audit rows they wrote');
select is((select role from public.audit_log), 'munshi',
  'the server filled the role from the membership');

-- As the accountant: uploads work too, and sees only their own rows.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-1000-4000-8000-000000000003","role":"authenticated"}', true);
select lives_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PUT","table":"audit_log","id":"ffffffff-1000-4000-8000-000000000002",
     "data":{"tenant_id":"bbbbbbbb-1000-4000-8000-000000000001","table_name":"parties",
             "row_id":"dddddddd-1000-4000-8000-000000000001","action":"update",
             "user_id":"aaaaaaaa-1000-4000-8000-000000000003"}}
  ]'::jsonb)$$,
  'an accountant uploads an audit row');
select is((select count(*)::int from public.audit_log), 1,
  'the accountant does not see the munshi''s rows');

-- As the owner: sees everyone's.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-1000-4000-8000-000000000001","role":"authenticated"}', true);
select is((select count(*)::int from public.audit_log), 2,
  'the owner sees the munshi''s and the accountant''s edits');

select * from finish();
rollback;
