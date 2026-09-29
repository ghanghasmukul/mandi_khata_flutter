---
name: next-step
description: Build the next unchecked step from docs/PROGRESS.md end to end (plan, implement, verify, update progress). Use when the user says "next step", "continue", or "carry on building".
argument-hint: [optional step id, e.g. 1.3]
disable-model-invocation: true
---

You are building Mandi Khata step by step.

1. Read `CLAUDE.md`, `docs/PROGRESS.md` and `docs/decisions.md` (if it exists).
2. Pick the step: if `$ARGUMENTS` is given, use that step id; otherwise the FIRST unchecked `- [ ]` step in `docs/PROGRESS.md`. Do not skip ahead. If the previous phase's exit criteria are not all checked, stop and run the phase review instead.
3. Open the phase file for that step in `docs/phases/` and read the step's Prompt block. It is your task specification. Read every `docs/domain/*.md` file the step touches.
4. Write a short plan (5–10 bullets): files to create/change, tables/migrations, tests, anything you need from the user (keys, accounts, decisions). If you need something only the user can provide, ASK and stop.
5. Implement. Rules:
   - Schema changes ONLY as new files in `supabase/migrations/` (`supabase migration new <name>`), applied locally with `supabase db reset`. Never change schema with ad-hoc SQL.
   - Business maths goes in `packages/khata_core` with tests written first.
   - Follow every rule in CLAUDE.md (tenant_id, paise, append-only ledger, offline-first, settings cascade, audit, i18n).
6. Verify: run the `/verify` checklist (format, analyze, tests, supabase tests, builds relevant to the step). Fix everything until green.
7. If the step touched the database, run the Supabase advisors on the dev project via MCP (security + performance) and fix findings, or record why not in `docs/decisions.md`.
8. Update `docs/PROGRESS.md`: tick the step `- [x]`, add today's date and a one-line note. Record any new business decision in `docs/decisions.md`.
9. Stage changes with `git add -A` and propose a Conventional Commit message (e.g. `feat(khata): step 1.4 khata screens`). Ask before committing.
10. Finish with: what was built, how the user can test it manually (exact commands / clicks), and what the next step is. Recommend `/clear` before the next step.
