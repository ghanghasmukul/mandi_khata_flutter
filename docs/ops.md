# Operations: production, releases, backups, incidents

Rule: **Claude and developers never connect to production.** Production changes
happen only through the GitHub Actions workflows below, approved by a human.
The dev project (`nqsaezlfqfrbrrleilyb`) is the only one tools may touch.

## Environments

| | Dev | Production |
|---|---|---|
| Supabase | dev project (Mumbai) | prod project (Mumbai, separate) |
| PowerSync | dev instance | prod instance (separate) |
| App config | `.env.dev` (git-ignored, on your Mac) | no file on any machine; GitHub variables / secrets, written to a temp file by `release.yml` |
| `APP_ENV` | `dev` (orange DEV ribbon) | `prod` (no ribbon) |
| Schema changes | `supabase migration new` + `db push` to dev | `deploy-db.yml` only |

## One-time GitHub setup (you)

Settings > Environments > **New environment** `production`, tick **Required
reviewers** and add yourself (and a second person if you have one). Optionally
restrict deployment branches/tags.

### Secrets and variables

| Name | Kind | Where to add | Used by | Notes |
|---|---|---|---|---|
| `SUPABASE_ACCESS_TOKEN` | secret | Repository secrets | deploy-db | Supabase dashboard > Account > Access Tokens |
| `SUPABASE_PROD_DB_PASSWORD` | secret | **production environment** secrets | deploy-db | Prod project database password |
| `SUPABASE_PROD_PROJECT_REF` | variable | **production environment** variables | deploy-db | Prod project ref (20 chars) |
| `SUPABASE_DEV_PROJECT_REF` | variable | Repository variables | deploy-db drift check | `nqsaezlfqfrbrrleilyb` |
| `SUPABASE_DEV_DB_PASSWORD` | secret | Repository secrets | deploy-db drift check | Dev database password |
| `PROD_SUPABASE_URL` | variable | Repository variables | release | Prod API URL |
| `PROD_SUPABASE_ANON_KEY` | variable | Repository variables | release | Prod publishable/anon key. Never the service-role key |
| `PROD_POWERSYNC_URL` | variable | Repository variables | release | Prod PowerSync instance URL |
| `PROD_SENTRY_DSN` | secret | Repository secrets | release | Optional; blank keeps error reporting off |
| `PROD_UPDATE_MANIFEST_URL` | variable | Repository variables | release | Optional. Where the installed apps fetch `latest.json` (below). Blank = no in-app update check |
| `PROD_DOWNLOAD_BASE_URL` | variable | Repository variables | release | Optional. Folder holding the installers; default is the GitHub Release download URL (only reachable by customers if the repo is public) |
| `APP_MIN_SUPPORTED` | variable | Repository variables | release | Optional, default `1.0.0`. Older builds get a non-dismissable "update now" banner |
| `PROD_ANDROID_STORE_URL` | variable | Repository variables | release | Optional. Play Store link put in the Android entry of `latest.json` |

Signing (all optional; each signing step is skipped, with a warning, when its
secrets are missing; the signing steps are written but have never been run):

| Secret | Purpose |
|---|---|
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | Upload key (`base64 -i upload.jks`). Without it the AAB is debug-signed and Play rejects it |
| `WINDOWS_CERT_PFX_BASE64`, `WINDOWS_CERT_PASSWORD` | Code-signing certificate for the installer. Without it SmartScreen warns |
| `MACOS_CERT_P12_BASE64`, `MACOS_CERT_PASSWORD`, `MACOS_SIGNING_IDENTITY` | Developer ID Application certificate (`Developer ID Application: Name (TEAMID)`) |
| `APPLE_ID`, `APPLE_APP_PASSWORD`, `APPLE_TEAM_ID` | Notarization (app-specific password) |

Edge Function secrets (Razorpay etc.) are NOT in GitHub: you set them with
`supabase secrets set` against prod yourself.

## Database release (`deploy-db.yml`)

1. Merge the migration PR to `main`; CI is green.
2. Tag the merge commit: `git tag db-v1.0.0 && git push origin db-v1.0.0`
   (or Actions > Deploy database > Run workflow).
3. Pre-checks run automatically and must pass:
   - commit is on `main`
   - fresh local stack: `supabase db reset` + `supabase test db` + lint
   - drift: `supabase db diff --linked` against **dev** is empty (nothing
     applied to dev by hand that is missing from `supabase/migrations/`)
4. The `deploy` job waits for the required reviewer. Open it, read the
   **dry run** output of the pending migrations, then approve.
5. It runs `supabase link` (prod), `db push`, then `functions deploy` (if the
   repo has functions).

Take a manual backup (below) immediately before approving any migration that
alters or drops existing data.

## App release (`release.yml`)

