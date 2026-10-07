-- Phase 4: the input shop. Rules: docs/domain/shop-schema.md (tables),
-- docs/domain/ledger-and-mandi.md ("Input shop"), posting-rules.md.
--
-- Master data   product_categories, products, batches (batch qty is a cached
--               projection of stock_movements, see below)
-- Stock         stock_movements: append-only, signed; SUM(qty_milli) per
--               batch is the truth. batches.qty_milli is kept by a trigger
--               and can be rebuilt with public.rebuild_batch_qty(tenant).
-- Documents     purchases(+lines), purchase_returns(+lines), shop_sales(+lines),
--               shop_returns(+lines). A header is frozen once posted (only
--               status / reversed_at change); lines are append-only and may
--               only join a header written by the same transaction.
-- Books         ledger_entries ref types shop_sale / shop_return / purchase /
--               purchase_return get permissions; journal_entries gain source
--               types; cash_bank_entries link to the shop documents; the chart
--               gets Stock-in-hand, COGS, GST and Round Off accounts.
--
-- The module flag `shop.enabled` is NOT enforced here (permission only);
-- the app hides the module.  Hold bills are local-only (no table).
-- Quantities are in milli-units (1000 = 1 bag / 1 kg / 1 ltr...).

-- ---------------------------------------------------------------------------
-- Permissions
-- ---------------------------------------------------------------------------

