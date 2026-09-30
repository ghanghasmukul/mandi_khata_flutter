# Build progress

Claude Code updates this file at the end of every step (`/next-step`). Tick = done and verified.
Format for a done step: `- [x] 0.1 Monorepo scaffold (2026-10-01): note`
🧑 = needs something only you can do (account, key, device, customer).

## Setup (you, once): see docs/SETUP.md
- [ ] 🧑 Tools installed, `flutter doctor` green for macOS + Android + Web on the Mac; Windows target verified on a Windows machine or CI
- [ ] 🧑 Supabase dev + prod projects (Mumbai), PowerSync dev instance
- [ ] 🧑 `.mcp.json` has the dev project ref; `/mcp` shows supabase connected
- [ ] 🧑 Dart & Flutter plugin installed in Claude Code
- [x] 🧑 `.env.dev` created; `supabase link` to dev done (2026-09-29): linked to `nqsaezlfqfrbrrleilyb`; `POWERSYNC_URL` still blank until the PowerSync instance exists

## Phase 0: Foundation
- [x] 0.1 Monorepo scaffold (2026-09-29): pub workspace + app/khata_core/mk_ui, very_good_analysis clean, 3 tests pass, `flutter build web` OK. Manual run on macOS/Chrome/emulator still to be confirmed by user.
- [x] 0.2 Design system (mk_ui) (2026-09-29): tokens, light theme + dark stub, bundled offline fonts (Plex Sans/Mono, Noto Devanagari/Gurmukhi), 15 widgets + responsive MkAppShell (sidebar ≥1000 / rail 600–999 / bottom <600, Ctrl/⌘K), `Money` format/short/tryParse in khata_core, `/dev/gallery` (debug only). 80 tests pass; web, macOS and debug APK build.
- [x] 0.3 Supabase schema: tenancy, users, settings, audit, parties (2026-09-30): 2 migrations, 9 tables with RLS, `private.auth_tenant_ids()` / `has_permission()`, `register_device()`, append-only audit log, seed (2 businesses × 3 users × 12 parties). 63 pgTAP tests pass locally, db lint clean, pushed to dev; advisors: 1 accepted warning, 9 unused-index infos (see decisions.md).
- [x] 0.4 PowerSync sync rules + local database (2026-09-30): `powersync` publication (pushed to dev), `powersync/sync-streams.yaml` (edition 3), PowerSync schema + Drift tables, Supabase connector (backoff, permanent errors → local `sync_errors`), sync status chip (en/hi/pa), web WASM/worker, debug Sync lab. 37 app tests incl. real-PowerSync upload tests; web/macOS/APK build. 🧑 still to do: PowerSync instance + role + deploy streams + `POWERSYNC_URL` (docs/SETUP.md step 2), then the offline → online test in Sync lab.
- [x] 0.5 Auth, tenant selection, devices (2026-09-30): phone OTP (+91) + email login, session-owned local DB (new user → wipe first), offline launch on cached session, business picker from local DB (auto-pick single, remember last), `register_device()` per business, PIN lock (PBKDF2, cooldown, 2-min background) + Android biometric, sign-out with unsynced-changes warning, go_router gate. 104 app tests; web/macOS/APK build. 🧑 still to do: enable Phone provider / test OTP numbers and link a dev user to a business (docs/SETUP.md step 2.3), then test on emulator + Chrome.
- [x] 0.6 Settings cascade + permissions (2026-09-30): khata_core settings schema (all v1 keys, validation, per-crop/role/doc/module suffixes), level-first resolver, Permission/MemberRole rules mirroring SQL (100% covered, 122 tests); app SettingsRepository (validated, audited, deterministic row ids), reactive `settingProvider(key, target)`, generic settings editor (business / party scope, "from X", reset), `canProvider` + `PermissionGate`, role table checked against SQL. 142 app tests; pgTAP 63 pass; web/macOS/APK build.
- [ ] 0.7 Audit, number series, i18n, error reporting
- [ ] 0.8 Parties screen (pipeline proof) + CI
- [ ] Phase 0 review (`/phase-review 0`) + 🧑 manual offline test on a real Android phone

## Phase 1: Core Mandi Khata (MVP)
- [ ] 1.1 Ledger core
- [ ] 1.2 Crops & mandi charge settings
- [ ] 1.3 Arrivals & lots
- [ ] 1.4 Khata screens
- [ ] 1.5 Payments & receipts
- [ ] 1.6 Dashboard
- [ ] 1.7 Reports v1 + export
- [ ] 1.8 Users, roles, audit log screen
- [ ] 1.9 Onboarding & opening balances import
- [ ] 1.10 Hardening & pilot build
- [ ] 1.11 Production environment & release pipeline (🧑 approve prod migration)
- [ ] Phase 1 review + 🧑 pilot with 2–3 arhtiyas; feedback recorded in docs/decisions.md

## Phase 2: Karza & Byaj
- [ ] 2.1 Interest engine (tests first)
- [ ] 2.2 Loans data & screens
- [ ] 2.3 Khata-level interest
- [ ] 2.4 Posting interest & settlement
- [ ] 2.5 Reports & alerts
- [ ] 2.6 Verification (🧑 compare 10 real accounts with pilot arhtiyas)
- [ ] Phase 2 review

## Phase 3: Accounting
- [ ] 3.1 Chart of accounts & journal (🧑 approve docs/domain/posting-rules.md)
- [ ] 3.2 Voucher entry
- [ ] 3.3 Cash book, bank book, reconciliation
- [ ] 3.4 Expenses
- [ ] 3.5 Financial statements & year close
- [ ] 3.6 Tally export (🧑 test import in Tally Prime)
- [ ] Phase 3 review

## Phase 4: Input shop
- [ ] 4.1 Products, batches, stock
- [ ] 4.2 Purchases
- [ ] 4.3 POS
- [ ] 4.4 Shop sales, returns, receivables & payables
- [ ] 4.5 Shop profit & GST (🧑 CA checks 5 invoices)
- [ ] Phase 4 review

## Phase 5: SaaS layer
- [ ] 5.1 Plans & entitlements (🧑 decide plan prices)
- [ ] 5.2 Razorpay subscriptions (🧑 Razorpay account + test keys as Supabase secrets)
- [ ] 5.3 Lifecycle: trial, grace, lock
- [ ] 5.4 Super-admin console
- [ ] 5.5 Self-serve signup & onboarding
- [ ] Phase 5 review

## Phase 6: Polish & scale
- [ ] 6.1 WhatsApp & SMS (🧑 WhatsApp BSP account + approved templates)
- [ ] 6.2 Printing (🧑 test on real thermal printer)
- [ ] 6.3 Documents & KYC
- [ ] 6.4 Backup, restore, export
- [ ] 6.5 Data import
- [ ] 6.6 Performance & reliability
- [ ] 6.7 Distribution & updates (🧑 Play Console, code-signing certificate, domain)
- [ ] Phase 6 review → public launch
