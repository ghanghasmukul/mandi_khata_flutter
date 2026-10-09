# SaaS rules (phase 5): plans, entitlements, lifecycle, signup

Everything below is **data you can change from the admin console**: plans, prices, limits, add-ons, trial and grace lengths, state presets, signup defaults. Only the *meaning* of a module or limit key (what screen it hides) is in code.

## 1. Plans

A plan is a row of `plans`. Clients read, only the platform changes it.

| Column | Meaning |
|---|---|
| `code` | stable id, e.g. `mandi_pro` (never reused) |
| `name`, `description` | shown to the owner |
| `price_monthly_paise`, `price_yearly_paise` | shown on the Billing screen; billing itself is manual until Razorpay (step 5.2, deferred) |
| `max_users`, `max_devices` | shortcut columns for the two limits every plan has; `null` = unlimited |
| `modules` | `{"khata": true, "shop": false, ...}` |
| `limits` | `{"parties": 2000, ...}` other counted limits; absent or `null` = unlimited |
| `default_settings` | settings applied at the **plan level of the settings cascade** (`{"interest.rate_pa": "18"}`) |
| `is_public` | offered in the self-serve plan list; trial plans are not public |
| `is_active`, `sort_order` | |

### Module keys (code knows these)
`khata` (parties, khata, payments), `arrivals` (lots, crops), `karza` (loans, byaj, interest posting), `accounting` (vouchers, books, expenses, reconciliation, statements, Tally), `shop` (products, purchases, POS, shop reports). Adding a module needs code; granting it needs only data.

### Limit keys
`users`, `devices` (from the shortcut columns), `parties` and any key an admin adds. Only `users`, `devices` and `parties` are enforced today (server triggers and the app); other keys are shown and available to future code.

### Seeded plans (all editable)
| Code | Modules | Users | Devices | Parties |
|---|---|---|---|---|
| `trial` | all | 5 | 5 | unlimited |
| `mandi_basic` | khata, arrivals | 2 | 2 | 2000 |
| `mandi_pro` | khata, arrivals, karza, accounting | 5 | 5 | unlimited |
| `shop` | khata, shop | 3 | 3 | unlimited |
| `combo` | all | 8 | 8 | unlimited |

Prices are placeholders (0 = "ask us") until you set them in the console.

### Add-ons
`plan_addons` rows: `grants_limits` is a per-unit increment (`{"users": 1}`), `grants_modules` switches modules on (`{"karza": true}`), optional `max_quantity`. Seeded: `extra_user` (+1 user), `extra_device` (+1 device).

## 2. Entitlements (khata_core `Entitlements.resolve`)

```
modules = plan.modules
          then each add-on:  grants_modules true -> on
          then overrides.modules (absolute, true or false)
limits  = plan.limits (+ users, devices from the shortcut columns)
          then each add-on:  limit += increment * quantity   (unlimited stays unlimited)
          then overrides.limits (absolute; null = unlimited)
```
- Overrides are per business (`tenant_subscriptions.overrides`), set by the super-admin. They win over everything, so a customer can get a module or a bigger limit without a new plan.
- A missing module is **off**. A missing limit is **unlimited**.
- The business's own switch `app.modules.<m>` can only turn a module **off**: effective = plan allows AND the switch is not false. A switch left over from before, or written by a tampered client, can never turn on what the plan lacks.
- Plan `default_settings` become the *plan* level of the settings cascade (below the business, above the system default). Keys that fail the settings schema are ignored.

## 3. Subscription and lifecycle

`tenant_subscriptions` (one row per business): `plan_code`, `billing_cycle`, `status`, `trial_ends_at`, `current_period_start/end`, `grace_days`, `grace_until`, `cancelled_at`, `addons`, `overrides`, `discount_pct`, `discount_note`, `razorpay_*` (empty until 5.2). `tenants.plan_code/status/trial_ends_at` mirror it by trigger.

Stored `status`: `trial | active | past_due | grace | locked | cancelled`.

### Effective state (khata_core `Lifecycle.evaluate`, mirrored in SQL `private.effective_status`)
Computed from dates and `now`, so it works offline and needs no cron job.

