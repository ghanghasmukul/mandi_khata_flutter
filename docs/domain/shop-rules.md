# Shop rules (Phase 4: agri-input counter)

**Status: written before the code of phase 4 (2026-10-07), choices follow the recommendations; the owner may overrule any row.** Implemented in `packages/khata_core` (`stock_rules`, `shop_pricing`, `gst`, `sale_calc`, `purchase_rules`, `return_rules`, `shop_posting`, `shop_reports`). Posting rows are also in `posting-rules.md` section 12. A rule change goes here first, then code, then a line in `docs/decisions.md`.

## 1. Stock (perpetual inventory)

- **Stock = Σ `stock_movements.qty_milli`**, per product and per batch. A batch's `qty_milli` column and a product's total are caches rebuilt from movements; movements are append-only (a mistake is a new movement).
- **1 unit = 1000 milli** (a bag, bottle, litre, kg, packet or piece). Fractions (2.5 kg) are allowed to 3 decimals. Money for a quantity: `unit price × qty_milli / 1000`, rounded half-up to the paisa.
- Movement `reason` and sign: `purchase` +, `sale_return` +, `opening` + (all inbound, qty > 0); `sale` -, `purchase_return` - (outbound, qty < 0); `adjustment` either sign, never 0. `ref_type` / `ref_id` point at the document.
- **FEFO** (first-expiry-first-out) when selling: batches with stock are ordered by expiry date ascending, **batches without expiry last**, then oldest `created_at`. One cart line is filled from as many batches as needed (one `sale_lines` row and one movement per batch used).
- **Expired batch** (expiry date before today; expiry day itself is still sellable):
  - `shop.block_expired` = true (default): an expired batch is never picked; if only expired stock is left the sale line is refused ("expired stock").
  - false: expired batches are picked **last**, after all fresh ones, and the POS shows a warning for each.
- **Near expiry** = expiry within `shop.expiry_warn_days` (default 60) days from today: sellable, flagged amber. Batches expiring in 30 / 60 / 90 days are the buckets of the expiry report.
- **Negative stock**: `shop.allow_negative_stock` = false (default) refuses a line that cannot be fully covered by batches. True lets the sale go through with a warning; the uncovered quantity has no batch (its movement has `batch_id` null) and costs 0 until the next purchase is reconciled (owner adjusts). Never allowed to bypass the expired-batch block.
- **Stock status** of a product: out (total <= 0), low (total <= `reorder_level`, reorder_level > 0), expiring / expired (it has stock in a batch that is within the warn days / past expiry). The stock screen counts products per status.
- **Stock value at cost** = Σ over batches of `cost × qty_milli / 1000` (half-up per batch). **Margin %** of a tier price = (price - cost) / price, kept as integer basis points (2550 = 25.50%), shown with 2 decimals; nothing shown when price is 0.
- **Stock adjustment** (count difference, damage, expiry write-off): reason text required; movement `adjustment`; valued at the batch cost; needs `stock.adjust`; audited. Opening stock import uses reason `opening`.

## 2. Price tiers

- Tiers are the tenant's list `shop.price_tiers` (default `farmer, retail, vendor, wholesale`). A product stores `prices` = `{tier: paise per unit}`.
- **Default tier of a bill** comes from the customer's roles: for each role of the party, in the order **vendor, farmer, customer, buyer, supplier, agency**, the first role that has a mapping (`shop.default_tier_for_role.<role>`, defaults farmer -> farmer, vendor -> vendor, any other role -> the key's base default `retail`) decides. No party (walk-in) = `shop.default_tier` (default `retail`). A tier that is not in the tenant's list falls back to `shop.default_tier`, then to the first tier.
- The cashier can switch the tier for the bill. **Price lookup with fallback**: the product's price for the tier; if it has none, its price for `shop.default_tier`; then for `retail`; then the first tier in list order that has a price; if none, the product cannot be sold until a price is typed (manual price on the line is always allowed).

## 3. Discounts and rounding

