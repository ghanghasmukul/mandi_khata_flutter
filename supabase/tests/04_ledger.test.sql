-- ledger_entries: tenant isolation, append-only, reversal rules, who may
-- post what; apply_crud_transaction: one local transaction all-or-nothing.
begin;
create extension if not exists pgtap with schema extensions;
select plan(36);

-- Fixtures (as postgres). Business 1: owner 1 + munshi 1. Business 2: owner 2.
insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'owner2@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'munshi1@test.local');

insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Business One'),
  ('22222222-2222-4222-8222-222222222222', 'Business Two');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'munshi');

insert into public.devices (id, tenant_id, user_id, device_code, platform) values
  ('dddddddd-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'A1', 'android');

insert into public.parties (id, tenant_id, code, name) values
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Party One'),
  ('cccccccc-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'F-1', 'Party Two');

-- A loan of 100 paise for the "a munshi cannot disburse a loan" check below
-- (a disbursal entry must match a real loan, so the permission is what fails).
insert into public.loans (id, tenant_id, loan_no, party_id, issue_date,
  principal_paise, interest_config_snapshot) values
  ('10000000-0000-4000-8000-000000000099', '11111111-1111-4111-8111-111111111111',
   'KZ-T-0001', 'cccccccc-0000-4000-8000-000000000001', '2026-04-08', 100,
   '{"rate_pa":"18"}'::jsonb);

insert into public.ledger_entries
  (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type) values
  ('eeeeeeee-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'cccccccc-0000-4000-8000-000000000001', '2026-04-05', 'jama', 1555800, 'arrival'),
  ('eeeeeeee-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'cccccccc-0000-4000-8000-000000000002', '2026-04-05', 'udhaar', 500000, 'payment');

-- Returns the HINT of the error apply_crud_transaction raises ("op N").
create function pg_temp.failing_op(p_ops jsonb) returns text
language plpgsql as $$
declare
  v_hint text;
begin
  perform public.apply_crud_transaction(p_ops);
  return null;
exception when others then
  get stacked diagnostics v_hint = pg_exception_hint;
  return v_hint;
end;
$$;

-- ---------------------------------------------------------------------------
-- As owner 1
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select is((select count(*)::int from public.ledger_entries), 1,
  'sees only their own business''s ledger');

select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id) values
    (gen_random_uuid(), '22222222-2222-4222-8222-222222222222',
     'cccccccc-0000-4000-8000-000000000002', '2026-04-06', 'jama', 100, 'arrival',
     'dddddddd-0000-4000-8000-000000000001')$$,
  '42501', null, 'cannot post to another business');

select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000002', '2026-04-06', 'jama', 100, 'arrival',
     'dddddddd-0000-4000-8000-000000000001')$$,
  '23503', null, 'cannot post to another business''s party');

select lives_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id,
     created_by, received_at) values
    ('eeeeeeee-0000-4000-8000-000000000011', '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-06', 'udhaar', 200000, 'payment',
     'dddddddd-0000-4000-8000-000000000001',
     'aaaaaaaa-0000-4000-8000-000000000002', '2000-01-01')$$,
  'posts an entry from their own device');

select is(
  (select created_by from public.ledger_entries
   where id = 'eeeeeeee-0000-4000-8000-000000000011'),
  'aaaaaaaa-0000-4000-8000-000000000001'::uuid,
  'created_by is the uploader, not what the client sent');
select ok(
  (select received_at > '2001-01-01' from public.ledger_entries
   where id = 'eeeeeeee-0000-4000-8000-000000000011'),
  'received_at is the server''s time, not the client''s');

select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-06', 'jama', 100, 'arrival',
     'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'cannot post as someone else''s device');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-06', 'jama', 100, 'arrival')$$,
  '42501', null, 'a device is required');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-06', 'jama', 0, 'arrival',
     'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'amount must be positive');

-- Append-only.
select throws_ok(
  $$update public.ledger_entries set amount_paise = 1
    where id = 'eeeeeeee-0000-4000-8000-000000000001'$$,
  '42501', null, 'cannot change an entry');
