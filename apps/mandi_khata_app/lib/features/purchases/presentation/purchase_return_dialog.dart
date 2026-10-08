import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/purchases/domain/purchase.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchases_labels.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchases_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Return goods to the supplier: a quantity per line (to its original
/// batch) and how the supplier settles. Ctrl+Enter saves.
class PurchaseReturnDialog extends ConsumerStatefulWidget {
  const PurchaseReturnDialog({required this.detail, super.key});

  final PurchaseDetail detail;

  static Future<void> show(BuildContext context, PurchaseDetail detail) =>
      showDialog<void>(
        context: context,
        builder: (_) => PurchaseReturnDialog(detail: detail),
      );

  @override
  ConsumerState<PurchaseReturnDialog> createState() => _State();
}

class _State extends ConsumerState<PurchaseReturnDialog> {
  final _qty = <String, int>{};
  RefundChoice _choice = RefundChoice.auto;
  String? _error;
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final r = await ref
        .read(purchaseWriterProvider)
        .createReturn(
          PurchaseReturnDraft(
            purchaseId: widget.detail.summary.id,
            choice: _choice,
            lines: [
              for (final e in _qty.entries)
                if (e.value > 0) PurchaseReturnLineDraft(e.key, e.value),
            ],
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    final error = l10n.purchaseResult(r);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.purchaseReturnSaved((r as PurchaseSaved).number)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _save,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _save,
      },
      child: AlertDialog(
        title: Text(l10n.purchaseReturnTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final l in widget.detail.lines)
                  if (l.returnableMilli > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: MkSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${l.productName} · ${l.batchNo}\n'
                              '/ ${Qty.format(l.returnableMilli)}',
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: MkNumberField(
                              key: ValueKey('return-qty-${l.id}'),
                              kind: MkNumberKind.integer,
                              label: l10n.purchaseReturnQty,
                              onChanged: (v) => setState(
                                () => _qty[l.id] = Qty.fromUnits(v ?? 0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                SegmentedButton<RefundChoice>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: RefundChoice.auto,
                      label: Text(l10n.purchaseRefundAuto),
                    ),
                    ButtonSegment(
                      value: RefundChoice.khata,
                      label: Text(l10n.purchaseRefundKhata),
                    ),
                    ButtonSegment(
                      value: RefundChoice.cash,
                      label: Text(l10n.purchaseRefundCash),
                    ),
                  ],
                  selected: {_choice},
                  onSelectionChanged: (s) => setState(() => _choice = s.first),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: MkSpacing.sm),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            key: const ValueKey('purchase-return-save'),
            onPressed: _saving ? null : _save,
            child: Text(l10n.purchaseReturnSave),
          ),
        ],
      ),
    );
  }
}
