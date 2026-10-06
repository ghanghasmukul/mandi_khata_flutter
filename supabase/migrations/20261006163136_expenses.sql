-- Step 3.4: expenses. Rules: docs/domain/posting-rules.md, section 11.4.
--
-- expense_categories  per business, seeded (palledari, transport, salary,
--                     bardana, mandi charges, electricity, rent, misc);
--                     each gets its own expense account from the server
--                     (accounts.expense_category_id), in Direct or Indirect
--                     Expenses.
-- expenses            EX- numbered; posts Dr expense account / Cr cash or
--                     bank (journal source_type 'expense') and one book line
--                     (cash_bank_entries.expense_id) in the same upload.
-- recurring_expenses  templates (monthly salary, rent); a month is posted
--                     once (unique recurring_id + period).
-- storage bucket      'bills' (private), path <tenant>/<expense>/<file>.

-- ---------------------------------------------------------------------------
-- expense_categories
-- ---------------------------------------------------------------------------

create table public.expense_categories (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- Set for the seeded categories (stable, part of their id).
  code text check (code is null or code ~ '^[a-z][a-z0-9_]{0,39}$'),
  name text not null check (length(trim(name)) > 0),
  group_code text not null default 'indirect_expenses'
    check (group_code in ('direct_expenses', 'indirect_expenses')),
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint expense_categories_id_tenant_unique unique (id, tenant_id)
);

create unique index expense_categories_code_unique
  on public.expense_categories (tenant_id, code) where code is not null;
create index expense_categories_tenant_idx on public.expense_categories (tenant_id, sort_order);

create trigger expense_categories_set_updated_at before update on public.expense_categories
  for each row execute function private.set_updated_at();
create trigger expense_categories_set_created_by before insert on public.expense_categories
  for each row execute function private.set_created_by();
create trigger expense_categories_keep_tenant_id before update on public.expense_categories
  for each row execute function private.keep_tenant_id();

-- A category's code never changes; clients do not create coded (seeded)
-- categories.
create or replace function private.guard_expense_category()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('authenticated', 'anon') then
    if tg_op = 'INSERT' and new.code is not null then
      raise exception 'seeded categories are created by the system' using errcode = '42501';
    end if;
    if tg_op = 'UPDATE' and new.code is distinct from old.code then
      raise exception 'a category keeps its code' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_expense_category() from public, anon, authenticated;

create trigger expense_categories_guard before insert or update on public.expense_categories
  for each row execute function private.guard_expense_category();

alter table public.expense_categories enable row level security;

create policy expense_categories_select on public.expense_categories
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));
create policy expense_categories_insert on public.expense_categories
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'entries.reverse')));
create policy expense_categories_update on public.expense_categories
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));

revoke all on public.expense_categories from anon;
revoke delete, truncate on public.expense_categories from authenticated;

-- ---------------------------------------------------------------------------
-- The category's account (created and kept in step by the server)
-- ---------------------------------------------------------------------------

alter table public.accounts add column expense_category_id uuid;
alter table public.accounts add constraint accounts_expense_category_fk
  foreign key (expense_category_id, tenant_id)
  references public.expense_categories (id, tenant_id);
create unique index accounts_expense_category_unique
  on public.accounts (tenant_id, expense_category_id) where expense_category_id is not null;
create index accounts_expense_category_fk_idx
  on public.accounts (expense_category_id, tenant_id) where expense_category_id is not null;

alter table public.accounts drop constraint accounts_one_owner;
alter table public.accounts add constraint accounts_one_owner check (
  num_nonnulls(party_id, bank_account_id, system_code, expense_category_id) <= 1
);

create or replace function private.guard_chart_row()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('authenticated', 'anon') then
    if tg_op = 'INSERT' and new.is_system then
      raise exception 'system rows are created by the system' using errcode = '42501';
    end if;
    if tg_op = 'INSERT' and tg_table_name = 'accounts' and (
      new.party_id is not null or new.bank_account_id is not null
      or new.system_code is not null or new.expense_category_id is not null
    ) then
      raise exception 'party, cash / bank, system and expense accounts are created by the system'
        using errcode = '42501';
    end if;
    if tg_op = 'UPDATE' and old.is_system and tg_table_name = 'account_groups' then
      raise exception 'a system group cannot be changed' using errcode = '42501';
    end if;
    if tg_op = 'UPDATE' and tg_table_name = 'accounts' then
      if new.party_id is distinct from old.party_id
        or new.bank_account_id is distinct from old.bank_account_id
        or new.system_code is distinct from old.system_code
        or new.expense_category_id is distinct from old.expense_category_id
        or new.is_system is distinct from old.is_system then
        raise exception 'an account keeps its identity' using errcode = '42501';
      end if;
      if old.is_system and new.group_id is distinct from old.group_id then
        raise exception 'a system account keeps its group' using errcode = '42501';
      end if;
      if old.expense_category_id is not null and (
        new.group_id is distinct from old.group_id or new.name is distinct from old.name
      ) then
        raise exception 'an expense account follows its category; edit the category'
          using errcode = '42501';
      end if;
    end if;
  end if;
  return new;
