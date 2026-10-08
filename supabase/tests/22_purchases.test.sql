-- Phase 4 (4.2): purchases, purchase returns. Permissions, frozen once
-- posted, totals, lines only with their header, returns to the original line
-- and batch, the supplier's khata and cash book lines, tenant isolation.
begin;
create extension if not exists pgtap with schema extensions;
select plan(31);

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
  ('cccccccc-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'S-1',
   'IFFCO Agency'),
  ('cccccccc-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'S-2',
   'Other Agency');

insert into public.products (id, tenant_id, sku, name, unit) values
  ('40000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'UREA',
   'Urea', 'bag');
insert into public.batches (id, tenant_id, product_id, batch_no, cost_paise) values
  ('50000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111',
   '40000000-0000-4000-8000-000000000001', 'OLD-1', 9000);

create temp table ids as
select (select id from public.bank_accounts
        where tenant_id = '11111111-1111-4111-8111-111111111111' and kind = 'cash') cash;
grant select on ids to authenticated;

-- A purchase of 10 bags (+ 5% GST, freight 2000), 40000 paid in cash:
-- header, line, batch, movement, supplier jama for the rest, cash book line.
create function pg_temp.buy(p_id uuid, p_no text, p_device uuid,
  p_total bigint default 107000, p_paid bigint default 40000,
  p_date date default (now() at time zone 'Asia/Kolkata')::date,
  p_mode text default 'cash')
returns void language plpgsql as $$
begin
  insert into public.purchases (id, tenant_id, purchase_no, party_id, supplier_invoice_no,
    invoice_date, entry_date, freight_paise, taxable_paise, gst_paise, total_paise,
    paid_paise, payment_mode, bank_account_id, credit_days, due_date, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', p_no,
    'cccccccc-0000-4000-8000-000000000001', 'INV-9', p_date, p_date, 2000, 100000, 5000,
    p_total, p_paid, case when p_paid > 0 then p_mode end,
    case when p_paid > 0 then (select cash from ids) end, 30, p_date + 30, p_device);
  insert into public.batches (id, tenant_id, product_id, batch_no, mfg_date, expiry_date,
    cost_paise)
  values (('51' || substr(p_id::text, 3))::uuid, '11111111-1111-4111-8111-111111111111',
    '40000000-0000-4000-8000-000000000001', 'PB-' || p_no, '2026-09-01', '2028-08-31', 10000);
  insert into public.purchase_lines (id, tenant_id, purchase_id, line_no, product_id, batch_id,
    batch_no, mfg_date, expiry_date, qty_milli, cost_paise, gst_rate, taxable_paise,
    gst_paise, line_total_paise)
  values (('52' || substr(p_id::text, 3))::uuid, '11111111-1111-4111-8111-111111111111', p_id, 0,
    '40000000-0000-4000-8000-000000000001', ('51' || substr(p_id::text, 3))::uuid,
    'PB-' || p_no, '2026-09-01', '2028-08-31', 10000, 10000, 5, 100000, 5000, 105000);
  insert into public.stock_movements (id, tenant_id, product_id, batch_id, entry_date,
    qty_milli, reason, ref_type, ref_id, device_id)
  values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
    '40000000-0000-4000-8000-000000000001', ('51' || substr(p_id::text, 3))::uuid, p_date,
    10000, 'purchase', 'purchase', p_id, p_device);
end;
$$;

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000003","role":"authenticated"}', true);

select lives_ok(
  $$select pg_temp.buy('60000000-0000-4000-8000-000000000001', 'PB-W2-0001',
    'dddddddd-0000-4000-8000-000000000003')$$,
  'an accountant records a purchase with its line, batch and stock movement');
select is(
  (select qty_milli from public.batches where id = '51000000-0000-4000-8000-000000000001'),
  10000::bigint, 'and the new batch has the purchased stock');
select lives_ok(
  $$insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side, amount_paise,
      ref_type, ref_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', (now() at time zone 'Asia/Kolkata')::date,
      'jama', 67000, 'purchase', '60000000-0000-4000-8000-000000000001',
      'dddddddd-0000-4000-8000-000000000003')$$,
  'the unpaid 67000 is jama in the supplier''s khata');
select throws_ok(
  $$insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side, amount_paise,
      ref_type, ref_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', (now() at time zone 'Asia/Kolkata')::date,
      'udhaar', 67000, 'purchase', '60000000-0000-4000-8000-000000000001',
      'dddddddd-0000-4000-8000-000000000003')$$,
  '23514', null, 'a purchase entry on the wrong side is refused');
