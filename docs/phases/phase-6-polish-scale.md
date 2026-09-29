# Phase 6 — Polish, integrations & scale

**Goal:** make it the tool arhtiyas recommend to each other: WhatsApp, printing, barcode, documents, backups, data import, performance at scale, and smooth distribution/updates.

---

## Step 6.1 — WhatsApp & SMS

**Prompt**
```
Integrate WhatsApp Business API (via a BSP such as Gupshup/Interakt/AiSensy — make the provider pluggable) in Edge Functions:
- Templates (en/hi/pa): payment receipt, lot sale slip, party statement link, loan due reminder, interest posted.
- Per-tenant setting notify.* toggles; per-party opt-out.
- Messages queue in a table when created offline and send after sync. Delivery status stored.
- Fallback "Share via WhatsApp" (share intent with PDF) that needs no API.
```

## Step 6.2 — Printing

**Prompt**
```
Printing:
- Thermal 58/80 mm ESC/POS on Windows and macOS (USB/network) and Android (Bluetooth) — use a maintained ESC/POS package; printer setup screen with test print.
- A4/A5 PDF templates editable per tenant (logo, header lines, footer, language, which fields show) — simple template settings, not a full designer.
- Batch print: day's receipts, all lot slips.
```

## Step 6.3 — Documents & KYC

**Prompt**
```
Party documents: capture with camera (Android) or pick file (Windows/macOS/Web), compress, store in Supabase Storage bucket per tenant (RLS by tenant), offline queue for uploads, thumbnails, types (Aadhaar, PAN, passbook, cheque, J-form, loan agreement). Mask Aadhaar number display. Owner-only access to KYC docs.
```

## Step 6.4 — Backup, restore, export

**Prompt**
```
- One-click "Download all my data" (owner): ZIP of XLSX per table + PDFs of all statements.
- Local encrypted backup file on desktop (Windows/macOS, scheduled daily to a chosen folder / USB) and restore into a fresh install (for shops with bad internet).
- Server side: rely on Supabase PITR; document RPO/RTO in docs/ops.md.
```

## Step 6.5 — Data import from existing systems

**Prompt**
```
Import wizards with column mapping + preview + validation + dry-run:
- Parties & opening balances from XLSX/CSV (already partly in 1.9 — extend).
- Tally XML masters & vouchers import (reverse of 3.6).
- Busy / Marg / generic CSV for products & stock.
Every import is a batch with an id and can be rolled back (reversal entries) by the owner.
```

## Step 6.6 — Performance & reliability at scale

**Prompt**
```
- Load test: tenant with 5 seasons of data (200k ledger rows, 50k lots, 10k parties). Measure cold start, first sync time, search, reports on low-end Android (2 GB RAM), a Windows 10 i3 (typical shop counter) and the development Mac.
- Add partial sync if needed: sync only current + previous FY by default; older years on demand (PowerSync parameterised buckets).
- Indexes, query plans, pagination for web.
- Sync health: server metrics per tenant (queue lag, errors) in the admin console.
- Crash-free sessions > 99.5% (Sentry).
```

## Step 6.7 — Distribution & updates

**Prompt**
```
- Windows: MSIX via Microsoft Store or signed installer (Inno Setup) with in-app update check (version endpoint in Supabase) and forced-update for breaking schema changes.
- macOS: notarized .dmg (or Mac App Store build) with the same update check.
- Android: Play Store (internal → closed → production tracks), in-app updates.
- Web: deploy on Cloudflare Pages / Firebase Hosting with the required COOP/COEP headers for PowerSync web if needed; cache-busting.
- Local-schema migrations: versioned, tested upgrade path from every released version.
- Release checklist docs/release.md; changelog shown in-app in all three languages.
```

## Step 6.8 — Nice-to-haves (pick by customer demand)

- Voice/number-pad fast entry for munshi (weights and rates).
- Digital weighbridge integration (serial/USB) to auto-fill qty.
- Buyer (exporter/miller) ledgers and buyer-side billing (kacha/pakka aadhat bills).
- Mandi rate feed (Agmarknet) on dashboard.
- Farmer self-service link: read-only statement page with OTP.
- Dark mode.
- Multi-branch (one owner, many shops) consolidated reports.

## Phase 6 exit criteria

- [ ] Receipts/statement reach farmers on WhatsApp automatically.
- [ ] A shop with 5 seasons of data runs smoothly on a low-end Android phone.
- [ ] Updates roll out to all platforms without data loss.
