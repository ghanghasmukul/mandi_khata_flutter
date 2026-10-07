-- Phase 4 (4.1): products, batches, stock movements. Tenant isolation,
-- permissions, unique keys, append-only, adjustment note, and
-- batch.qty_milli = SUM(stock_movements) (with the rebuild function).
begin;
create extension if not exists pgtap with schema extensions;
select plan(32);

insert into auth.users (id, aud, role, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'owner1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'owner2@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'acct1@test.local'),
  ('aaaaaaaa-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'munshi1@test.local');

insert into public.tenants (id, name) values
  ('11111111-1111-4111-8111-111111111111', 'Business One'),
  ('22222222-2222-4222-8222-222222222222', 'Business Two');

insert into public.tenant_members (id, tenant_id, user_id, role) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'owner'),
  ('bbbbbbbb-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000003', 'accountant'),
  ('bbbbbbbb-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'munshi');

insert into public.devices (id, tenant_id, user_id, device_code, platform) values
  ('dddddddd-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000001', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222',
   'aaaaaaaa-0000-4000-8000-000000000002', 'W1', 'windows'),
  ('dddddddd-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000003', 'W2', 'windows'),
  ('dddddddd-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111',
   'aaaaaaaa-0000-4000-8000-000000000004', 'A1', 'android');

-- A product and batch of business two (made by its owner below).
create function pg_temp.mv(p_reason text, p_qty bigint, p_device uuid,
  p_note text default null, p_batch uuid default '50000000-0000-4000-8000-000000000001',
  p_ref_type text default null, p_ref uuid default null)
returns void language plpgsql as $$
begin
  insert into public.stock_movements (id, tenant_id, product_id, batch_id, entry_date,
    qty_milli, reason, ref_type, ref_id, note, device_id)
  values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
    '40000000-0000-4000-8000-000000000001', p_batch,
    (now() at time zone 'Asia/Kolkata')::date, p_qty, p_reason, p_ref_type, p_ref, p_note,
    p_device);
end;
$$;

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select lives_ok(
  $$insert into public.product_categories (id, tenant_id, name)
    values ('30000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
      'Fertiliser')$$,
  'the owner adds a category');
select lives_ok(
  $$insert into public.products (id, tenant_id, sku, barcode, name, category_id, unit,
      hsn, gst_rate, prices)
    values ('40000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
      'UREA-50', '8901234567890', 'Urea 50 kg', '30000000-0000-4000-8000-000000000001',
      'bag', '3102', 5, '{"farmer": 26600, "retail": 28000}')$$,
  'the owner adds a product with tier prices');
select throws_ok(
  $$insert into public.products (id, tenant_id, sku, name, unit)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'UREA-50', 'Dup', 'bag')$$,
  '23505', null, 'a sku is unique per business');
select throws_ok(
  $$insert into public.products (id, tenant_id, sku, barcode, name, unit)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'X1', '8901234567890',
      'Dup', 'bag')$$,
  '23505', null, 'and so is a barcode');
select throws_ok(
  $$insert into public.products (id, tenant_id, sku, name, unit)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'X2', 'Odd', 'tonne')$$,
  '23514', null, 'the unit is one of the fixed set');

select lives_ok(
  $$insert into public.batches (id, tenant_id, product_id, batch_no, expiry_date, cost_paise,
      qty_milli)
    values ('50000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
      '40000000-0000-4000-8000-000000000001', 'B-001', '2028-03-31', 24000, 999)$$,
  'the owner adds a batch');
select is(
  (select qty_milli from public.batches where id = '50000000-0000-4000-8000-000000000001'),
  0::bigint, 'a client cannot start a batch with a quantity');
select throws_ok(
  $$insert into public.batches (id, tenant_id, product_id, batch_no, cost_paise)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '40000000-0000-4000-8000-000000000001', 'B-001', 1)$$,
  '23505', null, 'a batch number is unique per product');

-- Stock = sum of movements; the batch quantity follows.
select lives_ok(
  $$select pg_temp.mv('opening', 10000, 'dddddddd-0000-4000-8000-000000000001')$$,
  'opening stock');
select lives_ok(
  $$select pg_temp.mv('purchase', 5000, 'dddddddd-0000-4000-8000-000000000001',
    p_ref_type => 'purchase', p_ref => gen_random_uuid())$$,
  'a purchase brings stock in');
select throws_ok(
  $$select pg_temp.mv('adjustment', -1000, 'dddddddd-0000-4000-8000-000000000001')$$,
  '23514', null, 'an adjustment needs a note');
