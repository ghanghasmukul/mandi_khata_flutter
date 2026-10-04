import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_change_dialogs.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/repayment_dialog.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_mode_fields.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// A label and its value on one line.
Widget loanFact(BuildContext context, String label, Widget value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: MkSpacing.xs),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 150,
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
      Expanded(child: value),
    ],
  ),
);

/// "Simple · 15 days grace · Repayment goes first to: Interest".
String loanTermsText(AppLocalizations l10n, InterestConfig cfg) {
  if (!cfg.enabled) return l10n.loanInterestFree;
  final appropriation = l10n.settingOption(
    'interest.appropriation',
    cfg.appropriation.dbName,
  );
  return [
    l10n.settingOption('interest.method', cfg.method.name),
    if (cfg.compounds)
      l10n.settingOption('interest.compounding', cfg.compounding.dbName),
    if (cfg.graceDays > 0) l10n.loanGraceDays('${cfg.graceDays}'),
    '${l10n.settingInterestAppropriation}: $appropriation',
  ].join(' · ');
}

/// The rate in force on [day]: the last change on or before it, else the
/// rate the loan was issued at.
Decimal loanRateOn(LoanDetail detail, LedgerDate day) {
  var rate = detail.loan.config.ratePa;
  for (final c in detail.rateChanges) {
    if (c.effectiveDate <= day) rate = c.ratePa;
  }
  return rate;
}

/// Who, how much, when, why, the terms and how it ended.
class LoanSummaryCard extends StatelessWidget {
  const LoanSummaryCard({
    required this.detail,
    required this.position,
    super.key,
  });

  final LoanDetail detail;
  final LoanPosition position;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loan = detail.loan;
    final dueText = l10n.loanDueText(
      detail.position(LedgerDate.fromDateTime(DateTime.now())),
    );
    final closedNote = loan.closedOn == null
        ? null
        : [
            l10n.loanClosedOn(
              l10n.loanStatusName(loan.status),
              AppFormat.ledgerDate(context, loan.closedOn!),
            ),
            if (loan.closeReason != null) loan.closeReason!,
          ].join(' · ');
    return MkCard(
      key: const ValueKey('loan-summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => context.go(PartyRoutes.detail(loan.partyId)),
                  child: Text(
                    loan.partyCode == null
                        ? loan.partyName
                        : '${loan.partyName} · ${loan.partyCode}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              MkRoleChip(
                key: const ValueKey('loan-health'),
                label: l10n.loanHealthName(position.health),
                warning:
                    position.health == LoanHealth.overdue ||
                    position.health == LoanHealth.writtenOff,
              ),
            ],
          ),
          const SizedBox(height: MkSpacing.sm),
          loanFact(
            context,
            l10n.loanFieldAmount,
            MkMoneyText(loan.principal, tone: MkMoneyTone.udhaar),
          ),
          loanFact(
            context,
            l10n.loanFieldIssueDate,
            Text(AppFormat.ledgerDate(context, loan.issueDate)),
          ),
          if (loan.dueDate != null)
            loanFact(
              context,
              l10n.loanFieldDueDate,
              Text(
                '${AppFormat.ledgerDate(context, loan.dueDate!)}'
                '${loan.isOpen ? ' · $dueText' : ''}',
              ),
            ),
          if (loan.purpose != null)
            loanFact(context, l10n.loanFieldPurpose, Text(loan.purpose!)),
          if (loan.guarantorName != null)
            loanFact(
              context,
              l10n.loanFieldGuarantor,
              Text(loan.guarantorName!),
            ),
          loanFact(
            context,
            l10n.loanTermsSummary,
            Text(
              loanTermsText(l10n, loan.config),
              key: const ValueKey('loan-terms'),
            ),
          ),
          if (closedNote != null)
            loanFact(
              context,
              l10n.loanCloseDate,
              Text(closedNote, key: const ValueKey('loan-closed-note')),
            ),
        ],
      ),
    );
  }
}

/// Payable on the chosen day with the as-of picker, then the parts.
class LoanFiguresCard extends StatelessWidget {
  const LoanFiguresCard({
    required this.detail,
    required this.position,
    required this.asOf,
    required this.onAsOf,
    super.key,
  });

