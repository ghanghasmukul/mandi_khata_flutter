import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_line.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_picker.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_mode_fields.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/payments/presentation/receipt_actions.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Opens "Record payment": paid to a party (default) or received from one.
/// Shows the party's baki now and after this payment, with quick amounts.
/// Once saved it offers the receipt (print / share). Returns the saved
/// payment's id, or null when cancelled.
Future<String?> showRecordPaymentDialog(
  BuildContext context, {
  Party? party,
  PaymentDirection direction = PaymentDirection.toParty,
}) => showDialog<String>(
  context: context,
  barrierColor: MkColors.scrim,
  builder: (_) => RecordPaymentDialog(party: party, direction: direction),
);

class RecordPaymentDialog extends ConsumerStatefulWidget {
  const RecordPaymentDialog({required this.direction, super.key, this.party});

  final Party? party;
  final PaymentDirection direction;

  @override
  ConsumerState<RecordPaymentDialog> createState() => _RecordPaymentState();
}

class _RecordPaymentState extends ConsumerState<RecordPaymentDialog> {
  late PaymentDirection _direction = widget.direction;
  late Party? _party = widget.party;
  Money? _amount;
  int _amountResets = 0;
  late LedgerDate _date = LedgerDate.fromDateTime(DateTime.now());
  PaymentMode _mode = PaymentMode.cash;
  String? _bankId;
  LedgerDate? _chequeDate;
  final _reference = TextEditingController();
  final _chequeNo = TextEditingController();
  final _narration = TextEditingController();
  bool _saving = false;
  bool _submitted = false;
  String? _error;
  List<PaymentProblem>? _problems;

  /// Set once saved: what to show and print.
  Payment? _saved;
  Money? _balanceAfter;

  @override
  void dispose() {
    _reference.dispose();
    _chequeNo.dispose();
    _narration.dispose();
    super.dispose();
  }

  PaymentDraft? _draft(String? bankId) {
    final party = _party;
    final amount = _amount;
    if (party == null || amount == null) return null;
    return PaymentDraft(
      entryDate: _date,
      partyId: party.id,
      direction: _direction,
      mode: _mode,
      amount: amount,
      bankAccountId: _mode.usesCashAccount ? null : bankId,
      reference: _reference.text,
      chequeNo: _chequeNo.text,
      chequeDate: _chequeDate,
      narration: _narration.text,
    );
  }

  void _setAmount(Money m) => setState(() {
    _amount = m;
    _amountResets++;
  });

