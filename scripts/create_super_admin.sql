-- Creates (or promotes) a super admin on the DEV project.
--
-- Run it in the Supabase dashboard > SQL editor. Change the two values below
-- first; do NOT commit a real password. Prefer Authentication > Add user
-- (email + password, "Auto confirm") and then only run the last statement.
--
-- Production: never run by hand; add the admin through the same dashboard of
-- the prod project by a person who owns it.

do $$
declare
  v_email text := 'you@example.com';          -- <- your email
  v_password text := 'change-me-please-123';  -- <- a long password
  v_id uuid;
begin
  select id into v_id from auth.users where email = v_email;
  if v_id is null then
    v_id := gen_random_uuid();
    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) values (
      '00000000-0000-0000-0000-000000000000', v_id, 'authenticated', 'authenticated',
      v_email, extensions.crypt(v_password, extensions.gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"full_name":"Super Admin"}'::jsonb, now(), now(), '', '', '', ''
    );
    insert into auth.identities (id, user_id, provider_id, identity_data, provider,
      last_sign_in_at, created_at, updated_at)
    values (gen_random_uuid(), v_id, v_id::text,
      jsonb_build_object('sub', v_id::text, 'email', v_email), 'email', now(), now(), now());
  end if;

  insert into public.platform_admins (user_id, email) values (v_id, v_email)
  on conflict (user_id) do nothing;
end $$;