create or replace function private.role_allows(p_role text, p_permission text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case p_role
    when 'owner' then true
    when 'accountant' then p_permission in (
      'parties.manage', 'arrivals.manage', 'payments.create',
      'entries.reverse', 'finance.view',
      'products.manage', 'purchases.create', 'sales.create', 'sales.return',
      'stock.adjust', 'shop.view_profit'
    )
    when 'munshi' then p_permission in (
      'parties.manage', 'arrivals.manage', 'payments.create',
      'sales.create'
    )
    else false
  end;
$$;

-- Which permission a stock movement needs, by reason.
create or replace function private.stock_movement_permission(p_reason text)
returns text
language sql
immutable
set search_path = ''
as $$
  select case p_reason
    when 'purchase' then 'purchases.create'
    when 'purchase_return' then 'purchases.create'
    when 'sale' then 'sales.create'
    when 'sale_return' then 'sales.return'
    else 'stock.adjust'
  end;
$$;

revoke execute on function private.stock_movement_permission(text) from public, anon;
grant execute on function private.stock_movement_permission(text) to authenticated;

-- ---------------------------------------------------------------------------
-- product_categories
-- ---------------------------------------------------------------------------

create table public.product_categories (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  name text not null check (length(trim(name)) > 0),
  sort_order integer not null default 0,
  is_active boolean not null default true,
  deleted_at timestamptz,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint product_categories_id_tenant_unique unique (id, tenant_id)
);

create unique index product_categories_name_unique
  on public.product_categories (tenant_id, lower(name)) where deleted_at is null;

-- ---------------------------------------------------------------------------
-- products
-- ---------------------------------------------------------------------------

create table public.products (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  sku text not null check (length(trim(sku)) > 0),
  barcode text check (barcode is null or length(trim(barcode)) > 0),
  name text not null check (length(trim(name)) > 0),
  brand text,
  category_id uuid,
  unit text not null check (unit in ('bag', 'btl', 'ltr', 'kg', 'pkt', 'pc')),
  -- Free text such as '50 kg' or '500 ml'.
  pack_size text,
  hsn text,
  gst_rate numeric(5, 2) not null default 0 check (gst_rate between 0 and 100),
  reorder_level_milli bigint not null default 0 check (reorder_level_milli >= 0),
  -- {"<tier>": paise} for the business's price tiers.
  prices jsonb not null default '{}'::jsonb check (jsonb_typeof(prices) = 'object'),
  is_active boolean not null default true,
  deleted_at timestamptz,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint products_id_tenant_unique unique (id, tenant_id),
  constraint products_sku_unique unique (tenant_id, sku),
  constraint products_category_fk foreign key (category_id, tenant_id)
    references public.product_categories (id, tenant_id)
);

create unique index products_barcode_unique on public.products (tenant_id, barcode)
  where barcode is not null;
create index products_category_fk_idx on public.products (category_id, tenant_id)
  where category_id is not null;
create index products_tenant_name_idx on public.products (tenant_id, name);

-- ---------------------------------------------------------------------------
-- batches
-- ---------------------------------------------------------------------------

create table public.batches (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  product_id uuid not null,
  batch_no text not null check (length(trim(batch_no)) > 0),
  mfg_date date,
  expiry_date date,
  cost_paise bigint not null default 0 check (cost_paise >= 0),
  -- CACHE ONLY: sum of stock_movements.qty_milli. Maintained by trigger;
  -- clients cannot set it. Rebuild with public.rebuild_batch_qty().
  qty_milli bigint not null default 0,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint batches_id_tenant_unique unique (id, tenant_id),
  constraint batches_id_product_unique unique (id, product_id, tenant_id),
  constraint batches_no_unique unique (tenant_id, product_id, batch_no),
  constraint batches_dates check (expiry_date is null or mfg_date is null or expiry_date >= mfg_date),
  constraint batches_product_fk foreign key (product_id, tenant_id)
    references public.products (id, tenant_id)
);

create index batches_product_fk_idx on public.batches (product_id, tenant_id);
create index batches_expiry_idx on public.batches (tenant_id, expiry_date)
  where expiry_date is not null;

-- ---------------------------------------------------------------------------
-- stock_movements (append-only)
-- ---------------------------------------------------------------------------

create table public.stock_movements (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  product_id uuid not null,
  -- Null only for stock sold beyond what batches hold (shop.allow_negative_stock).
  batch_id uuid,
  entry_date date not null,
  -- Signed: + in, - out.
  qty_milli bigint not null check (qty_milli <> 0),
  reason text not null check (reason in (
    'purchase', 'sale', 'sale_return', 'purchase_return', 'adjustment', 'opening'
  )),
  -- The document behind it. 'stock_adjustment': ref_id is a client-made
  -- adjustment id shared by the movements of one adjustment (no table).
  ref_type text check (ref_type in (
    'purchase', 'purchase_return', 'shop_sale', 'shop_return',
    'stock_adjustment', 'opening'
  )),
  ref_id uuid,
  note text,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  -- When the server received it; set by the server, never the client.
  received_at timestamptz not null default now(),
  constraint stock_movements_id_tenant_unique unique (id, tenant_id),
  constraint stock_movements_adjustment_note
    check (reason <> 'adjustment' or length(trim(coalesce(note, ''))) > 0),
  constraint stock_movements_sign check (
    case reason
      when 'purchase' then qty_milli > 0
      when 'opening' then qty_milli > 0
      when 'sale_return' then qty_milli > 0
      when 'sale' then qty_milli < 0
      when 'purchase_return' then qty_milli < 0
      else true
    end),
  constraint stock_movements_ref check (
    (reason in ('adjustment', 'opening')) or (ref_type is not null and ref_id is not null)),
  constraint stock_movements_product_fk foreign key (product_id, tenant_id)
    references public.products (id, tenant_id),
  constraint stock_movements_batch_fk foreign key (batch_id, product_id, tenant_id)
    references public.batches (id, product_id, tenant_id)
);

create index stock_movements_batch_idx on public.stock_movements (tenant_id, batch_id);
create index stock_movements_product_date_idx
  on public.stock_movements (tenant_id, product_id, entry_date);
create index stock_movements_ref_idx on public.stock_movements (tenant_id, ref_id)
  where ref_id is not null;
create index stock_movements_product_fk_idx on public.stock_movements (product_id, tenant_id);
create index stock_movements_batch_fk_idx
  on public.stock_movements (batch_id, product_id, tenant_id);
create index stock_movements_device_idx on public.stock_movements (device_id)
  where device_id is not null;

-- ---------------------------------------------------------------------------
-- purchases
-- ---------------------------------------------------------------------------

create table public.purchases (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- PB-<device>-<n>
  purchase_no text not null check (length(trim(purchase_no)) > 0),
  party_id uuid not null,
  supplier_invoice_no text,
  invoice_date date not null,
  entry_date date not null,
  freight_paise bigint not null default 0 check (freight_paise >= 0),
  other_charges_paise bigint not null default 0 check (other_charges_paise >= 0),
  taxable_paise bigint not null check (taxable_paise >= 0),
  gst_paise bigint not null default 0 check (gst_paise >= 0),
  round_off_paise bigint not null default 0,
  total_paise bigint not null check (total_paise >= 0),
  -- Paid at the time of purchase; the rest is jama in the supplier's khata.
  paid_paise bigint not null default 0 check (paid_paise >= 0),
  payment_mode text check (payment_mode in ('cash', 'bank')),
  bank_account_id uuid,
  credit_days integer not null default 0 check (credit_days >= 0),
  due_date date,
  notes text,
  status text not null default 'posted' check (status in ('posted', 'reversed')),
  reversed_at timestamptz,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint purchases_no_unique unique (tenant_id, purchase_no),
  constraint purchases_id_tenant_unique unique (id, tenant_id),
  constraint purchases_total check (
    total_paise = taxable_paise + gst_paise + freight_paise + other_charges_paise
      + round_off_paise),
  constraint purchases_paid check (paid_paise <= total_paise),
  constraint purchases_paid_mode check (
    (paid_paise = 0) or (payment_mode is not null and bank_account_id is not null)),
  constraint purchases_due check (due_date is null or due_date >= invoice_date),
  constraint purchases_reversed_at check ((status = 'reversed') = (reversed_at is not null)),
  constraint purchases_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint purchases_account_fk foreign key (bank_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id)
);

create index purchases_tenant_date_idx on public.purchases (tenant_id, entry_date);
create index purchases_party_idx on public.purchases (party_id, tenant_id);
create index purchases_account_fk_idx on public.purchases (bank_account_id, tenant_id)
  where bank_account_id is not null;
create index purchases_device_idx on public.purchases (device_id) where device_id is not null;

create table public.purchase_lines (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  purchase_id uuid not null,
  line_no integer not null check (line_no >= 0),
  product_id uuid not null,
  batch_id uuid not null,
  -- Snapshots of the batch as bought.
  batch_no text not null,
  mfg_date date,
  expiry_date date,
  qty_milli bigint not null check (qty_milli > 0),
  -- Unit cost (per 1 unit, ex-GST).
  cost_paise bigint not null check (cost_paise >= 0),
  gst_rate numeric(5, 2) not null default 0 check (gst_rate between 0 and 100),
  taxable_paise bigint not null check (taxable_paise >= 0),
  gst_paise bigint not null default 0 check (gst_paise >= 0),
  line_total_paise bigint not null check (line_total_paise >= 0),
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint purchase_lines_id_tenant_unique unique (id, tenant_id),
  constraint purchase_lines_line_unique unique (purchase_id, line_no),
  constraint purchase_lines_total check (line_total_paise = taxable_paise + gst_paise),
  constraint purchase_lines_purchase_fk foreign key (purchase_id, tenant_id)
    references public.purchases (id, tenant_id),
  constraint purchase_lines_product_fk foreign key (product_id, tenant_id)
    references public.products (id, tenant_id),
  constraint purchase_lines_batch_fk foreign key (batch_id, product_id, tenant_id)
    references public.batches (id, product_id, tenant_id)
);

create index purchase_lines_tenant_idx on public.purchase_lines (tenant_id, purchase_id);
create index purchase_lines_purchase_fk_idx on public.purchase_lines (purchase_id, tenant_id);
create index purchase_lines_product_fk_idx on public.purchase_lines (product_id, tenant_id);
create index purchase_lines_batch_fk_idx
  on public.purchase_lines (batch_id, product_id, tenant_id);

-- ---------------------------------------------------------------------------
-- purchase_returns
-- ---------------------------------------------------------------------------

create table public.purchase_returns (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- PR-<device>-<n>
  return_no text not null check (length(trim(return_no)) > 0),
  purchase_id uuid not null,
  party_id uuid not null,
  entry_date date not null,
  taxable_paise bigint not null check (taxable_paise >= 0),
  gst_paise bigint not null default 0 check (gst_paise >= 0),
  round_off_paise bigint not null default 0,
  total_paise bigint not null check (total_paise >= 0),
  -- Credit note on the supplier's khata (udhaar) + money back from the
  -- supplier (cash / bank) = total.
  refund_khata_paise bigint not null default 0 check (refund_khata_paise >= 0),
  refund_paid_paise bigint not null default 0 check (refund_paid_paise >= 0),
  payment_mode text check (payment_mode in ('cash', 'bank')),
  bank_account_id uuid,
  note text,
  status text not null default 'posted' check (status in ('posted', 'reversed')),
  reversed_at timestamptz,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint purchase_returns_no_unique unique (tenant_id, return_no),
  constraint purchase_returns_id_tenant_unique unique (id, tenant_id),
  constraint purchase_returns_total check (
    total_paise = taxable_paise + gst_paise + round_off_paise),
  constraint purchase_returns_refund_sum check (
    refund_khata_paise + refund_paid_paise = total_paise),
  constraint purchase_returns_refund_mode check (
    refund_paid_paise = 0 or (payment_mode is not null and bank_account_id is not null)),
  constraint purchase_returns_reversed_at check ((status = 'reversed') = (reversed_at is not null)),
  constraint purchase_returns_purchase_fk foreign key (purchase_id, tenant_id)
    references public.purchases (id, tenant_id),
  constraint purchase_returns_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint purchase_returns_account_fk foreign key (bank_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id)
);

create index purchase_returns_tenant_date_idx on public.purchase_returns (tenant_id, entry_date);
create index purchase_returns_purchase_fk_idx on public.purchase_returns (purchase_id, tenant_id);
create index purchase_returns_party_fk_idx on public.purchase_returns (party_id, tenant_id);
create index purchase_returns_account_fk_idx on public.purchase_returns (bank_account_id, tenant_id)
  where bank_account_id is not null;
create index purchase_returns_device_idx on public.purchase_returns (device_id)
  where device_id is not null;

create table public.purchase_return_lines (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  purchase_return_id uuid not null,
  line_no integer not null check (line_no >= 0),
  -- The purchase line returned; the batch is that line's batch.
  purchase_line_id uuid not null,
  product_id uuid not null,
  batch_id uuid not null,
  qty_milli bigint not null check (qty_milli > 0),
  cost_paise bigint not null check (cost_paise >= 0),
  taxable_paise bigint not null check (taxable_paise >= 0),
  gst_paise bigint not null default 0 check (gst_paise >= 0),
  line_total_paise bigint not null check (line_total_paise >= 0),
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint purchase_return_lines_id_tenant_unique unique (id, tenant_id),
  constraint purchase_return_lines_line_unique unique (purchase_return_id, line_no),
  constraint purchase_return_lines_total check (line_total_paise = taxable_paise + gst_paise),
  constraint purchase_return_lines_return_fk foreign key (purchase_return_id, tenant_id)
    references public.purchase_returns (id, tenant_id),
  constraint purchase_return_lines_line_fk foreign key (purchase_line_id, tenant_id)
    references public.purchase_lines (id, tenant_id),
  constraint purchase_return_lines_batch_fk foreign key (batch_id, product_id, tenant_id)
    references public.batches (id, product_id, tenant_id)
);

create index purchase_return_lines_tenant_idx
  on public.purchase_return_lines (tenant_id, purchase_return_id);
create index purchase_return_lines_return_fk_idx
  on public.purchase_return_lines (purchase_return_id, tenant_id);
create index purchase_return_lines_line_fk_idx
  on public.purchase_return_lines (purchase_line_id, tenant_id);
create index purchase_return_lines_batch_fk_idx
  on public.purchase_return_lines (batch_id, product_id, tenant_id);

-- ---------------------------------------------------------------------------
-- shop_sales
-- ---------------------------------------------------------------------------

create table public.shop_sales (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- SI-<device>-<n>
  sale_no text not null check (length(trim(sale_no)) > 0),
  -- Null = walk-in customer.
  party_id uuid,
  customer_name text,
  -- Snapshots at the time of sale.
  customer_gstin text,
  place_of_supply text check (place_of_supply is null or place_of_supply ~ '^[0-9]{2}$'),
  tier text,
  entry_date date not null,
  -- Gross of line discounts; discount_paise = Σ line discounts.
  subtotal_paise bigint not null check (subtotal_paise >= 0),
  discount_paise bigint not null default 0 check (discount_paise >= 0),
  invoice_discount_pct numeric(5, 2) not null default 0
    check (invoice_discount_pct between 0 and 100),
  invoice_discount_paise bigint not null default 0 check (invoice_discount_paise >= 0),
  taxable_paise bigint not null check (taxable_paise >= 0),
  cgst_paise bigint not null default 0 check (cgst_paise >= 0),
  sgst_paise bigint not null default 0 check (sgst_paise >= 0),
  igst_paise bigint not null default 0 check (igst_paise >= 0),
  round_off_paise bigint not null default 0,
  total_paise bigint not null check (total_paise >= 0),
  paid_cash_paise bigint not null default 0 check (paid_cash_paise >= 0),
  paid_upi_paise bigint not null default 0 check (paid_upi_paise >= 0),
  -- Udhaar: posts to the party's khata.
  paid_credit_paise bigint not null default 0 check (paid_credit_paise >= 0),
  -- The bank account UPI money lands in (null: the app's default bank).
  upi_account_id uuid,
  notes text,
  status text not null default 'posted' check (status in ('posted', 'reversed')),
  reversed_at timestamptz,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint shop_sales_no_unique unique (tenant_id, sale_no),
  constraint shop_sales_id_tenant_unique unique (id, tenant_id),
  constraint shop_sales_total check (
    total_paise = taxable_paise + cgst_paise + sgst_paise + igst_paise + round_off_paise),
  constraint shop_sales_paid_sum check (
    paid_cash_paise + paid_upi_paise + paid_credit_paise = total_paise),
  constraint shop_sales_udhaar_party check (paid_credit_paise = 0 or party_id is not null),
  constraint shop_sales_reversed_at check ((status = 'reversed') = (reversed_at is not null)),
  constraint shop_sales_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint shop_sales_upi_fk foreign key (upi_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id)
);

create index shop_sales_tenant_date_idx on public.shop_sales (tenant_id, entry_date);
create index shop_sales_party_fk_idx on public.shop_sales (party_id, tenant_id)
  where party_id is not null;
create index shop_sales_upi_fk_idx on public.shop_sales (upi_account_id, tenant_id)
  where upi_account_id is not null;
create index shop_sales_device_idx on public.shop_sales (device_id) where device_id is not null;

create table public.shop_sale_lines (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  sale_id uuid not null,
  line_no integer not null check (line_no >= 0),
  product_id uuid not null,
  -- Null for the uncovered part of a negative-stock sale.
  batch_id uuid,
  qty_milli bigint not null check (qty_milli > 0),
  -- Unit price (per 1 unit) before discount, from the tier.
  unit_price_paise bigint not null check (unit_price_paise >= 0),
  tier text,
  discount_paise bigint not null default 0 check (discount_paise >= 0),
  taxable_paise bigint not null check (taxable_paise >= 0),
  gst_rate numeric(5, 2) not null default 0 check (gst_rate between 0 and 100),
  cgst_paise bigint not null default 0 check (cgst_paise >= 0),
  sgst_paise bigint not null default 0 check (sgst_paise >= 0),
  igst_paise bigint not null default 0 check (igst_paise >= 0),
  line_total_paise bigint not null check (line_total_paise >= 0),
  -- Snapshots: HSN as sold, and the batch's unit cost for COGS.
  hsn text,
  cost_paise bigint not null default 0 check (cost_paise >= 0),
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint shop_sale_lines_id_tenant_unique unique (id, tenant_id),
  constraint shop_sale_lines_line_unique unique (sale_id, line_no),
  constraint shop_sale_lines_total check (
    line_total_paise = taxable_paise + cgst_paise + sgst_paise + igst_paise),
  constraint shop_sale_lines_sale_fk foreign key (sale_id, tenant_id)
    references public.shop_sales (id, tenant_id),
  constraint shop_sale_lines_product_fk foreign key (product_id, tenant_id)
    references public.products (id, tenant_id),
  constraint shop_sale_lines_batch_fk foreign key (batch_id, product_id, tenant_id)
    references public.batches (id, product_id, tenant_id)
);

create index shop_sale_lines_tenant_idx on public.shop_sale_lines (tenant_id, sale_id);
create index shop_sale_lines_sale_fk_idx on public.shop_sale_lines (sale_id, tenant_id);
create index shop_sale_lines_product_fk_idx on public.shop_sale_lines (product_id, tenant_id);
create index shop_sale_lines_batch_fk_idx
  on public.shop_sale_lines (batch_id, product_id, tenant_id);

-- ---------------------------------------------------------------------------
-- shop_returns
-- ---------------------------------------------------------------------------

create table public.shop_returns (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- SR-<device>-<n>
  return_no text not null check (length(trim(return_no)) > 0),
  sale_id uuid not null,
  party_id uuid,
  entry_date date not null,
  taxable_paise bigint not null check (taxable_paise >= 0),
  cgst_paise bigint not null default 0 check (cgst_paise >= 0),
  sgst_paise bigint not null default 0 check (sgst_paise >= 0),
  igst_paise bigint not null default 0 check (igst_paise >= 0),
  round_off_paise bigint not null default 0,
  total_paise bigint not null check (total_paise >= 0),
  -- The settlement choice; the three parts below say what was done.
  refund_mode text not null check (refund_mode in ('khata', 'cash', 'upi', 'auto')),
  -- Credit to the party's khata (jama) + cash back + UPI back = total.
  refund_khata_paise bigint not null default 0 check (refund_khata_paise >= 0),
  refund_cash_paise bigint not null default 0 check (refund_cash_paise >= 0),
  refund_upi_paise bigint not null default 0 check (refund_upi_paise >= 0),
  -- For a UPI refund: the bank account it leaves.
  bank_account_id uuid,
  note text,
  status text not null default 'posted' check (status in ('posted', 'reversed')),
  reversed_at timestamptz,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint shop_returns_no_unique unique (tenant_id, return_no),
  constraint shop_returns_id_tenant_unique unique (id, tenant_id),
  constraint shop_returns_total check (
    total_paise = taxable_paise + cgst_paise + sgst_paise + igst_paise + round_off_paise),
  constraint shop_returns_refund_sum check (
    refund_khata_paise + refund_cash_paise + refund_upi_paise = total_paise),
  constraint shop_returns_khata_party check (refund_khata_paise = 0 or party_id is not null),
  constraint shop_returns_upi_account check (refund_upi_paise = 0 or bank_account_id is not null),
  constraint shop_returns_reversed_at check ((status = 'reversed') = (reversed_at is not null)),
  constraint shop_returns_sale_fk foreign key (sale_id, tenant_id)
    references public.shop_sales (id, tenant_id),
  constraint shop_returns_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint shop_returns_account_fk foreign key (bank_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id)
);

create index shop_returns_tenant_date_idx on public.shop_returns (tenant_id, entry_date);
create index shop_returns_sale_fk_idx on public.shop_returns (sale_id, tenant_id);
create index shop_returns_party_fk_idx on public.shop_returns (party_id, tenant_id)
  where party_id is not null;
create index shop_returns_account_fk_idx on public.shop_returns (bank_account_id, tenant_id)
  where bank_account_id is not null;
create index shop_returns_device_idx on public.shop_returns (device_id)
  where device_id is not null;

create table public.shop_return_lines (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  shop_return_id uuid not null,
  line_no integer not null check (line_no >= 0),
  -- The sale line returned; the batch restocked is that line's batch.
  sale_line_id uuid not null,
  product_id uuid not null,
  batch_id uuid,
  qty_milli bigint not null check (qty_milli > 0),
  taxable_paise bigint not null check (taxable_paise >= 0),
  cgst_paise bigint not null default 0 check (cgst_paise >= 0),
  sgst_paise bigint not null default 0 check (sgst_paise >= 0),
  igst_paise bigint not null default 0 check (igst_paise >= 0),
  -- What the customer gets back for this line (incl. GST).
  amount_paise bigint not null check (amount_paise >= 0),
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint shop_return_lines_id_tenant_unique unique (id, tenant_id),
  constraint shop_return_lines_line_unique unique (shop_return_id, line_no),
  constraint shop_return_lines_total check (
    amount_paise = taxable_paise + cgst_paise + sgst_paise + igst_paise),
  constraint shop_return_lines_return_fk foreign key (shop_return_id, tenant_id)
    references public.shop_returns (id, tenant_id),
  constraint shop_return_lines_sale_line_fk foreign key (sale_line_id, tenant_id)
    references public.shop_sale_lines (id, tenant_id),
  constraint shop_return_lines_batch_fk foreign key (batch_id, product_id, tenant_id)
    references public.batches (id, product_id, tenant_id)
);

create index shop_return_lines_tenant_idx
  on public.shop_return_lines (tenant_id, shop_return_id);
create index shop_return_lines_return_fk_idx
  on public.shop_return_lines (shop_return_id, tenant_id);
create index shop_return_lines_sale_line_fk_idx
  on public.shop_return_lines (sale_line_id, tenant_id);
create index shop_return_lines_batch_fk_idx
  on public.shop_return_lines (batch_id, product_id, tenant_id);

-- ---------------------------------------------------------------------------
-- Common triggers
-- ---------------------------------------------------------------------------

do $$
declare
  t text;
begin
  -- Tables with updated_at / master or header rows.
  foreach t in array array[
    'product_categories', 'products', 'batches', 'purchases', 'purchase_returns',
    'shop_sales', 'shop_returns'
  ] loop
    execute format(
      'create trigger %1$s_set_updated_at before update on public.%1$s
         for each row execute function private.set_updated_at()', t);
    execute format(
      'create trigger %1$s_keep_tenant_id before update on public.%1$s
         for each row execute function private.keep_tenant_id()', t);
  end loop;
  foreach t in array array[
    'product_categories', 'products', 'batches', 'stock_movements', 'purchases',
    'purchase_lines', 'purchase_returns', 'purchase_return_lines', 'shop_sales',
    'shop_sale_lines', 'shop_returns', 'shop_return_lines'
  ] loop
    execute format(
      'create trigger %1$s_set_created_by before insert on public.%1$s
         for each row execute function private.set_created_by()', t);
  end loop;
  -- Append-only rows.
  foreach t in array array[
    'stock_movements', 'purchase_lines', 'purchase_return_lines', 'shop_sale_lines',
    'shop_return_lines'
  ] loop
    execute format(
      'create trigger %1$s_append_only before update or delete on public.%1$s
         for each row execute function private.reject_change()', t);
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Master data guards
-- ---------------------------------------------------------------------------

-- Retiring (deleted_at) a product or category needs master.delete.
create or replace function private.guard_product_master()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    if new.deleted_at is distinct from old.deleted_at and new.deleted_at is not null
      and (select auth.uid()) is not null
      and not (select private.has_permission(new.tenant_id, 'master.delete')) then
      raise exception 'deleting master data needs master.delete' using errcode = '42501';
    end if;
    if tg_table_name = 'products' and new.unit is distinct from old.unit
      and exists (select 1 from public.batches b
                  where b.product_id = old.id and b.tenant_id = old.tenant_id) then
      raise exception 'a product with batches keeps its unit' using errcode = '23514';
    end if;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_product_master() from public, anon, authenticated;

create trigger product_categories_guard before update on public.product_categories
  for each row execute function private.guard_product_master();
create trigger products_guard before update on public.products
  for each row execute function private.guard_product_master();

-- A batch keeps its product and number; its quantity is only ever moved by
-- stock_movements (a client cannot set it).
create or replace function private.guard_batch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if current_user in ('authenticated', 'anon') then
      new.qty_milli := 0;
    end if;
    return new;
  end if;
  if new.product_id is distinct from old.product_id
    or new.batch_no is distinct from old.batch_no then
    raise exception 'a batch keeps its product and number' using errcode = '42501';
  end if;
  if current_user in ('authenticated', 'anon') then
    new.qty_milli := old.qty_milli;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_batch() from public, anon, authenticated;

create trigger batches_guard before insert or update on public.batches
  for each row execute function private.guard_batch();

-- ---------------------------------------------------------------------------
-- Stock movements: guard + cached batch quantity
-- ---------------------------------------------------------------------------

create or replace function private.guard_stock_movement()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.received_at := now();
  if new.created_at > now() + interval '1 day' then
    raise exception 'created_at is in the future' using errcode = '23514';
  end if;
  if (select auth.uid()) is not null and not exists (
    select 1 from public.devices d
    where d.id = new.device_id and d.tenant_id = new.tenant_id
      and d.user_id = (select auth.uid()) and d.revoked_at is null
  ) then
    raise exception 'stock movements must come from one of your devices in this business'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_stock_movement() from public, anon, authenticated;

create trigger stock_movements_guard before insert on public.stock_movements
  for each row execute function private.guard_stock_movement();

-- Runs as the function owner: a munshi who sells does not have permission to
-- update batches, but the sale still moves the cached quantity.
create or replace function private.apply_stock_movement()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.batches b set qty_milli = b.qty_milli + new.qty_milli
  where b.id = new.batch_id and b.tenant_id = new.tenant_id;
  return new;
end;
$$;

revoke execute on function private.apply_stock_movement() from public, anon, authenticated;

create trigger stock_movements_apply after insert on public.stock_movements
  for each row execute function private.apply_stock_movement();

-- Repairs batches.qty_milli from the movements (the truth). Returns how many
-- batches were wrong. Needs stock.adjust (or no signed-in user: maintenance).
create or replace function public.rebuild_batch_qty(p_tenant uuid)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_fixed integer;
begin
  if (select auth.uid()) is not null
    and not (select private.has_permission(p_tenant, 'stock.adjust')) then
    raise exception 'rebuilding stock needs stock.adjust' using errcode = '42501';
  end if;
  with truth as (
    select b.id, coalesce(sum(m.qty_milli), 0)::bigint as qty
    from public.batches b
    left join public.stock_movements m
      on m.batch_id = b.id and m.tenant_id = b.tenant_id
    where b.tenant_id = p_tenant
    group by b.id
  ), changed as (
    update public.batches b set qty_milli = t.qty
    from truth t
    where b.id = t.id and b.tenant_id = p_tenant and b.qty_milli is distinct from t.qty
    returning b.id
  )
  select count(*) into v_fixed from changed;
  return v_fixed;
end;
$$;

revoke execute on function public.rebuild_batch_qty(uuid) from public, anon;
grant execute on function public.rebuild_batch_qty(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- Document headers: frozen once posted
-- ---------------------------------------------------------------------------

-- One guard for purchases, purchase_returns, shop_sales and shop_returns.
-- Created posted, from one of the user's devices, back-dating needs
-- entries.reverse; afterwards only status / reversed_at change (reversal needs
-- entries.reverse) and a reversed document never changes.
create or replace function private.guard_shop_document()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if new.status <> 'posted' then
      raise exception 'a document is created posted' using errcode = '23514';
    end if;
    if new.created_at > now() + interval '1 day' then
      raise exception 'created_at is in the future' using errcode = '23514';
    end if;
    if (select auth.uid()) is not null then
      if private.ledger_date_restricted(new.tenant_id, new.entry_date, new.created_at)
        and not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
        raise exception 'a back-dated document needs entries.reverse' using errcode = '42501';
      end if;
      if not exists (
        select 1 from public.devices d
        where d.id = new.device_id and d.tenant_id = new.tenant_id
          and d.user_id = (select auth.uid()) and d.revoked_at is null
      ) then
        raise exception 'documents must come from one of your devices in this business'
          using errcode = '42501';
      end if;
    end if;
    -- Its lines may join now, in this transaction, and never later.
    perform set_config(
      'mk.shop_doc_new',
      coalesce(current_setting('mk.shop_doc_new', true), '') || new.id::text || ',',
      true);
    return new;
  end if;

  if old.status = 'reversed' then
    raise exception 'a reversed document cannot change' using errcode = '42501';
  end if;
  if (to_jsonb(new) - 'status' - 'reversed_at' - 'updated_at')
    <> (to_jsonb(old) - 'status' - 'reversed_at' - 'updated_at') then
    raise exception 'a posted document cannot change; reverse it instead'
      using errcode = '42501';
  end if;
  if (select auth.uid()) is not null and new.status is distinct from old.status
    and not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
    raise exception 'reversing a document needs entries.reverse' using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_shop_document() from public, anon, authenticated;

-- Lines only join a header written by the same transaction.
-- tg_argv[0] = the header id column.
create or replace function private.guard_shop_line()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if position(
    (to_jsonb(new) ->> tg_argv[0]) || ',' in coalesce(current_setting('mk.shop_doc_new', true), '')
  ) = 0 then
    raise exception 'lines can only be added in the transaction that wrote the document'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_shop_line() from public, anon, authenticated;

-- At the end of the upload a document has at least one line.
-- tg_argv: lines table, header id column in the lines table.
create or replace function private.check_shop_document_lines()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_lines bigint;
begin
  execute format(
    'select count(*) from public.%I where %I = $1 and tenant_id = $2', tg_argv[0], tg_argv[1])
    into v_lines using new.id, new.tenant_id;
  if v_lines < 1 then
    raise exception 'a document needs at least one line' using errcode = '23514';
  end if;
  return null;
end;
$$;

revoke execute on function private.check_shop_document_lines() from public, anon, authenticated;

create trigger purchases_guard before insert or update on public.purchases
  for each row execute function private.guard_shop_document();
create trigger purchase_returns_guard before insert or update on public.purchase_returns
  for each row execute function private.guard_shop_document();
create trigger shop_sales_guard before insert or update on public.shop_sales
  for each row execute function private.guard_shop_document();
create trigger shop_returns_guard before insert or update on public.shop_returns
  for each row execute function private.guard_shop_document();

create constraint trigger purchases_has_lines after insert on public.purchases
  deferrable initially deferred
  for each row execute function private.check_shop_document_lines('purchase_lines', 'purchase_id');
create constraint trigger purchase_returns_has_lines after insert on public.purchase_returns
  deferrable initially deferred
  for each row execute function private.check_shop_document_lines(
    'purchase_return_lines', 'purchase_return_id');
create constraint trigger shop_sales_has_lines after insert on public.shop_sales
  deferrable initially deferred
  for each row execute function private.check_shop_document_lines('shop_sale_lines', 'sale_id');
create constraint trigger shop_returns_has_lines after insert on public.shop_returns
  deferrable initially deferred
  for each row execute function private.check_shop_document_lines(
    'shop_return_lines', 'shop_return_id');

create trigger purchase_lines_guard before insert on public.purchase_lines
  for each row execute function private.guard_shop_line('purchase_id');
create trigger purchase_return_lines_guard before insert on public.purchase_return_lines
  for each row execute function private.guard_shop_line('purchase_return_id');
create trigger shop_sale_lines_guard before insert on public.shop_sale_lines
  for each row execute function private.guard_shop_line('sale_id');
create trigger shop_return_lines_guard before insert on public.shop_return_lines
  for each row execute function private.guard_shop_line('shop_return_id');

-- A return line returns (part of) a line of the ORIGINAL document, to the
-- original batch, never more than was bought / sold in total.
create or replace function private.guard_purchase_return_line()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_line public.purchase_lines;
  v_purchase uuid;
  v_returned bigint;
begin
  select * into v_line from public.purchase_lines l
  where l.id = new.purchase_line_id and l.tenant_id = new.tenant_id;
  select r.purchase_id into v_purchase from public.purchase_returns r
  where r.id = new.purchase_return_id and r.tenant_id = new.tenant_id;
  if v_line.id is null or v_purchase is null then
    return new; -- the foreign keys report it
  end if;
  if v_line.purchase_id <> v_purchase
    or v_line.product_id <> new.product_id or v_line.batch_id <> new.batch_id then
    raise exception 'a return goes to the original purchase line and batch'
      using errcode = '23514';
  end if;
  select coalesce(sum(l.qty_milli), 0) into v_returned
  from public.purchase_return_lines l
  join public.purchase_returns r on r.id = l.purchase_return_id and r.tenant_id = l.tenant_id
  where l.purchase_line_id = new.purchase_line_id and l.tenant_id = new.tenant_id
    and r.status = 'posted';
  if v_returned + new.qty_milli > v_line.qty_milli then
    raise exception 'more returned than bought' using errcode = '23514';
  end if;
  return new;
end;
$$;

create or replace function private.guard_shop_return_line()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_line public.shop_sale_lines;
  v_sale uuid;
  v_returned bigint;
begin
  select * into v_line from public.shop_sale_lines l
  where l.id = new.sale_line_id and l.tenant_id = new.tenant_id;
  select r.sale_id into v_sale from public.shop_returns r
  where r.id = new.shop_return_id and r.tenant_id = new.tenant_id;
  if v_line.id is null or v_sale is null then
    return new; -- the foreign keys report it
  end if;
  if v_line.sale_id <> v_sale
    or v_line.product_id <> new.product_id
    or v_line.batch_id is distinct from new.batch_id then
    raise exception 'a return goes to the original sale line and batch'
      using errcode = '23514';
  end if;
  select coalesce(sum(l.qty_milli), 0) into v_returned
  from public.shop_return_lines l
  join public.shop_returns r on r.id = l.shop_return_id and r.tenant_id = l.tenant_id
  where l.sale_line_id = new.sale_line_id and l.tenant_id = new.tenant_id
    and r.status = 'posted';
  if v_returned + new.qty_milli > v_line.qty_milli then
    raise exception 'more returned than sold' using errcode = '23514';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_purchase_return_line(),
  private.guard_shop_return_line() from public, anon, authenticated;

create trigger purchase_return_lines_guard_original
  before insert on public.purchase_return_lines
  for each row execute function private.guard_purchase_return_line();
create trigger shop_return_lines_guard_original
  before insert on public.shop_return_lines
  for each row execute function private.guard_shop_return_line();

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table public.product_categories enable row level security;
alter table public.products enable row level security;
alter table public.batches enable row level security;
alter table public.stock_movements enable row level security;
alter table public.purchases enable row level security;
alter table public.purchase_lines enable row level security;
alter table public.purchase_returns enable row level security;
alter table public.purchase_return_lines enable row level security;
alter table public.shop_sales enable row level security;
alter table public.shop_sale_lines enable row level security;
alter table public.shop_returns enable row level security;
alter table public.shop_return_lines enable row level security;

-- Products, batches, stock and sales: every member (the counter needs them).
-- Purchases: finance.view or purchases.create, plus rows you wrote yourself
-- (the upload's ON CONFLICT DO NOTHING needs to see them).
do $$
declare
  t text;
begin
  foreach t in array array[
    'product_categories', 'products', 'batches', 'stock_movements', 'shop_sales',
    'shop_sale_lines', 'shop_returns', 'shop_return_lines'
  ] loop
    execute format(
      'create policy %1$s_select on public.%1$s for select to authenticated
         using (tenant_id in (select private.auth_tenant_ids()))', t);
  end loop;
  foreach t in array array[
    'purchases', 'purchase_lines', 'purchase_returns', 'purchase_return_lines'
  ] loop
    execute format(
      'create policy %1$s_select on public.%1$s for select to authenticated
         using (tenant_id in (select private.auth_tenant_ids())
           and ((select private.has_permission(tenant_id, ''finance.view''))
             or (select private.has_permission(tenant_id, ''purchases.create''))
             or created_by = (select auth.uid())))', t);
  end loop;
end;
$$;

create policy product_categories_insert on public.product_categories
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'products.manage')));
create policy product_categories_update on public.product_categories
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'products.manage')))
  with check ((select private.has_permission(tenant_id, 'products.manage')));

create policy products_insert on public.products
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'products.manage')));
create policy products_update on public.products
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'products.manage')))
  with check ((select private.has_permission(tenant_id, 'products.manage')));