  final LoanDetail detail;
  final LoanPosition position;
  final LedgerDate asOf;
  final ValueChanged<LedgerDate> onAsOf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loan = detail.loan;
    final p = position;
    final stopped = p.asOf < asOf;
    return MkCard(
      key: const ValueKey('loan-figures'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PaymentDateField(
                  key: const ValueKey('loan-asof'),
                  label: l10n.loanDetailAsOf,
                  date: asOf,
                  onChanged: onAsOf,
                ),
              ),
              const SizedBox(width: MkSpacing.sm),
              TextButton(
                key: const ValueKey('loan-asof-today'),
                onPressed: () =>
                    onAsOf(LedgerDate.fromDateTime(DateTime.now())),
                child: Text(l10n.loanDetailToday),
              ),
            ],
          ),
          const SizedBox(height: MkSpacing.md),
          Text(
            l10n.loanPayableOn(AppFormat.ledgerDate(context, p.asOf)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          MkMoneyText(p.payable, key: const ValueKey('loan-payable'), size: 28),
          if (stopped)
            Text(
              l10n.loanClosedOn(
                l10n.loanStatusName(loan.status),
                AppFormat.ledgerDate(context, p.asOf),
              ),
              style: TextStyle(color: MkTokens.of(context).textMuted),
            ),
          const Divider(height: MkSpacing.xl),
          loanFact(
            context,
            l10n.loanPrincipalOutstanding,
            MkMoneyText(p.principal, key: const ValueKey('loan-principal')),
          ),
          loanFact(
            context,
            l10n.loanInterestAccrued,
            MkMoneyText(p.accrued, key: const ValueKey('loan-accrued')),
          ),
          loanFact(
            context,
            l10n.loanInterestRecovered,
            MkMoneyText(p.interestRecovered, tone: MkMoneyTone.jama),
          ),
          loanFact(
            context,
            l10n.loanPrincipalRecovered,
            MkMoneyText(p.principalRecovered, tone: MkMoneyTone.jama),
          ),
          loanFact(
            context,
            l10n.loanCurrentRate,
            Text(
              loan.config.enabled
                  ? l10n.loanRatePa(loanRateOn(detail, p.asOf).toString())
                  : l10n.loanInterestFree,
            ),
          ),
          const SizedBox(height: MkSpacing.sm),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: p.recoveryPercent / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: MkSpacing.sm),
              Text(
                l10n.loanCardRecovered('${p.recoveryPercent}'),
                key: const ValueKey('loan-recovered'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Repay (payments.create) and the owner's rate / close / write-off.
class LoanActions extends StatelessWidget {
  const LoanActions({
    required this.detail,
    required this.canManage,
    required this.canRepay,
    required this.asOf,
    super.key,
  });

  final LoanDetail detail;
  final LedgerDate asOf;
  final bool canManage;
  final bool canRepay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: MkSpacing.md,
      runSpacing: MkSpacing.sm,
      children: [
        if (canRepay)
          MkButton(
            key: const ValueKey('loan-repay'),
            label: l10n.loanActionRepay,
            icon: Icons.south_west,
            onPressed: () =>
                showRepaymentDialog(context, detail.loan.id, date: asOf),
          ),
        if (canManage) ...[
          MkButton(
            key: const ValueKey('loan-change-rate'),
            label: l10n.loanActionRate,
            icon: Icons.percent,
            variant: MkButtonVariant.secondary,
            onPressed: () => showChangeRateDialog(context, detail),
          ),
          MkButton(
            key: const ValueKey('loan-close'),
            label: l10n.loanActionClose,
            icon: Icons.check_circle_outline,
            variant: MkButtonVariant.secondary,
            onPressed: () =>
                showCloseLoanDialog(context, detail, writeOff: false),
          ),
          MkButton(
            key: const ValueKey('loan-write-off'),
            label: l10n.loanActionWriteOff,
            icon: Icons.block,
            variant: MkButtonVariant.danger,
            onPressed: () =>
                showCloseLoanDialog(context, detail, writeOff: true),
          ),
        ],
      ],
    );
  }
}

/// The rate at issue and each effective-dated change with its reason.
class LoanRateChangesCard extends StatelessWidget {
  const LoanRateChangesCard({required this.detail, super.key});

  final LoanDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkCard(
      key: const ValueKey('loan-rate-changes'),
      child: Column(
        children: [
          loanFact(
            context,
            l10n.loanRateAtIssue,
            Text(l10n.loanRatePa(detail.loan.config.ratePa.toString())),
          ),
          for (final c in detail.rateChanges)
            loanFact(
              context,
              AppFormat.ledgerDate(context, c.effectiveDate),
              Text(
                '${l10n.loanRatePa(c.ratePa.toString())}'
                '${c.reason == null ? '' : ' · ${c.reason}'}',
              ),
            ),
        ],
      ),
    );
  }
}
