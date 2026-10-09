# Phase 5 review (SaaS layer)

Reviewed 2026-10-09 by the author (no independent reviewer was run). Gates run: `dart format`, `flutter analyze` (workspace root, 0 issues), khata_core 767 tests, app tests (all new ones pass; `hardening/performance_test.dart` is the known Phase 3 failure), mk_ui 16, mk_admin 11, pgTAP 635 on the local stack (new: 24 saas core 58, 25 admin + signup 41, 26 admin functions 21), `supabase db lint` clean, Edge Functions type-checked with Deno and exercised against the local stack (signup RPC, `entitlement-token`, `admin-api`: me / overview / tenant_detail / plans / update_subscription / support_start), web build of the app and of mk_admin. Windows is built by CI only. **Advisors on dev: run after the push (nothing to fix, see decisions.md). **Not run:** a real device through a lock / unlock, two devices, PowerSync with the new streams.

## Exit criteria

| # | Criterion | Status |
|---|---|---|
| 1 | New customer can sign up, pay via UPI autopay, and start working without talking to you | **Half**: signup -> trial -> onboarding wizard works without you (RPC tested end to end, widget-tested screen). Paying online is not built (Razorpay deferred by you); payment is manual |
| 2 | Failed payment -> grace -> read-only lock works, even for a device that stays offline | **Proven by tests, not on a device**: every transition in khata_core `Lifecycle` and the SQL mirror, the offline tolerance, the read-only membership, the server refusing writes (pgTAP 24). Needs a manual run (below) |
| 3 | You can change any customer's defaults from the admin console and it syncs to their devices | **Server side proven** (`admin_set_tenant_setting` writes the same settings row id the app uses and a "support" audit row; verified through the Edge Function). Arrival on a device uses the existing settings stream: not tested on a device |

## Findings

| # | Sev | Finding | Outcome |
|---|---|---|---|
| 1 | H | `setState(() => _future = _load())` returned a Future in 4 admin screens (asserts at runtime) | Fixed; the widget tests caught it |
| 2 | H | Party-limit pre-check read an auto-dispose provider nobody listened to (always "loading", so it never fired; and threw after dispose in tests) | Fixed: the check is inside the save transaction (`maxParties`), atomic, tested |
| 3 | M | `TextEditingController` disposed right after `showDialog` returned (used while the dialog animates out) in the support and request dialogs | Fixed: `promptText` owns its controller |
| 4 | M | `guard_user_limit` read `new.is_active` on tables without it (plpgsql does not short-circuit); broke every invite | Fixed; pgTAP 09 caught it |
| 5 | M | Seeds and caches would be blocked by the module gate for a plan without the module (signup of a "shop" business, batch cache) | Fixed: triggers skip nested trigger work (`pg_trigger_depth() > 1`) and calls with no signed-in user; tested |
| 6 | M | A token must not extend a subscription from a tampered local DB, nor an old token override a renewal | Rule: a token wins only when issued after the row's `updated_at`; tested both ways |
| 7 | L | Opening-balance import does not check the party limit before saving (server refuses afterwards, shown as a sync error) | **Open**, recorded in decisions.md |
| 8 | L | Users / devices limits show the server's refusal (invite dialog has a clear message; device registration reuses "device limit reached") rather than a pre-check | Accepted |
| 9 | L | Announcements are visible on every customer device by design; targeting is by plan only (done on the device) | Documented in the console and in decisions.md |
| 10 | L | Plan `default_settings` are validated by the app against the settings schema (invalid = ignored), not when saved in the console | **Open**: the console accepts any JSON |
| 11 | L | Console is English only; hi / pa billing strings unreviewed | Accepted / for a native speaker |
| 12 | L | A locked munshi cannot export (`finance.view` is not a munshi default) | Accepted |
| 13 | L | `platform_admins` can only be added by SQL | By design |

## Manual checks for you
1. (Migrations pushed.) Deploy `powersync/sync-streams.yaml`. Follow docs/saas-setup.md (key pair, secrets, `functions deploy`, first admin).
2. In the console: set real prices; add yourself as admin; open a test business and try **Lock now** -> the app on a phone must turn read-only within a sync; **Mark paid +30 days** -> writable again.
3. Offline lock: set a business's *Paid until* to yesterday and *Grace days* 0, take a phone offline, check the "connect to confirm" banner, then (after the tolerance, or with the setting at 0) read-only. Reconnect: back to normal after renewal.
4. Create a business from a fresh phone number (Android, Chrome): picker -> Create a new business -> trial -> wizard.
5. Have a Hindi and a Punjabi speaker read the new billing / banner / signup strings.
