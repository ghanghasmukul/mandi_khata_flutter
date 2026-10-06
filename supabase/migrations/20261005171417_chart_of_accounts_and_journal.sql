-- Step 3.1: chart of accounts and double-entry journal.
-- Rules: docs/domain/posting-rules.md.
--
-- account_groups   Tally-like groups (Capital, Sundry Debtors, ...), seeded.
-- accounts         one per party, one per cash / bank account, and the system
--                  accounts (Commission Income, ...); the business may add its
--                  own. Ids are UUID v5 so the server seed, the triggers and
--                  every device agree without talking to each other:
--                    group    v5(ns, tenant|group|code)
--                    system   v5(ns, tenant|account|code)
--                    party    v5(ns, tenant|party|party_id)
--                    book     v5(ns, tenant|book|bank_account_id)
-- journal_entries  one per document (source_key 'lot:<id>', 'payment:<id>',
--                  'interest:<id>', 'waiver:<id>', 'entry:<ledger entry id>')
--                  plus a mirrored 'reversal:<key>' entry when it is reversed.
-- journal_lines    debit OR credit, in paise.
--
-- Journal entries and lines are append-only. Every entry must balance and
-- must have its lines in the SAME transaction (deferred constraint trigger);
-- a reversal must mirror the entry it reverses. The server does NOT check
-- that the journal matches the source document (posting-rules section 8).

create extension if not exists "uuid-ossp" with schema extensions;

-- ---------------------------------------------------------------------------
-- account_groups
-- ---------------------------------------------------------------------------

create table public.account_groups (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  code text not null check (code ~ '^[a-z][a-z0-9_]{0,39}$'),
  name text not null check (length(trim(name)) > 0),
  parent_id uuid,
  nature text not null check (nature in ('asset', 'liability', 'income', 'expense')),
  is_system boolean not null default false,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint account_groups_code_unique unique (tenant_id, code),
  constraint account_groups_id_tenant_unique unique (id, tenant_id),
  constraint account_groups_parent_fk foreign key (parent_id, tenant_id)
    references public.account_groups (id, tenant_id)
);

create index account_groups_parent_idx on public.account_groups (parent_id, tenant_id)
  where parent_id is not null;

-- ---------------------------------------------------------------------------
-- accounts
-- ---------------------------------------------------------------------------

create table public.accounts (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  group_id uuid not null,
  name text not null check (length(trim(name)) > 0),
  party_id uuid,
  bank_account_id uuid,
  -- Set for the accounts every business has (posting-rules section 2).
  system_code text check (system_code is null or system_code ~ '^[a-z][a-z0-9_]{0,39}$'),
  is_system boolean not null default false,
  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint accounts_id_tenant_unique unique (id, tenant_id),
  constraint accounts_one_owner check (
    (case when party_id is null then 0 else 1 end)
    + (case when bank_account_id is null then 0 else 1 end)
    + (case when system_code is null then 0 else 1 end) <= 1
  ),
  constraint accounts_group_fk foreign key (group_id, tenant_id)
    references public.account_groups (id, tenant_id),
  constraint accounts_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint accounts_bank_fk foreign key (bank_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id)
);

create unique index accounts_party_unique on public.accounts (tenant_id, party_id)
  where party_id is not null;
create unique index accounts_bank_unique on public.accounts (tenant_id, bank_account_id)
  where bank_account_id is not null;
create unique index accounts_system_unique on public.accounts (tenant_id, system_code)
  where system_code is not null;
create index accounts_group_idx on public.accounts (group_id, tenant_id);
create index accounts_party_fk_idx on public.accounts (party_id, tenant_id)
  where party_id is not null;
create index accounts_bank_fk_idx on public.accounts (bank_account_id, tenant_id)
  where bank_account_id is not null;

-- ---------------------------------------------------------------------------
-- journal_entries / journal_lines
-- ---------------------------------------------------------------------------

