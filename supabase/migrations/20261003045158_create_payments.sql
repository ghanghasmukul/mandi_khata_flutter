-- Step 1.5: payments & receipts.
--
-- bank_accounts   the business's own accounts: one 'Cash' account per
--                 business (seeded) plus bank accounts. Bank details need
--                 finance.view.
-- payments        money paid to a party (bhugtaan) or received from one
--                 (receipt), by cash, bank, UPI or cheque.
-- cash_bank_entries  the simple cash / bank book: one line per payment and
--                 one mirrored line when it is reversed. Append-only. Full
--                 accounting comes in phase 3.
--
-- A payment posts in ONE upload (apply_crud_transaction): the payment row,
-- the party's ledger entry (ref_type payment | receipt) and the book line.
-- A bounced cheque, or a payment reversed by mistake, reverses the khata
-- entry and the book line together and marks the payment reversed.
-- See docs/domain/ledger-and-mandi.md ("Payments").

-- ---------------------------------------------------------------------------
-- bank_accounts
-- ---------------------------------------------------------------------------

create table public.bank_accounts (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  kind text not null check (kind in ('cash', 'bank')),
  name text not null check (length(trim(name)) > 0),
  bank_name text,
  -- Only the last 4 digits of the account number are ever stored.
  account_last4 text check (account_last4 is null or account_last4 ~ '^[0-9]{4}$'),
  ifsc text check (ifsc is null or ifsc ~ '^[A-Z]{4}0[A-Z0-9]{6}$'),
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint bank_accounts_id_tenant_unique unique (id, tenant_id)
);

-- One cash account per business.
create unique index bank_accounts_one_cash_idx
  on public.bank_accounts (tenant_id) where kind = 'cash';
create index bank_accounts_tenant_idx on public.bank_accounts (tenant_id, sort_order);

create trigger bank_accounts_set_updated_at before update on public.bank_accounts
  for each row execute function private.set_updated_at();
create trigger bank_accounts_set_created_by before insert on public.bank_accounts
  for each row execute function private.set_created_by();
create trigger bank_accounts_keep_tenant_id before update on public.bank_accounts
  for each row execute function private.keep_tenant_id();

-- The Cash account never changes kind and is never switched off.
create or replace function private.guard_bank_account()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.kind is distinct from old.kind then
    raise exception 'an account kind cannot change' using errcode = '42501';
  end if;
  if old.kind = 'cash' and not new.is_active then
    raise exception 'the Cash account cannot be switched off'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_bank_account() from public, anon, authenticated;

create trigger bank_accounts_guard before update on public.bank_accounts
  for each row execute function private.guard_bank_account();

-- Ids are UUID v5 of "<tenant>|account|cash" in the namespace the app uses
-- (BankAccountsRepository.cashIdFor), so the server seed and every device
-- agree on the Cash account's id. A crop code cannot contain '|', so this
-- never collides with a crop id.
create or replace function private.seed_cash_account(p_tenant_id uuid)
returns void
language sql
set search_path = ''
as $$
  insert into public.bank_accounts (id, tenant_id, kind, name, sort_order)
  values (
    extensions.uuid_generate_v5(
      '3d8f2a6e-4c1b-4f0a-9b7e-5a2c8d1e6f30'::uuid,
      p_tenant_id::text || '|account|cash'),
    p_tenant_id, 'cash', 'Cash', 0)
  on conflict (id) do nothing;
$$;

revoke execute on function private.seed_cash_account(uuid) from public, anon, authenticated;

-- Runs as the function owner: the business is new, so its creator is not a
-- member yet and could not insert through RLS.
create or replace function private.seed_cash_for_new_tenant()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.seed_cash_account(new.id);
  return new;
end;
$$;

revoke execute on function private.seed_cash_for_new_tenant() from public, anon, authenticated;

create trigger tenants_seed_cash after insert on public.tenants
  for each row execute function private.seed_cash_for_new_tenant();

select private.seed_cash_account(id) from public.tenants;

alter table public.bank_accounts enable row level security;

-- Everyone reads Cash; bank accounts are finance details.
create policy bank_accounts_select on public.bank_accounts
  for select to authenticated
  using (
    tenant_id in (select private.auth_tenant_ids())
    and (
      kind = 'cash'
      or (select private.has_permission(tenant_id, 'finance.view'))
    )
  );

create policy bank_accounts_insert on public.bank_accounts
  for insert to authenticated
  with check (
    kind = 'bank'
    and (select private.has_permission(tenant_id, 'finance.view'))
  );

