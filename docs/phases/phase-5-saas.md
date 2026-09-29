# Phase 5 — SaaS layer (subscriptions, onboarding, super-admin)

**Goal:** sell Mandi Khata to many arhtiyas and vendors on subscription: plans, Razorpay billing, module gating, trial → active → grace → read-only lock (never data loss), and a super-admin console for you to manage every customer and their defaults.

---

## Step 5.1 — Plans & entitlements

**Prompt**
```
Tables (server-managed, clients read-only): plans (code, name, price_monthly, price_yearly, max_users, max_devices, modules jsonb e.g. {mandi:true, karza:true, accounting:false, shop:false}, limits jsonb e.g. {parties: 2000}, default_settings jsonb), tenant_subscriptions (tenant_id, plan_code, status trial|active|past_due|grace|locked|cancelled, current_period_end, razorpay_subscription_id, addons jsonb).
khata_core: Entitlements.resolve(plan, addons, tenantOverrides) → which modules/limits apply. Tests.
App: module gating everywhere — sidebar, dashboard quick actions, routes (guard), reports. Settings "Modules" screen (owner) can turn OFF modules they have, never ON modules the plan lacks (show upgrade CTA).
Plan default_settings become the "plan default" level in the settings cascade.
Suggested plans to seed: Mandi Basic (khata, arrivals, payments), Mandi Pro (+ karza/byaj, accounting, 5 users), Shop (input shop only), Combo (everything), plus per-extra-user and per-extra-device add-ons.
```

## Step 5.2 — Razorpay subscriptions

**Prompt**
```
Supabase Edge Functions (TypeScript):
- create-subscription: owner picks plan/cycle → creates Razorpay customer + subscription → returns short_url / checkout options.
- razorpay-webhook: verify signature; handle subscription.activated, charged, pending, halted, cancelled, completed; payment.failed → update tenant_subscriptions + tenants.status; idempotent by event id (store processed events).
- GST invoice for YOUR subscription fee (you are the seller) emailed/WhatsApped to the customer.
App: Billing screen (owner): current plan, renewal date, invoices, upgrade/downgrade, pay now (opens Razorpay checkout on web/Android; on desktop open the payment link in the browser).
Never put Razorpay secret keys in the app.
```

## Step 5.3 — Lifecycle: trial, grace, lock (offline-aware)

**Prompt**
```
Lifecycle rules:
- Trial 14 days (configurable per tenant by super-admin).
- past_due → grace 7 days: full access + banner.
- locked: READ-ONLY — can view, search, print and export everything, cannot create new business entries. Data is never deleted.
- cancelled: read-only for 90 days, then export-only; hard delete only on written request via super-admin.
Offline handling: the app stores a signed entitlement token (JWT signed by an Edge Function, contains tenant, plan, modules, valid_until = period end + grace). The app enforces it offline; if the device is offline longer than valid_until + 7 days, switch to read-only until it syncs once. Server also enforces via RLS on inserts using tenants.status (so tampered clients cannot write).
Tests for every state transition.
```

## Step 5.4 — Super-admin console (you)

**Prompt**
```
A separate Flutter web app apps/mk_admin (or an admin area gated by a super_admin claim — ask me which) for the vendor team:
- Tenants list: status, plan, users, devices, last sync, data size, MRR.
- Tenant detail: change plan/trial end, extend grace, apply discounts, set tenant default settings (interest, commission, charges) on their behalf, view (not edit) their audit log, impersonate read-only for support (audited, customer can see it).
- Global templates: state-wise presets (Punjab, Haryana, Rajasthan mandi fees/cess, typical commission), crop master updates pushed to all tenants.
- Announcements / in-app messages.
Super-admin actions use Edge Functions with the service role; every action audited in an admin_audit_log.
```

## Step 5.5 — Self-serve signup & onboarding

**Prompt**
```
Public signup flow (web + Android): phone OTP → business name, state, mandi, business type (arhtiya / input shop / both) → apply the state preset + plan defaults → trial starts → onboarding wizard from Phase 1 step 1.9.
Referral code field (for your dealers/agents) stored on tenant for commission tracking.
Marketing landing page is separate (not part of this app).
```

## Phase 5 exit criteria

- [ ] New customer can sign up, pay via UPI autopay, and start working without talking to you.
- [ ] Failed payment → grace → read-only lock works, even for a device that stays offline.
- [ ] You can change any customer's defaults (e.g. interest method) from the admin console and it syncs to their devices.
