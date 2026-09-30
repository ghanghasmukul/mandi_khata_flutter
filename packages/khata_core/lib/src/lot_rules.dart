import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/mandi_charges.dart';
import 'package:khata_core/src/money.dart';
import 'package:meta/meta.dart';

/// Weights are whole thousandths of a quintal (`qtl_milli`): 8.64 qtl =
/// 8640. Never a `double`, so `qtl × rate` stays exact.
abstract final class Quintals {
  static final _pattern = RegExp(r'^(\d{0,6})(?:\.(\d{0,3}))?$');

  /// `8.64` → 8640, `12` → 12000, `.5` → 500. Null for empty or malformed
  /// text, more than 3 decimals or more than 999999 qtl. Spaces and commas
  /// are ignored.
  static int? parseMilli(String text) {
    final cleaned = text.replaceAll(RegExp(r'[\s,]'), '');
    final m = _pattern.firstMatch(cleaned);
    if (m == null) return null;
    final whole = m[1]!;
    final fraction = m[2] ?? '';
    if (whole.isEmpty && fraction.isEmpty) return null;
    return int.parse(whole.isEmpty ? '0' : whole) * 1000 +
        int.parse(fraction.padRight(3, '0'));
  }

  /// 8640 → `8.64`, 8000 → `8.00`, 15375 → `15.375`: at least two
  /// decimals, a third only when it is not zero.
  static String format(int milli) {
    final negative = milli < 0;
    final v = milli.abs();
    var fraction = (v % 1000).toString().padLeft(3, '0');
    if (fraction.endsWith('0')) fraction = fraction.substring(0, 2);
    return '${negative ? '-' : ''}${v ~/ 1000}.$fraction';
  }
}

/// Where a lot is in its life (`lots.status`). Arrival → weigh → sale →
/// posted to the khata; a posted lot can only be reversed, an unposted one
/// can be cancelled (also stored as [reversed], with nothing posted).
enum LotStatus {
  arrived,
  weighed,
  sold,
  posted,
  reversed;

  static LotStatus parse(String value) => values.firstWhere(
    (s) => s.name == value,
    orElse: () => throw FormatException('Unknown lot status', value),
  );

  /// Not posted yet: every field can still be edited.
  bool get isOpen => this == arrived || this == weighed || this == sold;

  /// The status of an unposted lot from what has been filled in.
  static LotStatus draftFor({int? qtlMilli, Money? rate}) =>
      switch ((qtlMilli, rate)) {
        (null, _) => arrived,
        (_, null) => weighed,
        _ => sold,
      };

  /// Whether a lot may go from this status to [to]. Open lots move freely
  /// between open states, and may be posted or cancelled; a posted lot can
  /// only be reversed; a reversed lot never changes.
  bool canMoveTo(LotStatus to) => isOpen || (this == posted && to == reversed);
}

/// Why a lot cannot be saved or posted.
enum LotProblem {
  /// Bags below zero.
  bagsNegative,

  /// A weight was given but it is zero.
  weightNotPositive,

  /// A rate was given but it is zero.
  rateNotPositive,

  /// The buyer is the farmer.
  buyerIsFarmer,

  /// Posting needs the weight.
  noWeight,

  /// Posting needs the rate.
  noRate,

  /// A charge is paid by the buyer, so posting needs a buyer to bill.
  buyerRequired,

  /// Charges the farmer pays eat up the whole sale; nothing to credit.
  netNotPositive,
}

/// One ledger entry a posted lot makes.
@immutable
final class LotPostingLine {
  const LotPostingLine({
    required this.partyId,
    required this.side,
    required this.amount,
  });

  final String partyId;
  final Side side;
  final Money amount;

  @override
  bool operator ==(Object other) =>
      other is LotPostingLine &&
      other.partyId == partyId &&
      other.side == side &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(partyId, side, amount);

  @override
  String toString() => 'LotPostingLine($partyId, ${side.name}, $amount)';
}

/// What posting a lot writes to the khata.
@immutable
final class LotPostingPlan {
  const LotPostingPlan({
    required this.breakdown,
    required this.farmer,
    this.buyer,
  });

  final MandiBreakdown breakdown;

  /// Jama to the farmer for the net amount.
  final LotPostingLine farmer;

  /// Udhaar to the buyer for gross + buyer-borne charges; null without a
  /// buyer.
  final LotPostingLine? buyer;

  List<LotPostingLine> get lines => [farmer, ?buyer];
}

/// Rules for saving and posting a lot (docs/domain/ledger-and-mandi.md,
/// "Mandi arrival → sale → settlement").
abstract final class LotRules {
  /// Problems that stop a lot being saved at all.
  static Set<LotProblem> validate({
    required String farmerId,
    required int bags,
    int? qtlMilli,
    Money? rate,
    String? buyerId,
  }) => {
    if (bags < 0) LotProblem.bagsNegative,
    if (qtlMilli != null && qtlMilli <= 0) LotProblem.weightNotPositive,
    if (rate != null && !rate.isPositive) LotProblem.rateNotPositive,
    if (buyerId != null && buyerId == farmerId) LotProblem.buyerIsFarmer,
  };

  /// The ledger entries for posting the lot, or the problems that stop it.
  ///
  /// - farmer: `jama` of `net_to_farmer` (must be positive);
  /// - buyer (when given): `udhaar` of `gross + buyer-borne charges`;
  /// - a buyer is required when any charge is billed to the buyer.
  ///
  /// Commission income is not a khata entry; it stays on the lot until the
  /// accounts arrive (phase 3).
  static ({LotPostingPlan? plan, Set<LotProblem> problems}) planPosting({
    required String farmerId,
    required int bags,
    required int? qtlMilli,
    required Money? rate,
    required MandiConfig config,
    String? buyerId,
  }) {
    final problems = {
      ...validate(
        farmerId: farmerId,
        bags: bags,
        qtlMilli: qtlMilli,
        rate: rate,
        buyerId: buyerId,
      ),
      if (qtlMilli == null) LotProblem.noWeight,
      if (rate == null) LotProblem.noRate,
    };
    if (problems.isNotEmpty) return (plan: null, problems: problems);

    final b = MandiCharges.calculate(
      LotInput(bags: bags, qtlMilli: qtlMilli!, rate: rate!),
      config,
    );
    final billsBuyer = b.buyerCharges.isPositive;
    final blocked = {
      if (billsBuyer && buyerId == null) LotProblem.buyerRequired,
      if (!b.netToFarmer.isPositive) LotProblem.netNotPositive,
    };
    if (blocked.isNotEmpty) return (plan: null, problems: blocked);

    return (
      plan: LotPostingPlan(
        breakdown: b,
        farmer: LotPostingLine(
          partyId: farmerId,
          side: Side.jama,
          amount: b.netToFarmer,
        ),
        buyer: buyerId == null || !b.buyerTotal.isPositive
            ? null
            : LotPostingLine(
                partyId: buyerId,
                side: Side.udhaar,
                amount: b.buyerTotal,
              ),
      ),
      problems: const {},
    );
  }
}
