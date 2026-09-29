# Phase 3 — Accounting (vouchers, books, P&L)

**Goal:** the accountant can close the books: double-entry vouchers behind every business entry, day book, cash and bank books, expenses, trial balance, P&L, balance sheet, and export to Tally.

Design principle: party khata (Phase 1) stays the user-facing ledger. Under the hood every posting also creates balanced double-entry journal lines, so accounts always tally.

---

## Step 3.1 — Chart of accounts & journal

**Prompt**
```
Add double-entry accounting.
Tables: account_groups (Tally-like: Capital, Current Assets, Current Liabilities, Sundry Debtors, Sundry Creditors, Cash-in-hand, Bank Accounts, Direct/Indirect Income, Direct/Indirect Expenses, Loans & Advances (Asset), Duties & Taxes, Stock-in-hand), accounts (id, tenant_id, group_id, name, party_id nullable — every party auto-gets an account, is_system), journal_entries (id, tenant_id, voucher_id, entry_date, narration), journal_lines (id, journal_entry_id, account_id, debit, credit).
khata_core: JournalBuilder with an invariant check Σdebit = Σcredit (throw otherwise) + tests.
Supabase: constraint/trigger that rejects unbalanced journal entries (deferred check).
Seed a default chart of accounts per tenant on creation (editable).
Back-fill: every existing Phase 1/2 document type (lot posting, payment, receipt, loan disbursal/repayment, interest posting) must now also produce journal lines — write a mapping table in docs/domain/posting-rules.md FIRST, show it to me, then implement it in each posting service and add tests.
```

## Step 3.2 — Voucher entry (Tally/Busy style)

**Prompt**
```
Voucher entry screen, keyboard-first like Tally:
F4 Contra, F5 Payment, F6 Receipt, F7 Sales, F8 Purchase, F9 Journal (desktop shortcuts; buttons on mobile).
Fields: date, voucher no (series per type), Dr/Cr lines with account search, amount, narration; defaults per type (Payment: Dr party / Cr cash-bank …).
Enter moves to next field; Ctrl+Enter saves; Esc cancels. Shows running difference until balanced.
Vouchers affecting a party also write the party's ledger_entries in the same transaction.
Day book: all vouchers for a date/range, drill-down to voucher, reverse (permission-gated).
```

## Step 3.3 — Cash book, bank book, reconciliation

**Prompt**
```
Cash book and bank book per account (opening, receipts, payments, closing, daily totals).
Bank reconciliation: import bank statement CSV/XLSX (map columns once, remember per bank), auto-match by amount+date±3 days+reference (UTR/cheque no), manual match, mark reconciled with date; show unreconciled items on the dashboard.
Cash denomination count at day close (optional) with difference posting.
```

## Step 3.4 — Expenses

**Prompt**
```
Expenses: categories (palledari, transport, salary, bardana, mandi charges, electricity, rent, misc — editable), expense entry (date, category, amount, mode, paid to, bill photo attachment → Supabase Storage with offline queue), recurring expenses (monthly salary), expense report by category/month.
Each expense posts journal lines (Dr expense account / Cr cash-bank).
```

## Step 3.5 — Financial statements & year close

**Prompt**
```
Reports: Trial balance (as of date, group/ledger level), Profit & Loss (period), Balance sheet (as of date), Ledger report for any account, Group summary.
Financial year: FY list (Apr–Mar), year-end close process: post interest (optional run), carry forward closing balances as opening balances of the new FY (as opening_balance entries + journal), lock the old FY (entries before lock date need owner + reason).
All reports offline, exportable to PDF/XLSX.
```

## Step 3.6 — Tally export

**Prompt**
```
Export to Tally Prime: generate Tally XML (masters: ledgers with groups; vouchers: payment, receipt, journal, sales, purchase, contra) for a date range, with a mapping screen for account groups. Include a validation report of anything that cannot be mapped. Document how the accountant imports it in Tally (docs/tally-import.md).
```

## Phase 3 exit criteria

- [ ] Trial balance always tallies (automated check on every sync + a test that fuzzes random postings).
- [ ] Party khata balance = that party's account balance in the journal.
- [ ] An accountant can export a month to Tally and it imports without errors.
