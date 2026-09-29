# Phase 4 — Input shop (fertiliser, seed, pesticide)

**Goal:** the same business runs its agri-input counter in the same app: products with batch & expiry, purchases from agencies, fast POS with price tiers, credit sales to farmers' khata, returns, payables/receivables, GST invoices and shop profit. Sold as an add-on module.

Read first: `docs/domain/ledger-and-mandi.md` (Input shop + One party many roles), `docs/domain/posting-rules.md` (from Phase 3).

---

## Step 4.1 — Products, batches, stock

**Prompt**
```
Tables: product_categories, products (id, tenant_id, sku, barcode, name, brand, category_id, unit (bag/btl/ltr/kg/pkt/pc), pack_size, hsn, gst_rate, reorder_level, prices jsonb {tier: paise} for the tenant's price tiers, is_active), batches (id, product_id, batch_no, mfg_date, expiry_date nullable, cost_paise, qty_milli), stock_movements (id, tenant_id, product_id, batch_id, entry_date, qty_milli ±, reason: purchase|sale|sale_return|purchase_return|adjustment|opening, ref_type, ref_id). Stock = Σ movements (never a mutable qty column as truth; batch qty is a cached projection rebuilt from movements).
Products & stock screen like the prototype: stock value at cost, low stock, out of stock, expiring/expired counts; table with batches, cost, tier prices, margin %, stock, value; filters; stock adjustment (reason required, audited).
Opening stock import from XLSX.
```

## Step 4.2 — Purchases

**Prompt**
```
Purchase entry: supplier (party with supplier/agency role), supplier invoice no & date, lines (product, batch no, mfg, expiry, qty, cost, GST), freight/other charges, amount paid now (mode) → in one transaction: purchase row + lines, stock movements (new/existing batch), supplier khata jama for unpaid amount, journal lines, audit.
Purchase list, detail, purchase return (to original batch).
Supplier credit terms (e.g. 30 days) → due dates in payables.
```

## Step 4.3 — POS (counter sale)

**Prompt**
```
POS screen like the prototype, keyboard-first on desktop (Windows/macOS):
- Barcode scan (USB scanner = keyboard wedge; Android camera via mobile_scanner) or type-to-search; product grid with stock left.
- Price tier toggle (Farmer / Retail / Vendor / Wholesale); default tier from the customer's role (setting).
- Cart: qty +/-, line discount, invoice discount %, GST breakdown, total.
- Payment: Cash / UPI / Udhaar (udhaar requires a party; posts to their khata) / split payment.
- FEFO batch picking automatically; warn on expired batch (block if setting says so); block negative stock unless allowed.
- Save → invoice no SI-<device>-n, print (A5 GST invoice or 80mm thermal), share PDF on WhatsApp.
- Hold/recall bills; F2 new bill, F10 pay.
```

## Step 4.4 — Shop sales, returns, receivables & payables

**Prompt**
```
Shop sales list (party, items, tier, total, outstanding) with invoice view and sales return (select lines/qty, restocks the original batch, posts credit to party khata or refunds cash).
Payables & receivables screen: supplier payables (outstanding, due date, overdue) with "Pay" → payment voucher; customer receivables from the SHOP portion with "Collect" → receipt.
IMPORTANT: net party position comes from the single khata; this screen only shows breakdowns by ref_type (see docs/domain/ledger-and-mandi.md "One party, many roles"). Add a test proving no double counting.
```

## Step 4.5 — Shop profit & GST

**Prompt**
```
Shop profit by product (sold qty, revenue, COGS at batch cost, profit, margin), by category, by month.
GST: tenant GSTIN & state code, B2B/B2C invoices, CGST/SGST vs IGST by place of supply, HSN summary, GSTR-1 style export (XLSX/JSON) for the period. Flag missing HSN/GST rates.
Expiry report and reorder report (suggested purchase qty).
```

## Phase 4 exit criteria

- [ ] Stock on screen = Σ stock movements for every product/batch.
- [ ] A farmer who sold wheat and bought urea on credit has ONE correct net balance.
- [ ] POS bill (5 items, udhaar) takes < 20 seconds with keyboard only.
- [ ] GST invoice validated by a CA on 5 sample bills.
