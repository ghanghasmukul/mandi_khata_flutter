# Interest verification (step 2.6)

Ten scenarios with the expected result worked out **by hand** (exact decimal arithmetic, half-up to paise) from the rules in `docs/domain/interest-engine.md`, before the engine was run on them. Each one is a test in `packages/khata_core/test/interest/verification_test.dart`. A difference is a finding to report, never a number to edit.

All amounts are rupees. 18% unless noted, 365-day basis unless noted, whole-paise rounding.

| # | Scenario | Hand calculation | Hand result | Engine result | Match |
|---|---|---|---|---|---|
| V1 | Simple: 50,000 at 24%, 1 Jan to 1 Jul (181 days) | 50,000 × 24% × 181 / 365 | accrued 5,950.68 | 5,950.68 | yes |
| V2 | Interest first: debit 1,00,000 (1 Jan), debit 50,000 (1 Feb), credit 60,000 (1 Mar), as of 1 Apr | before the credit 1,528.77 + 2,071.23 = 3,600.00 paid first, principal paid 56,400; then 31 d on 93,600 | principal 93,600.00, accrued 1,430.93, payable 95,030.93 | same | yes |
| V3 | Same, principal first | credit pays 60,000 of principal; interest 3,600.00 + 31 d on 90,000 (1,375.89) | principal 90,000.00, accrued 4,975.89, payable 94,975.89 | same | yes |
| V4 | Monthly compounding: 1,00,000 at 12%, 1 Jan to 1 Apr | steps 1,019.18 / 929.93 / 1,039.04 | principal 1,02,988.15, accrued 0 | same | yes |
| V5 | Quarterly compounding: 2,00,000 at 15%, 1 Jan to 1 Oct | steps 7,397.26 / 7,756.09 / 8,134.56 | principal 2,23,287.91 | same | yes |
| V6 | Yearly compounding: 1,00,000 at 10%, 1 Jan 2027 to 1 Jul 2029 (2028 leap year, basis stays 365) | 10,000.00; 11,030.14; then 181 d on 1,21,030.14 = 6,001.77 | principal 1,21,030.14, accrued 6,001.77, payable 1,27,031.91 | same | yes |
| V7 | Grace 30 d: debit 10,000 (1 Jan), debit 20,000 (21 Jan), credit 5,000 (10 Feb), as of 1 Mar | 10 d on 10,000 = 49.32 paid first; principal paid 4,950.68 from the oldest debit; 19 d on 5,049.32 + 9 d on 20,000 | principal 25,049.32, accrued 136.07 | same | yes |
| V8 | Surplus jama: jama 50,000 (1 Jan), udhaar 80,000 (1 Feb), as of 1 Mar | 50,000 set off, 28 d on 30,000 | principal 30,000.00, accrued 414.25, no credit left | same | yes |
| V9 | Rate change: 18% to 1 Mar, then 24%, 1,00,000, as of 1 Jun | 59 d at 18% = 2,909.59 + 92 d at 24% = 6,049.32 (exact 8,958.904) | accrued 8,958.90 | same | yes |
| V10 | Compounding on FY close, 360-day basis: 3,00,000 at 12%, 1 Jan 2027 to 1 Apr 2028 | 90 d = 9,000.00; 366 d on 3,09,000 = 37,698.00 | principal 3,46,698.00 | same | yes |

## Observations (not mismatches)

- **Compounding rounding.** At each compounding step the accrued interest is rounded to paise and joins the principal; the sub-paise left over **stays in the running accrued figure**. A first quick hand calculation that rounded each step on its own (no carry) was 1 paisa higher in V5 (2,23,287.92); the carry version is the one the engine rules describe ("no money is created or lost") and the one used above. Worth knowing when a pilot arhtiya compares with a ledger that rounds each month on its own: differences of a few paise over many steps are expected.
- **Leap years.** The basis stays 365 (or 360) in a leap year, so a leap year earns a day more than a "year" (V6, V10). This follows the rule "days in a slab / day basis".
- **A step on the as-of day** (V4, V5, V10) turns all accrued interest into principal on that day; the payable total is the same either way.

## 🧑 Real accounts (pilot)

Phase 2 exit criterion: the engine matches the pilot arhtiyas' own ledgers for 10 or more real accounts. For each account, copy the entries, the rate and terms they use (simple / compound, grace, who is paid first) and **their** closing figure for a date, then compare with the Byaj tab (or the loan screen) on the same date. Record each below; flag any difference with the account's entries instead of changing a test.

| # | Arhtiya | Party | Terms (rate, method, grace, order) | As-of date | Ledger says | App says | Difference | Why |
|---|---|---|---|---|---|---|---|---|
| 1 | | | | | | | | |