create table public.journal_entries (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- 'lot:<id>', 'payment:<id>', 'interest:<id>', 'waiver:<id>',
  -- 'entry:<ledger entry id>' or 'reversal:<key of the entry reversed>'.
  source_key text not null check (length(source_key) > 0),
  source_type text not null
    check (source_type in ('lot', 'payment', 'interest', 'waiver', 'entry', 'reversal')),
  -- Filled in step 3.2 (voucher entry).
  voucher_id uuid,
  entry_date date not null,
  narration text,
  reverses_id uuid,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint journal_entries_key_unique unique (tenant_id, source_key),
  constraint journal_entries_id_tenant_unique unique (id, tenant_id),
  constraint journal_entries_reversed_once unique (reverses_id),
  constraint journal_entries_key_type check (source_key like source_type || ':%'),
  constraint journal_entries_reversal_link
    check ((source_type = 'reversal') = (reverses_id is not null)),
  constraint journal_entries_reverses_fk foreign key (reverses_id, tenant_id)
    references public.journal_entries (id, tenant_id)
);

create index journal_entries_date_idx on public.journal_entries (tenant_id, entry_date);
create index journal_entries_device_idx on public.journal_entries (device_id)
  where device_id is not null;

create table public.journal_lines (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  journal_entry_id uuid not null,
  line_no integer not null check (line_no >= 0),
  account_id uuid not null,
  debit_paise bigint not null default 0 check (debit_paise >= 0),
  credit_paise bigint not null default 0 check (credit_paise >= 0),
  memo text,
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint journal_lines_one_side check ((debit_paise > 0) <> (credit_paise > 0)),
  constraint journal_lines_line_unique unique (journal_entry_id, line_no),
  constraint journal_lines_entry_fk foreign key (journal_entry_id, tenant_id)
    references public.journal_entries (id, tenant_id),
  constraint journal_lines_account_fk foreign key (account_id, tenant_id)
    references public.accounts (id, tenant_id)
);

create index journal_lines_account_idx on public.journal_lines (tenant_id, account_id);
create index journal_lines_entry_fk_idx on public.journal_lines (journal_entry_id, tenant_id);

-- ---------------------------------------------------------------------------
-- Common triggers
-- ---------------------------------------------------------------------------

create trigger account_groups_set_updated_at before update on public.account_groups
  for each row execute function private.set_updated_at();
create trigger account_groups_set_created_by before insert on public.account_groups
  for each row execute function private.set_created_by();
create trigger account_groups_keep_tenant_id before update on public.account_groups
  for each row execute function private.keep_tenant_id();

create trigger accounts_set_updated_at before update on public.accounts
  for each row execute function private.set_updated_at();
create trigger accounts_set_created_by before insert on public.accounts
  for each row execute function private.set_created_by();
create trigger accounts_keep_tenant_id before update on public.accounts
  for each row execute function private.keep_tenant_id();

create trigger journal_entries_set_created_by before insert on public.journal_entries
  for each row execute function private.set_created_by();
create trigger journal_lines_set_created_by before insert on public.journal_lines
  for each row execute function private.set_created_by();
create trigger journal_entries_append_only before update or delete on public.journal_entries
  for each row execute function private.reject_change();
create trigger journal_lines_append_only before update or delete on public.journal_lines
  for each row execute function private.reject_change();

-- System groups and accounts: only the seed (which runs as the function
-- owner) may create them; clients may rename an account or switch it off but
-- never change what it is. Groups of the chart cannot be touched by clients.
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

revoke execute on function private.guard_chart_row() from public, anon, authenticated;

create trigger account_groups_guard before insert or update on public.account_groups
  for each row execute function private.guard_chart_row();
create trigger accounts_guard before insert or update on public.accounts
  for each row execute function private.guard_chart_row();

-- ---------------------------------------------------------------------------
-- Who may post which journal entry: the permission of the document behind it
-- ---------------------------------------------------------------------------

create or replace function private.journal_post_permission(p_source_type text)
returns text
language sql
immutable
set search_path = ''
as $$
  select case p_source_type
    when 'lot' then 'arrivals.manage'
    when 'payment' then 'payments.create'
    when 'interest' then 'loans.manage'
    else 'entries.reverse'
  end;
