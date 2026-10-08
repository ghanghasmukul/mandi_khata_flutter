import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/products/presentation/products_labels.dart';
import 'package:mandi_khata_app/features/products/presentation/products_providers.dart';
import 'package:mandi_khata_app/features/products/presentation/products_routes.dart';
import 'package:mandi_khata_app/features/products/presentation/stock_adjust_dialog.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One batch: cost, dates, what is left and its stock book (every movement).
class BatchDetailScreen extends ConsumerWidget {
  const BatchDetailScreen({
    required this.productId,
    required this.batchId,
    super.key,
  });

  final String productId;
  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stock = ref.watch(productWithStockProvider(productId)).value;
    final moves =
        ref.watch(batchMovementsProvider(productId, batchId)).value ?? const [];
    final profit = ref.watch(canProvider(Permission.shopViewProfit));
    final adjust = ref.watch(canProvider(Permission.stockAdjust));
    final batch = stock?.batches.where((b) => b.id == batchId).firstOrNull;
    if (stock == null || batch == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final today = LedgerDate.fromDateTime(DateTime.now());
    String d(LedgerDate? x) =>
        x == null ? '—' : AppFormat.ledgerDate(context, x);
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.prodBatchTitle(batch.batchNo),
            actions: [
              IconButton(
                onPressed: () =>
                    context.go(ProductRoutes.edit(stock.product.id)),
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(MkSpacing.lg),
              children: [
                MkCard(
                  title: stock.product.name,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.prodBatchLeft}: '
                        '${Qty.format(batch.remainingMilli)} '
                        '${l10n.productUnit(stock.product.unit)}',
                        key: const ValueKey('batch-left'),
                      ),
                      if (profit)
                        Text(
                          '${l10n.prodBatchCost}: ${batch.cost.format()}  ·  '
                          '${l10n.prodColValue}: ${batch.value.format()}',
                        ),
                      Text('${l10n.prodBatchMfg}: ${d(batch.mfgDate)}'),
                      Text('${l10n.prodBatchExpiry}: ${d(batch.expiry)}'),
                      if (batch.isExpired(today))
                        Text(l10n.prodBatchExpiredTag),
                      if (batch.cacheStale) ...[
                        const SizedBox(height: MkSpacing.sm),
                        Text(
                          l10n.prodBatchStale,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        if (adjust)
                          MkButton(
                            key: const ValueKey('batch-rebuild'),
                            label: l10n.prodBatchRebuild,
                            variant: MkButtonVariant.secondary,
                            onPressed: () async {
                              final n = await ref
                                  .read(productsWriterProvider)
                                  .rebuild();
                              if (n != null && context.mounted) {
                                MkToast.show(context, l10n.prodBatchRebuilt(n));
                              }
                            },
                          ),
                      ],
                      if (adjust) ...[
                        const SizedBox(height: MkSpacing.md),
                        MkButton(
                          key: const ValueKey('batch-adjust'),
                          label: l10n.prodAdjTitle,
                          icon: Icons.tune,
                          onPressed: () => showStockAdjustDialog(
                            context,
                            stock,
                            batch: batch,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: MkSpacing.lg),
                MkCard(
                  title: l10n.prodBatchMovements,
                  child: Column(
                    children: [
                      for (final m in moves)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.stockReason(m.reason)),
                          subtitle: Text([d(m.entryDate), ?m.note].join(' · ')),
                          trailing: Text(
                            (m.qtyMilli > 0 ? '+' : '') +
                                Qty.format(m.qtyMilli),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
