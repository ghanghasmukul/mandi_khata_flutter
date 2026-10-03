# Mandi Khata

Multi-tenant, offline-first khata and accounting app for **arhtiyas** (commission
agents) and agri-input vendors in Indian grain mandis.

Ships to Windows (shop counter), macOS, Android (munshi at the gate) and Web.
Everything works offline; data syncs through PowerSync when there is internet.

See [`CLAUDE.md`](CLAUDE.md) for the rules, [`docs/ROADMAP.md`](docs/ROADMAP.md)
for the plan and [`docs/PROGRESS.md`](docs/PROGRESS.md) for where we are.

## Layout

This is a Dart pub workspace — one lockfile at the root, three members.

| Path | What it is |
|---|---|
| `apps/mandi_khata_app` | The Flutter app (android, macos, web, windows) |
| `packages/khata_core` | Pure Dart. Money, interest, mandi charges, ledger maths. No Flutter, no DB. |
| `packages/mk_ui` | Design system: tokens, theme, shared widgets |
| `supabase/` | Migrations, Edge Functions, pgTAP tests |
| `docs/` | Roadmap, per-phase specs, domain rules |
| `design/` | The HTML prototype used as the visual reference |

## Setup

One-time setup (accounts, tooling, keys) is in [`docs/SETUP.md`](docs/SETUP.md).

Copy `.env.example` to `.env.dev` and fill it in — it is git-ignored and must
never be committed. Only the Supabase **anon/publishable** key belongs there,
never the service-role key.

```bash
flutter pub get          # resolves the whole workspace
```

## Run

Development happens on macOS. Daily testing is Chrome and the Android emulator.

```bash
cd apps/mandi_khata_app

flutter run -d chrome  --dart-define-from-file=../../.env.dev
flutter run -d macos   --dart-define-from-file=../../.env.dev
flutter emulators --launch Pixel_10
flutter run -d emulator-5554 --dart-define-from-file=../../.env.dev
```

Always run from `apps/mandi_khata_app`. The repo root is only a pub workspace,
so `flutter run` there fails with `Target file "lib/main.dart" not found`. In
Android Studio use the shared **main.dart** run configuration: it points at
`apps/mandi_khata_app/lib/main.dart` and passes `.env.dev`.

## Environments

| | Dev | Production |
|---|---|---|
| Config | `.env.dev` (copy `.env.example`, git-ignored) | no `.env.prod` file exists; `release.yml` writes one from GitHub variables / secrets at build time |
| `APP_ENV` | `dev`: the app shows an orange **DEV** ribbon | `prod`: no ribbon |
| Backend | dev Supabase + PowerSync | prod Supabase + PowerSync |
| Database changes | `supabase db push` to dev | `deploy-db.yml` (tag `db-v*`, approval in the `production` environment) |
| App builds | `flutter run` on your Mac | `release.yml` (tag `v*`): Windows installer, macOS dmg, Android AAB, web zip, in a draft GitHub Release |

`.env.*` is git-ignored except `.env.example`. Never put production values on a
dev machine or in the repo. Secrets, variables and the release / rollback
procedures are in [`docs/ops.md`](docs/ops.md).

Windows is **not** built on the Mac — Flutter cannot cross-compile it. CI builds
it on a `windows-latest` runner and it is tested on a real Windows PC before the
pilot.

## Offline database and sync

The app reads and writes only a local SQLite database (PowerSync + Drift);
PowerSync syncs it with Supabase in the background. Setup of the PowerSync
instance is in [`docs/SETUP.md`](docs/SETUP.md) (step 2), the sync definitions
are in `powersync/sync-streams.yaml`.

**Web** needs two files in `apps/mandi_khata_app/web/`, committed to the repo:
`sqlite3.wasm` and `powersync_db.worker.js`. After upgrading the `powersync`
package, refresh them:

```bash
cd apps/mandi_khata_app && dart run powersync:setup_web
```

Debug builds have a **Sync lab** (`/dev/sync`, button on the home screen) for
testing offline writes and sync before the real login and screens exist.

## Test

```bash
dart format .
flutter analyze

cd packages/khata_core && dart test
cd apps/mandi_khata_app && flutter test
```

## Database

Schema changes are **only ever** migration files in `supabase/migrations/`,
never ad-hoc SQL.

```bash
supabase migration new <name>

# With Docker running — test destructively first:
supabase db reset
supabase test db

# Then apply to the dev project:
supabase db push
```

If Docker is not running, skip the local stack: apply migrations to the dev
project with `supabase db push` and let the pgTAP tests run in CI.
