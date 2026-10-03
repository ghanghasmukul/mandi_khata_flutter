# Phase 1 review: Core Mandi Khata

Date: 2026-10-03 · Reviewed range: `53bef48..HEAD` (steps 1.1 to 1.11), reviewed by an independent subagent that did not write the code, plus a full `/verify`.

**Verdict: code-complete, not closed.** One HIGH finding (invite hijack) found and fixed with a pgTAP test, migration pushed to dev. Phase 1 stays open for the pilot and for the manual checks below. Several MEDIUM findings need a decision before real money goes through (see Open items).

## Exit criteria

| # | Criterion | Status | Evidence / manual test |
|---|---|---|---|
| 1 | A pilot arhtiya records a full day offline and numbers match their paper khata | **Manual** | Machinery proven: `integration_test` and `test/hardening` khata flow (farmer, arrival, post, payment, statement balance, offline then upload); two-device conflict test against local Supabase. Manual: take a real day's paper khata (10+ lots, 5+ payments), switch the device to airplane mode, enter it all, compare each farmer's closing baki and the day total with the paper, then reconnect and confirm the same balances on a second device |
| 2 | Every balance on every screen equals the ledger sum | **Pass** | `test/hardening/balance_integrity_test.dart` "every displayed balance equals the ledger sum after a messy day" (reversals, payments, cheque bounce, opening balances); `integration_test/support/balance_check.dart`; balances are read only from `ledger_entries` (review confirmed no separate dues) |
| 3 | Munshi cannot reverse entries or see bank details; owner sees every munshi edit in the audit log | **Partly proven** | Reversal: pass in UI and RLS (pgTAP 04, 06, 08; `ledger_repository_test`, `payments_screens_test`). Munshi edits visible to owner: pass (`audit_repository_test`, `audit_screen_test`, pgTAP 10). Bank details: **UI-hidden only**; party bank columns and payment UTR / cheque numbers still sync to a munshi's device (finding M5). Manual: sign in as munshi on a phone, open a farmer with bank details, and a UPI payment; confirm nothing is shown. The data-on-device leak is not closed |
| 4 | Receipts print on the shop's printer; statements share on WhatsApp as PDF | **Manual** | PDF generation covered by tests. Manual: (a) Windows/macOS: Payments, open a receipt, Print, choose the shop printer (A5 and 80mm); (b) Android: open a farmer statement, Share, pick WhatsApp, open the PDF on the receiving phone and check Hindi / Punjabi text renders |

## Quality gate (`/verify full`)

| Check | Result |
|---|---|
| `dart format` | pass, 0 changed |
| `flutter analyze` (repo root) | pass, 0 issues |
| khata_core tests | 341 pass |
| mk_ui tests | 16 pass |
| app tests | 526 pass, 1 skipped (device-only) |
| `supabase db reset`, `test db`, `db lint` (local Docker) | pass: 11 files, 251 pgTAP tests (5 new), no schema errors |
| `flutter build web` | pass |
| `flutter build apk --debug` | pass |
| `flutter build macos` | pass (a first attempt failed only because two builds ran at once) |
| Windows | CI only, not built locally |
| Rule scan | no `double` money, every table has tenant_id, no direct Supabase business-data calls from screens, no UPDATE/DELETE on append-only tables, ARB parity: 915 keys in en/hi/pa, 0 TODO(translate); hard-coded strings only `DEV` ribbon, `EN` chip, xlsx sheet fallback `Report` (low) |

## Supabase advisors (dev, after the fix)

| Advisor | Finding | Action |
|---|---|---|
| Security | 0029 `register_device`, `create_member_invite`, `accept_member_invites` SECURITY DEFINER callable by `authenticated` | Intended (each checks `auth.uid()` / permission inside). Accept; add to decisions.md |
| Security | Leaked password protection disabled | Dashboard setting, still open (🧑, optional; the app uses phone OTP) |
| Performance | 23 unused indexes | Dev has almost no traffic; keep, re-check after the pilot |
| Performance | `devices_revoked_by_fkey` has no covering index | Info, negligible. Fold into the next migration |
| Performance | multiple permissive SELECT policies on `audit_log`, UPDATE on `devices` | Intentional (own-rows vs audit.view; admin vs self). Merge to one `OR` policy later if it shows in profiling |

## Code review findings

