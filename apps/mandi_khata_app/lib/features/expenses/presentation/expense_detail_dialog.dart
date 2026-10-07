import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart' show Permission;
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:mandi_khata_app/features/expenses/presentation/bill_picker.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_labels.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One expense: its details and bill; attach a bill, reverse.
class ExpenseDetailDialog extends ConsumerWidget {
  const ExpenseDetailDialog({required this.expense, super.key});

  final Expense expense;

  static Future<void> show(BuildContext context, Expense e) => showDialog<void>(
    context: context,
    builder: (_) => ExpenseDetailDialog(expense: e),
  );

  Future<void> _reverse(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.expenseReverse),
        content: Text(l10n.expenseReverseBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('expense-reverse-confirm'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(l10n.expenseReverse),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final r = await ref.read(expensesWriterProvider).reverse(expense.id);
    if (!context.mounted) return;
    final error = l10n.expenseResult(r);
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _attach(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final BillPhoto? bill;
    try {
      bill = await ref.read(billPickerProvider)();
    } on BillTooLarge {
      messenger.showSnackBar(SnackBar(content: Text(l10n.expenseBillTooLarge)));
      return;
    }
    if (bill == null) return;
    await ref.read(expensesWriterProvider).attachBill(expense.id, bill);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final e = expense;
    final canReverse = ref.watch(canProvider(Permission.entriesReverse));
    final canAttach = ref.watch(canProvider(Permission.paymentsCreate));
    final path = e.billPath;
    final image = path == null ? null : ref.watch(billImageProvider(path));
    return AlertDialog(
      title: Text('${e.expenseNo} · ${e.categoryName}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                AppFormat.ledgerDate(context, e.date),
                e.accountName,
                if (e.isReversed) l10n.voucherReversedTag,
              ].join(' · '),
            ),
            Text(e.amount.format(), style: MkText.mono()),
            if (e.paidTo != null) Text('${l10n.expensePaidTo}: ${e.paidTo}'),
            if (e.narration != null) Text(e.narration!),
            if (image != null) ...[
              const SizedBox(height: MkSpacing.md),
              image.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => Text(l10n.expenseBillOffline),
                data: (img) {
                  if (img?.bytes != null && !path!.endsWith('.pdf')) {
                    return Image.memory(img!.bytes!, height: 240);
                  }
                  if (img?.url != null && !path!.endsWith('.pdf')) {
                    return Image.network(
                      img!.url!,
                      height: 240,
                      errorBuilder: (_, _, _) => Text(l10n.expenseBillOffline),
                    );
                  }
                  return Text(
                    img == null ? l10n.expenseBillOffline : path!,
                    key: const ValueKey('expense-bill-offline'),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (path == null && !e.isReversed && canAttach)
          TextButton.icon(
            key: const ValueKey('expense-attach'),
            onPressed: () => _attach(context, ref),
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(l10n.expenseAttachBill),
          ),
        if (!e.isReversed && canReverse)
          TextButton.icon(
            key: const ValueKey('expense-reverse'),
            onPressed: () => _reverse(context, ref),
            icon: const Icon(Icons.undo),
            label: Text(l10n.expenseReverse),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}