-- A batch is made by a purchase, an opening-stock import or an adjustment.
create policy batches_insert on public.batches
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and ((select private.has_permission(tenant_id, 'purchases.create'))
      or (select private.has_permission(tenant_id, 'stock.adjust'))
      or (select private.has_permission(tenant_id, 'products.manage'))));
create policy batches_update on public.batches
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'purchases.create'))
    or (select private.has_permission(tenant_id, 'stock.adjust'))
    or (select private.has_permission(tenant_id, 'products.manage')))
  with check ((select private.has_permission(tenant_id, 'purchases.create'))
    or (select private.has_permission(tenant_id, 'stock.adjust'))
    or (select private.has_permission(tenant_id, 'products.manage')));

create policy stock_movements_insert on public.stock_movements
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(
      tenant_id, private.stock_movement_permission(reason))));

create policy purchases_insert on public.purchases
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'purchases.create')));
create policy purchases_update on public.purchases
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));
create policy purchase_lines_insert on public.purchase_lines
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'purchases.create')));

create policy purchase_returns_insert on public.purchase_returns
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'purchases.create')));
create policy purchase_returns_update on public.purchase_returns
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));
create policy purchase_return_lines_insert on public.purchase_return_lines
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'purchases.create')));

create policy shop_sales_insert on public.shop_sales
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'sales.create')));
create policy shop_sales_update on public.shop_sales
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));
create policy shop_sale_lines_insert on public.shop_sale_lines
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'sales.create')));

