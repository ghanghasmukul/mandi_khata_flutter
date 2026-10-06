-- Step 3.2: voucher entry (Tally style) and the chart rows phase 3 needs.
-- Rules: docs/domain/posting-rules.md, section 11.1 and 11.2.
--
-- vouchers          contra / payment / receipt / sales / purchase / journal.
--                   Frozen once posted; reversed as a whole (entries.reverse).
-- journal_entries   a voucher's entry has source_type 'voucher' and
--                   voucher_id = the voucher.
-- ledger_entries    a voucher line on a party's account posts ref_type
--                   'voucher' (ref_id = the voucher).
-- cash_bank_entries a voucher line on a cash / bank account writes a book
--                   line with voucher_id (payment_id is now optional).
-- chart             new groups Sales Accounts / Purchase Accounts and system
--                   accounts Sales, Purchase, Capital, Profit & Loss A/c,
--                   Cash Short / Excess, for every business.

-- ---------------------------------------------------------------------------
-- Chart rows
-- ---------------------------------------------------------------------------

create or replace function private.seed_chart_groups(p_tenant uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  insert into public.account_groups (id, tenant_id, code, name, parent_id, nature, is_system)
  select private.chart_id(p_tenant, 'group', g.code), p_tenant, g.code, g.name,
         case when g.parent is null then null
              else private.chart_id(p_tenant, 'group', g.parent) end,
         g.nature, true
  from (values
    ('capital',             'Capital Account',          null,                  'liability'),
    ('current_assets',      'Current Assets',           null,                  'asset'),
    ('sundry_debtors',      'Sundry Debtors',           'current_assets',      'asset'),
    ('cash_in_hand',        'Cash-in-hand',             'current_assets',      'asset'),
    ('bank_accounts',       'Bank Accounts',            'current_assets',      'asset'),
    ('stock_in_hand',       'Stock-in-hand',            'current_assets',      'asset'),
    ('loans_and_advances',  'Loans & Advances (Asset)', 'current_assets',      'asset'),
    ('current_liabilities', 'Current Liabilities',      null,                  'liability'),
    ('sundry_creditors',    'Sundry Creditors',         'current_liabilities', 'liability'),
    ('duties_and_taxes',    'Duties & Taxes',           'current_liabilities', 'liability'),
    ('direct_income',       'Direct Income',            null,                  'income'),
    ('indirect_income',     'Indirect Income',          null,                  'income'),
    ('direct_expenses',     'Direct Expenses',          null,                  'expense'),
    ('indirect_expenses',   'Indirect Expenses',        null,                  'expense'),
    ('sales_accounts',      'Sales Accounts',           null,                  'income'),
    ('purchase_accounts',   'Purchase Accounts',        null,                  'expense')
  ) as g(code, name, parent, nature)
  order by (g.parent is not null)
  on conflict (tenant_id, code) do nothing;
end;
$$;

create or replace function private.seed_chart_accounts(p_tenant uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform private.seed_chart_groups(p_tenant);
  insert into public.accounts (id, tenant_id, group_id, name, system_code, is_system)
  select private.chart_id(p_tenant, 'account', a.code), p_tenant,
         private.chart_id(p_tenant, 'group', a.grp), a.name, a.code, true
  from (values
    ('commission_income',      'Commission Income',      'direct_income'),
    ('palledari_receipts',     'Palledari Receipts',     'direct_income'),
    ('bardana_receipts',       'Bardana Receipts',       'direct_income'),
    ('tulai_receipts',         'Tulai Receipts',         'direct_income'),
    ('interest_income',        'Interest Income',        'indirect_income'),
    ('mandi_fee_payable',      'Mandi Fee Payable',      'duties_and_taxes'),
    ('cess_payable',           'Cess Payable',           'duties_and_taxes'),
    ('mandi_fee_own_cost',     'Mandi Fee (own cost)',   'direct_expenses'),
    ('cess_own_cost',          'Cess (own cost)',        'direct_expenses'),
    ('interest_waived',        'Interest Waived',        'indirect_expenses'),
    ('lot_sale_clearing',      'Lot Sale Clearing',      'current_assets'),
    ('khata_adjustments',      'Khata Adjustments',      'current_liabilities'),
    ('opening_balance_equity', 'Opening Balance Equity', 'capital'),
    ('sales',                  'Sales',                  'sales_accounts'),
    ('purchase',               'Purchase',               'purchase_accounts'),
    ('capital',                'Capital',                'capital'),
    ('profit_and_loss',        'Profit & Loss A/c',      'capital'),
    ('cash_short_excess',      'Cash Short / Excess',    'indirect_expenses')
  ) as a(code, name, grp)
  on conflict (id) do nothing;
end;
$$;

revoke execute on function private.seed_chart_groups(uuid), private.seed_chart_accounts(uuid)
  from public, anon, authenticated;

select private.seed_chart_accounts(id) from public.tenants;

-- Clients add their own accounts, never one that owns a party, a bank
-- account or a system code (those come from the server only).
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
      or new.system_code is not null
    ) then
      raise exception 'party, cash / bank and system accounts are created by the system'
        using errcode = '42501';
    end if;
    if tg_op = 'UPDATE' and old.is_system and tg_table_name = 'account_groups' then
      raise exception 'a system group cannot be changed' using errcode = '42501';
    end if;
    if tg_op = 'UPDATE' and tg_table_name = 'accounts' then
      if new.party_id is distinct from old.party_id
        or new.bank_account_id is distinct from old.bank_account_id
        or new.system_code is distinct from old.system_code
        or new.is_system is distinct from old.is_system then
        raise exception 'an account keeps its identity' using errcode = '42501';
      end if;
      if old.is_system and new.group_id is distinct from old.group_id then
        raise exception 'a system account keeps its group' using errcode = '42501';
      end if;
    end if;
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- vouchers
-- ---------------------------------------------------------------------------

create table public.vouchers (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  voucher_type text not null
    check (voucher_type in ('contra', 'payment', 'receipt', 'sales', 'purchase', 'journal')),
  -- CV- / PY- / RC- / SV- / PU- / JV- + device code + counter.
  voucher_no text not null check (length(trim(voucher_no)) > 0),
  entry_date date not null,
  narration text,
  -- Σ debit of the journal entry (= Σ credit).
  total_paise bigint not null check (total_paise > 0),
  status text not null default 'posted' check (status in ('posted', 'reversed')),
  reversed_at timestamptz,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint vouchers_no_unique unique (tenant_id, voucher_no),
  constraint vouchers_id_tenant_unique unique (id, tenant_id),
  constraint vouchers_reversed_at check ((status = 'reversed') = (reversed_at is not null))
);

create index vouchers_tenant_date_idx on public.vouchers (tenant_id, entry_date);
create index vouchers_device_idx on public.vouchers (device_id) where device_id is not null;

create trigger vouchers_set_updated_at before update on public.vouchers
  for each row execute function private.set_updated_at();
create trigger vouchers_set_created_by before insert on public.vouchers
  for each row execute function private.set_created_by();
create trigger vouchers_keep_tenant_id before update on public.vouchers
  for each row execute function private.keep_tenant_id();

-- A voucher is created posted and frozen; the only change is posted →
-- reversed (entries.reverse).
create or replace function private.guard_voucher()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if new.status <> 'posted' then
      raise exception 'a voucher is created posted' using errcode = '23514';
    end if;
    if new.created_at > now() + interval '1 day' then
      raise exception 'created_at is in the future' using errcode = '23514';
    end if;
    if (select auth.uid()) is not null then
      if not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
        raise exception 'vouchers need entries.reverse' using errcode = '42501';
      end if;
      if not exists (
        select 1 from public.devices d
        where d.id = new.device_id and d.tenant_id = new.tenant_id
          and d.user_id = (select auth.uid()) and d.revoked_at is null
      ) then
        raise exception 'vouchers must come from one of your devices in this business'
          using errcode = '42501';
      end if;
    end if;
    return new;
  end if;

  if old.status = 'reversed' then
    raise exception 'a reversed voucher cannot change' using errcode = '42501';
  end if;
  if (to_jsonb(new) - 'status' - 'reversed_at' - 'updated_at')
    <> (to_jsonb(old) - 'status' - 'reversed_at' - 'updated_at') then
    raise exception 'a posted voucher cannot change; reverse it instead'
      using errcode = '42501';
  end if;
  if (select auth.uid()) is not null
    and not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
    raise exception 'reversing a voucher needs entries.reverse' using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_voucher() from public, anon, authenticated;

create trigger vouchers_guard before insert or update on public.vouchers
  for each row execute function private.guard_voucher();

alter table public.vouchers enable row level security;

-- Every member sees vouchers: their khata and cash lines already sync to
-- everyone. Bank lines stay finance-only (cash_bank_entries policy).
create policy vouchers_select on public.vouchers
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));
create policy vouchers_insert on public.vouchers
  for insert to authenticated
  with check (
    tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'entries.reverse'))
  );
