-- Step 6.6: sync health per business for the admin console.
--
-- What the server can see of a device's upload queue: a ledger entry carries
-- the device's created_at and the server's received_at, so received_at -
-- created_at is how long the entry waited on the device (offline time or a
-- stuck queue). A business whose devices have not been seen for days while
-- its owner is active is the other warning sign. Device clocks can be wrong:
-- negative lags are ignored.

create index if not exists ledger_entries_tenant_received_idx
  on public.ledger_entries (tenant_id, received_at);

create or replace function public.admin_sync_health(p_days integer default 7)
returns table (
  tenant_id uuid,
  name text,
  active_devices bigint,
  last_seen_at timestamptz,
  entries bigint,
  lag_p50_seconds integer,
  lag_p95_seconds integer,
  lag_max_seconds integer,
  late_entries bigint,
  last_received_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  with window_entries as (
    select e.tenant_id,
           extract(epoch from (e.received_at - e.created_at)) as lag
    from public.ledger_entries e
    where e.received_at > now() - make_interval(days => greatest(p_days, 1))
  ),
  lag as (
    select w.tenant_id,
           count(*) as entries,
           percentile_cont(0.5) within group (order by w.lag)
             filter (where w.lag >= 0) as p50,
           percentile_cont(0.95) within group (order by w.lag)
             filter (where w.lag >= 0) as p95,
           max(w.lag) filter (where w.lag >= 0) as max_lag,
           count(*) filter (where w.lag > 3600) as late
    from window_entries w
    group by w.tenant_id
  )
  select t.id, t.name,
    (select count(*) from public.devices d
     where d.tenant_id = t.id and d.revoked_at is null),
    (select max(d.last_seen_at) from public.devices d where d.tenant_id = t.id),
    coalesce(l.entries, 0),
    round(l.p50)::integer, round(l.p95)::integer, round(l.max_lag)::integer,
    coalesce(l.late, 0),
    (select max(e.received_at) from public.ledger_entries e
     where e.tenant_id = t.id)
  from public.tenants t
  left join lag l on l.tenant_id = t.id
  order by l.p95 desc nulls last, t.name;
$$;

revoke execute on function public.admin_sync_health(integer) from public, anon, authenticated;
grant execute on function public.admin_sync_health(integer) to service_role;
