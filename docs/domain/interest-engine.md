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
