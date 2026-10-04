import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_terms_editor.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_picker.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_mode_fields.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_tile.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Opens "Issue loan" (owner). The interest terms start from the settings
/// cascade for the borrower and are snapshotted on the loan. Returns the new
/// loan's id, or null when cancelled.
Future<String?> showIssueLoanDialog(BuildContext context, {Party? party}) =>
    showDialog<String>(
      context: context,
      barrierColor: MkColors.scrim,
      builder: (_) => IssueLoanDialog(party: party),
    );

class IssueLoanDialog extends ConsumerStatefulWidget {
  const IssueLoanDialog({super.key, this.party});

  final Party? party;

  @override
  ConsumerState<IssueLoanDialog> createState() => _IssueLoanState();
}

class _IssueLoanState extends ConsumerState<IssueLoanDialog> {
  late Party? _party = widget.party;
  Party? _guarantor;
  Money? _amount;
  late LedgerDate _issueDate = LedgerDate.fromDateTime(DateTime.now());
  LedgerDate? _dueDate;
  final _purpose = TextEditingController();
  PaymentMode _mode = PaymentMode.cash;
  String? _bankId;
  LedgerDate? _chequeDate;
  final _reference = TextEditingController();
  final _chequeNo = TextEditingController();

  /// The terms as edited; null until the person edits them (then the cascade
  /// values for the borrower are used) or while the rate is invalid.
  InterestConfig? _edited;
  bool _termsTouched = false;
  bool _saving = false;
  bool _submitted = false;
  String? _error;
  List<PaymentProblem>? _paymentProblems;

  @override
  void dispose() {
    _purpose.dispose();
    _reference.dispose();
    _chequeNo.dispose();
    super.dispose();
  }

  SettingsTarget get _target => (
    partyId: _party?.id,
    partyGroupId: _party?.partyGroupId,
    documentId: null,
  );

  /// The cascade's terms for the chosen borrower.
  InterestConfig _seed(SettingsResolver? resolver) => resolver == null
      ? InterestConfig(ratePa: Decimal.fromInt(18))
      : InterestConfig.fromSettings(
          resolver,
          partyId: _party?.id,
          partyGroupId: _party?.partyGroupId,
          partyRoles: _party?.roles ?? const {},
        );

  Future<void> _save(SettingsResolver? resolver) async {
    setState(() => _submitted = true);
    final party = _party;
    final amount = _amount;
    final config = _termsTouched ? _edited : _seed(resolver);
    if (party == null || amount == null || config == null) return;
    final banks = ref.read(bankAccountListProvider()).value ?? const [];
    final bankId =
        _bankId ??
        (banks.where((b) => !b.isCash).length == 1 ? _firstBank(banks) : null);
    final draft = LoanDraft(
      partyId: party.id,
      amount: amount,
      issueDate: _issueDate,
      dueDate: _dueDate,
      purpose: _purpose.text,
      guarantorPartyId: _guarantor?.id,
      config: config,
      mode: _mode,
      bankAccountId: _mode.usesCashAccount ? null : bankId,
      reference: _reference.text,
      chequeNo: _chequeNo.text,
      chequeDate: _chequeDate,
    );
    setState(() {
      _saving = true;
      _error = null;
      _paymentProblems = null;
    });
    final result = await ref.read(loanWriterProvider).issue(draft);
    if (!mounted) return;
    final error = AppLocalizations.of(context).loanSaveError(result);
    if (error != null || result is! LoanSaved) {
      setState(() {
        _saving = false;
        _error = error;
        if (result is LoanInvalid) _paymentProblems = result.paymentProblems;
      });
      return;
    }
    Navigator.of(context).pop(result.id);
  }