select throws_ok(
  $$insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side, amount_paise,
      ref_type, ref_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000002', (now() at time zone 'Asia/Kolkata')::date,
      'jama', 67000, 'purchase', '60000000-0000-4000-8000-000000000001',
      'dddddddd-0000-4000-8000-000000000003')$$,
  '23514', null, 'or for another party than the purchase''s supplier');
select throws_ok(
  $$insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side, amount_paise,
      ref_type, ref_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', (now() at time zone 'Asia/Kolkata')::date,
      'jama', 67000, 'purchase', gen_random_uuid(),
      'dddddddd-0000-4000-8000-000000000003')$$,
  '23514', null, 'or without a real purchase behind it');
select lives_ok(
  $$insert into public.cash_bank_entries (id, tenant_id, account_id, account_kind, entry_date,
      direction, amount_paise, purchase_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', (select cash from ids),
      'cash', (now() at time zone 'Asia/Kolkata')::date, 'out', 40000,
      '60000000-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000003')$$,
  'the cash paid is a cash book line linked to the purchase');

-- Constraints.
select throws_ok(
  $$select pg_temp.buy(gen_random_uuid(), 'PB-W2-0002', 'dddddddd-0000-4000-8000-000000000003',
    p_total => 107001)$$,
  '23514', null, 'total must equal taxable + GST + charges + round off');
select throws_ok(
  $$select pg_temp.buy(gen_random_uuid(), 'PB-W2-0003', 'dddddddd-0000-4000-8000-000000000003',
    p_paid => 200000)$$,
  '23514', null, 'paid cannot exceed the total');
select throws_ok(
  $$select pg_temp.buy('60000000-0000-4000-8000-000000000001', 'PB-W2-0001',
    'dddddddd-0000-4000-8000-000000000003')$$,
  '23505', null, 'a purchase number is unique per business');
select throws_ok(
  $$select pg_temp.buy(gen_random_uuid(), 'PB-W2-0004', 'dddddddd-0000-4000-8000-000000000001')$$,
  '42501', null, 'a purchase must come from the member''s own device');
select lives_ok(
  $$select pg_temp.buy('60000000-0000-4000-8000-000000000002', 'PB-W2-0005',
    'dddddddd-0000-4000-8000-000000000003',
    p_date => (now() at time zone 'Asia/Kolkata')::date - 30)$$,
  'a back-dated purchase is fine for someone with entries.reverse');
select throws_ok(
  $$insert into public.purchases (id, tenant_id, purchase_no, party_id, invoice_date,
      entry_date, taxable_paise, total_paise, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'PB-W2-0006',
      'cccccccc-0000-4000-8000-000000000001', current_date, current_date, 1, 1,
      'dddddddd-0000-4000-8000-000000000003');
    set constraints all immediate$$,
  '23514', null, 'a purchase without lines is refused when the upload ends');

-- Frozen once posted.
select throws_ok(
  $$update public.purchases set total_paise = 1, taxable_paise = 1, gst_paise = 0,
      freight_paise = 0 where id = '60000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'a posted purchase is frozen');
select throws_ok(
  $$update public.purchase_lines set qty_milli = 1$$,
  '42501', null, 'its lines are append-only');
select throws_ok(
  $$delete from public.purchase_lines$$,
  '42501', null, 'and cannot be deleted');
select set_config('mk.shop_doc_new', '', true);
select throws_ok(
  $$insert into public.purchase_lines (id, tenant_id, purchase_id, line_no, product_id,
      batch_id, batch_no, qty_milli, cost_paise, taxable_paise, line_total_paise)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '60000000-0000-4000-8000-000000000001', 5, '40000000-0000-4000-8000-000000000001',
      '51000000-0000-4000-8000-000000000001', 'x', 1000, 1, 1, 1)$$,
  '23514', null, 'a line cannot be added to a posted purchase later');

-- Returns go to the original line and batch.
select set_config('mk.shop_doc_new', '', true);
create function pg_temp.pret(p_id uuid, p_no text, p_qty bigint,
  p_batch uuid default '51000000-0000-4000-8000-000000000001')
