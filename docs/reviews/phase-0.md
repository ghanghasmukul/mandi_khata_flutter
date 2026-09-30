# Phase 0 review: Foundation

Date: 2026-09-30 · Reviewed range: `9c5ef25..HEAD` (steps 0.1–0.8 + fixes found in the first real sync test)

**Verdict: not closed yet.** Code, tests and database checks pass. CI is fully green (Windows included) since a33b007. Phase 0 stays open only for the manual device tests (see "Open items").

## Exit criteria

| # | Criterion | Status | Evidence |
|---|---|---|---|
| 1 | Same party list on Windows, macOS, Android and Web for one tenant; invisible to another tenant | **Partly proven, manual pending** | Isolation: pgTAP `01_tenant_isolation` (63/63 pass, local reset); `membership_repository_test` "never shows another user their businesses"; `schema_consistency_test` "every synced table has tenant_id"; dev DB on 2026-09-30: Mukul Arhat Co. 4 parties / Bali Traders 5, 0 audit rows pointing across businesses. Same list on every platform: manual (Chrome done; Android, macOS, Windows pending) |
| 2 | Airplane mode: 20 parties on Android, reconnect → on desktop within a minute | **Manual pending** | Upload queue / backoff covered by `upload_pending_test`; needs a real phone |
| 3 | Two devices edit the same party offline → last-write-wins, both edits in audit log | **Mechanism proven, manual pending** | `parties_repository_test` "writes only the changed fields (per-field last write wins)": the update uploads as PATCH of changed columns only, and each edit writes its own audit row (before/after). Needs two real devices |
| 4 | RLS pgTAP tests pass. CI green | **Pass** | `supabase test db` 63/63, `db lint` clean. CI run 36752398308 (a33b007): checks, pgTAP, web, Android, macOS and **Windows** all green after fix F2 |
| 5 | Settings editor changes a value at tenant and party scope; resolver shows the right source | **Pass** | `settings_screen_test` "owner sets a business rate; a party inherits it, then gets …"; khata_core resolver tests (100% covered) |

## Quality gate (`/verify full`)

| Check | Result |
|---|---|
| `dart format` | pass (0 changed) |
| `flutter analyze` (repo root) | pass, 0 issues |
| khata_core tests | 151 pass |
| mk_ui tests | 16 pass |
| app tests | 197 pass (incl. 6 new sync tests) |
| `supabase db reset` + `test db` + `db lint` (local Docker) | pass, 63 tests, no lint errors |
| `flutter build web` | pass |
| `flutter build apk --debug` | pass |
| `flutter build macos` | **fails locally only**: stale Sentry package in `build/macos` (`no submodule named '_Hybrid'`). The same commit builds in CI. Fix: `flutter clean` (see open items) |
| Windows | CI only; green after fix F2 (run 36752398308) |
| Rule scan: money as `double`, missing `tenant_id`, direct Supabase calls from screens, hard-coded rates | none found (review agent + schema consistency test) |

## Supabase advisors (dev)

| Advisor | Finding | Action |
|---|---|---|
| Security | 0029 `register_device` SECURITY DEFINER callable by `authenticated` | Already accepted (decisions.md 2026-09-30) |
| Security | Leaked password protection disabled | 🧑 Turn on in the dashboard: Authentication → Providers → Email → "Prevent use of leaked passwords" (may need a paid plan; then accept) |
| Performance | 6 unused indexes | Already accepted; dev data is tiny |

## Code review findings (independent subagent)

Clean areas: RLS on every table checks tenant; `keep_tenant_id` on every updatable table; composite FKs stop cross-tenant references; all SECURITY DEFINER functions set `search_path = ''`; sync streams match RLS; UI permission checks mirror SQL `role_allows` / `can_write_setting`; no `double` for money.

| # | Severity | Finding | Status |
|---|---|---|---|
| R1 | Medium (reported high) | A different user signing in wipes the local DB, including the previous user's unsent changes (`session.dart` `_adopt`) | **Open.** Downgraded because the normal sign-out already warns and offers "Upload, then sign out" (`sign_out_flow.dart`). Remaining gap: sign-out that skips the flow (session revoked or expired). Fix in 1.10 hardening: refuse to adopt a new user while `ps_crud` is not empty, with an owner-only "discard" |
| R2 | Medium | PATCH hidden by RLS updates 0 rows with no error → marked uploaded, change silently lost (`supabase_connector.dart`) | **Fixed (F1)** |
| R3 | Medium | A rejected entry doesn't stop the rest of its local transaction: e.g. duplicate party code → party rejected but its audit row lands | **Fixed in step 1.1**: `apply_crud_transaction` uploads each local transaction all-or-nothing; rejected transactions are kept, retried and discarded as one batch. Still open (low): local code check is case-insensitive, server unique is case-sensitive |
| R4 | Medium | Retry of a rejected insert when the row still exists locally re-queues it as PATCH | **Mitigated by F1**: it now lands back in sync_errors instead of vanishing. Proper fix (re-queue as PUT) in 1.10 |
| R5 | Medium | Audit log is client-written only; a member calling PostgREST directly can skip or forge audit rows (`device_id`, `created_at`) | **Open.** Add server-side audit triggers and a server receive time before the pilot (1.10); required for the ledger |
| R6 | Medium (product) | Any member (e.g. munshi) can set party / lot level commission and charges, per `settings-cascade.md` | **Accepted** by the owner 2026-09-30: munshis may change them; audited (decisions.md) |
| R7–R13 | Low | Unknown error codes retried forever (can block the queue); duplicate sync_errors rows on transient retry; `owner_audit` stream is role-based but RLS is permission-based; owner can add any user id without an invite; server-created settings rows use different ids from device v5 ids; dev sync panel writes differ from production; number_series counters not audited | **Open**, backlog for 1.10 hardening |

## Fixes applied in this review

| # | Fix | Files |
|---|---|---|
| F0 | (found during the manual sync test) `audit_log` uploads used upsert → 403 on every audit row. Append-only tables now upload as plain INSERT; duplicate on retry = done | `powersync_schema.dart`, `supabase_connector.dart`, test (committed in 53bef48) |
| F1 | PATCH asks for the row back (`select=id`); no row → rejection 42501 into `sync_errors` | `supabase_connector.dart`, `supabase_crud_applier_test.dart` |
| F2 | Windows CI build: define `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` (local_auth_windows `/await` vs VS 2026) | `windows/CMakeLists.txt`, decisions.md |
| F3 | Android Studio treated the SwiftPM `sentry-cocoa` checkout as a second git root, blocking push | `.idea/vcs.xml` (committed in 2829897) |

## Open items for you (🧑)

1. ~~CI Windows green~~ (done, run 36752398308). Run `windows-release` on a Windows PC and check the same parties appear.
2. Real Android phone: airplane mode, add 20 parties, reconnect → all on Chrome/macOS within a minute.
3. Two devices (phone + emulator/Chrome) offline, edit the same party, reconnect → last sync wins, both edits in Supabase `audit_log`.
4. As bali: `/dev/diagnostics` → Retry the 2 old rejected `audit_log` rows.
5. `cd apps/mandi_khata_app && flutter clean && flutter build macos` to clear the stale Sentry cache.
6. ~~Decide R6~~: decided 2026-09-30, munshis may change them.
7. Optional: leaked-password protection in Supabase Auth.
