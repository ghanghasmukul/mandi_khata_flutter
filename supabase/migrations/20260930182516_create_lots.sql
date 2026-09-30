-- Step 1.3: lots — one farmer's crop brought to the mandi (aamad), weighed,
-- sold and posted to the khata. See docs/domain/ledger-and-mandi.md.
--
-- An open lot (arrived / weighed / sold) can be edited freely. Posting
-- writes the lot, the farmer's jama and the buyer's udhaar in one upload
-- (apply_crud_transaction); from then on the lot is frozen and can only be
-- reversed (entries.reverse), which also reverses its ledger entries. An
-- open lot that never happened is cancelled: status 'reversed' with nothing
-- posted (posted_at null). Lots are never deleted.
--
-- Money columns are paise; weight is thousandths of a quintal.

create table public.lots (
  id uuid primary key,
  tenant_id uuid not null references public.tenants (id),
  -- L-W1-0001: per device, so offline devices never collide.
  lot_no text not null check (length(trim(lot_no)) > 0),
  -- Business date in the tenant's local calendar; also the date of the
  -- lot's ledger entries.
  entry_date date not null,
  farmer_id uuid not null,
  crop_id uuid not null,
  bags integer not null default 0 check (bags >= 0),
  qtl_milli bigint check (qtl_milli > 0),
  -- The weight was worked out as bags × mandi.bag_weight_kg.
  qtl_from_bags boolean not null default false,
  rate_paise_per_qtl bigint check (rate_paise_per_qtl > 0),
  buyer_party_id uuid,
  j_form_no text,
  vehicle_no text,
  notes text,
  status text not null default 'arrived'
    check (status in ('arrived', 'weighed', 'sold', 'posted', 'reversed')),
  -- khata_core MandiConfig.toJson() as resolved when posted.
  charges_snapshot jsonb,
  gross bigint check (gross >= 0),
  -- Commission the arhtiya earns (zero when waived).
  commission bigint check (commission >= 0),
  net_to_farmer bigint,
  -- What the buyer is billed: gross + buyer-borne charges.
  buyer_total bigint check (buyer_total >= 0),
  -- When it was posted on the device.
  posted_at timestamptz,
  device_id uuid references public.devices (id),
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint lots_lot_no_unique unique (tenant_id, lot_no),
  constraint lots_farmer_fk foreign key (farmer_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint lots_buyer_fk foreign key (buyer_party_id, tenant_id)
    references public.parties (id, tenant_id),
  constraint lots_crop_fk foreign key (crop_id, tenant_id)
    references public.crops (id, tenant_id),
  constraint lots_buyer_not_farmer check (buyer_party_id <> farmer_id),
  -- A posted lot has its weight, rate, snapshot and amounts.
  constraint lots_posted_complete check (
    posted_at is null or (
      qtl_milli is not null and rate_paise_per_qtl is not null
      and charges_snapshot is not null and gross is not null
      and commission is not null and net_to_farmer > 0
      and buyer_total is not null
    )
  ),
  constraint lots_posted_has_time check (status <> 'posted' or posted_at is not null),
  constraint lots_posted_time_status check (
    posted_at is null or status in ('posted', 'reversed')
  )
);

-- Composite FKs need an index starting with the same columns (advisor 0001).
create index lots_farmer_idx on public.lots (farmer_id, tenant_id, entry_date);
create index lots_buyer_idx on public.lots (buyer_party_id, tenant_id);
create index lots_crop_idx on public.lots (crop_id, tenant_id);
create index lots_tenant_date_idx on public.lots (tenant_id, entry_date);
create index lots_device_idx on public.lots (device_id) where device_id is not null;

create trigger lots_set_updated_at before update on public.lots
  for each row execute function private.set_updated_at();
create trigger lots_set_created_by before insert on public.lots
  for each row execute function private.set_created_by();
create trigger lots_keep_tenant_id before update on public.lots
  for each row execute function private.keep_tenant_id();

-- What RLS cannot express: the status moves and who may make them.
--   open → anything (arrivals.manage); posted → reversed (entries.reverse),
--   nothing else changes; reversed is final; lot_no never changes.
create or replace function private.guard_lot()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_is_user boolean := (select auth.uid()) is not null;
begin
  if tg_op = 'INSERT' then
    if new.status = 'reversed' then
      raise exception 'a lot cannot be created reversed' using errcode = '23514';
    end if;
  else
    if old.status = 'reversed' then
      raise exception 'a reversed lot cannot change' using errcode = '42501';
    end if;
    if new.lot_no is distinct from old.lot_no then
      raise exception 'a lot number cannot change' using errcode = '42501';
    end if;
    if old.status = 'posted' then
      if new.status <> 'reversed'
        or (to_jsonb(new) - 'status' - 'updated_at')
          <> (to_jsonb(old) - 'status' - 'updated_at') then
        raise exception 'a posted lot cannot change; reverse it instead'
          using errcode = '42501';
      end if;
      if v_is_user and not (select private.has_permission(new.tenant_id, 'entries.reverse')) then
        raise exception 'reversing a posted lot needs entries.reverse'
          using errcode = '42501';
      end if;
      return new;
    end if;
  end if;

  if v_is_user and not (select private.has_permission(new.tenant_id, 'arrivals.manage')) then
    raise exception 'lots need arrivals.manage' using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_lot() from public, anon, authenticated;

create trigger lots_guard before insert or update on public.lots
  for each row execute function private.guard_lot();

alter table public.lots enable row level security;

create policy lots_select on public.lots
  for select to authenticated
  using (tenant_id in (select private.auth_tenant_ids()));

create policy lots_insert on public.lots
  for insert to authenticated
  with check ((select private.has_permission(tenant_id, 'arrivals.manage')));

-- Which change needs which permission is checked by private.guard_lot().
create policy lots_update on public.lots
  for update to authenticated
  using (
    (select private.has_permission(tenant_id, 'arrivals.manage'))
    or (select private.has_permission(tenant_id, 'entries.reverse'))
  )
  with check (
    (select private.has_permission(tenant_id, 'arrivals.manage'))
    or (select private.has_permission(tenant_id, 'entries.reverse'))
  );

revoke all on public.lots from anon;
revoke delete, truncate on public.lots from authenticated;

alter publication powersync add table public.lots;