Push a tag `vX.Y.Z` (`git tag v1.0.0 && git push origin v1.0.0`). The workflow
checks the `PROD_*` variables exist, runs analyze and tests, builds the four
targets with `APP_ENV=prod`, and creates a **draft** GitHub Release with the
files. Read the draft, test the installers, then publish it by hand. Windows is
built only on the `windows-latest` runner.

Order for a release that needs schema changes: `db-v*` first, then the
PowerSync sync streams, then `v*`.

## Packaging and updates (step 1.10)

What `release.yml` (step 1.11) builds, and what has and has not been verified.
Nothing below has run on GitHub yet: the first `v*` tag is the first real run.

| Target | Artifact | How it is built | Verified so far |
|---|---|---|---|
| Windows | `MandiKhata-Setup-X.Y.Z.exe` (Inno Setup, per-user install by default, desktop-shortcut task, uninstaller) | `windows-latest`: `flutter build windows --release`, then `ISCC` on `apps/mandi_khata_app/windows/installer/mandi_khata.iss` | Script read, not run. Never built on the Mac. Try it on a real PC (see `docs/pilot-checklist.md`) |
| macOS | `MandiKhata-X.Y.Z.dmg` | `macos-latest`: `flutter build macos --release`, `hdiutil`, optional notarization | `flutter build macos` works on the Mac; dmg and notarization steps not run |
| Android | `app-release.aab` | `flutter build appbundle --release`; env-based upload-key signing | `flutter build apk --debug` works; AAB is debug-signed without the keystore secrets and Play rejects it |
| Web | `mandi-khata-web-X.Y.Z.zip` (static) | `flutter build web --release` with the prod env | `flutter build web --release` works; served locally with the headers below |

### In-app update check

There is no store on Windows / macOS, so the app asks for a small
`latest.json` on start: one GET, 8 s timeout, silent when offline or when the
server is unreachable; web and dev builds never check. (Not `version.json`:
Flutter writes its own file of that name into every web build.)

```json
{
  "version": "1.2.0",
  "min_supported": "1.0.0",
  "notes": "Cheque reminders on the dashboard.",
  "downloads": {
    "windows": "https://downloads.example.com/MandiKhata-Setup-1.2.0.exe",
    "macos": "https://downloads.example.com/MandiKhata-1.2.0.dmg",
    "android": "https://play.google.com/store/apps/details?id=com.example.mandi_khata_app"
  }
}
```

If `version` is newer than the running build and there is a link for the
platform, a strip "Mandi Khata 1.2.0 is available [Download] [Later]" shows on
the home screen. "Later" hides that version only. A build below `min_supported`
gets a red strip with no "Later". Installing is manual: Download opens the
link, the installer replaces the old version in place (same `AppId`), and the
local database is untouched.

How to publish it:

1. `release.yml` writes `latest.json` into the draft release (version from the
   tag, `min_supported` from `APP_MIN_SUPPORTED`, links from
   `PROD_DOWNLOAD_BASE_URL`).
2. Once you publish the release, upload that file to the **web host root**, so
   it is served at `https://<your-web-host>/latest.json`, and set the variable
   `PROD_UPDATE_MANIFEST_URL` to that URL **before** tagging the release that
   first ships the check. (The URL is baked into the app at build time.)
3. Host the installers somewhere customers can download them without a GitHub
   login (a public release, or an R2 / Drive link) and set
   `PROD_DOWNLOAD_BASE_URL` to that folder.

To raise the floor (e.g. after a breaking sync change), set `APP_MIN_SUPPORTED`
and re-run the manifest step, or edit `latest.json` on the host by hand.

### Web deploy (Cloudflare Pages, static)

The web app is a static bundle; there is no server code. Two things matter:

* **Cross-origin isolation headers.** PowerSync / sqlite3 run in a WASM worker
  that uses `SharedArrayBuffer`, which browsers only allow on a page served with
  `Cross-Origin-Opener-Policy: same-origin` and
  `Cross-Origin-Embedder-Policy: credentialless`. They are in
  `apps/mandi_khata_app/web/_headers`, which `flutter build web` copies into the
  bundle. (`credentialless` rather than `require-corp` so cross-origin requests
  need no CORP header; the app loads no third-party scripts or fonts.)
  `sqlite3.wasm` and `powersync_db.worker.js` must be in `web/` (README,
  "Offline database and sync").
* **SPA fallback.** A refresh on `/parties/123` must return `index.html`; that is
  `web/_redirects` (`/* /index.html 200`).

Deploy (once per release, after the draft release is published):

```bash
unzip mandi-khata-web-X.Y.Z.zip -d site
cp latest.json site/latest.json            # the update manifest, see above
npx wrangler pages deploy site --project-name mandi-khata
```

