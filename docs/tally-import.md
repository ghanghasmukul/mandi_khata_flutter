# Importing Mandi Khata books into Tally Prime

For the accountant (CA / munim) who keeps the business's books in Tally Prime. Rules behind the export: `docs/domain/posting-rules.md`, section 11.6.

## 1. Make the export (in Mandi Khata)

1. Open **Accounts → Export to Tally** (owner or accountant; needs the "Bank details, profit, reports export" permission).
2. Pick the period: **This month**, **Last month**, or a custom range. Export one month at a time; it keeps each import small and easy to check.
3. **Account groups in Tally**: every group used in the period is listed with the Tally group its ledgers go under. The defaults follow Tally's own groups (Sundry Debtors, Sundry Creditors, Cash-in-Hand, Bank Accounts, Direct Incomes, Indirect Expenses, Duties & Taxes, …). Change one if your Tally company uses a different group; the owner's choice is saved for the business.
4. **Checks before export** must show nothing in red:
   - *no Tally group for …*: pick a group in step 3;
   - *the name is empty or longer than 99 characters*: rename the account / party;
   - *debit and credit differ*: should never happen; run **Accounts → Books (checks)** and tell support;
   - *an account has not synced yet*: connect to the internet, let the app sync, then export again.
   Grey lines are information only: two parties with the same name are exported with their party code, e.g. `Gurmeet Singh (P-W1-0001)`.
5. Press **Export (.zip)** and save the file. It holds:
   - `01-masters.xml`: one ledger per account used in the period (parties, cash, banks, income, expense, duties…);
   - `02-vouchers.xml`: one voucher per journal entry of the period;
   - `validation.txt`: the checks shown on screen.

## 2. Import into Tally Prime

Do this on a **backup** of the Tally company the first time.

1. Unzip the file.
2. Open the company in Tally Prime. Check that the company's financial year covers the period.
3. **Masters first**: Gateway of Tally → **Import** → **Masters** → file path = `01-masters.xml` → *Behaviour of import if master already exists*: **Combine Opening Balances** (or *Ignore Duplicates* on later months) → Import.
4. **Then vouchers**: Gateway of Tally → **Import** → **Transactions** → file path = `02-vouchers.xml` → Import.
5. Tally shows how many masters / vouchers were created and any errors. Every voucher carries the Mandi Khata entry id (`REMOTEID`), so importing the same month twice is refused by Tally instead of doubling the books.

## 3. How the vouchers look in Tally

| In Mandi Khata | Tally voucher type |
|---|---|
| Payment to a party, cash / bank expense, payment voucher | **Payment** (a cash / bank ledger is credited) |
| Receipt from a party, receipt voucher | **Receipt** (a cash / bank ledger is debited) |
| Cash to bank / bank to cash (contra voucher) | **Contra** |
| Sales voucher / purchase voucher | **Sales** / **Purchase** |
| Lot (farmer, buyer, commission, mandi fee…), interest, waiver, manual khata entry, opening balance, journal voucher, year close | **Journal** |
| Anything reversed | its own voucher with the lines swapped, dated like the reversal |

Amounts follow Tally's convention (debit = `ISDEEMEDPOSITIVE Yes` with a negative amount). Voucher numbers are the Mandi Khata numbers (`PY-W1-0001`, `R-W1-0002`, `L-A4-0007`, `EX-W1-0003`…); set the voucher types' numbering in Tally to **Manual** so they are kept.

## 4. Things to know

- **Journal vouchers with cash.** A cash count difference is a journal voucher with the Cash ledger. If Tally refuses it, enable *Allow Cash Accounts in Journals* (F12 configuration of the Journal voucher type) or post that one line by hand.
- **Opening balances.** The export carries transactions, not opening balances of ledgers: start the Tally company on the same date as the books in Mandi Khata, or import from the first month on.
- **Bill-wise details** are switched on for party ledgers (`ISBILLWISEON Yes`) but the vouchers carry no bill references; Tally treats them as *On Account*.
- **Inventory** (shop stock, phase 4) is not exported yet.

## 5. If the import fails

Send the `validation.txt` and Tally's import log (`tally.imp` in the Tally folder) to support. Do not edit the XML by hand: fix the cause in Mandi Khata and export again.
