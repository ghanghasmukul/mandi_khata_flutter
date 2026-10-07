# Phase 3 review (Accounting)

Reviewed 2026-10-07 by an independent subagent (read-only; it could not run tests) after steps 3.2-3.6 (commit `ce60009`). The only HIGH-severity question was answered "none found". Gates run by me afterwards: `dart format`, `flutter analyze` (0 issues), khata_core 602 tests, app 708 tests, pgTAP 421, `supabase db lint` clean, web / macOS / Android debug builds. Windows is built by CI only.

## Exit criteria

| # | Criterion | Status |
|---|---|---|
| 1 | Trial balance always tallies (check on every sync + fuzz) | **Pass**: books checks re-run after each sync with a dashboard alert; `books_fuzz_test` (150 random postings through every repository, 3 seeds) and khata_core 200-run fuzz |
| 2 | Party khata balance = party account balance in the journal | **Pass**: `BooksInvariants.partyDifferences` asserted after every scenario in the journal / voucher / fuzz tests |
| 3 | An accountant can export a month to Tally and it imports without errors | **Manual**: XML structure and signs are tested, the import into Tally Prime has not been run. See docs/tally-import.md |

## Findings and what was done

| # | Sev | Finding | Outcome |
|---|---|---|---|
| 1 | M | The owner's closed-year unlock survived a business switch / new sign-in | Fixed: `LockOverride` now watches the active business and session, so it resets |
| 2 | M | `financial_years` (with the year's profit) synced to every member | Fixed: moved to `finance_data`, select policy needs `finance.view`; pgTAP updated. Still open: `recurring_expenses` (salary templates), `expenses` and `vouchers` sync to every member (a munshi enters cash expenses) |
| 3 | M | Bills over the bucket limit or retried uploads stayed queued forever | Fixed: 8 MB check in the picker, no `upsert`, "already exists" treated as success |
| 4 | L | Tally export joined journal entries on expressions | Fixed: `substr` joins on the keyed id |
| 5 | L | A switched-off seeded category still took expenses | Fixed (+ test) |
| 8 | L | Dr X / Cr X of one amount passed the voucher rules | Fixed (+ test) |
| 9 | L | Cash count crashed when Cash Short / Excess was not in the local chart | Fixed: refused as "not found" |
| 10 | L | A recurring month could not be re-posted after reversing it | Fixed: reversed rows no longer count as posted |
| 12 (part) | L | A voucher's khata line could be reversed on its own from the khata | Fixed in `LedgerRepository.reverse` (+ test) |
| 6 | L | Entries posted into a closed year after an unlock never reach P&L A/c | **Open**: balance sheet still balances through "Profit & Loss (current)"; document: post such a correction by manual journal, or close adjustments in the next year |
| 7 | L | An account whose row has not synced is treated as an asset in statements | **Open**: only before the first sync of a brand-new account |
| 11 | L | `date_locked` callable by any user; a year need not have ended to be closed on the server; closing entry type not checked | **Open** (server hardening; the app refuses these cases) |
| 12 (rest) | L | Server does not stop own accounts in Cash / Bank / Debtors / Creditors groups; reconciliation repository takes no `can` | **Open** (UI and RLS cover the permission; groups are an app rule) |
| 13 | - | Missing tests: SQL closed-year reversal by non-owner / owner with reason; storage UPDATE policy; unlock leakage across businesses; oversize bill | **Open** |

## Manual checks for you

1. Import one month's Tally export into Tally Prime (docs/tally-import.md).
2. Run the Accounts screens on a real Android phone offline: voucher, expense with bill photo, cash count.
3. Confirm the decisions in docs/decisions.md for 3.2-3.6, above all that year close does not carry balances forward as khata entries.
4. After `supabase db push` and deploying `powersync/sync-streams.yaml`, check the dashboard shows no "books do not tally" row on a device with real data.
