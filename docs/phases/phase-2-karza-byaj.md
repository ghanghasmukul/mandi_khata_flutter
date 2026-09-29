# Phase 2 — Karza (loans) & Byaj (interest)

**Goal:** fully configurable interest, per customer, per party and per loan — simple or chakravardhi (compound), any compounding period, grace days, interest-first or principal-first — with transparent day-by-day statements that farmers and owners can trust.

Read first: `docs/domain/interest-engine.md` (this is the spec — follow it exactly), `docs/domain/settings-cascade.md` (Interest keys), `docs/domain/ledger-and-mandi.md` (Karza section).

---

## Step 2.1 — Interest engine in khata_core (tests first)

**Prompt**
```
Read docs/domain/interest-engine.md completely.
First write ALL the worked-example tests listed at the bottom of that file in packages/khata_core/test/interest/ (they should fail).
Then implement the engine in packages/khata_core/lib/src/interest/ to make them pass:
InterestConfig (from resolved settings), LedgerEvent, RateChange, InterestRow (kind: accrue|debit|credit|compound|rate_change, from, to, days, principal, rate, interest, payInterest, payPrincipal, note), InterestResult.
Requirements: running net balance, surplus credit carried (never lost), apply_on modes, appropriation modes, compounding (monthly/quarterly/halfyearly/yearly/on_fy_close), grace days with FIFO tranches, rate changes, min days, rounding modes, day basis 365/360, "₹ per 100 per month" ⇄ % p.a. conversion helper.
Use the `decimal` package internally; return paise ints.
Add property-based tests: (a) with rate 0 interest is always 0; (b) total payable = principal + accrued; (c) interest never negative; (d) adding a jama never increases interest.
Report test coverage for the interest folder (aim 100% lines).
```

## Step 2.2 — Loans (karza) data & screens

**Prompt**
```
Tables: loans (id, tenant_id, loan_no KZ-, party_id, issue_date, principal, purpose, due_date, guarantor_party_id, interest_config_snapshot jsonb, status active|closed|written_off, closed_on, notes), loan_rate_changes (loan_id, effective_date, rate_pa, reason, by).
Issue karza (owner only): party, amount, date, purpose, due date, interest terms prefilled from the cascade (party → tenant) and editable per loan → snapshot. Posts loan_disbursal udhaar entry + payment out (cash/bank) in one transaction.
Loans list: cards like the prototype (principal, outstanding + byaj, % recovered, days left / overdue).
Loan detail: interest statement table (from/to, event, dr/cr, days, principal, rate, interest) using the engine live; "payable today"; "as of date" picker to answer "how much if he pays on 15 Oct?".
Repayment: record repayment (cash/bank or adjust from crop proceeds jama) showing the split interest/principal BEFORE saving.
Change rate (owner): effective-dated rate change, audited.
Close loan / write-off (owner, reason required).
```

## Step 2.3 — Khata-level interest (net udhaar)

**Prompt**
```
Implement interest on the whole party khata when tenant setting interest.apply_on = net_udhaar:
- Party detail "Byaj" tab: config (inherited/overridden per party, with the source shown), live statement from the engine over the party's ledger (excluding posted interest entries per the spec), accrued unpaid, recovered.
- Make sure the loans_only vs net_udhaar modes never double-charge the same money (if a party has loans and tenant uses net_udhaar, loan disbursals are part of the khata and loans don't run a separate engine — show a notice).
- Party-level overrides: rate, method, compounding, grace, appropriation, "no interest for this party" toggle.
- Party groups (e.g. by village): bulk-apply interest settings.
```

## Step 2.4 — Posting interest & settlement

**Prompt**
```
Posting:
- "Post interest" on a party or loan: posts an udhaar entry ref_type=interest with meta {from,to,rate,method,amount}; preview first.
- Bulk posting run (owner): for all parties/loans with accrued interest as of a date (e.g. quarter end / 31 March) — preview table, exclude rows, post in batches, fully audited, re-runnable safely (idempotent by period key).
- Settlement (hisaab): a "Hisaab karo" screen for a party showing principal, interest till today, crop proceeds, payments, and final payable/receivable; print a settlement slip; optional waiver (discount on interest) with reason → posted as jama ref_type=journal.
Scheduled posting per interest.post_frequency runs on the client that is online as owner (not server cron) in v1; document this.
```

## Step 2.5 — Reports & alerts

**Prompt**
```
Reports: Karza register (principal, repaid, outstanding, interest accrued, ageing, overdue), Interest earned (period, party-wise, posted vs accrued), Party interest statement PDF (in hi/pa too).
Alerts on dashboard "Needs you today": loans overdue, loans due in 7 days, parties crossing a credit limit (new party setting credit_limit), interest not posted for last quarter.
Sidebar badge on Loans = overdue count.
```

## Step 2.6 — Verification

**Prompt**
```
Create docs/interest-verification.md with 10 real-world scenarios (simple, monthly/quarterly/yearly compounding, grace, interest-first vs principal-first, surplus jama, rate change, FY close). For each: inputs, hand-calculated expected result, and the engine's result. Add each as a test. Flag any mismatch instead of silently changing the test.
```

## Phase 2 exit criteria

- [ ] Pilot arhtiyas' hand calculations (their own ledgers) match the engine for 10+ real accounts.
- [ ] Changing tenant default rate does not change existing loans (snapshot rule).
- [ ] A farmer with a jama balance is never charged interest (unless pay_on_jama is configured).
- [ ] Every posted interest entry can be explained by the statement shown on screen.
