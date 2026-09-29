# Mandi Khata — project guide for Claude Code

Read this file fully before any task. Then read the phase file you are asked to work on in `docs/phases/`, and the domain rules in `docs/domain/` that the task touches.

## What we are building

Mandi Khata is a multi-tenant, offline-first SaaS app for **arhtiyas (commission agents) and agri-input vendors** in Indian grain mandis (Punjab / Haryana / Rajasthan first).
It is sold on subscription. Every business (tenant) configures its own rules: interest rate, simple vs compound (chakravardhi byaj), compounding period, commission %, mandi charges, price tiers, modules on/off, role permissions.

Platforms shipped: **Windows desktop (primary, shop counter)**, **macOS desktop**, **Android (munshi at the mandi gate)**, **Web (owner / accountant)**.

Development happens on a **MacBook**. See "Development environment" below — Windows is a build target, not a local one.
The app must work **fully offline**. Every screen, search, report and interest calculation runs against the local database. Data syncs to the backend whenever internet is available.

Languages: English, Hindi (हिंदी), Punjabi (ਪੰਜਾਬੀ).

## Tech stack (do not change without asking)

| Layer | Choice |
|---|---|
| App | Flutter (stable), Dart 3.x, null-safe |
| State | Riverpod (`flutter_riverpod`, `riverpod_annotation`, code-gen) |
| Routing | `go_router` |
| Local DB | PowerSync SQLite (`powersync`) + Drift for typed queries (`drift`, `powersync` drift integration) |
| Sync | PowerSync (Cloud first, self-host later) |
| Backend | Supabase — Postgres, Auth (phone OTP), Row Level Security, Edge Functions (Deno/TypeScript), Storage. Region: Mumbai (ap-south-1) |
| Models | `freezed` + `json_serializable` |
| i18n | Flutter `gen_l10n` with ARB files (`en`, `hi`, `pa`) |
| PDF / print | `pdf`, `printing` |
| Payments (SaaS billing) | Razorpay Subscriptions via Supabase Edge Function webhooks |
| Errors | `sentry_flutter` |
| Tests | `test`, `flutter_test`, `mocktail`, `integration_test` |

## Repository layout

```
mandi_khata/
├── CLAUDE.md
├── pubspec.yaml                 # Dart pub workspace root
├── apps/
│   └── mandi_khata_app/         # Flutter app (windows, macos, android, web)
│       └── lib/
│           ├── main.dart
│           ├── app/             # router, theme, l10n, bootstrap
│           ├── core/            # db, sync, auth, settings, permissions, utils
│           ├── features/        # one folder per feature (see below)
│           └── shared/          # shared widgets
├── packages/
│   ├── khata_core/              # PURE DART. Money, interest engine, mandi charges, ledger maths. No Flutter, no DB.
│   └── mk_ui/                   # design system: tokens, theme, reusable widgets
├── supabase/
│   ├── migrations/              # SQL migrations, numbered
│   ├── functions/               # Edge Functions (TypeScript)
│   ├── seed.sql
│   └── tests/                   # pgTAP tests for RLS
├── powersync/
│   └── sync-rules.yaml
└── docs/
    ├── ROADMAP.md
    ├── phases/
    └── domain/
```

Feature folder shape (`lib/features/<feature>/`):
```
data/          # repositories (read/write local DB), DTOs
domain/        # entities, use-cases (call khata_core for maths)
presentation/  # screens, widgets, riverpod providers/controllers
```

## Non-negotiable rules

1. **Multi-tenant.** Every business table has `tenant_id uuid not null`. Every RLS policy checks it. Every local query filters by the active tenant. Never write a query without the tenant filter.
2. **Offline first.** UI reads and writes ONLY the local PowerSync database. Never call Supabase directly from a screen for business data. Only auth, billing and file upload may go online, and they must degrade gracefully offline.
3. **IDs are client-generated UUID v4** (`uuid` package). Never rely on server sequences for primary keys.
4. **Money is `int` paise.** Never `double` for money. Use the `Money` type from `khata_core`. Format with Indian grouping (₹1,55,580 and ₹13.28 L).
5. **Ledger is append-only.** Never update or delete a posted ledger entry. A correction = a reversal entry + a new entry, both linked. Soft-delete (`deleted_at`) only for master data (parties, products).
6. **All business maths lives in `packages/khata_core`**, pure Dart, 100% unit tested. The app and Edge Functions never duplicate it.
7. **Configuration is data, not code.** Rules resolve through the settings cascade: system default → tenant → party → document (loan / lot). See `docs/domain/settings-cascade.md`. Never hard-code a rate, percentage or charge.
8. **Every write is audited.** Each insert/reversal writes an `audit_log` row (who, device, role, before/after, time).
9. **Permissions are checked in two places:** in the UI (hide/disable) and in RLS / the sync upload handler (enforce).
10. **Human-readable numbers** (receipt R-3008, lot L-445, invoice SI-7741) are per-tenant, per-series, and must not collide offline: use `<series>-<deviceCode>-<counter>` locally.
11. **Dates:** store `timestamptz` in UTC on server, ISO-8601 text in SQLite. Business date (`entry_date`) is a separate `date` column in the tenant's local date. Financial year April–March.
12. **i18n:** no hard-coded user-facing strings. Add every string to all three ARB files (put the English text in `hi`/`pa` with a `TODO(translate)` note if a translation is unknown).
13. **Accessibility:** min touch target 48 px on mobile; keyboard shortcuts on desktop for all data-entry screens.