  Future<void> _save(Money balance, String? bankId) async {
    setState(() => _submitted = true);
    final draft = _draft(bankId);
    if (draft == null) return;
    final problems = draft.validate();
    if (problems.isNotEmpty) {
      setState(() => _problems = problems);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _problems = null;
    });
    final result = await ref.read(paymentWriterProvider).save(draft);
    if (!mounted) return;
    final error = AppLocalizations.of(context).paymentSaveError(result);
    if (error != null || result is! PaymentSaved) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    final tenantId = ref.read(activeTenantProvider);
    final repo = await ref.read(paymentsRepositoryProvider.future);
    final saved = tenantId == null
        ? null
        : await repo.watchOne(tenantId, result.id).first;
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved = saved;
      _balanceAfter = PaymentRules.balanceAfter(
        balance,
        _direction,
        draft.amount,
      );
    });
    if (saved == null) Navigator.of(context).pop(result.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saved = _saved;
    if (saved != null) return _savedView(context, l10n, saved);

    final canFinance = ref.watch(canProvider(Permission.financeView));
    final modes = canFinance ? PaymentMode.values : [PaymentMode.cash];
    final banks = [
      for (final b
          in ref.watch(bankAccountListProvider()).value ??
              const <BankAccount>[])
        if (!b.isCash) b,
    ];
    final bankId = _bankId ?? (banks.length == 1 ? banks.first.id : null);
    final balance = _party == null
        ? Money.zero
        : ref.watch(partyBalancesProvider).value?[_party!.id] ?? Money.zero;
    final full = PaymentRules.fullBaki(balance, _direction);
    final after = _amount == null
        ? null
        : PaymentRules.balanceAfter(balance, _direction, _amount!);
    final isFarmer = _party?.roles.contains(PartyRole.farmer) ?? false;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f10): () =>
            _save(balance, bankId),
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
            _save(balance, bankId),
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): () =>
            _save(balance, bankId),
      },
      child: MkDialog(
        title: l10n.paymentRecordTitle,
        maxWidth: 520,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<PaymentDirection>(
                key: const ValueKey('payment-direction'),
                segments: [
                  ButtonSegment(
                    value: PaymentDirection.toParty,
                    label: Text(l10n.paymentDirectionTo),
                  ),
                  ButtonSegment(
                    value: PaymentDirection.fromParty,
                    label: Text(l10n.paymentDirectionFrom),
                  ),
                ],
                selected: {_direction},
                onSelectionChanged: (s) => setState(() => _direction = s.first),
              ),
              const SizedBox(height: MkSpacing.md),
              PartyPicker(
                role: null,
                selected: _party,
                onSelected: (p) => setState(() => _party = p),
                label: l10n.khataFieldParty,
                hint: l10n.khataFieldPartyHint,
                autofocus: widget.party == null,
                errorText: _submitted && _party == null
                    ? l10n.partyErrorRequired
                    : null,
              ),
              if (_party != null) ...[
                const SizedBox(height: MkSpacing.sm),
                _BakiRow(
                  label: l10n.paymentBakiNow,
                  balance: balance,
                  isFarmer: isFarmer,
                ),
              ],
              const SizedBox(height: MkSpacing.md),
              MkNumberField(
                key: ValueKey('payment-amount-$_amountResets'),
                label: l10n.paymentFieldAmount,
                initialValue: _amount?.paise,
                autofocus: widget.party != null,
                errorText: _submitted && !(_amount?.isPositive ?? false)
                    ? l10n.paymentErrorAmount
                    : null,
                onChanged: (p) =>
                    setState(() => _amount = p == null ? null : Money(p)),
              ),
              const SizedBox(height: MkSpacing.sm),
              Wrap(
                spacing: MkSpacing.sm,
                runSpacing: MkSpacing.xs,
                children: [
                  if (full != null)
                    ActionChip(
                      key: const ValueKey('payment-full-baki'),
                      label: Text('${l10n.paymentFullBaki} · ${full.format()}'),
                      onPressed: () => _setAmount(full),
                    ),
                  for (final r in const [500, 1000, 5000])
                    ActionChip(
                      key: ValueKey('payment-quick-$r'),
                      label: Text(Money.rupees(r).format()),
                      onPressed: () => _setAmount(Money.rupees(r)),
                    ),
                ],
              ),
              if (after != null) ...[
                const SizedBox(height: MkSpacing.sm),
                _BakiRow(
                  key: const ValueKey('payment-baki-after'),
                  label: l10n.paymentBakiAfter,
                  balance: after,
                  isFarmer: isFarmer,
                ),
              ],
              const SizedBox(height: MkSpacing.md),
              PaymentDateField(
                key: const ValueKey('payment-date'),
                label: l10n.paymentFieldDate,
                date: _date,
                onChanged: (d) => setState(() => _date = d),
              ),
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
                problems: _problems,
              ),
              const SizedBox(height: MkSpacing.md),
              MkTextField(
                key: const ValueKey('payment-narration'),
                controller: _narration,
                label: l10n.paymentFieldNarration,
                maxLines: 2,
              ),
              if (_error != null) ...[
                const SizedBox(height: MkSpacing.md),
                Text(
                  _error!,
                  key: const ValueKey('payment-error'),
                  style: TextStyle(color: MkTokens.of(context).udhaar),
                ),
              ],
            ],
          ),
        ),
        actions: [
          MkButton(
            label: l10n.commonCancel,
            variant: MkButtonVariant.ghost,
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
          MkButton(
            key: const ValueKey('payment-save'),
            label: l10n.paymentSave,
            icon: Icons.check,
            onPressed: _saving ? null : () => _save(balance, bankId),
          ),
        ],
      ),
    );
  }

  Widget _savedView(
    BuildContext context,
    AppLocalizations l10n,
    Payment saved,
  ) {
    final party = _party;
    return MkDialog(
      title: l10n.paymentSavedAs(saved.receiptNo),
      content: Column(
        key: const ValueKey('payment-saved'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(saved.partyName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: MkSpacing.xs),
          MkMoneyText(
            saved.amount,
            size: 22,
            tone: saved.direction == PaymentDirection.toParty
                ? MkMoneyTone.udhaar
                : MkMoneyTone.jama,
          ),
          if (_balanceAfter != null) ...[
            const SizedBox(height: MkSpacing.sm),
            _BakiRow(
              label: l10n.paymentBakiAfter,
              balance: _balanceAfter!,
              isFarmer: party?.roles.contains(PartyRole.farmer) ?? false,
            ),
          ],
        ],
      ),
      actions: [
        MkButton(
          key: const ValueKey('payment-print'),
          label: l10n.paymentPrintReceipt,
          icon: Icons.print_outlined,
          variant: MkButtonVariant.secondary,
          onPressed: () => PaymentReceipts.print(
            ref,
            saved,
            party: party,
            balanceAfter: _balanceAfter,
          ),
        ),
        MkButton(
          key: const ValueKey('payment-share'),
          label: l10n.paymentShareReceipt,
          icon: Icons.share_outlined,
          variant: MkButtonVariant.secondary,
          onPressed: () => PaymentReceipts.share(
            ref,
            saved,
            party: party,
            balanceAfter: _balanceAfter,
          ),
        ),
        MkButton(
          key: const ValueKey('payment-done'),
          label: l10n.paymentDone,
          icon: Icons.check,
          onPressed: () => Navigator.of(context).pop(saved.id),
        ),
      ],
    );
  }
}

class _BakiRow extends StatelessWidget {
  const _BakiRow({
    required this.label,
    required this.balance,
    required this.isFarmer,
    super.key,
  });

  final String label;
  final Money balance;
  final bool isFarmer;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
      KhataBalanceChip(balance: balance, isFarmer: isFarmer),
    ],
  );
}
