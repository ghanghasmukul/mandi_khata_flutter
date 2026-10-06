import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_labels.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Expense categories: add one (direct / indirect), switch one off.
class ExpenseCategoriesDialog extends ConsumerStatefulWidget {
  const ExpenseCategoriesDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => const ExpenseCategoriesDialog(),
  );

  @override
  ConsumerState<ExpenseCategoriesDialog> createState() => _State();
}

class _State extends ConsumerState<ExpenseCategoriesDialog> {
  final _name = TextEditingController();
  AccountGroup _group = AccountGroup.indirectExpenses;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_name.text.trim().isEmpty) return;
    await ref.read(expensesWriterProvider).addCategory(_name.text, _group);
    _name.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(expenseCategoriesProvider).value ?? const [];
    String groupName(AccountGroup g) => g == AccountGroup.directExpenses
        ? l10n.expenseGroupDirect
        : l10n.expenseGroupIndirect;
    return AlertDialog(
      title: Text(l10n.expenseCategoriesTitle),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in categories)
                    SwitchListTile(
                      key: ValueKey('category-${c.id}'),
                      dense: true,
                      value: c.isActive,
                      title: Text(l10n.categoryName(c)),
                      subtitle: Text(groupName(c.group)),
                      onChanged: (v) => ref
                          .read(expensesWriterProvider)
                          .updateCategory(c.id, isActive: v),
                    ),
                ],
              ),
            ),
            const Divider(),
            MkTextField(
              key: const ValueKey('category-name'),
              label: l10n.expenseCategoryName,
              controller: _name,
              onSubmitted: (_) => _add(),
            ),
            SegmentedButton<AccountGroup>(
              segments: [
                for (final g in ExpenseRules.groups)
                  ButtonSegment(value: g, label: Text(groupName(g))),
              ],
              selected: {_group},
              onSelectionChanged: (s) => setState(() => _group = s.first),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
        FilledButton(
          key: const ValueKey('category-add'),
          onPressed: _add,
          child: Text(l10n.expenseCategoryAdd),
        ),
      ],
    );
  }
}