create policy bank_accounts_update on public.bank_accounts
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'finance.view')))
  with check ((select private.has_permission(tenant_id, 'finance.view')));

revoke all on public.bank_accounts from anon;
revoke delete, truncate on public.bank_accounts from authenticated;

-- The kind of an account, whoever asks. The guards below must see accounts a
-- munshi cannot read (bank accounts), or a cash payment could point at one.
create or replace function private.account_kind(p_tenant_id uuid, p_account_id uuid)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select a.kind from public.bank_accounts a
  where a.id = p_account_id and a.tenant_id = p_tenant_id;
$$;

revoke execute on function private.account_kind(uuid, uuid) from public, anon;
grant execute on function private.account_kind(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- The munshi payment limit
-- ---------------------------------------------------------------------------

-- The business's limit on one payment to a party, in paise; 0 = none. An
-- invalid stored value falls back to the system default (no limit).
create or replace function private.payment_limit(p_tenant_id uuid)
returns bigint
language sql
stable
set search_path = ''
as $$
  select coalesce((
    select (s.value #>> '{}')::bigint
    from public.settings s
    where s.tenant_id = p_tenant_id
      and s.scope = 'tenant'
      and s.key = 'business.munshi_payment_limit'
      and jsonb_typeof(s.value) = 'number'
      and (s.value #>> '{}') ~ '^[0-9]{1,12}$'
      and (s.value #>> '{}')::bigint <= 100000000000
  ), 0);
$$;

-- True when a payment TO a party of p_amount is above the limit. Receipts
-- are never limited.
create or replace function private.payment_over_limit(
  p_tenant_id uuid,
  p_is_payment_to_party boolean,
  p_amount bigint
)
returns boolean
language sql
stable
set search_path = ''
as $$
  select p_is_payment_to_party
    and private.payment_limit(p_tenant_id) > 0
    and p_amount > private.payment_limit(p_tenant_id);
$$;

revoke execute on function private.payment_limit(uuid) from public, anon;
revoke execute on function private.payment_over_limit(uuid, boolean, bigint)
  from public, anon;
grant execute on function private.payment_limit(uuid) to authenticated;
grant execute on function private.payment_over_limit(uuid, boolean, bigint)
  to authenticated;

-- The khata entry of a payment to a party obeys the limit too, so a client
-- cannot post the entry without the payment row.
drop policy ledger_entries_insert on public.ledger_entries;

create policy ledger_entries_insert on public.ledger_entries
  for insert to authenticated
  with check (
    tenant_id in (select private.auth_tenant_ids())
    and (
      private.ledger_post_permission(ref_type, replaces_id) is null
      or (select private.has_permission(
        tenant_id, private.ledger_post_permission(ref_type, replaces_id)
      ))
    )
    and (
      not private.ledger_date_restricted(tenant_id, entry_date, created_at)
      or (select private.has_permission(tenant_id, 'entries.reverse'))
    )
    and (
      not private.payment_over_limit(
        tenant_id, ref_type = 'payment' and replaces_id is null, amount_paise)
      or (select private.has_permission(tenant_id, 'entries.reverse'))
    )
  );

-- ---------------------------------------------------------------------------
-- payments
-- ---------------------------------------------------------------------------

create table public.payments (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- V-W1-0001 (paid to a party) / R-W1-0001 (received): per device, so
  -- offline devices never collide.
  receipt_no text not null check (length(trim(receipt_no)) > 0),
  -- Business date in the tenant's local calendar; also the date of the
  -- khata entry and the book line.
  entry_date date not null,
  party_id uuid not null,
  direction text not null check (direction in ('to_party', 'from_party')),
  mode text not null check (mode in ('cash', 'bank', 'upi', 'cheque')),
  amount_paise bigint not null check (amount_paise > 0),
  -- The Cash account for cash, a bank account for everything else.
  bank_account_id uuid not null,
  -- UTR / UPI transaction id.
  reference text,
  cheque_no text,
  cheque_date date,
  cheque_status text check (cheque_status in ('pending', 'cleared', 'bounced')),
  narration text,
  status text not null default 'posted' check (status in ('posted', 'reversed')),
  reversed_at timestamptz,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint payments_receipt_no_unique unique (tenant_id, receipt_no),
  constraint payments_id_tenant_unique unique (id, tenant_id),
  constraint payments_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint payments_account_fk foreign key (bank_account_id, tenant_id)
    references public.bank_accounts (id, tenant_id),
  -- Cheque details exactly when the mode is cheque.
  constraint payments_cheque_fields check (
    (mode = 'cheque') = (cheque_status is not null)
    and (mode = 'cheque') = (cheque_no is not null and length(trim(cheque_no)) > 0)
    and (mode = 'cheque') = (cheque_date is not null)
  ),
  -- A bounced cheque is a reversed payment.
  constraint payments_bounced_reversed check (
    cheque_status is distinct from 'bounced' or status = 'reversed'
  ),
  constraint payments_reversed_at check ((status = 'reversed') = (reversed_at is not null))
);

create index payments_party_idx on public.payments (party_id, tenant_id, entry_date);
create index payments_account_idx on public.payments (bank_account_id, tenant_id);
create index payments_tenant_date_idx on public.payments (tenant_id, entry_date);
create index payments_cheque_idx on public.payments (tenant_id, cheque_date)
  where cheque_status = 'pending';
create index payments_device_idx on public.payments (device_id) where device_id is not null;

create trigger payments_set_updated_at before update on public.payments
  for each row execute function private.set_updated_at();
create trigger payments_set_created_by before insert on public.payments
  for each row execute function private.set_created_by();
create trigger payments_keep_tenant_id before update on public.payments
  for each row execute function private.keep_tenant_id();

-- What RLS cannot express. A payment is frozen once posted, except:
--   cheque_status  pending → cleared (payments.create)
--                  pending → bounced  (entries.reverse, with status reversed)
--   status         posted → reversed  (entries.reverse)
-- A reversed payment never changes. The account must be the Cash account
-- exactly when the mode is cash.
create or replace function private.guard_payment()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_is_user boolean := (select auth.uid()) is not null;
  v_kind text;
begin
  if tg_op = 'INSERT' then
    if new.status <> 'posted' then
      raise exception 'a payment is created posted' using errcode = '23514';
    end if;
    if new.cheque_status is not null and new.cheque_status <> 'pending' then
      raise exception 'a new cheque is pending' using errcode = '23514';
    end if;
    if new.created_at > now() + interval '1 day' then
      raise exception 'created_at is in the future' using errcode = '23514';
    end if;

    v_kind := private.account_kind(new.tenant_id, new.bank_account_id);
    if v_kind is not null and (v_kind = 'cash') <> (new.mode = 'cash') then
      raise exception 'cash goes through the Cash account, everything else through a bank account'
        using errcode = '23514';
    end if;

    if v_is_user then
      if not (select private.has_permission(new.tenant_id, 'payments.create')) then
        raise exception 'payments need payments.create' using errcode = '42501';
      end if;
      if new.mode <> 'cash'
        and not (select private.has_permission(new.tenant_id, 'finance.view')) then
        raise exception 'bank, UPI and cheque payments need finance.view'
          using errcode = '42501';
      end if;
      if not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
        if private.payment_over_limit(
          new.tenant_id, new.direction = 'to_party', new.amount_paise) then
          raise exception 'this payment is above the payment limit; it needs entries.reverse'
            using errcode = '42501';
        end if;
        if private.ledger_date_restricted(new.tenant_id, new.entry_date, new.created_at) then
          raise exception 'a back-dated payment needs entries.reverse'
            using errcode = '42501';
        end if;
      end if;
      if not exists (
        select 1 from public.devices d
        where d.id = new.device_id and d.tenant_id = new.tenant_id
          and d.user_id = (select auth.uid())
      ) then
        raise exception 'payments must come from one of your devices in this business'
          using errcode = '42501';
      end if;
    end if;
    return new;
  end if;

  -- UPDATE
  if old.status = 'reversed' then
    raise exception 'a reversed payment cannot change' using errcode = '42501';
  end if;
  if (to_jsonb(new) - 'status' - 'cheque_status' - 'reversed_at' - 'updated_at')
    <> (to_jsonb(old) - 'status' - 'cheque_status' - 'reversed_at' - 'updated_at') then
    raise exception 'a posted payment cannot change; reverse it instead'
      using errcode = '42501';
  end if;
  if new.cheque_status is distinct from old.cheque_status then
    if old.cheque_status is distinct from 'pending'
      or new.cheque_status not in ('cleared', 'bounced') then
      raise exception 'a pending cheque clears or bounces; nothing else changes'
        using errcode = '23514';
    end if;
  end if;
  if v_is_user then
    if new.status = 'reversed'
      and not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
      raise exception 'reversing a payment needs entries.reverse'
        using errcode = '42501';
    end if;
    if new.cheque_status = 'cleared' and old.cheque_status is distinct from 'cleared'
      and not (select private.has_permission(new.tenant_id, 'payments.create')) then
      raise exception 'clearing a cheque needs payments.create'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_payment() from public, anon, authenticated;

create trigger payments_guard before insert or update on public.payments
  for each row execute function private.guard_payment();

alter table public.payments enable row level security;

create policy payments_select on public.payments
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy payments_insert on public.payments
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'payments.create')));

-- Which change needs which permission is checked by private.guard_payment().
create policy payments_update on public.payments
  for update to authenticated
  using (
    (select private.has_permission(tenant_id, 'payments.create'))
    or (select private.has_permission(tenant_id, 'entries.reverse'))
  )
  with check (
    (select private.has_permission(tenant_id, 'payments.create'))
    or (select private.has_permission(tenant_id, 'entries.reverse'))
  );

revoke all on public.payments from anon;
revoke delete, truncate on public.payments from authenticated;

-- ---------------------------------------------------------------------------
-- cash_bank_entries: the simple cash / bank book
-- ---------------------------------------------------------------------------

create table public.cash_bank_entries (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  account_id uuid not null,
  -- Copied from the account so a device without bank details (a munshi)
  -- can still be sent only the cash lines.
  account_kind text not null check (account_kind in ('cash', 'bank')),
  entry_date date not null,
  direction text not null check (direction in ('in', 'out')),
  amount_paise bigint not null check (amount_paise > 0),
  -- The payment this line belongs to.
  payment_id uuid not null,
  narration text,
  reverses_id uuid,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint cash_bank_entries_id_tenant_unique unique (id, tenant_id),
  constraint cash_bank_entries_account_fk foreign key (account_id, tenant_id)
    references public.bank_accounts (id, tenant_id),
  constraint cash_bank_entries_payment_fk foreign key (payment_id, tenant_id)
    references public.payments (id, tenant_id),
  constraint cash_bank_entries_reverses_fk foreign key (reverses_id, tenant_id)
    references public.cash_bank_entries (id, tenant_id),
  -- A line is reversed at most once, even by two devices offline.
  constraint cash_bank_entries_reversed_once unique (reverses_id)
);

create index cash_bank_entries_account_idx
  on public.cash_bank_entries (account_id, tenant_id, entry_date);
create index cash_bank_entries_payment_idx
  on public.cash_bank_entries (payment_id, tenant_id);
create index cash_bank_entries_tenant_date_idx
  on public.cash_bank_entries (tenant_id, entry_date);
create index cash_bank_entries_device_idx
  on public.cash_bank_entries (device_id) where device_id is not null;

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
      or v_original.payment_id <> new.payment_id
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
        and d.user_id = (select auth.uid())
    ) then
      raise exception 'book lines must come from one of your devices in this business'
        using errcode = '42501';
    end if;
    if new.account_kind = 'bank'
      and not (select private.has_permission(new.tenant_id, 'finance.view')) then
      raise exception 'bank book lines need finance.view' using errcode = '42501';
    end if;
    if new.reverses_id is null then
      if not (select private.has_permission(new.tenant_id, 'payments.create')) then
        raise exception 'book lines need payments.create' using errcode = '42501';
      end if;
    elsif not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
      raise exception 'reversing a book line needs entries.reverse'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_cash_bank_entry() from public, anon, authenticated;

create trigger cash_bank_entries_guard before insert on public.cash_bank_entries
  for each row execute function private.guard_cash_bank_entry();
create trigger cash_bank_entries_set_created_by before insert on public.cash_bank_entries
  for each row execute function private.set_created_by();
-- Append-only for everyone, including the service role.
create trigger cash_bank_entries_append_only before update or delete on public.cash_bank_entries
  for each row execute function private.reject_change();

alter table public.cash_bank_entries enable row level security;

create policy cash_bank_entries_select on public.cash_bank_entries
  for select to authenticated
  using (
    tenant_id in (select private.auth_tenant_ids())
    and (
      account_kind = 'cash'
      or (select private.has_permission(tenant_id, 'finance.view'))
    )
  );

-- Permissions are checked by private.guard_cash_bank_entry().
create policy cash_bank_entries_insert on public.cash_bank_entries
  for insert to authenticated
  with check (tenant_id in (select private.auth_tenant_ids()));

revoke all on public.cash_bank_entries from anon;
revoke update, delete, truncate on public.cash_bank_entries from authenticated;

alter publication powersync add table public.bank_accounts;
alter publication powersync add table public.payments;
alter publication powersync add table public.cash_bank_entries;
