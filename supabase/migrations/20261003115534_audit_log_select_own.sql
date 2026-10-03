-- Step 1.10 fix: members without audit.view (munshi, accountant) could not
-- upload ANY change.
--
-- Every business write uploads an audit_log row, and apply_crud_transaction
-- inserts append-only rows with `on conflict (id) do nothing` (a retry of a
-- row that already landed is skipped). PostgreSQL checks the SELECT policies
-- of the existing row on that path, and audit_log could only be read with
-- audit.view, so the insert failed with "new row violates row-level security
-- policy for table audit_log" and the whole change was rejected. Found by the
-- two-device test (a munshi's phone), not by the owner-only tests before it.
--
-- Fix: everyone may read the audit rows they wrote themselves. The business
-- log stays owner-only (audit.view): a munshi sees nothing of anyone else's.
-- The PowerSync sync rules are unchanged (the log is still only synced to
-- members with audit.view).

create policy audit_log_select_own on public.audit_log
  for select to authenticated
  using (
    user_id = (select auth.uid())
    and tenant_id in (select private.auth_tenant_ids())
  );