returns void language plpgsql as $$
begin
  insert into public.purchase_returns (id, tenant_id, return_no, purchase_id, party_id,
    entry_date, taxable_paise, gst_paise, total_paise, refund_khata_paise, device_id)
  values (p_id, '11111111-1111-4111-8111-111111111111', p_no,
    '60000000-0000-4000-8000-000000000001', 'cccccccc-0000-4000-8000-000000000001',
    (now() at time zone 'Asia/Kolkata')::date, 10000, 500, 10500, 10500,
    'dddddddd-0000-4000-8000-000000000003');
  insert into public.purchase_return_lines (id, tenant_id, purchase_return_id, line_no,
    purchase_line_id, product_id, batch_id, qty_milli, cost_paise, taxable_paise, gst_paise,
    line_total_paise)
  values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', p_id, 0,
    '52000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000001', p_batch,
    p_qty, 10000, 10000, 500, 10500);
end;
$$;
select lives_ok(
  $$select pg_temp.pret('61000000-0000-4000-8000-000000000001', 'PR-W2-0001', 4000)$$,
  'returning 4 of 10 bags to the original batch');
select throws_ok(
  $$select pg_temp.pret(gen_random_uuid(), 'PR-W2-0002', 7000)$$,
  '23514', null, 'returning more than was bought (4 + 7 > 10) is refused');
select throws_ok(
  $$select pg_temp.pret(gen_random_uuid(), 'PR-W2-0003', 1000,
    '50000000-0000-4000-8000-000000000002')$$,
  '23514', null, 'a return to another batch than the original is refused');
select lives_ok(
  $$insert into public.stock_movements (id, tenant_id, product_id, batch_id, entry_date,
      qty_milli, reason, ref_type, ref_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      '40000000-0000-4000-8000-000000000001', '51000000-0000-4000-8000-000000000001',
      (now() at time zone 'Asia/Kolkata')::date, -4000, 'purchase_return', 'purchase_return',
      '61000000-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000003')$$,
  'the returned stock leaves the batch');
select is(
  (select qty_milli from public.batches where id = '51000000-0000-4000-8000-000000000001'),
  6000::bigint, 'leaving 6 bags');
select lives_ok(
  $$insert into public.ledger_entries (id, tenant_id, party_id, entry_date, side, amount_paise,
      ref_type, ref_id, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111',
      'cccccccc-0000-4000-8000-000000000001', (now() at time zone 'Asia/Kolkata')::date,
      'udhaar', 10500, 'purchase_return', '61000000-0000-4000-8000-000000000001',
      'dddddddd-0000-4000-8000-000000000003')$$,
  'a credit note is udhaar on the supplier''s khata');

-- Reversal.
select lives_ok(
  $$update public.purchases set status = 'reversed', reversed_at = now()
    where id = '60000000-0000-4000-8000-000000000002'$$,
  'an accountant (entries.reverse) reverses a purchase');
select throws_ok(
  $$update public.purchases set notes = 'x' where id = '60000000-0000-4000-8000-000000000002'$$,
  '42501', null, 'and a reversed purchase never changes again');

select throws_ok(
  $$update public.purchases set status = 'reversed', reversed_at = now()
    where id = '60000000-0000-4000-8000-000000000001'$$,
  '23514', null, 'a purchase with a posted return cannot be reversed');
select throws_ok(
  $$insert into public.purchase_returns (id, tenant_id, return_no, purchase_id, party_id,
      entry_date, taxable_paise, gst_paise, total_paise, refund_khata_paise, device_id)
    values (gen_random_uuid(), '11111111-1111-4111-8111-111111111111', 'PR-W2-0010',
      '60000000-0000-4000-8000-000000000002', 'cccccccc-0000-4000-8000-000000000001',
      (now() at time zone 'Asia/Kolkata')::date, 10000, 500, 10500, 10500,
      'dddddddd-0000-4000-8000-000000000003')$$,
  '23514', null, 'a reversed purchase cannot take a return');

-- The munshi has no purchases.create.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000004","role":"authenticated"}', true);
select throws_ok(
  $$select pg_temp.buy(gen_random_uuid(), 'PB-A1-0001', 'dddddddd-0000-4000-8000-000000000004')$$,
  '42501', null, 'a munshi cannot record a purchase');
select is(
  (select count(*)::int from public.purchases) + (select count(*)::int from public.purchase_lines),
  0, 'and does not see purchases (cost and supplier terms are finance data)');

-- Another business.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000002","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.purchases) + (select count(*)::int from public.purchase_lines)
  + (select count(*)::int from public.purchase_returns)
  + (select count(*)::int from public.purchase_return_lines), 0,
  'another business sees no purchases or returns');
select throws_ok(
  $$select pg_temp.buy(gen_random_uuid(), 'PB-X-1', 'dddddddd-0000-4000-8000-000000000002')$$,
  '42501', null, 'and cannot buy into this business');

select * from finish();
rollback;