$$;

revoke execute on function private.journal_post_permission(text) from public, anon;
grant execute on function private.journal_post_permission(text) to authenticated;

-- Whether the signed-in user may add lines to this entry. SECURITY DEFINER so
-- a member who cannot read journal entries (a munshi) can still post lines.
create or replace function private.journal_line_allowed(p_entry uuid, p_tenant uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.journal_entries e
    where e.id = p_entry and e.tenant_id = p_tenant
      and private.has_permission(
        p_tenant, private.journal_post_permission(e.source_type)
      )
  );
$$;

revoke execute on function private.journal_line_allowed(uuid, uuid) from public, anon;
grant execute on function private.journal_line_allowed(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- Guards on journal rows
-- ---------------------------------------------------------------------------

create or replace function private.guard_journal_entry()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.created_at > now() + interval '1 day' then
    raise exception 'created_at is in the future' using errcode = '23514';
  end if;
  if (select auth.uid()) is not null and not exists (
    select 1 from public.devices d
    where d.id = new.device_id and d.tenant_id = new.tenant_id
      and d.user_id = (select auth.uid()) and d.revoked_at is null
  ) then
    raise exception 'journal entries must come from one of your devices in this business'
      using errcode = '42501';
  end if;
  -- Remember (for this transaction only) that this entry is new, so its lines
  -- may be added now and never later. A transaction-local setting survives
  -- the sub-transactions apply_crud_transaction uses.
  perform set_config(
    'mk.journal_new',
    coalesce(current_setting('mk.journal_new', true), '') || new.id::text || ',',
    true);
  return new;
end;
$$;

revoke execute on function private.guard_journal_entry() from public, anon, authenticated;

create trigger journal_entries_guard before insert on public.journal_entries
  for each row execute function private.guard_journal_entry();

-- Lines may only join an entry written by the same transaction: an entry
-- cannot grow later.
create or replace function private.guard_journal_line()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if position(
    new.journal_entry_id::text in coalesce(current_setting('mk.journal_new', true), '')
  ) = 0 then
    raise exception 'lines can only be added in the transaction that wrote the entry'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_journal_line() from public, anon, authenticated;

create trigger journal_lines_guard before insert on public.journal_lines
  for each row execute function private.guard_journal_line();

-- At the end of the upload: an entry has at least two lines, balances, and a
-- reversal is the mirror of the entry it reverses.
create or replace function private.check_journal_entry()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  -- A line carries journal_entry_id; for an entry the key is absent.
  v_id uuid := coalesce((to_jsonb(new) ->> 'journal_entry_id')::uuid, new.id);
  v_tenant uuid := new.tenant_id;
  v_lines int;
  v_debit bigint;
  v_credit bigint;
  v_reverses uuid;
begin
  select count(*), coalesce(sum(debit_paise), 0), coalesce(sum(credit_paise), 0)
    into v_lines, v_debit, v_credit
  from public.journal_lines l
  where l.journal_entry_id = v_id and l.tenant_id = v_tenant;

  if v_lines < 2 then
    raise exception 'a journal entry needs at least two lines' using errcode = '23514';
  end if;
  if v_debit <> v_credit then
    raise exception 'journal entry does not balance: debit % credit %', v_debit, v_credit
      using errcode = '23514';
  end if;

  select e.reverses_id into v_reverses
  from public.journal_entries e where e.id = v_id and e.tenant_id = v_tenant;
  if v_reverses is not null and exists (
    select 1
    from (
      select account_id, sum(debit_paise) d, sum(credit_paise) c
      from public.journal_lines
      where journal_entry_id = v_id and tenant_id = v_tenant group by account_id
    ) r
    full join (
      select account_id, sum(debit_paise) d, sum(credit_paise) c
      from public.journal_lines
      where journal_entry_id = v_reverses and tenant_id = v_tenant group by account_id
    ) o on o.account_id = r.account_id
    where coalesce(r.d, 0) <> coalesce(o.c, 0) or coalesce(r.c, 0) <> coalesce(o.d, 0)
  ) then
    raise exception 'a reversal must mirror the entry it reverses' using errcode = '23514';
  end if;
  return null;
end;
$$;

revoke execute on function private.check_journal_entry() from public, anon, authenticated;

create constraint trigger journal_entries_balanced
  after insert on public.journal_entries
  deferrable initially deferred
  for each row execute function private.check_journal_entry();
create constraint trigger journal_lines_balanced
  after insert on public.journal_lines
  deferrable initially deferred
  for each row execute function private.check_journal_entry();

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table public.account_groups enable row level security;
alter table public.accounts enable row level security;
alter table public.journal_entries enable row level security;
alter table public.journal_lines enable row level security;

-- The books are for finance.view. A member can always read the journal rows
-- they wrote themselves: the upload inserts with ON CONFLICT DO NOTHING,
-- which needs a select policy to pass (same as audit_log_select_own).
create policy account_groups_select on public.account_groups
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'finance.view')));
create policy accounts_select on public.accounts
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(tenant_id, 'finance.view')));
create policy journal_entries_select on public.journal_entries
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids())
    and ((select private.has_permission(tenant_id, 'finance.view'))
      or created_by = (select auth.uid())));
