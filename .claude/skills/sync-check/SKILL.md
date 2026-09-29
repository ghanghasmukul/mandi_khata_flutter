---
name: sync-check
description: Test offline-first behaviour and sync for a feature (offline writes, reconnect, conflicts, tenant isolation). Use after building any feature that writes data.
argument-hint: [feature name]
---

Test offline + sync for `$ARGUMENTS`.

1. Write/extend an integration test (`apps/mandi_khata_app/integration_test/`) that:
   - starts with local Supabase (`supabase start`) and a seeded tenant,
   - simulates offline (disconnect PowerSync / stub connector), performs the feature's writes, asserts the UI and local DB show them immediately,
   - reconnects, waits for upload, asserts rows exist in Postgres with correct `tenant_id`,
   - simulates a second device writing the same records offline: assert no lost writes, no number-series collisions, append-only rows both present, master-data last-write-wins, audit rows for both.
   - asserts a user of another tenant receives none of these rows.
2. Test a permanent upload error (RLS rejection): the op lands in `sync_errors` and the queue keeps moving.
3. Run it on the host platform; list manual steps for Android (airplane mode) and web (DevTools offline).
4. Report results and any fixes made.
