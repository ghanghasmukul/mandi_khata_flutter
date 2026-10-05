import 'package:khata_core/src/money.dart';

/// The credit limit alert (setting `business.credit_limit`): how much a
/// party may owe. It only warns; nothing is blocked.
abstract final class CreditLimit {
  /// How far past [limitPaise] the party owes, or null when within it.
  /// [balance] is Σ jama − Σ udhaar, so a party who owes has a negative
  /// balance. A limit of 0 means no limit.
  static Money? excess(Money balance, int limitPaise) {
    if (limitPaise <= 0 || !balance.isNegative) return null;
    final over = -balance.paise - limitPaise;
    return over > 0 ? Money(over) : null;
  }

  static bool isOver(Money balance, int limitPaise) =>
      excess(balance, limitPaise) != null;
}
