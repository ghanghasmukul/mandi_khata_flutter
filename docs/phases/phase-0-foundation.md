# Phase 0 — Foundation

**Goal:** a skeleton app that logs in, belongs to a tenant, reads/writes a local database, works offline, and syncs to Supabase on Windows, macOS, Android and Web. No business features yet except one demo table (`parties`) to prove the pipeline.

**Estimated time:** 2–3 weeks.

Prerequisites: finish **docs/SETUP.md** (tools, Supabase dev/prod projects, PowerSync, Supabase MCP + Dart/Flutter plugin connected in Claude Code). Then run `/next-step`; you don't need to paste the prompts below yourself.

Database work in every step: migration files via `supabase migration new`, tested locally with `supabase db reset` + `supabase test db`, then applied to the **dev** project (`supabase db push` to the linked dev project, or the Supabase MCP `apply_migration` with the same SQL), then checked with the Supabase MCP security/performance advisors.

---

## Step 0.1 — Monorepo scaffold

**Prompt**
```
Read CLAUDE.md. Create the repository layout exactly as described there:
- Root pubspec.yaml as a Dart pub workspace including apps/mandi_khata_app, packages/khata_core, packages/mk_ui.
- apps/mandi_khata_app: Flutter app with platforms windows, macos, android, web only. Org id com.mandikhata.
- packages/khata_core: pure Dart package (no Flutter dependency).
- packages/mk_ui: Flutter package for the design system.
- Add very_good_analysis to all three, a shared analysis_options.yaml, .gitignore (include .env*, build outputs, supabase/.temp), and an .editorconfig.
- Add the dependencies listed in CLAUDE.md's tech stack table to the right packages (latest stable versions), plus build_runner, riverpod_generator, freezed, json_serializable, uuid, intl, decimal, logging.
- Run `supabase init` at the root (keep the existing .mcp.json, .claude/ and docs/ untouched), add `.env.example` listing SUPABASE_URL, SUPABASE_ANON_KEY, POWERSYNC_URL, SENTRY_DSN, and make the app read them via --dart-define-from-file.
- Add a README.md with setup and run commands.
Show me the tree and run `flutter analyze` and `dart test` (with one placeholder test per package) at the end.
```

**Done when:** `flutter run -d macos`, `-d chrome`, and an Android emulator all show a blank "Mandi Khata" screen (and `-d windows` when you next have a Windows machine).

---

## Step 0.2 — Design system (`mk_ui`)

**Prompt**
```
Build the design system in packages/mk_ui, matching design/Mandi_Khata.html.
Tokens (light theme):
- Brand dark green #173B2C, green #2F7A56, green-2 #245440, gold #D4A140, gold-soft #E9C46A, gold-text #9C7425
- Background #F4F2EA, background-2 #F7F5EC, surface #FFFFFF, surface-alt #FCFBF6, border #E7E4D6, border-2 #EDEADF
- Text primary #1A231D, text-body #424A40, text-muted #6A6F62, text-faint #8C8F80
- Jama/positive #2F7A56, Udhaar/negative #CF6A5C
Fonts: IBM Plex Sans (UI), IBM Plex Mono (all numbers & money), Noto Sans Devanagari (hi), Noto Sans Gurmukhi (pa). Bundle them as assets (google_fonts is not allowed — must work offline).
Create:
- MkTheme (ThemeData + ThemeExtension for custom tokens), light theme only for now, dark theme stub.
- Spacing/radius scale (4, 8, 12, 16, 20, 24; radius 10/14/20).
- Widgets: MkCard, MkStatTile (label, value, sub), MkMoneyText (paise int → ₹ Indian format, colours jama/udhaar, mono font), MkBalanceChip, MkButton (primary/secondary/ghost/danger), MkTextField, MkNumberField (numeric keypad, paise-safe), MkDataTable (sortable, sticky header, zebra-free, dense on desktop), MkEmptyState, MkSidebar (grouped sections: Mandi / Shop / Accounts / Admin, collapsible, badge support), MkTopBar (title, subtitle, search with Ctrl+K, language switcher EN/हिं/ਪੰ, role chip), MkToast, MkDialog, MkBottomNav (mobile).
- Responsive scaffold MkAppShell: sidebar on width ≥ 1000, rail on 600–999, bottom nav < 600.
- A widgetbook-style gallery page in the app at route /dev/gallery showing every widget.
Put Indian money formatting in khata_core (Money.format(), Money.short() → "₹13.28 L", "₹1.20 Cr") with unit tests, and use it from MkMoneyText.
```

---

## Step 0.3 — Supabase schema: tenancy, users, settings, audit, parties

**Prompt**
```
Read CLAUDE.md and docs/domain/settings-cascade.md and docs/domain/ledger-and-mandi.md.
In supabase/migrations create numbered SQL migrations for:
1. tenants (id, name, legal_name, gstin, address, state_code, mandi_name, phone, plan_code, status: trial|active|grace|locked|cancelled, trial_ends_at, created_at)
2. app_users (id = auth.users.id, phone, full_name, preferred_language)
3. tenant_members (tenant_id, user_id, role: owner|accountant|munshi|custom, custom_permissions jsonb, is_active, device_limit) — a user can belong to several tenants.
4. devices (id, tenant_id, user_id, device_code short unique per tenant e.g. 'W1','A3', platform, last_seen_at)
5. settings (per settings-cascade.md, unique (tenant_id, scope, scope_id, key))
6. audit_log (id, tenant_id, table_name, row_id, action, before jsonb, after jsonb, user_id, device_id, role, created_at)
7. parties (id, tenant_id, code, name, father_or_husband_name, relation: s_o|d_o|w_o|prop, village, district, state, mobile, alt_mobile, aadhaar_last4, bank_name, bank_account_masked, ifsc, gstin, notes, party_group_id, created_at, updated_at, deleted_at) and party_roles(party_id, tenant_id, role).
8. number_series (tenant_id, series, device_code, next_value).
Every table: tenant_id NOT NULL (except app_users), uuid PKs with no DB default requirement (client supplies), created_by, updated_at trigger.
Helper SQL functions: auth_tenant_ids() returns the tenant ids of the current user; has_permission(tenant_id, perm text) boolean.
RLS: enable on every table; select/insert/update only where tenant_id in auth_tenant_ids(); owner-only for tenant_members and settings at tenant scope. No hard deletes allowed from clients.
Write pgTAP tests in supabase/tests proving user A of tenant 1 cannot read or write tenant 2 rows.
Add seed.sql with 2 demo tenants, 3 users each (owner, accountant, munshi) and ~12 parties modelled on the prototype names.
Run `supabase db reset` and `supabase test db` and show results.
```

