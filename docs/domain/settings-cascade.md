# Settings cascade (everything configurable per customer)

Every configurable value resolves from the most specific level that has a value:

```
document (loan / lot / invoice)   ← most specific, wins
  └─ party (farmer / vendor)
       └─ party group (optional: e.g. "Village Rampura", "Big vendors")
            └─ tenant (the arhtiya's business)
                 └─ plan default (from subscription plan)
                      └─ system default (in code: khata_core/defaults.dart)
```

A `null` at a level means "inherit". The resolved value AND the level it came from must be shown in the UI (e.g. "18% · from business default"), so the owner always knows why a number was used.

## Resolution details

- **Per-crop (and other suffixed) keys — level first.** A key like `mandi.commission_pct.wheat` is looked up level by level, most specific first; *within* each level the suffixed key beats the generic one (`mandi.commission_pct`). So a party's negotiated general commission beats the business's wheat rate:
  `lot(wheat → generic) → party(wheat → generic) → party group(…) → business(…) → plan(…) → system(generic)`.
- A stored value that fails validation (e.g. written by a newer app version) is treated as `null` (inherit), never used.
- "Reset to inherited" writes `null`; setting rows are never deleted.
- **Where a key may be set:** `interest.*` and `mandi.*` at every level; everything else (shop, business, app, print, notify) at business level only.
- **Who may set it** (enforced by RLS `can_write_setting` and in the UI): `interest.*` needs `loans.manage` at every level; other keys need `settings.manage` at business / party-group level and only membership at party / document level.
- Percentages and other decimals are stored as JSON **strings** (`"18"`, `"2.5"`) and handled as exact decimals; money as integer paise.

## Storage

- `settings` table: `(id, tenant_id, scope, scope_id, key, value jsonb, updated_by, updated_at)`
  - `scope` ∈ `tenant | party_group | party | loan | lot | invoice`
  - `scope_id` is null for `tenant`
  - unique `(tenant_id, scope, scope_id, key)`
- Keys are namespaced strings, e.g. `interest.rate_pa`, `mandi.commission_pct.wheat`.
- Values are validated against a schema defined in `khata_core/settings_schema.dart` (type, min, max, allowed values).
- **Snapshot rule:** when a document is posted (loan issued, lot sold), copy the resolved values INTO the document row (`loan.interest_config jsonb`). Later changes to tenant defaults must NOT silently change old documents. Changing an existing loan's terms is an explicit, audited action with an effective-from date.

## Setting keys (v1)

### Interest (byaj)
| Key | Type | Default | Notes |
|---|---|---|---|
| `interest.enabled` | bool | true | |
| `interest.rate_pa` | decimal % | 18.0 | per annum. Also allow entry as "₹ per 100 per month" (e.g. ₹1.5 = 18% p.a.) — convert on input. |
| `interest.rate_unit_display` | enum | `pa` | `pa` \| `per100_per_month` (how the UI shows it) |
| `interest.method` | enum | `simple` | `simple` \| `compound` |
| `interest.compounding` | enum | `quarterly` | `monthly` \| `quarterly` \| `halfyearly` \| `yearly` \| `on_fy_close` (only if method=compound) |
| `interest.day_basis` | int | 365 | 365 \| 360 |
| `interest.grace_days` | int | 0 | no interest for first N days after each debit |
| `interest.appropriation` | enum | `interest_first` | `interest_first` \| `principal_first` — how a repayment is split |
| `interest.apply_on` | enum | `net_udhaar` | `net_udhaar` (only when party's NET balance is udhaar) \| `loans_only` \| `none` |
| `interest.min_days` | int | 0 | ignore periods shorter than this |
| `interest.rounding` | enum | `rupee` | `paise` \| `rupee` \| `ten_rupee` |
| `interest.post_frequency` | enum | `on_demand` | `on_demand` \| `monthly` \| `quarterly` \| `fy_close` — when accrued interest is posted as a khata entry |
| `interest.pay_on_jama` | bool | false | pay interest TO party when we owe them (some arhtiyas do) |
| `business.credit_limit` | paise | 0 | the most a party may owe; 0 = no limit. A business default that a party (or group) can override. Only raises the "over the credit limit" alert on the dashboard; nothing is blocked |
| `interest.pay_rate_pa` | decimal % | 0 | rate used when `pay_on_jama` = true |

### Mandi (arhat & charges) — can be per crop: `mandi.<key>.<crop_code>` overrides `mandi.<key>`
| Key | Type | Default |
|---|---|---|
| `mandi.commission_pct` | decimal % | 2.5 |
| `mandi.palledari_per_bag` | paise | 1200 |
| `mandi.bardana_per_bag` | paise | 800 |
| `mandi.tulai_per_qtl` | paise | 300 |
| `mandi.mandi_fee_pct` | decimal % | 1.0 |
| `mandi.cess` | list of `{name, pct}` | [] |
| `mandi.charges_borne_by` | map charge→`farmer`\|`buyer`\|`arhtiya` | all `farmer` |
| `mandi.bag_weight_kg` | decimal | 50 |

### Shop
| Key | Type | Default |
|---|---|---|
| `shop.price_tiers` | list | `[farmer, retail, vendor, wholesale]` |
| `shop.default_tier_for_role.<role>` | enum | farmer→farmer, vendor→vendor |
| `shop.allow_negative_stock` | bool | false |
| `shop.expiry_warn_days` | int | 180 |
| `shop.gst_enabled` | bool | true |
| `shop.post_credit_sale_to_khata` | bool | true |

### Business / numbering / app
| Key | Type | Default |
|---|---|---|
| `business.fy_start_month` | int | 4 |
| `business.backdate_days` | int | 3 — a khata entry dated more than N days before the day it is recorded, or in the future, needs `entries.reverse` (see ledger-and-mandi.md) |
| `business.number_series.<doc>` | `{prefix, next}` | R-, L-, SI-, PI-, KZ-, V- |
| `app.modules.<module>` | bool | per plan |
| `app.languages` | list | `[en, hi, pa]` |
| `app.default_language` | enum | `en` |
| `print.receipt_size` | enum | `a5` \| `thermal_80` \| `thermal_58` |
| `notify.whatsapp_receipts` | bool | false |
| `onboarding.status` | enum | `not_started` — `not_started` \| `in_progress` \| `completed` \| `skipped`. Hidden app bookkeeping: the first-run wizard's state, business level only |
| `onboarding.step` | int | 0 — steps finished (0–7); the wizard resumes there, on any device |
