import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_providers.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_mode_fields.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Opens "Record repayment" for the loan [loanId]. The split between byaj and
/// principal is shown BEFORE saving. Returns true once saved.
Future<bool?> showRepaymentDialog(
  BuildContext context,
  String loanId, {
  LedgerDate? date,
}) => showDialog<bool>(
  context: context,
  barrierColor: MkColors.scrim,
  builder: (_) => RepaymentDialog(loanId: loanId, date: date),
);

class RepaymentDialog extends ConsumerStatefulWidget {
  const RepaymentDialog({required this.loanId, super.key, this.date});

  final String loanId;

  /// The day to start from (the loan screen's as-of date); today when null.
  final LedgerDate? date;

  @override
  ConsumerState<RepaymentDialog> createState() => _RepaymentState();
}

class _RepaymentState extends ConsumerState<RepaymentDialog> {
  Money? _amount;
  int _amountResets = 0;
  late LedgerDate _date =
      widget.date ?? LedgerDate.fromDateTime(DateTime.now());
  RepaymentSource _source = RepaymentSource.payment;
  PaymentMode _mode = PaymentMode.cash;
  String? _bankId;
  LedgerDate? _chequeDate;
  final _reference = TextEditingController();
  final _chequeNo = TextEditingController();
  final _narration = TextEditingController();
  bool _saving = false;
  bool _submitted = false;
  String? _error;
  List<PaymentProblem>? _paymentProblems;

  @override
  void dispose() {
    _reference.dispose();
    _chequeNo.dispose();
    _narration.dispose();
    super.dispose();
  }

  void _setAmount(Money m) => setState(() {
    _amount = m;
    _amountResets++;
  });

