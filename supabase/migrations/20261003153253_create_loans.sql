-- Step 2.2: loans (karza) and their effective-dated rate changes.
--
-- loans              one loan to a party: principal, due date, purpose,
--                    guarantor and the interest terms SNAPSHOTTED when it was
--                    issued (later changes to the business default never
--                    alter it). Issued, rate-changed, closed and written off
--                    by loans.manage (owner by default) only.
-- loan_rate_changes  append-only, effective-dated rate changes of a loan.
--
-- A loan is issued in ONE upload (apply_crud_transaction): the loan row, the
-- party's udhaar entry (ref_type loan_disbursal, ref_id = the loan) and the
-- payment out with its book line. A repayment is a payment from the party
-- linked to the loan (payments.loan_id) whose khata entry is a
-- loan_repayment (ref_id = the payment), or, adjusted from crop proceeds, a
-- loan_repayment jama (ref_id = the loan) with a balancing journal line.
-- See docs/domain/ledger-and-mandi.md ("Karza") and interest-engine.md.

-- ---------------------------------------------------------------------------
-- loans
-- ---------------------------------------------------------------------------

create table public.loans (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- KZ-W1-0001: per device, so offline devices never collide.
  loan_no text not null check (length(trim(loan_no)) > 0),
  party_id uuid not null,
  -- Business date in the tenant's local calendar; also the date of the
  -- disbursal entry.
  issue_date date not null,
  principal_paise bigint not null check (principal_paise > 0),
  purpose text,
  due_date date,
  guarantor_party_id uuid,
  -- khata_core InterestConfig.toJson() as resolved when the loan was issued.
  interest_config_snapshot jsonb not null
    check (jsonb_typeof(interest_config_snapshot) = 'object'),
  status text not null default 'active'
    check (status in ('active', 'closed', 'written_off')),
  closed_on date,
  -- Why it was closed or written off (required for a write-off).
  close_reason text,
  notes text,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint loans_loan_no_unique unique (tenant_id, loan_no),
  constraint loans_id_tenant_unique unique (id, tenant_id),
  constraint loans_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint loans_guarantor_fk foreign key (guarantor_party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint loans_guarantor_not_borrower
    check (guarantor_party_id is distinct from party_id),
  constraint loans_due_after_issue check (due_date is null or due_date >= issue_date),
  -- Closed exactly when it has a closing date, never before it was issued.
  constraint loans_closed_on check (
    (status = 'active') = (closed_on is null)
    and (closed_on is null or closed_on >= issue_date)
  ),
  constraint loans_written_off_reason check (
    status <> 'written_off' or length(trim(coalesce(close_reason, ''))) > 0
  )
);

-- Composite FKs need an index starting with the same columns (advisor 0001).
create index loans_party_idx on public.loans (party_id, tenant_id, issue_date);
create index loans_guarantor_idx on public.loans (guarantor_party_id, tenant_id)
  where guarantor_party_id is not null;
create index loans_tenant_status_idx on public.loans (tenant_id, status, due_date);
create index loans_device_idx on public.loans (device_id) where device_id is not null;

create trigger loans_set_updated_at before update on public.loans
  for each row execute function private.set_updated_at();
create trigger loans_set_created_by before insert on public.loans
  for each row execute function private.set_created_by();
create trigger loans_keep_tenant_id before update on public.loans
  for each row execute function private.keep_tenant_id();

-- What RLS cannot express. A loan is frozen once issued, except it can be
-- closed or written off (active -> closed | written_off, with closed_on and
-- a reason) and its notes edited while active. Closed / written-off loans
-- never change. Everything needs loans.manage.
create or replace function private.guard_loan()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_is_user boolean := (select auth.uid()) is not null;
begin
  if tg_op = 'INSERT' then
    if new.status <> 'active' then
      raise exception 'a loan is issued active' using errcode = '23514';
    end if;
    if new.created_at > now() + interval '1 day' then
      raise exception 'created_at is in the future' using errcode = '23514';
    end if;
    if v_is_user then
      if not (select private.has_permission(new.tenant_id, 'loans.manage')) then
        raise exception 'issuing a loan needs loans.manage' using errcode = '42501';
      end if;
      if not exists (
        select 1 from public.devices d
        where d.id = new.device_id and d.tenant_id = new.tenant_id
          and d.user_id = (select auth.uid()) and d.revoked_at is null
      ) then
        raise exception 'loans must come from one of your devices in this business'
          using errcode = '42501';
      end if;
    end if;
    return new;
  end if;

  -- UPDATE
  if old.status <> 'active' then
    raise exception 'a closed loan cannot change' using errcode = '42501';
  end if;
  if (to_jsonb(new) - 'status' - 'closed_on' - 'close_reason' - 'notes' - 'updated_at')
    <> (to_jsonb(old) - 'status' - 'closed_on' - 'close_reason' - 'notes' - 'updated_at') then
    raise exception 'an issued loan cannot change; change its rate or close it'
      using errcode = '42501';
  end if;
  if v_is_user and not (select private.has_permission(new.tenant_id, 'loans.manage')) then
    raise exception 'changing a loan needs loans.manage' using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_loan() from public, anon, authenticated;

create trigger loans_guard before insert or update on public.loans
  for each row execute function private.guard_loan();

alter table public.loans enable row level security;

create policy loans_select on public.loans
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy loans_insert on public.loans
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'loans.manage')));