create policy vouchers_update on public.vouchers
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));

revoke all on public.vouchers from anon;
revoke delete, truncate on public.vouchers from authenticated;

-- ---------------------------------------------------------------------------
-- Journal: voucher entries
-- ---------------------------------------------------------------------------

alter table public.journal_entries drop constraint journal_entries_source_type_check;
alter table public.journal_entries add constraint journal_entries_source_type_check
  check (source_type in ('lot', 'payment', 'interest', 'waiver', 'entry', 'reversal', 'voucher'));
alter table public.journal_entries add constraint journal_entries_voucher_link
  check ((source_type = 'voucher') = (voucher_id is not null));
alter table public.journal_entries add constraint journal_entries_voucher_fk
  foreign key (voucher_id, tenant_id) references public.vouchers (id, tenant_id);
create index journal_entries_voucher_idx on public.journal_entries (voucher_id, tenant_id)
  where voucher_id is not null;

-- ---------------------------------------------------------------------------
-- Khata: voucher lines on party accounts
-- ---------------------------------------------------------------------------

alter table public.ledger_entries drop constraint ledger_entries_ref_type_check;
alter table public.ledger_entries add constraint ledger_entries_ref_type_check
  check (ref_type in (
    'arrival', 'payment', 'receipt', 'shop_sale', 'shop_return', 'purchase',
    'loan_disbursal', 'loan_repayment', 'interest', 'expense', 'journal',
    'opening_balance', 'reversal', 'voucher'
  ));

