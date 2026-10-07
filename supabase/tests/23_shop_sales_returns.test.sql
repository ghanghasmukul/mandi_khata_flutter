-- Phase 4 (4.3-4.4): shop sales and returns. paid = total, udhaar needs a
-- party, frozen once posted, lines with their header, returns to the original
-- line and batch, the khata and book lines, permissions, tenant isolation.
begin;
create extension if not exists pgtap with schema extensions;
select plan(29);

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

insert into public.parties (id, tenant_id, code, name) values
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'F-1',
   'Farmer One');

insert into public.products (id, tenant_id, sku, name, unit, gst_rate) values
  ('40000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'UREA',
   'Urea', 'bag', 5),
  ('40000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'DAP',
   'DAP', 'bag', 5);
insert into public.batches (id, tenant_id, product_id, batch_no, cost_paise) values
  ('50000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111',
   '40000000-0000-4000-8000-000000000001', 'B-1', 24000),
  ('50000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111',
   '40000000-0000-4000-8000-000000000002', 'B-2', 120000);

create temp table ids as
select (select id from public.bank_accounts
        where tenant_id = '11111111-1111-4111-8111-111111111111' and kind = 'cash') cash;
grant select on ids to authenticated;

-- 2 bags of urea at 26600 = 53200 + 5% GST (CGST/SGST 1330 each) = 55860.
create function pg_temp.sell(p_id uuid, p_no text, p_device uuid, p_party uuid default null,
  p_cash bigint default 55860, p_upi bigint default 0, p_credit bigint default 0,
  p_total bigint default 55860)
returns void language plpgsql as $$
begin
  insert into public.shop_sales (id, tenant_id, sale_no, party_id, place_of_supply, tier,
    entry_date, subtotal_paise, taxable_paise, cgst_paise, sgst_paise, total_paise,
    paid_cash_paise, paid_upi_paise, paid_credit_paise, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', p_no, p_party, '03', 'farmer',
    (now() at time zone 'Asia/Kolkata')::date, 53200, 53200, 1330, 1330, p_total,
    p_cash, p_upi, p_credit, p_device);
  insert into public.shop_sale_lines (id, tenant_id, sale_id, line_no, product_id, batch_id,
    qty_milli, unit_price_paise, tier, taxable_paise, gst_rate, cgst_paise, sgst_paise,
    line_total_paise, hsn, cost_paise)
  values (('70' || substr(p_id::text, 3))::uuid, '11111111-1111-4111-8111-111111111111', p_id,
    0, '40000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001',
    2000, 26600, 'farmer', 53200, 5, 1330, 1330, 55860, '3102', 24000);
  insert into public.stock_movements (id, tenant_id, product_id, batch_id, entry_date,
    qty_milli, reason, ref_type, ref_id, device_id)
  values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
    '40000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001',
    (now() at time zone 'Asia/Kolkata')::date, -2000, 'sale', 'shop_sale', p_id, p_device);
end;
$$;

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);

-- The munshi sells.
select lives_ok(
  $$select pg_temp.sell('80000000-0000-4000-8000-000000000001', 'SI-A1-0001',
    'dddddddd-0000-4000-8000-000000000004')$$,
  'a munshi (sales.create) sells to a walk-in for cash');
select is(
  (select qty_milli from public.batches where id = '50000000-0000-4000-8000-000000000001'),
  -2000::bigint, 'the batch follows the sale movement');
select lives_ok(
  $$select pg_temp.sell('80000000-0000-4000-8000-000000000002', 'SI-A1-0002',
    'dddddddd-0000-4000-8000-000000000004', 'cccccccc-0000-4000-8000-000000000001',
    p_cash => 10000, p_credit => 45860)$$,
  'a split sale: cash + udhaar for a farmer');
select lives_ok(
  $$insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side, amount_paise,
      ref_type, ref_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', (now() at time zone 'Asia/Kolkata')::date,
      'udhaar', 45860, 'shop_sale', '80000000-0000-4000-8000-000000000002',
      'dddddddd-0000-4000-8000-000000000004')$$,
  'the udhaar part posts to the farmer''s khata');
