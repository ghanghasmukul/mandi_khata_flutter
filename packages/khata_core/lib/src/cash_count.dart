import 'package:khata_core/src/money.dart';
import 'package:meta/meta.dart';

/// Notes and coins counted at day close (docs/domain/posting-rules.md,
/// 11.3), in rupees.
const cashDenominations = [500, 200, 100, 50, 20, 10, 5, 2, 1];

/// A cash count: how many of each denomination, and the result against the
/// cash book.
@immutable
final class CashCount {
  /// Throws [ArgumentError] for an unknown denomination or a negative count.
  CashCount(Map<int, int> counts, {this.loose = Money.zero})
    : counts = Map.unmodifiable(counts) {
    for (final MapEntry(key: d, value: n) in counts.entries) {
      if (!cashDenominations.contains(d)) {
        throw ArgumentError.value(d, 'denomination');
      }
      if (n < 0) throw ArgumentError.value(n, 'count of ₹$d');
    }
    if (loose.isNegative) throw ArgumentError.value(loose, 'loose');
  }

  /// Reads what [toJson] wrote.
  factory CashCount.fromJson(Map<String, Object?> json) => CashCount({
    for (final d in cashDenominations)
      if (json['$d'] is int) d: json['$d']! as int,
  }, loose: Money(json['loose'] is int ? json['loose']! as int : 0));

  /// Denomination (rupees) → pieces.
  final Map<int, int> counts;

  /// Coins / change not counted by denomination (paise).
  final Money loose;

  Money get total =>
      counts.entries.fold(
        Money.zero,
        (s, e) => s + Money.rupees(e.key * e.value),
      ) +
      loose;

  /// Counted − book: positive = excess, negative = short.
  Money difference(Money book) => total - book;

  Map<String, Object?> toJson() => {
    for (final d in cashDenominations)
      if ((counts[d] ?? 0) > 0) '$d': counts[d],
    if (!loose.isZero) 'loose': loose.paise,
  };
}
