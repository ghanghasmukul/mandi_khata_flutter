# Ledger, mandi arrival and shop — business rules

## Ledger (khata)

- One ledger per party per tenant. Table `ledger_entries`:
  `id, tenant_id, party_id, entry_date, side ('udhaar'|'jama'), amount_paise (>0), ref_type, ref_id, narration, reverses_id, replaces_id, device_id, created_by, created_at, received_at`.
  - `created_at` = when recorded on the device; `received_at` = when the server got it (set by the server).
  - "Reversed by" is not stored (that would be an update); it is derived from the reversal's `reverses_id`.
- `ref_type` ∈ `arrival | payment | receipt | shop_sale | shop_return | purchase | loan_disbursal | loan_repayment | interest | expense | journal | opening_balance | reversal`.
- **Balance** = Σ jama − Σ udhaar. Positive → "we owe" (green, Jama). Negative → "party owes" (red, Udhaar).
- **Statement order** (same on every device): `entry_date`, then `created_at`, then `id`.
- **Append-only.** No update or delete, ever (not even by the service role). Edit = reversal entry (`ref_type=reversal`, opposite side, same amount and party, `reverses_id`) + new entry (`replaces_id` = the original), posted in one transaction. UI shows the reversed pair struck-through; the audit log shows before → after.
  - A reversal is dated like the original (so balances on past dates are corrected) unless the event has its own date (bounced cheque → the bounce date).
  - An entry is reversed at most once (unique `reverses_id`, so two devices reversing offline cannot both succeed). A reversal is never reversed; post a new entry instead.
- **Who may post** (server policy + app check, khata_core `LedgerPosting`):
  - reversal, correction (`replaces_id`), journal, opening balance → `entries.reverse`
  - arrival → `arrivals.manage`
  - payment, receipt, loan repayment → `payments.create`
  - loan disbursal, interest → `loans.manage`
  - shop sale / return, purchase, expense → any active member (until phases 3–4 add their permissions)
- **Uploads are all-or-nothing per local transaction** (`apply_crud_transaction`): a document and its ledger entries, or a reversal and its replacement, reach the server together or not at all.
- **Opening balance** per party when onboarding a tenant (`ref_type=opening_balance`, dated FY start or go-live date).
- **Every business document posts to the khata in the same local transaction** as the document itself. Never "post later".

## One party, many roles

- `parties` + `party_roles(party_id, role)` where role ∈ `farmer | customer | supplier | vendor | agency | buyer`.
- A party has ONE khata. Shop credit sales, crop sales, payments, purchases from them — all in the same ledger.
- **Net position = khata balance.** Do NOT add shop dues or purchase payables on top of the khata balance — they are already inside it. (*Bug in prototype:* Parties screen double-counted shop dues.) Breakdown views (by ref_type) are fine; totals must come from the ledger only.

## Mandi arrival → sale → settlement

Flow: **Arrival (aamad) → Weigh → Auction/sale & rate → Arhat + charges → Net to khata**.

Per lot:
```
gross        = round(qtl × rate_per_qtl)                  // paise
commission   = round(gross × commission_pct / 100)
palledari    = bags × palledari_per_bag
bardana      = bags × bardana_per_bag
tulai        = round(qtl × tulai_per_qtl)
mandi_fee    = round(gross × mandi_fee_pct / 100)
cess_i       = round(gross × cess_i_pct / 100)
farmer_deductions = Σ charges where charges_borne_by = farmer (+ commission)
net_to_farmer     = gross − farmer_deductions
```
- All rates/charges come from the settings cascade (crop-level overrides allowed) and are **snapshotted** into the lot row.
- Posting a sold lot creates: `jama` entry to farmer for `net_to_farmer`; `udhaar` entry to the buyer (if buyer ledger enabled) for gross + buyer-borne charges; income lines for commission.
- Qtl can be entered directly or computed from bags × bag weight; show both.
- Lot states: `arrived → weighed → sold → posted → (reversed)`.

## Payments

- Modes: cash, bank (NEFT/RTGS/IMPS), UPI, cheque (with cheque no, date, status: pending/cleared/bounced).
- Payment TO party (bhugtaan) → `udhaar` on party + credit cash/bank book.
- Receipt FROM party → `jama` on party + debit cash/bank book.
- Bounced cheque → reversal entry automatically.
- Receipt PDF + optional WhatsApp share.

## Karza (loans)

- A loan is a document with its own interest config snapshot, due date, purpose, guarantor (optional).
- Disbursal posts `udhaar` to party khata (`ref_type=loan_disbursal`, `ref_id=loan.id`).
- Repayments post `jama` with `ref_type=loan_repayment`. Crop proceeds can be adjusted against a loan (a jama that is marked as loan repayment).
- Two modes (tenant setting `interest.apply_on`): interest on **whole net khata** (common in mandis) OR **per loan only**. Never both on the same money.

## Input shop

- Products with batches (batch no, mfg, expiry, qty). Stock = Σ batch qty. FEFO (first-expiry-first-out) when selling.
- Purchase entry: supplier invoice → stock in (batch) → `jama` to supplier khata for unpaid amount.
- Sale (POS): price from tier; discount; payment cash/UPI/udhaar. Udhaar → `udhaar` entry on party khata.
- Returns: sales return restores stock to the original batch and posts a reversal/credit.
- COGS at batch cost. Shop profit = sales − COGS.
- GST: HSN, rate, CGST/SGST/IGST split on invoice when `shop.gst_enabled`.

## Roles & permissions (defaults; editable per tenant)

| Permission | Key | Owner | Accountant | Munshi |
|---|---|---|---|---|
| View/add parties | `parties.manage` | ✓ | ✓ | ✓ |
| Arrivals, lots | `arrivals.manage` | ✓ | ✓ | ✓ |
| Payments (create) | `payments.create` | ✓ | ✓ | ✓ (limit configurable) |
| Edit / reverse past entries | `entries.reverse` | ✓ | ✓ | ✗ |
| Issue karza, change interest | `loans.manage` | ✓ | ✗ | ✗ |
| Bank details, profit, reports export | `finance.view` | ✓ | ✓ | ✗ |
| Modules, users, subscription | `admin.manage` | ✓ | ✗ | ✗ |
| Delete master data | `master.delete` | ✓ | ✗ | ✗ |
| Business-wide settings (tenant / party-group scope) | `settings.manage` | ✓ | ✗ | ✗ |
| View the audit log | `audit.view` | ✓ | ✗ | ✗ |

- The key is what `tenant_members.custom_permissions` and the SQL `private.has_permission()` use. `custom_permissions` is `{"<key>": true|false}` and overrides the role default for that member; a `custom` role starts with nothing.
- Owners always have every permission (custom entries cannot lock an owner out), and a business must keep at least one active owner.
- Settings: `interest.*` keys need `loans.manage` at every scope; other keys need `settings.manage` at tenant / party-group scope and only membership at party / document scope.