create policy loans_update on public.loans
  for update to authenticated
  using ((select private.has_permission(tenant_id, 'loans.manage')))
  with check ((select private.has_permission(tenant_id, 'loans.manage')));

revoke all on public.loans from anon;
revoke delete, truncate on public.loans from authenticated;

-- ---------------------------------------------------------------------------
-- loan_rate_changes
-- ---------------------------------------------------------------------------

create table public.loan_rate_changes (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  loan_id uuid not null,
  -- The new rate applies from this day (the day itself counts).
  effective_date date not null,
  -- % per annum as exact text: 0 to 100, at most four decimals ("18", "1.5").
  rate_pa text not null
    check (rate_pa ~ '^(100(\.0{1,4})?|[0-9]{1,2}(\.[0-9]{1,4})?)$'),
  reason text,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint loan_rate_changes_loan_fk foreign key (loan_id, tenant_id)
    references public.loans (id, tenant_id)
);

create index loan_rate_changes_loan_idx
  on public.loan_rate_changes (loan_id, tenant_id, effective_date);
create index loan_rate_changes_device_idx
  on public.loan_rate_changes (device_id) where device_id is not null;

create or replace function private.guard_loan_rate_change()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_loan public.loans;
begin
  if new.created_at > now() + interval '1 day' then
    raise exception 'created_at is in the future' using errcode = '23514';
  end if;
  select * into v_loan from public.loans l
  where l.id = new.loan_id and l.tenant_id = new.tenant_id;
  if found then
    if v_loan.status <> 'active' then
      raise exception 'a closed loan has no rate changes' using errcode = '23514';
    end if;
    if new.effective_date < v_loan.issue_date then
      raise exception 'a rate cannot change before the loan was issued'
        using errcode = '23514';
    end if;
  end if;
  if (select auth.uid()) is not null then
    if not (select private.has_permission(new.tenant_id, 'loans.manage')) then
      raise exception 'changing a loan rate needs loans.manage' using errcode = '42501';
    end if;
    if not exists (
      select 1 from public.devices d
      where d.id = new.device_id and d.tenant_id = new.tenant_id
        and d.user_id = (select auth.uid()) and d.revoked_at is null
    ) then
      raise exception 'rate changes must come from one of your devices in this business'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_loan_rate_change() from public, anon, authenticated;

create trigger loan_rate_changes_guard before insert on public.loan_rate_changes
  for each row execute function private.guard_loan_rate_change();
create trigger loan_rate_changes_set_created_by before insert on public.loan_rate_changes
  for each row execute function private.set_created_by();
-- Append-only for everyone, including the service role.
create trigger loan_rate_changes_append_only before update or delete on public.loan_rate_changes
  for each row execute function private.reject_change();

alter table public.loan_rate_changes enable row level security;

create policy loan_rate_changes_select on public.loan_rate_changes
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy loan_rate_changes_insert on public.loan_rate_changes
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'loans.manage')));

revoke all on public.loan_rate_changes from anon;
revoke update, delete, truncate on public.loan_rate_changes from authenticated;

