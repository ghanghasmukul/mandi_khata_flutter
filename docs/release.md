# Release checklist (step 6.7)

How a version reaches shops on Windows, macOS, Android and the web without
losing data. The machinery is in `.github/workflows/release.yml` and
`docs/ops.md` (secrets, signing, `latest.json`); this is the order to do it in.

## Before tagging

- [ ] `flutter analyze` and `dart format` clean; `flutter test` (app, `mk_admin`)
      and `dart test` (khata_core) green; CI green on `main`.
- [ ] **Local schema changed?** (`core/db/powersync_schema.dart`): bump
      `localSchemaVersion`, add the new fingerprint to `released` in
      `test/core/db/schema_version_test.dart`, extend the upgrade test. The
      test fails until you do.
- [ ] **Server schema changed?** Migration reviewed, `supabase db reset` +
      `supabase test db` green, then `deploy-db.yml` (docs/ops.md) BEFORE the
      app that needs it ships. New synced table: also `powersync/sync-streams.yaml`
      deployed to PowerSync.
- [ ] **Does an older app break against the new schema or sync streams?** If
      yes, set `APP_MIN_SUPPORTED` to this version: older apps then show the
      non-dismissable update banner. If the change is additive, leave it.
- [ ] Release notes: add `changelogV<xyz>` to `app_en/hi/pa.arb` and one line
      in `changelog()` (`whats_new_screen.dart`). Ask a native speaker to read
      the Hindi and Punjabi.
- [ ] Version in `apps/mandi_khata_app/pubspec.yaml` (`1.2.0+build`), same as
      the tag.
- [ ] Manual smoke on the Android emulator and Chrome: sign in, add a party,
      add a document offline, turn the network on, see it sync.

## Tag and build

1. `git tag v1.2.0 && git push origin v1.2.0`: `release.yml` builds the
   Windows installer (Inno Setup), macOS `.dmg`, Android `.aab` and the web
   zip and attaches them to a **draft** GitHub Release.
2. Download the Windows installer on a real Windows PC (never built locally):
   install over the previous version, open a business, check data is still
   there and sync runs. Same for the `.dmg` on a clean Mac.
3. Signing: without certificates the builds are unsigned (SmartScreen /
   Gatekeeper warn; Play rejects a debug-signed AAB). See docs/ops.md.

## Publish

| Platform | Steps |
|---|---|
| Windows | Upload the signed installer where `PROD_DOWNLOAD_BASE_URL` points (or the Microsoft Store). |
| macOS | Notarised `.dmg`, same place. |
| Android | Play Console: upload the AAB to **internal** testing, then **closed**, then **production** with a staged rollout (5% -> 20% -> 100%). Watch Sentry crash-free sessions (target 99.5%) between steps. |
| Web | Upload `web` to Cloudflare Pages; `_headers` (COOP/COEP, no-cache on entry files) and `_redirects` ship in the build. Hard reload to verify. |
| All | Last: update `latest.json` (version, `min_supported`, notes, download links). Installed apps show the banner on their next start. |

## After

- [ ] Sentry: new errors in the first hours? Roll back = unpublish / halt the
      rollout and republish the previous `latest.json`; do not roll the
      database back (docs/ops.md: forward-fix migrations only).
- [ ] Admin console > Sync health: no business suddenly red.
- [ ] Record the release and anything surprising in `docs/decisions.md`.

## Upgrade path of local data

PowerSync stores rows in generic tables and shows each table as a view built
from the app's schema, so installing a newer version never converts or loses
local data: it opens the old file with the new schema. Tested for the last
layout in `schema_version_test.dart`. Downgrades are not supported: an older
app against a newer file may miss columns, which is what `min_supported`
guards against. Unsynced local changes survive an update (they are in the
upload queue, not in the schema).

Not automated yet (needs real accounts / devices): store submissions, in-app
updates through the Play API (the banner links to the store instead), Windows
MSIX / Store, macOS notarisation, the Windows installer run.
