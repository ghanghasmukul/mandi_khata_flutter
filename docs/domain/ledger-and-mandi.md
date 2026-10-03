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
  - **Back-dating** (any ref type): an entry whose `entry_date` is more than `business.backdate_days` (default 3) days before the day it was recorded, or after it, also needs `entries.reverse`. "Recorded" is the device's day (`created_at` in Asia/Kolkata), so an entry made today offline and synced next week is not back-dated. The server also rejects a `created_at` more than a day ahead of its own clock. (khata_core `LedgerPosting.requiredPermissions`, SQL `private.ledger_date_restricted`.)
  - A **manual khata entry** (Ctrl/⌘ K → "Khata entry") is a `journal` entry, so it needs `entries.reverse` (Accountant / Owner). Editing it = reversal + replacement; entries posted by a document (lot, payment…) are corrected through that document, not edited in the khata.
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
- Every rounding is **half-up to the paisa, each line on its own** (gross first, then each percentage of the rounded gross). Weight is `qtl_milli` (1/1000 qtl), so `qtl × rate` is exact integer maths.
- Every charge line is always listed (zero lines too); each cess in `mandi.cess` is its own line and follows the `cess` payer.
- Who pays (`mandi.charges_borne_by`): **farmer** → deducted from net; **buyer** → added to the buyer's udhaar (`buyer_total = gross + buyer-borne charges`); **arhtiya** → the arhtiya's own cost. Commission "borne by arhtiya" means **waived**: shown, but neither deducted, billed, earned nor counted as a cost.
- Implemented in khata_core `MandiCharges.calculate(LotInput, MandiConfig)`; `MandiConfig.resolve(settings, cropCode, partyId, lotId)` resolves every `mandi.*` key and `toJson()` is the snapshot.
- All rates/charges come from the settings cascade (crop-level overrides allowed) and are **snapshotted** into the lot row.
- Posting a lot creates, in ONE local transaction with the lot row and audit rows (`ref_type=arrival`, `ref_id=lot.id`, narration = lot number, dated like the lot):
  - `jama` to the farmer for `net_to_farmer` (must be > 0, else posting is refused);
  - `udhaar` to the buyer for `gross + buyer-borne charges`, when a buyer is picked. **A buyer is required** when any buyer-borne charge is above zero.
  - Commission income is not a khata entry: it stays on the lot (`lots.commission` = commission earned, zero when waived) until the chart of accounts (phase 3) posts it.
- Qtl can be entered directly or computed from bags × `mandi.bag_weight_kg` (`qtl_from_bags`); show both.
- Lot states: `arrived → weighed → sold → posted → (reversed)`. Rules (khata_core `LotStatus` / `LotRules`, server trigger `private.guard_lot`):
  - An **open** lot (arrived / weighed / sold) is edited freely (`arrivals.manage`); its status follows what is filled in (no weight → arrived, weight → weighed, weight + rate → sold).
  - At the counter, **Save posts the lot as soon as it has weight and rate** (status → posted). "Hold" keeps a complete lot as sold. The gate wizard (munshi, phone) saves farmer + crop + bags as arrived.
  - A **posted** lot is frozen. It can only be **reversed** (`entries.reverse`): every entry it posted is reversed (same date) and the lot becomes `reversed`, in one transaction. A correct lot is then entered again as a new lot ("Enter again" copies it).
  - An open lot that never happened is **cancelled** (`arrivals.manage`): status `reversed` with `posted_at` null; nothing was posted. `reversed` is final.
  - Lot numbers `L-<device>-<n>` come from the `lot` number series when the lot is first saved and never change. Lots are never deleted.

### Table `lots`
`id, tenant_id, lot_no (unique per tenant), entry_date, farmer_id, crop_id, bags, qtl_milli (1/1000 qtl), qtl_from_bags, rate_paise_per_qtl, buyer_party_id, j_form_no, vehicle_no, notes, status, charges_snapshot (MandiConfig.toJson), gross, commission (earned), net_to_farmer, buyer_total, posted_at, device_id, created_by, created_at, updated_at`. Money in paise. A posted lot must have weight, rate, snapshot and amounts (check constraints); the farmer, buyer and crop must be in the same business (composite FKs).

