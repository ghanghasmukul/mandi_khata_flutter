-- Step 6.3: party documents, KYC owner-only, buckets, tenant isolation.
begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

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

insert into public.parties (id, tenant_id, code, name) values
  ('90000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1', 'Gurdev');

create function pg_temp.doc(p_id uuid, p_type text, p_masked text default null,
  p_tenant uuid default '11111111-1111-4111-8111-111111111111')
returns void language plpgsql as $$
begin
  insert into public.party_documents (id, tenant_id, party_id, doc_type, id_masked,
    file_path, content_type, size_bytes)
  values (p_id, p_tenant, '90000000-0000-4000-8000-000000000001', p_type, p_masked,
    p_tenant::text || '/90000000-0000-4000-8000-000000000001/' || p_id::text || '/a.jpg',
    'image/jpeg', 1000);
end;
$$;

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select lives_ok(
  $$select pg_temp.doc('a1000000-0000-4000-8000-000000000001', 'aadhaar', 'XXXX XXXX 1234')$$,
  'the owner adds an Aadhaar with a masked number');
select throws_ok(
  $$select pg_temp.doc(gen_random_uuid(), 'aadhaar', '234567890123')$$,
  '23514', null, 'a full Aadhaar number cannot be stored');
select throws_ok(
  $$select pg_temp.doc(gen_random_uuid(), 'passbook', 'XXXX XXXX 1234')$$,
  '23514', null, 'only identity documents carry a masked number');
select throws_ok(
  $$select pg_temp.doc(gen_random_uuid(), 'pan', null, '22222222-2222-4222-8222-222222222222')$$,
  '42501', null, 'the owner cannot add a document to another business');
select lives_ok(
  $$select pg_temp.doc('a1000000-0000-4000-8000-000000000002', 'passbook')$$,
  'the owner adds a passbook');
select throws_ok(
  $$update public.party_documents set doc_type = 'pan'
    where id = 'a1000000-0000-4000-8000-000000000002'$$,
  '42501', null, 'a document keeps its type');
select lives_ok(
  $$update public.party_documents set title = 'SBI passbook'
    where id = 'a1000000-0000-4000-8000-000000000002'$$,
  'but its title can change');

-- Buckets.
select lives_ok(
  $$insert into storage.objects (bucket_id, name, owner)
    values ('kyc-docs', '11111111-1111-4111-8111-111111111111/p/d/a.jpg',
      'aaaaaaaa-0000-4000-8000-000000000001')$$,
  'the owner stores an identity file');

-- The munshi.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.party_documents
   where doc_type in ('aadhaar', 'pan')), 0,
  'a munshi does not see identity documents');
select throws_ok(
  $$select pg_temp.doc(gen_random_uuid(), 'pan')$$,
  '42501', null, 'and cannot add one');
select lives_ok(
  $$select pg_temp.doc('a1000000-0000-4000-8000-000000000003', 'j_form')$$,
  'but can add a J-form at the gate');
select is(
  (select count(*)::int from storage.objects where bucket_id = 'kyc-docs'), 0,
  'a munshi sees no identity file');
select throws_ok(
  $$insert into storage.objects (bucket_id, name, owner)
    values ('kyc-docs', '11111111-1111-4111-8111-111111111111/p/d/b.jpg',
      'aaaaaaaa-0000-4000-8000-000000000004')$$,
  '42501', null, 'and cannot upload one');
select throws_ok(
  $$update public.party_documents set deleted_at = now()
    where id = 'a1000000-0000-4000-8000-000000000003'$$,
  '42501', null, 'a munshi cannot delete a document (master.delete)');

-- Another business.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.party_documents)
  + (select count(*)::int from storage.objects
     where bucket_id in ('kyc-docs', 'party-docs')), 0,
  'another business sees no documents or files');
select throws_ok(
  $$insert into storage.objects (bucket_id, name, owner)
    values ('party-docs', '11111111-1111-4111-8111-111111111111/p/d/c.jpg',
      'aaaaaaaa-0000-4000-8000-000000000002')$$,
  '42501', null, 'nor write into this business''s folder');

select * from finish();
rollback;
