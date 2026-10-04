import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One loan on the list: borrower, principal outstanding + byaj = payable,
/// how much is recovered, and days left or overdue.
class LoanCard extends StatelessWidget {
  const LoanCard({required this.summary, required this.onTap, super.key});

  final LoanSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final loan = summary.loan;
    final p = summary.position;
    final bad =
        p.health == LoanHealth.overdue || p.health == LoanHealth.writtenOff;

    Widget figure(String label, Money value, {MkMoneyTone? tone}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          MkMoneyText(value, tone: tone ?? MkMoneyTone.plain),
        ],
      ),
    );

    return MkCard(
      key: ValueKey('loan-card-${loan.id}'),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.partyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${loan.loanNo} · '
                      '${l10n.loanCardIssued(loan.principal.format())}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              MkRoleChip(label: l10n.loanHealthName(p.health), warning: bad),
            ],
          ),
          const SizedBox(height: MkSpacing.md),
          Row(
            children: [
              figure(l10n.loanCardOutstanding, p.principal),
              figure(l10n.loanCardByaj, p.accrued),
              figure(l10n.loanCardPayable, p.payable, tone: MkMoneyTone.udhaar),
            ],
          ),
          const SizedBox(height: MkSpacing.md),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: p.recoveryPercent / 100,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: MkSpacing.sm),
              Text(
                l10n.loanCardRecovered('${p.recoveryPercent}'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (loan.isOpen) ...[
            const SizedBox(height: MkSpacing.xs),
            Text(
              l10n.loanDueText(p),
              style: TextStyle(
                fontSize: 12,
                color: p.health == LoanHealth.overdue
                    ? tokens.udhaar
                    : tokens.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
