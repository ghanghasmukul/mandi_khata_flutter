import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expense_categories_dialog.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expense_detail_dialog.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expense_dialog.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expense_recurring_tab.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expense_report_tab.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mk_ui/mk_ui.dart';

/// Expenses: entries (add, view bill, reverse), recurring months due, and
/// the report by category and month. `Ctrl/⌘ N` adds one.
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  LedgerDate? _from = LedgerDate.fromDateTime(DateTime.now()).addDays(-6);
  LedgerDate? _to = LedgerDate.fromDateTime(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = ref.watch(canProvider(Permission.paymentsCreate));
    final canManage = ref.watch(canProvider(Permission.entriesReverse));
    final pending = ref.watch(pendingBillsProvider).value ?? 0;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(AccountRoutes.hub),
        if (canAdd) ...{
          const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
              ExpenseDialog.show(context),
          const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
              ExpenseDialog.show(context),
        },
      },
      child: Focus(
        autofocus: true,
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            floatingActionButton: canAdd
                ? FloatingActionButton.extended(
                    key: const ValueKey('expense-add'),
                    onPressed: () => ExpenseDialog.show(context),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.expenseAdd),
                  )
                : null,
            body: Column(
              children: [
                MkTopBar(
                  title: l10n.expensesTitle,
                  subtitle: pending == 0
                      ? null
                      : l10n.expenseUploadsPending(pending),
                  actions: [
                    if (canManage)
                      IconButton(
                        key: const ValueKey('expense-categories'),
                        tooltip: l10n.expenseCategoriesTitle,
                        onPressed: () => ExpenseCategoriesDialog.show(context),
                        icon: const Icon(Icons.category_outlined),
                      ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: () => context.go(AccountRoutes.hub),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                TabBar(
                  tabs: [
                    Tab(text: l10n.expensesEntriesTab),
                    Tab(text: l10n.expensesRecurringTab),
                    Tab(text: l10n.expensesReportTab),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(MkSpacing.sm),
                  child: DateRangeChips(
                    keyPrefix: 'expenses',
                    from: _from,
                    to: _to,
                    onChanged: (f, t) => setState(() {
                      _from = f;
                      _to = t;
                    }),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _Entries(from: _from, to: _to),
                      const ExpenseRecurringTab(),
                      ExpenseReportTab(from: _from, to: _to),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Entries extends ConsumerWidget {
  const _Entries({required this.from, required this.to});

  final LedgerDate? from;
  final LedgerDate? to;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rows =
        ref.watch(expenseListProvider(from: from, to: to)).value ??
        const <Expense>[];
    if (rows.isEmpty) return MkEmptyState(title: l10n.expensesEmpty);
    final total = rows
        .where((e) => !e.isReversed)
        .fold(Money.zero, (s, e) => s + e.amount);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = rows[i];
              return ListTile(
                key: ValueKey('expense-${e.id}'),
                onTap: () => ExpenseDetailDialog.show(context, e),
                leading: Icon(
                  e.billPath == null
                      ? Icons.receipt_outlined
                      : Icons.receipt_long,
                ),
                title: Text(
                  [e.categoryName, ?e.paidTo].join(' · '),
                  style: TextStyle(
                    decoration: e.isReversed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(
                  [
                    e.expenseNo,
                    AppFormat.ledgerDate(context, e.date),
                    e.accountName,
                  ].join(' · '),
                ),
                trailing: Text(e.amount.format(), style: MkText.mono()),
              );
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MkSpacing.md),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            '${l10n.expenseReportTotal}: ${total.format()}',
            key: const ValueKey('expenses-total'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
