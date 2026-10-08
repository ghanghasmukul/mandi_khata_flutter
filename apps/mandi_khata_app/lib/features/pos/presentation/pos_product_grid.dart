import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/pos/domain/pos_cart.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Products as tappable cards with the price of the bill's tier and the
/// stock left. [highlight] marks the one Enter would add.
class PosProductGrid extends StatelessWidget {
  const PosProductGrid({
    required this.products,
    required this.settings,
    required this.tier,
    required this.highlight,
    required this.onAdd,
    required this.blockExpired,
    super.key,
  });

  final List<PosProduct> products;
  final PriceTiers settings;
  final String tier;
  final int highlight;
  final ValueChanged<PosProduct> onAdd;
  final bool blockExpired;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    if (products.isEmpty) {
      return Center(child: Text(l10n.posNoProducts));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(MkSpacing.sm),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 104,
        crossAxisSpacing: MkSpacing.sm,
        mainAxisSpacing: MkSpacing.sm,
      ),
      itemCount: products.length > 120 ? 120 : products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        final price = p.prices.lookup(tier, settings)?.price;
        final left = p.sellableMilli(blockExpired: blockExpired);
        final out = left <= 0;
        return Material(
          color: tokens.surfaceAlt,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MkRadius.sm),
            side: BorderSide(
              color: i == highlight ? tokens.gold : tokens.border,
              width: i == highlight ? 2 : 1,
            ),
          ),
          child: InkWell(
            key: ValueKey('pos-product-${p.id}'),
            borderRadius: BorderRadius.circular(MkRadius.sm),
            onTap: () => onAdd(p),
            child: Padding(
              padding: const EdgeInsets.all(MkSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    price == null ? l10n.posNoPrice : price.format(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: price == null ? MkColors.udhaar : null,
                      fontSize: price == null ? 11 : 14,
                    ),
                  ),
                  Text(
                    out
                        ? (p.expiredMilli > 0 && p.stockMilli > 0
                              ? l10n.posExpiredStock
                              : l10n.posOutOfStock)
                        : l10n.stockText(p, blockExpired: blockExpired),
                    style: TextStyle(
                      fontSize: 12,
                      color: out ? MkColors.udhaar : tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
