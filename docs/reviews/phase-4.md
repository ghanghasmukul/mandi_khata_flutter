# Phase 4 review (Input shop)

Reviewed 2026-10-08. Code review by an independent subagent (read-only, did not write the code; traced paths, did not run tests). Gates run by me: `dart format`, `flutter analyze` (0 issues), khata_core 725 tests, app 781 pass + 1 known failure (below), pgTAP 511 (schema agent, local stack), web / Android debug / macOS debug builds. Supabase advisors on dev after `db push`: nothing new from Phase 4 (unused-index infos only). Windows is built by CI only.

## Exit criteria

| # | Criterion | Status |
|---|---|---|
| 1 | Stock on screen = Σ stock movements for every product/batch | **Pass**: `stock_repository_test` asserts per product and per batch; the app never writes the batch cache, the server trigger does; pgTAP proves cache = Σ movements and `rebuild_batch_qty` |
| 2 | A farmer who sold wheat and bought urea on credit has ONE correct net balance | **Pass**: `shop_reports_repository_test` (lot jama 10,000 + udhaar 4,000 = one balance of 6,000; breakdown parts sum to it; receivable shows 0) |
| 3 | POS bill (5 items, udhaar) < 20 s with keyboard only | **Manual**: `pos_keyboard_test` drives a 5-item udhaar bill by keyboard only and passes; the stopwatch time on a real PC with a real scanner is for you |
| 4 | GST invoice validated by a CA on 5 sample bills | **Manual** (you): print 5 sample bills (B2B intra-state, B2B inter-state, B2C, discount, return) and have the CA check them |

## Findings

| # | Sev | Finding | Outcome |
|---|---|---|---|
| 2 | M | A return could be accepted against a sale/purchase reversed on another device (and the reverse of a document with a posted return); only the client checked | Fixed in migration `20261008151709_phase4_review_fixes.sql` (4 guard triggers, parent read FOR SHARE) + pgTAP 22 / 23 (515 pass locally); **not yet pushed to dev** |
| 3 | M | Round-off on the final return could make the refund negative; the upload then failed for good | Fixed in `ReturnRules` + repository validation + tests |
| 5 | M | Same batch number created offline on two devices (random ids) hit the unique constraint and blocked the queue | Fixed: batch id is a v5 UUID over tenant / product / batch no, like the opening import. SKU duplicates: see agent note in decisions.md |
| 9 | L | UPI refund on a return did not check `finance.view` on the client | Fixed |
| 10 | L | Stock adjustment audit row pointed at the adjustment id, not the movement id | Fixed |
| 1 | M | Cost and profit data (batch cost, sale-line cost, movements) sync to every member including munshi; hiding is UI-only | **Accepted, open**: a munshi device needs cost to snapshot COGS. Full fix = server-side COGS or a cost table in `finance_data`. Recorded in decisions.md |
| 4 | M | A munshi cannot take UPI sales: bank accounts sync only in `finance_data`, so the UPI account lookup fails | **Open**: either sync id + name of bank accounts to sales-capable members or require finance for UPI. Needs your decision |
| 6 | M | Editing a batch's cost, or a re-purchase's weighted cost, changes stock value without a journal, so Stock-in-Hand can differ from the stock report | **Open**: post a revaluation to Stock Adjustment, or forbid cost edits while the batch has stock |
| 7 | L | Purchase return stores its freight share in `round_off_paise` | **Open**, documented in decisions.md; do not treat that column as round-off in exports |
| 8 | L | A bank line tied to a shop sale is not compared with the sale's UPI amount on the server | **Open** (server hardening; needs `sales.create` to exploit) |
| 11 | L | Zero-value purchase refused; zero-cost adjustments post no journal so the closed-year lock does not see them; `rebuildBatchQty` audits a cache the server resets; auto refund ignores later payments on the udhaar; per-line COGS rounding differs from journal by 1 paisa on partial returns | **Open**, minor |

## Not covered by tests
Server-side: a munshi udhaar / UPI sale (the fixer adds the udhaar case), a return racing a reversal (added with fix 2), two devices creating the same SKU.
Not run: the camera scanner on a device, printing on real printers, two physical devices.

## Known failing test
`test/hardening/performance_test.dart` fails on this machine; it fails identically on the Phase 3 commit (day-book deep page 129 ms vs a 100 ms budget), so it is not caused by Phase 4. Needs a look at that query or at the budget.

## Manual checks for you
1. Deploy `powersync/sync-streams.yaml` in PowerSync (dashboard, Sync Streams).
2. Print 5 sample bills and give them to the CA (exit criterion 4); try a POS bill with a USB scanner and stopwatch (criterion 3).
3. Try the camera scan on an Android phone.
4. Have a Hindi and a Punjabi speaker check `docs/translation-review-phase4.md`.
5. Decide findings 4 (munshi UPI) and 6 (batch cost edits).
6. Approve `supabase db push` for the review-fix migration once the fixer reports.

## Manual checks: prepared 2026-10-08
- Criterion 4: `docs/ca-sample-bills/` holds 4 invoice PDFs (B2B intra-state 5% + 18%, B2B inter-state IGST, B2C 12%, line + invoice discount) and `sheet.md` with the figures and a worked return, all made by the real `SaleCalculator` and invoice PDF (regenerate: `cd apps/mandi_khata_app && flutter test tool/ca_sample_bills_test.dart`). Gap found: the app has no printable credit note for a return, so the CA can only check the return arithmetic from the sheet. Spot-checked by hand: 1,350 / 1.12 = 1,205.36 taxable; 13,500 / 1.05 = 12,857.14.
- Criterion 3 (stopwatch) still needs a person at a PC with a scanner.
