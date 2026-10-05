import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/interest/data/interest_statement_pdf.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_statement_table.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

/// The party's byaj statement in [l10n]'s language: the same rows the Byaj
/// tab shows (engine output), with the figures of the day.
InterestStatementData interestStatementData(
  AppLocalizations l10n, {
  required String businessName,
  required Party party,
  required InterestConfig config,
  required InterestResult result,
  required LedgerDate asOf,
  required int postedPaise,
  required String Function(LedgerDate) formatDate,
}) {
  String money(int paise) => Money(paise).format();
  return InterestStatementData(
    title: l10n.byajStatementTitle,
    businessName: businessName,
    partyName: party.name,
    partyCode: party.code,
    partyPlace: party.village,
    asOf: l10n.slipAsOf(formatDate(asOf)),
    terms: l10n.byajStatementTerms(
      config.ratePa.toString(),
      l10n.settingOption('interest.method', config.method.name),
    ),
    figures: [
      (
        label: l10n.loanPrincipalOutstanding,
        amount: money(result.principalPaise),
        bold: false,
      ),
      (
        label: l10n.loanInterestAccrued,
        amount: money(result.accruedUnpaidPaise),
        bold: false,
      ),
      (
        label: l10n.loanInterestRecovered,
        amount: money(result.interestRecoveredPaise),
        bold: false,
      ),
      (label: l10n.byajPosted, amount: money(postedPaise), bold: false),
      (
        label: l10n.byajUnposted,
        amount: money(
          InterestPosting.unposted(result, postedPaise: postedPaise),
        ),
        bold: false,
      ),
      (
        label: l10n.loanPayableOn(formatDate(asOf)),
        amount: money(result.totalPayablePaise),
        bold: true,
      ),
    ],
    headers: [
      l10n.loanColFrom,
      l10n.loanColTo,
      l10n.loanColEvent,
      l10n.loanColDebit,
      l10n.loanColCredit,
      l10n.loanColDays,
      l10n.loanColPrincipal,
      l10n.loanColRate,
      l10n.loanColInterest,
    ],
    rows: [for (final r in result.schedule) _row(l10n, r, formatDate)],
  );
}

List<String> _row(
  AppLocalizations l10n,
  InterestRow r,
  String Function(LedgerDate) formatDate,
) {
  String money(int paise) => Money(paise).format();
  final accrues = r.kind == InterestRowKind.accrue;
  final String debit;
  final String credit;
  final String interest;
  switch (r.kind) {
    case InterestRowKind.debit:
      (debit, credit, interest) = (money(r.amountPaise), '', '');
    case InterestRowKind.credit:
      (debit, credit, interest) = ('', money(r.amountPaise), '');
    case InterestRowKind.accrue:
      (debit, credit, interest) = ('', '', money(r.interestPaise));
    case InterestRowKind.compound:
      (debit, credit, interest) = ('', '', money(r.amountPaise));
    case InterestRowKind.rateChange:
      (debit, credit, interest) = ('', '', '');
  }
  return [
    formatDate(r.from),
    if (accrues) formatDate(r.to) else '',
    interestRowEvent(l10n, r, forKhata: true),
    debit,
    credit,
    if (accrues) '${r.days}' else '',
    money(r.principalPaise),
    r.ratePa.toString(),
    interest,
  ];
}
