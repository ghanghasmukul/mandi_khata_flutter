import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_labels.dart';
import 'package:mandi_khata_app/features/shop_sales/data/return_repository.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sales_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Sales return: pick lines and quantities (never more than sold less what
/// came back), see the refund and where it goes, confirm.
Future<void> showSaleReturnDialog(BuildContext context, SaleDetail detail) =>
    showDialog<void>(
      context: context,
      barrierColor: MkColors.scrim,
      builder: (_) => SaleReturnDialog(detail: detail),
    );

enum _Via { auto, khata, cash, upi }

class SaleReturnDialog extends ConsumerStatefulWidget {
  const SaleReturnDialog({required this.detail, super.key});

  final SaleDetail detail;

  @override
  ConsumerState<SaleReturnDialog> createState() => _SaleReturnState();
}

class _SaleReturnState extends ConsumerState<SaleReturnDialog> {
  final Map<String, int> _qty = {};
  _Via _via = _Via.auto;
  String? _bankId;
  bool _saving = false;
  String? _error;

  List<ReturnItem> get _items => [
    for (final e in _qty.entries)
      if (e.value > 0) ReturnItem(e.key, e.value),
  ];

  RefundChoice get _choice => switch (_via) {
    _Via.auto => RefundChoice.auto,
    _Via.khata => RefundChoice.khata,
    _Via.cash || _Via.upi => RefundChoice.cash,
  };

  Future<void> _save(String? bankId) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final r = await ref
        .read(saleWriterProvider)
        .createReturn(
          ReturnDraft(
            saleId: widget.detail.sale.id,
            items: _items,
            choice: _choice,
            viaUpi: _via == _Via.upi,
            bankAccountId: _via == _Via.upi ? bankId : null,
          ),
        );
    if (!mounted) return;
    final error = l10n.returnError(r);
    if (error != null || r is! ReturnSaved) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop();
    MkToast.show(
      context,
      l10n.salesReturnSaved(r.returnNo),
      tone: MkToastTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = widget.detail;
    final banks = [
      for (final b
          in ref.watch(bankAccountListProvider()).value ??
              const <BankAccount>[])
        if (!b.isCash) b,
    ];
    final bankId = _bankId ?? (banks.length == 1 ? banks.first.id : null);
    var prior = Money.zero;
    // Round-off already given back with earlier returns is part of the
    // repository's calculation; the preview only needs it for the last one.
    final p = ReturnRepository.preview(
      d,
      _items,
      _choice,
      priorRoundOff: prior,
    );
    prior = Money.zero;
    return MkDialog(
      title: '${l10n.salesReturnTitle} · ${d.sale.saleNo}',
      maxWidth: 560,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final l in d.lines)
            if (l.returnableMilli > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.productName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            l10n.salesReturnLeft(_leftText(l)),
                            style: TextStyle(
                              fontSize: 12,
                              color: MkTokens.of(context).textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 96,
                      child: MkTextField(
                        key: ValueKey('return-qty-${l.id}'),
                        hint: l10n.salesReturnQty,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (t) =>
                            setState(() => _qty[l.id] = Qty.parse(t) ?? 0),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: MkSpacing.md),
          DropdownButtonFormField<_Via>(
            key: const ValueKey('return-via'),
            initialValue: _via,
            items: [
              DropdownMenuItem(
                value: _Via.auto,
                child: Text(l10n.salesRefundAuto),
              ),
              if (d.sale.partyId != null)
                DropdownMenuItem(
                  value: _Via.khata,
                  child: Text(l10n.salesRefundKhata),
                ),
              DropdownMenuItem(
                value: _Via.cash,
                child: Text(l10n.salesRefundCash),
              ),
              if (banks.isNotEmpty)
                DropdownMenuItem(
                  value: _Via.upi,
                  child: Text(l10n.salesRefundUpi),
                ),
            ],
            onChanged: (v) => setState(() => _via = v ?? _Via.auto),
          ),
          if (_via == _Via.upi && banks.length > 1)
            DropdownButtonFormField<String>(
              initialValue: _bankId,
              decoration: InputDecoration(labelText: l10n.posPayUpiAccount),
              items: [
                for (final b in banks)
                  DropdownMenuItem(value: b.id, child: Text(b.label)),
              ],
              onChanged: (v) => setState(() => _bankId = v),
            ),
          if (p != null) ...[
            const SizedBox(height: MkSpacing.md),
            Text(
              l10n.salesReturnRefund(p.result.refund.format()),
              key: const ValueKey('return-refund'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              l10n.salesReturnSplit(
                p.settlement.khata.format(),
                p.settlement.cash.format(),
              ),
            ),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.sm),
              child: Text(
                _error!,
                style: const TextStyle(color: MkColors.udhaar),
              ),
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
          key: const ValueKey('return-save'),
          label: l10n.salesReturnAction,
          busy: _saving,
          onPressed: _items.isEmpty ? null : () => _save(bankId),
        ),
      ],
    );
  }
}

String _leftText(InvoiceLine l) =>
    '${Qty.format(l.returnableMilli)} ${l.unit ?? ''}';
