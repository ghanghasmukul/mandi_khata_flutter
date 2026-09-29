# Phase 1 — Core Mandi Khata (MVP)

**Goal:** an arhtiya can run a mandi season on it: add farmers, record arrivals and lots, calculate arhat and charges, keep every farmer's khata, record payments, print receipts, and see a dashboard and basic reports — fully offline on all three platforms.

**Ships to:** 2–3 pilot arhtiyas.

Read first: `CLAUDE.md`, `docs/domain/ledger-and-mandi.md`, `docs/domain/settings-cascade.md`, `docs/domain/glossary.md`.

---

## Step 1.1 — Ledger core (khata_core + DB)

**Prompt**
```
Read docs/domain/ledger-and-mandi.md (Ledger section).
khata_core:
- LedgerEntry model, Side enum (udhaar/jama), RefType enum.
- LedgerCalculator: running balance, balance as of date, totals by ref_type, reversal pairing, statement rows with running baki.
- Reversal builder: given an entry, produce the reversal entry (opposite side, same amount, reverses_id).
- Unit tests incl. edits via reversal, same-day ordering (entry_date, created_at, id), opening balance.
Supabase: migration for ledger_entries (+ indexes on (tenant_id, party_id, entry_date)), RLS, a trigger that REJECTS update of amount/side/party_id/entry_date and rejects delete (append-only), pgTAP tests.
App: LedgerRepository (append, reverse, watchStatement(partyId, from, to), watchBalances()), sync rules, audit.
```

## Step 1.2 — Crops & mandi charge settings

**Prompt**
```
Crops master: code, name_en, name_hi, name_pa, unit (qtl), msp_or_std_rate (paise), is_active.
Seed defaults: Wheat, Paddy (PR-126, 1509, 1121), Mustard, Cotton (Narma), Guar, Bajra, Moong, Chana, Maize.
Crop settings screen: per-crop overrides for all `mandi.*` keys (commission %, palledari, bardana, tulai, mandi fee, cess list, charges_borne_by) using the settings cascade editor from Phase 0 — show inherited values.
khata_core: MandiCharges.calculate(lotInput, resolvedConfig) exactly per the formula in ledger-and-mandi.md, returning each line + net_to_farmer. Unit tests with worked examples (e.g. Wheat 18 bags, 8.64 qtl @ ₹2,425).
```

## Step 1.3 — Arrivals & lots

**Prompt**
```
Build the Transactions (Arrivals) feature.
Tables: lots (id, tenant_id, lot_no, entry_date, farmer_id, crop_id, bags, qtl_milli (int, 1/1000 qtl), rate_paise_per_qtl, buyer_party_id nullable, j_form_no, status arrived|weighed|sold|posted|reversed, charges_snapshot jsonb, gross, commission, net_to_farmer, vehicle_no, notes).
Flow UI (desktop): one keyboard-first screen: farmer search (type 3 letters) → crop → bags → qtl (or auto from bag weight) → rate → live breakdown panel (gross, arhat, each charge, net) → Save (F10) / Save & new.
Mobile (munshi at gate): a 3-step "New arrival" wizard (farmer, crop+bags, confirm) that saves status=arrived; the rate is added later at the counter.
Posting: when status becomes sold→posted, in ONE local transaction write the lot, the jama ledger entry to the farmer, optional buyer udhaar entry, audit rows.
List: filters by date, crop, farmer, status; totals row; lot detail with the full calculation and "Reverse lot" (permission-gated).
Number series L-<device>-n.
```

## Step 1.4 — Khata screens

**Prompt**
```
Build Khata:
1. "All entries" screen (day book style): date, party, description, udhaar, jama, running baki per party; filters date range / party / ref_type; virtualised list for 100k rows.
2. Party khata tab (inside party detail): statement with opening balance, entries, running baki, closing balance; date range; print/PDF; share.
3. Manual khata entry dialog (Ctrl+K → "khata entry"): party, date, udhaar/jama, amount, narration. Permission: back-dated entries older than N days (setting) need Accountant/Owner.
4. Edit = reverse + re-enter, with a clear UI showing the struck-through original.
5. Farmers list shows live balance chip: "Jama · we owe" green / "Udhaar · farmer owes" red.
Balances must come ONLY from the ledger (never add shop dues etc. separately).
```

## Step 1.5 — Payments & receipts

**Prompt**
```
Payments feature per docs/domain/ledger-and-mandi.md (Payments).
Tables: payments (id, tenant_id, receipt_no, entry_date, party_id, direction: to_party|from_party, mode: cash|bank|upi|cheque, reference, cheque_no, cheque_date, cheque_status, bank_account_id, amount, narration), bank_accounts (tenant's own accounts + a 'Cash' account).
Posting in one transaction: payment row + ledger entry on party + cash/bank book line (simple cash_bank_entries table for now; full accounting in Phase 3).
UI: Record payment dialog showing party's current baki and "after this payment" baki; quick amounts ("Full baki"); cheque status change (bounce → auto reversal).
Receipt PDF (A5 and 80mm thermal layouts) in the tenant's language with business header; share sheet on Android; print on Windows and macOS.
```

