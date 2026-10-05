# Phase 2 review: Karza & Byaj

Date: 2026-10-05 · Reviewed range: `967310c..HEAD` (steps 2.1 to 2.6), reviewed by an independent subagent that did not write the code (it read the code and test names, it did not run tests), plus a full `/verify` run by the main session.

**Update 2026-10-05 (later): finding 1 (option A) and findings 2, 3, 5, 6 are fixed; khata_core 511, app 642, pgTAP 323 pass. Finding 4 is resolved by option A (test added). Findings 7-11 are open.**

**Verdict: code-complete, NOT closed.** One HIGH finding is a conflict between exit criterion 2 and the documented design; it needs an owner decision on money logic and was deliberately not "fixed" by guessing (see Open decision). Exit criteria are not ticked.

## Exit criteria

| # | Criterion | Status | Evidence / manual test |
|---|---|---|---|
| 1 | Pilot arhtiyas' hand calculations match the engine for 10+ real accounts | **Manual** | Machinery proven by 10 hand-calculated scenarios (`docs/interest-verification.md`, `test/interest/verification_test.dart`, all match). Manual: fill the real-accounts table in that doc with 10+ accounts from the pilot arhtiyas' own ledgers (principal, dates, rate, payments, the arhtiya's figure vs the app's Byaj tab figure at the same date). Any difference over Rs 1 per account is a bug report |
| 2 | Changing the tenant default rate does not change existing loans (snapshot rule) | **Pass after fix** (was FAIL for `net_udhaar` parties; owner chose option A, see decisions.md) | Snapshot storage was already proven (`loans_repository_test` "the interest terms are snapshotted and the loan is its own account (loans_only)"; pgTAP 12 "the interest snapshot cannot be edited"). Before the fix, for a `net_udhaar` party (the default) the loan's money ran in the khata engine at the LIVE rate. Now proven by `interest_posting_repository_test` "changing the business default rate does not change what a loan is posted at" (fails on the old code) and "khata and loan are both posted, on separate money" |
| 3 | A farmer with a jama balance is never charged interest (unless `pay_on_jama`) | **Pass (engine)** | `khata_core/test/interest/rules_test.dart` "no interest accrues while the party is in credit", the `pay_on_jama` group, surplus regression tests, worked example 2. At posting level the repository test "party with interest switched off or a credit balance has no candidate" only exercises the switched-off half; the credit half rests on the engine tests |
| 4 | Every posted interest entry can be explained by the statement shown on screen | **Partly proven** | `interest_posting_repository_test` "the preview is what the engine charged up to the day", "posted interest is not charged again..."; `interest_statement_test`. Not guaranteed on the `post()` path when entries change between preview and Post (finding 5), for loans of `net_udhaar` parties (finding 1) or for `pay_on_jama` payable (finding 7) |

## Quality gate (`/verify full`)

| Check | Result |
|---|---|
| `dart format` | pass, 0 changed |
| `flutter analyze` (repo root) | pass, 0 issues |
| khata_core tests | 509 pass |
| mk_ui tests | 16 pass |
| app tests | 639 pass, 1 skipped (device-only); after the fixes 642 |
| `supabase db reset`, `test db`, `db lint` (local Docker) | pass: 13 files, 308 pgTAP tests, no schema errors |
| `flutter build web` / `apk --debug` / `macos` | pass |
| Windows | CI only, not built locally |
| Rule scan (reviewer) | no `double` money; ARB parity 1169 keys in en / hi / pa; hard-coded English narrations stored in ledger entries (finding 9) |

## Supabase advisors (dev)

Dev WAS missing the step 2.4 migration (pushed later the same day together with the integrity migration; advisors re-run: nothing new, 4 unused-index infos on interest_postings) (`20261005154532_create_interest_postings`; latest on dev is `loan_rate_changes_tenant_index`), so the advisors below do not cover `interest_postings`. Re-run them after `supabase db push`.

| Advisor | Finding | Action |
|---|---|---|
| Security | 0029 `register_device`, `create_member_invite`, `accept_member_invites` callable by `authenticated` | Intended, already accepted in phase 1 |
| Security | Leaked password protection disabled | Dashboard setting, optional (phone OTP app) |
| Performance | 28 unused indexes (loans / rate changes / payments / lots ...) | Dev has no traffic; re-check after the pilot |
| Performance | `devices_revoked_by_fkey` unindexed; multiple permissive policies on `audit_log` SELECT and `devices` UPDATE | Unchanged since phase 1, intentional / negligible |

## Findings

Severity as given by the reviewer; the main session re-read the code behind finding 1 only. The others are reported as found and not independently re-verified.