First time: create the project (Cloudflare dashboard > Workers & Pages >
Create > Pages > Direct Upload, or `npx wrangler pages project create
mandi-khata`), add the custom domain, and add that domain to Supabase
(Authentication > URL configuration > Site URL / Redirect URLs). Test locally
with the same headers and fallback first:

```bash
cd apps/mandi_khata_app && flutter build web --release --dart-define-from-file=../../.env.dev
python3 ../../scripts/hardening/serve_web.py build/web 8099   # http://localhost:8099
```

Firebase Hosting instead (same rules; `firebase.json` at the repo root, deploy
the unzipped `site/` folder with `"public": "site"`):

```json
{
  "hosting": {
    "public": "site",
    "ignore": ["firebase.json", "**/.*"],
    "rewrites": [{ "source": "**", "destination": "/index.html" }],
    "headers": [
      { "source": "**", "headers": [
        { "key": "Cross-Origin-Opener-Policy", "value": "same-origin" },
        { "key": "Cross-Origin-Embedder-Policy", "value": "credentialless" } ] },
      { "source": "/{index.html,flutter_bootstrap.js,flutter_service_worker.js,latest.json}",
        "headers": [{ "key": "Cache-Control", "value": "no-cache" }] }
    ]
  }
}
```

Safari does not support `credentialless`: there the app falls back to the
browser's IndexedDB storage (slower, still works). The pilot uses Chrome / Edge
on the web and the installed apps at the counter.

## PowerSync production instance

1. powersync.com dashboard > new instance for the **prod** Supabase project
   (region close to Mumbai).
2. Connect the database with a dedicated replication role (the SQL is in
   `docs/SETUP.md` step 2; run it on the prod database from the Supabase SQL
   editor yourself, not through tools). The `powersync` publication is created
   by migrations, so it exists after the first `db-v*` deploy.
3. Auth: enable Supabase Auth with the prod project's JWT secret / JWKS.
4. Deploy sync config: paste or deploy `powersync/sync-streams.yaml` (edition 3)
   in the instance's Sync Streams editor, or with the PowerSync CLI. **Redeploy
   it whenever that file changes**, after the migration that adds the tables it
   references. The order is always: migration, then sync streams, then app.
5. Copy the instance URL into the GitHub variable `PROD_POWERSYNC_URL`.
6. Smoke test with a release build: sign in, create a party, confirm it appears
   in the prod `parties` table and on a second device.

## Backups and restore

- Supabase **Point-in-Time Recovery** needs the Pro plan with the PITR add-on.
  Enable it on the prod project (Database > Backups) before the pilot. Daily
  backups alone can lose up to a day of ledger entries.
- Before risky releases: Database > Backups > take a manual backup, or
  `supabase db dump` from a trusted machine.
- Restore drill: restore PITR into a **new** project, check row counts and a
  few party balances, then discard it. Do it once before go-live and write the
  result in `docs/decisions.md`.
- Devices keep a full local copy; after a restore the app re-syncs. Entries
  made on devices after the restore point re-upload (ids are client UUIDs, so
  they do not duplicate).

## Rolling back a bad migration

Never edit or delete an applied migration, and never `db reset` prod.

1. Stop the bleeding: if the app is the problem, stop distributing the build
   (unpublish the draft release / pause rollout).
2. Write a **new forward-fix migration** (`supabase migration new fix_...`) that
   reverts or repairs the change; test it with `db reset` + `test db` and on dev.
3. Ship it through `deploy-db.yml` like any other migration.
4. If data was damaged, restore PITR to a new project and copy the missing rows
   back with a reviewed SQL script.
5. Record what happened in `docs/decisions.md`.

The ledger is append-only: fix wrong business data with reversal entries from
the app, not SQL edits.

## Incident checklist

1. **Assess**: who is affected (one business or all), since when, what is
   visible (sync errors, wrong balance, login failure)? Check Sentry, the
   Supabase logs and advisors, and the PowerSync dashboard.
2. **Contain**: pause rollout of any recent build; if a policy leaks data,
   disable the affected feature or revoke the tenant's access first.
3. **Protect data**: take a manual backup before any fix; never delete rows.
4. **Fix forward**: migration or app patch via the normal pipeline; hotfix tags
   (`vX.Y.Z` / `db-vX.Y.Z`) still need the production approval.
5. **Verify**: Diagnostics screen shows no rejected changes; balances equal the
   ledger sum for the affected businesses.
6. **Communicate**: tell affected arhtiyas what happened and what to do (e.g.
   keep working offline; changes upload once fixed).
7. **Follow up**: write the cause and the prevention in `docs/decisions.md`;
   add a test (pgTAP or app) that would have caught it.
8. **Secrets exposed?** Rotate in Supabase (JWT secret, keys, DB password),
   update the GitHub secrets, redeploy.
