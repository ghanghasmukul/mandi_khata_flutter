-- Phase 5 (steps 5.3 + 5.4): functions the `admin-api` and
-- `entitlement-token` Edge Functions call with the service role. The
-- business logic stays in SQL (one transaction with its audit row), so the
-- TypeScript layer is thin and never re-implements entitlement maths.

create or replace function public.admin_tenant_entitlements(p_tenant_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select private.tenant_entitlements(p_tenant_id);
$$;

-- The subscription fields a super-admin may change, in one audited step.
create or replace function public.admin_update_subscription(
  p_admin_id uuid,
  p_admin_email text,
  p_tenant_id uuid,
  p_changes jsonb,
  p_note text default null
)
returns public.tenant_subscriptions
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_before public.tenant_subscriptions;
  v_after public.tenant_subscriptions;
  v_allowed constant text[] := array[
    'plan_code', 'billing_cycle', 'status', 'trial_ends_at',
    'current_period_start', 'current_period_end', 'grace_days', 'grace_until',
    'cancelled_at', 'cancelled_readonly_days', 'addons', 'overrides',
    'discount_pct', 'discount_note'
  ];
  v_key text;
begin
  if jsonb_typeof(p_changes) is distinct from 'object' then
    raise exception 'changes must be an object' using errcode = '22023';
  end if;
  for v_key in select jsonb_object_keys(p_changes) loop
    if not (v_key = any (v_allowed)) then
      raise exception 'field % cannot be changed', v_key using errcode = '22023';
    end if;
  end loop;

  select * into v_before from public.tenant_subscriptions where tenant_id = p_tenant_id;
  if not found then
    raise exception 'no subscription for this business' using errcode = 'P0002';
  end if;

  update public.tenant_subscriptions s set
    plan_code = coalesce(p_changes ->> 'plan_code', s.plan_code),
    billing_cycle = coalesce(p_changes ->> 'billing_cycle', s.billing_cycle),
    status = coalesce(p_changes ->> 'status', s.status),
    trial_ends_at = case when p_changes ? 'trial_ends_at'
      then (p_changes ->> 'trial_ends_at')::timestamptz else s.trial_ends_at end,
    current_period_start = case when p_changes ? 'current_period_start'
      then (p_changes ->> 'current_period_start')::timestamptz else s.current_period_start end,
    current_period_end = case when p_changes ? 'current_period_end'
      then (p_changes ->> 'current_period_end')::timestamptz else s.current_period_end end,
    grace_days = coalesce((p_changes ->> 'grace_days')::int, s.grace_days),
    grace_until = case when p_changes ? 'grace_until'
      then (p_changes ->> 'grace_until')::timestamptz else s.grace_until end,
    cancelled_at = case
      when p_changes ? 'cancelled_at' then (p_changes ->> 'cancelled_at')::timestamptz
      when p_changes ->> 'status' = 'cancelled' and s.cancelled_at is null then now()
      when p_changes ->> 'status' is distinct from 'cancelled' and p_changes ? 'status' then null
      else s.cancelled_at end,
    cancelled_readonly_days = coalesce((p_changes ->> 'cancelled_readonly_days')::int,
      s.cancelled_readonly_days),
    addons = coalesce(p_changes -> 'addons', s.addons),
    overrides = coalesce(p_changes -> 'overrides', s.overrides),
    discount_pct = coalesce((p_changes ->> 'discount_pct')::numeric, s.discount_pct),
    discount_note = case when p_changes ? 'discount_note'
      then p_changes ->> 'discount_note' else s.discount_note end
  where s.tenant_id = p_tenant_id
  returning * into v_after;

  insert into public.admin_audit_log (
    admin_user_id, admin_email, action, target_tenant_id, target_type, target_id,
    before, after, note
  )
  values (
    p_admin_id, p_admin_email, 'update_subscription', p_tenant_id,
    'tenant_subscriptions', p_tenant_id::text,
    to_jsonb(v_before) - 'id', to_jsonb(v_after) - 'id', p_note
  );
  return v_after;
end;
$$;

-- A business-level setting changed on the customer's behalf. Written like
-- the app writes it (same deterministic row id), and recorded in BOTH the
-- business's audit log (the customer sees who changed it) and the admin log.
create or replace function public.admin_set_tenant_setting(
  p_admin_id uuid,
  p_admin_email text,
  p_tenant_id uuid,
  p_key text,
  p_value jsonb,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid := extensions.uuid_generate_v5(
    '6f1c0a52-3b0e-4f7e-9d58-2f3c1c6a9e41'::uuid,
    p_tenant_id::text || '|tenant||' || p_key);
  v_before jsonb;
begin
  if p_key !~ '^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$' then
    raise exception 'invalid setting key' using errcode = '22023';
  end if;
  select s.value into v_before from public.settings s where s.id = v_id;
  insert into public.settings (id, tenant_id, scope, scope_id, key, value, updated_by)
  values (v_id, p_tenant_id, 'tenant', null, p_key, p_value, p_admin_id)
  on conflict (id) do update set value = excluded.value, updated_by = p_admin_id;

  insert into public.audit_log (id, tenant_id, table_name, row_id, action, before, after,
    user_id, role)
  values (gen_random_uuid(), p_tenant_id, 'settings', v_id,
    case when v_before is null then 'insert' else 'update' end,
    jsonb_build_object('key', p_key, 'value', v_before),
    jsonb_build_object('key', p_key, 'value', p_value, 'by', 'support'),
    p_admin_id, 'support');
  insert into public.admin_audit_log (
    admin_user_id, admin_email, action, target_tenant_id, target_type, target_id,
    before, after, note
  )
  values (p_admin_id, p_admin_email, 'set_tenant_setting', p_tenant_id, 'settings',
    p_key, jsonb_build_object('value', v_before), jsonb_build_object('value', p_value),
    p_note);
end;
$$;

-- Read-only support: opens a session the customer can see, and returns a
-- snapshot of the business (counts, recent audit and khata activity).
create or replace function public.admin_start_support_session(
  p_admin_id uuid,
  p_admin_email text,
  p_tenant_id uuid,
  p_reason text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
begin
  if p_reason is null or length(trim(p_reason)) = 0 then
    raise exception 'a reason is required' using errcode = '22023';
  end if;
  insert into public.support_sessions (tenant_id, admin_user_id, admin_label, reason)
  values (p_tenant_id, p_admin_id, 'Mandi Khata support', trim(p_reason))
  returning id into v_id;
  insert into public.admin_audit_log (
    admin_user_id, admin_email, action, target_tenant_id, target_type, target_id, note
  )
  values (p_admin_id, p_admin_email, 'support_session_start', p_tenant_id,
    'support_sessions', v_id::text, trim(p_reason));
  return v_id;
end;
$$;

create or replace function public.admin_end_support_session(
  p_admin_id uuid,
  p_admin_email text,
  p_session_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_tenant uuid;
begin
  update public.support_sessions set ended_at = now()
    where id = p_session_id and ended_at is null
    returning tenant_id into v_tenant;
  if v_tenant is not null then
    insert into public.admin_audit_log (
      admin_user_id, admin_email, action, target_tenant_id, target_type, target_id
    )
    values (p_admin_id, p_admin_email, 'support_session_end', v_tenant,
      'support_sessions', p_session_id::text);
  end if;
end;
$$;

create or replace function public.admin_support_snapshot(p_tenant_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'tenant', (select to_jsonb(t) from public.tenants t where t.id = p_tenant_id),
    'subscription', (select to_jsonb(s) - 'id' from public.tenant_subscriptions s
      where s.tenant_id = p_tenant_id),
    'access', private.tenant_access(p_tenant_id),
    'entitlements', private.tenant_entitlements(p_tenant_id),
    'counts', jsonb_build_object(
      'members', (select count(*) from public.tenant_members m
        where m.tenant_id = p_tenant_id and m.is_active),
      'devices', (select count(*) from public.devices d
        where d.tenant_id = p_tenant_id and d.revoked_at is null),
      'parties', (select count(*) from public.parties p
        where p.tenant_id = p_tenant_id and p.deleted_at is null),
      'ledger_entries', (select count(*) from public.ledger_entries e
        where e.tenant_id = p_tenant_id)),
    'members', coalesce((select jsonb_agg(jsonb_build_object(
        'role', m.role, 'active', m.is_active, 'name', u.full_name, 'phone', u.phone)
        order by m.created_at)
      from public.tenant_members m join public.app_users u on u.id = m.user_id
      where m.tenant_id = p_tenant_id), '[]'::jsonb),
    'recent_audit', coalesce((select jsonb_agg(to_jsonb(a) - 'tenant_id')
      from (select * from public.audit_log l where l.tenant_id = p_tenant_id
        order by l.created_at desc limit 30) a), '[]'::jsonb),
    'recent_entries', coalesce((select jsonb_agg(jsonb_build_object(
        'date', e.entry_date, 'party', p.name, 'side', e.side,
        'amount_paise', e.amount_paise, 'ref_type', e.ref_type))
      from (select * from public.ledger_entries x where x.tenant_id = p_tenant_id
        order by x.created_at desc limit 30) e
      join public.parties p on p.id = e.party_id), '[]'::jsonb)
  );
$$;

do $$
declare
  f text;
begin
  foreach f in array array[
    'admin_tenant_entitlements(uuid)',
    'admin_update_subscription(uuid, text, uuid, jsonb, text)',
    'admin_set_tenant_setting(uuid, text, uuid, text, jsonb, text)',
    'admin_start_support_session(uuid, text, uuid, text)',
    'admin_end_support_session(uuid, text, uuid)',
    'admin_support_snapshot(uuid)'
  ] loop
    execute format('revoke execute on function public.%s from public, anon, authenticated', f);
    execute format('grant execute on function public.%s to service_role', f);
  end loop;
end;
$$;