- **Line discount**: an absolute amount in paise taken off the line (`unit price × qty`); not more than the line.
- **Invoice discount**: a percentage (basis points of the sum of line values after line discount), half-up to the paisa, or a fixed amount. It is **apportioned to the lines in proportion to their value after line discount, by the largest-remainder method** (floor of each share, leftover paise go to the lines with the largest fractional remainder, ties to the earlier line), so the shares add to the discount exactly. Taxes are computed on the line value after both discounts.
- **Round to the rupee** (`shop.round_invoice_to_rupee`, default true): the invoice total (after tax) is rounded half-up to the whole rupee; the difference (`round_off`, between -50 and +49 paise) is shown on the invoice and posted to the Round Off account. Returns do not round; the round-off of an invoice is refunded with its last returning line.

## 4. GST

- Settings: `shop.gst_enabled` (module level switch; false = no tax anywhere, all rates treated as 0), `shop.prices_include_gst` (default **true**: prices on the product are MRP-style, tax-inclusive; false = prices are before tax and tax is added), `shop.default_gst_rate` (default 5, used to prefill a product), `business.gstin`, `business.state_code`.
- A product has `hsn` (4, 6 or 8 digits) and `gst_rate` in {0, 0.25, 3, 5, 12, 18, 28} %. Anything else is invalid. **Missing HSN or missing / invalid rate is flagged** on the product, on the POS (warning) and in the GST report; a sale is not blocked.
- **Per line** (after discounts, line value `A`, rate `r`):
  - exclusive: taxable = `A`, tax = `round(A × r)`;
  - inclusive: taxable = `round(A × 10000 / (10000 + r_bp))`, tax = `A - taxable` (so the line total is exactly `A`).
  - Intra-state: CGST = `tax / 2` (floor), SGST = `tax - CGST`. Inter-state: IGST = tax.
  - The invoice tax is **the sum of its line taxes**.
- **Place of supply**: customer GSTIN's first two digits (state code); else the state code given for the customer; else the tenant's `business.state_code` (counter sale = intra-state). Inter-state when the place of supply differs from the tenant's state code. GSTIN is validated (15 characters, pattern and mod-36 check character).
- **B2B** = customer has a valid GSTIN; **B2C** otherwise. In GSTR-1: B2B per invoice; B2C inter-state invoices above `B2CL` threshold (Rs 1,00,000, a parameter; confirm with the CA) per invoice (B2CL); every other B2C grouped by state and rate (B2CS); sales returns = credit notes (CDNR for B2B, CDNUR for the rest); HSN summary; document summary (series, from, to, count).

## 5. Purchases

