import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sales_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// What the payment dialog returns.
class PosPayment {
  const PosPayment(this.split, this.upiAccountId);

  final PaymentSplit split;
  final String? upiAccountId;
}

/// Cash / UPI / udhaar / split for a bill of [total]. Udhaar needs a party
/// (shown with their baki and a credit-limit warning). Keys: Alt+1 all
/// cash, Alt+2 all UPI, Alt+3 all udhaar, F10 or Ctrl+Enter saves.
Future<PosPayment?> showPosPaymentDialog(
  BuildContext context, {
  required Money total,
  String? partyId,
  String? partyName,
}) => showDialog<PosPayment>(
  context: context,
  barrierColor: MkColors.scrim,
  builder: (_) =>
      PosPaymentDialog(total: total, partyId: partyId, partyName: partyName),
);

class PosPaymentDialog extends ConsumerStatefulWidget {
  const PosPaymentDialog({
    required this.total,
    super.key,
    this.partyId,
    this.partyName,
  });

  final Money total;
  final String? partyId;
  final String? partyName;

  @override
  ConsumerState<PosPaymentDialog> createState() => _PosPaymentState();
}

class _PosPaymentState extends ConsumerState<PosPaymentDialog> {
  late Money _cash = widget.total;
  Money _upi = Money.zero;
  Money _udhaar = Money.zero;
  String? _bankId;
  int _resets = 0;
  String? _error;

  PaymentSplit get _split =>
      PaymentSplit(cash: _cash, upi: _upi, udhaar: _udhaar);

  void _all({
    Money cash = Money.zero,
    Money upi = Money.zero,
    Money udhaar = Money.zero,
  }) {
    setState(() {
      _cash = cash;
      _upi = upi;
      _udhaar = udhaar;
      _resets++;
      _error = null;
    });
  }

  void _save(String? bankId) {
    final l10n = AppLocalizations.of(context);
    final check = PaymentChecks.validate(
      total: widget.total,
      payment: _split,
      partyId: widget.partyId,
    );
    String? error;
    if (check.errors.contains(PaymentIssue.udhaarNeedsParty)) {
      error = l10n.posErrorUdhaarParty;
    } else if (!check.ok) {
      error = l10n.posErrorPayMismatch;
    } else if (_upi.isPositive && bankId == null) {
      error = l10n.posErrorUpiAccount;
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(
      context,
    ).pop(PosPayment(_split, _upi.isPositive ? bankId : null));
  }

  Widget _field(
    String key,
    String label,
    Money value,
    ValueChanged<Money> onChanged,
  ) => MkNumberField(
    key: ValueKey('$key-$_resets'),
    label: label,
    initialValue: value.paise,
    onChanged: (v) => setState(() {
      onChanged(Money(v ?? 0));
      _error = null;
    }),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final banks = [
      for (final b
          in ref.watch(bankAccountListProvider()).value ??
              const <BankAccount>[])
        if (!b.isCash) b,
    ];
    final bankId = _bankId ?? (banks.length == 1 ? banks.first.id : null);
    final settings = ref.watch(shopSettingsProvider);
    final balance = widget.partyId == null
        ? null
        : ref.watch(partyBalancesProvider).value?[widget.partyId!] ??
              Money.zero;
    final over =
        widget.partyId != null && _udhaar.isPositive && settings != null
        ? CreditLimit.excess(
            (balance ?? Money.zero) - _udhaar,
            settings.creditLimitFor(widget.partyId),
          )
        : null;
    final left = widget.total - _split.sum;
    void save() => _save(bankId);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f10): save,
        const SingleActivator(LogicalKeyboardKey.enter, control: true): save,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): save,
        const SingleActivator(LogicalKeyboardKey.digit1, alt: true): () =>
            _all(cash: widget.total),
        const SingleActivator(LogicalKeyboardKey.digit2, alt: true): () =>
            _all(upi: widget.total),
        const SingleActivator(LogicalKeyboardKey.digit3, alt: true): () {
          if (widget.partyId == null) {
            setState(() => _error = l10n.posErrorUdhaarParty);
          } else {
            _all(udhaar: widget.total);
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: MkDialog(
          title: l10n.posPayTitle,
          maxWidth: 480,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.posTotal,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  MkMoneyText(widget.total, size: 22),
                ],
              ),
              const SizedBox(height: MkSpacing.md),
              Wrap(
                spacing: MkSpacing.sm,
                runSpacing: MkSpacing.sm,
                children: [
                  MkButton(
                    key: const ValueKey('pay-all-cash'),
                    label: '${l10n.posPayCash} (Alt+1)',
                    variant: MkButtonVariant.secondary,
                    onPressed: () => _all(cash: widget.total),
                  ),
                  MkButton(
                    key: const ValueKey('pay-all-upi'),
                    label: '${l10n.posPayUpi} (Alt+2)',
                    variant: MkButtonVariant.secondary,
                    onPressed: banks.isEmpty
                        ? null
                        : () => _all(upi: widget.total),
                  ),
                  MkButton(
                    key: const ValueKey('pay-all-udhaar'),
                    label: '${l10n.posPayUdhaar} (Alt+3)',
                    variant: MkButtonVariant.secondary,
                    onPressed: widget.partyId == null
                        ? null
                        : () => _all(udhaar: widget.total),
                  ),
                ],
              ),
              const SizedBox(height: MkSpacing.md),
              _field('pay-cash', l10n.posPayCash, _cash, (v) => _cash = v),
              const SizedBox(height: MkSpacing.sm),
              _field('pay-upi', l10n.posPayUpi, _upi, (v) => _upi = v),
              if (banks.isEmpty)
                Text(
                  l10n.posPayNoBank,
                  style: TextStyle(color: MkTokens.of(context).textMuted),
                )
              else if (banks.length > 1 && _upi.isPositive)
                Padding(
                  padding: const EdgeInsets.only(top: MkSpacing.sm),
                  child: DropdownButtonFormField<String>(
                    initialValue: _bankId,
                    decoration: InputDecoration(
                      labelText: l10n.posPayUpiAccount,
                    ),
                    items: [
                      for (final b in banks)
                        DropdownMenuItem(value: b.id, child: Text(b.label)),
                    ],
                    onChanged: (v) => setState(() => _bankId = v),
                  ),
                ),
              const SizedBox(height: MkSpacing.sm),
              _field(
                'pay-udhaar',
                l10n.posPayUdhaar,
                _udhaar,
                (v) => _udhaar = v,
              ),
              if (widget.partyId != null && balance != null)
                Padding(
                  padding: const EdgeInsets.only(top: MkSpacing.xs),
                  child: Text(
                    '${widget.partyName ?? ''} · '
                    '${l10n.posPayBalance(balance.format())}',
                  ),
                ),
              if (over != null)
                Padding(
                  padding: const EdgeInsets.only(top: MkSpacing.xs),
                  child: Text(
                    l10n.posPayCreditLimit(over.format()),
                    key: const ValueKey('credit-warning'),
                    style: const TextStyle(color: MkColors.udhaar),
                  ),
                ),
              const SizedBox(height: MkSpacing.sm),
              Text(
                left.isZero
                    ? l10n.posPayAllHint
                    : l10n.posPayRemaining(left.format()),
                key: const ValueKey('pay-left'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: MkSpacing.sm),
                  child: Text(
                    _error!,
                    key: const ValueKey('pay-error'),
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
              key: const ValueKey('pay-save'),
              label: '${l10n.posPaySave} (F10)',
              onPressed: save,
            ),
          ],
        ),
      ),
    );
  }
}
