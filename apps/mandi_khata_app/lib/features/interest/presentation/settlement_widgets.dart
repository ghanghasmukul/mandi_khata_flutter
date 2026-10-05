import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/interest/data/settlement_slip_pdf.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_detail_cards.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One account with interest to settle and the waiver typed for it.
class SettlementSourceCard extends StatelessWidget {
  const SettlementSourceCard({
    required this.candidate,
    required this.controller,
    required this.canWaive,
    required this.onChanged,
    super.key,
  });

  final PostingCandidate candidate;
  final TextEditingController controller;
  final bool canWaive;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plan = candidate.plan;
    return Padding(
      padding: const EdgeInsets.only(bottom: MkSpacing.sm),
      child: MkCard(
        key: ValueKey('settle-source-${candidate.source.key}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              candidate.loanNo == null
                  ? l10n.postAccountKhata
                  : l10n.postAccountLoan(candidate.loanNo!),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              l10n.postPeriod(
                AppFormat.ledgerDate(context, plan.from),
                AppFormat.ledgerDate(context, plan.to),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            loanFact(
              context,
              l10n.loanPrincipalOutstanding,
              MkMoneyText(candidate.principal),
            ),
            loanFact(
              context,
              l10n.postInterestAmount,
              MkMoneyText(candidate.amount),
            ),
            if (canWaive)
              MkTextField(
                key: ValueKey('settle-waiver-${candidate.source.key}'),
                controller: controller,
                label: l10n.settleWaiver,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                ],
                onChanged: (_) => onChanged(),
              ),
          ],
        ),
      ),
    );
  }
}

/// The settlement slip in [l10n]'s language for the figures on screen.
SettlementSlip settlementSlip(
  AppLocalizations l10n, {
  required BuildContext context,
  required String businessName,
  required Party party,
  required LedgerDate asOf,
  required Settlement settlement,
  required Map<RefType, SideTotals> totals,
  required List<PostingCandidate> sources,
  required String reason,
}) {
  Money net(SideTotals? t) => t == null ? Money.zero : t.jama - t.udhaar;
  SlipLine line(String label, Money m, {bool bold = false}) =>
      (label: label, amount: m.format(), bold: bold);
  return SettlementSlip(
    title: l10n.slipTitle,
    businessName: businessName,
    partyName: party.name,
    partyCode: party.code,
    partyPlace: party.village,
    asOf: l10n.slipAsOf(AppFormat.ledgerDate(context, asOf)),
    lines: [
      line(l10n.settleCropProceeds, net(totals[RefType.arrival])),
      line(
        l10n.settlePayments,
        net(totals[RefType.payment]) + net(totals[RefType.receipt]),
      ),
      line(
        l10n.settleLoans,
        net(totals[RefType.loanDisbursal]) + net(totals[RefType.loanRepayment]),
      ),
      line(l10n.settleInterestPosted, net(totals[RefType.interest])),
      line(l10n.settleKhataBalance, settlement.balance, bold: true),
      for (final c in sources)
        line(
          c.loanNo == null
              ? l10n.settleInterestOnKhata
              : l10n.settleInterestOnLoan(c.loanNo!),
          c.amount,
        ),
      if (settlement.waiver.isPositive)
        line(l10n.settleWaiver, -settlement.waiver),
    ],
    finalLabel: switch (settlement.direction) {
      SettlementDirection.receivable => l10n.settleReceivable,
      SettlementDirection.payable => l10n.settlePayable,
      SettlementDirection.settled => l10n.settleSettled,
    },
    finalAmount: settlement.finalBalance.abs().format(),
    reasonLine: settlement.waiver.isPositive && reason.isNotEmpty
        ? l10n.slipReason(reason)
        : null,
    partySignature: l10n.slipSignParty,
    ownerSignature: l10n.slipSignOwner,
  );
}

/// The khata so far: crop proceeds, payments, loans, interest already
/// posted and the balance now.
class SettlementKhataCard extends StatelessWidget {
  const SettlementKhataCard({
    required this.totals,
    required this.balance,
    super.key,
  });

  final Map<RefType, SideTotals> totals;
  final Money balance;

  static Money _net(SideTotals? t) =>
      t == null ? Money.zero : t.jama - t.udhaar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget line(String label, Money amount, {String? key, bool bold = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: MkSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: bold ? Theme.of(context).textTheme.titleSmall : null,
                ),
              ),
              MkMoneyText(amount, key: key == null ? null : ValueKey(key)),
            ],
          ),
        );
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line(l10n.settleCropProceeds, _net(totals[RefType.arrival])),
          line(
            l10n.settlePayments,
            _net(totals[RefType.payment]) + _net(totals[RefType.receipt]),
          ),
          line(
            l10n.settleLoans,
            _net(totals[RefType.loanDisbursal]) +
                _net(totals[RefType.loanRepayment]),
          ),
          line(l10n.settleInterestPosted, _net(totals[RefType.interest])),
          const Divider(),
          line(
            l10n.settleKhataBalance,
            balance,
            key: 'settle-balance',
            bold: true,
          ),
        ],
      ),
    );
  }
}