- A purchase has a supplier party (role supplier / agency / vendor), supplier invoice no and date, lines (product, batch no, mfg, expiry, qty, cost per unit, GST rate), optional freight and other charges, amount paid now (cash / bank), notes.
- Costs are entered **before tax** by default (supplier invoices show tax separately); the same inclusive / exclusive setting can be applied. Tax on the lines goes to GST Input (CGST + SGST, or IGST when the supplier's state differs). **Freight and other charges** are added to stock cost (no input credit taken on them); they are **spread over the lines in proportion to taxable value (largest remainder)**; the batch cost per unit = `(taxable + share) × 1000 / qty_milli`, half-up.
- Total = Σ taxable + Σ tax + freight + other + `round_off` (the signed paise that make it equal the supplier's printed total; 0 by default).
- **Paid now** (<= total) goes straight to cash / bank; the unpaid rest is the supplier's khata (`jama`, supplier is owed). **Due date** = invoice date + `shop.supplier_credit_days` (default 30; the supplier's own override later). Overdue = today after due date and unpaid part still open.
- **Purchase return** goes to the original batch only: quantity <= purchased - already returned, and <= what is still in that batch (cannot return what has been sold). Amounts are proportional to the original line (the last return of a line takes the exact remainder, so rounding never leaves a paisa behind).

## 6. Sales, payments, returns

- Sale: lines, tier, discounts, GST, payment split **cash + UPI + udhaar = total** (each >= 0). Udhaar needs a party; it posts to their khata. `business.credit_limit` over-limit is a **warning** (never blocks), same as the rest of the app.
- A sale is **frozen once saved**. Mistakes are fixed with a sales return (qty from the original lines), or an owner reversal of the whole invoice (`entries.reverse`, mirrors everything).
- **Sales return**: select lines and qty with qty <= sold - already returned (per sale line). The original batch is restocked (`sale_return` movement), COGS is reversed at the original batch cost. Refund amount = proportional taxable and tax of the line; the last return takes the remainder. **Settlement choice**: `khata` (credit the party's khata, `jama`, needs a party), `cash` (refund from cash / bank), or `auto`: credit khata up to the invoice's unpaid udhaar, the rest in cash.
- **No double counting**: payables and receivables are views by `ref_type` over the single khata; the net position of a party always comes from the ledger only.

## 7. Documents, numbers

| Document | Series (setting `business.number_series.<doc>`) | Prefix | Khata `ref_type` | Journal `source_type` |
|---|---|---|---|---|
| Sales invoice | `sales_invoice` | `SI-` | `shop_sale` (udhaar) | `shop_sale` |
| Sales return | `sales_return` | `SR-` | `shop_return` (jama) | `shop_return` |
| Purchase bill | `purchase_bill` | `PB-` | `purchase` (jama, supplier) | `purchase` |
| Purchase return | `purchase_return` | `PR-` | `purchase_return` (udhaar, supplier) | `purchase_return` |
| Stock adjustment / opening stock | none | | none | `stock_adjustment` |

Format `<prefix><deviceCode>-<counter>`, e.g. `SI-W1-0042`. Journal source key = `<source_type>:<document id>`.

## 8. Settings keys (all business level)

| Key | Type | Default |
|---|---|---|
| `app.modules.shop` (= "shop.enabled") | bool | true (per plan) |
| `shop.gst_enabled` | bool | true |
| `shop.prices_include_gst` | bool | true |
| `shop.price_tiers` | list | `[farmer, retail, vendor, wholesale]` |
| `shop.default_tier` | identifier | `retail` |
| `shop.default_tier_for_role.<role>` | identifier | farmer -> farmer, vendor -> vendor, others -> retail (this is the "tier by role" map) |
| `shop.block_expired` | bool | true |
| `shop.allow_negative_stock` | bool | false |
| `shop.expiry_warn_days` | int | **60** (was 180) |
| `shop.supplier_credit_days` | int | 30 |
| `shop.round_invoice_to_rupee` | bool | true |
| `shop.default_gst_rate` | choice % | `5` (`0, 0.25, 3, 5, 12, 18, 28`) |
| `shop.post_credit_sale_to_khata` | bool | true (existing) |
| `business.gstin` | text, "" or valid GSTIN | "" |
| `business.state_code` | text, "" or 2-digit GST state code | "" |

## 9. Permissions (keys; khata_core `Permission`)

| Permission | Key | Owner | Accountant | Munshi |
|---|---|---|---|---|
| Add / edit products, batches, categories, prices | `products.manage` | yes | yes | no |
| Purchases (create, purchase return) | `purchases.create` | yes | yes | no |
| Sell at the counter (POS) | `sales.create` | yes | yes | yes |
| Sales return | `sales.return` | yes | yes | no |
| Stock adjustment, opening stock | `stock.adjust` | yes | yes | no |
| See shop profit and cost prices | `shop.view_profit` | yes | yes | no |

SQL `private.role_allows()` must list exactly these (checked by `role_consistency_test`). Cost prices and profit are hidden from members without `shop.view_profit`.

## 10. System accounts added for the shop

| Code | Name | Group |
|---|---|---|
| `stock_in_hand` | Stock-in-Hand | Stock-in-hand |
| `cost_of_goods_sold` | Cost of Goods Sold | Direct Expenses |
| `stock_adjustment` | Stock Adjustment | Direct Expenses |
| `round_off` | Round Off | Indirect Expenses |
| `gst_output_cgst`, `gst_output_sgst`, `gst_output_igst` | GST Output CGST / SGST / IGST | Duties & Taxes |
| `gst_input_cgst`, `gst_input_sgst`, `gst_input_igst` | GST Input CGST / SGST / IGST | Duties & Taxes |

Existing `Sales` is used for shop sales. Input tax is an asset in nature but sits in Duties & Taxes (as in Tally); the balance sheet shows a debit balance on the asset side.
