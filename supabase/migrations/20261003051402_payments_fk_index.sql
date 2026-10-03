-- Step 1.5 follow-up: advisor 0001. The composite FK of a book reversal
-- (reverses_id, tenant_id) needs an index starting with the same columns.
create index cash_bank_entries_reverses_idx
  on public.cash_bank_entries (reverses_id, tenant_id);
