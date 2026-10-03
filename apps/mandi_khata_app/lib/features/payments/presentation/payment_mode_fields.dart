import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// A date field that opens the date picker.
class PaymentDateField extends StatelessWidget {
  const PaymentDateField({
    required this.label,
    required this.date,
    required this.onChanged,
    super.key,
    this.errorText,
  });

  final String label;
  final LedgerDate? date;
  final ValueChanged<LedgerDate> onChanged;
  final String? errorText;

  Future<void> _pick(BuildContext context) async {
    final d = date ?? LedgerDate.fromDateTime(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(d.year, d.month, d.day),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (picked != null) onChanged(LedgerDate.fromDateTime(picked));
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _pick(context),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
      ),
      child: Text(date == null ? '' : AppFormat.ledgerDate(context, date!)),
    ),
  );
}

/// How the money moved: mode chips and the details that mode needs (bank
/// account, UTR, cheque number and date).
class PaymentModeFields extends StatelessWidget {
  const PaymentModeFields({
    required this.modes,
    required this.mode,
    required this.onMode,
    required this.banks,
    required this.bankId,
    required this.onBank,
    required this.reference,
    required this.chequeNo,
    required this.chequeDate,
    required this.onChequeDate,
    required this.problems,
    super.key,
  });

  /// Modes this member may use (cash only without finance access).
  final List<PaymentMode> modes;
  final PaymentMode mode;
  final ValueChanged<PaymentMode> onMode;
  final List<BankAccount> banks;
  final String? bankId;
  final ValueChanged<String?> onBank;
  final TextEditingController reference;
  final TextEditingController chequeNo;
  final LedgerDate? chequeDate;
  final ValueChanged<LedgerDate> onChequeDate;

  /// Set after a failed save attempt, to show what is missing.
  final List<PaymentProblem>? problems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shown = problems ?? const <PaymentProblem>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: MkSpacing.sm,
          runSpacing: MkSpacing.sm,
          children: [
            for (final m in modes)
              ChoiceChip(
                key: ValueKey('payment-mode-${m.name}'),
                label: Text(l10n.paymentModeName(m)),
                selected: m == mode,
                onSelected: (_) => onMode(m),
              ),
          ],
        ),
        if (!mode.usesCashAccount) ...[
          const SizedBox(height: MkSpacing.md),
          if (banks.isEmpty)
            Text(
              l10n.paymentNoBankAccounts,
              key: const ValueKey('payment-no-banks'),
            )
          else
            DropdownButtonFormField<String>(
              key: const ValueKey('payment-bank'),
              initialValue: bankId,
              decoration: InputDecoration(
                labelText: l10n.paymentFieldAccount,
                errorText: shown.contains(PaymentProblem.bankAccountMissing)
                    ? l10n.paymentErrorBank
                    : null,
              ),
              items: [
                for (final b in banks)
                  DropdownMenuItem(value: b.id, child: Text(b.label)),
              ],
              onChanged: onBank,
            ),
        ],
        if (mode == PaymentMode.bank || mode == PaymentMode.upi) ...[
          const SizedBox(height: MkSpacing.md),
          MkTextField(
            key: const ValueKey('payment-reference'),
            controller: reference,
            label: l10n.paymentFieldReference,
          ),
        ],
        if (mode == PaymentMode.cheque) ...[
          const SizedBox(height: MkSpacing.md),
          MkTextField(
            key: const ValueKey('payment-cheque-no'),
            controller: chequeNo,
            label: l10n.paymentFieldChequeNo,
            errorText: shown.contains(PaymentProblem.chequeNoMissing)
                ? l10n.paymentErrorChequeNo
                : null,
          ),
          const SizedBox(height: MkSpacing.md),
          PaymentDateField(
            key: const ValueKey('payment-cheque-date'),
            label: l10n.paymentFieldChequeDate,
            date: chequeDate,
            onChanged: onChequeDate,
            errorText: shown.contains(PaymentProblem.chequeDateMissing)
                ? l10n.paymentErrorChequeDate
                : null,
          ),
        ],
      ],
    );
  }
}
