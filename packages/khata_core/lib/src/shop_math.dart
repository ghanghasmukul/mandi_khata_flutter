import 'package:khata_core/src/money.dart';

/// Exact integer helpers for the shop: products of two amounts can pass the
/// 2^53 an `int` holds exactly on the web, so they go through [BigInt].
abstract final class ShopMath {
  /// `a × b ÷ c` rounded half-up (away from zero for negatives).
  static int mulDivRound(int a, int b, int c) {
    if (c <= 0) throw ArgumentError.value(c, 'c', 'must be positive');
    final n = BigInt.from(a) * BigInt.from(b);
    final half = BigInt.from(c) ~/ BigInt.two;
    final abs = (n.abs() + half) ~/ BigInt.from(c);
    return (n.isNegative ? -abs : abs).toInt();
  }

  /// `a × b ÷ c` rounded down (toward zero).
  static int mulDivFloor(int a, int b, int c) {
    if (c <= 0) throw ArgumentError.value(c, 'c', 'must be positive');
    return (BigInt.from(a) * BigInt.from(b) ~/ BigInt.from(c)).toInt();
  }

  /// `qtyMilli` units of something priced [unit] per whole unit: `unit ×
  /// qtyMilli ÷ 1000`, half-up.
  static Money valueOf(Money unit, int qtyMilli) =>
      Money(mulDivRound(unit.paise, qtyMilli, 1000));

  /// Splits [total] (>= 0) over [weights] (>= 0, not all 0) in proportion,
  /// by the largest-remainder method: every share is the floor of its exact
  /// part and the leftover paise go to the largest fractional remainders
  /// (ties to the earlier entry). The shares add up to [total] exactly.
  static List<int> apportion(int total, List<int> weights) {
    if (total < 0) throw ArgumentError.value(total, 'total', 'must be >= 0');
    final sum = weights.fold<int>(0, (a, w) => a + w);
    if (weights.any((w) => w < 0) || sum <= 0) {
      throw ArgumentError.value(weights, 'weights', 'need a positive sum');
    }
    final shares = <int>[];
    final rems = <BigInt>[];
    for (final w in weights) {
      final n = BigInt.from(total) * BigInt.from(w);
      shares.add((n ~/ BigInt.from(sum)).toInt());
      rems.add(n % BigInt.from(sum));
    }
    var left = total - shares.fold<int>(0, (a, s) => a + s);
    final order = List.generate(weights.length, (i) => i)
      ..sort((a, b) {
        final c = rems[b].compareTo(rems[a]);
        return c != 0 ? c : a.compareTo(b);
      });
    for (final i in order) {
      if (left == 0) break;
      shares[i]++;
      left--;
    }
    return shares;
  }

  /// The part of [total] for [partMilli] of [wholeMilli], where
  /// [doneMilli] of the whole (worth [doneAmount]) is already taken. The
  /// share is proportional, half-up; the one that completes the whole takes
  /// exactly what is left, so repeated partial returns never leave a paisa.
  static int proportional({
    required int total,
    required int partMilli,
    required int wholeMilli,
    int doneMilli = 0,
    int doneAmount = 0,
  }) {
    if (partMilli + doneMilli >= wholeMilli) return total - doneAmount;
    return mulDivRound(total, partMilli, wholeMilli);
  }
}