select throws_ok(
  $$delete from public.ledger_entries
    where id = 'eeeeeeee-0000-4000-8000-000000000001'$$,
  '42501', null, 'cannot delete an entry');

-- Reversals.
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, reverses_id,
     device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-05', 'jama', 1555800, 'reversal',
     'eeeeeeee-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a reversal must be on the opposite side');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, reverses_id,
     device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-05', 'udhaar', 1555700, 'reversal',
     'eeeeeeee-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a reversal must be for the same amount');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type,
     device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-05', 'udhaar', 100, 'reversal',
     'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a reversal must say what it reverses');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, reverses_id,
     device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-05', 'jama', 500000, 'reversal',
     'eeeeeeee-0000-4000-8000-000000000002', 'dddddddd-0000-4000-8000-000000000001')$$,
  '23503', null, 'cannot reverse another business''s entry');
select lives_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, reverses_id,
     device_id) values
    ('eeeeeeee-0000-4000-8000-000000000012', '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-05', 'udhaar', 1555800, 'reversal',
     'eeeeeeee-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000001')$$,
  'reverses an entry');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, reverses_id,
     device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-05', 'udhaar', 1555800, 'reversal',
     'eeeeeeee-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000001')$$,
  '23505', null, 'an entry is reversed at most once');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, reverses_id,
     device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-05', 'jama', 1555800, 'reversal',
     'eeeeeeee-0000-4000-8000-000000000012', 'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'a reversal cannot be reversed');

-- ---------------------------------------------------------------------------
-- apply_crud_transaction (still owner 1)
-- ---------------------------------------------------------------------------
select lives_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PUT","table":"parties","id":"cccccccc-0000-4000-8000-000000000021",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111","code":"F-21","name":"Batch Party"}},
    {"op":"PUT","table":"ledger_entries","id":"eeeeeeee-0000-4000-8000-000000000021",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111",
             "party_id":"cccccccc-0000-4000-8000-000000000021","entry_date":"2026-04-07",
             "side":"udhaar","amount_paise":125000,"ref_type":"opening_balance",
             "device_id":"dddddddd-0000-4000-8000-000000000001"}},
    {"op":"PUT","table":"audit_log","id":"ffffffff-0000-4000-8000-000000000021",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111","table_name":"parties",
             "row_id":"cccccccc-0000-4000-8000-000000000021","action":"insert",
             "user_id":"aaaaaaaa-0000-4000-8000-000000000001",
             "after":{"name":"Batch Party"}}}
  ]'::jsonb)$$,
  'applies a party, its ledger entry and its audit row together');
select is(
  (select amount_paise from public.ledger_entries
   where id = 'eeeeeeee-0000-4000-8000-000000000021'),
  125000::bigint, 'the batch wrote typed values');

select lives_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PUT","table":"ledger_entries","id":"eeeeeeee-0000-4000-8000-000000000021",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111",
             "party_id":"cccccccc-0000-4000-8000-000000000021","entry_date":"2026-04-07",
             "side":"udhaar","amount_paise":125000,"ref_type":"opening_balance",
             "device_id":"dddddddd-0000-4000-8000-000000000001"}},
    {"op":"PUT","table":"audit_log","id":"ffffffff-0000-4000-8000-000000000021",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111","table_name":"parties",
             "row_id":"cccccccc-0000-4000-8000-000000000021","action":"insert",
             "user_id":"aaaaaaaa-0000-4000-8000-000000000001"}}
  ]'::jsonb)$$,
  'sending the same append-only rows again (lost response) is a no-op');

select lives_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PUT","table":"parties","id":"cccccccc-0000-4000-8000-000000000021",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111","code":"F-21","name":"Renamed"}},
    {"op":"PATCH","table":"parties","id":"cccccccc-0000-4000-8000-000000000021",
     "data":{"village":"Mansa"}}
  ]'::jsonb)$$,
  'PUT on an existing row updates it; PATCH updates the given columns');
select is(
  (select name || '/' || village from public.parties
   where id = 'cccccccc-0000-4000-8000-000000000021'),
  'Renamed/Mansa', 'both changes landed');