  String? _firstBank(List<BankAccount> banks) {
    for (final b in banks) {
      if (!b.isCash) return b.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resolver = ref.watch(settingsResolverProvider(_target));
    final seed = _seed(resolver);
    final canFinance = ref.watch(canProvider(Permission.financeView));
    final modes = canFinance ? PaymentMode.values : [PaymentMode.cash];
    final banks = [
      for (final b
          in ref.watch(bankAccountListProvider()).value ??
              const <BankAccount>[])
        if (!b.isCash) b,
    ];
    final bankId = _bankId ?? (banks.length == 1 ? banks.first.id : null);
    final nextNo = ref.watch(nextLoanNoProvider).value;
    final source = resolver?.resolve(
      'interest.rate_pa',
      partyId: _party?.id,
      partyGroupId: _party?.partyGroupId,
    );
    final perMonth =
        resolver
            ?.resolve(
              'interest.rate_unit_display',
              partyId: _party?.id,
              partyGroupId: _party?.partyGroupId,
            )
            .value ==
        'per100_per_month';
    final wholeKhata =
        resolver
            ?.resolve(
              'interest.apply_on',
              partyId: _party?.id,
              partyGroupId: _party?.partyGroupId,
            )
            .value ==
        'net_udhaar';
    final termsInvalid = _termsTouched && _edited == null;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f10): () => _save(resolver),
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
            _save(resolver),
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): () =>
            _save(resolver),
      },
      child: MkDialog(
        title: l10n.loanIssueTitle,
        maxWidth: 560,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (nextNo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: MkSpacing.sm),
                child: Text(
                  l10n.loanNextNo(nextNo),
                  key: const ValueKey('loan-next-no'),
                  style: MkText.mono(),
                ),
              ),
            PartyPicker(
              role: null,
              selected: _party,
              onSelected: (p) => setState(() {
                _party = p;
                // The cascade is per party: take its terms again unless the
                // person already chose their own.
                if (!_termsTouched) _edited = null;
              }),
              label: l10n.loanFieldBorrower,
              hint: l10n.khataFieldPartyHint,
              autofocus: widget.party == null,
              errorText: _submitted && _party == null
                  ? l10n.partyErrorRequired
                  : null,
            ),
            const SizedBox(height: MkSpacing.md),
            MkNumberField(
              key: const ValueKey('loan-amount'),
              label: l10n.loanFieldAmount,
              autofocus: widget.party != null,
              errorText: _submitted && !(_amount?.isPositive ?? false)
                  ? l10n.loanErrorAmount
                  : null,
              onChanged: (p) =>
                  setState(() => _amount = p == null ? null : Money(p)),
            ),
            const SizedBox(height: MkSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PaymentDateField(
                    key: const ValueKey('loan-issue-date'),
                    label: l10n.loanFieldIssueDate,
                    date: _issueDate,
                    onChanged: (d) => setState(() => _issueDate = d),
                  ),
                ),
                const SizedBox(width: MkSpacing.md),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: PaymentDateField(
                          key: const ValueKey('loan-due-date'),
                          label: l10n.loanFieldDueDate,
                          date: _dueDate,
                          onChanged: (d) => setState(() => _dueDate = d),
                          errorText: _dueDate != null && _dueDate! < _issueDate
                              ? l10n.loanErrorDue
                              : null,
                        ),
                      ),
                      if (_dueDate != null)
                        IconButton(
                          key: const ValueKey('loan-due-clear'),
                          tooltip: l10n.loanClearDate,
                          onPressed: () => setState(() => _dueDate = null),
                          icon: const Icon(Icons.clear, size: 18),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('loan-purpose'),
              controller: _purpose,
              label: l10n.loanFieldPurpose,
              maxLines: 2,
            ),
            const SizedBox(height: MkSpacing.md),
            PartyPicker(
              key: const ValueKey('loan-guarantor'),
              role: null,
              selected: _guarantor,
              onSelected: (p) => setState(() => _guarantor = p),
              label: l10n.loanFieldGuarantor,
              hint: l10n.khataFieldPartyHint,
              errorText: _guarantor != null && _guarantor!.id == _party?.id
                  ? l10n.loanErrorGuarantor
                  : null,
            ),
            const Divider(height: MkSpacing.xxl),
            Text(
              l10n.loanTermsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (source != null) ...[
              const SizedBox(height: MkSpacing.xs),
              Text(
                l10n.loanTermsFrom(settingSourceText(l10n, source.level)),
                key: const ValueKey('loan-terms-from'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: MkSpacing.sm),
            LoanTermsEditor(
              // Re-seeded when the borrower (and so the cascade) changes.
              key: ValueKey('terms-${_party?.id}-${resolver != null}'),
              initial: _termsTouched ? (_edited ?? seed) : seed,
              perMonthInitially: perMonth,
              showRateError: _submitted || termsInvalid,
              onChanged: (c) => setState(() {
                _termsTouched = true;
                _edited = c;
              }),
            ),
            if (wholeKhata) ...[
              const SizedBox(height: MkSpacing.sm),
              Container(
                key: const ValueKey('loan-notice-net'),
                padding: const EdgeInsets.all(MkSpacing.md),
                decoration: BoxDecoration(
                  color: MkTokens.of(context).background2,
                  borderRadius: BorderRadius.circular(MkRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: MkSpacing.sm),
                    Expanded(child: Text(l10n.loanNoticeNetUdhaar)),
                  ],
                ),
              ),
            ],
            const Divider(height: MkSpacing.xxl),
            Text(
              l10n.loanPayOutTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: MkSpacing.sm),
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
            if (_error != null) ...[
              const SizedBox(height: MkSpacing.md),
              Text(
                _error!,
                key: const ValueKey('loan-error'),
                style: TextStyle(color: MkTokens.of(context).udhaar),
              ),
            ],
          ],
        ),
        actions: [
          MkButton(
            label: l10n.commonCancel,
            variant: MkButtonVariant.ghost,
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
          MkButton(
            key: const ValueKey('loan-save'),
            label: l10n.loanSaveIssue,
            icon: Icons.check,
            onPressed: _saving ? null : () => _save(resolver),
          ),
        ],
      ),
    );
  }
}