end;
$$;

create or replace function private.ensure_expense_account(p_tenant uuid, p_category uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform private.seed_chart_groups(p_tenant);
  insert into public.accounts (id, tenant_id, group_id, name, expense_category_id)
  select private.chart_id(p_tenant, 'expense', c.id::text), p_tenant,
         private.chart_id(p_tenant, 'group', c.group_code), c.name, c.id
  from public.expense_categories c where c.id = p_category and c.tenant_id = p_tenant
  on conflict (id) do nothing;
end;
$$;

-- Seeded categories: ids are UUID v5 like every chart row, so the app knows
-- them before they sync.
create or replace function private.seed_expense_categories(p_tenant uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  insert into public.expense_categories (id, tenant_id, code, name, group_code, sort_order)
  select private.chart_id(p_tenant, 'expense_category', c.code), p_tenant, c.code, c.name,
         c.grp, c.ord
  from (values
    ('palledari',     'Palledari',     'direct_expenses',   10),
    ('transport',     'Transport',     'direct_expenses',   20),
    ('salary',        'Salary',        'indirect_expenses', 30),
    ('bardana',       'Bardana',       'direct_expenses',   40),
    ('mandi_charges', 'Mandi charges', 'direct_expenses',   50),
    ('electricity',   'Electricity',   'indirect_expenses', 60),
    ('rent',          'Rent',          'indirect_expenses', 70),
    ('misc',          'Miscellaneous', 'indirect_expenses', 80)
  ) as c(code, name, grp, ord)
  on conflict (id) do nothing;
end;
$$;

revoke execute on function private.ensure_expense_account(uuid, uuid),
  private.seed_expense_categories(uuid) from public, anon, authenticated;

create or replace function private.chart_for_expense_category()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    perform private.ensure_expense_account(new.tenant_id, new.id);
  else
    update public.accounts a
    set name = new.name,
        group_id = private.chart_id(new.tenant_id, 'group', new.group_code),
        is_active = new.is_active
    where a.id = private.chart_id(new.tenant_id, 'expense', new.id::text)
      and (a.name is distinct from new.name
        or a.group_id is distinct from private.chart_id(new.tenant_id, 'group', new.group_code)
        or a.is_active is distinct from new.is_active);
  end if;
  return new;
end;
$$;

create or replace function private.expense_categories_for_new_tenant()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  perform private.seed_expense_categories(new.id);
  return new;
end;
$$;

revoke execute on function private.chart_for_expense_category(),
  private.expense_categories_for_new_tenant() from public, anon, authenticated;

create trigger expense_categories_chart after insert or update on public.expense_categories
  for each row execute function private.chart_for_expense_category();
-- After the chart is seeded (trigger names fire in alphabetical order).
create trigger tenants_zz_expense_categories after insert on public.tenants
  for each row execute function private.expense_categories_for_new_tenant();

select private.seed_expense_categories(id) from public.tenants;

-- ---------------------------------------------------------------------------
-- recurring_expenses
-- ---------------------------------------------------------------------------

create table public.recurring_expenses (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  category_id uuid not null,
  amount_paise bigint not null check (amount_paise > 0),
  mode text not null check (mode in ('cash', 'bank')),
  bank_account_id uuid not null,
  paid_to text,
  narration text,
  day_of_month integer not null check (day_of_month between 1 and 31),
  start_date date not null,
  end_date date,
  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint recurring_expenses_id_tenant_unique unique (id, tenant_id),
  constraint recurring_expenses_dates check (end_date is null or end_date >= start_date),
  constraint recurring_expenses_category_fk foreign key (category_id, tenant_id)
    references public.expense_categories (id, tenant_id),
  constraint recurring_expenses_account_fk foreign key (bank_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id)
);

create index recurring_expenses_tenant_idx on public.recurring_expenses (tenant_id);
create index recurring_expenses_category_fk_idx
  on public.recurring_expenses (category_id, tenant_id);
create index recurring_expenses_account_fk_idx
  on public.recurring_expenses (bank_account_id, tenant_id);

create trigger recurring_expenses_set_updated_at before update on public.recurring_expenses
  for each row execute function private.set_updated_at();
create trigger recurring_expenses_set_created_by before insert on public.recurring_expenses
  for each row execute function private.set_created_by();
create trigger recurring_expenses_keep_tenant_id before update on public.recurring_expenses
  for each row execute function private.keep_tenant_id();

alter table public.recurring_expenses enable row level security;

create policy recurring_expenses_select on public.recurring_expenses
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));
create policy recurring_expenses_insert on public.recurring_expenses
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'entries.reverse')));
create policy recurring_expenses_update on public.recurring_expenses
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));

