import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/rate_input.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_mode_fields.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The rate as "18% a year".
String loanRateText(AppLocalizations l10n, Decimal pa) =>
    l10n.loanRatePa(pa.toString());

/// Opens "Change rate" (owner): a new rate from an effective date, with a
/// reason. The old rate stays in the statement for the days before. Returns
/// true once saved.
Future<bool?> showChangeRateDialog(BuildContext context, LoanDetail detail) =>
    showDialog<bool>(
      context: context,
      barrierColor: MkColors.scrim,
      builder: (_) => _ChangeRateDialog(detail: detail),
    );

class _ChangeRateDialog extends ConsumerStatefulWidget {
  const _ChangeRateDialog({required this.detail});

  final LoanDetail detail;

  @override
  ConsumerState<_ChangeRateDialog> createState() => _ChangeRateState();
}

class _ChangeRateState extends ConsumerState<_ChangeRateDialog> {
  Decimal? _rate;
  late LedgerDate _effective = LedgerDate.fromDateTime(DateTime.now());
  final _reason = TextEditingController();
  bool _saving = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Decimal get _current {
    final today = LedgerDate.fromDateTime(DateTime.now());
    var rate = widget.detail.loan.config.ratePa;
    for (final c in widget.detail.rateChanges) {
      if (c.effectiveDate <= today) rate = c.ratePa;
    }
    return rate;
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final rate = _rate;
    if (rate == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref
        .read(loanWriterProvider)
        .changeRate(
          widget.detail.loan.id,
          ratePa: rate.toString(),
          effectiveDate: _effective,
          reason: _reason.text,
        );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final error = l10n.loanSaveError(result);
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(l10n.loanRateChanged)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f10): _save,
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _save,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _save,
      },
      child: MkDialog(
        title: '${l10n.loanRateTitle} · ${widget.detail.loan.loanNo}',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.loanRateCurrent(loanRateText(l10n, _current)),
              key: const ValueKey('rate-current'),
            ),
            const SizedBox(height: MkSpacing.md),
            RateInput(
              initialPa: null,
              autofocus: true,
              errorText: _submitted && _rate == null
                  ? l10n.loanErrorRate
                  : null,
              onChanged: (pa) => setState(() => _rate = pa),
            ),
            const SizedBox(height: MkSpacing.md),
            PaymentDateField(
              key: const ValueKey('rate-effective'),
              label: l10n.loanRateEffective,
              date: _effective,
              onChanged: (d) => setState(() => _effective = d),
              errorText: _effective < widget.detail.loan.issueDate
                  ? l10n.loanErrorEffective
                  : null,
            ),
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('rate-reason'),
              controller: _reason,
              label: l10n.loanRateReason,
              maxLines: 2,
            ),
            if (_error != null) ...[
              const SizedBox(height: MkSpacing.md),
              Text(
                _error!,
                key: const ValueKey('rate-error'),
                style: TextStyle(color: MkTokens.of(context).udhaar),
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
            key: const ValueKey('rate-save'),
            label: l10n.loanRateSave,
            icon: Icons.check,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

/// Opens "Close loan" ([writeOff] false: nothing may be left to pay) or
/// "Write off" (a reason is required). Owner only. Returns true once saved.
Future<bool?> showCloseLoanDialog(
  BuildContext context,
  LoanDetail detail, {
  required bool writeOff,
}) => showDialog<bool>(
  context: context,
  barrierColor: MkColors.scrim,
  builder: (_) => _CloseLoanDialog(detail: detail, writeOff: writeOff),
);

class _CloseLoanDialog extends ConsumerStatefulWidget {
  const _CloseLoanDialog({required this.detail, required this.writeOff});

  final LoanDetail detail;
  final bool writeOff;

  @override
  ConsumerState<_CloseLoanDialog> createState() => _CloseLoanState();
}

class _CloseLoanState extends ConsumerState<_CloseLoanDialog> {
  late LedgerDate _date = _initialDate();
  final _reason = TextEditingController();
  bool _saving = false;
  bool _submitted = false;
  String? _error;

  LedgerDate _initialDate() {
    final today = LedgerDate.fromDateTime(DateTime.now());
    final last = widget.detail.lastEntryDate;
    return today < last ? last : today;
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final l10n = AppLocalizations.of(context);
    final reason = _reason.text.trim();
    if (widget.writeOff && reason.isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final writer = ref.read(loanWriterProvider);
    final id = widget.detail.loan.id;
    final result = widget.writeOff
        ? await writer.writeOff(id, closedOn: _date, reason: reason)
        : await writer.close(id, closedOn: _date, reason: reason);
    if (!mounted) return;
    final error = l10n.loanSaveError(result);
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          widget.writeOff ? l10n.loanWrittenOffDone : l10n.loanClosedDone,
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final payable = widget.detail.position(_date).payable;
    final blocked = !widget.writeOff && payable.isPositive;
    final nothing = widget.writeOff && !payable.isPositive;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f10): _save,
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _save,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _save,
      },
      child: MkDialog(
        title:
            '${widget.writeOff ? l10n.loanWriteOffTitle : l10n.loanCloseTitle}'
            ' · ${widget.detail.loan.loanNo}',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.detail.loan.partyName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: MkSpacing.md),
            PaymentDateField(
              key: const ValueKey('close-date'),
              label: l10n.loanCloseDate,
              date: _date,
              onChanged: (d) => setState(() => _date = d),
              errorText: _date < widget.detail.lastEntryDate
                  ? l10n.loanErrorClosedBefore
                  : null,
            ),
            const SizedBox(height: MkSpacing.md),
            if (blocked)
              Text(
                l10n.loanCloseStillDue(payable.format()),
                key: const ValueKey('close-still-due'),
                style: TextStyle(color: MkTokens.of(context).udhaar),
              )
            else if (nothing)
              Text(
                l10n.loanErrorNothingToWriteOff,
                key: const ValueKey('close-nothing'),
              )
            else
              Text(
                widget.writeOff
                    ? l10n.loanWriteOffBody(payable.format())
                    : l10n.loanCloseAllPaid,
                key: const ValueKey('close-body'),
              ),
            const SizedBox(height: MkSpacing.md),
            MkTextField(
              key: const ValueKey('close-reason'),
              controller: _reason,
              label: widget.writeOff
                  ? l10n.loanCloseReason
                  : l10n.loanCloseReasonOptional,
              maxLines: 2,
              errorText:
                  widget.writeOff && _submitted && _reason.text.trim().isEmpty
                  ? l10n.loanErrorReason
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            if (_error != null) ...[
              const SizedBox(height: MkSpacing.md),
              Text(
                _error!,
                key: const ValueKey('close-error'),
                style: TextStyle(color: MkTokens.of(context).udhaar),
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
            key: const ValueKey('close-save'),
            label: widget.writeOff
                ? l10n.loanWriteOffConfirm
                : l10n.loanCloseConfirm,
            icon: widget.writeOff ? Icons.block : Icons.check,
            variant: widget.writeOff
                ? MkButtonVariant.danger
                : MkButtonVariant.primary,
            onPressed: _saving || blocked || nothing ? null : _save,
          ),
        ],
      ),
    );
  }
}
