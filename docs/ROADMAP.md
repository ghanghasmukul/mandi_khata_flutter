# Mandi Khata — build roadmap

| Phase | Name | Goal | Ships to customers? |
|---|---|---|---|
| 0 | Foundation | Monorepo, Supabase + PowerSync + auth + tenancy + settings + design system, proven offline sync on Windows/macOS/Android/Web | No (internal) |
| 1 | Core Mandi Khata (MVP) | Parties, crops, arrivals & lots, khata, payments, receipts, basic reports, roles, audit | **Yes — pilot with 2–3 arhtiyas** |
| 2 | Karza & Byaj | Configurable interest engine, loans, interest statements, posting, overdue alerts | Yes |
| 3 | Accounting | Vouchers, day book, cash/bank book, expenses, trial balance, P&L, Tally export | Yes |
| 4 | Input shop | Products, batches, purchases, POS, returns, payables/receivables, shop profit, GST invoice | Yes (add-on module) |
| 5 | SaaS layer | Plans, Razorpay subscriptions, module gating, trial/grace/lock, super-admin panel, tenant onboarding | Yes — public launch |
| 6 | Polish & scale | WhatsApp, thermal printing, barcode, backup/restore, data import, performance, Play Store / MSIX / web deploy | Yes |

## Building the whole project with Claude Code

Claude Code writes all the code, migrations, tests and CI. Your job: accounts and keys, approving risky actions, testing on real devices, and talking to customers.

### What's in this package

| Path | What it does |
|---|---|
| `CLAUDE.md` | Project rules. Claude Code reads it automatically at the start of every session. |
| `.mcp.json` | Connects Claude Code to your **dev** Supabase project (Supabase MCP). |
| `.claude/settings.json` | Pre-approves safe commands (analyze, test, local DB); asks before commits, pushes, migrations on dev and function deploys; blocks prod. |
| `.claude/skills/` | Your slash commands: `/next-step`, `/verify`, `/new-table`, `/sync-check`, `/phase-review`. |
| `docs/SETUP.md` | One-time setup: tools, Supabase, connecting Claude to Supabase and Flutter. |
| `docs/PROGRESS.md` | The checklist Claude works through and ticks off. |
| `docs/phases/*.md` | Detailed spec + prompt for every step. |
| `docs/domain/*.md` | Business rules (interest, ledger, charges, settings). The source of truth for money logic. |
| `design/Mandi_Khata.html` | Visual reference. |

### The loop (repeat for every step)

```
cd ~/dev/mandi_khata
claude
> /next-step
```
1. Claude picks the next unchecked step in `docs/PROGRESS.md`, reads its spec and the domain rules, and shows a plan. For big steps, press **Shift+Tab** to switch to plan mode first, read the plan, then approve.
2. Claude builds it, runs `/verify`, fixes failures, checks the Supabase advisors, and ticks the step.
3. **You** run the app (`flutter run -d macos`, Android emulator, Chrome — plus `-d windows` on a Windows machine before shipping) and click through what Claude says to test.
4. Approve the commit Claude proposes.
5. Type `/clear`, then `/next-step` again. Memory lives in the files, not in the chat, so clearing is safe and keeps Claude sharp.

At the end of each phase: `/phase-review <n>`. An independent reviewer checks the phase, fixes the serious issues, and lists the manual tests for you. Don't start the next phase until its exit criteria are ticked.

### When to step in

- Steps marked 🧑 in `PROGRESS.md` need you (accounts, API keys, real devices, customers, pricing decisions).
- Claude asks before: `git commit/push`, applying a migration to dev, running SQL on dev, deploying Edge Functions. Read what it's about to do, then approve.
- Money logic: when Claude shows interest or charge calculations, check at least one example by hand or against a real arhtiya's register.
- Business decision changes (e.g. "interest-first should be default"): tell Claude to update `docs/domain/*.md` **first**, then the code. Record it in `docs/decisions.md`.

### Useful things to say to Claude

- "Continue" / `/next-step 1.4`: do a specific step.
- "Re-read CLAUDE.md and docs/domain/interest-engine.md and fix this": when it drifts from the rules.
- "Use the supabase MCP to check logs for errors in the last hour" / "run the security advisor".
- "Use a subagent to review the diff of this step for tenant-isolation bugs."
- "/new-table loan_guarantors link guarantors to loans".
- "/sync-check payments".

### Environments

| | Dev | Prod |
|---|---|---|
| Supabase project | `mandi-khata-dev` (Claude via MCP + CLI) | `mandi-khata-prod` (no Claude access) |
| Schema changes | `supabase db reset` locally → `supabase db push` to dev | GitHub Actions `deploy-db.yml` with your approval (Step 1.11) |
| App config | `.env.dev` | `.env.prod` (Claude is blocked from reading it) |