| # | Severity | Where | Defect | Status |
|---|---|---|---|---|
| 1 | HIGH (**fixed 2026-10-05**, option A) | `interest_posting_repository.dart` (~175), `khata_interest.dart` `includesLoans`, `settings_schema.dart` `interest.apply_on` | For a `net_udhaar` party (the default) the loan's snapshot rate / grace / appropriation / `loan_rate_changes` are never used when posting; interest follows the live party / tenant rate. A tenant-default change, or a rate change on the loan, changes what is posted. The loan screen shows "reference only" figures that differ from the posted ones | Fixed: loans always posted on their own snapshot; khata engine excludes loan entries; test changes the default rate after issuing a loan |
| 2 | MEDIUM-HIGH | `loans_repository.dart` close / write-off, `loan_rules.dart` `validateClose` | Closing or writing off a loan does not require its interest to be posted, and closed loans drop out of the posting candidates, so unposted interest is never charged (for `loans_only` parties the repayment jama sits in the khata as a permanent credit) | Fixed: close needs interest posted; test in `loans_repository_test` (close) and `loan_rules_test` |
| 3 | MEDIUM | `create_interest_postings.sql` unique `(tenant_id, period_key)` | Server idempotency only covers the same `period_to`. Two offline devices posting the same account up to different days both succeed and charge the period twice | Fixed in SQL: overlap guard; pgTAP 14 (migration not on dev yet) |
| 4 | MEDIUM (plausible) | `interest_posting_models.dart` `PostedSummary.of` | Posted interest is counted per loan or per khata only; switching `apply_on` after postings exist can charge the same period again | Resolved by option A (khata and loans are separate accounts, so a mode switch moves no money between them); proven by test "switching the interest mode after postings never charges a period again" |
| 5 | MEDIUM | `interest_posting_repository.dart` `post` | `post()` writes the previewed amount without recomputing inside the transaction (`settle()` does). A synced repayment between preview and Post makes the posted amount differ from the engine figure | Fixed: `post()` recomputes in the transaction; test "a preview that went stale is not posted" |
| 6 | MEDIUM | `guard_ledger_entry` (interest / waiver) | Server does not check one entry per posting, entry date = `period_to - 1`, a waiver posting having its entry, or waivers capped at interest charged. No pgTAP for these | Fixed in SQL: unique interest entry, entry dates, one waiver entry, waiver cap, posting needs entry; pgTAP 14 |
| 7 | LOW-MEDIUM | `interest_posting.dart` | With `pay_on_jama` the payable-to-party figure is shown but never posted or included in `Settlement` | Open, needs a decision in decisions.md |
| 8 | LOW | `interest_posting.dart` `unposted` clamped at 0 | Interest over-posted after a repayment is reversed is never surfaced | Open |
| 9 | LOW | posting / loan narrations | English narration text stored in ledger entries (i18n rule) | Open |
| 10 | LOW | `interest_postings` select policy + sync stream | Every member receives all postings; the interest-earned report permission is UI-only (`finance.view`) | Accept and record, or gate |
| 11 | LOW | tests | Missing: pgTAP for duplicate entry per posting, waiver without `entries.reverse`, backdate window, closed-loan posting; repository tests for two devices posting different `to` dates, a mode switch with prior postings, closing with unposted interest | Open |

## Decision taken (finding 1): option A chosen by the owner

The phase file says: with `net_udhaar`, a loan's disbursals are part of the khata and the loan does not run a separate engine. That is how 2.3 / 2.4 were built, and it avoids double charging. It also means a loan to a default-configured party is not a fixed contract: its interest moves with the party / tenant rate, which contradicts exit criterion 2 and the snapshot rule in `docs/domain/settings-cascade.md`.

Options (a money-logic choice, not made by the reviewer or by Claude):

- **A. Loans are always their own account.** Posting runs the loan on its snapshot, and loan disbursals / repayments are left out of the khata engine input (the khata byaj then covers only the non-loan balance). Matches the snapshot rule; changes netting (a loan's udhaar no longer offsets the farmer's crop jama for byaj purposes) and needs a domain-doc change first.
- **B. Issuing a loan to a `net_udhaar` party switches that party to `loans_only`** (a party-level override, audited, with a confirmation). Simple and consistent with the "its own contract" idea, but the party's ordinary khata then stops charging interest.
- **C. Keep the design, change the criterion.** Say plainly that for `net_udhaar` parties the loan follows the live khata rate, and warn on the issue form. Criterion 2 then only holds for `loans_only`.

## Manual checks for the user

1. Real accounts (criterion 1), as above.
2. After deciding finding 1: issue a loan to a default-configured farmer at 24%, change the business default rate to 18%, open the farmer's Byaj tab and the loan detail: both must still say 24% on the loan's money.
3. Two devices: post the same farmer's khata interest offline on both, up to different dates, reconnect, and confirm the khata shows the interest once (currently expected to show it twice, finding 3).
4. Print a Hisaab slip in Hindi and Punjabi and check the text renders (strings were not natively reviewed).

## Environment actions still open (🧑)

- `supabase db push` to apply `create_interest_postings` to dev, then re-run the advisors.
- Deploy `powersync/sync-streams.yaml` (`loans`, `loan_rate_changes`, `interest_postings` and the earlier streams) in PowerSync.
