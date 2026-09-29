---
name: new-table
description: Add a new synced business table end to end (migration, RLS, pgTAP test, PowerSync sync rule, local schema, Drift table, repository, audit, tests). Use whenever a step needs a new table.
argument-hint: [table_name] [short purpose]
---

Add the table `$0` ($ARGUMENTS) following CLAUDE.md. Do ALL of the following in one go:

1. `supabase migration new create_$0`: columns incl. `id uuid primary key`, `tenant_id uuid not null references tenants(id)`, business columns (money as `bigint` paise), `created_by`, `created_at timestamptz default now()`, `updated_at` + trigger, `deleted_at` only if master data. Indexes on `(tenant_id, …)` for every expected filter.
2. RLS: enable; select/insert/update policies using `tenant_id in (select auth_tenant_ids())` and `has_permission(...)` where the permission table in `docs/domain/ledger-and-mandi.md` requires it. No delete policy for clients. If append-only (ledger, stock movements, journal): trigger that rejects updates to financial columns.
3. pgTAP test in `supabase/tests/`: another tenant cannot select/insert/update; a munshi cannot do owner-only actions.
4. Add the table to `powersync/sync-rules.yaml` in the tenant bucket.
5. App: add to the PowerSync schema + Drift table definition; run build_runner.
6. Repository in the owning feature's `data/` (streams for lists, futures for writes, tenant filter on every query, AuditWriter in the same transaction).
7. Unit tests for the repository using an in-memory database.
8. `supabase db reset && supabase test db` and `flutter analyze`: all green.
9. Summarise the columns and policies created.
