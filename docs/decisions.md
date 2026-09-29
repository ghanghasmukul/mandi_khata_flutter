# Decisions log

| Date | Decision | Reason |
|---|---|---|
| 2026-09-26 | Backend: Supabase (Postgres, RLS, Auth, Edge Functions, Storage, Mumbai region) + PowerSync for offline sync | Relational ledger data; SQL reports; RLS multi-tenancy; Firebase on Windows is dev-only; Firestore offline is a cache only |
| 2026-09-26 | Flutter for Windows, Android, Web from one codebase | One team, one codebase |
| 2026-09-26 | Money stored as integer paise; ledger append-only | Correctness, auditability, conflict-free sync |
| 2026-09-26 | Interest default appropriation = interest_first; interest only on NET udhaar; surplus jama carried forward | Mandi practice; fixes prototype bug (farmers we owe were charged interest) |
| 2026-09-26 | Party net position = khata balance only (no adding shop dues on top) | Fixes prototype double counting |
| 2026-09-26 | Claude Code accesses only the dev Supabase project; prod via approved GitHub Actions | Safety |
| 2026-09-29 | Add macOS as a shipped desktop target alongside Windows | Development happens on a Mac, so macOS/Android/Web build and run locally; Windows stays the primary shop-counter platform, built on a Windows machine or the `windows-latest` CI runner |
