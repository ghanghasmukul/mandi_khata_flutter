import 'package:decimal/decimal.dart';

/// Mandi practice quotes interest as "₹ per 100 per month" (₹1.5 = 18% p.a.).
/// Rates are stored as % per annum; these convert for entry and display.
abstract final class InterestRate {
  static final _twelve = Decimal.fromInt(12);

  static Decimal paFromPer100PerMonth(Decimal perMonth) => perMonth * _twelve;

  /// Rounded half-up to 4 places for display (20% p.a. → ₹1.6667).
  static Decimal per100PerMonthFromPa(Decimal pa) =>
      (pa / _twelve).toDecimal(scaleOnInfinitePrecision: 10).round(scale: 4);
}
