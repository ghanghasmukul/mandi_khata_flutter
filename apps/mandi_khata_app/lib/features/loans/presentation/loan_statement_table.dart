import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The loan's interest statement as the engine worked it out: every slab of
/// days, loan given, repayment (with its byaj / principal split), step where
/// byaj joins the principal and rate change, in order.
class LoanStatementTable extends StatelessWidget {
  const LoanStatementTable({required this.rows, super.key});

  final List<InterestRow> rows;

  String _event(AppLocalizations l10n, InterestRow r) {
    final note = r.note == null || r.note!.isEmpty ? '' : '\n${r.note}';
    switch (r.kind) {
      case InterestRowKind.accrue:
        return l10n.loanRowAccrue;
      case InterestRowKind.debit:
        return '${l10n.loanRowDebit}$note';
      case InterestRowKind.credit:
        final split = l10n.loanRowSplit(
          Money(r.payInterestPaise).format(),
          Money(r.payPrincipalPaise).format(),
        );
        final surplus = r.toCreditBalancePaise > 0
            ? '\n${l10n.loanRowSurplus(Money(r.toCreditBalancePaise).format())}'
            : '';
        return '${l10n.loanRowCredit}$note\n$split$surplus';
      case InterestRowKind.compound:
        return l10n.loanRowCompound;
      case InterestRowKind.rateChange:
        return l10n.loanRowRate(r.ratePa.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String date(LedgerDate d) => AppFormat.ledgerDate(context, d);
    Widget money(int paise, MkMoneyTone tone) =>
        paise == 0 ? const Text('') : MkMoneyText(Money(paise), tone: tone);
    return MkDataTable<InterestRow>(
      key: const ValueKey('loan-statement'),
      minWidth: 900,
      rows: rows,
      empty: Text(l10n.loanStmtEmpty),
      columns: [
        MkColumn(
          label: l10n.loanColFrom,
          flex: 3,
          cell: (r) => Text(date(r.from)),
        ),
        MkColumn(
          label: l10n.loanColTo,
          flex: 3,
          cell: (r) => Text(r.kind == InterestRowKind.accrue ? date(r.to) : ''),
        ),
        MkColumn(
          label: l10n.loanColEvent,
          flex: 6,
          cell: (r) => Text(_event(l10n, r)),
        ),
        MkColumn(
          label: l10n.loanColDebit,
          flex: 3,
          numeric: true,
          cell: (r) => money(
            r.kind == InterestRowKind.debit ? r.amountPaise : 0,
            MkMoneyTone.udhaar,
          ),
        ),
        MkColumn(
          label: l10n.loanColCredit,
          flex: 3,
          numeric: true,
          cell: (r) => money(
            r.kind == InterestRowKind.credit ? r.amountPaise : 0,
            MkMoneyTone.jama,
          ),
        ),
        MkColumn(
          label: l10n.loanColDays,
          flex: 2,
          numeric: true,
          cell: (r) =>
              Text(r.kind == InterestRowKind.accrue ? '${r.days}' : ''),
        ),
        MkColumn(
          label: l10n.loanColPrincipal,
          flex: 3,
          numeric: true,
          cell: (r) => MkMoneyText(Money(r.principalPaise)),
        ),
        MkColumn(
          label: l10n.loanColRate,
          flex: 2,
          numeric: true,
          cell: (r) => Text(r.ratePa.toString(), style: MkText.mono()),
        ),
        MkColumn(
          label: l10n.loanColInterest,
          flex: 3,
          numeric: true,
          cell: (r) => switch (r.kind) {
            InterestRowKind.accrue => MkMoneyText(Money(r.interestPaise)),
            InterestRowKind.compound => MkMoneyText(Money(r.amountPaise)),
            _ => const Text(''),
          },
        ),
      ],
    );
  }
}
