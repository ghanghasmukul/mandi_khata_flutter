# Decisions log

| Date | Decision | Reason |
|---|---|---|
| 2026-09-26 | Backend: Supabase (Postgres, RLS, Auth, Edge Functions, Storage, Mumbai region) + PowerSync for offline sync | Relational ledger data; SQL reports; RLS multi-tenancy; Firebase on Windows is dev-only; Firestore offline is a cache only |
| 2026-09-26 | Flutter for Windows, Android, Web from one codebase | One team, one codebase |
| 2026-09-26 | Money stored as integer paise; ledger append-only | Correctness, auditability, conflict-free sync |
| 2026-09-26 | Interest default appropriation = interest_first; interest only on NET udhaar; surplus jama carried forward | Mandi practice; fixes prototype bug (farmers we owe were charged interest) |
| 2026-09-26 | Party net position = khata balance only (no adding shop dues on top) | Fixes prototype double counting |
| 2026-09-26 | Claude Code accesses only the dev Supabase project; prod via approved GitHub Actions | Safety |
| 2026-09-29 | Add macOS as a shipped desktop target alongside Windows | Development happens on a Mac, so macOS/Android/Web build and run locally; Windows stays the primary shop-counter platform, built on a Windows machine or the `windows-latest` CI runner |
| 2026-09-29 | Upgraded Flutter 3.44.0 → 3.47.5 (Dart 3.12 → 3.13.4) | `drift_dev`, `riverpod_generator` and `very_good_analysis` 11 all require analyzer ≥13, which Dart 3.12 could not satisfy; pinning older packages would have started the project on stale deps |
| 2026-09-29 | Dart pub workspace with a single root lockfile | One resolution for app + khata_core + mk_ui; prevents version drift between the packages |
| 2026-09-29 | Money display: `Money.format()` shows paise only when non-zero (`₹1,55,580`, `₹1,109.59`); `Money.short()` shows whole rupees below ₹1 L, then `₹13.28 L` / `₹1.20 Cr` with two decimals, rounded half-up (a value that rounds to 100.00 L shows as 1.00 Cr). Balances are shown without a sign, with colour for the side (jama green, udhaar red) | Matches the prototype and mandi practice; display rounding never touches stored paise |
| 2026-09-29 | Typed amounts are parsed by `Money.tryParse`, which rejects more than two decimals instead of rounding | A typing slip must never silently change an amount |
| 2026-09-29 | Fonts bundled as static TTFs in `mk_ui` (IBM Plex Sans 400–700, IBM Plex Mono 400–600, Noto Sans Devanagari/Gurmukhi 400–700), cut from the Google Fonts variable files; Hindi and Punjabi render through `fontFamilyFallback` | Offline-first (no `google_fonts`); static weights render the same on every platform; one font setup works for all three languages |
| 2026-09-29 | Radius scale follows the step spec (10/14/20) rather than the prototype's 22–28 px card corners | Spec tokens are authoritative; prototype is a look reference |
| 2026-09-29 | `/dev/gallery` is registered only in non-release builds, and its sample text is not put in the ARB files | Developer tool, never shown to users; keeps the ARB files for real UI strings |
| 2026-09-29 | Permission keys (`parties.manage`, `loans.manage`, `master.delete`, …) added to the roles table; `settings.manage` and `audit.view` are owner-only | Needed a stable name for `custom_permissions` and `has_permission()`; the domain table did not name them |
| 2026-09-29 | RLS helpers (`auth_tenant_ids`, `has_permission`, …) live in a non-exposed `private` schema as `SECURITY DEFINER` with `search_path = ''` | Not callable through the REST API; avoids RLS recursion on `tenant_members`; Supabase-recommended pattern |
| 2026-09-29 | Tenants are created only by the service role; clients cannot change `plan_code`, `status` or `trial_ends_at` | Signup and billing are server-side (phase 5); stops a client unlocking a plan |
| 2026-09-29 | Device codes (`W1`, `A2`, `M1`, `B1` = web) are allocated online by `register_device()` under a per-business lock; `device_limit` is stored but not enforced yet | Codes must never collide; enforcing the limit needs a device-retire flow (phase 5) or users could never replace a phone |
| 2026-09-29 | `created_by` and `audit_log.role` are set by the server from the JWT, not trusted from the client | Audit must show who really did it |
| 2026-09-29 | `audit_log` rejects UPDATE/DELETE for every role, including the database owner | Append-only audit trail |
| 2026-09-29 | `party_groups` table deferred; `parties.party_group_id` is a plain uuid until it exists | Not in the 0.3 spec; added with the party-group feature |
| 2026-09-30 | Advisor warning 0029 on `public.register_device` (SECURITY DEFINER callable by `authenticated`) accepted | Intentional: it is the only way to create a device; it checks `auth.uid()` and membership itself and needs definer rights to allocate unique codes under a lock. A client insert policy instead would let clients pick colliding codes. Covered by pgTAP (03_integrity) |
| 2026-09-30 | Advisor "unused index" notes (9) ignored for now | Dev database is empty; every index backs an RLS lookup or a planned query. Re-check once real data exists |
