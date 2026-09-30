# Setup: Claude Code + Supabase + Flutter (do this once, ~1 hour)

These steps are for **you** (they need your accounts, logins and installers). After this, Claude Code does the building.

Development machine: **MacBook (macOS)**. Daily work is the **Android emulator** and **Chrome** (`flutter run -d chrome`), with `-d macos` as a desktop sanity check.

**Windows is the primary customer platform** (the shop counter), but Flutter cannot cross-compile it. So:
- Nobody runs `flutter build windows` on the Mac — it cannot work there.
- Windows builds are produced **only by GitHub Actions** on a `windows-latest` runner (set up in Step 0.8).
- You test that CI-produced build on a **real Windows PC before the pilot** (see Step 1b).
- `windows` stays in the app's target platforms the whole time.

**Backend:** the app runs against the **online Supabase dev project + PowerSync Cloud**, configured in `.env.dev`. You do **not** need Docker to run the app. The local Supabase stack is optional — see Step 2b.

---

## 1. Install the tools

| Tool | Why | Install |
|---|---|---|
| Homebrew | Package manager used for most of the tools below | https://brew.sh |
| Xcode + Command Line Tools | Needed to build the macOS desktop app; also provides git | App Store, then `xcode-select --install` |
| Flutter SDK (stable) | The app | https://docs.flutter.dev/get-started/install/macos |
| Android Studio | Android SDK, emulator, your IDE | https://developer.android.com/studio |
| Docker Desktop | *Optional.* Local Supabase copy for `supabase db reset` / `supabase test db` | https://www.docker.com/products/docker-desktop/ |
| Node.js 20 LTS | Edge Functions tooling | `brew install node@20` |
| Supabase CLI | Migrations, local DB, deploy functions | `brew install supabase/tap/supabase` |
| Claude Code | The builder | `curl -fsSL https://claude.ai/install.sh \| bash` |
| GitHub account + GitHub CLI | Code backup, CI | `brew install gh` |

Check: open a new Terminal and run:
```bash
flutter doctor          # everything green for macOS, Android and Chrome
supabase --version
docker --version
claude --version
```

If `docker` is not found after installing Docker Desktop, its CLI has not been linked onto your PATH:
```bash
ln -sf /Applications/Docker.app/Contents/Resources/bin/docker /opt/homebrew/bin/docker
```

Optional: install the **Claude Code plugin for JetBrains** in Android Studio (Settings → Plugins → Marketplace → "Claude Code"). It opens Claude's diffs inside the editor. You still run `claude` in Android Studio's **Terminal** tab.

---

## 1b. The Windows test PC (needed before the pilot, not on day one)

CI builds the Windows app; you only need somewhere to **run and check** it before the pilot. Any Windows 10/11 PC (or a VM on the Mac — Parallels / VMware Fusion / UTM) works: download the installer artifact from the GitHub Actions run and install it.

You do **not** need Flutter, Visual Studio, Supabase, Docker or Claude Code on that PC just to test a release build.

Only if you later want to build Windows locally on that PC:

| Tool | Why | Install |
|---|---|---|
| Git for Windows | Version control | https://git-scm.com/download/win |
| Flutter SDK (stable) | The app | https://docs.flutter.dev/get-started/install/windows |
| Visual Studio 2022 Community | Required to compile Windows desktop apps. Tick **"Desktop development with C++"** | https://visualstudio.microsoft.com/ |

Then `flutter doctor` there must show the **Visual Studio** line green, and:
```powershell
flutter run -d windows
```

---

## 2. Create the cloud accounts & projects