create or replace function private.ledger_post_permission(
  p_ref_type text,
  p_replaces_id uuid
)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when p_replaces_id is not null
      or p_ref_type in ('reversal', 'journal', 'opening_balance', 'voucher')
      then 'entries.reverse'
    when p_ref_type = 'arrival' then 'arrivals.manage'
    when p_ref_type in ('payment', 'receipt', 'loan_repayment')
      then 'payments.create'
    when p_ref_type in ('loan_disbursal', 'interest') then 'loans.manage'
    else null
  end;
$$;

-- ---------------------------------------------------------------------------
-- Cash / bank book: lines of a payment OR a voucher
-- ---------------------------------------------------------------------------

alter table public.cash_bank_entries alter column payment_id drop not null;
alter table public.cash_bank_entries add column voucher_id uuid;
alter table public.cash_bank_entries add constraint cash_bank_entries_voucher_fk
  foreign key (voucher_id, tenant_id) references public.vouchers (id, tenant_id);
alter table public.cash_bank_entries add constraint cash_bank_entries_one_source
  check (num_nonnulls(payment_id, voucher_id) = 1);
create index cash_bank_entries_voucher_idx on public.cash_bank_entries (voucher_id, tenant_id)
  where voucher_id is not null;

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
      -- Reversals and voucher lines change the books: accountant / owner.
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

alter publication powersync add table public.vouchers;
