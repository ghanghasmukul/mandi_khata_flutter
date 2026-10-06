import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statement_export_bar.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_labels.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_providers.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_table_view.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Expenses by category (rows) and month (columns) with totals; print /
/// PDF / Excel / CSV.
class ExpenseReportTab extends ConsumerWidget {
  const ExpenseReportTab({required this.from, required this.to, super.key});

  final LedgerDate? from;
  final LedgerDate? to;

  static ReportTable table(
    AppLocalizations l10n,
    ExpensePivot pivot,
    List<ExpenseCategory> categories,
  ) {
    final names = {for (final c in categories) c.id: l10n.categoryName(c)};
    final ids = pivot.byCategory.keys.toList()
      ..sort((a, b) => (names[a] ?? a).compareTo(names[b] ?? b));
    return ReportTable(
      columns: [
        ReportColumn(l10n.expenseCategory, ReportColumnKind.text),
        for (final m in pivot.months) ReportColumn(m, ReportColumnKind.money),
        ReportColumn(l10n.expenseReportTotal, ReportColumnKind.money),
      ],
      rows: [
        for (final id in ids)
          [
            names[id] ?? id,
            for (final m in pivot.months) pivot.byCategory[id]![m],
            pivot.categoryTotal(id),
          ],
      ],
      totals: [
        l10n.expenseReportTotal,
        for (final m in pivot.months) pivot.monthTotals[m],
        pivot.total,
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pivot = ref.watch(expensePivotProvider(from: from, to: to)).value;
    final categories = ref.watch(expenseCategoriesProvider).value ?? const [];
    if (pivot == null) return const Center(child: CircularProgressIndicator());
    if (pivot.byCategory.isEmpty) {
      return MkEmptyState(title: l10n.expensesEmpty);
    }
    final t = table(l10n, pivot, categories);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(MkSpacing.sm),
          child: StatementExportBar(
            title: l10n.expensesTitle,
            fileStem: 'expenses-${to ?? 'all'}',
            table: t,
          ),
        ),
        Expanded(child: ReportTableView(table: t)),
      ],
    );
  }
}
