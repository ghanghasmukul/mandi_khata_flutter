-- Advisor follow-up for the chart / journal tables: the composite foreign keys
-- (account_id, tenant_id) and (reverses_id, tenant_id) had no covering index.
create index journal_lines_account_fk_idx
  on public.journal_lines (account_id, tenant_id);
create index journal_entries_reverses_fk_idx
  on public.journal_entries (reverses_id, tenant_id)
  where reverses_id is not null;
