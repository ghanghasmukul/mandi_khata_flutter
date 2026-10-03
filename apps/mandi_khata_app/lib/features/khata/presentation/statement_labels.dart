import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

/// The statement PDF's words in [l10n]'s language. [period] is the
/// "1 Apr – 30 Sep" line; [formatDate] writes a business date.
StatementLabels statementLabels(
  AppLocalizations l10n, {
  required String period,
  required String Function(LedgerDate date) formatDate,
}) => StatementLabels(
  title: l10n.statementTitle,
  period: period,
  opening: l10n.statementOpening,
  closing: l10n.statementClosing,
  date: l10n.khataColDate,
  details: l10n.khataColDetails,
  udhaar: l10n.khataColUdhaar,
  jama: l10n.khataColJama,
  baki: l10n.khataColBaki,
  totals: l10n.statementTotals,
  balanceSide: (m) => m.isPositive
      ? l10n.khataBalanceJama
      : m.isNegative
      ? l10n.khataBalanceUdhaarParty
      : l10n.khataBalanceSettled,
  page: l10n.statementPage,
  reversedTag: l10n.khataTagReversed,
  describe: l10n.entryDescription,
  formatDate: formatDate,
);