## Crops master

- Table `crops` per tenant: `code, name_en, name_hi, name_pa, unit ('qtl'), msp_or_std_rate (paise per unit, nullable), sort_order, is_active`.
- `code` is the suffix of per-crop settings (`mandi.commission_pct.<code>`): lowercase identifier (`^[a-z][a-z0-9_]*$`, ≤ 24), unique per business, **never changes**. Ids are UUID v5 of `<tenant>|<code>`.
- Crops are switched off (`is_active`), never deleted. Adding / editing needs `settings.manage`.
- Every new business is seeded with: wheat, paddy_pr126, paddy_1509, paddy_1121, mustard, cotton_narma, guar, bajra, moong, chana, maize. `msp_or_std_rate` is a reference only (pre-fill / sample); a lot's rate is entered per lot.

## Payments

- Modes: cash, bank (NEFT/RTGS/IMPS), UPI, cheque (with cheque no, date, status: pending/cleared/bounced).
- Payment TO party (bhugtaan, `direction=to_party`) → `udhaar` on the party (`ref_type=payment`) + a money-out line in the cash / bank book. Numbered `V-<device>-<n>` (voucher series).
- Receipt FROM party (`direction=from_party`) → `jama` on the party (`ref_type=receipt`) + a money-in line. Numbered `R-<device>-<n>` (receipt series).
- One local transaction writes the `payments` row, the khata entry, the book line (`cash_bank_entries`) and the audit rows; they upload together.
- **Accounts** (`bank_accounts`): every business has one `Cash` account (seeded, fixed id, never switched off) and any number of bank accounts (name, bank, last 4 digits of the number, IFSC). Cash payments use the Cash account; bank, UPI and cheque use a bank account. Only members with `finance.view` see or add bank accounts, post to them, or record non-cash payments; a munshi pays and receives in **cash only**. Bank accounts and their book lines sync only to owners and accountants.
- **Cash / bank book** (`cash_bank_entries`): append-only, one line per payment (`in` for receipts, `out` for payments) and one mirrored line per reversal (`reverses_id`, reversed once). Account book balance = Σ in − Σ out. Phase 3 replaces this with the full cash / bank book.
- **Payment limit** (`business.munshi_payment_limit`, paise, default 0 = none): a payment TO a party above it needs `entries.reverse` (accountant / owner), in the app and in RLS (on the payment row and on the khata entry). Receipts are never limited. Back-dating follows `business.backdate_days` like every entry.
- **Cheques**: a pending cheque posts at once (khata entry and book line). `pending → cleared` needs `payments.create` and changes no money. `pending → bounced` needs `entries.reverse`: the khata entry and the book line are reversed together, **dated the bounce date**, and the payment is marked reversed. Cleared and bounced are final.
- **Reversing a payment** (entered by mistake) needs `entries.reverse`: same two reversals, dated like the payment; the payment row stays, marked `reversed` (never deleted, never edited otherwise). A posted payment is frozen: only `status`, `cheque_status` and `reversed_at` ever change (server trigger `private.guard_payment`).
- Receipt / voucher PDF: A5 or 80 mm / 58 mm thermal (`print.receipt_size`), in the business language (`app.default_language`), with the business name; shared on Android, printed on Windows and macOS. A receipt printed right after recording also shows the party's baki.

## Reports (v1)

- All from the local database; each filters by tenant and sums in SQL. Export (print, PDF, Excel, CSV) needs `finance.view`; **Commission earned** is closed to members without it.
- **Outstanding**: Σ jama − Σ udhaar per party up to the as-of day, non-zero only, split "we owe" / "they owe us". Ageing days = as-of day − the party's last entry date (either side): 0–30, 31–90, 91–180, over 180 (khata_core `Ageing`).
- **Arrival register**: lots in the period except reversed / cancelled; charges = gross − net to farmer (commission and the charges the farmer bears).
- **Commission**: posted lots per crop: lots, quintals, sale value, arhat earned.
- **Payment register**: posted payments and receipts by mode (cash, bank, UPI, cheque), received and paid in separate columns.
- **Party statements**: every farmer of a village (or all) as one PDF, one statement per page, same maths as the party khata.

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
