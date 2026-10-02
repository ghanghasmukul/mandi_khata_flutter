import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// What the "All entries" (day book) screen shows. Every field null = the
/// whole khata of the business.
@immutable
class LedgerFilter {
  const LedgerFilter({this.from, this.to, this.partyId, this.refType});

  final LedgerDate? from;
  final LedgerDate? to;
  final String? partyId;
  final RefType? refType;

  LedgerFilter copyWith({
    LedgerDate? Function()? from,
    LedgerDate? Function()? to,
    String? Function()? partyId,
    RefType? Function()? refType,
  }) => LedgerFilter(
    from: from == null ? this.from : from(),
    to: to == null ? this.to : to(),
    partyId: partyId == null ? this.partyId : partyId(),
    refType: refType == null ? this.refType : refType(),
  );

  @override
  bool operator ==(Object other) =>
      other is LedgerFilter &&
      other.from == from &&
      other.to == to &&
      other.partyId == partyId &&
      other.refType == refType;

  @override
  int get hashCode => Object.hash(from, to, partyId, refType);
}

/// One line of the day book: the entry, its party and that party's running
/// baki after it (over the party's whole khata, not only the filtered
/// lines).
@immutable
class DayBookRow {
  const DayBookRow({
    required this.entry,
    required this.partyName,
    required this.partyCode,
    required this.balance,
    this.reversedById,
  });

  final LedgerEntry entry;
  final String partyName;
  final String partyCode;

  /// The party's baki after this entry (Σ jama − Σ udhaar).
  final Money balance;

  /// The reversal that cancelled this entry, if any.
  final String? reversedById;

  /// Shown struck through: a reversed entry or the reversal itself.
  bool get isStruck => reversedById != null || entry.isReversal;
}

/// Size and totals of a filtered day book.
typedef DayBookSummary = ({int count, Money udhaar, Money jama});
