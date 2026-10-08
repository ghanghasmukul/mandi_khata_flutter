import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/products/data/stock_repository.dart';
import 'package:mandi_khata_app/features/products/domain/opening_stock_import.dart';
import 'package:mandi_khata_app/features/products/domain/stock.dart';
import 'package:mandi_khata_app/features/products/presentation/products_labels.dart';
import 'package:mandi_khata_app/features/products/presentation/products_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Stock adjustment (reason required) or opening stock as a new batch.
/// [batch] preselects the batch to correct.
Future<void> showStockAdjustDialog(
  BuildContext context,
  ProductWithStock product, {
  BatchStock? batch,
}) => showDialog<void>(
  context: context,
  barrierColor: MkColors.scrim,
  builder: (_) => _AdjustDialog(product: product, batch: batch),
);

class _AdjustDialog extends ConsumerStatefulWidget {
  const _AdjustDialog({required this.product, this.batch});

  final ProductWithStock product;
  final BatchStock? batch;

  @override
  ConsumerState<_AdjustDialog> createState() => _AdjustDialogState();
}

class _AdjustDialogState extends ConsumerState<_AdjustDialog> {
  final _delta = TextEditingController();
  final _note = TextEditingController();
  final _batchNo = TextEditingController();
  final _cost = TextEditingController();
  final _mfg = TextEditingController();
  final _expiry = TextEditingController();
  late bool _newBatch = widget.product.batches.isEmpty;
  late String? _batchId =
      widget.batch?.id ?? widget.product.batches.firstOrNull?.id;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_delta, _note, _batchNo, _cost, _mfg, _expiry]) {
      c.dispose();
    }
    super.dispose();
  }

  /// `-2.5` -> -2500, `3` -> 3000; null when not a number.
  static int? parseSigned(String text) {
    final t = text.trim();
    final neg = t.startsWith('-');
    final q = Qty.parse(
      neg
          ? t.substring(1)
          : t.startsWith('+')
          ? t.substring(1)
          : t,
    );
    return q == null ? null : (neg ? -q : q);
  }

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context);
    final writer = ref.read(productsWriterProvider);
    final id = widget.product.product.id;
    final delta = parseSigned(_delta.text);
    setState(() {
      _busy = true;
      _error = null;
    });
    final StockResult result;
    if (_newBatch) {
      final cost = Money.tryParse(_cost.text);
      final mfg = _mfg.text.trim().isEmpty
          ? null
          : OpeningStockImport.parseDate(_mfg.text);
      final exp = _expiry.text.trim().isEmpty
          ? null
          : OpeningStockImport.parseDate(_expiry.text, endOfMonth: true);
      if (delta == null || delta <= 0) {
        return _fail(l10n.prodAdjErrZero);
      }
      if (cost == null) return _fail(l10n.prodAdjErrCost);
      if ((_mfg.text.trim().isNotEmpty && mfg == null) ||
          (_expiry.text.trim().isNotEmpty && exp == null)) {
        return _fail(l10n.prodImpProbExpiry);
      }
      result = await writer.addBatch(
        productId: id,
        batchNo: _batchNo.text,
        qtyMilli: delta,
        cost: cost,
        mfgDate: mfg,
        expiry: exp,
      );
    } else {
      if (_batchId == null || delta == null || delta == 0) {
        return _fail(l10n.prodAdjErrZero);
      }
      result = await writer.adjust(
        productId: id,
        batchId: _batchId!,
        deltaMilli: delta,
        note: _note.text,
      );
    }
    if (!mounted) return;
    if (result is StockAdjusted || result is OpeningStockImported) {
      MkToast.show(context, l10n.prodAdjDone);
      Navigator.of(context).pop();
    } else {
      _fail(l10n.stockFailure(result));
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final batches = widget.product.batches;
    return MkDialog(
      title: '${l10n.prodAdjTitle}: ${widget.product.product.name}',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (batches.isNotEmpty)
            SwitchListTile(
              key: const ValueKey('adj-new-batch'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.prodAdjAddBatch),
              value: _newBatch,
              onChanged: (v) => setState(() => _newBatch = v),
            ),
          if (!_newBatch && batches.isNotEmpty)
            DropdownButtonFormField<String>(
              key: const ValueKey('adj-batch'),
              initialValue: _batchId,
              decoration: InputDecoration(labelText: l10n.prodAdjBatch),
              items: [
                for (final b in batches)
                  DropdownMenuItem(
                    value: b.id,
                    child: Text(
                      '${b.batchNo} (${Qty.format(b.remainingMilli)})',
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _batchId = v),
            ),
          if (_newBatch) ...[
            MkTextField(
              key: const ValueKey('adj-batch-no'),
              controller: _batchNo,
              label: l10n.prodAdjBatchNo,
            ),
            MkTextField(
              key: const ValueKey('adj-cost'),
              controller: _cost,
              label: l10n.prodAdjCost,
              keyboardType: TextInputType.number,
            ),
            MkTextField(controller: _mfg, label: l10n.prodAdjMfg),
            MkTextField(controller: _expiry, label: l10n.prodAdjExpiry),
          ],
          MkTextField(
            key: const ValueKey('adj-delta'),
            controller: _delta,
            autofocus: true,
            label: _newBatch ? l10n.prodAdjQty : l10n.prodAdjDelta,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
          ),
          if (!_newBatch)
            MkTextField(
              key: const ValueKey('adj-note'),
              controller: _note,
              label: l10n.prodAdjNote,
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.sm),
              child: Text(
                _error!,
                key: const ValueKey('adj-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      actions: [
        MkButton(
          label: l10n.commonCancel,
          variant: MkButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MkButton(
          key: const ValueKey('adj-apply'),
          label: l10n.prodAdjApply,
          busy: _busy,
          onPressed: _apply,
        ),
      ],
    );
  }
}