  Future<void> _save(LoanDetail detail, Money cropAvailable) async {
    setState(() => _submitted = true);
    final amount = _amount;
    if (amount == null || !amount.isPositive) return;
    final preview = detail.previewRepayment(_date, amount);
    if (preview.exceedsPayable) return;
    if (_source == RepaymentSource.cropProceeds && amount > cropAvailable) {
      return;
    }
    final banks = ref.read(bankAccountListProvider()).value ?? const [];
    final bankId =
        _bankId ??
        (banks.where((b) => !b.isCash).length == 1
            ? banks.firstWhere((b) => !b.isCash).id
            : null);
    final draft = LoanRepaymentDraft(
      loanId: widget.loanId,
      date: _date,
      amount: amount,
      source: _source,
      mode: _mode,
      bankAccountId: _mode.usesCashAccount ? null : bankId,
      reference: _reference.text,
      chequeNo: _chequeNo.text,
      chequeDate: _chequeDate,
      narration: _narration.text,
    );
    setState(() {
      _saving = true;
      _error = null;
      _paymentProblems = null;
    });
    final result = await ref.read(loanWriterProvider).repay(draft);
    if (!mounted) return;
    final error = AppLocalizations.of(context).loanSaveError(result);
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
        if (result is LoanInvalid) _paymentProblems = result.paymentProblems;
      });
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).loanRepaid)),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(loanDetailProvider(widget.loanId)).value;
    if (detail == null) {
      return MkDialog(
        title: l10n.loanRepayTitle,
        content: const Center(child: CircularProgressIndicator()),
      );
    }
    final canCrop = ref.watch(canProvider(Permission.entriesReverse));
    final canFinance = ref.watch(canProvider(Permission.financeView));
    final modes = canFinance ? PaymentMode.values : [PaymentMode.cash];
    final banks = [
      for (final b
          in ref.watch(bankAccountListProvider()).value ??
              const <BankAccount>[])
        if (!b.isCash) b,
    ];
    final bankId = _bankId ?? (banks.length == 1 ? banks.first.id : null);
    final balance =
        ref.watch(partyBalancesProvider).value?[detail.loan.partyId] ??
        Money.zero;
    final cropAvailable = LoanRules.cropProceedsAvailable(balance);
    final amount = _amount;
    final payable = detail
        .previewRepayment(_date, const Money(1))
        .payableBefore;
    final preview = amount != null && amount.isPositive
        ? detail.previewRepayment(_date, amount)
        : null;
    final tokens = MkTokens.of(context);
    final cropOver =
        _source == RepaymentSource.cropProceeds &&
        amount != null &&
        amount > cropAvailable;
    final exceeds = preview?.exceedsPayable ?? false;
    final amountError = _submitted && !(amount?.isPositive ?? false)
        ? l10n.loanErrorAmount
        : exceeds
        ? l10n.loanErrorExceeds(preview!.payableBefore.format())
        : cropOver
        ? l10n.loanErrorExceedsCrop(cropAvailable.format())
        : null;

    Widget line(String label, Widget value, {Key? key}) => Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          value,
        ],
      ),
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f10): () =>
            _save(detail, cropAvailable),
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
            _save(detail, cropAvailable),
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): () =>
            _save(detail, cropAvailable),
      },
      child: MkDialog(
        title: '${l10n.loanRepayTitle} · ${detail.loan.loanNo}',
        maxWidth: 520,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              detail.loan.partyName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: MkSpacing.md),
            PaymentDateField(
              key: const ValueKey('repay-date'),
              label: l10n.loanRepayDate,
              date: _date,
              onChanged: (d) => setState(() => _date = d),
            ),
            const SizedBox(height: MkSpacing.md),
            if (canCrop) ...[
              SegmentedButton<RepaymentSource>(
                key: const ValueKey('repay-source'),
                segments: [
                  ButtonSegment(
                    value: RepaymentSource.payment,
                    label: Text(l10n.loanRepaySourcePay),
                  ),
                  ButtonSegment(
                    value: RepaymentSource.cropProceeds,
                    label: Text(l10n.loanRepaySourceCrop),
                  ),
                ],
                selected: {_source},
                onSelectionChanged: (s) => setState(() => _source = s.first),
              ),
              const SizedBox(height: MkSpacing.md),
            ],
            MkNumberField(
              key: ValueKey('repay-amount-$_amountResets'),
              label: l10n.loanRepayAmount,
              initialValue: _amount?.paise,
              autofocus: true,
              errorText: amountError,
              onChanged: (p) =>
                  setState(() => _amount = p == null ? null : Money(p)),
            ),
            const SizedBox(height: MkSpacing.sm),
            Wrap(
              spacing: MkSpacing.sm,
              runSpacing: MkSpacing.xs,
              children: [
                if (payable.isPositive)
                  ActionChip(
                    key: const ValueKey('repay-full'),
                    label: Text(
                      '${l10n.loanRepayFullPayable} · ${payable.format()}',
                    ),
                    onPressed: () => _setAmount(
                      _source == RepaymentSource.cropProceeds &&
                              payable > cropAvailable
                          ? cropAvailable
                          : payable,
                    ),
                  ),
              ],
            ),
            if (_source == RepaymentSource.cropProceeds) ...[
              const SizedBox(height: MkSpacing.sm),
              Text(
                cropAvailable.isPositive
                    ? l10n.loanRepayCropAvailable(cropAvailable.format())
                    : l10n.loanRepayCropNone,
                key: const ValueKey('repay-crop-available'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: MkSpacing.md),
            MkCard(
              key: const ValueKey('repay-preview'),
              title: l10n.loanPreviewTitle,
              child: Column(
                children: [
                  line(
                    l10n.loanPreviewBefore,
                    MkMoneyText(preview?.payableBefore ?? payable),
                  ),
                  if (preview != null) ...[
                    line(
                      l10n.loanPreviewInterest,
                      MkMoneyText(
                        preview.interest,
                        key: const ValueKey('repay-preview-interest'),
                        tone: MkMoneyTone.jama,
                      ),
                    ),
                    line(
                      l10n.loanPreviewPrincipal,
                      MkMoneyText(
                        preview.principal,
                        key: const ValueKey('repay-preview-principal'),
                        tone: MkMoneyTone.jama,
                      ),
                    ),
                    Divider(color: tokens.border),
                    line(
                      l10n.loanPreviewAfter,
                      MkMoneyText(
                        exceeds ? Money.zero : preview.payableAfter,
                        key: const ValueKey('repay-preview-after'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_source == RepaymentSource.cropProceeds) ...[
              const SizedBox(height: MkSpacing.sm),
              Text(
                l10n.loanPreviewCropNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else ...[
              const SizedBox(height: MkSpacing.md),
              PaymentModeFields(
                modes: modes,
                mode: _mode,
                onMode: (m) => setState(() => _mode = m),
                banks: banks,
                bankId: bankId,
                onBank: (id) => setState(() => _bankId = id),
                reference: _reference,
                chequeNo: _chequeNo,
                chequeDate: _chequeDate,
                onChequeDate: (d) => setState(() => _chequeDate = d),
                problems: _paymentProblems,
              ),
            ],
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('repay-narration'),
              controller: _narration,
              label: l10n.paymentFieldNarration,
              maxLines: 2,
            ),
            if (_error != null) ...[
              const SizedBox(height: MkSpacing.md),
              Text(
                _error!,
                key: const ValueKey('repay-error'),
                style: TextStyle(color: tokens.udhaar),
              ),
            ],
          ],
        ),
        actions: [
          MkButton(
            label: l10n.commonCancel,
            variant: MkButtonVariant.ghost,
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          ),
          MkButton(
            key: const ValueKey('repay-save'),
            label: l10n.loanRepaySave,
            icon: Icons.check,
            onPressed: _saving || exceeds || cropOver
                ? null
                : () => _save(detail, cropAvailable),
          ),
        ],
      ),
    );
  }
}
