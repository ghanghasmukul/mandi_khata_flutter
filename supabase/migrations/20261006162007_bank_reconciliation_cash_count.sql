-- Step 3.3: bank reconciliation and the cash count at day close.
-- Rules: docs/domain/posting-rules.md, section 11.3.
--
-- bank_accounts.statement_mapping  the column mapping of the bank's
--                       statement file, saved at the first import.
-- bank_statement_lines  imported statement lines (append-only; ids are
--                       deterministic, so a file imported twice adds nothing).
-- bank_reconciliations  a bank book line marked reconciled on a date, with
--                       the statement line it matched (optional). Undo =
--                       soft delete.
-- cash_counts           notes and coins counted at day close; a difference
--                       is posted as a journal voucher (voucher_id).

alter table public.bank_accounts add column statement_mapping jsonb;

-- ---------------------------------------------------------------------------
-- bank_statement_lines
-- ---------------------------------------------------------------------------

create table public.bank_statement_lines (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  bank_account_id uuid not null,
  txn_date date not null,
  direction text not null check (direction in ('in', 'out')),
  amount_paise bigint not null check (amount_paise > 0),
  reference text,
  description text,
  balance_paise bigint,
  import_batch uuid not null,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint bank_statement_lines_id_tenant_unique unique (id, tenant_id),
  constraint bank_statement_lines_account_fk foreign key (bank_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id)
);

create index bank_statement_lines_account_idx
  on public.bank_statement_lines (bank_account_id, tenant_id, txn_date);
create index bank_statement_lines_device_idx
  on public.bank_statement_lines (device_id) where device_id is not null;

create trigger bank_statement_lines_set_created_by before insert on public.bank_statement_lines
  for each row execute function private.set_created_by();
create trigger bank_statement_lines_append_only
  before update or delete on public.bank_statement_lines
  for each row execute function private.reject_change();

create or replace function private.guard_bank_statement_line()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if private.account_kind(new.tenant_id, new.bank_account_id) is distinct from 'bank' then
    raise exception 'statement lines belong to a bank account' using errcode = '23514';
  end if;
  if (select auth.uid()) is not null and not exists (
    select 1 from public.devices d
    where d.id = new.device_id and d.tenant_id = new.tenant_id
      and d.user_id = (select auth.uid()) and d.revoked_at is null
  ) then
    raise exception 'statement lines must come from one of your devices in this business'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_bank_statement_line() from public, anon, authenticated;

create trigger bank_statement_lines_guard before insert on public.bank_statement_lines
  for each row execute function private.guard_bank_statement_line();

alter table public.bank_statement_lines enable row level security;

create policy bank_statement_lines_select on public.bank_statement_lines
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'finance.view')));
create policy bank_statement_lines_insert on public.bank_statement_lines
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'finance.view')));

revoke all on public.bank_statement_lines from anon;
revoke update, delete, truncate on public.bank_statement_lines from authenticated;

-- ---------------------------------------------------------------------------
-- bank_reconciliations
-- ---------------------------------------------------------------------------

create table public.bank_reconciliations (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  bank_account_id uuid not null,
  book_line_id uuid not null,
  statement_line_id uuid,
  reconciled_on date not null,
  deleted_at timestamptz,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint bank_reconciliations_id_tenant_unique unique (id, tenant_id),
  constraint bank_reconciliations_account_fk foreign key (bank_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id),
  constraint bank_reconciliations_book_fk foreign key (book_line_id, tenant_id)
    references public.cash_bank_entries (id, tenant_id),
  constraint bank_reconciliations_statement_fk foreign key (statement_line_id, tenant_id)
    references public.bank_statement_lines (id, tenant_id)
);

-- A line is reconciled at most once at a time.
create unique index bank_reconciliations_book_unique
  on public.bank_reconciliations (book_line_id) where deleted_at is null;
create unique index bank_reconciliations_statement_unique
  on public.bank_reconciliations (statement_line_id)
  where deleted_at is null and statement_line_id is not null;
create index bank_reconciliations_account_idx
  on public.bank_reconciliations (bank_account_id, tenant_id);
create index bank_reconciliations_book_fk_idx
  on public.bank_reconciliations (book_line_id, tenant_id);
create index bank_reconciliations_statement_fk_idx
  on public.bank_reconciliations (statement_line_id, tenant_id)
  where statement_line_id is not null;
create index bank_reconciliations_device_idx
  on public.bank_reconciliations (device_id) where device_id is not null;

create trigger bank_reconciliations_set_updated_at before update on public.bank_reconciliations
  for each row execute function private.set_updated_at();
create trigger bank_reconciliations_set_created_by before insert on public.bank_reconciliations
  for each row execute function private.set_created_by();
create trigger bank_reconciliations_keep_tenant_id before update on public.bank_reconciliations
  for each row execute function private.keep_tenant_id();

-- The book line and the statement line are of this bank account and agree
-- on direction and amount; afterwards only the undo (deleted_at) changes.
create or replace function private.guard_bank_reconciliation()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_book public.cash_bank_entries;
  v_statement public.bank_statement_lines;
