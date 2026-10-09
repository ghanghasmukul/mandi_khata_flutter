# Phase 5 setup: plans, admin console, signed entitlements

What you (the vendor) do once, in order. Nothing here needs Razorpay (step 5.2 is deferred).

## 1. Apply the database changes
```bash
supabase db push        # 3 migrations: phase5_saas_core, phase5_admin_signup, phase5_admin_functions
```
Seeds five plans (`trial`, `mandi_basic`, `mandi_pro`, `shop`, `combo`), two add-ons, the platform settings and the 11 default crops. **Prices are 0 ("price on request") until you set them** in the console. Every existing business gets a subscription (a fresh 14-day trial for those still on trial).

## 2. Deploy the PowerSync streams
Deploy `powersync/sync-streams.yaml` in the PowerSync dashboard. New: `tenant_subscriptions`, `plan_requests`, `support_sessions` (per business) and the `platform_data` stream (plans, add-ons, public platform settings, announcements). Without it devices never learn their plan and stay unrestricted (the server still enforces).

## 3. Signed entitlement token (optional but recommended)
The token lets a device that is offline prove its plan; without it the app uses the synced subscription row.
```bash
openssl ecparam -name prime256v1 -genkey -noout -out ent.pem
openssl pkcs8 -topk8 -nocrypt -in ent.pem -out ent_pkcs8.pem
openssl ec -in ent.pem -pubout -out ent_pub.pem

supabase secrets set ENTITLEMENT_PRIVATE_KEY="$(awk 'NF{printf "%s\\n",$0}' ent_pkcs8.pem)"
supabase functions deploy entitlement-token admin-api invite-member
```
Put the **public** key in each app env file as one line with `\n` for line breaks:
`ENTITLEMENT_PUBLIC_KEY=-----BEGIN PUBLIC KEY-----\nMFkw...\n-----END PUBLIC KEY-----`
Keep `ent.pem` / `ent_pkcs8.pem` out of git. Rotating the key = new secret + new public key in the next app release (old tokens stop verifying and the app falls back to the synced row).

## 4. Make yourself a platform admin
Create a normal Supabase Auth user (dashboard -> Authentication -> Add user, email + password), then in the SQL editor:
```sql
insert into public.platform_admins (user_id, email)
select id, email from auth.users where email = 'you@example.com';
```
Admins are only ever added this way; there is no screen for it.

## 5. Run the admin console
```bash
cd apps/mk_admin
flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
flutter build web --release      # host the output anywhere private; it only talks to admin-api
```
It is a separate app, so no admin code ships to customers. Sign in with the admin user. Everything it does goes through the `admin-api` Edge Function (checks `platform_admins`, uses the service role, writes `admin_audit_log`).

## 6. Set up the commercial data (in the console)
1. **Plans**: set the real prices, limits, modules, default settings; mark which plans are offered to new customers (`Offered`).
2. **Add-ons**: prices, maximum quantity.
3. **Platform settings**: `trial_days`, `grace_days`, `cancelled_readonly_days`, `max_businesses_per_user`, `signup_enabled`, and `signup.trial_plan.arhtiya|shop|both` (which plan the trial uses; default `trial` = every module).
4. **State presets**: fill in Punjab / Haryana / Rajasthan only after checking the current fee schedules (shipped empty on purpose).
5. **Crop master**, **Referral codes**, **Announcements** as needed.

## 7. Day to day (no payment gateway yet)
- A customer taps *Plan & billing -> Request this plan*; it appears under **Requests**.
- You agree the amount with them, take payment outside the app, then open the business: **Mark paid +30 days** (or set the plan, period end and status by hand), and press **Mark done** on the request.
- Non-payment: nothing to do. After the paid-until date the business gets the grace period (banner, full access), then becomes read-only on its own. **Extend grace 7 days** / **Extend trial 7 days** / **Lock now** are one click each.
- Changing a customer's interest method, commission etc.: *Business defaults*. The change shows in the customer's own audit log as "support".
- Looking at a customer's data: *Open read-only support view* (a reason is required; the customer sees the session under Plan & billing).

## What the server enforces (customers cannot bypass it)
- Read-only businesses: every insert / update on business tables is refused (`subscription_locked`); service-role work and audit rows are not.
- Modules the plan lacks (`module_not_in_plan`), the tables per module are the rows of `private.module_tables`.
- Limits: users (members + open invites), devices, parties (`limit_reached:*`, `device_limit_reached`).
