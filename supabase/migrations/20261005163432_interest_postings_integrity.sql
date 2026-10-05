-- Phase 2 review, findings 3 and 6: server-side integrity of interest postings.
--
-- 3. Two offline devices could post the same account up to different days
--    (different period_key, so both syncs succeeded) and charge a period twice.
--    A new interest posting may not overlap a live posting of the same account.
-- 6. The ledger guard now also checks that an interest entry is dated the last
--    day interest ran (period_to - 1) and a waiver entry the waiver day; an
--    interest posting has ONE entry (unique index) and so has a waiver
--    (guard); every posting must have its khata entry by commit (deferred
--    constraint trigger); waivers of an account cannot exceed the interest
--    posted on it.
--
-- "Live" = the khata entry of the posting has not been reversed.

create function private.interest_posting_live(p_id uuid, p_tenant uuid)
returns boolean
language sql
stable
set search_path = ''
as $$
  select not exists (
    select 1
    from public.ledger_entries e
    join public.ledger_entries r
      on r.reverses_id = e.id and r.tenant_id = e.tenant_id
    where e.tenant_id = p_tenant and e.ref_id = p_id
      and e.ref_type in ('interest', 'journal')
  );
$$;

-- Called by the guard trigger as the signed-in user; reads through RLS.
revoke execute on function private.interest_posting_live(uuid, uuid)
  from public, anon;
grant execute on function private.interest_posting_live(uuid, uuid) to authenticated;

create or replace function private.guard_interest_posting()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_loan public.loans;
  v_expected text;
  v_posted bigint;
  v_waived bigint;
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

  if new.kind = 'interest' then
    -- No overlap with a live posting of the same account (khata or loan).
    if exists (
      select 1 from public.interest_postings ip
      where ip.tenant_id = new.tenant_id and ip.kind = 'interest'
        and ip.party_id = new.party_id
        and ip.loan_id is not distinct from new.loan_id
        and ip.id <> new.id
        and ip.period_from < new.period_to and ip.period_to > new.period_from
        and (select private.interest_posting_live(ip.id, ip.tenant_id))
    ) then
      raise exception 'this period is already posted on this account'
        using errcode = '23P01';
    end if;
  else
    -- Waivers of an account cannot exceed the interest posted on it.
    select coalesce(sum(ip.amount_paise) filter (where ip.kind = 'interest'), 0),
           coalesce(sum(ip.amount_paise) filter (where ip.kind = 'waiver'), 0)
      into v_posted, v_waived
    from public.interest_postings ip
    where ip.tenant_id = new.tenant_id and ip.party_id = new.party_id
      and ip.loan_id is not distinct from new.loan_id
      and ip.id <> new.id
      and (select private.interest_posting_live(ip.id, ip.tenant_id));
    if v_waived + new.amount_paise > v_posted then
      raise exception 'waivers cannot exceed the interest posted on the account'
        using errcode = '23514';
    end if;
  end if;
  return new;
end;
$$;

-- One non-reversal interest entry per posting.
create unique index ledger_entries_interest_ref_unique
  on public.ledger_entries (tenant_id, ref_id)
  where ref_type = 'interest' and reverses_id is null and replaces_id is null;

-- A posting must have its khata entry by the end of the upload.
create function private.check_posting_has_entry()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.ledger_entries e
    where e.tenant_id = new.tenant_id and e.ref_id = new.id
      and e.ref_type = case new.kind when 'interest' then 'interest' else 'journal' end
      and e.reverses_id is null
  ) then
    raise exception 'a posting needs its khata entry' using errcode = '23514';
  end if;
  return null;
end;
$$;

revoke execute on function private.check_posting_has_entry()
  from public, anon, authenticated;

create constraint trigger interest_postings_has_entry
  after insert on public.interest_postings
  deferrable initially deferred
  for each row execute function private.check_posting_has_entry();

-- Same body as create_interest_postings plus the date and one-entry checks.
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
          -- Dated the last day interest ran (period_to is exclusive).
          and new.entry_date = ip.period_to - 1
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
            or ip.amount_paise <> new.amount_paise
            or new.entry_date <> ip.period_to)
      ) then
        raise exception 'a waiver entry must match its waiver posting'
          using errcode = '23514';
      end if;
      -- One entry per waiver posting.
      if exists (
        select 1 from public.interest_postings ip
        where ip.id = new.ref_id and ip.tenant_id = new.tenant_id
          and ip.kind = 'waiver'
      ) and exists (
        select 1 from public.ledger_entries e
        where e.tenant_id = new.tenant_id and e.ref_id = new.ref_id
          and e.ref_type = 'journal' and e.reverses_id is null
          and e.id <> new.id
      ) then
        raise exception 'a waiver posting has one entry only'
          using errcode = '23505';
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

