import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// Loans that need chasing.
@immutable
class LoanAlerts {
  const LoanAlerts({required this.overdue, required this.dueSoon});

  static const none = LoanAlerts(overdue: 0, dueSoon: 0);

  /// Open loans past their due date (the Loans badge).
  final int overdue;

  /// Open loans due within `LoanRules.dueSoonDays` days.
  final int dueSoon;

  @override
  bool operator ==(Object other) =>
      other is LoanAlerts &&
      other.overdue == overdue &&
      other.dueSoon == dueSoon;

  @override
  int get hashCode => Object.hash(overdue, dueSoon);
}

/// Parties past their credit limit.
@immutable
class CreditAlerts {
  const CreditAlerts({required this.count, required this.excess});

  static const none = CreditAlerts(count: 0, excess: Money.zero);

  final int count;

  /// Σ of what they owe beyond their limits.
  final Money excess;

  @override
  bool operator ==(Object other) =>
      other is CreditAlerts && other.count == count && other.excess == excess;

  @override
  int get hashCode => Object.hash(count, excess);
}

/// Interest charged up to [asOf] (the last quarter boundary) and not posted.
@immutable
class UnpostedInterest {
  const UnpostedInterest({
    required this.asOf,
    required this.accounts,
    required this.amount,
  });

  final LedgerDate asOf;
  final int accounts;
  final Money amount;

  @override
  bool operator ==(Object other) =>
      other is UnpostedInterest &&
      other.asOf == asOf &&
      other.accounts == accounts &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(asOf, accounts, amount);
}
