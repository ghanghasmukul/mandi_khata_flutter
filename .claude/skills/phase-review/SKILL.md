---
name: phase-review
description: Review a finished phase against its exit criteria and CLAUDE.md rules before moving to the next phase. Use at the end of each phase.
argument-hint: [phase number]
disable-model-invocation: true
---

Review phase $ARGUMENTS (default: the latest phase whose steps are all ticked in `docs/PROGRESS.md`).

1. Read the phase file's **Exit criteria** in `docs/phases/`.
2. For each criterion: prove it with a test, a command output, or a script. Where something can only be proven manually (e.g. printing on a real printer, two physical devices), write exact manual test instructions for the user instead.
3. Use a subagent to do an independent code review of the phase's changes (`git diff` from the phase's first commit) focused on: money correctness, tenant isolation, offline behaviour, sync conflicts, permissions, missing tests. The subagent should not have written the code.
4. Run `/verify full`.
5. Run Supabase advisors (security and performance) on dev via MCP.
6. Write `docs/reviews/phase-$ARGUMENTS.md`: criteria table (pass / fail / manual), review findings with severity, fixes applied, open items.
7. Fix all high-severity findings. List the manual checks the user must do, then tick the exit criteria in `docs/PROGRESS.md` only when proven.
