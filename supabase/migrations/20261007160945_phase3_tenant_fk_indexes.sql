-- Advisor follow-up for step 3.3: cover the tenant_id foreign keys of the
-- bank reconciliation tables (performance advisor 0001).
create index bank_reconciliations_tenant_idx on public.bank_reconciliations (tenant_id);
create index bank_statement_lines_tenant_idx on public.bank_statement_lines (tenant_id);