Verified clean: charge formula matches `ledger-and-mandi.md` (exact integer rounding, per-line half-up, borne-by rules); int paise throughout; ledger and cash book append-only by trigger and revoked grants, with UNIQUE(reverses_id); RLS on every table keyed on `auth_tenant_ids()`; composite tenant FKs; SECURITY DEFINER functions set `search_path = ''`; number series are per device and cannot collide offline; audit rows written in the same local transaction for every write path traced; no direct Supabase business-data calls.

| # | Severity | Finding | Status |
|---|---|---|---|
| H1 | **High** | Any user could edit their own `app_users.phone` (policy allowed any column) and call `accept_member_invites()`, which matches invites by that column: join a business with the invited role and permissions | **Fixed**: migration `20261003130000_app_users_phone_locked.sql` (trigger blocks phone changes by `authenticated` / `anon`), pgTAP `11_app_users_phone_locked` (5 tests), pushed to dev |
| M1 | Medium | Server back-date limit uses the client `created_at`; setting the device clock back defeats it (also `guard_payment`) | Open. Add a lower bound against `received_at` (e.g. 30 days) |
| M2 | Medium | `shop_sale`, `shop_return`, `purchase`, `expense` ref types need no permission or limit, so a munshi using the API can post a jama that cancels a debtor's udhaar | Open. Require `entries.reverse` for these until Phases 3 to 4 |
| M3 | Medium | Device revocation only enforced on `audit_log` inserts and ledger entries; payments, cash book, lots, parties, settings still accept a revoked device; revoked devices keep reading | Open. Add `revoked_at is null` to those guards |
| M4 | Medium | Dashboard "arhat earned" stat and chart not gated by `finance.view` (domain doc says closed). Reports are gated | Open (UI gate + widget test) |
| M5 | Medium | Party bank columns and payment UTR / cheque no. sync to all members; "munshi cannot see bank details" is UI-only | Open. Separate finance stream / table |
| M6 | Medium | Party / lot scope `mandi.*` settings writable by any member; `scope_id` not verified to belong to the tenant | Open (matches the accepted R6 decision; scope check is new) |
| M7 | Medium | Server does not check that a lot's gross / net equal qty × rate or that ledger entries match; same for payment vs book line. Needs a modified client to exploit | Open |
| M8 | Medium | Lot (and payment, L9) can be marked reversed without all its ledger reversals when some entries were not yet local | Open. Server check on `posted -> reversed` |
| L1 | Low | App "today" uses device-local day, server uses Asia/Kolkata: possible permanent rejection near midnight in other time zones | Open |
| L2 | Low | Day-book running baki orders same-day rows by `created_at` text; mixed ISO formats could misorder | Open, unconfirmed |
| L3 | Low | Finance stream follows default role, not per-user `finance.view` override | Open (documented) |
| L4 | Low | Opening-balance idempotence holds only for same date and file across devices | Open |
| L5 | Low | `audit_log` is client-written; a modified client can omit or forge rows (carried from R5) | Open, accepted for pilot |
| L6 | Low | Several local UPDATEs filter by `id` only, not `tenant_id` | Open, not exploitable (UUID ids) |
| L7-L10 | Low | Team phone numbers synced to members; payment limit is per payment; CLAUDE.md names `sync-rules.yaml` but the file is `powersync/sync-streams.yaml` | Open (CLAUDE.md fix is trivial but I did not edit it) |

Not fixed because the brief was HIGH only: M1 and M2 are the ones I would fix first (both let a munshi bypass a documented limit with a modified client or a clock change, but neither is reachable from the shipped UI).

## Fixes applied in this review

| # | Fix | Files |
|---|---|---|
| H1 | Block `app_users.phone` changes from API roles + pgTAP test | `supabase/migrations/20261003130000_app_users_phone_locked.sql`, `supabase/tests/11_app_users_phone_locked.test.sql` |

## Open items

For you (🧑):
1. Manual criteria 1 and 4 above, and the bank-details check in criterion 3 (note M5).
2. Decide on M1 to M8 before the pilot handles real money; I recommend M1, M2, M3, M5 first.
3. Dev PowerSync lacks the ledger / payments streams (noted in step 1.10): deploy `powersync/sync-streams.yaml` before testing khata sync on dev.
4. `actionlint` was not available and the `deploy-db.yml` / `release.yml` workflows have never run; try them on a tag or dispatch.
5. Windows installer: run the CI build on a real Windows PC.
6. Optional: enable leaked-password protection in Supabase Auth.
7. Prod Supabase and PowerSync setup and CI secrets (step 1.11).
