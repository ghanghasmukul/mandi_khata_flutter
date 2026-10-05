# Interest (byaj) engine — specification

Lives in `packages/khata_core/lib/src/interest/`. Pure Dart. No I/O. Deterministic.
The same engine is used for (a) party khata interest and (b) individual karza (loan) accounts.

## Input

```dart
InterestResult calculate({
  required List<LedgerEvent> events, // date, side (udhaar|jama), amountPaise, id, note
  required InterestConfig config,    // resolved from the settings cascade
  required DateTime asOf,            // calculate up to this business date (inclusive/exclusive rule below)
  List<RateChange> rateChanges = const [], // effective-dated rate changes for this account
});
```

## Output

```dart
class InterestResult {
  final List<InterestRow> schedule; // every slab + every event + every compounding step
  final int principalPaise;         // outstanding principal (udhaar side, >= 0)
  final int accruedUnpaidPaise;     // interest accrued, not yet recovered
  final int interestRecoveredPaise; // interest already recovered from repayments
  final int principalRecoveredPaise;
  final int totalPayablePaise;      // principal + accruedUnpaid
  final int creditBalancePaise;     // surplus jama (we owe the party), >= 0
}
```

## Rules

1. **Day count.** Days in a slab = `to - from` in calendar days (the start day counts, the end day doesn't). Interest for a slab = `principal × rate/100 × days / dayBasis`. Compute in high precision (`decimal` package or scaled integers). Keep slab values unrounded; round only the final totals (and posted amounts) according to `interest.rounding`. Tests must pin this behaviour.
2. **Running balance, not per-entry.** Interest runs on the **net running udhaar balance**. Each debit or credit starts a new slab.
3. **Surplus credit is NOT lost.** If a credit exceeds `principal + accrued`, the surplus becomes `creditBalance`. A later debit is first set off against `creditBalance`; only the remainder becomes interest-bearing principal.
   - *Bug found in the prototype:* surplus credit was discarded, so farmers we owed money to were still charged interest on later debits. Must have a regression test.
4. **Only charge when party is net udhaar.** With `apply_on = net_udhaar`, no interest accrues while the party's net balance is jama (we owe them). If `pay_on_jama = true`, interest accrues in the party's favour at `pay_rate_pa` instead.
5. **Suppliers/agencies:** by default `interest.apply_on = none` for parties whose only roles are `supplier`/`agency`.
6. **Appropriation of a repayment (credit):**
   - `interest_first` (default): pay accrued interest first, then principal.
   - `principal_first`: pay principal first, then accrued interest.
7. **Compounding** (`method = compound`): at each compounding date (monthly / quarterly / half-yearly / yearly counted from the account's first debit; or on financial-year close 31 Mar for `on_fy_close`), unpaid accrued interest is added to principal and a `compound` row is written.
8. **Interest never earns interest in simple mode.** Posted interest entries (`ref_type = interest`) are excluded from the principal fed to the engine.
9. **Grace days:** for each debit, the first `grace_days` days of that debit's amount are interest-free. (Implement per-debit tranches: each debit tracks its own start date for grace; repayments reduce the oldest tranche first — FIFO.)
10. **Rate changes** are effective-dated; a slab that crosses a change date is split.
11. **Min days:** slabs shorter than `min_days` produce zero interest.
12. **Determinism:** sort events by (date, created_at, id). Same-day events: apply debits and credits in sort order; interest for a 0-day slab is 0.
13. **asOf:** interest is calculated up to `asOf` (exclusive of asOf day) — "payable if settled today".

## Posting interest to the khata

- Interest is **calculated live** for display (statement, payable today).
- It is **posted** as an `udhaar` ledger entry with `ref_type = interest` only when: the user clicks "Post interest", on `post_frequency` schedule, or when a settlement is made. The posted row stores `{from, to, rate, method, amount}` in `meta`.
- After posting, the engine treats that amount as accrued-and-posted (not principal, unless compounding).

## Required worked-example tests (write these first)

1. Simple, 18% p.a., 365: debit ₹1,50,000 on 4 Aug; credit ₹40,000 on 19 Aug; asOf 13 Sep.
   - `principal_first`: 15d × 1,50,000 → ₹1,109.59; then principal 1,10,000 × 25d → ₹1,356.16; accrued ≈ ₹2,465.75.
   - `interest_first`: on 19 Aug interest ₹1,109.59 paid first, principal paid ₹38,890.41 → principal ₹1,11,109.59 × 25d → ₹1,369.84; accrued unpaid ≈ ₹1,369.84, interest recovered ₹1,109.59.
2. Surplus credit: jama ₹50,000 then udhaar ₹20,000 → zero interest, creditBalance ₹30,000.
3. Monthly compounding over 3 months, no repayments — matches `P(1+r/12)^3 − P` within ₹1 when basis aligns.
4. Grace 30 days: debit ₹10,000, asOf +45 days → interest for 15 days only.
5. Rate change mid-period splits the slab.
6. Supplier-only party with default config → zero interest.
7. `on_fy_close` compounding across 31 Mar.
8. Same-day debit and credit.

## Implementation decisions (step 2.1)

Where the rules above leave room, the engine does this. Each point is pinned by a test in `packages/khata_core/test/interest/`.

- **Dates.** `asOf`, event dates and rate-change dates are `LedgerDate` (calendar days, no time zone), not `DateTime`. Events dated on `asOf` ARE applied (a payment dated today counts as paid); the `asOf` day itself earns no interest (rule 13). Events after `asOf` are ignored.
- **Order on one day.** Compounding first, then the rate change, then events in (date, createdAt, id) order.
- **Rounding.** Slab interest and the running accrued amount stay unrounded (20-digit decimals). Rounding by `interest.rounding` (half-up to paise / rupee / 10 rupees) is applied only to the final `accruedUnpaidPaise`. A repayment's interest part is always split in whole **paise** (accrued rounded half-up to paise), whatever `interest.rounding` says, because the split is a fact about a real payment (worked example 1 pays ₹1,109.59). The sub-paise difference stays in the running accrued figure, so no money is created or lost.
- **Interest-first with compounding.** A repayment pays the interest accrued so far since the last compounding step first, then principal. Compounding dates are anchored on the account's first debit and are not reset by repayments.
- **Compounding dates.** `monthly/quarterly/halfyearly/yearly`: first-debit date + 1/3/6/12 months (day clamped to month end, always counted from the anchor so it never drifts). `on_fy_close`: the close of 31 March, i.e. the boundary is 1 April, so 31 March earns interest in the year it closes. At each date the accrued unpaid interest (rounded half-up to paise) becomes a new principal tranche without grace days.
- **Min days.** A "period" is the stretch between two balance-changing events (or the last event and `asOf`). A period shorter than `min_days` earns nothing, even if a rate change or compounding date splits it into several slabs.
- **Grace.** Each debit is a tranche with its own interest-free window; repayments consume the oldest tranche first. Capitalised interest has no grace. A debit that is set off against a credit balance creates no tranche for the set-off part.
- **`apply_on`.** `net_udhaar` and `loans_only` run the same maths (the caller decides which events to pass: whole khata or one loan's events). `none`, or `interest.enabled = false`, gives zero interest but still tracks principal, recoveries and credit balance. The supplier / agency default (`none`) is applied by `InterestConfig.fromSettings` only when the value came from the system, plan or tenant level and the party's roles are all supplier / agency; an explicit party, group or document value wins.
- **`pay_on_jama`.** While a credit balance exists, interest accrues in the party's favour at `pay_rate_pa` (no grace, simple, never compounded, not netted against what the party owes). It is reported separately as `interestPayableToPartyPaise`; `totalPayablePaise` is unchanged.
- **Posted interest** (`LedgerEvent.isPostedInterest`): ignored by the engine (rule 8). Reconciling accrued interest against already-posted interest is step 2.4's job.
- **Rate changes** only change `rate_pa`; the pay-on-jama rate is fixed. A change dated on or before the first event applies from the start without a schedule row.

## Khata-level interest (step 2.3)

`khata_core` `KhataInterest` feeds a party's whole khata to the engine when the party's resolved `interest.apply_on` is `net_udhaar`.

- **Events.** Every entry of the party except reversals and the entries they reverse (they net to nothing), **and except the entries that belong to a loan** (`loan_disbursal`, `loan_repayment`, and the waiver journals that point at a loan's waiver posting). Entries with `ref_type = interest` are passed flagged and ignored (rule 8). The journal line that moves crop proceeds against a loan stays in the khata, so crop proceeds applied to a loan net to nothing there.
- **Modes** (`KhataInterest.mode`): `khata` (`net_udhaar`), `loansOnly` (`loans_only`: no khata engine runs, the result is empty), `off` (`none` or `interest.enabled = false`: nothing charged, principal still tracked).
- **A loan is always its own account (decision 2026-10-05, phase 2 review).** A loan's interest always runs on the loan's own snapshot (terms and `loan_rate_changes`), whatever the party's `apply_on` is. Changing the business or party default never moves it (settings-cascade snapshot rule). The khata engine leaves loan entries out, so the same money is never charged twice. Cost: a loan's udhaar no longer offsets the party's crop credit for byaj purposes. `loans_only` means "no khata byaj, loans only"; `none` / `interest.enabled = false` switch the khata byaj off but a loan keeps its own contract.
- **Party overrides** (`PartyInterestOverrides`): the editor writes party-level `interest.*` settings, only for values that differ from what the party would inherit; a value equal to the inherited one is reset to inherit (`null`). "No interest for this party" writes only `interest.enabled = false`. A party that is off by `apply_on = none` (supplier / agency default) shows as off; switching it on writes `interest.enabled = true` and `interest.apply_on = net_udhaar`.
- **Bulk apply.** `PartyInterestOverrides.explicit` writes every editable value as party-level rows for the parties picked (usually one village). Needs `loans.manage`; each row is an audited setting write.

## Posting interest and settlement (step 2.4)

Interest is posted from what the engine charged, never typed in. khata_core `InterestPosting` / `Settlement` / `PostingSchedule`; the app writes it in `InterestPostingRepository`.

- **What is still to post.** The engine ignores posted interest (rule 8), so `charged = accrued unpaid + recovered + waived + capitalised by compounding` does not change when interest is posted or repaid. `unposted = max(0, charged − posted)`, where `posted` = interest entries of that account that are not reversed. The posting preview is `unposted`, for the period from the last posting's `to` (or the first entry) up to `asOf` (exclusive).
- **`interest_postings`.** The document behind an `interest` khata entry (the ledger has no `meta` column). Columns: party, loan (null = whole khata), period from / to, amount, rate, method, bulk `batch_id`, `period_key`. The khata entry is `udhaar`, `ref_type = interest`, `ref_id` = the posting, **dated the last day interest ran (`to − 1`)** so a posting "up to 1 April" falls on 31 March, in the financial year it belongs to. Append-only; the posting row is written before the entry in one upload and the entry's guard checks that they match (side, party, amount).
- **Idempotent.** `period_key` = `interest:khata:<party>:<to>` or `interest:loan:<loan>:<to>`, unique per business. Posting and entry ids are UUID v5 of tenant + key, so the same run on two devices writes the same rows and the upload keeps the first. A run also skips an account already posted up to that day or later (not reversed). A posting whose khata entry was reversed counts as not posted, but its key stays taken: post again with a different day.
- **Khata AND loans, never the same money twice.** A loan is always posted on its own snapshot terms and rate changes. A party whose `apply_on` is `net_udhaar` is additionally posted on the khata without the loan entries (see step 2.3). A party that is `loans_only` or switched off has only its loans posted.
- **Fresh figures at posting (phase 2 review).** `post()` recomputes each account inside the posting transaction and skips a plan whose amount or start day no longer matches what the engine charges now (`PostingSkip.changed`), so what is written always equals the statement. `settle()` already recomputed.
- **Closing a loan.** A loan can be closed only when nothing is payable AND all its interest is posted to the khata: a closed loan is not offered for posting any more, so unposted interest would never be charged. Writing off is unchanged: interest not posted by then is not charged (post it first if it should be).
- **Server integrity (migration `interest_postings_integrity`).** A new interest posting may not overlap a live posting (entry not reversed) of the same party / loan, so two offline devices posting to different days cannot charge a period twice (the later upload is rejected and shows in rejected changes). One interest entry per posting (unique index), dated `period_to - 1`; one entry per waiver posting, dated the waiver day; every posting must have its khata entry by the end of its upload (deferred constraint trigger); waivers of an account are capped at the interest posted on it.
- **`pay_on_jama` in v1 (phase 2 review).** Interest the business owes a party on their credit is calculated and shown on the Byaj tab, labelled "not posted". It is not posted and not part of Hisaab karo: the owner settles it by hand with a journal entry. Posting it automatically needs its own rules (who pays, tax) and is left for later.
- **Posted too much.** If a reversal leaves more interest posted than the engine charges (`InterestPosting.overPosted`), the Byaj tab shows the difference so the extra interest entry can be reversed; "still to post" stays at 0 (never negative).
- **Narrations are language-neutral.** Posting entries carry the period and rate (`2027-01-01 – 2027-04-11 · 18%`), waivers carry the reason the owner typed, loan lines carry the loan number. The entry type gives the label in the reader's language, like lots and receipts, which carry only their number.
- **Bulk run.** `/loans/post` (needs `loans.manage`): candidates for all parties and loans up to a day, rows can be unticked, posted in batches of 25 (one local transaction each, one upload each), fully audited. The day proposed follows `interest.post_frequency` (`PostingSchedule`: monthly = 1st of this month, quarterly = latest 1 Apr / 1 Jul / 1 Oct / 1 Jan, `fy_close` = latest 1 April, `on_demand` = today). A day after today is refused.
- **Scheduled posting (v1).** Nothing posts by itself and there is no server cron: the interest rules need a person to confirm the figures. `interest.post_frequency` only chooses the day the owner's run proposes. A client-side scheduler (owner's device, when online) can reuse the same `post` call later.
- **Waiver (discount on interest).** A waiver is a `jama` entry (`ref_type = journal`, `ref_id` = a `waiver` posting) with a mandatory reason. The engine treats it as an interest-only credit (`LedgerEvent.interestOnly`: pays accrued interest first whatever `interest.appropriation` says, reported as `interestWaivedPaise`, not recovered). It cannot exceed the interest charged on that account. A loan's waiver is a loan event, so the loan's own statement shows it. Needs `loans.manage` and `entries.reverse`.
- **Hisaab karo.** `Settlement.compute`: `final = khata balance − (unposted interest − waiver)` (jama positive; negative = the party pays). One transaction posts the interest of every account and its waiver, then the party pays or is paid from the khata. The slip (A5 PDF, printed in the app language) can be printed before or after posting.

## Reports and alerts (step 2.5)

- **Karza register** (`/reports`, kind karza): every loan (open first) with its figures on a chosen day (`LoanPosition`): principal issued, principal repaid, outstanding, interest accrued and recovered, days overdue with the same ageing bands as the outstanding report, status. Readable by every member (loans already are), export needs `finance.view`.
- **Interest earned** (kind interestEarned, needs `finance.view`): per party, interest **posted** and **waived** with an entry dated inside the period (reversed entries do not count) and interest **accrued, not yet posted** as of today (the posting run's candidates). Earned = posted + accrued not yet posted. The waived column is shown but not part of earned (a waiver is already off the posted figure in the khata, not off "charged").
- **Byaj statement PDF** (party Byaj tab): the engine's day-by-day rows, the figures of the day and the terms, in the language of the app (Devanagari and Gurmukhi fonts are bundled). It prints what is on screen, nothing else.
- **Credit limit** (`business.credit_limit`, paise, 0 = none; a party or group may override): a party is over it when what it owes (−balance) is more than its limit (`CreditLimit.excess`). It is an alert only.
- **Alerts** ("Needs you today"): loans overdue and due within `LoanRules.dueSoonDays` (7) days (`loans.manage`), parties over their credit limit (`finance.view`), and interest of the last quarter not posted (`loans.manage`): the posting run's candidates as of the last quarter boundary (1 Jan / 1 Apr / 1 Jul / 1 Oct, `PostingSchedule`), tapping opens the bulk run on that day. The Loans link shows the overdue count (there is no sidebar yet).
