---
name: verify
description: Run the full quality gate for Mandi Khata (format, analyze, unit tests, Supabase RLS tests, platform builds) and fix failures. Use after any code change and before marking a step done.
argument-hint: [quick|full]
---

Run the quality gate. `quick` = steps 1–4 only. `full` (default) = all steps.

1. `dart format .` (commit formatting changes).
2. `flutter analyze` at the repo root: must report zero issues. Fix, don't suppress (no `// ignore:` without a written reason).
3. `cd packages/khata_core && dart test`: all pass. Report coverage for any money/interest code touched.
4. `cd apps/mandi_khata_app && flutter test`: all pass.
5. If `supabase/` changed: `supabase db reset` then `supabase test db` (pgTAP RLS tests) and `supabase db lint`.
6. Builds (full only): `flutter build web`, `flutter build macos` (only on a macOS host), `flutter build windows` (only on a Windows host — otherwise rely on CI), `flutter build apk --debug`.
7. Rule checks, search the diff for violations and fix them:
   - `double` used for money → must be int paise / `Money`.
   - a query or table without `tenant_id`.
   - UPDATE/DELETE on `ledger_entries` or `stock_movements`.
   - direct Supabase calls from presentation code for business data.
   - hard-coded user-facing strings (must be in ARB en/hi/pa).
   - hard-coded rates/charges (must come from the settings cascade).
8. Report a table: check → pass/fail → what was fixed.