-- ---------------------------------------------------------------------------
-- payments.loan_id: a payment out that disburses a loan, or money in that
-- repays one.
-- ---------------------------------------------------------------------------

alter table public.payments add column loan_id uuid;
alter table public.payments
  add constraint payments_loan_fk foreign key (loan_id, tenant_id)
    references public.loans (id, tenant_id);
create index payments_loan_idx on public.payments (loan_id, tenant_id)
  where loan_id is not null;

-- A loan payment goes to / comes from the loan's own party, on an active
-- loan. Disbursing needs loans.manage; a repayment needs only
-- payments.create (checked by guard_payment).
create or replace function private.guard_payment_loan()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_loan public.loans;
begin
  if new.loan_id is null then
    return new;
  end if;
  select * into v_loan from public.loans l
  where l.id = new.loan_id and l.tenant_id = new.tenant_id;
  if found then
    if v_loan.party_id <> new.party_id then
      raise exception 'a loan payment must be with the borrower' using errcode = '23514';
    end if;
    if v_loan.status <> 'active' then
      raise exception 'a closed loan takes no payments' using errcode = '23514';
    end if;
    if new.direction = 'to_party' and new.amount_paise <> v_loan.principal_paise then
      raise exception 'the disbursal must be the loan principal' using errcode = '23514';
    end if;
  end if;
  if new.direction = 'to_party' and (select auth.uid()) is not null
    and not (select private.has_permission(new.tenant_id, 'loans.manage')) then
    raise exception 'disbursing a loan needs loans.manage' using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_payment_loan() from public, anon, authenticated;

create trigger payments_guard_loan before insert on public.payments
  for each row execute function private.guard_payment_loan();

-- ---------------------------------------------------------------------------
-- The khata entries of a loan must point at a real loan
-- ---------------------------------------------------------------------------

-- Same body as before (users_invites_devices_revoke) plus: a loan_disbursal
-- entry is the principal of a loan of that party (ref_id = the loan); a
-- loan_repayment entry is for an ACTIVE loan of that party, ref_id being the
-- loan (adjusted from crop proceeds) or a payment linked to it. The loan /
-- payment row is written before the entry in the same upload.
create or replace function private.guard_ledger_entry()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_original public.ledger_entries;
begin
  new.received_at := now();

  if new.created_at > now() + interval '1 day' then
    raise exception 'created_at is in the future'
      using errcode = '23514';
  end if;

  if new.reverses_id is not null then
    select * into v_original from public.ledger_entries e
    where e.id = new.reverses_id and e.tenant_id = new.tenant_id;
    if found and (
      v_original.ref_type = 'reversal'
      or v_original.party_id <> new.party_id
      or v_original.side = new.side
      or v_original.amount_paise <> new.amount_paise
    ) then
      raise exception 'a reversal must mirror the entry it reverses'
        using errcode = '23514';
    end if;
  end if;

  if new.reverses_id is null and new.replaces_id is null then
    if new.ref_type = 'loan_disbursal' then
      if new.side <> 'udhaar' or not exists (
        select 1 from public.loans l
        where l.id = new.ref_id and l.tenant_id = new.tenant_id
          and l.party_id = new.party_id and l.principal_paise = new.amount_paise
      ) then
        raise exception 'a loan disbursal must match the loan it disburses'
          using errcode = '23514';
      end if;
    elsif new.ref_type = 'loan_repayment' then
      if new.side <> 'jama' or not exists (
        select 1 from public.loans l
        where l.tenant_id = new.tenant_id and l.party_id = new.party_id
          and l.status = 'active'
          and (
            l.id = new.ref_id
            or exists (
              select 1 from public.payments p
              where p.id = new.ref_id and p.tenant_id = new.tenant_id
                and p.loan_id = l.id and p.direction = 'from_party'
            )
          )
      ) then
        raise exception 'a loan repayment must be for an active loan of this party'
          using errcode = '23514';
      end if;
    end if;
  end if;

  if (select auth.uid()) is not null and not exists (
    select 1 from public.devices d
    where d.id = new.device_id
      and d.tenant_id = new.tenant_id
      and d.user_id = (select auth.uid())
      and d.revoked_at is null
  ) then
    raise exception 'ledger entries must come from one of your devices in this business'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

alter publication powersync add table public.loans;
alter publication powersync add table public.loan_rate_changes;