select throws_ok(
  $$insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side, amount_paise,
      ref_type, ref_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', (now() at time zone 'Asia/Kolkata')::date,
      'jama', 45860, 'shop_sale', '80000000-0000-4000-8000-000000000002',
      'dddddddd-0000-4000-8000-000000000004')$$,
  '23514', null, 'a sale cannot post jama');
select lives_ok(
  $$insert into public.cash_bank_entries (id, tenant_id, account_id, account_kind, entry_date,
      direction, amount_paise, shop_sale_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', (select cash from ids),
      'cash', (now() at time zone 'Asia/Kolkata')::date, 'in', 10000,
      '80000000-0000-4000-8000-000000000002', 'dddddddd-0000-4000-8000-000000000004')$$,
  'the cash received is a cash book line linked to the sale');

-- Constraints.
select throws_ok(
  $$select pg_temp.sell(gen_random_uuid(), 'SI-A1-0003', 'dddddddd-0000-4000-8000-000000000004',
    p_cash => 50000)$$,
  '23514', null, 'cash + UPI + udhaar must equal the total');
select throws_ok(
  $$select pg_temp.sell(gen_random_uuid(), 'SI-A1-0004', 'dddddddd-0000-4000-8000-000000000004',
    p_cash => 0, p_credit => 55860)$$,
  '23514', null, 'udhaar needs a party (no walk-in credit)');
select throws_ok(
  $$select pg_temp.sell(gen_random_uuid(), 'SI-A1-0005', 'dddddddd-0000-4000-8000-000000000004',
    p_total => 55000)$$,
  '23514', null, 'the total must equal taxable + GST + round off');
select throws_ok(
  $$select pg_temp.sell('80000000-0000-4000-8000-000000000001', 'SI-A1-0001',
    'dddddddd-0000-4000-8000-000000000004')$$,
  '23505', null, 'an invoice number is unique per business');
select throws_ok(
  $$select pg_temp.sell(gen_random_uuid(), 'SI-A1-0006', 'dddddddd-0000-4000-8000-000000000003')$$,
  '42501', null, 'a sale must come from the member''s own device');
select throws_ok(
  $$insert into public.shop_sales (id, tenant_id, sale_no, entry_date, subtotal_paise,
      taxable_paise, total_paise, paid_cash_paise, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'SI-A1-0007',
      (now() at time zone 'Asia/Kolkata')::date, 1, 1, 1, 1,
      'dddddddd-0000-4000-8000-000000000004');
    set constraints all immediate$$,
  '23514', null, 'a sale without lines is refused when the upload ends');
select throws_ok(
  $$insert into public.shop_sales (id, tenant_id, sale_no, entry_date, subtotal_paise,
      taxable_paise, total_paise, paid_cash_paise, status, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'SI-A1-0008',
      (now() at time zone 'Asia/Kolkata')::date, 1, 1, 1, 1, 'reversed',
      'dddddddd-0000-4000-8000-000000000004')$$,
  '23514', null, 'a sale is created posted');

-- Frozen once posted; the munshi cannot reverse.
select lives_ok(
  $$update public.shop_sales set paid_cash_paise = 0, paid_upi_paise = 55860
    where id = '80000000-0000-4000-8000-000000000001'$$,
  'a munshi''s update of a posted sale matches no row (RLS)');
select is(
  (select paid_upi_paise from public.shop_sales
   where id = '80000000-0000-4000-8000-000000000001'),
  0::bigint, 'and the sale is unchanged');
select throws_ok(
  $$update public.shop_sale_lines set qty_milli = 1$$,
  '42501', null, 'its lines are append-only');
select set_config('mk.shop_doc_new', '', true);
select throws_ok(
  $$insert into public.shop_sale_lines (id, tenant_id, sale_id, line_no, product_id, batch_id,
      qty_milli, unit_price_paise, taxable_paise, line_total_paise)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '80000000-0000-4000-8000-000000000001', 3, '40000000-0000-4000-8000-000000000001',
      '50000000-0000-4000-8000-000000000001', 1000, 1, 1, 1)$$,
  '23514', null, 'a line cannot be added to a posted sale later');
create function pg_temp.sret(p_id uuid, p_no text, p_device uuid, p_qty bigint,
  p_mode text default 'cash',
  p_batch uuid default '50000000-0000-4000-8000-000000000001',
  p_party uuid default null)
