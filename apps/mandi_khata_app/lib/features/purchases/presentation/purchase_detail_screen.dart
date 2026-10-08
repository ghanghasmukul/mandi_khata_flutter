import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/purchases/domain/purchase.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchase_return_dialog.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchases_labels.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchases_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One purchase: lines, money, returns, with Return and Reverse buttons.
class PurchaseDetailScreen extends ConsumerWidget {
  const PurchaseDetailScreen({required this.purchaseId, super.key});

  final String purchaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(purchaseDetailProvider(purchaseId)).value;
    final canReturn = ref.watch(canProvider(Permission.purchasesCreate));
    final canReverse = ref.watch(canProvider(Permission.entriesReverse));
    if (detail == null) {
      return Scaffold(
        body: Column(
          children: [
            MkTopBar(title: l10n.purchasesTitle),
            Expanded(child: MkEmptyState(title: l10n.purchaseNotFound)),
          ],
        ),
      );
    }
    final s = detail.summary;
    final how = detail.paidInCash
        ? l10n.purchaseCash
        : detail.accountName ?? l10n.purchaseBank;
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: '${s.purchaseNo} · ${s.supplierName}',
            subtitle: [
              AppFormat.ledgerDate(context, s.date),
              if (s.supplierInvoiceNo != null) s.supplierInvoiceNo!,
              if (s.isReversed) l10n.purchaseReversedTag,
            ].join(' · '),
            actions: [
              IconButton(
                tooltip: l10n.purchasesTitle,
                onPressed: () => context.go(PurchaseRoutes.list),
                icon: const Icon(Icons.list),
              ),
              if (canReturn && detail.canReturn)
                TextButton.icon(
                  key: const ValueKey('purchase-return'),
                  onPressed: () => PurchaseReturnDialog.show(context, detail),
                  icon: const Icon(Icons.assignment_return_outlined),
                  label: Text(l10n.purchaseReturnTitle),
                ),
              if (canReverse && !s.isReversed)
                TextButton.icon(
                  key: const ValueKey('purchase-reverse'),
                  onPressed: () => _reverse(context, ref),
                  icon: const Icon(Icons.undo),
                  label: Text(l10n.purchaseReverse),
                ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(MkSpacing.md),
              children: [
                Text(
                  l10n.purchaseLinesTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final l in detail.lines)
                  ListTile(
                    dense: true,
                    title: Text('${l.productName} · ${l.batchNo}'),
                    subtitle: Text(
                      [
                        '${Qty.format(l.qtyMilli)} × ${l.unitCost.format()}',
                        '${GstRates.format(l.gstRateBp)}%',
                        if (l.returnedMilli > 0) l.purchaseReturned(l10n),
                      ].join(' · '),
                    ),
                    trailing: Text(l.total.format()),
                  ),
                const Divider(),
                _kv(l10n.purchaseTaxable, detail.taxable),
                _kv(l10n.purchaseGst, detail.gst),
                if (detail.freight.isPositive)
                  _kv(l10n.purchaseFreight, detail.freight),
                if (detail.otherCharges.isPositive)
                  _kv(l10n.purchaseOtherCharges, detail.otherCharges),
                if (!detail.roundOff.isZero)
                  _kv(l10n.purchaseRoundOff, detail.roundOff),
                _kv(l10n.purchaseTotal, s.total, bold: true),
                _kv('${l10n.purchasePaid} ($how)', s.paid),
                _kv(l10n.purchaseOutstanding, s.outstanding, bold: true),
                if (s.dueDate != null)
                  ListTile(
                    dense: true,
                    title: Text(l10n.purchaseDueDate),
                    trailing: Text(AppFormat.ledgerDate(context, s.dueDate!)),
                  ),
                if (detail.returns.isNotEmpty) ...[
                  const SizedBox(height: MkSpacing.md),
                  Text(
                    l10n.purchaseReturns,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final r in detail.returns)
                    ListTile(
                      dense: true,
                      title: Text(
                        [
                          r.returnNo,
                          if (r.isReversed) l10n.purchaseReversedTag,
                        ].join(' · '),
                      ),
                      subtitle: Text(AppFormat.ledgerDate(context, r.date)),
                      trailing: Text(r.total.format()),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, Money v, {bool bold = false}) => ListTile(
    dense: true,
    title: Text(k),
    trailing: Text(
      v.format(),
      style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
    ),
  );

  Future<void> _reverse(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.purchaseReverse),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(MaterialLocalizations.of(c).cancelButtonLabel),
          ),
          FilledButton(
            key: const ValueKey('purchase-reverse-confirm'),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.purchaseReverse),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final r = await ref.read(purchaseWriterProvider).reverse(purchaseId);
    final error = l10n.purchaseResult(r);
    if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
  }
}

extension on PurchaseLineView {
  String purchaseReturned(AppLocalizations l10n) =>
      '${l10n.purchaseReturns}: ${Qty.format(returnedMilli)}';
}