create policy journal_lines_select on public.journal_lines
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids())
    and ((select private.has_permission(tenant_id, 'finance.view'))
      or created_by = (select auth.uid())));

-- Chart rows: the accountant / owner (entries.reverse) adds and renames.
create policy account_groups_insert on public.account_groups
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));
create policy account_groups_update on public.account_groups
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));
create policy accounts_insert on public.accounts
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));
create policy accounts_update on public.accounts
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'entries.reverse')))
  with check ((select private.has_permission(tenant_id, 'entries.reverse')));

create policy journal_entries_insert on public.journal_entries
  for insert to authenticated
  with check (
    tenant_id in (select private.auth_tenant_ids())
    and (select private.has_permission(
      tenant_id, private.journal_post_permission(source_type)))
  );
create policy journal_lines_insert on public.journal_lines
  for insert to authenticated
  with check (
    tenant_id in (select private.auth_tenant_ids())
    and (select private.journal_line_allowed(journal_entry_id, tenant_id))
  );

revoke all on public.account_groups, public.accounts,
  public.journal_entries, public.journal_lines from anon;
revoke delete, truncate on public.account_groups, public.accounts from authenticated;
revoke update, delete, truncate on public.journal_entries, public.journal_lines
  from authenticated;

-- ---------------------------------------------------------------------------
-- Seed: groups, system accounts, and an account for every party / cash / bank
-- ---------------------------------------------------------------------------

create or replace function private.chart_id(p_tenant uuid, p_kind text, p_key text)
returns uuid
language sql
immutable
set search_path = ''
as $$
  select extensions.uuid_generate_v5(
    '5c0f9d3a-8e21-4b6c-a7d4-1e9b3f2a6c80'::uuid,
    p_tenant::text || '|' || p_kind || '|' || p_key);
$$;

revoke execute on function private.chart_id(uuid, text, text) from public, anon, authenticated;

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
    ('indirect_expenses',   'Indirect Expenses',        null,                  'expense')
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
    ('opening_balance_equity', 'Opening Balance Equity', 'capital')
  ) as a(code, name, grp)
  on conflict (id) do nothing;
end;
$$;

-- The group a party's account belongs to: Sundry Debtors for a customer or
-- buyer (also when the party is more), else Sundry Creditors.
create or replace function private.party_account_group(p_tenant uuid, p_party uuid)
returns uuid
language sql
stable
set search_path = ''
as $$
  select private.chart_id(p_tenant, 'group',
    case when exists (
      select 1 from public.party_roles r
      where r.party_id = p_party and r.tenant_id = p_tenant
        and r.deleted_at is null and r.role in ('customer', 'buyer')
    ) then 'sundry_debtors' else 'sundry_creditors' end);
$$;

