import 'package:khata_core/src/ledger.dart';
import 'package:meta/meta.dart';

/// An Indian financial year: 1 April to 31 March.
///
/// Used for "this season" figures and, later, year close (phase 3).
@immutable
final class FinancialYear {
  const FinancialYear(this.startYear);

  /// The financial year that includes [date].
  factory FinancialYear.containing(LedgerDate date) =>
      FinancialYear(date.month >= 4 ? date.year : date.year - 1);

  /// The calendar year of the 1 April it starts on (2026 for "2026-27").
  final int startYear;

  LedgerDate get start => LedgerDate(startYear, 4, 1);

  LedgerDate get end => LedgerDate(startYear + 1, 3, 31);

  bool contains(LedgerDate date) => date >= start && date <= end;

  /// `2026-27`.
  String get label {
    final endYear = ((startYear + 1) % 100).toString().padLeft(2, '0');
    return '$startYear-$endYear';
  }

  @override
  bool operator ==(Object other) =>
      other is FinancialYear && other.startYear == startYear;

  @override
  int get hashCode => startYear.hashCode;

  @override
  String toString() => 'FinancialYear($label)';
}