revoke all on public.recurring_expenses from anon;
revoke delete, truncate on public.recurring_expenses from authenticated;

-- ---------------------------------------------------------------------------
-- expenses
-- ---------------------------------------------------------------------------

create table public.expenses (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  expense_no text not null check (length(trim(expense_no)) > 0),
  entry_date date not null,
  category_id uuid not null,
  amount_paise bigint not null check (amount_paise > 0),
  mode text not null check (mode in ('cash', 'bank')),
  bank_account_id uuid not null,
  paid_to text,
  narration text,
  -- Storage path of the bill photo (bucket 'bills'); set once.
  bill_path text,
  recurring_id uuid,
  -- yyyy-mm of the recurring month this expense posts.
  period text check (period is null or period ~ '^[0-9]{4}-[0-9]{2}$'),
  status text not null default 'posted' check (status in ('posted', 'reversed')),
  reversed_at timestamptz,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint expenses_no_unique unique (tenant_id, expense_no),
  constraint expenses_id_tenant_unique unique (id, tenant_id),
  constraint expenses_reversed_at check ((status = 'reversed') = (reversed_at is not null)),
  constraint expenses_recurring_period check ((recurring_id is null) = (period is null)),
  constraint expenses_category_fk foreign key (category_id, tenant_id)
    references public.expense_categories (id, tenant_id),
  constraint expenses_account_fk foreign key (bank_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id),
  constraint expenses_recurring_fk foreign key (recurring_id, tenant_id)
    references public.recurring_expenses (id, tenant_id)
);

-- A recurring month is posted once, even by two devices.
create unique index expenses_recurring_period_unique
  on public.expenses (recurring_id, period) where recurring_id is not null;
create index expenses_tenant_date_idx on public.expenses (tenant_id, entry_date);
create index expenses_category_fk_idx on public.expenses (category_id, tenant_id);
create index expenses_account_fk_idx on public.expenses (bank_account_id, tenant_id);
create index expenses_recurring_fk_idx on public.expenses (recurring_id, tenant_id)
  where recurring_id is not null;
create index expenses_device_idx on public.expenses (device_id) where device_id is not null;

create trigger expenses_set_updated_at before update on public.expenses
  for each row execute function private.set_updated_at();
create trigger expenses_set_created_by before insert on public.expenses
  for each row execute function private.set_created_by();
create trigger expenses_keep_tenant_id before update on public.expenses
  for each row execute function private.keep_tenant_id();

-- Like a payment: frozen once posted except reversal (entries.reverse) and
-- attaching the bill once; cash through the Cash account only; back-dating
-- and bank need more permission.
create or replace function private.guard_expense()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_kind text;
begin
  if tg_op = 'INSERT' then
    if new.status <> 'posted' then
      raise exception 'an expense is created posted' using errcode = '23514';
    end if;
    if new.created_at > now() + interval '1 day' then
      raise exception 'created_at is in the future' using errcode = '23514';
    end if;
    v_kind := private.account_kind(new.tenant_id, new.bank_account_id);
    if v_kind is not null and (v_kind = 'cash') <> (new.mode = 'cash') then
      raise exception 'cash goes through the Cash account, bank through a bank account'
        using errcode = '23514';
    end if;
    if (select auth.uid()) is not null then
      if not (select private.has_permission(new.tenant_id, 'payments.create')) then
        raise exception 'expenses need payments.create' using errcode = '42501';
      end if;
      if new.mode <> 'cash'
        and not (select private.has_permission(new.tenant_id, 'finance.view')) then
        raise exception 'bank expenses need finance.view' using errcode = '42501';
      end if;
      if private.ledger_date_restricted(new.tenant_id, new.entry_date, new.created_at)
        and not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
        raise exception 'a back-dated expense needs entries.reverse' using errcode = '42501';
      end if;
      if not exists (
        select 1 from public.devices d
        where d.id = new.device_id and d.tenant_id = new.tenant_id
          and d.user_id = (select auth.uid()) and d.revoked_at is null
      ) then
        raise exception 'expenses must come from one of your devices in this business'
          using errcode = '42501';
      end if;
    end if;
    return new;
  end if;

  if old.status = 'reversed' then
    raise exception 'a reversed expense cannot change' using errcode = '42501';
  end if;
  if (to_jsonb(new) - 'status' - 'reversed_at' - 'bill_path' - 'updated_at')
    <> (to_jsonb(old) - 'status' - 'reversed_at' - 'bill_path' - 'updated_at') then
    raise exception 'a posted expense cannot change; reverse it instead'
      using errcode = '42501';
  end if;
  if old.bill_path is not null and new.bill_path is distinct from old.bill_path then
    raise exception 'a bill is attached once' using errcode = '42501';
  end if;
  if (select auth.uid()) is not null and new.status is distinct from old.status
    and not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
    raise exception 'reversing an expense needs entries.reverse' using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_expense() from public, anon, authenticated;

