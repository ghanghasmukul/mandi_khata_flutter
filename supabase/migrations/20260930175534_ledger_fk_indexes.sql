-- Step 1.1 follow-up (advisor 0001 unindexed_foreign_keys): the composite
-- foreign keys (party_id, tenant_id) and (reverses_id, tenant_id) need an
-- index starting with the same columns.

-- Same lookups (one party's khata by date), columns in FK order.
drop index public.ledger_entries_party_date_idx;
create index ledger_entries_party_date_idx
  on public.ledger_entries (party_id, tenant_id, entry_date);

-- Still "reversed at most once": ids are unique, so (reverses_id, tenant_id)
-- is as strict as reverses_id alone, and its index covers the FK.
alter table public.ledger_entries drop constraint ledger_entries_reversed_once;
alter table public.ledger_entries
  add constraint ledger_entries_reversed_once unique (reverses_id, tenant_id);
