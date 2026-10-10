# Super admin guide

The super admin is the vendor (you). Everything is in the separate web app
`apps/mk_admin`; the customer app only has an **Admin sign-in** link on its
login screen that opens it.

## Sign in

| Where | Address | Admin |
|---|---|---|
| Local stack (`supabase db reset` seeds it) | `flutter run -d chrome --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=<anon key from supabase status>` | `admin@mandikhata.test` / `Admin@12345` |
| Dev project | same, with the dev URL and key | create yours with `scripts/create_super_admin.sql` (dashboard SQL editor; edit the email and password first) or Authentication > Add user + the last statement of that script |

Main app: build with `--dart-define=ADMIN_CONSOLE_URL=https://<where you host mk_admin>`
(put it in `.env.dev`); the login screen's **Admin sign-in** then opens the
console. Without it the link explains what to set.

Anyone in `public.platform_admins` is a super admin; there is deliberately no
screen to add one. Local seed password is for local only.

## What you can do

| Page | Use |
|---|---|
| **Businesses** | Every customer: plan, status, MRR; open one to change subscription, add-ons, module overrides and limits, set business defaults, start a read-only support view. |
| **Users & access** | Everyone who can sign in. **Create user** (name, email, optional mobile and password; empty password = a strong one is generated and shown once; optional business and role). Open a person to: reset the password, disable / enable sign-in, add them to businesses, and per business set the **role**, **devices**, **can use this business**, and a switch for each of the 16 features (**Role / Allow / Deny**). Presets: Follow role, Allow all, Allow none. |
| Requests | Plan change requests from customers. |
| Plans & add-ons, Platform settings, State presets | Everything commercial and default is data. |
| Crop master, Referral codes, Announcements | Content. |
| Sync health | Upload delay and last-seen per business. |
| Audit log | Every admin action (before / after). |

## How feature access works (and when it applies)

1. The **plan** decides which modules a business has at all (Businesses > open > Add-ons and overrides).
2. The person's **role** gives defaults; **Allow / Deny** overrides one feature (`tenant_members.custom_permissions`).
3. Both the app (hides the screen) and the database (RLS) read the same value, so a Deny cannot be bypassed from a modified app. The person's device picks the change up on its next sync; offline devices keep their old copy until then.
4. An **owner** always has every feature and cannot be limited; a business always keeps at least one active owner (the switch is refused for the last one).
5. Admin-created memberships ignore the plan's user limit (a deliberate vendor override); the customer's own invites respect it.

Users created here sign in to the customer app with the **Email** tab
(email + password). A mobile number is stored for the phone-OTP tab but an OTP
needs the SMS provider configured in Supabase.

## Passwords
Shown once when created or reset, with a copy button; never stored by us. Ask
the user to change it after the first sign-in.