## Step 1.6 — Dashboard

**Prompt**
```
Dashboard matching design/Mandi_Khata.html:
- Hero: business name, date, "5 lots in today · ₹7,230 arhat earned", tiles "We owe farmers" and "Others owe us".
- Quick actions (permission & module aware): Add farmer, New arrival, Khata entry, Record payment.
- Stat tiles: lots in today (+qtl), arhat earned today, paid out today, receipts today.
- Chart: arhat earned last 10 days (fl_chart bar chart).
- Crop mix by sale value (this season).
- "Where the money is": farmer khata payable vs receivable.
- "Needs you today": sync errors, cheques due, large edits by munshi (from audit), parties over credit limit.
All numbers computed from the local DB via reactive providers.
```

## Step 1.7 — Reports v1 + export

**Prompt**
```
Reports (each: filters, on-screen table, PDF and Excel (.xlsx via `excel` package) and CSV export, permission 'export'):
1. Outstanding / baki by party (payable vs receivable, ageing buckets 0–30/31–90/91–180/180+ by last jama/udhaar date).
2. Arrival register (lot-wise gross, charges, net).
3. Commission earned (crop-wise volume, sale value, arhat).
4. Payment register (mode-wise).
5. Party statement (bulk: all farmers of a village as one PDF).
Reports must run offline from the local DB and complete in < 2 s for one season of data (~20k lots).
```

## Step 1.8 — Users, roles, audit log screen

**Prompt**
```
Users & permissions screen (owner): invite user by phone (creates membership; Edge Function sends SMS/WhatsApp invite link), set role, custom permission overrides grid (like the prototype), deactivate, device list with "revoke device".
Audit log screen: timeline (who, role, device, what, before → after), filter by user/table/date; highlight edits/reversals of money.
Enforce the permission table from docs/domain/ledger-and-mandi.md in UI AND in RLS/has_permission for inserts of reversals, back-dated entries, and settings.
```

## Step 1.9 — Onboarding & data entry for a new customer

**Prompt**
```
First-run onboarding wizard for a new tenant (owner):
business details → mandi & state → crops they deal in → default commission & charges → interest defaults (just store; engine comes in Phase 2) → language → invite munshi.
Opening balances import: paste/upload CSV or XLSX of parties with opening baki (preview, validate, then post as opening_balance entries).
```

## Step 1.10 — Hardening & pilot build

**Prompt**
```
Hardening pass for pilot:
- Integration tests (integration_test) for: add farmer → arrival → post → payment → statement balance correct, offline then online.
- Performance: seed 50k ledger rows, 5k parties; ensure lists/search < 100 ms, reports < 2 s on a mid-range Android.
- Conflict test: two devices create lots offline → no number collisions, both synced.
- Build: Windows MSIX (or Inno Setup installer) and macOS notarized .dmg, both with auto-update check, Android release APK/AAB, web deploy to Firebase Hosting or Cloudflare Pages (static only).
- Write docs/pilot-checklist.md for installing at a customer's shop.
```

## Step 1.11 — Production environment & release pipeline

**Prompt**
```
Set up the path from dev to production. You (Claude) never connect to production; everything goes through reviewed files and CI.
1. Environments: .env.dev / .env.prod (git-ignored), README section on which is used where; app shows a DEV ribbon when built with dev config.
2. GitHub Actions workflow `deploy-db.yml`: on a tag `db-v*` or manual dispatch with approval (GitHub environment "production" with required reviewer), run `supabase link --project-ref $SUPABASE_PROD_PROJECT_REF` and `supabase db push` using secrets SUPABASE_ACCESS_TOKEN / SUPABASE_PROD_DB_PASSWORD; then deploy Edge Functions.
3. Before push: job that runs `supabase db reset` + `supabase test db` on a fresh local stack and fails on any error; and a `supabase db diff` check that dev has no changes missing from migration files.
4. Document the PowerSync production instance setup and sync-rules deployment in docs/ops.md.
5. Release workflow `release.yml`: build Windows installer, macOS .dmg, Android AAB, web bundle with prod config on tag `v*`; attach artifacts to a GitHub Release.
6. docs/ops.md: backup (PITR), how to roll back a bad migration (forward-fix migration, never edit old ones), incident checklist.
Tell me exactly which secrets I must add in GitHub and where.
```

## Phase 1 exit criteria

- [ ] A pilot arhtiya records a full day (arrivals, sales, payments) offline and the numbers match their paper khata.
- [ ] Every balance on every screen equals the ledger sum.
- [ ] Munshi cannot reverse entries or see bank details; owner sees every munshi edit in the audit log.
- [ ] Receipts print on the shop's printer; statements share on WhatsApp as PDF.