| Stored | Condition | Effective | Access |
|---|---|---|---|
| trial | now < trial_ends_at | trial | full (banner with days left) |
| trial | now >= trial_ends_at | locked | read-only |
| active | now <= current_period_end | active | full |
| active / past_due / grace | now > current_period_end and now < graceEnd | grace | full + banner |
| active / past_due / grace | now >= graceEnd | locked | read-only |
| locked | | locked | read-only |
| cancelled | now < cancelled_at + 90 days | cancelled | read-only |
| cancelled | after that | cancelled | export-only |

`graceEnd` = `grace_until` if set, else `current_period_end + grace_days` (default 7, per business). `current_period_end` null on active = no end (comp account).
- **Read-only** = view, search, print, export everything; no new business entries. Data is never deleted.
- **Export-only** = only the export screens (and sign-out / billing) are reachable.
- Trial length (14 days) and grace (7) come from `platform_settings` at signup and are copied onto the business, where the super-admin can change them.
- Hard delete only on a written request through the super-admin.

### Offline tolerance
A device that has not synced since the lock moment may be wrong (the owner may have renewed). It stays in the previous mode with a "connect to confirm your subscription" banner until `lockMoment + 7 days` (`platform_settings.offline_tolerance_days`), then becomes read-only until it syncs once. A device that synced after the lock moment locks exactly at the lock moment. The server never has this tolerance: an upload after the lock moment is checked against the server's current subscription, which a renewal has already moved forward.

### Signed entitlement token
Edge Function `entitlement-token` returns an ES256 JWT `{tid, plan, status, modules, limits, valid_until, iat}` for a member of the business. The app caches it after each sync and verifies it with the public key in `ENTITLEMENT_PUBLIC_KEY`. When a verified token is newer than the synced subscription row it wins, so editing the local database cannot extend a subscription. Without a configured key the synced row alone is used (dev).

### Server enforcement
- A trigger on every business table refuses inserts and updates from a signed-in user when the business is read-only (effective locked or cancelled) with errcode `42501` and message `subscription_locked`. Service role and admin functions are not affected. Exempt: `tenants`, `tenant_members`, `devices`, `app_users`, `member_invites`, `audit_log`, `number_series`, plan requests and the subscription tables.
- The same trigger refuses writes to tables of a module the plan lacks (`private.module_tables`: data, not code), message `module_not_in_plan`.
- Limits: `tenant_members` (active members plus pending invites <= users), `devices` (non-revoked <= devices), `parties` (not deleted <= parties); message `limit_reached:<key>`.

## 4. Platform settings (`platform_settings`, super-admin only)
`trial_days` 14, `grace_days` 7, `cancelled_readonly_days` 90, `offline_tolerance_days` 7, `max_businesses_per_user` 3, `signup_enabled` true, `signup.trial_plan.arhtiya|shop|both` (plan code used for the trial), `signup.default_plan.*`. The app reads the ones marked `is_public`.

## 5. Signup (`signup_business()` RPC)
A signed-in user (phone OTP) with fewer than `max_businesses_per_user` businesses calls it with: business id (client UUID), name, state code, mandi name, business type (`arhtiya | shop | both`), phone, optional referral code. It, in one transaction: creates the tenant, the owner membership, the subscription (trial plan for the business type, `trial_days`), the state preset's settings and the plan's `default_settings` are **not copied** (the plan default is a cascade level; the preset is copied into tenant settings once so the owner can edit them), and sets `app.modules.*` off for modules the business type does not use. The onboarding wizard (step 1.9) then opens by itself because the business is new.
- The referral code is stored on the tenant (`referral_code`); an unknown code is stored as typed with `referral_valid = false` so a dealer can be credited later; it never blocks signup.
- State presets (`state_presets`: state code, settings jsonb for `mandi.*` fees, cess and commission) are edited in the console.

## 6. Super-admin
Separate Flutter web app `apps/mk_admin`. Every action goes through the Edge Function `admin-api` (service role) after it checks the caller is in `platform_admins`; every action writes `admin_audit_log`. Support view is read-only and writes a `support_sessions` row the customer can see in Billing.