-- One bad change rolls back the whole local transaction.
select is(
  pg_temp.failing_op('[
    {"op":"PUT","table":"parties","id":"cccccccc-0000-4000-8000-000000000022",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111","code":"F-22","name":"Lost"}},
    {"op":"PUT","table":"parties","id":"cccccccc-0000-4000-8000-000000000023",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111","code":"F-21","name":"Dup code"}},
    {"op":"PUT","table":"audit_log","id":"ffffffff-0000-4000-8000-000000000022",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111","table_name":"parties",
             "row_id":"cccccccc-0000-4000-8000-000000000023","action":"insert",
             "user_id":"aaaaaaaa-0000-4000-8000-000000000001"}}
  ]'::jsonb),
  'op 2', 'the error says which change failed');
select is(
  (select count(*)::int from public.parties
   where id in ('cccccccc-0000-4000-8000-000000000022', 'cccccccc-0000-4000-8000-000000000023'))
  + (select count(*)::int from public.audit_log
     where id = 'ffffffff-0000-4000-8000-000000000022'),
  0, 'nothing from a failed transaction is kept');

select throws_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PATCH","table":"parties","id":"cccccccc-0000-4000-8000-000000000002",
     "data":{"name":"Hijacked"}}]'::jsonb)$$,
  '42501', null, 'PATCH of a row hidden by RLS is an error, not a silent success');
select throws_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PATCH","table":"ledger_entries","id":"eeeeeeee-0000-4000-8000-000000000011",
     "data":{"amount_paise":1}}]'::jsonb)$$,
  '42501', null, 'the batch cannot change a ledger entry either');
select throws_ok(
  $$select public.apply_crud_transaction('[
    {"op":"DELETE","table":"parties","id":"cccccccc-0000-4000-8000-000000000021"}]'::jsonb)$$,
  '42501', null, 'DELETE is refused like a direct delete');
select throws_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PUT","table":"pg_authid","id":"cccccccc-0000-4000-8000-000000000031",
     "data":{}}]'::jsonb)$$,
  '42501', null, 'only synced tables can be written');
select throws_ok(
  $$select public.apply_crud_transaction('[
    {"op":"PATCH","table":"parties","id":"cccccccc-0000-4000-8000-000000000021",
     "data":{"name; drop table x":"y"}}]'::jsonb)$$,
  '42703', null, 'only real columns can be written');

-- ---------------------------------------------------------------------------
-- As munshi 1: may post day-to-day entries, not reversals or journals.
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

select lives_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id,
     created_at) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-08', 'udhaar', 100000, 'payment',
     'dddddddd-0000-4000-8000-000000000004', '2026-04-08T06:00:00Z')$$,
  'a munshi records a payment');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, reverses_id,
     device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-06', 'jama', 200000, 'reversal',
     'eeeeeeee-0000-4000-8000-000000000011', 'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'a munshi cannot reverse (entries.reverse)');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-08', 'jama', 100, 'journal',
     'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'a munshi cannot post a journal entry');
select throws_ok(
  $$insert into public.ledger_entries
    (id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, ref_id, device_id) values
    (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
     'cccccccc-0000-4000-8000-000000000001', '2026-04-08', 'udhaar', 100, 'loan_disbursal',
     '10000000-0000-4000-8000-000000000099', 'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'a munshi cannot disburse a loan');

select is(
  pg_temp.failing_op('[
    {"op":"PUT","table":"parties","id":"cccccccc-0000-4000-8000-000000000024",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111","code":"F-24","name":"Munshi party"}},
    {"op":"PUT","table":"ledger_entries","id":"eeeeeeee-0000-4000-8000-000000000024",
     "data":{"tenant_id":"11111111-1111-4111-8111-111111111111",
             "party_id":"cccccccc-0000-4000-8000-000000000024","entry_date":"2026-04-08",
             "side":"jama","amount_paise":100,"ref_type":"opening_balance",
             "device_id":"dddddddd-0000-4000-8000-000000000004"}}
  ]'::jsonb),
  'op 2', 'a forbidden entry rejects the whole save');
select is(
  (select count(*)::int from public.parties
   where id = 'cccccccc-0000-4000-8000-000000000024'),
  0, '…including the party saved with it');

select * from finish();
rollback;
