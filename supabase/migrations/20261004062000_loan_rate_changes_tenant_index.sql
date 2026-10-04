-- Step 2.2 follow-up: advisor 0001. The tenant FK of loan_rate_changes needs
-- its own covering index.
create index loan_rate_changes_tenant_idx on public.loan_rate_changes (tenant_id);
