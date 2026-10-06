import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_labels.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Recurring expenses: the months due (post with one tap) and the
/// templates (add, switch off). No automatic posting.
class ExpenseRecurringTab extends ConsumerWidget {
  const ExpenseRecurringTab({super.key});

  Future<void> _post(
    BuildContext context,
    WidgetRef ref,
    DueRecurring d,
  ) async {
    final l10n = AppLocalizations.of(context);
    final r = await ref.read(expensesWriterProvider).postDue(d);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.expenseResult(r) ??
              l10n.expenseSaved((r as ExpenseSaved).expenseNo),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final due = ref.watch(dueRecurringProvider).value ?? const [];
    final templates = ref.watch(recurringExpensesProvider).value ?? const [];
    final canPost = ref.watch(canProvider(Permission.paymentsCreate));
    final canManage = ref.watch(canProvider(Permission.entriesReverse));
    return ListView(
      padding: const EdgeInsets.all(MkSpacing.md),
      children: [
        Text(
          l10n.expenseDueTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (due.isEmpty) Text(l10n.expenseDueNone),
        for (final d in due)
          ListTile(
            key: ValueKey('due-${d.template.id}-${d.period}'),
            title: Text(
              [d.template.categoryName, ?d.template.paidTo].join(' · '),
            ),
            subtitle: Text(AppFormat.ledgerDate(context, d.date)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d.template.amount.format(), style: MkText.mono()),
                const SizedBox(width: MkSpacing.sm),
                if (canPost)
                  FilledButton(
                    key: ValueKey('due-post-${d.template.id}-${d.period}'),
                    onPressed: () => _post(context, ref, d),
                    child: Text(l10n.expenseDuePost),
                  ),
              ],
            ),
          ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.expensesRecurringTab,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (canManage)
              TextButton.icon(
                key: const ValueKey('recurring-add'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const _RecurringDialog(),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.expenseRecurringAdd),
              ),
          ],
        ),
        for (final t in templates)
          SwitchListTile(
            key: ValueKey('recurring-${t.id}'),
            value: t.isActive,
            onChanged: canManage
                ? (v) => ref
                      .read(expensesWriterProvider)
                      .setRecurringActive(t.id, isActive: v)
                : null,
            title: Text([t.categoryName, ?t.paidTo].join(' · ')),
            subtitle: Text(
              l10n.expenseRecurringEvery(
                t.schedule.dayOfMonth,
                t.amount.format(),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecurringDialog extends ConsumerStatefulWidget {
  const _RecurringDialog();

  @override
  ConsumerState<_RecurringDialog> createState() => _RecurringDialogState();
}

class _RecurringDialogState extends ConsumerState<_RecurringDialog> {
  String? _categoryId;
  Money _amount = Money.zero;
  int _day = 1;
  final _paidTo = TextEditingController();

  @override
  void dispose() {
    _paidTo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final categoryId = _categoryId;
    if (categoryId == null || !_amount.isPositive) return;
    final id = await ref
        .read(expensesWriterProvider)
        .addRecurring(
          categoryId: categoryId,
          amount: _amount,
          isCash: true,
          dayOfMonth: _day,
          start: LedgerDate.fromDateTime(DateTime.now()),
          paidTo: _paidTo.text,
        );
    if (id != null && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = [
      for (final c
          in ref.watch(expenseCategoriesProvider).value ??
              const <ExpenseCategory>[])
        if (c.isActive) c,
    ];
    return AlertDialog(
      title: Text(l10n.expenseRecurringAdd),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              key: const ValueKey('recurring-category'),
              initialValue: _categoryId,
              decoration: InputDecoration(labelText: l10n.expenseCategory),
              items: [
                for (final c in categories)
                  DropdownMenuItem(
                    value: c.id,
                    child: Text(l10n.categoryName(c)),
                  ),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            MkNumberField(
              key: const ValueKey('recurring-amount'),
              label: l10n.voucherAmount,
              onChanged: (p) => setState(() => _amount = Money(p ?? 0)),
            ),
            DropdownButtonFormField<int>(
              key: const ValueKey('recurring-day'),
              initialValue: _day,
              decoration: InputDecoration(labelText: l10n.expenseRecurringDay),
              items: [
                for (var d = 1; d <= 31; d++)
                  DropdownMenuItem(value: d, child: Text('$d')),
              ],
              onChanged: (v) => setState(() => _day = v ?? 1),
            ),
            MkTextField(label: l10n.expensePaidTo, controller: _paidTo),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('recurring-save'),
          onPressed: _save,
          child: Text(l10n.voucherSave),
        ),
      ],
    );
  }
}
