import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:mandi_khata_app/features/team/presentation/team_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

extension ExpensesLabels on AppLocalizations {
  /// A seeded category in the app language while it keeps its first name.
  String categoryName(ExpenseCategory c) {
    final seed = ExpenseCategorySeed.values
        .where((s) => s.code == c.code)
        .firstOrNull;
    if (seed == null || seed.name != c.name) return c.name;
    return switch (seed) {
      ExpenseCategorySeed.palledari => expenseCategoryPalledari,
      ExpenseCategorySeed.transport => expenseCategoryTransport,
      ExpenseCategorySeed.salary => expenseCategorySalary,
      ExpenseCategorySeed.bardana => expenseCategoryBardana,
      ExpenseCategorySeed.mandiCharges => expenseCategoryMandiCharges,
      ExpenseCategorySeed.electricity => expenseCategoryElectricity,
      ExpenseCategorySeed.rent => expenseCategoryRent,
      ExpenseCategorySeed.misc => expenseCategoryMisc,
    };
  }

  String expenseProblem(ExpenseProblem p) => switch (p) {
    ExpenseProblem.amountNotPositive => expenseProblemAmount,
    ExpenseProblem.noCategory => expenseProblemCategory,
    ExpenseProblem.noBankAccount => expenseProblemBank,
  };

  /// Why a save / reversal failed; null when it worked.
  String? expenseResult(ExpenseResult r) => switch (r) {
    ExpenseSaved() => null,
    ExpenseInvalid(:final problems) => problems.map(expenseProblem).join('\n'),
    ExpenseNotPermitted(lockedYear: true) => yearLockedError,
    ExpenseNotPermitted(:final backdateDays?) => khataErrorBackdated(
      backdateDays,
    ),
    ExpenseNotPermitted(:final permission) => acctNeedsPermission(
      permissionName(permission),
    ),
    ExpenseNotFound() => expenseNotFound,
    ExpenseLocked() => expenseLocked,
  };
}
