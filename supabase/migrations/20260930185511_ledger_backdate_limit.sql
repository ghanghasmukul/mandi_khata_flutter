-- Step 1.4: back-dated khata entries need entries.reverse.
--
-- An entry dated more than `business.backdate_days` (default 3) days before
-- the day it was recorded on the device, or after it, needs entries.reverse
-- whatever its ref type. "Recorded" is created_at in India time, so an entry
-- made offline today and synced next week is not back-dated. Mirrors
-- khata_core `LedgerPosting.requiredPermissions`. See
-- docs/domain/ledger-and-mandi.md ("Who may post").

-- The business's back-date window in days. An invalid stored value falls
-- back to the system default, like the app's settings resolver.
create or replace function private.backdate_days(p_tenant_id uuid)
returns integer
language sql
stable
set search_path = ''
as $$
  select coalesce((
    select (s.value #>> '{}')::integer
    from public.settings s
    where s.tenant_id = p_tenant_id
      and s.scope = 'tenant'
      and s.key = 'business.backdate_days'
      and jsonb_typeof(s.value) = 'number'
      and (s.value #>> '{}') ~ '^[0-9]{1,4}$'
      and (s.value #>> '{}')::integer <= 3650
  ), 3);
$$;

-- True when an entry dated p_entry_date and recorded at p_created_at is
-- outside the window: older than backdate_days, or in the future.
create or replace function private.ledger_date_restricted(
  p_tenant_id uuid,
  p_entry_date date,
  p_created_at timestamptz
)
returns boolean
language sql
stable
set search_path = ''
as $$
  select p_entry_date > (p_created_at at time zone 'Asia/Kolkata')::date
    or p_entry_date < (p_created_at at time zone 'Asia/Kolkata')::date
      - private.backdate_days(p_tenant_id);
$$;

-- Same checks as before, plus: created_at may not be ahead of the server's
-- clock by more than a day (it decides the back-date window).
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

  if (select auth.uid()) is not null and not exists (
    select 1 from public.devices d
    where d.id = new.device_id
      and d.tenant_id = new.tenant_id
      and d.user_id = (select auth.uid())
  ) then
    raise exception 'ledger entries must come from one of your devices in this business'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

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
  );

revoke execute on function private.backdate_days(uuid) from public, anon;
revoke execute on function private.ledger_date_restricted(uuid, date, timestamptz)
  from public, anon;
grant execute on function private.backdate_days(uuid) to authenticated;
grant execute on function private.ledger_date_restricted(uuid, date, timestamptz)
  to authenticated;