create policy shop_returns_insert on public.shop_returns
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'sales.return')));
create policy shop_returns_update on public.shop_returns
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));
create policy shop_return_lines_insert on public.shop_return_lines
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'sales.return')));

revoke all on public.product_categories, public.products, public.batches,
  public.stock_movements, public.purchases, public.purchase_lines,
  public.purchase_returns, public.purchase_return_lines, public.shop_sales,
  public.shop_sale_lines, public.shop_returns, public.shop_return_lines from anon;
revoke delete, truncate on public.product_categories, public.products, public.batches,
  public.purchases, public.purchase_returns, public.shop_sales, public.shop_returns
  from authenticated;
revoke update, delete, truncate on public.stock_movements, public.purchase_lines,
  public.purchase_return_lines, public.shop_sale_lines, public.shop_return_lines
  from authenticated;

-- ---------------------------------------------------------------------------
-- Chart of accounts: stock, COGS, GST, round off
-- ---------------------------------------------------------------------------

-- Unchanged; repeated so the groups and the accounts seed live together.
create or replace function private.seed_chart_groups(p_tenant uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  insert into public.account_groups (id, tenant_id, code, name, parent_id, nature, is_system)
  select private.chart_id(p_tenant, 'group', g.code), p_tenant, g.code, g.name,
         case when g.parent is null then null
              else private.chart_id(p_tenant, 'group', g.parent) end,
         g.nature, true
  from (values
    ('capital',             'Capital Account',          null,                  'liability'),
    ('current_assets',      'Current Assets',           null,                  'asset'),
    ('sundry_debtors',      'Sundry Debtors',           'current_assets',      'asset'),
    ('cash_in_hand',        'Cash-in-hand',             'current_assets',      'asset'),
    ('bank_accounts',       'Bank Accounts',            'current_assets',      'asset'),
    ('stock_in_hand',       'Stock-in-hand',            'current_assets',      'asset'),
    ('loans_and_advances',  'Loans & Advances (Asset)', 'current_assets',      'asset'),
    ('current_liabilities', 'Current Liabilities',      null,                  'liability'),
    ('sundry_creditors',    'Sundry Creditors',         'current_liabilities', 'liability'),
    ('duties_and_taxes',    'Duties & Taxes',           'current_liabilities', 'liability'),
    ('direct_income',       'Direct Income',            null,                  'income'),
    ('indirect_income',     'Indirect Income',          null,                  'income'),
    ('direct_expenses',     'Direct Expenses',          null,                  'expense'),
    ('indirect_expenses',   'Indirect Expenses',        null,                  'expense'),
    ('sales_accounts',      'Sales Accounts',           null,                  'income'),
    ('purchase_accounts',   'Purchase Accounts',        null,                  'expense')
  ) as g(code, name, parent, nature)
  order by (g.parent is not null)
  on conflict (tenant_id, code) do nothing;
end;
$$;

create or replace function private.seed_chart_accounts(p_tenant uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform private.seed_chart_groups(p_tenant);
  insert into public.accounts (id, tenant_id, group_id, name, system_code, is_system)
  select private.chart_id(p_tenant, 'account', a.code), p_tenant,
         private.chart_id(p_tenant, 'group', a.grp), a.name, a.code, true
  from (values
    ('commission_income',      'Commission Income',      'direct_income'),
    ('palledari_receipts',     'Palledari Receipts',     'direct_income'),
    ('bardana_receipts',       'Bardana Receipts',       'direct_income'),
    ('tulai_receipts',         'Tulai Receipts',         'direct_income'),
    ('interest_income',        'Interest Income',        'indirect_income'),
    ('mandi_fee_payable',      'Mandi Fee Payable',      'duties_and_taxes'),
    ('cess_payable',           'Cess Payable',           'duties_and_taxes'),
    ('mandi_fee_own_cost',     'Mandi Fee (own cost)',   'direct_expenses'),
    ('cess_own_cost',          'Cess (own cost)',        'direct_expenses'),
    ('interest_waived',        'Interest Waived',        'indirect_expenses'),
    ('lot_sale_clearing',      'Lot Sale Clearing',      'current_assets'),
    ('khata_adjustments',      'Khata Adjustments',      'current_liabilities'),
    ('opening_balance_equity', 'Opening Balance Equity', 'capital'),
    ('sales',                  'Sales',                  'sales_accounts'),
    ('purchase',               'Purchase',               'purchase_accounts'),
    ('capital',                'Capital',                'capital'),
    ('profit_and_loss',        'Profit & Loss A/c',      'capital'),
    ('cash_short_excess',      'Cash Short / Excess',    'indirect_expenses'),
    -- Phase 4
    ('stock_in_hand',          'Stock-in-Hand',          'stock_in_hand'),
    ('cost_of_goods_sold',     'Cost of Goods Sold',     'direct_expenses'),
    ('stock_adjustment',       'Stock Adjustment',       'direct_expenses'),
    ('gst_output_cgst',        'GST Output CGST',        'duties_and_taxes'),
    ('gst_output_sgst',        'GST Output SGST',        'duties_and_taxes'),
    ('gst_output_igst',        'GST Output IGST',        'duties_and_taxes'),
    ('gst_input_cgst',         'GST Input CGST',         'duties_and_taxes'),
    ('gst_input_sgst',         'GST Input SGST',         'duties_and_taxes'),
    ('gst_input_igst',         'GST Input IGST',         'duties_and_taxes'),
    ('round_off',              'Round Off',              'indirect_expenses')
  ) as a(code, name, grp)
  on conflict (id) do nothing;
end;
$$;

revoke execute on function private.seed_chart_groups(uuid), private.seed_chart_accounts(uuid)
  from public, anon, authenticated;

select private.seed_chart_accounts(id) from public.tenants;

-- ---------------------------------------------------------------------------
-- Journal: the shop's source types and who may post them
-- ---------------------------------------------------------------------------

alter table public.journal_entries drop constraint journal_entries_source_type_check;
alter table public.journal_entries add constraint journal_entries_source_type_check
  check (source_type in (
    'lot', 'payment', 'interest', 'waiver', 'entry', 'reversal', 'voucher', 'expense',
    'purchase', 'purchase_return', 'shop_sale', 'shop_return', 'stock_adjustment'
  ));

create or replace function private.journal_post_permission(p_source_type text)
returns text
language sql
immutable
set search_path = ''
as $$
  select case p_source_type
    when 'lot' then 'arrivals.manage'
    when 'payment' then 'payments.create'
    when 'expense' then 'payments.create'
    when 'interest' then 'loans.manage'
    when 'purchase' then 'purchases.create'
    when 'purchase_return' then 'purchases.create'
    when 'shop_sale' then 'sales.create'
    when 'shop_return' then 'sales.return'
    when 'stock_adjustment' then 'stock.adjust'
    else 'entries.reverse'
  end;
$$;

-- ---------------------------------------------------------------------------
-- Khata: the shop's ref types
-- ---------------------------------------------------------------------------

alter table public.ledger_entries drop constraint ledger_entries_ref_type_check;
alter table public.ledger_entries add constraint ledger_entries_ref_type_check
  check (ref_type in (
    'arrival', 'payment', 'receipt', 'shop_sale', 'shop_return', 'purchase',
    'purchase_return', 'loan_disbursal', 'loan_repayment', 'interest', 'expense',
    'journal', 'opening_balance', 'reversal', 'voucher'
  ));

create or replace function private.ledger_post_permission(
  p_ref_type text,
  p_replaces_id uuid
)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when p_replaces_id is not null
      or p_ref_type in ('reversal', 'journal', 'opening_balance', 'voucher')
      then 'entries.reverse'
    when p_ref_type = 'arrival' then 'arrivals.manage'
    when p_ref_type in ('payment', 'receipt', 'loan_repayment')
      then 'payments.create'
    when p_ref_type in ('loan_disbursal', 'interest') then 'loans.manage'
    when p_ref_type = 'shop_sale' then 'sales.create'
    when p_ref_type = 'shop_return' then 'sales.return'
    when p_ref_type in ('purchase', 'purchase_return') then 'purchases.create'
    else null
  end;
$$;

-- A shop khata entry points at its document and takes the right side:
-- sale = udhaar, sale return = jama, purchase = jama, purchase return =
-- udhaar; same party; never more than the document total. Reversals and
-- replacements are checked by the general guard.
create or replace function private.guard_ledger_shop_entry()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_party uuid;
  v_total bigint;
  v_side text;
begin
  if new.reverses_id is not null or new.replaces_id is not null
    or new.ref_type not in ('shop_sale', 'shop_return', 'purchase', 'purchase_return') then
    return new;
  end if;

  if new.ref_type = 'shop_sale' then
    select s.party_id, s.total_paise into v_party, v_total
    from public.shop_sales s where s.id = new.ref_id and s.tenant_id = new.tenant_id;
    v_side := 'udhaar';
  elsif new.ref_type = 'shop_return' then
    select r.party_id, r.total_paise into v_party, v_total
    from public.shop_returns r where r.id = new.ref_id and r.tenant_id = new.tenant_id;
    v_side := 'jama';
  elsif new.ref_type = 'purchase' then
    select p.party_id, p.total_paise into v_party, v_total
    from public.purchases p where p.id = new.ref_id and p.tenant_id = new.tenant_id;
    v_side := 'jama';
  else
    select r.party_id, r.total_paise into v_party, v_total
    from public.purchase_returns r where r.id = new.ref_id and r.tenant_id = new.tenant_id;
    v_side := 'udhaar';
  end if;

  if v_total is null or v_party is distinct from new.party_id
    or new.side <> v_side or new.amount_paise > v_total then
    raise exception 'a % entry must match its document', new.ref_type
      using errcode = '23514';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_ledger_shop_entry() from public, anon, authenticated;

create trigger ledger_entries_shop_guard before insert on public.ledger_entries
  for each row execute function private.guard_ledger_shop_entry();

-- ---------------------------------------------------------------------------
-- Cash / bank book: lines of the shop documents
-- ---------------------------------------------------------------------------

alter table public.cash_bank_entries add column purchase_id uuid;
alter table public.cash_bank_entries add column purchase_return_id uuid;
alter table public.cash_bank_entries add column shop_sale_id uuid;
alter table public.cash_bank_entries add column shop_return_id uuid;

alter table public.cash_bank_entries add constraint cash_bank_entries_purchase_fk
  foreign key (purchase_id, tenant_id) references public.purchases (id, tenant_id);
alter table public.cash_bank_entries add constraint cash_bank_entries_purchase_return_fk
  foreign key (purchase_return_id, tenant_id)
  references public.purchase_returns (id, tenant_id);
alter table public.cash_bank_entries add constraint cash_bank_entries_shop_sale_fk
  foreign key (shop_sale_id, tenant_id) references public.shop_sales (id, tenant_id);
alter table public.cash_bank_entries add constraint cash_bank_entries_shop_return_fk
  foreign key (shop_return_id, tenant_id) references public.shop_returns (id, tenant_id);

alter table public.cash_bank_entries drop constraint cash_bank_entries_one_source;
alter table public.cash_bank_entries add constraint cash_bank_entries_one_source
  check (num_nonnulls(payment_id, voucher_id, expense_id, purchase_id, purchase_return_id,
    shop_sale_id, shop_return_id) = 1);

create index cash_bank_entries_purchase_idx on public.cash_bank_entries (purchase_id, tenant_id)
  where purchase_id is not null;
create index cash_bank_entries_purchase_return_idx
  on public.cash_bank_entries (purchase_return_id, tenant_id)
  where purchase_return_id is not null;
create index cash_bank_entries_shop_sale_idx on public.cash_bank_entries (shop_sale_id, tenant_id)
  where shop_sale_id is not null;
create index cash_bank_entries_shop_return_idx
  on public.cash_bank_entries (shop_return_id, tenant_id)
  where shop_return_id is not null;

-- As in expenses, plus: the shop documents' lines mirror correctly and need
-- the shop permission of their document. A UPI sale by a munshi may land in a
-- bank account without finance.view.
create or replace function private.guard_cash_bank_entry()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_kind text;
  v_original public.cash_bank_entries;
  v_needs text;
begin
  v_kind := private.account_kind(new.tenant_id, new.account_id);
  if v_kind is not null and v_kind <> new.account_kind then
    raise exception 'account_kind does not match the account' using errcode = '23514';
  end if;

  if new.reverses_id is not null then
    select * into v_original from public.cash_bank_entries e
    where e.id = new.reverses_id and e.tenant_id = new.tenant_id;
    if found and (
      v_original.reverses_id is not null
      or v_original.account_id <> new.account_id
      or v_original.payment_id is distinct from new.payment_id
      or v_original.voucher_id is distinct from new.voucher_id
      or v_original.expense_id is distinct from new.expense_id
      or v_original.purchase_id is distinct from new.purchase_id
      or v_original.purchase_return_id is distinct from new.purchase_return_id
      or v_original.shop_sale_id is distinct from new.shop_sale_id
      or v_original.shop_return_id is distinct from new.shop_return_id
      or v_original.direction = new.direction
      or v_original.amount_paise <> new.amount_paise
    ) then
      raise exception 'a reversal must mirror the line it reverses'
        using errcode = '23514';
    end if;
  end if;

  if (select auth.uid()) is not null then
    if not exists (
      select 1 from public.devices d
      where d.id = new.device_id and d.tenant_id = new.tenant_id
        and d.user_id = (select auth.uid()) and d.revoked_at is null
    ) then
      raise exception 'book lines must come from one of your devices in this business'
        using errcode = '42501';
    end if;
    if new.account_kind = 'bank' and new.shop_sale_id is null
      and not (select private.has_permission(new.tenant_id, 'finance.view')) then
      raise exception 'bank book lines need finance.view' using errcode = '42501';
    end if;
    v_needs := case
      when new.reverses_id is not null or new.voucher_id is not null then 'entries.reverse'
      when new.shop_sale_id is not null then 'sales.create'
      when new.shop_return_id is not null then 'sales.return'
      when new.purchase_id is not null or new.purchase_return_id is not null
        then 'purchases.create'
      else 'payments.create'
    end;
    if not (select private.has_permission(new.tenant_id, v_needs)) then
      raise exception 'this book line needs %', v_needs using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Sync
-- ---------------------------------------------------------------------------

alter publication powersync add table public.product_categories, public.products,
  public.batches, public.stock_movements, public.purchases, public.purchase_lines,
  public.purchase_returns, public.purchase_return_lines, public.shop_sales,
  public.shop_sale_lines, public.shop_returns, public.shop_return_lines;
