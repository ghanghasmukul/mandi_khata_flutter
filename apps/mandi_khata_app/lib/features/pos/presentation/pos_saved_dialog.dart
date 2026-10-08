import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/pos/domain/pos_cart.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_labels.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_providers.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/invoice_actions.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sales_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// "Bill saved": number, total, any stock warnings, then print / share /
/// the next bill (Enter).
Future<void> showPosSavedDialog(
  BuildContext context,
  SaleSaved saved, {
  required Money total,
}) => showDialog<void>(
  context: context,
  barrierColor: MkColors.scrim,
  builder: (_) => _SavedDialog(saved: saved, total: total),
);

class _SavedDialog extends ConsumerWidget {
  const _SavedDialog({required this.saved, required this.total});

  final SaleSaved saved;
  final Money total;

  Future<SaleDetail?> _detail(WidgetRef ref) async {
    final tenantId = ref.read(activeTenantProvider);
    if (tenantId == null) return null;
    final repo = await ref.read(saleRepositoryProvider.future);
    return await repo.detail(tenantId, saved.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final warnings = {
      for (final w in saved.warnings) ?l10n.stockWarning(w.kind),
    };
    return MkDialog(
      title: l10n.posSavedTitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.posSavedBody(saved.saleNo, total.format()),
            key: const ValueKey('pos-saved-body'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final w in warnings)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.sm),
              child: Text(w, style: const TextStyle(color: MkColors.udhaar)),
            ),
        ],
      ),
      actions: [
        MkButton(
          key: const ValueKey('pos-print'),
          label: l10n.posPrint,
          variant: MkButtonVariant.secondary,
          icon: Icons.print_outlined,
          onPressed: () async {
            final d = await _detail(ref);
            if (d != null) await SaleInvoices.print(ref, d);
          },
        ),
        MkButton(
          key: const ValueKey('pos-share'),
          label: l10n.posShare,
          variant: MkButtonVariant.secondary,
          icon: Icons.share_outlined,
          onPressed: () async {
            final d = await _detail(ref);
            if (d != null) await SaleInvoices.share(ref, d);
          },
        ),
        MkButton(
          key: const ValueKey('pos-next'),
          label: '${l10n.posNewBill} (Enter)',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Edit quantity, price and line discount of one cart line.
Future<void> showLineEditDialog(
  BuildContext context,
  WidgetRef ref,
  int index,
  PosCartLine line,
) => showDialog<void>(
  context: context,
  barrierColor: MkColors.scrim,
  builder: (_) => _LineEdit(index: index, line: line),
);

class _LineEdit extends ConsumerStatefulWidget {
  const _LineEdit({required this.index, required this.line});

  final int index;
  final PosCartLine line;

  @override
  ConsumerState<_LineEdit> createState() => _LineEditState();
}

class _LineEditState extends ConsumerState<_LineEdit> {
  late final _qty = TextEditingController(
    text: Qty.format(widget.line.qtyMilli),
  );
  late Money _price = widget.line.unitPrice;
  late Money _discount = widget.line.lineDiscount;

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  void _apply() {
    final c = ref.read(posCartControllerProvider.notifier);
    final q = Qty.parse(_qty.text);
    if (_price != widget.line.unitPrice) c.setPrice(widget.index, _price);
    if (_discount != widget.line.lineDiscount) {
      c.setLineDiscount(widget.index, _discount);
    }
    if (q != null && q > 0 && q != widget.line.qtyMilli) {
      c.setQty(widget.index, q);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkDialog(
      title: widget.line.product.name,
      content: Column(
        children: [
          MkTextField(
            key: const ValueKey('edit-qty'),
            controller: _qty,
            label: l10n.posColQty,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (_) => _apply(),
          ),
          const SizedBox(height: MkSpacing.sm),
          MkNumberField(
            key: const ValueKey('edit-price'),
            label: l10n.posColPrice,
            initialValue: _price.paise,
            onChanged: (v) => _price = Money(v ?? 0),
          ),
          const SizedBox(height: MkSpacing.sm),
          MkNumberField(
            key: const ValueKey('edit-discount'),
            label: l10n.posColDiscount,
            initialValue: _discount.paise,
            onChanged: (v) => _discount = Money(v ?? 0),
          ),
        ],
      ),
      actions: [
        MkButton(
          label: l10n.commonCancel,
          variant: MkButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MkButton(
          key: const ValueKey('edit-apply'),
          label: l10n.settingsSave,
          onPressed: _apply,
        ),
      ],
    );
  }
}