create trigger expenses_guard before insert or update on public.expenses
  for each row execute function private.guard_expense();

alter table public.expenses enable row level security;

create policy expenses_select on public.expenses
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));
create policy expenses_insert on public.expenses
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'payments.create')));
create policy expenses_update on public.expenses
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'payments.create'))
    or (select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'payments.create'))
    or (select private.has_permission(tenant_id, 'entries.reverse')));

revoke all on public.expenses from anon;
revoke delete, truncate on public.expenses from authenticated;

-- ---------------------------------------------------------------------------
-- Journal and cash / bank book
-- ---------------------------------------------------------------------------

alter table public.journal_entries drop constraint journal_entries_source_type_check;
alter table public.journal_entries add constraint journal_entries_source_type_check
  check (source_type in (
    'lot', 'payment', 'interest', 'waiver', 'entry', 'reversal', 'voucher', 'expense'
  ));

create or replace function private.journal_post_permission(p_source_type text)
returns text
language sql
immutable
set search_path = ''
as $$
  select case p_source_type
    when 'lot' then 'arrivals.manage'
    when 'payment' then 'payments.create'
    when 'expense' then 'payments.create'
    when 'interest' then 'loans.manage'
    else 'entries.reverse'
  end;
$$;

alter table public.cash_bank_entries add column expense_id uuid;
alter table public.cash_bank_entries add constraint cash_bank_entries_expense_fk
  foreign key (expense_id, tenant_id) references public.expenses (id, tenant_id);
alter table public.cash_bank_entries drop constraint cash_bank_entries_one_source;
alter table public.cash_bank_entries add constraint cash_bank_entries_one_source
  check (num_nonnulls(payment_id, voucher_id, expense_id) = 1);
create index cash_bank_entries_expense_idx on public.cash_bank_entries (expense_id, tenant_id)
  where expense_id is not null;

create or replace function private.guard_cash_bank_entry()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_kind text;
  v_original public.cash_bank_entries;
begin
  v_kind := private.account_kind(new.tenant_id, new.account_id);
  if v_kind is not null and v_kind <> new.account_kind then
    raise exception 'account_kind does not match the account' using errcode = '23514';
  end if;

  if new.reverses_id is not null then
    select * into v_original from public.cash_bank_entries e
    where e.id = new.reverses_id and e.tenant_id = new.tenant_id;
    if found and (
      v_original.reverses_id is not null
      or v_original.account_id <> new.account_id
      or v_original.payment_id is distinct from new.payment_id
      or v_original.voucher_id is distinct from new.voucher_id
      or v_original.expense_id is distinct from new.expense_id
      or v_original.direction = new.direction
      or v_original.amount_paise <> new.amount_paise
    ) then
      raise exception 'a reversal must mirror the line it reverses'
        using errcode = '23514';
    end if;
  end if;

  if (select auth.uid()) is not null then
    if not exists (
      select 1 from public.devices d
      where d.id = new.device_id and d.tenant_id = new.tenant_id
        and d.user_id = (select auth.uid()) and d.revoked_at is null
    ) then
      raise exception 'book lines must come from one of your devices in this business'
        using errcode = '42501';
    end if;
    if new.account_kind = 'bank'
      and not (select private.has_permission(new.tenant_id, 'finance.view')) then
      raise exception 'bank book lines need finance.view' using errcode = '42501';
    end if;
    if new.reverses_id is not null or new.voucher_id is not null then
      if not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
        raise exception 'this book line needs entries.reverse' using errcode = '42501';
      end if;
    elsif not (select private.has_permission(new.tenant_id, 'payments.create')) then
      raise exception 'book lines need payments.create' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Bill photos: private bucket, one folder per business
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('bills', 'bills', false, 10485760,
  array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf'])
on conflict (id) do nothing;

create policy bills_select on storage.objects
  for select to authenticated
  using (bucket_id = 'bills'
    and (storage.foldername(name))[1] in (
      select t::text from private.auth_tenant_ids() t));
create policy bills_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'bills'
    and (storage.foldername(name))[1] in (
      select t::text from private.auth_tenant_ids() t)
    and (select private.has_permission(
      ((storage.foldername(name))[1])::uuid, 'payments.create')));

alter publication powersync add table public.expense_categories,
  public.recurring_expenses, public.expenses;
