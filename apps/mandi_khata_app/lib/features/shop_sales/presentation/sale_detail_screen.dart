import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_labels.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/invoice_actions.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sale_return_dialog.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sales_providers.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sales_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Invoice view: header, lines with batch, GST, the paid / udhaar split,
/// returns, and print / share / return / reverse.
class SaleDetailScreen extends ConsumerWidget {
  const SaleDetailScreen({required this.saleId, super.key});

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(saleDetailProvider(saleId));
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: detail.value?.sale.saleNo ?? l10n.salesInvoiceTitle,
            actions: [
              IconButton(
                tooltip: l10n.salesTitle,
                onPressed: () => context.go(SalesRoutes.list),
                icon: const Icon(Icons.list_alt_outlined),
              ),
            ],
          ),
          Expanded(
            child: detail.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (d) => d == null
                  ? MkEmptyState(title: l10n.salesNotFound)
                  : _Body(detail: d),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.detail});

  final SaleDetail detail;

  Future<void> _reverse(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await MkDialog.show<bool>(
      context,
      title: l10n.salesReverseAction,
      content: Text(l10n.salesReverseConfirm),
      actions: [
        Builder(
          builder: (c) => MkButton(
            label: l10n.commonCancel,
            variant: MkButtonVariant.ghost,
            onPressed: () => Navigator.of(c).pop(false),
          ),
        ),
        Builder(
          builder: (c) => MkButton(
            key: const ValueKey('sale-reverse-confirm'),
            label: l10n.salesReverseAction,
            variant: MkButtonVariant.danger,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ),
      ],
    );
    if (ok != true || !context.mounted) return;
    final r = await ref.read(saleWriterProvider).reverse(detail.sale.id);
    if (!context.mounted) return;
    final error = l10n.saleSaveError(r, const {});
    MkToast.show(
      context,
      error ?? l10n.salesReverseDone,
      tone: error == null ? MkToastTone.success : MkToastTone.error,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = detail.sale;
    final canReturn = ref.watch(canProvider(Permission.salesReturn));
    final canReverse = ref.watch(canProvider(Permission.entriesReverse));
    final showCost = ref.watch(canProvider(Permission.shopViewProfit));
    final tokens = MkTokens.of(context);
    Widget kv(String k, Money v, {MkMoneyTone tone = MkMoneyTone.plain}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(k),
              MkMoneyText(v, tone: tone),
            ],
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(MkSpacing.lg),
      children: [
        MkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      s.saleNo,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (s.isReversed)
                    MkRoleChip(label: l10n.salesReversedTag, warning: true),
                ],
              ),
              Text(AppFormat.ledgerDate(context, s.entryDate)),
              if (s.displayName != null)
                Text('${l10n.salesBillTo}: ${s.displayName}'),
              if ((s.customerGstin ?? '').isNotEmpty)
                Text('${l10n.salesGstin}: ${s.customerGstin}'),
              if (s.tier != null)
                Text('${l10n.posTierLabel}: ${l10n.tierName(s.tier!)}'),
            ],
          ),
        ),
        const SizedBox(height: MkSpacing.md),
        MkCard(
          child: Column(
            children: [
              for (final l in detail.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${Qty.format(l.qtyMilli)} ${l.unit ?? ''} x '
                              '${l.unitPrice.format()}'
                              '${_hsnText(l10n, l.hsn)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: tokens.textMuted,
                              ),
                            ),
                            Text(
                              l.batchNo == null
                                  ? l10n.salesNoBatch
                                  : l.expiry == null
                                  ? l10n.salesBatchOnly(l.batchNo!)
                                  : l10n.salesBatchExpiry(
                                      l.batchNo!,
                                      AppFormat.ledgerDate(context, l.expiry!),
                                    ),
                              style: TextStyle(
                                fontSize: 12,
                                color: tokens.textMuted,
                              ),
                            ),
                            if (showCost)
                              Text(
                                '${l10n.salesCost} ${l.cost.format()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tokens.textMuted,
                                ),
                              ),
                            if (l.returnedMilli > 0)
                              Text(
                                '${l10n.salesReturnsHeader}: '
                                '${Qty.format(l.returnedMilli)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: MkColors.udhaar,
                                ),
                              ),
                          ],
                        ),
                      ),
                      MkMoneyText(l.total),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: MkSpacing.md),
        MkCard(
          child: Column(
            children: [
              kv(l10n.posSubtotal, s.subtotal),
              if ((s.lineDiscounts + s.invoiceDiscount).isPositive)
                kv(
                  l10n.posDiscountTotal,
                  -(s.lineDiscounts + s.invoiceDiscount),
                ),
              kv(l10n.posTaxable, s.gst.taxable),
              if (s.gst.cgst.isPositive) kv(l10n.posCgst, s.gst.cgst),
              if (s.gst.sgst.isPositive) kv(l10n.posSgst, s.gst.sgst),
              if (s.gst.igst.isPositive) kv(l10n.posIgst, s.gst.igst),
              if (!s.roundOff.isZero) kv(l10n.posRoundOff, s.roundOff),
              kv(l10n.posTotal, s.total),
              const Divider(),
              if (s.paidCash.isPositive) kv(l10n.posPayCash, s.paidCash),
              if (s.paidUpi.isPositive) kv(l10n.posPayUpi, s.paidUpi),
              if (s.paidCredit.isPositive)
                kv(l10n.posPayUdhaar, s.paidCredit, tone: MkMoneyTone.udhaar),
              if (showCost)
                kv(
                  l10n.salesProfit,
                  s.gst.taxable - detail.costOfGoods,
                  tone: MkMoneyTone.jama,
                ),
            ],
          ),
        ),
        if (detail.postedReturns.isNotEmpty) ...[
          const SizedBox(height: MkSpacing.md),
          MkCard(
            title: l10n.salesReturnsHeader,
            child: Column(
              children: [
                for (final r in detail.postedReturns)
                  ListTile(
                    dense: true,
                    title: Text(r.returnNo),
                    subtitle: Text(
                      l10n.salesReturnSplit(
                        r.refundKhata.format(),
                        (r.refundCash + r.refundUpi).format(),
                      ),
                    ),
                    trailing: MkMoneyText(r.total),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: MkSpacing.lg),
        Wrap(
          spacing: MkSpacing.sm,
          runSpacing: MkSpacing.sm,
          children: [
            MkButton(
              key: const ValueKey('sale-print'),
              label: l10n.posPrint,
              icon: Icons.print_outlined,
              variant: MkButtonVariant.secondary,
              onPressed: () => SaleInvoices.print(ref, detail),
            ),
            MkButton(
              key: const ValueKey('sale-share'),
              label: l10n.posShare,
              icon: Icons.share_outlined,
              variant: MkButtonVariant.secondary,
              onPressed: () => SaleInvoices.share(ref, detail),
            ),
            if (canReturn && detail.canReturn)
              MkButton(
                key: const ValueKey('sale-return'),
                label: l10n.salesReturnAction,
                icon: Icons.undo,
                variant: MkButtonVariant.secondary,
                onPressed: () => showSaleReturnDialog(context, detail),
              ),
            if (canReverse &&
                canReturn &&
                !s.isReversed &&
                detail.postedReturns.isEmpty)
              MkButton(
                key: const ValueKey('sale-reverse'),
                label: l10n.salesReverseAction,
                variant: MkButtonVariant.danger,
                onPressed: () => _reverse(context, ref),
              ),
          ],
        ),
      ],
    );
  }
}

String _hsnText(AppLocalizations l10n, String? hsn) =>
    hsn == null ? '' : ' · ${l10n.salesHsn} $hsn';