1. **Supabase** (https://supabase.com): create an organisation, then **two projects**, both in region **South Asia (Mumbai)**:
   - `mandi-khata-dev`: Claude Code is allowed to touch this.
   - `mandi-khata-prod`: real customers. **Claude never connects here.** You or GitHub CI push migrations to it.
   Note each project's **Project ref** (Settings → General), **URL** and **anon (publishable) key**.
2. **PowerSync** (https://www.powersync.com): one instance for dev (later one for prod). Do these in order:
   1. **Replication role (Supabase dashboard → SQL Editor, dev project).** It has a password, so it is not in a migration. Pick a long random password and keep it in your password manager:
      ```sql
      CREATE ROLE powersync_role WITH REPLICATION BYPASSRLS LOGIN PASSWORD '<long random password>';
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO powersync_role;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO powersync_role;
      ```
      The `powersync` **publication** is already created by the migration `*_powersync_publication.sql`; don't run `CREATE PUBLICATION` by hand.
   2. **Create the instance** in the PowerSync dashboard (pick a region near Mumbai) and connect it to Supabase: use the **Session pooler / direct connection** details from Supabase → Connect, but with user `powersync_role` and the password above.
   3. **Client Auth:** tick **"Use Supabase Auth"**. Leave the legacy JWT secret empty unless your project still uses the legacy JWT secret (PowerSync then auto-configures JWKS). Save and deploy.
   4. **Sync Streams:** paste the contents of `powersync/sync-streams.yaml` and deploy. Every time that file changes, deploy it again.
   5. Copy the **instance URL** into `.env.dev` as `POWERSYNC_URL`.
   6. Test: run the app, open **Sync lab** (debug builds), sign in with a dev user who is a member of a business, add a test party, toggle **Go offline / Go online**, and check the row appears in Supabase → Table editor → `parties`.
3. **Sign-in (Supabase dashboard → Authentication, dev project)** — needed from step 0.5:
   1. **Sign In / Providers → Phone:** enable it and pick an SMS provider (Twilio, MessageBird, Textlocal or Vonage) with its keys. For development you can skip real SMS: under **Phone → Test phone numbers and OTPs** add e.g. `919814022110=123456`, and that number always accepts code `123456`.
   2. **Email** stays enabled (fallback for web / accountants). Create a dev user under **Users → Add user → Create new user** (email + password, *Auto Confirm User* ticked).
   3. **Give the user a business.** Businesses are created only by the server (never by the app), so for dev run this once in **SQL Editor** (replace the email or phone):
      ```sql
      with u as (
        select id from auth.users
        where email = 'you@example.com' or phone = '919814022110'
        limit 1
      ), t as (
        insert into public.tenants (id, name, mandi_name, state_code)
        values (gen_random_uuid(), 'Dev Arhat Co.', 'Sirsa Mandi', '06')
        returning id
      )
      insert into public.tenant_members (id, tenant_id, user_id, role)
      select gen_random_uuid(), t.id, u.id, 'owner' from t, u;
      ```
      A phone user appears in `auth.users` after their first OTP sign-in; until they are a member the app shows "No business linked yet".
4. **Razorpay** (Phase 5 only): test-mode keys.
5. **Sentry** (optional, Phase 0.7): create a Flutter project (region EU or US) and put its DSN in `.env.dev` as `SENTRY_DSN=...`. Leave it blank to keep error reporting off. Events carry only the business id and device code as tags, never names, phones or emails.

The app always talks to these **online** services via `.env.dev`. That is the normal development path.

---

## 2b. Local Supabase (optional — only for schema tests)

The local Docker stack is **not** needed to run the app. It exists so migrations can be tested destructively before they touch the dev project:

```bash
supabase start             # needs Docker Desktop running
supabase db reset          # re-apply all migrations + seed from scratch
supabase test db           # pgTAP RLS tests
```

**If Docker isn't running**, don't start the stack. Instead:
- Claude asks you to approve `supabase db push`, which applies the migration files to the **dev** project.
- The pgTAP RLS tests run in **CI** on every push instead of locally.

**Android emulator note:** the emulator cannot reach the host's `127.0.0.1`. If you ever point the app at a *local* Supabase/PowerSync, the Android config must use **`10.0.2.2`** instead of `127.0.0.1`. This does not apply to the online dev project.

---

## 3. Create the project folder

```bash
mkdir -p ~/dev/mandi_khata
cd ~/dev/mandi_khata
git init
```
Unzip this plan package into `~/dev/mandi_khata` so that `CLAUDE.md`, `.claude/`, `.mcp.json`, `docs/` and `design/` sit at the root.

Create `~/dev/mandi_khata/.env.dev` (never commit it; `.gitignore` covers `.env*`):
```
SUPABASE_URL=https://<dev-project-ref>.supabase.co
SUPABASE_ANON_KEY=<dev anon/publishable key>
POWERSYNC_URL=https://<your-instance>.powersync.journeyapps.com
SENTRY_DSN=
```
The Flutter app reads these with `--dart-define-from-file=.env.dev`. **Only the anon key goes in the app. Never the service-role key.**

---

## 4. Connect Claude Code to Supabase (MCP)

Supabase has an official **MCP server**. Once connected, Claude Code can list tables, apply migrations, run SQL, read logs, run the security advisors, deploy Edge Functions and search the Supabase docs, all against your **dev** project only.

### 4a. Put your dev project ref in `.mcp.json`

The package already contains `.mcp.json`. Open it and replace `YOUR_DEV_PROJECT_REF` with the dev project ref:

```json
{
  "mcpServers": {
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=YOUR_DEV_PROJECT_REF&features=docs%2Cdatabase%2Cdebugging%2Cdevelopment%2Cfunctions"
    }
  }
}
```

What the options mean:
- `project_ref=…` locks Claude to **one** project (the dev one). It cannot see or touch prod.
- `features=…` enables only docs, database, debugging (logs/advisors), development (keys/types) and edge functions. Account management (create/delete projects) and storage are off.
- For a look-only session, add `&read_only=true`.

The same thing from the command line, if you prefer:
```bash
claude mcp add --scope project --transport http supabase "https://mcp.supabase.com/mcp?project_ref=YOUR_DEV_PROJECT_REF&features=docs%2Cdatabase%2Cdebugging%2Cdevelopment%2Cfunctions"
```

### 4b. Log in

```bash
cd ~/dev/mandi_khata
claude
```
Inside Claude Code type `/mcp`, select **supabase** → **Authenticate**. A browser opens; log in to Supabase and allow access. Back in Claude, `/mcp` should show `supabase ✔ connected`.

Test it by asking Claude: `Use the supabase MCP to list tables and run the security advisor on the dev project.`

### 4c. Also link the Supabase CLI (for migration files)

Claude writes schema changes as **migration files** (in git) and uses the CLI to apply them. The MCP is for inspecting, logs, advisors and function deploys. Link the CLI to **dev** once:
```bash
supabase login
supabase init              # only if supabase/ doesn't exist yet (Claude does this in Step 0.1)
supabase link --project-ref YOUR_DEV_PROJECT_REF
```

### Safety rules (already in CLAUDE.md and .claude/settings.json)
- Claude only ever connects to **dev**. Production gets changes only through `supabase db push` run by **you** or by GitHub Actions after review.
- Schema changes are **only** migration files, never ad-hoc SQL. Otherwise dev and git drift apart.
- Leave MCP tool approval **on** for `execute_sql`, `apply_migration` and `deploy_edge_function`. Read-only tools (list tables, logs, advisors, docs) are pre-approved in `.claude/settings.json`.
- Never paste real customer data into Claude; use the seed data.

---

## 5. Connect Claude Code to Flutter (recommended)

The Flutter team publishes an official Claude Code plugin with the **Dart & Flutter MCP server**. It lets Claude read analyzer errors, run tests, hot-reload and inspect the running app.

Inside Claude Code:
```
/plugin marketplace add flutter/agent-plugins
/plugin install dart-flutter@dart-flutter
```
(or from the terminal: `claude plugin marketplace add flutter/agent-plugins` then `claude plugin install dart-flutter@dart-flutter`). Restart Claude Code and check `/mcp` shows the dart server.

---

## 6. Optional: GitHub

```bash
gh auth login
gh repo create mandi-khata --private --source . --push
```
Claude Code can then open PRs, and CI (`.github/workflows/ci.yml`, step 0.8) runs on every push to `main` and every pull request: format, generated-code check, analyze, all tests, Supabase migrations + pgTAP RLS tests, and builds for web, Android, macOS and **Windows** (`windows-latest`). CI needs no secrets.

**Windows build to test on a real PC:** open the latest green run under GitHub → Actions → CI, download the `windows-release` artifact, unzip it on the Windows machine and run `mandi_khata_app.exe`. The Android debug APK is there too (`android-debug-apk`).

Add these GitHub **Actions secrets** for the production deploy workflow (Phase 6): `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROD_PROJECT_REF`, `SUPABASE_PROD_DB_PASSWORD`.

---

## 7. Start building

```bash
cd ~/dev/mandi_khata
claude
```
Then type:
```
/next-step
```
Claude reads `docs/PROGRESS.md`, picks the first unchecked step, plans it, builds it, verifies it, and updates progress. See `docs/ROADMAP.md` for the full workflow.