## Coding conventions

- Run `dart format .` and `flutter analyze` with zero warnings before finishing any task.
- Use `very_good_analysis` lint rules.
- Riverpod: code-gen providers (`@riverpod`). No global mutable state.
- Repositories return `Stream` for lists (reactive from local DB) and `Future` for single writes.
- Errors: use a `Result`/sealed failure type in domain layer; never swallow exceptions.
- Widgets: keep screens under ~300 lines; extract widgets.
- Every new table: migration SQL + RLS policy + pgTAP test + PowerSync sync rule + Drift table + repository + tests.
- Commit messages: Conventional Commits (`feat(khata): …`, `fix(interest): …`).

## Commands

```bash
# Workspace
dart pub get
dart run build_runner build --delete-conflicting-outputs   # inside a package/app

# Tests
cd packages/khata_core && dart test
cd apps/mandi_khata_app && flutter test

# Run — daily development (macOS dev machine)
flutter run -d chrome --web-renderer canvaskit             # primary quick loop
flutter run -d <android-emulator-id>                       # primary quick loop
flutter run -d macos                                       # desktop check
# flutter run -d windows                                   # only on a real Windows PC

# Supabase (local stack — OPTIONAL, needs Docker running)
supabase start
supabase db reset          # re-applies migrations + seed
supabase test db           # pgTAP RLS tests
supabase functions serve
```

## Definition of done (every task)

- [ ] Code compiles on macOS, Android and Web locally; Windows is built by CI (`windows-latest`), never on the dev machine.
- [ ] `flutter analyze` clean, `dart format` applied.
- [ ] Unit tests for any logic; `khata_core` changes have tests with worked examples.
- [ ] Works with network OFF, and syncs correctly when turned back ON.
- [ ] Tenant isolation verified (RLS test or repository test).
- [ ] Strings added to en / hi / pa ARB files.
- [ ] Audit log written for every business write.
- [ ] Short summary of what changed + how to test it manually.

## How to work

- Progress lives in `docs/PROGRESS.md`. Work through it with the `/next-step` skill: one step at a time, never skip ahead, tick the step only after `/verify` passes.
- Before coding a step, restate the plan in 5–10 bullets and list files you will create/change. Then implement.
- New tables always via the `/new-table` skill checklist. Features that write data get a `/sync-check`.
- If a domain rule is unclear, check `docs/domain/`. If still unclear, ask. Do not guess on money logic.
- When a business rule changes, update `docs/domain/*.md` first, then code, then add a line to `docs/decisions.md`.
- Design reference: the HTML prototype `design/Mandi_Khata.html` (colours, layout, screen list). Match its look. The prototype's data and logic are NOT authoritative; `docs/domain/` is.
- Use subagents for independent code review and for broad searches; keep the main context for building.

## Development environment

- The dev machine is a **MacBook**. Daily testing is the **Android emulator** and **Chrome** (`flutter run -d chrome`); `-d macos` for a desktop sanity check.
- **Never run `flutter build windows` or `flutter run -d windows` locally** — it cannot work on macOS. Windows is built only by GitHub Actions on a `windows-latest` runner; the user tests that build on a real Windows PC before the pilot. Keep `windows` in the app's target platforms regardless.
- The app runs against the **online Supabase dev project and PowerSync Cloud**, configured through `.env.dev` (`--dart-define-from-file=.env.dev`). This is the normal path — no Docker needed to run the app.
- The **local Supabase stack (Docker) is optional** and used only for `supabase db reset` and `supabase test db`. If Docker is not running, do not try to start the stack: instead ask the user to approve `supabase db push` to apply migrations to the dev project, and let the pgTAP tests run in CI.
- **Android emulator + local Supabase:** the emulator cannot reach the host's `127.0.0.1`/`localhost`. If the app is ever pointed at a local Supabase or PowerSync, use **`10.0.2.2`** in place of `127.0.0.1` in the Android config. This does not apply when using the online dev project (the normal case).

## Supabase & tools

- The `supabase` MCP server is connected to the **dev** project only. Use it to: list tables/migrations, read logs, run security and performance advisors, search Supabase docs, deploy Edge Functions to dev.
- **Never change schema with `execute_sql`.** Schema = migration files in `supabase/migrations/` created with `supabase migration new`, then applied to dev (`supabase db push` or MCP `apply_migration` with identical SQL). `execute_sql` is for read queries and debugging only.
- Test migrations locally with `supabase db reset` + `supabase test db` **when Docker is running**. When it is not, skip the local stack: ask the user to approve `supabase db push` to dev, and rely on CI for the pgTAP RLS tests.
- Never try to access production: no prod project ref, no `.env.prod`, no linking to prod. Production changes go through the GitHub Actions workflow the user approves.
- Never put the service-role key or any secret in Flutter code. Secrets for Edge Functions go in Supabase secrets (`supabase secrets set`), set by the user.
- Use the Dart & Flutter MCP server (if connected) for analyzer diagnostics, running tests and hot reload instead of guessing.
- Before using any Supabase/PowerSync/package API you are unsure of, check current docs (Supabase MCP `search_docs`, pub.dev) rather than relying on memory.
