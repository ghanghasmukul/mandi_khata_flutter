-- Step 2.4: posting interest and waiving it.
--
-- interest_postings is the document behind a khata entry of ref_type
-- 'interest' (the interest charged up to a day, posted as udhaar) or behind a
-- waiver (a jama 'journal' entry that takes interest off). It records what
-- the entry cannot: the period, the rate and method, the loan it belongs to
-- (null = the party's whole khata), the reason of a waiver and the bulk run.
--
-- period_key makes posting idempotent: 'interest:khata:<party>:<to>' or
-- 'interest:loan:<loan>:<to>' is unique per business, so two devices (or a
-- re-run of the bulk posting) can post the same account up to the same day
-- only once. A waiver's key is 'waiver:<id>'.
--
-- The posting row is written BEFORE its khata entry in the same upload
-- (apply_crud_transaction); the entry's guard checks that it matches.
-- See docs/domain/interest-engine.md ("Posting interest to the khata").

create table public.interest_postings (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  party_id uuid not null,
  -- Null: the party's whole khata (apply_on = net_udhaar).
  loan_id uuid,
  kind text not null check (kind in ('interest', 'waiver')),
  -- Interest: the period posted, [period_from, period_to) (to exclusive).
  -- Waiver: both are the day of the waiver.
  period_from date not null,
  period_to date not null,
  amount_paise bigint not null check (amount_paise > 0),
  -- % p.a. as exact text and the method in force (interest only).
  rate_pa text
    check (rate_pa is null or rate_pa ~ '^(100(\.0{1,4})?|[0-9]{1,2}(\.[0-9]{1,4})?)$'),
  method text check (method is null or method in ('simple', 'compound')),
  -- Why interest was waived (required for a waiver).
  reason text,
  period_key text not null check (length(period_key) > 0),
  -- Groups the rows of one bulk posting run.
  batch_id uuid,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint interest_postings_key_unique unique (tenant_id, period_key),
  constraint interest_postings_id_tenant_unique unique (id, tenant_id),
  constraint interest_postings_party_fk foreign key (party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint interest_postings_loan_fk foreign key (loan_id, tenant_id)
    references public.loans (id, tenant_id),
  constraint interest_postings_period check (period_to >= period_from),
  constraint interest_postings_kind_fields check (
    case kind
      when 'interest' then rate_pa is not null and method is not null
        and period_to > period_from
      else length(trim(coalesce(reason, ''))) > 0 and period_to = period_from
    end
  )
);

create index interest_postings_party_idx
  on public.interest_postings (tenant_id, party_id, period_to);
create index interest_postings_loan_idx
  on public.interest_postings (loan_id, tenant_id) where loan_id is not null;
create index interest_postings_party_fk_idx
  on public.interest_postings (party_id, tenant_id);
create index interest_postings_device_idx
  on public.interest_postings (device_id) where device_id is not null;

create or replace function private.guard_interest_posting()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_loan public.loans;
  v_expected text;
begin
  if new.created_at > now() + interval '1 day' then
    raise exception 'created_at is in the future' using errcode = '23514';
  end if;

  if new.loan_id is not null then
    select * into v_loan from public.loans l
    where l.id = new.loan_id and l.tenant_id = new.tenant_id;
    if found and v_loan.party_id <> new.party_id then
      raise exception 'a loan posting must be on the borrower' using errcode = '23514';
    end if;
  end if;

  v_expected := case new.kind
    when 'interest' then 'interest:'
      || case when new.loan_id is null
           then 'khata:' || new.party_id::text
           else 'loan:' || new.loan_id::text end
      || ':' || new.period_to::text
    else 'waiver:' || new.id::text
  end;
  if new.period_key <> v_expected then
    raise exception 'period_key must be %', v_expected using errcode = '23514';
  end if;

  if (select auth.uid()) is not null then
    if not (select private.has_permission(new.tenant_id, 'loans.manage')) then
      raise exception 'posting interest needs loans.manage' using errcode = '42501';
    end if;
    -- A waiver is a journal entry: it needs entries.reverse as well.
    if new.kind = 'waiver'
      and not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
      raise exception 'waiving interest needs entries.reverse' using errcode = '42501';
    end if;
    if not exists (
      select 1 from public.devices d
      where d.id = new.device_id and d.tenant_id = new.tenant_id
        and d.user_id = (select auth.uid()) and d.revoked_at is null
    ) then
      raise exception 'postings must come from one of your devices in this business'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_interest_posting() from public, anon, authenticated;

create trigger interest_postings_guard before insert on public.interest_postings
  for each row execute function private.guard_interest_posting();
create trigger interest_postings_set_created_by before insert on public.interest_postings
  for each row execute function private.set_created_by();
-- Append-only for everyone, including the service role.
create trigger interest_postings_append_only before update or delete on public.interest_postings
  for each row execute function private.reject_change();

alter table public.interest_postings enable row level security;

create policy interest_postings_select on public.interest_postings
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy interest_postings_insert on public.interest_postings
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'loans.manage')));

revoke all on public.interest_postings from anon;
revoke update, delete, truncate on public.interest_postings from authenticated;

-- ---------------------------------------------------------------------------
-- The khata entries of a posting must match it
-- ---------------------------------------------------------------------------

-- Same body as before (create_loans) plus: an 'interest' entry is an udhaar
-- for an interest posting of that party and amount (ref_id = the posting),
-- and a journal entry that points at a waiver posting is a jama of that
-- party and amount. The posting row is written before the entry.
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
    elsif new.ref_type = 'interest' then
      if new.side <> 'udhaar' or not exists (
        select 1 from public.interest_postings ip
        where ip.id = new.ref_id and ip.tenant_id = new.tenant_id
          and ip.kind = 'interest' and ip.party_id = new.party_id
          and ip.amount_paise = new.amount_paise
      ) then
        raise exception 'an interest entry must match an interest posting'
          using errcode = '23514';
      end if;
    elsif new.ref_type = 'journal' and new.ref_id is not null then
      if exists (
        select 1 from public.interest_postings ip
        where ip.id = new.ref_id and ip.tenant_id = new.tenant_id
          and ip.kind = 'waiver'
          and (new.side <> 'jama' or ip.party_id <> new.party_id
            or ip.amount_paise <> new.amount_paise)
      ) then
        raise exception 'a waiver entry must match its waiver posting'
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

alter publication powersync add table public.interest_postings;
