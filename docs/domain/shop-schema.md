# Shop schema (Phase 4)

Migration `20261007164200_phase4_input_shop.sql`. Rules and maths: `shop-rules.md`; postings: `posting-rules.md` section 12. Quantities are milli-units (1000 = 1 unit), money is paise, rates are `numeric(5,2)` percent. Every table has `tenant_id`, client UUID ids, composite `(x, tenant_id)` foreign keys, and `created_by / created_at` (+ `updated_at` on masters and headers).

## Tables

| Table | Kind | Key columns |
|---|---|---|
| `product_categories` | master (`deleted_at`) | name, sort_order, is_active |
| `products` | master (`deleted_at`) | sku (unique per tenant), barcode (unique when set), name, brand, category_id, unit (bag/btl/ltr/kg/pkt/pc), pack_size, hsn, gst_rate, reorder_level_milli, prices jsonb `{tier: paise}`, is_active |
| `batches` | master-like | product_id, batch_no (unique per product), mfg_date, expiry_date, cost_paise, **qty_milli = cache** |
| `stock_movements` | append-only | product_id, batch_id (null only for negative-stock sales), entry_date, qty_milli (signed, never 0), reason (purchase / sale / sale_return / purchase_return / adjustment / opening), ref_type, ref_id, note (required for adjustment), device_id, received_at (server) |
| `purchases` | header, frozen | purchase_no (PB-), party_id (supplier), supplier_invoice_no, invoice_date, entry_date, freight / other_charges / taxable / gst / round_off / total, paid_paise + payment_mode + bank_account_id, credit_days, due_date, status |
| `purchase_lines` | append-only | purchase_id, line_no, product_id, batch_id, batch_no, mfg, expiry, qty_milli, cost_paise, gst_rate, taxable, gst, line_total |
| `purchase_returns` / `purchase_return_lines` | header, frozen / append-only | purchase_id, party_id, taxable / gst / round_off / total, refund_khata_paise + refund_paid_paise (+ payment_mode, bank_account_id); lines point at `purchase_line_id` and its batch |
| `shop_sales` | header, frozen | sale_no (SI-), party_id (null = walk-in), customer_name / customer_gstin / place_of_supply snapshots, tier, subtotal, discount, invoice_discount_pct / paise, taxable, cgst, sgst, igst, round_off, total, paid_cash / paid_upi / paid_credit, upi_account_id, status |
| `shop_sale_lines` | append-only | sale_id, line_no, product_id, batch_id (null = uncovered negative stock), qty_milli, unit_price_paise, tier, discount, taxable, gst_rate, cgst / sgst / igst, line_total, hsn snapshot, cost_paise snapshot (COGS) |
| `shop_returns` / `shop_return_lines` | header, frozen / append-only | sale_id, party_id, return_no (SR-), taxable / cgst / sgst / igst / round_off / total, refund_mode (khata/cash/upi/auto) + refund_khata / refund_cash / refund_upi paise (sum = total), bank_account_id; lines: sale_line_id, batch_id = the sold batch, qty, amount |

Hold bills are **local only** (`held_bills` in the PowerSync local schema: id, tenant_id, device_id, payload JSON, created_at). No server table; wiped by `disconnectAndClear` with the rest.

## Truth versus cache

- **Truth:** `stock_movements` (Σ qty_milli per batch / product) and the posted documents.
- **Cache:** `batches.qty_milli`. A trigger adds each movement; a client cannot set it (forced to 0 on insert, kept on update). `public.rebuild_batch_qty(tenant)` recomputes it from the movements (needs `stock.adjust`). A product's stock is always Σ of its movements (or of its batches' cache). pgTAP proves `batch.qty = Σ movements`.
- Documents are never edited: headers change only `status` / `reversed_at` (`entries.reverse`), lines are append-only and may only be inserted in the **same transaction as their header** (write header and lines together, document first, then batches/movements/khata/book/journal). A header needs at least one line by the end of the upload. Returns must point at lines of the original document, restock / return the same batch, and never exceed the original quantity.
- Server arithmetic checks only: `total = taxable + tax + charges + round_off`, `cash + upi + udhaar = total` (udhaar needs a party), refund parts = total, line total = taxable + tax. Whether the journal / khata match the document is the app's job (`khata_core`).

## Ref and source types

- `ledger_entries.ref_type` adds `purchase_return`. Shop entries must point (`ref_id`) at a real document of the same party, on the right side (sale = udhaar, sale return = jama, purchase = jama, purchase return = udhaar) and not exceed its total; checked on insert for non-reversal entries.
- `journal_entries.source_type` adds `purchase`, `purchase_return`, `shop_sale`, `shop_return`, `stock_adjustment` (`stock_adjustment:<id>` where id is the client adjustment id shared by its movements; opening stock too).
- `stock_movements.ref_type`: purchase, purchase_return, shop_sale, shop_return, stock_adjustment, opening.
- `cash_bank_entries` gets `purchase_id`, `purchase_return_id`, `shop_sale_id`, `shop_return_id` (exactly one source per line, as for payments / vouchers / expenses). A book line of a shop sale in a bank account (UPI) does not need `finance.view`.
- New system accounts (UUID v5 like all chart rows): `stock_in_hand`, `cost_of_goods_sold`, `stock_adjustment`, `round_off`, `gst_output_cgst / sgst / igst`, `gst_input_cgst / sgst / igst`. `sales` and `purchase` already exist.

## Permissions

| Key | Needed for | Default |
|---|---|---|
| `products.manage` | categories, products, batches | owner, accountant |
| `purchases.create` | purchases, purchase returns, their lines / movements / khata / journal / book lines; reading purchases (with `finance.view`) | owner, accountant |
| `sales.create` | shop_sales(+lines), `sale` movements, shop_sale khata / journal / book lines | owner, accountant, munshi |
| `sales.return` | shop_returns(+lines), `sale_return` movements, shop_return khata / journal / book lines | owner, accountant |
| `stock.adjust` | `adjustment` / `opening` movements, `stock_adjustment` journal, `rebuild_batch_qty` | owner, accountant |
| `shop.view_profit` | UI only: cost prices and profit (cost sits in the synced rows, see below) | owner, accountant |

Reversing any shop document needs `entries.reverse`; back-dating beyond `business.backdate_days` also; deleting products / categories (`deleted_at`) needs `master.delete`. The module switch `shop.enabled` is **not** enforced in SQL (permission only); the app hides the module.

## Sync

- `tenant_data` (all members, the counter works offline): product_categories, products, batches, stock_movements, shop_sales, shop_sale_lines, shop_returns, shop_return_lines. Sale lines and batches carry cost, so `shop.view_profit` is enforced in the UI only.
- `finance_data` (owner / accountant by default role): purchases, purchase_lines, purchase_returns, purchase_return_lines. RLS lets `finance.view` / `purchases.create` holders (and the author) read them.