select lives_ok(
  $$select pg_temp.mv('adjustment', -1000, 'dddddddd-0000-4000-8000-000000000001',
    p_note => 'torn bag')$$,
  'an adjustment with a note');
select throws_ok(
  $$select pg_temp.mv('sale', 1000, 'dddddddd-0000-4000-8000-000000000001',
    p_ref_type => 'shop_sale', p_ref => gen_random_uuid())$$,
  '23514', null, 'a sale moves stock out, not in');
select is(
  (select qty_milli from public.batches where id = '50000000-0000-4000-8000-000000000001'),
  14000::bigint, 'the batch quantity is the sum of its movements (10000 + 5000 - 1000)');

select lives_ok(
  $$select pg_temp.mv('sale', -1000, 'dddddddd-0000-4000-8000-000000000001',
    p_batch => null, p_ref_type => 'shop_sale', p_ref => gen_random_uuid())$$,
  'a negative-stock sale may move stock without a batch (no cache to move)');
select throws_ok(
  $$update public.stock_movements set qty_milli = 1$$,
  '42501', null, 'stock movements are append-only (no update)');
select throws_ok(
  $$delete from public.stock_movements$$,
  '42501', null, 'nor delete');
select lives_ok(
  $$update public.batches set qty_milli = 1, cost_paise = 24500
    where id = '50000000-0000-4000-8000-000000000001'$$,
  'a client update to a batch is accepted');
select is(
  (select qty_milli from public.batches where id = '50000000-0000-4000-8000-000000000001'),
  14000::bigint, 'but the cached quantity is not theirs to set');
select throws_ok(
  $$update public.batches set batch_no = 'B-999'
    where id = '50000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a batch keeps its number');
select throws_ok(
  $$update public.products set unit = 'kg' where id = '40000000-0000-4000-8000-000000000001'$$,
  '23514', null, 'a product with batches keeps its unit');

-- The accountant: master data and adjustments yes, deleting master data no.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);
select throws_ok(
  $$update public.product_categories set deleted_at = now()
    where id = '30000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'an accountant cannot delete master data');

-- The munshi: sells (sales.create) but cannot manage products or adjust.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);
select throws_ok(
  $$insert into public.products (id, tenant_id, sku, name, unit)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'M1', 'Munshi', 'bag')$$,
  '42501', null, 'a munshi cannot add products');
select throws_ok(
  $$select pg_temp.mv('adjustment', -500, 'dddddddd-0000-4000-8000-000000000004',
    p_note => 'x')$$,
  '42501', null, 'nor adjust stock');
select throws_ok(
  $$select pg_temp.mv('purchase', 500, 'dddddddd-0000-4000-8000-000000000004',
    p_ref_type => 'purchase', p_ref => gen_random_uuid())$$,
  '42501', null, 'nor receive a purchase');
select lives_ok(
  $$select pg_temp.mv('sale', -500, 'dddddddd-0000-4000-8000-000000000004',
    p_ref_type => 'shop_sale', p_ref => gen_random_uuid())$$,
  'but a sale moves stock, and the batch follows although the munshi cannot edit batches');
select throws_ok(
  $$select pg_temp.mv('sale', -500, 'dddddddd-0000-4000-8000-000000000001',
    p_ref_type => 'shop_sale', p_ref => gen_random_uuid())$$,
  '42501', null, 'a movement must come from the member''s own device');
select is(
  (select count(*)::int from public.products), 1, 'a munshi reads the products');

-- Rebuild: the movements are the truth.
reset role;
select set_config('request.jwt.claims', '{}', true);
update public.batches set qty_milli = 5
  where id = '50000000-0000-4000-8000-000000000001';
select is(
  public.rebuild_batch_qty('11111111-1111-4111-8111-111111111111'), 1,
  'rebuild fixes the one wrong batch');
select is(
  (select b.qty_milli from public.batches b
   where b.id = '50000000-0000-4000-8000-000000000001'),
  (select sum(m.qty_milli)::bigint from public.stock_movements m
   where m.batch_id = '50000000-0000-4000-8000-000000000001'),
  'and batch.qty_milli = SUM(stock_movements)');

-- Another business sees nothing and cannot write here.
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.products) + (select count(*)::int from public.batches)
  + (select count(*)::int from public.stock_movements)
  + (select count(*)::int from public.product_categories), 0,
  'another business sees no products, batches, movements or categories');
select throws_ok(
  $$insert into public.products (id, tenant_id, sku, name, unit)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'EVIL', 'Evil', 'bag')$$,
  '42501', null, 'and cannot add a product to this business');

select * from finish();
rollback;
