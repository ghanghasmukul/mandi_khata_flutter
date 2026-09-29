# Setup: Claude Code + Supabase + Flutter (do this once, ~1 hour)

These steps are for **you** (they need your accounts, logins and installers). After this, Claude Code does the building.

Development machine: **macOS (Apple silicon)**. macOS, Android and Web all build and run from it.

**Windows is the primary customer platform** (the shop counter), but Flutter cannot cross-compile it — a Windows build needs an actual Windows machine. So:
- Day-to-day development and testing happens on the Mac (macOS + Android + Web).
- Windows builds run on the `windows-latest` GitHub Actions runner (set up in Step 0.8).
- Before each pilot/release, test the Windows build on a real Windows 10/11 machine or VM (see Step 1b).

---

## 1. Install the tools

| Tool | Why | Install |
|---|---|---|
| Homebrew | Package manager used for most of the tools below | https://brew.sh |
| Xcode + Command Line Tools | Needed to build the macOS desktop app; also provides git | App Store, then `xcode-select --install` |
| Flutter SDK (stable) | The app | https://docs.flutter.dev/get-started/install/macos |
| Android Studio | Android SDK, emulator, your IDE | https://developer.android.com/studio |
| Docker Desktop | Runs a local Supabase copy for development and tests | https://www.docker.com/products/docker-desktop/ |
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

## 1b. The Windows build machine (needed before the pilot, not on day one)

CI produces the Windows build, but you still need somewhere to run and test it. A Windows 10/11 machine, or a VM on the Mac (Parallels / VMware Fusion / UTM), needs:

| Tool | Why | Install |
|---|---|---|
| Git for Windows | Version control | https://git-scm.com/download/win |
| Flutter SDK (stable) | The app | https://docs.flutter.dev/get-started/install/windows |
| Visual Studio 2022 Community | Required to build Windows desktop apps. Tick **"Desktop development with C++"** | https://visualstudio.microsoft.com/ |

Then `flutter doctor` there must show the **Visual Studio** line green, and:
```powershell
flutter run -d windows
```

You don't need Supabase, Docker or Claude Code on that machine — it only builds and runs the app.

---

## 2. Create the cloud accounts & projects

1. **Supabase** (https://supabase.com): create an organisation, then **two projects**, both in region **South Asia (Mumbai)**:
   - `mandi-khata-dev`: Claude Code is allowed to touch this.
   - `mandi-khata-prod`: real customers. **Claude never connects here.** You or GitHub CI push migrations to it.
   Note each project's **Project ref** (Settings → General), **URL** and **anon (publishable) key**.
2. **PowerSync** (https://www.powersync.com): create an instance for dev (and later one for prod) and connect it to the Supabase project (their dashboard has a Supabase connection wizard). Note the **PowerSync instance URL**.
3. **Razorpay** (Phase 5 only): test-mode keys.
4. **Sentry** (optional, Phase 0.7): a Flutter project DSN.

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
Claude Code can then open PRs, and CI (set up in Step 0.8) runs tests on every push.

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