begin
  if tg_op = 'UPDATE' then
    if old.deleted_at is not null then
      raise exception 'an undone reconciliation cannot change' using errcode = '42501';
    end if;
    if (to_jsonb(new) - 'deleted_at' - 'updated_at')
      <> (to_jsonb(old) - 'deleted_at' - 'updated_at') then
      raise exception 'a reconciliation can only be undone' using errcode = '42501';
    end if;
    return new;
  end if;

  select * into v_book from public.cash_bank_entries e
  where e.id = new.book_line_id and e.tenant_id = new.tenant_id;
  if not found or v_book.account_id <> new.bank_account_id or v_book.account_kind <> 'bank' then
    raise exception 'the book line is not a line of this bank account' using errcode = '23514';
  end if;
  if new.statement_line_id is not null then
    select * into v_statement from public.bank_statement_lines s
    where s.id = new.statement_line_id and s.tenant_id = new.tenant_id;
    if not found or v_statement.bank_account_id <> new.bank_account_id
      or v_statement.direction <> v_book.direction
      or v_statement.amount_paise <> v_book.amount_paise then
      raise exception 'the statement line must be of this account, same direction and amount'
        using errcode = '23514';
    end if;
  end if;
  if (select auth.uid()) is not null and not exists (
    select 1 from public.devices d
    where d.id = new.device_id and d.tenant_id = new.tenant_id
      and d.user_id = (select auth.uid()) and d.revoked_at is null
  ) then
    raise exception 'reconciliations must come from one of your devices in this business'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_bank_reconciliation() from public, anon, authenticated;

create trigger bank_reconciliations_guard before insert or update on public.bank_reconciliations
  for each row execute function private.guard_bank_reconciliation();

alter table public.bank_reconciliations enable row level security;

create policy bank_reconciliations_select on public.bank_reconciliations
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'finance.view')));
create policy bank_reconciliations_insert on public.bank_reconciliations
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'finance.view')));
create policy bank_reconciliations_update on public.bank_reconciliations
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'finance.view')))
  with check ((select private.has_permission(tenant_id, 'finance.view')));

revoke all on public.bank_reconciliations from anon;
revoke delete, truncate on public.bank_reconciliations from authenticated;

-- ---------------------------------------------------------------------------
-- cash_counts
-- ---------------------------------------------------------------------------

create table public.cash_counts (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  count_date date not null,
  bank_account_id uuid not null,
  -- {"500": 20, "100": 7, "loose": 50}: pieces per note, loose paise.
  denominations jsonb not null,
  counted_paise bigint not null check (counted_paise >= 0),
  book_paise bigint not null,
  difference_paise bigint not null,
  -- The journal voucher that posted the difference, when it was posted.
  voucher_id uuid,
  note text,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint cash_counts_id_tenant_unique unique (id, tenant_id),
  constraint cash_counts_difference check (difference_paise = counted_paise - book_paise),
  constraint cash_counts_account_fk foreign key (bank_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id),
  constraint cash_counts_voucher_fk foreign key (voucher_id, tenant_id)
    references public.vouchers (id, tenant_id)
);

create index cash_counts_tenant_date_idx on public.cash_counts (tenant_id, count_date);
create index cash_counts_account_fk_idx on public.cash_counts (bank_account_id, tenant_id);
create index cash_counts_voucher_fk_idx on public.cash_counts (voucher_id, tenant_id)
  where voucher_id is not null;
create index cash_counts_device_idx on public.cash_counts (device_id) where device_id is not null;

create trigger cash_counts_set_updated_at before update on public.cash_counts
  for each row execute function private.set_updated_at();
create trigger cash_counts_set_created_by before insert on public.cash_counts
  for each row execute function private.set_created_by();
create trigger cash_counts_keep_tenant_id before update on public.cash_counts
  for each row execute function private.keep_tenant_id();

-- A count is of the Cash account and is frozen; the only change is setting
-- the voucher that posted its difference (entries.reverse).
create or replace function private.guard_cash_count()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    if old.voucher_id is not null
      or (to_jsonb(new) - 'voucher_id' - 'updated_at')
        <> (to_jsonb(old) - 'voucher_id' - 'updated_at') then
      raise exception 'a cash count is frozen; only its difference can be posted once'
        using errcode = '42501';
    end if;
    if (select auth.uid()) is not null
      and not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
      raise exception 'posting a cash difference needs entries.reverse' using errcode = '42501';
    end if;
    return new;
  end if;

  if private.account_kind(new.tenant_id, new.bank_account_id) is distinct from 'cash' then
    raise exception 'a cash count is of the Cash account' using errcode = '23514';
  end if;
  if (select auth.uid()) is not null then
    if new.voucher_id is not null
      and not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
      raise exception 'posting a cash difference needs entries.reverse' using errcode = '42501';
    end if;
    if not exists (
      select 1 from public.devices d
      where d.id = new.device_id and d.tenant_id = new.tenant_id
        and d.user_id = (select auth.uid()) and d.revoked_at is null
    ) then
      raise exception 'cash counts must come from one of your devices in this business'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_cash_count() from public, anon, authenticated;

create trigger cash_counts_guard before insert or update on public.cash_counts
  for each row execute function private.guard_cash_count();

alter table public.cash_counts enable row level security;

-- Everyone who handles cash sees the counts (the cash book is not secret).
create policy cash_counts_select on public.cash_counts
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));
create policy cash_counts_insert on public.cash_counts
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'payments.create')));
create policy cash_counts_update on public.cash_counts
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));

revoke all on public.cash_counts from anon;
revoke delete, truncate on public.cash_counts from authenticated;

alter publication powersync add table public.bank_statement_lines,
  public.bank_reconciliations, public.cash_counts;
