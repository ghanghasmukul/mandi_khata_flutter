import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/pos/domain/pos_cart.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The cart lines: name, unit price, qty with - / + (48 px targets), line
/// total. Tapping a line selects it (keys + / - / Del act on it) and
/// double tap / the edit button opens [onEdit].
class PosCartLines extends StatelessWidget {
  const PosCartLines({
    required this.cart,
    required this.selected,
    required this.onSelect,
    required this.onBump,
    required this.onRemove,
    required this.onEdit,
    required this.totals,
    required this.blockExpired,
    super.key,
  });

  final PosCart cart;
  final int selected;
  final ValueChanged<int> onSelect;
  final void Function(int index, int deltaMilli) onBump;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onEdit;
  final SaleTotals? totals;
  final bool blockExpired;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(MkSpacing.lg),
          child: Text(
            l10n.posCartEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.textMuted),
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: cart.lines.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final line = cart.lines[i];
        final result = totals?.lines[i];
        final issues = totals?.gstIssues[i] ?? const <GstIssue>[];
        final isSelected = i == selected;
        return Material(
          color: isSelected ? tokens.goldTint : Colors.transparent,
          child: InkWell(
            key: ValueKey('pos-cart-line-$i'),
            onTap: () => onSelect(i),
            onDoubleTap: () => onEdit(i),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: MkSpacing.sm,
                  vertical: MkSpacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _priceText(line),
                            style: TextStyle(
                              fontSize: 12,
                              color: tokens.textMuted,
                            ),
                          ),
                          if (line.manualPrice && line.unitPrice.isZero)
                            Text(
                              l10n.posNoPrice,
                              style: const TextStyle(
                                fontSize: 12,
                                color: MkColors.udhaar,
                              ),
                            ),
                          if (issues.isNotEmpty)
                            Text(
                              l10n.posGstMissing,
                              style: TextStyle(
                                fontSize: 12,
                                color: tokens.goldText,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: ValueKey('pos-dec-$i'),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      icon: const Icon(Icons.remove),
                      onPressed: () => onBump(i, -Qty.unit),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text(
                        Qty.format(line.qtyMilli),
                        key: ValueKey('pos-qty-$i'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      key: ValueKey('pos-inc-$i'),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      icon: const Icon(Icons.add),
                      onPressed: () => onBump(i, Qty.unit),
                    ),
                    SizedBox(
                      width: 84,
                      child: Text(
                        (result?.total ?? line.toCartLine().gross).format(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.posRemoveLine,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      icon: const Icon(Icons.close),
                      onPressed: () => onRemove(i),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Subtotal, discounts, GST breakdown, round-off and total.
class PosTotalsBlock extends StatelessWidget {
  const PosTotalsBlock({required this.totals, super.key});

  final SaleTotals? totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = totals;
    Widget row(String k, Money v, {bool big = false, Key? key}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: TextStyle(
              fontSize: big ? 16 : 13,
              fontWeight: big ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          MkMoneyText(v, key: key, size: big ? 22 : 13),
        ],
      ),
    );
    if (t == null) {
      return row(l10n.posTotal, Money.zero, big: true);
    }
    return Column(
      children: [
        row(l10n.posSubtotal, t.subtotal),
        if (t.totalDiscount.isPositive)
          row(l10n.posDiscountTotal, -t.totalDiscount),
        row(l10n.posTaxable, t.gst.taxable),
        if (t.gst.cgst.isPositive) row(l10n.posCgst, t.gst.cgst),
        if (t.gst.sgst.isPositive) row(l10n.posSgst, t.gst.sgst),
        if (t.gst.igst.isPositive) row(l10n.posIgst, t.gst.igst),
        if (!t.roundOff.isZero) row(l10n.posRoundOff, t.roundOff),
        row(
          l10n.posTotal,
          t.total,
          big: true,
          key: const ValueKey('pos-total'),
        ),
      ],
    );
  }
}

String _priceText(PosCartLine line) {
  final base = '${line.unitPrice.format()} / ${line.product.unit}';
  return line.lineDiscount.isPositive
      ? '$base · -${line.lineDiscount.format()}'
      : base;
}
