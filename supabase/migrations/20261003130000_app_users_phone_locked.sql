-- Phase 1 review H1: app_users.phone was editable by its owner (policy
-- app_users_update allows any column). accept_member_invites() matches
-- pending invites against that column, so a signed-in user could set it to an
-- invited number and join a business with the invite's role and permissions.
-- The phone is a copy of the verified auth.users phone made at sign-up; API
-- roles may no longer change it.

create or replace function private.lock_app_user_phone()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.phone is distinct from old.phone
     and current_user in ('authenticated', 'anon') then
    raise exception 'phone_is_read_only' using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke all on function private.lock_app_user_phone() from public;

create trigger app_users_lock_phone
  before update on public.app_users
  for each row execute function private.lock_app_user_phone();
