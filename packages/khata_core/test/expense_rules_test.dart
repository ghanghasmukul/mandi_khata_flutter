import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('ExpenseRules', () {
    test('validate', () {
      expect(
        ExpenseRules.validate(
          amount: const Money.rupees(5),
          categoryId: 'c',
          isCash: true,
          bankAccountId: null,
        ),
        isEmpty,
      );
      expect(
        ExpenseRules.validate(
          amount: Money.zero,
          categoryId: '',
          isCash: false,
          bankAccountId: null,
        ),
        [
          ExpenseProblem.amountNotPositive,
          ExpenseProblem.noCategory,
          ExpenseProblem.noBankAccount,
        ],
      );
      expect(
        ExpenseRules.validate(
          amount: const Money.rupees(1),
          categoryId: 'c',
          isCash: false,
          bankAccountId: '',
        ),
        [ExpenseProblem.noBankAccount],
      );
    });

    test('journal: Dr expense account, Cr cash / bank', () {
      final e = ExpenseRules.journal(
        expenseId: 'x1',
        date: LedgerDate(2027, 4, 30),
        expenseAccount: const ChartAccount('salary-acct'),
        bankAccountId: 'cash',
        amount: const Money.rupees(12000),
        narration: 'EX-W1-0001',
      );
      expect(e.sourceKey, 'expense:x1');
      expect(
        [for (final l in e.lines) l.toString()],
        ['Dr account:salary-acct 1200000', 'Cr book:cash 1200000'],
      );
    });

    test('seeds: unique codes, expense groups only', () {
      expect({
        for (final s in ExpenseCategorySeed.values) s.code,
      }, hasLength(ExpenseCategorySeed.values.length));
      for (final s in ExpenseCategorySeed.values) {
        expect(ExpenseRules.groups, contains(s.group));
      }
    });
  });

  group('RecurringSchedule', () {
    test('monthly on the day; short months use their last day', () {
      final s = RecurringSchedule(
        dayOfMonth: 31,
        start: LedgerDate(2027, 1, 15),
      );
      final due = s.due(LedgerDate(2027, 4, 30));
      expect(
        [for (final d in due) d.date.toString()],
        ['2027-01-31', '2027-02-28', '2027-03-31', '2027-04-30'],
      );
      expect(due.first.period, '2027-01');
      expect(s.dateIn(2028, 2), LedgerDate(2028, 2, 29));
    });

    test(
      'skips posted months, a first date before start, and stops at end',
      () {
        final s = RecurringSchedule(
          dayOfMonth: 1,
          start: LedgerDate(2027, 1, 15),
          end: LedgerDate(2027, 5, 1),
        );
        final due = s.due(LedgerDate(2027, 12, 31), posted: {'2027-03'});
        expect(
          [for (final d in due) d.period],
          ['2027-02', '2027-04', '2027-05'],
        );
      },
    );

    test('across a year end; nothing due before the first date', () {
      final s = RecurringSchedule(
        dayOfMonth: 10,
        start: LedgerDate(2026, 12, 1),
      );
      expect(
        [for (final d in s.due(LedgerDate(2027, 1, 10))) d.period],
        ['2026-12', '2027-01'],
      );
      expect(s.due(LedgerDate(2026, 12, 9)), isEmpty);
    });

    test('refuses bad days and an end before the start', () {
      expect(
        () => RecurringSchedule(dayOfMonth: 0, start: LedgerDate(2027, 1, 1)),
        throwsArgumentError,
      );
      expect(
        () => RecurringSchedule(dayOfMonth: 32, start: LedgerDate(2027, 1, 1)),
        throwsArgumentError,
      );
      expect(
        () => RecurringSchedule(
          dayOfMonth: 1,
          start: LedgerDate(2027, 2, 1),
          end: LedgerDate(2027, 1, 1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('ExpensePivot', () {
    test('by category and month with totals', () {
      final p = ExpensePivot.of([
        ExpenseFact(
          categoryId: 'rent',
          date: LedgerDate(2027, 4, 1),
          amount: const Money.rupees(5000),
        ),
        ExpenseFact(
          categoryId: 'rent',
          date: LedgerDate(2027, 5, 1),
          amount: const Money.rupees(5000),
        ),
        ExpenseFact(
          categoryId: 'transport',
          date: LedgerDate(2027, 4, 9),
          amount: const Money.rupees(300),
        ),
        ExpenseFact(
          categoryId: 'transport',
          date: LedgerDate(2027, 4, 19),
          amount: const Money.rupees(200),
        ),
      ]);
      expect(p.months, ['2027-04', '2027-05']);
      expect(p.byCategory['transport']!['2027-04'], const Money.rupees(500));
      expect(p.monthTotals['2027-04'], const Money.rupees(5500));
      expect(p.categoryTotal('rent'), const Money.rupees(10000));
      expect(p.categoryTotal('none'), Money.zero);
      expect(p.total, const Money.rupees(10500));
    });
  });
}
