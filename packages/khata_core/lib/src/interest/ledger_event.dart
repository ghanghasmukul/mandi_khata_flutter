import 'package:decimal/decimal.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:meta/meta.dart';

/// One khata movement as the interest engine sees it.
@immutable
class LedgerEvent {
  const LedgerEvent({
    required this.id,
    required this.date,
    required this.side,
    required this.amountPaise,
    this.createdAt,
    this.note,
    this.isPostedInterest = false,
    this.interestOnly = false,
  });

  final String id;

  /// Business date (`entry_date`).
  final LedgerDate date;

  /// [Side.udhaar] raises what the party owes, [Side.jama] lowers it.
  final Side side;

  /// Always positive.
  final int amountPaise;

  /// Tie-break for entries on the same day (spec rule 12).
  final DateTime? createdAt;
  final String? note;

  /// An entry with `ref_type = interest`: ignored by the engine (rule 8).
  final bool isPostedInterest;

  /// A waiver (discount on interest): a credit that always pays accrued
  /// interest first, whatever `interest.appropriation` says, and is reported
  /// as waived, not recovered.
  final bool interestOnly;
}

/// An effective-dated change of the annual rate (loan_rate_changes).
@immutable
class RateChange {
  const RateChange({
    required this.effectiveDate,
    required this.ratePa,
    this.reason,
  });

  /// The new rate applies from this day (the day itself counts).
  final LedgerDate effectiveDate;

  /// Percent per annum.
  final Decimal ratePa;
  final String? reason;
}
