# Importing from other systems (step 6.5)

Hub: Settings > Import data. Every import is **preview first** (nothing is
written until the person confirms; the preview is the dry run), then ONE
local transaction, then a **batch record** in the audit log. The owner can
roll a batch back in "Past imports".

## What each import does

| Source | Reads | Writes |
|---|---|---|
| Opening balances file (CSV / Excel / pasted) | party, role, village, mobile, amount + Dr/Cr | missing parties + one `opening_balance` entry each |
| **Tally XML** (masters and/or vouchers, one or several files, UTF-8 or UTF-16) | ledgers under Sundry Debtors / Sundry Creditors, their opening balance, address, mobile, and every voucher line on them | the same as the file import, with the party's **closing balance** as of the last voucher date |
| Products (CSV / Excel; Busy, Marg or any file with a header) | name (required), SKU / item code or barcode, unit, HSN, GST %, retail / wholesale price, brand, category, reorder level | products |
| Opening stock | existing (step 4) | batches + stock movements |

### Tally: balances, not history
Voucher lines are **summed into the balance**; they are not re-created as khata
entries. A party's khata starts with one opening entry (Tally opening + all
vouchers in the files). Why: the khata is append-only and every entry must
come with a journal entry and a back-dating permission; replaying thousands of
foreign vouchers cannot be proven right by us, while a balance can be checked
against Tally's trial balance. Cancelled and optional vouchers are ignored.
Tally sign: debit = negative = udhaar; credit = positive = jama. Debtors become
`customer`, creditors `supplier`. Other groups (cash, bank, income, expense)
are skipped and counted in the summary. History stays in Tally.

## Rules
- Nothing is guessed: a sign-less amount, an unknown unit, an invalid GST rate
  are row errors, not defaults. Bad rows are skipped; good rows import.
- Safe to repeat: the same file gives the same batch id and is refused the
  second time; ids are derived from the content (UUID v5), so two devices
  importing the same file land on the same rows.
- A change between preview and import (SKU taken, party got a balance) stops
  the whole import (`stale`), nothing is written, preview again.
- Limits: 5,000 rows per file.

## Rollback (owner only)
- Balances: every entry of the batch that is not reversed gets a reversal
  entry (append-only, nothing is deleted). Parties the batch created are
  retired (soft delete) only if no other entry touches them; otherwise kept
  and counted. Refused while any entry is in a closed financial year.
- Products: retired (soft delete) unless they have stock movements.
- A rollback record marks the batch; it can happen once. Batches imported
  before this feature have no party list and keep their parties.