returns void language plpgsql as $$
begin
  insert into public.shop_returns (id, tenant_id, sale_id, return_no, party_id, entry_date,
    taxable_paise, cgst_paise, sgst_paise, total_paise, refund_mode, refund_khata_paise,
    refund_cash_paise, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', '80000000-0000-4000-8000-000000000001',
    p_no, p_party, (now() at time zone 'Asia/Kolkata')::date, 26600, 665, 665, 27930,
    p_mode, case when p_mode = 'khata' then 27930 else 0 end,
    case when p_mode = 'khata' then 0 else 27930 end, p_device);
  insert into public.shop_return_lines (id, tenant_id, shop_return_id, line_no, sale_line_id,
    product_id, batch_id, qty_milli, taxable_paise, cgst_paise, sgst_paise, amount_paise)
  values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', p_id, 0,
    '70000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000001', p_batch,
    p_qty, 26600, 665, 665, 27930);
end;
$$;
select throws_ok(
  $$select pg_temp.sret(gen_random_uuid(), 'SR-A1-0001', 'dddddddd-0000-4000-8000-000000000004',
    1000)$$,
  '42501', null, 'a munshi cannot take a return (sales.return)');

-- The accountant: returns, reversal.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);
select set_config('mk.shop_doc_new', '', true);
select lives_ok(
  $$select pg_temp.sret('81000000-0000-4000-8000-000000000001', 'SR-W2-0001',
    'dddddddd-0000-4000-8000-000000000003', 1000)$$,
  'an accountant takes back 1 of 2 bags for a cash refund');
select lives_ok(
  $$insert into public.stock_movements (id, tenant_id, product_id, batch_id, entry_date,
      qty_milli, reason, ref_type, ref_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '40000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001',
      (now() at time zone 'Asia/Kolkata')::date, 1000, 'sale_return', 'shop_return',
      '81000000-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000003')$$,
  'the bag goes back into the original batch');
select is(
  (select qty_milli from public.batches where id = '50000000-0000-4000-8000-000000000001'),
  -3000::bigint, 'batch: two sales of 2 bags and one bag returned = -3 bags');
select throws_ok(
  $$select pg_temp.sret(gen_random_uuid(), 'SR-W2-0002', 'dddddddd-0000-4000-8000-000000000003',
    1500)$$,
  '23514', null, 'returning more than sold (1 + 1.5 > 2) is refused');
select throws_ok(
  $$select pg_temp.sret(gen_random_uuid(), 'SR-W2-0003', 'dddddddd-0000-4000-8000-000000000003',
    500, p_batch => '50000000-0000-4000-8000-000000000002')$$,
  '23514', null, 'a return restocking another batch than the sold one is refused');
select throws_ok(
  $$select pg_temp.sret(gen_random_uuid(), 'SR-W2-0004', 'dddddddd-0000-4000-8000-000000000003',
    500, 'khata')$$,
  '23514', null, 'a refund to the khata needs a party');
select throws_ok(
  $$insert into public.shop_returns (id, tenant_id, sale_id, return_no, entry_date,
      taxable_paise, total_paise, refund_mode, refund_cash_paise, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '80000000-0000-4000-8000-000000000001', 'SR-W2-0009',
      (now() at time zone 'Asia/Kolkata')::date, 100, 100, 'cash', 50,
      'dddddddd-0000-4000-8000-000000000003')$$,
  '23514', null, 'the refund parts must add up to the return total');
select lives_ok(
  $$update public.shop_sales set status = 'reversed', reversed_at = now()
    where id = '80000000-0000-4000-8000-000000000001'$$,
  'an accountant (entries.reverse) reverses a sale');
select throws_ok(
  $$update public.shop_sales set notes = 'x' where id = '80000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'and a reversed sale never changes again');

-- Another business.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.shop_sales) + (select count(*)::int from public.shop_sale_lines)
  + (select count(*)::int from public.shop_returns)
  + (select count(*)::int from public.shop_return_lines), 0,
  'another business sees no sales or returns');
select throws_ok(
  $$select pg_temp.sell(gen_random_uuid(), 'SI-X-1', 'dddddddd-0000-4000-8000-000000000002')$$,
  '42501', null, 'and cannot sell into this business');

select * from finish();
rollback;
