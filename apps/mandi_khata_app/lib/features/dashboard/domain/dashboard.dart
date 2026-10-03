import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// What came in and went out on one business day.
@immutable
class DaySummary {
  const DaySummary({
    required this.lots,
    required this.qtlMilli,
    required this.arhatEarned,
    required this.paidOut,
    required this.receipts,
  });

  static const empty = DaySummary(
    lots: 0,
    qtlMilli: 0,
    arhatEarned: Money.zero,
    paidOut: Money.zero,
    receipts: Money.zero,
  );

  /// Lots that arrived (not cancelled or reversed).
  final int lots;

  /// Their weight, in 1/1000 quintal.
  final int qtlMilli;

  /// Commission earned on the day's posted lots.
  final Money arhatEarned;

  /// Payments to parties and receipts from them (posted, not reversed).
  final Money paidOut;
  final Money receipts;

  @override
  bool operator ==(Object other) =>
      other is DaySummary &&
      other.lots == lots &&
      other.qtlMilli == qtlMilli &&
      other.arhatEarned == arhatEarned &&
      other.paidOut == paidOut &&
      other.receipts == receipts;

  @override
  int get hashCode =>
      Object.hash(lots, qtlMilli, arhatEarned, paidOut, receipts);
}

/// Who owes whom, summed over the khata of every party.
@immutable
class MoneyPosition {
  const MoneyPosition({
    required this.farmersPayable,
    required this.farmersReceivable,
    required this.othersReceivable,
  });

  static const empty = MoneyPosition(
    farmersPayable: Money.zero,
    farmersReceivable: Money.zero,
    othersReceivable: Money.zero,
  );

  /// We owe farmers (their jama balances).
  final Money farmersPayable;

  /// Farmers owe us (their udhaar balances, e.g. advances).
  final Money farmersReceivable;

  /// Parties who are not farmers and owe us.
  final Money othersReceivable;

  /// Everyone who owes us: "Others owe us" in the hero.
  Money get totalReceivable => farmersReceivable + othersReceivable;

  @override
  bool operator ==(Object other) =>
      other is MoneyPosition &&
      other.farmersPayable == farmersPayable &&
      other.farmersReceivable == farmersReceivable &&
      other.othersReceivable == othersReceivable;

  @override
  int get hashCode =>
      Object.hash(farmersPayable, farmersReceivable, othersReceivable);
}

/// One crop's share of this season's sales.
@immutable
class CropSale {
  const CropSale({
    required this.cropId,
    required this.code,
    required this.nameEn,
    required this.nameHi,
    required this.namePa,
    required this.gross,
    required this.lots,
  });

  final String cropId;
  final String code;
  final String nameEn;
  final String? nameHi;
  final String? namePa;
  final Money gross;
  final int lots;

  String nameIn(String languageCode) {
    final local = switch (languageCode) {
      'hi' => nameHi,
      'pa' => namePa,
      _ => null,
    };
    return local == null || local.trim().isEmpty ? nameEn : local;
  }
}

/// Things that want the owner's attention today.
@immutable
class AttentionCounts {
  const AttentionCounts({
    required this.chequesDue,
    required this.chequesDueAmount,
    required this.staffChanges,
  });

  static const none = AttentionCounts(
    chequesDue: 0,
    chequesDueAmount: Money.zero,
    staffChanges: 0,
  );

  /// Pending cheques dated today or earlier.
  final int chequesDue;
  final Money chequesDueAmount;

  /// Changes and reversals made by munshis in the last
  /// [DashboardDays.staffWindow] days.
  final int staffChanges;

  @override
  bool operator ==(Object other) =>
      other is AttentionCounts &&
      other.chequesDue == chequesDue &&
      other.chequesDueAmount == chequesDueAmount &&
      other.staffChanges == staffChanges;

  @override
  int get hashCode => Object.hash(chequesDue, chequesDueAmount, staffChanges);
}

/// One bar of the "arhat earned" chart.
@immutable
class DayAmount {
  const DayAmount(this.date, this.amount);

  final LedgerDate date;
  final Money amount;
}

/// Date windows used by the dashboard.
abstract final class DashboardDays {
  /// Days shown in the arhat chart, today included.
  static const chartDays = 10;

  /// How far back munshi changes are listed.
  static const staffWindow = 7;

  /// The [chartDays] days ending [today], oldest first, zero-filled where
  /// [earned] has no row.
  static List<DayAmount> chart(
    LedgerDate today,
    Map<LedgerDate, Money> earned,
  ) {
    final first = today.addDays(1 - chartDays);
    return [
      for (var i = 0; i < chartDays; i++)
        DayAmount(first.addDays(i), earned[first.addDays(i)] ?? Money.zero),
    ];
  }
}