---

## Step 0.4 — PowerSync sync rules + local database

**Prompt**
```
Set up offline-first sync.
1. powersync/sync-rules.yaml: bucket per tenant — sync every table in 0.3 filtered by the tenant ids of the logged-in user (via tenant_members). Exclude audit_log from download (upload only) except the last 30 days for owners.
2. In the app core/db: define the PowerSync schema mirroring the tables, open the database, and wire Drift on top of it for typed queries (use the official powersync + drift integration).
3. core/sync: a SupabaseConnector implementing PowerSync's backend connector — fetchCredentials from Supabase session, uploadData that applies CRUD batches to Supabase via PostgREST, with:
   - retry with backoff,
   - permanent-error handling (RLS/constraint violations) → move the op to a local `sync_errors` table and show it in the UI, never block the queue forever.
4. A SyncStatus provider and a small widget in MkTopBar: "Synced · 2 min ago" / "Offline · 4 queued" / "Sync error (tap)".
5. Make sure web uses the PowerSync web (WASM) setup correctly; add the required web assets and document them in README.
Test: create a party offline on the desktop app, go online, see it appear in Supabase and on Web.
```

---

## Step 0.5 — Auth, tenant selection, devices

**Prompt**
```
Implement auth:
- Phone OTP login with Supabase Auth (India +91 default). Also email+password as fallback for web/accountants.
- After login: load memberships; if more than one tenant, show a tenant picker; remember the last tenant.
- Register the device (devices table) and get a short device_code; store it locally.
- Offline launch: if a valid session was cached, open the app offline with the last tenant (do not force login when offline).
- App lock: 4–6 digit PIN on Android, Windows and macOS (local only, hashed), optional biometric on Android (local_auth).
- Logout clears the local database after confirming unsynced changes are uploaded (warn if queue not empty).
- go_router guards: unauthenticated → /login; no tenant → /select-tenant.
```

---

## Step 0.6 — Settings cascade + permissions in the app

**Prompt**
```
Read docs/domain/settings-cascade.md.
In khata_core: settings_schema.dart (all keys, types, defaults, validation) and a pure resolver:
  resolve(key, {partyId, partyGroupId, documentId}) using a list of setting rows + plan defaults + system defaults, returning (value, sourceLevel).
Unit-test the resolver thoroughly.
In the app core/settings: SettingsRepository (local DB), a Riverpod `settingProvider(key, scope)` that is reactive, and a generic settings editor screen that renders any key from the schema (bool switch, enum dropdown, number field with %, paise field) and shows "inherited from X" with a "reset to inherited" button.
core/permissions: Permission enum per docs/domain/ledger-and-mandi.md table, `can(Permission)` provider using role defaults + custom_permissions; a `PermissionGate` widget.
```

---

## Step 0.7 — Audit, number series, i18n, error reporting

**Prompt**
```
1. core/audit: an AuditWriter used by every repository write (same local transaction). 
2. core/numbering: NumberSeriesService producing '<prefix><device_code>-<n>' e.g. 'R-W1-0042', stored per device locally, synced.
3. i18n: set up gen_l10n with en, hi, pa ARB files; language switcher in top bar; numbers stay in Western digits; dates localised.
4. Sentry: capture errors with tenant id + device code tags (no personal data).
5. A /dev/diagnostics screen: DB size, queued ops, last sync, sync errors list with retry/discard (owner only).
```

---

## Step 0.8 — Parties screen (pipeline proof) + CI

**Prompt**
```
Build the Parties feature end to end as the reference implementation for all future features:
- List with search (name, village, mobile, code) — instant, from local DB, 10k rows smooth.
- Role filter chips (farmer, customer, supplier, vendor, agency, buyer).
- Add/edit party form with validation (Indian mobile, IFSC, GSTIN format), relation s/o | d/o | w/o | prop.
- Soft delete (owner only) with audit.
- Party detail screen with tabs placeholder (Khata, Lots, Loans, Shop, Documents, Notes).
Then add GitHub Actions CI: analyze, test (khata_core + app), build web, build windows (windows-latest runner), build macos (macos-latest runner), build android apk; and supabase db tests using the supabase CLI.
```

## Phase 0 exit criteria

- [ ] Same party list visible on Windows, macOS, Android and Web for one tenant; invisible to another tenant.
- [ ] Airplane mode: add 20 parties on Android, reconnect → all appear on the desktop app within a minute.
- [ ] Two devices edit the same party offline → last-write-wins, both edits in audit log.
- [ ] RLS pgTAP tests pass. CI green.
- [ ] Settings editor changes a value at tenant scope and party scope, and the resolver shows the right source.
