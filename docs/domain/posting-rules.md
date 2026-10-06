# Posting rules: how every document becomes double-entry journal lines

**Status: APPROVED 2026-10-05 (owner: "go with the recommendations" for Q1-Q8; section 4 not objected to).** Section 9 records the decisions. Once approved this file is the specification; if a rule changes later, change this file first, then the code, then add a line to `docs/decisions.md`.

The party khata (phase 1) stays the user-facing ledger. Under it, every business document also writes a **balanced journal entry** in the same local transaction, so the books always tally.

## 1. Principles

1. **One document, one journal entry** (plus a mirrored reversal entry if the document is reversed). The journal entry points at its source (`source_type`, `source_id`) and carries the same `entry_date` as the khata entry.
2. **Σ debit = Σ credit** for every journal entry: checked in `khata_core` `JournalBuilder` (throws) and on the server (deferred constraint trigger, rejects the upload).
3. **Money is `int` paise**; each line has a debit or a credit (exactly one is non-zero). Lines are never netted away: a posting with 6 charge lines has 6 + 2 journal lines.
4. **Append-only like the ledger.** A journal entry is never updated or deleted. A correction is a reversal entry (same lines, debit and credit swapped, same date as the reversal of the document) plus a new entry.
5. **Party accounts mirror the khata.** Every party has one account; for every party, `Σ debit − Σ credit` on its account equals minus its khata balance (`Σ jama − Σ udhaar`), on every date. This is a tested invariant (phase 1's "every balance equals the ledger sum" extends to the books).
6. **Cash and bank accounts mirror the cash / bank book** (`cash_bank_entries`): for each bank account, `Σ debit − Σ credit` = `Σ in − Σ out`.
7. **Deterministic ids.** Journal entry and line ids are UUID v5 of tenant + source key (+ line index), so a re-run or the same posting on two devices never writes twice, and the back-fill (section 7) is idempotent.
8. **Offline first.** The journal is built on the device in the same transaction as the document; the server only validates balance and basic integrity (section 8).

## 2. Chart of accounts (seeded per business, editable)

Groups follow Tally. `nature`: asset / liability / income / expense. Capital is a liability-side group.

| Group | Parent | Nature | Holds |
|---|---|---|---|
| Capital Account | none | liability | Opening Balance Equity, Capital, Profit & Loss (3.5) |
| Current Assets | none | asset | parent group |
| Sundry Debtors | Current Assets | asset | party accounts of buyers / customers |
| Cash-in-hand | Current Assets | asset | the Cash account |
| Bank Accounts | Current Assets | asset | one account per bank account |
| Stock-in-hand | Current Assets | asset | shop stock (phase 4) |
| Loans & Advances (Asset) | Current Assets | asset | manual accounts only (see Q3) |
| Current Liabilities | none | liability | parent group |
| Sundry Creditors | Current Liabilities | liability | party accounts of farmers / suppliers / vendors / agencies |
| Duties & Taxes | Current Liabilities | liability | Mandi Fee Payable, Cess Payable, GST (phase 4) |
| Direct Income | none | income | commission and charges recovered |
| Indirect Income | none | income | interest |
| Direct Expenses | none | expense | own-cost mandi charges, COGS (phase 4) |
| Indirect Expenses | none | expense | expenses (3.4), interest waived |

System accounts (`is_system = true`: cannot be deleted or change group, may be renamed):

| Account | Group | Used for |
|---|---|---|
| Cash | Cash-in-hand | the Cash `bank_accounts` row |
| *each bank account* | Bank Accounts | created with the bank account |
| *each party* | Sundry Debtors or Creditors | created with the party (rule in Q2) |
| Commission Income | Direct Income | arhat commission on lots |
| Palledari Receipts | Direct Income | palledari recovered on lots |
| Bardana Receipts | Direct Income | bardana recovered on lots |
| Tulai Receipts | Direct Income | tulai recovered on lots |
| Interest Income | Indirect Income | interest posted to the khata |
| Mandi Fee Payable | Duties & Taxes | mandi fee collected, owed to the market committee |
| Cess Payable | Duties & Taxes | cess collected (each cess is its own journal line, narration = its name) |
| Mandi Fee (own cost) | Direct Expenses | mandi fee the arhtiya bears |
| Cess (own cost) | Direct Expenses | cess the arhtiya bears |
| Interest Waived | Indirect Expenses | interest discounted in a hisaab |
| Lot Sale Clearing | Current Assets | a posted lot that has no buyer yet |
| Khata Adjustments | Current Liabilities | manual khata entries (counter side) |
| Opening Balance Equity | Capital Account | opening balances |

## 3. Tables (step 3.1)

`account_groups(id, tenant_id, name, parent_id, nature, is_system)`, `accounts(id, tenant_id, group_id, name, party_id null, bank_account_id null, is_system, is_active)`, `journal_entries(id, tenant_id, voucher_id null, source_type, source_id, entry_date, narration, reverses_id null, device_id, created_by, created_at)` and `journal_lines(id, tenant_id, journal_entry_id, account_id, debit_paise, credit_paise)`. `voucher_id` stays empty until step 3.2 (vouchers). All append-only, tenant-scoped, RLS like `ledger_entries`; account and group rows are master data (soft switch-off with `is_active`, never deleted if they have lines).

## 4. The mapping

`P` = the party's account. `Cash/Bank` = the account of the payment's bank account. Dates are the document's `entry_date` unless stated. "Both" = always posted together with the khata entry in the same transaction.

| # | Document (`ref_type`) | Khata entry today | Journal lines (Dr / Cr) |
|---|---|---|---|
| 1 | **Lot posted** (`arrival`) | Jama farmer = net; Udhaar buyer = gross + buyer-borne charges | Dr **Buyer P** (gross + buyer-borne charges). Cr **Farmer P** (net to farmer). Cr **Commission Income** (commission, when charged to farmer or buyer). Cr **Palledari / Bardana / Tulai Receipts** (each charge the farmer or buyer bears). Cr **Mandi Fee Payable** (mandi fee, when farmer or buyer bears it). Cr **Cess Payable** (one line per cess, same rule). Arhtiya-borne mandi fee / cess: Dr **Mandi Fee / Cess (own cost)** and Cr the matching **Payable**. Arhtiya-borne palledari, bardana, tulai and waived commission: **no line** (the cost appears when it is paid, step 3.4). Zero lines are not written. No buyer: the Dr side is **Lot Sale Clearing** for the gross |
| 2 | **Payment to party** (`payment`, `to_party`) | Udhaar party | Dr **P**, Cr **Cash/Bank** |
| 3 | **Receipt from party** (`receipt`, `from_party`) | Jama party | Dr **Cash/Bank**, Cr **P** |
| 4 | **Cheque pending** | posts at once | as 2 or 3 (the bank account is debited / credited at once, as the cash / bank book does today) |
| 5 | **Cheque cleared** | no money change | **nothing** (reconciliation, 3.3, marks it) |
| 6 | **Cheque bounced** | reversal dated the bounce date | reversal of 2 / 3: same lines swapped, **dated the bounce date** |
| 7 | **Payment / receipt reversed** | reversal dated like the payment | reversal of 2 / 3, dated like the payment |
| 8 | **Loan disbursal** (`loan_disbursal`) | Udhaar party | Dr **P**, Cr **Cash/Bank** (see Q3: the borrower's party account, not a separate receivable) |
| 9 | **Loan repayment, cash / bank** (`loan_repayment`) | Jama party | Dr **Cash/Bank**, Cr **P** |
| 10 | **Loan repayment from crop proceeds** | Jama (`loan_repayment`) + Udhaar (`journal`), same party | **No journal entry**: both sides are the same account, so it nets to nothing (the invariant of principle 5 still holds) |
| 11 | **Interest posted** (`interest`) | Udhaar party | Dr **P**, Cr **Interest Income** |
| 12 | **Interest waived** (waiver `journal`, jama) | Jama party | Dr **Interest Waived**, Cr **P** (see Q4) |
| 13 | **Manual khata entry** (`journal`) | Udhaar or Jama party | Udhaar: Dr **P**, Cr **Khata Adjustments**. Jama: Dr **Khata Adjustments**, Cr **P** (see Q6). Replaced by a real counter account when vouchers arrive (3.2) |
| 14 | **Opening balance** (`opening_balance`) | Udhaar or Jama party | Udhaar: Dr **P**, Cr **Opening Balance Equity**. Jama: Dr **Opening Balance Equity**, Cr **P** |
| 15 | **Any reversal** (`reversal`) | mirrored entry | mirrored journal entry (`reverses_id`), lines swapped, same date as the khata reversal |
| 16 | **Lot reversed / cancelled** | every entry reversed | mirrored journal entry of row 1; a cancelled open lot posted nothing, so writes nothing |

Later phases (not built in 3.1, listed so the chart is complete): expenses (3.4) Dr expense account / Cr Cash/Bank; shop sale, return, purchase (phase 4) Dr/Cr party, sales, GST, stock and COGS accounts; rules for those are added to this file before their steps.

## 5. Worked examples (paise in the tests; rupees here)

**Lot 1: Wheat, 18 bags, 8.64 qtl at 2,425, all charges borne by the farmer, buyer picked.** gross 20,952.00; commission 2.5% = 523.80; palledari 216.00; bardana 144.00; tulai 25.92; mandi fee 1% = 209.52; net to farmer 19,832.76.

| Account | Dr | Cr |
|---|---|---|
| Buyer P | 20,952.00 | |
| Farmer P | | 19,832.76 |
| Commission Income | | 523.80 |
| Palledari Receipts | | 216.00 |
| Bardana Receipts | | 144.00 |
| Tulai Receipts | | 25.92 |
| Mandi Fee Payable | | 209.52 |
| **Total** | **20,952.00** | **20,952.00** |

**Lot 2: same lot, but the buyer bears the palledari.** Buyer is billed 20,952.00 + 216.00 = 21,168.00; farmer net 20,048.76 (= 20,952.00 − 523.80 − 144.00 − 25.92 − 209.52).

| Account | Dr | Cr |
|---|---|---|
| Buyer P | 21,168.00 | |
| Farmer P | | 20,048.76 |
| Commission Income | | 523.80 |
| Palledari Receipts | | 216.00 |
| Bardana Receipts | | 144.00 |
| Tulai Receipts | | 25.92 |
| Mandi Fee Payable | | 209.52 |
| **Total** | **21,168.00** | **21,168.00** |

**Payment** of 5,000.00 cash to the farmer: Dr Farmer P 5,000.00 / Cr Cash 5,000.00. **Loan** of 50,000.00 by SBI: Dr Borrower P 50,000.00 / Cr SBI 50,000.00. **Interest** 4,931.51 posted: Dr P 4,931.51 / Cr Interest Income 4,931.51; **waiver** 931.51 of it: Dr Interest Waived 931.51 / Cr P 931.51.

## 6. Reversals, dates, permissions

- A reversal journal entry is created by the same code that reverses the khata entry, in the same transaction, with the **same date as that reversal** (a bounced cheque: the bounce date). It is never reversed itself.
- Posting a journal entry needs the same permission as the document that causes it (`arrivals.manage`, `payments.create`, `loans.manage`, `entries.reverse`…). There is no way to post a bare journal entry before step 3.2 (voucher entry); that screen will need `entries.reverse`.
- Back-dating rules (`business.backdate_days`) apply to the document, and the journal entry copies its date, so it needs no separate rule.
- Reading journal and accounts needs `finance.view`; party accounts sync to every member who sees the party (a munshi sees no bank or profit accounts, as today for bank accounts).

## 7. Back-fill of existing data

Businesses that already have lots, payments, loans, interest and opening balances get their journal entries from an **idempotent on-device job** (deterministic ids, section 1.7) that reads the existing documents and writes what section 4 says, once, in batches of 25 documents per transaction, owner-triggered after the upgrade with a progress screen (also runs automatically for a business with no journal entries yet). Lots are re-derived from their stored `charges_snapshot`, so the amounts are exactly what was posted. Afterwards the invariants of principles 5 and 6 are checked and any difference is listed, never silently fixed. The job needs `entries.reverse`.

## 8. What the server enforces and what it does not

- Enforced: every journal entry balances (deferred trigger), lines have exactly one of debit / credit, tenant consistency (composite foreign keys), append-only, device ownership, and the same RLS permission model as the ledger.
- **Not** enforced on the server: that the journal matches the source document (the server cannot recompute a lot's charges or a payment's bank account cheaply). The app is the only writer; the invariant checks in the app and the phase review catch drift. See Q8.

## 9. Decisions I need from you (please answer each)

| Q | Question | My recommendation |
|---|---|---|
| Q1 | Palledari, bardana and tulai recovered from the farmer / buyer: book them as **income** (Receipts accounts) with the real labour cost as an **expense** when paid, or as a **liability** (labour payable) that is cleared when you pay the labourers? | Income + expense: simpler for an arhtiya, the profit shows the margin. Mandi fee and cess are always liabilities (owed to the committee) |
| Q2 | Which group does a party account go in? | Sundry **Debtors** if the party is a customer or buyer (also when it has both kinds of role), else Sundry **Creditors** (farmer, supplier, vendor, agency). The balance sheet (3.5) shows a debit balance as an asset and a credit balance as a liability whatever the group |
| Q3 | Loans: debit the **borrower's party account** (keeps "party accounts = khata balances" true), or a separate "Karza receivable" account? | Party account. The loans table already tracks each loan, and a loan report can sum them. The "Loans & Advances" group remains for manual accounts |
| Q4 | Interest waiver: **expense** (Interest Waived) or reduce Interest Income? | Expense, so income shows what was charged and the discount is visible |
| Q5 | A lot posted **without a buyer** (allowed when no charge is buyer-borne): debit **Lot Sale Clearing** until the buyer is known? | Yes. The clearing account is cleared when the buyer is added in a later step (a report lists open clearing items) |
| Q6 | Manual khata entries have only the party side: counter side **Khata Adjustments** (a suspense liability) until step 3.2 lets the user choose an account? | Yes |
| Q7 | Opening balances: counter side **Opening Balance Equity**, closed into capital at year-end (3.5)? | Yes |
| Q8 | Server enforces only "journal balances" (section 8), not "journal matches the document"? | Yes for now; revisit before phase 5 (SaaS) |

Anything not answered I will implement as recommended above. Please also say if any row of section 4 is wrong for how your arhtiyas actually keep their books (for example the commission on the buyer's side, or mandi fee borne by the buyer).

## 10. As built (step 3.1)

- **Core.** `khata_core` `AccountGroup`, `SystemAccount`, `JournalBuilder` (throws `JournalError` unless balanced, at least two lines, every line above zero), `JournalEntryDraft.reversal()` and `PostingRules` (one function per row of section 4). The SQL seed and the Dart enums are kept equal by `chart_consistency_test`.
- **Ids.** UUID v5 (namespaces in `JournalWriter` and `private.chart_id`), asserted equal in Dart and in pgTAP 16. The app never creates account rows: the server creates groups and system accounts with the business, a party account when the party row arrives (group moved by its roles), a book account with each cash / bank account. Journal lines only need the ids.
- **Where it is written.** Lots (`LotsRepository.save` when it posts), payments and loan disbursal / cash repayment (`PaymentsRepository.saveIn`), interest and waivers (`InterestPostingRepository`), manual entries and opening balances (`LedgerRepository.post`), and every reversal or edit (`LedgerRepository.reverseIn` / `correct`: the journal entry behind the reversed khata entry is mirrored on the reversal's date). A lot's two khata entries share one journal entry, mirrored once.
- **Server.** Tables `account_groups`, `accounts`, `journal_entries`, `journal_lines` (append-only entries and lines; lines may only join an entry written in the same transaction; deferred balance and mirror check). Read needs `finance.view` (plus a member's own rows, so uploads with `ON CONFLICT DO NOTHING` pass); posting needs the permission of the document (`lot` arrivals.manage, `payment` payments.create, `interest` loans.manage, anything else entries.reverse). The journal tables sync to owners and accountants only (`finance_data` stream); a munshi's journal rows upload but are not downloaded back, like the cash book of banks.
- **Back-fill.** `JournalBackfill` (screen `/accounts/books`, dashboard link for `entries.reverse`) writes entries for lots, payments, interest, waivers, manual entries and opening balances that have none, then their reversals; idempotent, 25 documents per transaction, problems listed and never silently fixed. A test deletes the whole journal of a busy day and checks the back-fill rebuilds identical entries.
- **Checks.** `BooksInvariants`: unbalanced entries, party accounts vs khata balances, cash / bank accounts vs the cash book; shown on the books screen and asserted after every scenario in `journal_integration_test`.
- **Not built yet (later steps).** `voucher_id` stays empty until 3.2; the cash book (3.3), expenses (3.4) and statements (3.5) read these tables.


## 11. Phase 3 additions (steps 3.2-3.6)

Written before the code of each step; the owner approved "complete phase 3 in one go" on 2026-10-06 and the choices below follow the recommendations of section 9. Anything marked **(decision)** is also in `docs/decisions.md`.

### 11.1 More chart rows (seeded with 3.2, same UUID v5 rules)

| Group | Parent | Nature |
|---|---|---|
| Sales Accounts | none | income |
| Purchase Accounts | none | expense |

| System account | Group | Used for |
|---|---|---|
| Sales | Sales Accounts | sales vouchers (F7); the shop (phase 4) |
| Purchase | Purchase Accounts | purchase vouchers (F8); the shop (phase 4) |
| Capital | Capital Account | the owner's capital; year close moves Opening Balance Equity here |
| Profit & Loss A/c | Capital Account | year close moves each year's profit or loss here |
| Cash Short / Excess | Indirect Expenses | the difference found by a cash count (3.3) |

Businesses may add their own accounts (name + group, `entries.reverse`). A client may never create an account that owns a party, a bank account or a system code: those are created by the server only.

### 11.2 Vouchers (3.2)

`vouchers(id, tenant_id, voucher_type, voucher_no, entry_date, narration, total_paise, status posted | reversed, reversed_at, device_id, …)`; its journal entry is `source_type = voucher`, `source_key = voucher:<id>`, `voucher_id = <id>`.

| Type | Key | Rule (khata_core `VoucherRules`) | Default lines |
|---|---|---|---|
| Contra | F4 | every line is a cash / bank account; at least one debit and one credit | Dr bank, Cr cash |
| Payment | F5 | at least one **credit** on a cash / bank account; no debit on one | Dr party / expense, Cr cash or bank |
| Receipt | F6 | at least one **debit** on a cash / bank account; no credit on one | Dr cash or bank, Cr party / income |
| Sales | F7 | at least one credit on a Sales Accounts account | Dr party (or cash), Cr Sales |
| Purchase | F8 | at least one debit on a Purchase Accounts account | Dr Purchase, Cr party (or cash) |
| Journal | F9 | no cash / bank account (Tally's rule) | any |

All types: at least two lines, every line above zero, Σ Dr = Σ Cr, the same account at most once per side, no account that is switched off. Numbers per type and device: `CV-` contra, `PY-` payment, `RC-` receipt, `SV-` sales, `PU-` purchase, `JV-` journal (`business.number_series.<type>_voucher`).

Side effects, in the **same transaction** as the voucher and its journal entry:
- a line on a **party** account also writes that party's khata entry (`ref_type = voucher`, `ref_id` = voucher; Dr = udhaar, Cr = jama, one entry per party line), so principle 5 keeps holding;
- a line on a **cash / bank** account writes a cash / bank book line (`cash_bank_entries.voucher_id`; Dr = in, Cr = out), so principle 6 keeps holding.

Posting needs `entries.reverse` (owner / accountant, posting-rules section 6); a cash / bank line on a bank account also needs `finance.view` (book-line rule of 1.5). Back-dating follows `business.backdate_days`. A voucher is frozen once posted; **reversing** it (`entries.reverse`) reverses every khata entry and book line it wrote and mirrors its journal entry, all dated like the voucher, and marks it `reversed`. The khata screen does not reverse a voucher's khata line on its own.

The **day book** (accounts) lists every journal entry of a date range (vouchers and documents), with drill-down to the lines; only vouchers are reversed there, other documents through their own screen.

### 11.3 Cash book, bank book, reconciliation, cash count (3.3)

- The cash / bank book of an account = its `cash_bank_entries` (payments, vouchers, expenses). Opening = Σ in − Σ out before the period; then receipts (in), payments (out), closing, and a total per day. A munshi sees the cash book only.
- **Bank statement import**: CSV / XLSX through `SheetReader`; the column mapping (date, description, reference, debit, credit or one signed amount, balance; date format) is saved per bank account (`bank_accounts.statement_mapping`) and offered next time. Lines go to `bank_statement_lines` (deterministic ids per account + date + amount + reference + row text, so importing the same file twice adds nothing).
- **Auto-match** (khata_core `BankReconciliation`): a statement line matches an unreconciled book line of the same account with the same direction and amount, dated within ±3 days; when a reference (UTR, cheque no.) is on both, it must agree, and a matching reference wins over the closest date. Each line matches at most once; ties go to the closest date, then the oldest line. Manual match pairs any one statement line with one book line of the same amount and direction.
- **Reconciled**: `bank_reconciliations(book_line_id, statement_line_id null, reconciled_on)`; un-reconcile = soft delete (`deleted_at`). A reversed book line and its reversal may be reconciled together without a statement line.
- **Dashboard**: bank book lines older than 7 days with no reconciliation show in "Needs you today" (finance members).
- **Cash count** at day close (optional): denominations × count; difference = counted − cash book closing. A non-zero difference is posted (owner / accountant) as a **journal voucher** generated by the count: excess = Dr Cash / Cr Cash Short / Excess; short = Dr Cash Short / Excess / Cr Cash (a journal voucher may use Cash here because the count makes it, not the user). The count row stores the denominations and the voucher id.

### 11.4 Expenses (3.4)

- `expense_categories` (seeded: palledari, transport, salary, bardana, mandi charges, electricity, rent, misc; editable, switched off not deleted). Each category has its own expense account created by the server (`chart_id(tenant, 'expense', category_id)`), in **Direct Expenses** (palledari, transport, bardana, mandi charges) or **Indirect Expenses** (the rest; the user picks for new ones).
- An expense (`expenses`: `EX-` number, date, category, amount, mode cash | bank, bank account, paid to, narration, bill path) posts **Dr expense account / Cr Cash or bank** (journal `source_type = expense`) and one book line (`cash_bank_entries.expense_id`), same transaction. Needs `payments.create` (+ `finance.view` for bank), back-date rule as usual; reversal needs `entries.reverse`.
- **Bill photo**: stored on the device and uploaded to Supabase Storage (`bills/<tenant>/<expense id>/<file>`) when online; the expense row carries the path from the start. Upload failures retry; the expense never waits for the photo.
- **Recurring** (`recurring_expenses`: category, amount, mode, account, paid to, day of month, from, until): the screen lists what is due (each month from `from` until today) and posts it with one click; the expense id is UUID v5 of template + month, so two devices never post a month twice. No automatic posting (same as interest).

### 11.5 Statements and year close (3.5)

- **Trial balance** (as of a date): every account's Σ Dr and Σ Cr up to the date; closing Dr or Cr balance; group level sums the accounts of each group and its sub-groups. Σ Dr balances = Σ Cr balances always (the journal balances).
- **Profit & Loss** (period): income groups (Sales Accounts, Direct Income, Indirect Income) minus expense groups (Purchase Accounts, Direct Expenses, Indirect Expenses) over the period, **without year-close entries**. Gross profit = direct income + sales − purchases − direct expenses; net profit = gross + indirect income − indirect expenses.
- **Balance sheet** (as of a date): assets and liabilities by group; a party or other account in a group of one nature with a balance of the other side is shown on the other side ("Sundry Debtors with credit balance" goes to liabilities). Profit not yet closed (every income / expense balance to that date) is shown in the Capital section as "Profit & Loss (current)", so assets = liabilities + capital.
- **Ledger** of any account (period, opening, lines with running balance) and **group summary** (accounts of a group with balances).
- **Year close (decision)**: the khata is cumulative, so closing does **not** post carry-forward khata entries (a closing jama plus an opening udhaar would restart grace tranches and change interest). Instead, for FY *Y*: (1) optional interest run up to 31 March; (2) the books must tally (`BooksInvariants`); (3) one **closing journal entry** dated 31 March (`source_type = year_close`) moves every income and expense account's balance for the year to **Profit & Loss A/c** and the balance of **Opening Balance Equity** to **Capital**; (4) `financial_years` row → `closed` with the lock. Opening balances of the next year are the closing balances (reports compute them). Re-opening is not offered in v1.
- **Lock**: entries dated inside a closed financial year need the **owner** and a written **reason** (stored on the journal entry as `lock_reason` and in the audit row). The server rejects a khata entry, journal entry, payment, voucher, expense or book line dated in a closed year unless the uploader is an owner, and a journal entry there without a reason.

### 11.6 Tally export (3.6)

- Masters: one Tally ledger per account used in the period, with its parent group mapped to a Tally reserved group (defaults below; the business can change the mapping, setting `tally.group_map`). Ledger names must be unique in Tally: duplicates get the party code appended (`Gurmeet Singh (P-W1-0001)`).
- Vouchers: one per journal entry in the range. Type: lines only on cash / bank → Contra; a cash / bank account credited → Payment; debited → Receipt; else the voucher's own type (sales, purchase) or Journal. Reversals export as their own voucher with the lines swapped. Amounts: Tally's sign convention (debit negative, `ISDEEMEDPOSITIVE` Yes).
- Validation report before export: unmapped groups, names Tally refuses (empty, over 99 characters), duplicate names resolved, entries that do not balance (none expected), accounts referenced but not synced yet.

| Our group | Tally group |
|---|---|
| Capital Account | Capital Account |
| Current Assets | Current Assets |
| Sundry Debtors | Sundry Debtors |
| Cash-in-hand | Cash-in-Hand |
| Bank Accounts | Bank Accounts |
| Stock-in-hand | Stock-in-Hand |
| Loans & Advances (Asset) | Loans & Advances (Asset) |
| Current Liabilities | Current Liabilities |
| Sundry Creditors | Sundry Creditors |
| Duties & Taxes | Duties & Taxes |
| Direct Income | Direct Incomes |
| Indirect Income | Indirect Incomes |
| Direct Expenses | Direct Expenses |
| Indirect Expenses | Indirect Expenses |
| Sales Accounts | Sales Accounts |
| Purchase Accounts | Purchase Accounts |