create or replace function private.ensure_party_account(p_tenant uuid, p_party uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform private.seed_chart_groups(p_tenant);
  insert into public.accounts (id, tenant_id, group_id, name, party_id)
  select private.chart_id(p_tenant, 'party', p_party::text), p_tenant,
         private.party_account_group(p_tenant, p_party), p.name, p.id
  from public.parties p where p.id = p_party and p.tenant_id = p_tenant
  on conflict (id) do nothing;
end;
$$;

create or replace function private.ensure_book_account(p_tenant uuid, p_bank uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform private.seed_chart_groups(p_tenant);
  insert into public.accounts (id, tenant_id, group_id, name, bank_account_id)
  select private.chart_id(p_tenant, 'book', b.id::text), p_tenant,
         private.chart_id(p_tenant, 'group',
           case b.kind when 'cash' then 'cash_in_hand' else 'bank_accounts' end),
         b.name, b.id
  from public.bank_accounts b where b.id = p_bank and b.tenant_id = p_tenant
  on conflict (id) do nothing;
end;
$$;

revoke execute on function
  private.seed_chart_groups(uuid), private.seed_chart_accounts(uuid),
  private.party_account_group(uuid, uuid), private.ensure_party_account(uuid, uuid),
  private.ensure_book_account(uuid, uuid)
  from public, anon, authenticated;

-- Triggers run as the function owner: the business may be brand new (its
-- creator is not a member yet) and clients cannot create system rows.
create or replace function private.chart_for_new_tenant()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  perform private.seed_chart_accounts(new.id);
  return new;
end;
$$;

create or replace function private.chart_for_new_party()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  perform private.ensure_party_account(new.tenant_id, new.id);
  return new;
end;
$$;

-- A party's roles arrive after the party row: keep the account in the right
-- group while it is still in one of the two party groups.
create or replace function private.chart_for_party_role()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  perform private.ensure_party_account(new.tenant_id, new.party_id);
  update public.accounts a
  set group_id = private.party_account_group(new.tenant_id, new.party_id)
  where a.id = private.chart_id(new.tenant_id, 'party', new.party_id::text)
    and a.group_id in (
      private.chart_id(new.tenant_id, 'group', 'sundry_debtors'),
      private.chart_id(new.tenant_id, 'group', 'sundry_creditors'))
    and a.group_id is distinct from
      private.party_account_group(new.tenant_id, new.party_id);
  return new;
end;
$$;

create or replace function private.chart_for_party_rename()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  update public.accounts a set name = new.name
  where a.id = private.chart_id(new.tenant_id, 'party', new.id::text)
    and a.name is distinct from new.name;
  return new;
end;
$$;

create or replace function private.chart_for_new_book()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  perform private.ensure_book_account(new.tenant_id, new.id);
  return new;
end;
$$;

revoke execute on function private.chart_for_new_tenant(), private.chart_for_new_party(),
  private.chart_for_party_role(), private.chart_for_party_rename(),
  private.chart_for_new_book() from public, anon, authenticated;

create trigger tenants_chart after insert on public.tenants
  for each row execute function private.chart_for_new_tenant();
create trigger parties_chart after insert on public.parties
  for each row execute function private.chart_for_new_party();
create trigger parties_chart_rename after update of name on public.parties
  for each row execute function private.chart_for_party_rename();
create trigger party_roles_chart after insert or update on public.party_roles
  for each row execute function private.chart_for_party_role();
create trigger bank_accounts_chart after insert on public.bank_accounts
  for each row execute function private.chart_for_new_book();

-- Existing businesses.
select private.seed_chart_accounts(id) from public.tenants;
select private.ensure_party_account(p.tenant_id, p.id) from public.parties p;
select private.ensure_book_account(b.tenant_id, b.id) from public.bank_accounts b;
update public.accounts a
set group_id = private.party_account_group(a.tenant_id, a.party_id)
where a.party_id is not null
  and a.group_id in (
    private.chart_id(a.tenant_id, 'group', 'sundry_debtors'),
    private.chart_id(a.tenant_id, 'group', 'sundry_creditors'));

alter publication powersync add table public.account_groups, public.accounts,
  public.journal_entries, public.journal_lines;
