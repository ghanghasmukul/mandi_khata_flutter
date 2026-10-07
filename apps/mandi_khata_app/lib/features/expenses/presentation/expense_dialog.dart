import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:mandi_khata_app/features/expenses/presentation/bill_picker.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_labels.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_providers.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Records an expense: date, category, amount, cash or bank, paid to,
/// narration, optional bill photo. Ctrl+Enter saves.
class ExpenseDialog extends ConsumerStatefulWidget {
  const ExpenseDialog({super.key});

  static Future<void> show(BuildContext context) =>
      showDialog<void>(context: context, builder: (_) => const ExpenseDialog());

  @override
  ConsumerState<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends ConsumerState<ExpenseDialog> {
  LedgerDate _date = LedgerDate.fromDateTime(DateTime.now());
  String? _categoryId;
  Money _amount = Money.zero;
  bool _cash = true;
  String? _bankId;
  final _paidTo = TextEditingController();
  final _narration = TextEditingController();
  BillPhoto? _bill;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _paidTo.dispose();
    _narration.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime(_date.year, _date.month, _date.day),
    );
    if (picked != null) setState(() => _date = LedgerDate.fromDateTime(picked));
  }

  Future<void> _pickBill() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final bill = await ref.read(billPickerProvider)();
      if (bill != null && mounted) setState(() => _bill = bill);
    } on BillTooLarge {
      messenger.showSnackBar(SnackBar(content: Text(l10n.expenseBillTooLarge)));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final r = await ref
        .read(expensesWriterProvider)
        .save(
          ExpenseDraft(
            date: _date,
            categoryId: _categoryId ?? '',
            amount: _amount,
            isCash: _cash,
            bankAccountId: _cash ? null : _bankId,
            paidTo: _paidTo.text,
            narration: _narration.text,
            bill: _bill,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    final error = l10n.expenseResult(r);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.expenseSaved((r as ExpenseSaved).expenseNo))),
    );
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
    final canBank = ref.watch(canProvider(Permission.financeView));
    final banks = <BankAccount>[
      for (final a
          in ref.watch(bankAccountListProvider()).value ??
              const <BankAccount>[])
        if (a.kind == AccountKind.bank && a.isActive) a,
    ];
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _save,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _save,
      },
      child: AlertDialog(
        title: Text(l10n.expenseAdd),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event, size: 18),
                  label: Text(
                    '${l10n.voucherDate}: '
                    '${AppFormat.ledgerDate(context, _date)}',
                  ),
                ),
                DropdownButtonFormField<String>(
                  key: const ValueKey('expense-category'),
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
                const SizedBox(height: MkSpacing.sm),
                MkNumberField(
                  key: const ValueKey('expense-amount'),
                  label: l10n.voucherAmount,
                  autofocus: true,
                  onChanged: (p) => setState(() => _amount = Money(p ?? 0)),
                ),
                const SizedBox(height: MkSpacing.sm),
                if (canBank)
                  SegmentedButton<bool>(
                    key: const ValueKey('expense-mode'),
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(l10n.expenseModeCash),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.expenseModeBank),
                      ),
                    ],
                    selected: {_cash},
                    onSelectionChanged: (s) => setState(() => _cash = s.first),
                  ),
                if (!_cash)
                  DropdownButtonFormField<String>(
                    key: const ValueKey('expense-bank'),
                    initialValue: _bankId,
                    decoration: InputDecoration(
                      labelText: l10n.expenseBankAccount,
                    ),
                    items: [
                      for (final b in banks)
                        DropdownMenuItem(value: b.id, child: Text(b.name)),
                    ],
                    onChanged: (v) => setState(() => _bankId = v),
                  ),
                const SizedBox(height: MkSpacing.sm),
                MkTextField(
                  key: const ValueKey('expense-paid-to'),
                  label: l10n.expensePaidTo,
                  controller: _paidTo,
                ),
                const SizedBox(height: MkSpacing.sm),
                MkTextField(
                  label: l10n.voucherNarration,
                  controller: _narration,
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: MkSpacing.sm),
                TextButton.icon(
                  key: const ValueKey('expense-bill'),
                  onPressed: _pickBill,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(
                    _bill == null
                        ? l10n.expenseAttachBill
                        : l10n.expenseBillAttached(_bill!.fileName),
                  ),
                ),
                if (_error != null)
                  Text(
                    _error!,
                    key: const ValueKey('expense-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('expense-save'),
            onPressed: _saving ? null : _save,
            child: Text(l10n.voucherSave),
          ),
        ],
      ),
    );
  }
}
