-- Super-admin user management (service role only, called by `admin-api`).
--
-- admin_users()             every user with their businesses, role and the
--                           per-feature overrides the admin set
-- admin_set_member_access() add a user to a business or change role, feature
--                           overrides (custom_permissions), device limit and
--                           active flag; audited in admin_audit_log in the
--                           same transaction
--
-- Feature access of one user = the role's defaults, changed by
-- custom_permissions {"<permission key>": true|false}. The app and RLS
-- already read it (private.has_permission), so what the admin sets here is
-- enforced at once, also offline-cached copies after their next sync.

create or replace function private.valid_permission_key(p_key text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select p_key = any (array[
    'parties.manage', 'arrivals.manage', 'payments.create', 'entries.reverse',
    'loans.manage', 'finance.view', 'admin.manage', 'master.delete',
    'settings.manage', 'audit.view', 'products.manage', 'purchases.create',
    'sales.create', 'sales.return', 'stock.adjust', 'shop.view_profit'
  ]);
$$;

revoke execute on function private.valid_permission_key(text) from public, anon, authenticated;

create or replace function public.admin_users()
returns table (
  user_id uuid,
  email text,
  phone text,
  full_name text,
  created_at timestamptz,
  last_sign_in_at timestamptz,
  is_banned boolean,
  is_platform_admin boolean,
  memberships jsonb
)
language sql
stable
security definer
set search_path = ''
as $$
  select u.id, u.email::text, coalesce(a.phone, u.phone::text), a.full_name,
    u.created_at, u.last_sign_in_at,
    coalesce(u.banned_until > now(), false),
    exists (select 1 from public.platform_admins p where p.user_id = u.id),
    coalesce((
      select jsonb_agg(jsonb_build_object(
        'tenant_id', m.tenant_id,
        'tenant_name', t.name,
        'role', m.role,
        'is_active', m.is_active,
        'custom_permissions', m.custom_permissions,
        'device_limit', m.device_limit
      ) order by t.name)
      from public.tenant_members m
      join public.tenants t on t.id = m.tenant_id
      where m.user_id = u.id
    ), '[]'::jsonb)
  from auth.users u
  left join public.app_users a on a.id = u.id
  order by u.created_at desc;
$$;

revoke execute on function public.admin_users() from public, anon, authenticated;
grant execute on function public.admin_users() to service_role;

create or replace function public.admin_set_member_access(
  p_admin_id uuid,
  p_admin_email text,
  p_tenant_id uuid,
  p_user_id uuid,
  p_role text default null,
  p_custom jsonb default null,
  p_is_active boolean default null,
  p_device_limit integer default null,
  p_note text default null
)
returns public.tenant_members
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_before public.tenant_members;
  v_after public.tenant_members;
  v_key text;
  v_val jsonb;
begin
  if p_role is not null and p_role not in ('owner', 'accountant', 'munshi', 'custom') then
    raise exception 'unknown role %', p_role using errcode = '22023';
  end if;
  if p_custom is not null then
    if jsonb_typeof(p_custom) <> 'object' then
      raise exception 'custom permissions must be an object' using errcode = '22023';
    end if;
    for v_key, v_val in select * from jsonb_each(p_custom) loop
      if not private.valid_permission_key(v_key) or jsonb_typeof(v_val) <> 'boolean' then
        raise exception 'bad permission %', v_key using errcode = '22023';
      end if;
    end loop;
  end if;
  if not exists (select 1 from public.tenants t where t.id = p_tenant_id) then
    raise exception 'business not found' using errcode = 'P0002';
  end if;
  if not exists (select 1 from public.app_users u where u.id = p_user_id) then
    raise exception 'user not found' using errcode = 'P0002';
  end if;

  select * into v_before from public.tenant_members m
  where m.tenant_id = p_tenant_id and m.user_id = p_user_id;

  if not found then
    insert into public.tenant_members (id, tenant_id, user_id, role, custom_permissions,
      is_active, device_limit, created_by)
    values (gen_random_uuid(), p_tenant_id, p_user_id, coalesce(p_role, 'munshi'),
      coalesce(p_custom, '{}'::jsonb), coalesce(p_is_active, true),
      coalesce(p_device_limit, 5), p_admin_id)
    returning * into v_after;
  else
    update public.tenant_members m set
      role = coalesce(p_role, m.role),
      custom_permissions = coalesce(p_custom, m.custom_permissions),
      is_active = coalesce(p_is_active, m.is_active),
      device_limit = coalesce(p_device_limit, m.device_limit)
    where m.id = v_before.id
    returning * into v_after;
  end if;

  insert into public.admin_audit_log (admin_user_id, admin_email, action,
    target_tenant_id, target_type, target_id, before, after, note)
  values (p_admin_id, p_admin_email,
    case when v_before.id is null then 'add_member' else 'update_member_access' end,
    p_tenant_id, 'tenant_members', p_user_id::text,
    case when v_before.id is null then null else jsonb_build_object(
      'role', v_before.role, 'custom_permissions', v_before.custom_permissions,
      'is_active', v_before.is_active, 'device_limit', v_before.device_limit) end,
    jsonb_build_object('role', v_after.role,
      'custom_permissions', v_after.custom_permissions,
      'is_active', v_after.is_active, 'device_limit', v_after.device_limit),
    p_note);
  return v_after;
end;
$$;

revoke execute on function public.admin_set_member_access(uuid, text, uuid, uuid, text, jsonb,
  boolean, integer, text) from public, anon, authenticated;
grant execute on function public.admin_set_member_access(uuid, text, uuid, uuid, text, jsonb,
  boolean, integer, text) to service_role;
