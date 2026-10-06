import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/accounts/data/books_invariants.dart';
import 'package:mandi_khata_app/features/accounts/data/cash_count_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/statements_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/voucher_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/expenses/data/expenses_repository.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';

/// Phase 3 exit criterion 1: random postings through every repository that
/// writes the journal (payments, receipts, vouchers of every type,
/// expenses, manual entries, cash counts, and reversals of all of them);
/// afterwards the trial balance tallies, the balance sheet balances, every
/// party account equals its khata and every book account its cash book.
const t1 = '11111111-1111-4111-8111-111111111111';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'owner',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const sbi = 'a0000000-0000-4000-8000-000000000001';

bool owner(Permission _) => true;

void main() {
  for (final seed in [1, 7, 42]) {
    test('seed $seed: 150 random postings keep the books tallied', () async {
      final dir = await Directory.systemTemp.createTemp('mk_books_fuzz');
      final db = PowerSyncDatabase(
        schema: powerSyncSchema,
        path: '${dir.path}/t.db',
      );
      addTearDown(() async {
        await db.close();
        await dir.delete(recursive: true);
      });
      await db.initialize();
      final rnd = Random(seed);
      final cash = BankAccountsRepository.cashIdFor(t1);
      final parties = [
        for (var i = 0; i < 6; i++) 'p0000000-0000-4000-8000-00000000000$i',
      ];
      for (final (i, id) in parties.indexed) {
        await db.execute(
          'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
          [id, t1, 'P-$i', 'Party $i'],
        );
        await db.execute(
          'INSERT INTO party_roles (id, tenant_id, party_id, role) '
          'VALUES (?, ?, ?, ?)',
          ['r$i', t1, id, if (i.isEven) 'farmer' else 'buyer'],
        );
      }
      for (final (id, kind, name) in [
        (cash, 'cash', 'Cash'),
        (sbi, 'bank', 'SBI'),
      ]) {
        await db.execute(
          'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
          'sort_order) VALUES (?, ?, ?, ?, 1, 0)',
          [id, t1, kind, name],
        );
      }
      final payments = PaymentsRepository(db);
      final vouchers = VoucherRepository(db);
      final expenses = ExpensesRepository(db);
      final ledger = LedgerRepository(db);
      final counts = CashCountRepository(db, vouchers);
      final chart = await db.readTransaction(
        (tx) => ChartRepository.load(tx, t1),
      );
      final today = LedgerDate(2027, 4, 10);
      final now = DateTime.utc(2027, 4, 10, 6);
      LedgerDate day() => today.addDays(-rnd.nextInt(3));
      Money amount() => Money(rnd.nextInt(5000000) + 1);
      String party() => parties[rnd.nextInt(parties.length)];
      VoucherDraftLine line(JournalAccount a, DrCr side, Money m) =>
          VoucherDraftLine(
            account: chart.byId(JournalWriter.accountId(t1, a))!,
            side: side,
            amount: m,
          );
      final posted = <(String kind, String id)>[];
      var writes = 0;

      for (var i = 0; i < 150; i++) {
        final op = rnd.nextInt(9);
        final m = amount();
        switch (op) {
          case 0 || 1:
            final r = await payments.save(
              ctx,
              PaymentDraft(
                entryDate: day(),
                partyId: party(),
                direction: rnd.nextBool()
                    ? PaymentDirection.toParty
                    : PaymentDirection.fromParty,
                mode: rnd.nextBool() ? PaymentMode.cash : PaymentMode.bank,
                bankAccountId: sbi,
                amount: m,
              ),
              can: owner,
              now: now,
            );
            if (r case PaymentSaved(:final id)) {
              posted.add(('payment', id));
              writes++;
            }
          case 2:
            final a = party();
            var b = party();
            while (b == a) {
              b = party();
            }
            final r = await vouchers.save(
              ctx,
              VoucherDraft(
                type: VoucherType.journal,
                date: day(),
                lines: [
                  line(PartyAccount(a), DrCr.dr, m),
                  line(PartyAccount(b), DrCr.cr, m),
                ],
              ),
              can: owner,
              now: now,
            );
            if (r case VoucherSaved(:final id)) {
              posted.add(('voucher', id));
              writes++;
            }
          case 3:
            final half = Money(m.paise ~/ 2);
            final rest = m - half;
            final r = await vouchers.save(
              ctx,
              VoucherDraft(
                type: VoucherType.sales,
                date: day(),
                lines: [
                  line(PartyAccount(party()), DrCr.dr, m),
                  if (half.isPositive)
                    line(
                      const SystemJournalAccount(SystemAccount.sales),
                      DrCr.cr,
                      half,
                    ),
                  line(
                    const SystemJournalAccount(SystemAccount.commissionIncome),
                    DrCr.cr,
                    half.isPositive ? rest : m,
                  ),
                ],
              ),
              can: owner,
              now: now,
            );
            if (r case VoucherSaved(:final id)) {
              posted.add(('voucher', id));
              writes++;
            }
          case 4:
            final r = await vouchers.save(
              ctx,
              VoucherDraft(
                type: VoucherType.contra,
                date: day(),
                lines: [
                  line(const BookAccount(sbi), DrCr.dr, m),
                  line(BookAccount(cash), DrCr.cr, m),
                ],
              ),
              can: owner,
              now: now,
            );
            if (r case VoucherSaved(:final id)) {
              posted.add(('voucher', id));
              writes++;
            }
          case 5:
            final seed = ExpenseCategorySeed
                .values[rnd.nextInt(ExpenseCategorySeed.values.length)];
            final r = await expenses.save(
              ctx,
              ExpenseDraft(
                date: day(),
                categoryId: JournalWriter.expenseCategoryId(t1, seed),
                amount: m,
                isCash: rnd.nextBool(),
                bankAccountId: sbi,
              ),
              can: owner,
              now: now,
            );
            if (r case ExpenseSaved(:final id)) {
              posted.add(('expense', id));
              writes++;
            }
          case 6:
            final r = await ledger.append(
              ctx,
              LedgerDraft(
                partyId: party(),
                side: rnd.nextBool() ? Side.jama : Side.udhaar,
                amount: m,
                refType: rnd.nextBool()
                    ? RefType.journal
                    : RefType.openingBalance,
                entryDate: day(),
              ),
              can: owner,
              now: now,
            );
            if (r is LedgerPosted) writes++;
          case 7:
            await counts.save(
              ctx,
              day(),
              CashCount({100: rnd.nextInt(50)}),
              can: owner,
              postDifference: true,
              now: now,
            );
            writes++;
          case 8:
            if (posted.isEmpty) break;
            final (kind, id) = posted.removeAt(rnd.nextInt(posted.length));
            switch (kind) {
              case 'payment':
                await payments.reverse(ctx, id, can: owner, now: now);
              case 'voucher':
                await vouchers.reverse(ctx, id, can: owner, now: now);
              default:
                await expenses.reverse(ctx, id, can: owner, now: now);
            }
            writes++;
        }
      }
      expect(writes, greaterThan(100));

      final books = BooksInvariants(db);
      expect(await books.unbalancedEntries(t1), isEmpty);
      expect(await books.partyDifferences(t1), isEmpty);
      expect(await books.bookDifferences(t1), isEmpty);

      final statements = StatementsRepository(db);
      final tb = await statements.trialBalance(t1, asOf: today);
      expect(tb.isBalanced, isTrue);
      expect(tb.debit.isPositive, isTrue);
      final bs = await statements.balanceSheet(t1, asOf: today);
      expect(bs.isBalanced, isTrue);
      final pl = await statements.profitAndLoss(
        t1,
        from: LedgerDate(2000, 1, 1),
        to: today,
      );
      expect(pl.netProfit, bs.currentProfit);
    });
  }
}
