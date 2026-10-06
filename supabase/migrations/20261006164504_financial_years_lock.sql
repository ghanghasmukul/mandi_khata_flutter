-- Step 3.5: financial years, year close and the lock of a closed year.
-- Rules: docs/domain/posting-rules.md, section 11.5.
--
-- financial_years   one row per closed (or being closed) year: April-March,
--                   status, the closing journal entry, the profit. Owner only.
-- journal_entries   source_type 'year_close' (the closing entry, dated
--                   31 March) and lock_reason (the owner's reason for any
--                   entry dated inside a closed year).
-- lock              khata entries, journal entries, payments, vouchers,
--                   expenses and book lines dated inside a closed year are
--                   refused unless the uploader is an owner; a journal entry
--                   there also needs a reason.

create table public.financial_years (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  start_date date not null check (extract(month from start_date) = 4
    and extract(day from start_date) = 1),
  end_date date not null,
  status text not null default 'closed' check (status in ('open', 'closed')),
  closed_at timestamptz,
  closed_by uuid,
  closing_entry_id uuid,
  profit_paise bigint not null default 0,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint financial_years_id_tenant_unique unique (id, tenant_id),
  constraint financial_years_year_unique unique (tenant_id, start_date),
  constraint financial_years_end check (end_date = (start_date + interval '1 year' - interval '1 day')::date),
  constraint financial_years_closed check ((status = 'closed') = (closed_at is not null)),
  constraint financial_years_entry_fk foreign key (closing_entry_id, tenant_id)
    references public.journal_entries (id, tenant_id)
);

create index financial_years_entry_fk_idx on public.financial_years (closing_entry_id, tenant_id)
  where closing_entry_id is not null;
create index financial_years_device_idx on public.financial_years (device_id)
  where device_id is not null;

create trigger financial_years_set_updated_at before update on public.financial_years
  for each row execute function private.set_updated_at();
create trigger financial_years_set_created_by before insert on public.financial_years
  for each row execute function private.set_created_by();
create trigger financial_years_keep_tenant_id before update on public.financial_years
  for each row execute function private.keep_tenant_id();

-- Owner only; a closed year stays closed (re-opening is not offered in v1);
-- years close in order.
create or replace function private.guard_financial_year()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (select auth.uid()) is not null and not private.is_owner(new.tenant_id) then
    raise exception 'only the owner closes a financial year' using errcode = '42501';
  end if;
  if tg_op = 'UPDATE' and old.status = 'closed' then
    raise exception 'a closed financial year stays closed' using errcode = '42501';
  end if;
  if new.status = 'closed' and exists (
    select 1 from public.financial_years f
    where f.tenant_id = new.tenant_id and f.start_date < new.start_date
      and f.status <> 'closed'
  ) then
    raise exception 'close the earlier year first' using errcode = '23514';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_financial_year() from public, anon, authenticated;

create trigger financial_years_guard before insert or update on public.financial_years
  for each row execute function private.guard_financial_year();

alter table public.financial_years enable row level security;

-- Everyone sees which years are closed (their app must refuse dates there).
create policy financial_years_select on public.financial_years
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));
create policy financial_years_insert on public.financial_years
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.is_owner(tenant_id)));
create policy financial_years_update on public.financial_years
  for update to authenticated
  using ((select private.is_owner(tenant_id)))
  with check ((select private.is_owner(tenant_id)));

revoke all on public.financial_years from anon;
revoke delete, truncate on public.financial_years from authenticated;

-- ---------------------------------------------------------------------------
-- Journal: year-close entries and the reason for a locked date
-- ---------------------------------------------------------------------------

alter table public.journal_entries add column lock_reason text;

alter table public.journal_entries drop constraint journal_entries_source_type_check;
alter table public.journal_entries add constraint journal_entries_source_type_check
  check (source_type in (
    'lot', 'payment', 'interest', 'waiver', 'entry', 'reversal', 'voucher', 'expense',
    'year_close'
  ));

-- ---------------------------------------------------------------------------
-- The lock
-- ---------------------------------------------------------------------------

create or replace function private.date_locked(p_tenant uuid, p_date date)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.financial_years f
    where f.tenant_id = p_tenant and f.status = 'closed'
      and p_date between f.start_date and f.end_date
  );
$$;

revoke execute on function private.date_locked(uuid, date) from public, anon;
grant execute on function private.date_locked(uuid, date) to authenticated;

create or replace function private.guard_locked_period()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_date date := (to_jsonb(new) ->> 'entry_date')::date;
begin
  if (select auth.uid()) is null or v_date is null
    or not private.date_locked(new.tenant_id, v_date) then
    return new;
  end if;
  if not private.is_owner(new.tenant_id) then
    raise exception 'this date is in a closed financial year; only the owner can post there'
      using errcode = '42501';
  end if;
  if tg_table_name = 'journal_entries'
    and length(trim(coalesce(to_jsonb(new) ->> 'lock_reason', ''))) = 0 then
    raise exception 'an entry in a closed financial year needs a reason'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_locked_period() from public, anon, authenticated;

create trigger ledger_entries_locked_period before insert on public.ledger_entries
  for each row execute function private.guard_locked_period();
create trigger journal_entries_locked_period before insert on public.journal_entries
  for each row execute function private.guard_locked_period();
create trigger payments_locked_period before insert on public.payments
  for each row execute function private.guard_locked_period();
create trigger vouchers_locked_period before insert on public.vouchers
  for each row execute function private.guard_locked_period();
create trigger expenses_locked_period before insert on public.expenses
  for each row execute function private.guard_locked_period();
create trigger cash_bank_entries_locked_period before insert on public.cash_bank_entries
  for each row execute function private.guard_locked_period();

alter publication powersync add table public.financial_years;
