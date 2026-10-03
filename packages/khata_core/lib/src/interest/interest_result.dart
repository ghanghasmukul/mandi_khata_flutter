import 'package:decimal/decimal.dart';
import 'package:khata_core/src/interest/interest_math.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:meta/meta.dart';

enum InterestRowKind { accrue, debit, credit, compound, rateChange }

/// One line of the interest statement: a slab of days, an event, a
/// compounding step or a rate change.
@immutable
class InterestRow {
  InterestRow({
    required this.kind,
    required this.from,
    required this.to,
    required this.principalPaise,
    required this.ratePa,
    this.days = 0,
    Decimal? interest,
    this.amountPaise = 0,
    this.payInterestPaise = 0,
    this.payPrincipalPaise = 0,
    this.toCreditBalancePaise = 0,
    this.fromCreditBalancePaise = 0,
    this.inPartyFavour = false,
    this.eventId,
    this.note,
  }) : interest = interest ?? Decimal.zero;

  final InterestRowKind kind;

  /// First day (counts). Equal to [to] for event, compound and rate rows.
  final LedgerDate from;

  /// Last day, exclusive.
  final LedgerDate to;

  final int days;

  /// Principal outstanding during the slab, or after the event / step.
  final int principalPaise;

  /// Rate used (% p.a.).
  final Decimal ratePa;

  /// Exact (unrounded) interest of an accrue slab, or the amount capitalised
  /// by a compound step.
  final Decimal interest;

  /// [interest] to whole paise, half-up. For display only.
  int get interestPaise => roundHalfUpPaise(interest);

  /// Amount of a debit / credit event.
  final int amountPaise;

  /// How a credit was split.
  final int payInterestPaise;
  final int payPrincipalPaise;

  /// A credit's surplus kept as credit balance.
  final int toCreditBalancePaise;

  /// The part of a debit set off against credit balance.
  final int fromCreditBalancePaise;

  /// An accrue row where the interest is owed TO the party (`pay_on_jama`).
  final bool inPartyFavour;
  final String? eventId;
  final String? note;
}

@immutable
class InterestResult {
  const InterestResult({
    required this.schedule,
    required this.principalPaise,
    required this.accruedUnpaidPaise,
    required this.interestRecoveredPaise,
    required this.principalRecoveredPaise,
    required this.creditBalancePaise,
    required this.interestPayableToPartyPaise,
  });

  static const empty = InterestResult(
    schedule: [],
    principalPaise: 0,
    accruedUnpaidPaise: 0,
    interestRecoveredPaise: 0,
    principalRecoveredPaise: 0,
    creditBalancePaise: 0,
    interestPayableToPartyPaise: 0,
  );

  /// Every slab, event, compounding step and rate change, in order.
  final List<InterestRow> schedule;

  /// Outstanding principal (udhaar side, never negative).
  final int principalPaise;

  /// Interest accrued and not yet recovered, rounded by `interest.rounding`.
  final int accruedUnpaidPaise;

  /// Interest already recovered from repayments.
  final int interestRecoveredPaise;
  final int principalRecoveredPaise;

  /// Surplus jama: what we owe the party. Never negative.
  final int creditBalancePaise;

  /// Interest earned by the party on their credit (`pay_on_jama`), rounded by
  /// `interest.rounding`. Not part of [totalPayablePaise].
  final int interestPayableToPartyPaise;

  /// Principal plus accrued unpaid interest: payable if settled "today".
  int get totalPayablePaise => principalPaise + accruedUnpaidPaise;
}
