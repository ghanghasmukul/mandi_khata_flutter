import 'package:khata_core/src/journal.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:meta/meta.dart';

/// The expense categories every business starts with (editable), and the
/// group their account goes in (docs/domain/posting-rules.md, 11.4). The
/// [code] is stable: part of the category's id and of the server seed.
enum ExpenseCategorySeed {
  palledari('palledari', 'Palledari', AccountGroup.directExpenses),
  transport('transport', 'Transport', AccountGroup.directExpenses),
  salary('salary', 'Salary', AccountGroup.indirectExpenses),
  bardana('bardana', 'Bardana', AccountGroup.directExpenses),
  mandiCharges('mandi_charges', 'Mandi charges', AccountGroup.directExpenses),
  electricity('electricity', 'Electricity', AccountGroup.indirectExpenses),
  rent('rent', 'Rent', AccountGroup.indirectExpenses),
  misc('misc', 'Miscellaneous', AccountGroup.indirectExpenses);

  const ExpenseCategorySeed(this.code, this.name, this.group);

  final String code;
  final String name;
  final AccountGroup group;
}

/// Why an expense cannot be saved.
enum ExpenseProblem { amountNotPositive, noCategory, noBankAccount }

/// The rules of an expense.
abstract final class ExpenseRules {
  /// The groups an expense category's account may be in.
  static const Set<AccountGroup> groups = {
    AccountGroup.directExpenses,
    AccountGroup.indirectExpenses,
  };

  static List<ExpenseProblem> validate({
    required Money amount,
    required String? categoryId,
    required bool isCash,
    required String? bankAccountId,
  }) => [
    if (!amount.isPositive) ExpenseProblem.amountNotPositive,
    if (categoryId == null || categoryId.isEmpty) ExpenseProblem.noCategory,
    if (!isCash && (bankAccountId == null || bankAccountId.isEmpty))
      ExpenseProblem.noBankAccount,
  ];

  /// Dr the category's expense account, Cr cash / bank.
  static JournalEntryDraft journal({
    required String expenseId,
    required LedgerDate date,
    required JournalAccount expenseAccount,
    required String bankAccountId,
    required Money amount,
    String? narration,
  }) =>
      (JournalBuilder()
            ..debit(expenseAccount, amount)
            ..credit(BookAccount(bankAccountId), amount))
          .build(
            sourceKey: 'expense:$expenseId',
            date: date,
            narration: narration,
          );
}

/// A recurring expense (monthly salary, rent): the day of month and the
/// months it runs.
@immutable
final class RecurringSchedule {
  /// Throws [ArgumentError] for a day outside 1..31 or an end before the
  /// start.
  RecurringSchedule({required this.dayOfMonth, required this.start, this.end}) {
    if (dayOfMonth < 1 || dayOfMonth > 31) {
      throw ArgumentError.value(dayOfMonth, 'dayOfMonth');
    }
    if (end != null && end! < start) {
      throw ArgumentError.value(end, 'end', 'before start');
    }
  }

  final int dayOfMonth;
  final LedgerDate start;
  final LedgerDate? end;

  /// `2027-04`.
  static String periodOf(LedgerDate d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  /// The day it falls on in [year]-[month]: [dayOfMonth], or the month's
  /// last day when shorter (31 → 30 April, 28 / 29 February).
  LedgerDate dateIn(int year, int month) {
    final last = DateTime.utc(year, month + 1, 0).day;
    return LedgerDate(year, month, dayOfMonth > last ? last : dayOfMonth);
  }

  /// Every month's date from [start] up to [today] (and [end]) not in
  /// [posted] (periods like `2027-04`), oldest first.
  List<({String period, LedgerDate date})> due(
    LedgerDate today, {
    Set<String> posted = const {},
  }) {
    final out = <({String period, LedgerDate date})>[];
    var y = start.year;
    var m = start.month;
    while (true) {
      final date = dateIn(y, m);
      if (date > today || (end != null && date > end!)) break;
      final period = periodOf(date);
      if (date >= start && !posted.contains(period)) {
        out.add((period: period, date: date));
      }
      m++;
      if (m > 12) {
        m = 1;
        y++;
      }
    }
    return out;
  }
}

/// One posted expense for the report.
@immutable
final class ExpenseFact {
  const ExpenseFact({
    required this.categoryId,
    required this.date,
    required this.amount,
  });

  final String categoryId;
  final LedgerDate date;
  final Money amount;
}

/// Expenses by category and month (columns are `yyyy-mm`, oldest first).
@immutable
final class ExpensePivot {
  const ExpensePivot({
    required this.months,
    required this.byCategory,
    required this.monthTotals,
    required this.total,
  });

  /// Sums [facts] by category and month.
  factory ExpensePivot.of(Iterable<ExpenseFact> facts) {
    final byCategory = <String, Map<String, Money>>{};
    final monthTotals = <String, Money>{};
    var total = Money.zero;
    for (final f in facts) {
      final month = RecurringSchedule.periodOf(f.date);
      final row = byCategory.putIfAbsent(f.categoryId, () => {});
      row[month] = (row[month] ?? Money.zero) + f.amount;
      monthTotals[month] = (monthTotals[month] ?? Money.zero) + f.amount;
      total += f.amount;
    }
    return ExpensePivot(
      months: monthTotals.keys.toList()..sort(),
      byCategory: byCategory,
      monthTotals: monthTotals,
      total: total,
    );
  }

  final List<String> months;
  final Map<String, Map<String, Money>> byCategory;
  final Map<String, Money> monthTotals;
  final Money total;

  Money categoryTotal(String categoryId) =>
      (byCategory[categoryId] ?? {}).values.fold(Money.zero, (s, m) => s + m);
}
