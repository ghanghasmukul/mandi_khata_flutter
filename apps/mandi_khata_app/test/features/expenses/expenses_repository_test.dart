import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/accounts/data/books_invariants.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/expenses/data/bill_uploader.dart';
import 'package:mandi_khata_app/features/expenses/data/expenses_repository.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const ctxB = WriteContext(
  tenantId: t1,
  userId: 'user-b',
  deviceId: 'device-a1',
  deviceCode: 'A1',
);
const sbi = 'a0000000-0000-4000-8000-000000000001';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

final today = LedgerDate(2027, 4, 30);
final now = DateTime.utc(2027, 4, 30, 6);
final String cash = BankAccountsRepository.cashIdFor(t1);
final String salary = JournalWriter.expenseCategoryId(
  t1,
  ExpenseCategorySeed.salary,
);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late ExpensesRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_expenses_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = ExpensesRepository(db);
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
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<int> count(String sql, [List<Object?> args = const []]) async =>
      (await db.get('SELECT COUNT(*) AS n FROM $sql', args))['n']! as int;

  ExpenseDraft draft({
    int rupees = 500,
    bool isCash = true,
    LedgerDate? date,
    BillPhoto? bill,
    String? categoryId,
  }) => ExpenseDraft(
    date: date ?? today,
    categoryId: categoryId ?? salary,
    amount: Money.rupees(rupees),
    isCash: isCash,
    bankAccountId: isCash ? null : sbi,
    paidTo: 'Ramesh',
    bill: bill,
  );

  test('seeded categories are there before they sync', () async {
    final cats = await repo.watchCategories(t1).first;
    expect(cats, hasLength(ExpenseCategorySeed.values.length));
    expect(
      cats.firstWhere((c) => c.id == salary).group,
      AccountGroup.indirectExpenses,
    );
    // Their accounts are in the chart, in the right group.
    final chart = await db.readTransaction(
      (tx) => ChartRepository.load(tx, t1),
    );
    expect(
      chart.byId(JournalWriter.expenseAccountId(t1, salary)),
      isNull,
      reason: 'no category rows locally yet',
    );
  });

  test('cash expense: Dr category account, Cr cash, book line', () async {
    await db.execute(
      'INSERT INTO expense_categories (id, tenant_id, code, name, group_code, '
      "sort_order, is_active) VALUES (?, ?, 'salary', 'Salary', "
      "'indirect_expenses', 30, 1)",
      [salary, t1],
    );
    final r = await repo.save(ctx, draft(rupees: 12000), can: owner, now: now);
    expect(r, isA<ExpenseSaved>());
    final saved = r as ExpenseSaved;
    expect(saved.expenseNo, 'EX-W1-0001');
    final lines = await db.getAll(
      'SELECT l.account_id, l.debit_paise, l.credit_paise FROM journal_lines l '
      'JOIN journal_entries e ON e.id = l.journal_entry_id '
      'WHERE e.source_key = ? ORDER BY l.line_no',
      ['expense:${saved.id}'],
    );
    expect(
      [for (final l in lines) (l['account_id'], l['debit_paise'])],
      [
        (JournalWriter.expenseAccountId(t1, salary), 1200000),
        (JournalWriter.accountId(t1, BookAccount(cash)), 0),
      ],
    );
    final book = await db.get(
      'SELECT * FROM cash_bank_entries WHERE expense_id = ?',
      [saved.id],
    );
    expect(book['direction'], 'out');
    expect(book['amount_paise'], 1200000);
    final chart = await db.readTransaction(
      (tx) => ChartRepository.load(tx, t1),
    );
    final acct = chart.byId(JournalWriter.expenseAccountId(t1, salary))!;
    expect(acct.expenseCategoryId, salary);
    expect(acct.isOwn, isFalse);
    expect(chart.groupOf(acct)!.code, 'indirect_expenses');
    final invariants = BooksInvariants(db);
    expect(await invariants.unbalancedEntries(t1), isEmpty);
    expect(await invariants.bookDifferences(t1), isEmpty);
    expect(
      await count(
        "audit_log WHERE table_name IN ('expenses', 'journal_entries', "
        "'cash_bank_entries')",
      ),
      3,
    );
  });

  test(
    'refused: zero, munshi bank, munshi back-dated; nothing written',
    () async {
      expect(
        await repo.save(ctx, draft(rupees: 0), can: owner),
        isA<ExpenseInvalid>(),
      );
      expect(
        await repo.save(ctx, draft(isCash: false), can: munshi),
        isA<ExpenseNotPermitted>(),
      );
      expect(
        await repo.save(
          ctx,
          draft(date: today.addDays(-30)),
          can: munshi,
          now: now,
        ),
        isA<ExpenseNotPermitted>().having((r) => r.backdateDays, 'window', 3),
      );
      expect(
        await repo.save(ctx, draft(categoryId: 'nope'), can: owner),
        isA<ExpenseNotFound>(),
      );
      expect(await count('expenses'), 0);
      expect(await count('journal_entries'), 0);
    },
  );

  test('a munshi records a cash expense today', () async {
    expect(
      await repo.save(ctx, draft(), can: munshi, now: now),
      isA<ExpenseSaved>(),
    );
  });

  test(
    'reverse mirrors journal and book line; once; needs entries.reverse',
    () async {
      final saved =
          await repo.save(ctx, draft(isCash: false), can: owner, now: now)
              as ExpenseSaved;
      expect(
        await repo.reverse(ctx, saved.id, can: munshi),
        isA<ExpenseNotPermitted>(),
      );
      expect(
        await repo.reverse(ctx, saved.id, can: owner, now: now),
        isA<ExpenseSaved>(),
      );
      expect(
        await repo.reverse(ctx, saved.id, can: owner),
        isA<ExpenseLocked>(),
      );
      final net = await db.get(
        "SELECT SUM(CASE direction WHEN 'in' THEN amount_paise "
        'ELSE -amount_paise END) AS n FROM cash_bank_entries '
        'WHERE expense_id = ?',
        [saved.id],
      );
      expect(net['n'], 0);
      expect(await BooksInvariants(db).unbalancedEntries(t1), isEmpty);
    },
  );

  group('bill photo', () {
    test(
      'queued with the expense and uploaded later; failures retry',
      () async {
        final bill = BillPhoto(
          'IMG 001.jpg',
          Uint8List.fromList([1, 2, 3]),
          'image/jpeg',
        );
        final saved =
            await repo.save(
                  ctx,
                  draft(bill: bill),
                  can: owner,
                  now: now,
                )
                as ExpenseSaved;
        final row = await db.get(
          'SELECT bill_path FROM expenses WHERE id = ?',
          [saved.id],
        );
        final path = row['bill_path']! as String;
        expect(path, '$t1/${saved.id}/IMG_001.jpg');

        var fail = true;
        final sent = <String>[];
        final uploader = BillUploader(db, (p, bytes, type) async {
          if (fail) throw Exception('offline');
          sent.add('$p ${bytes.length} $type');
        });
        expect(await uploader.watchPending().first, 1);
        expect(await uploader.uploadPending(), 0);
        final failed = await db.get('SELECT * FROM bill_uploads');
        expect(failed['attempts'], 1);
        expect(failed['last_error'], contains('offline'));
        fail = false;
        expect(await uploader.uploadPending(now: now), 1);
        expect(sent, ['$path 3 image/jpeg']);
        expect(await uploader.watchPending().first, 0);
        // The photo stays viewable on this device.
        expect(await uploader.localBytes(path), [1, 2, 3]);
      },
    );

    test('attached once to an expense that has none', () async {
      final saved =
          await repo.save(ctx, draft(), can: owner, now: now) as ExpenseSaved;
      final bill = BillPhoto('b.png', Uint8List.fromList([9]), 'image/png');
      expect(await repo.attachBill(ctx, saved.id, bill, can: owner), isTrue);
      expect(await repo.attachBill(ctx, saved.id, bill, can: owner), isFalse);
    });
  });

  group('recurring', () {
    test('due months, posted once, even from two devices', () async {
      final id = (await repo.addRecurring(
        ctx,
        categoryId: salary,
        amount: const Money.rupees(12000),
        isCash: true,
        dayOfMonth: 31,
        start: LedgerDate(2027, 2, 1),
        paidTo: 'Munim ji',
        can: owner,
        now: now,
      ))!;
      expect(
        await repo.addRecurring(
          ctx,
          categoryId: salary,
          amount: const Money.rupees(1),
          isCash: true,
          dayOfMonth: 1,
          start: today,
          can: munshi,
        ),
        isNull,
      );
      var due = await repo.due(t1, today);
      expect(
        [for (final d in due) d.date.toString()],
        ['2027-02-28', '2027-03-31', '2027-04-30'],
      );
      final first = await repo.postDue(ctx, due.first, can: owner, now: now);
      expect(first, isA<ExpenseSaved>());
      // A second device posting the same month gets the same expense id.
      final again = await repo.postDue(ctxB, due.first, can: owner, now: now);
      expect(again, isA<ExpenseLocked>());
      due = await repo.due(t1, today);
      expect(due, hasLength(2));
      await repo.setRecurringActive(ctx, id, isActive: false, now: now);
      expect(await repo.due(t1, today), isEmpty);
      final row = await db.get(
        'SELECT period, recurring_id, paid_to FROM expenses',
      );
      expect(row['period'], '2027-02');
      expect(row['recurring_id'], id);
      expect(row['paid_to'], 'Munim ji');
    });
  });

  test('report facts and categories are per business', () async {
    await repo.save(ctx, draft(rupees: 100), can: owner, now: now);
    final reversed =
        await repo.save(ctx, draft(rupees: 50), can: owner, now: now)
            as ExpenseSaved;
    await repo.reverse(ctx, reversed.id, can: owner, now: now);
    final facts = await repo.facts(t1);
    expect(facts.single.amount, const Money.rupees(100));
    expect(await repo.facts(t2), isEmpty);
    expect(await repo.watchExpenses(t2).first, isEmpty);
    final cats = await repo.addCategory(
      ctx,
      'Diesel',
      AccountGroup.directExpenses,
      can: owner,
    );
    expect(cats, isNotNull);
    expect(
      await repo.addCategory(ctx, 'x', AccountGroup.salesAccounts, can: owner),
      isNull,
    );
    expect(
      await repo.addCategory(
        ctx,
        'y',
        AccountGroup.directExpenses,
        can: munshi,
      ),
      isNull,
    );
    expect(
      await repo.updateCategory(ctx, cats!, can: owner, isActive: false),
      isTrue,
    );
  });
}
