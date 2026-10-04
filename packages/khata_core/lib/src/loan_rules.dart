import 'package:decimal/decimal.dart';
import 'package:khata_core/src/interest/interest_config.dart';
import 'package:khata_core/src/interest/interest_engine.dart';
import 'package:khata_core/src/interest/interest_result.dart';
import 'package:khata_core/src/interest/ledger_event.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/permissions.dart';
import 'package:meta/meta.dart';

/// `loans.status`.
enum LoanStatus {
  active('active'),
  closed('closed'),
  writtenOff('written_off');

  const LoanStatus(this.dbName);

  final String dbName;

  /// Only an active loan takes repayments, rate changes and a closing.
  bool get isOpen => this == active;

  static LoanStatus parse(String value) => values.firstWhere(
    (s) => s.dbName == value,
    orElse: () => throw FormatException('Unknown loan status', value),
  );
}

/// What the loan cards say about a loan.
enum LoanHealth {
  /// Open, due date far off (or none).
  onTrack,

  /// Open and due within [LoanRules.dueSoonDays] days (today included).
  dueSoon,

  /// Open and past its due date.
  overdue,

  /// Open but nothing is left to pay: ready to be closed.
  settled,
  closed,
  writtenOff,
}

/// What is wrong with a loan action before it is written.
enum LoanProblem {
  amountNotPositive,
  dueBeforeIssue,
  guarantorIsBorrower,
  rateInvalid,
  effectiveBeforeIssue,
  notActive,
  amountStillDue,
  nothingToWriteOff,
  reasonMissing,
  closedBeforeLastEntry,
}

/// What a person does to a loan (for permission checks).
enum LoanAction { issue, repay, adjustFromCrop, changeRate, close, writeOff }

/// A loan as the interest engine sees it on one day.
@immutable
class LoanPosition {
  const LoanPosition({
    required this.issued,
    required this.result,
    required this.asOf,
    required this.recoveryPercent,
    required this.health,
    this.daysLeft,
  });

  /// The principal the loan was issued for.
  final Money issued;

  /// The engine's full result: the statement rows and every total.
  final InterestResult result;

  /// The day the figures are for (never after the day a closed loan stopped).
  final LedgerDate asOf;

  /// Share of the issued principal already repaid, 0 to 100, rounded down.
  final int recoveryPercent;

  /// Days from [asOf] to the due date (negative = overdue); null without a
  /// due date.
  final int? daysLeft;
  final LoanHealth health;

  Money get principal => Money(result.principalPaise);
  Money get accrued => Money(result.accruedUnpaidPaise);
  Money get interestRecovered => Money(result.interestRecoveredPaise);
  Money get principalRecovered => Money(result.principalRecoveredPaise);

  /// What settles the loan on [asOf]: principal plus interest accrued.
  Money get payable => Money(result.totalPayablePaise);
}

/// How a repayment would be split, shown before it is saved.
@immutable
class LoanRepaymentPreview {
  const LoanRepaymentPreview({
    required this.interest,
    required this.principal,
    required this.surplus,
    required this.payableBefore,
    required this.payableAfter,
    required this.principalAfter,
    required this.asOf,
  });

  /// The part that pays interest.
  final Money interest;

  /// The part that pays principal.
  final Money principal;

  /// Paid beyond what was due: it would sit as credit with the party.
  final Money surplus;
  final Money payableBefore;
  final Money payableAfter;
  final Money principalAfter;

  /// The day the figures are for.
  final LedgerDate asOf;

  bool get exceedsPayable => surplus.isPositive;
}

/// Rules for loans (karza). Pure: the app and the server checks follow
/// these. The interest itself comes from the engine (`calculate`).
abstract final class LoanRules {
  /// A loan due within this many days (today included) is "due soon".
  static const dueSoonDays = 7;

  static final _rate = RegExp(r'^[0-9]{1,3}(\.[0-9]{1,4})?$');
  static final _hundred = Decimal.fromInt(100);

  /// A rate in % per annum: 0 to 100 with at most four decimals. Null when
  /// it is anything else.
  static Decimal? parseRate(String text) {
    final t = text.trim();
    if (!_rate.hasMatch(t)) return null;
    final d = Decimal.parse(t);
    return d > _hundred ? null : d;
  }

  /// The loan's figures on [asOf]. A loan that is not active stops at the
  /// day it was closed ([closedOn]).
  static LoanPosition position({
    required Money principal,
    required List<LedgerEvent> events,
    required InterestConfig config,
    required LedgerDate asOf,
    required LoanStatus status,
    LedgerDate? closedOn,
    LedgerDate? dueDate,
    List<RateChange> rateChanges = const [],
  }) {
    final stop = !status.isOpen && closedOn != null && closedOn < asOf
        ? closedOn
        : asOf;
    final result = calculate(
      events: events,
      config: config,
      asOf: stop,
      rateChanges: rateChanges,
    );
    final recovered = result.principalRecoveredPaise;
    final percent = principal.paise <= 0
        ? 0
        : (recovered * 100 ~/ principal.paise).clamp(0, 100);
    final left = dueDate == null ? null : stop.daysUntil(dueDate);
    return LoanPosition(
      issued: principal,
      result: result,
      asOf: stop,
      recoveryPercent: percent,
      daysLeft: left,
      health: _health(status, result.totalPayablePaise, left),
    );
  }

  static LoanHealth _health(LoanStatus status, int payable, int? daysLeft) {
    switch (status) {
      case LoanStatus.closed:
        return LoanHealth.closed;
      case LoanStatus.writtenOff:
        return LoanHealth.writtenOff;
      case LoanStatus.active:
        if (payable == 0) return LoanHealth.settled;
        if (daysLeft == null) return LoanHealth.onTrack;
        if (daysLeft < 0) return LoanHealth.overdue;
        if (daysLeft <= dueSoonDays) return LoanHealth.dueSoon;
        return LoanHealth.onTrack;
    }
  }

  /// How a repayment of [amount] on [repaymentDate] would be split, with
  /// the loan's payable before and after. Figures are as of the later of the
  /// repayment date and the loan's last entry, so a back-dated repayment
  /// still sees everything recorded after it.
  static LoanRepaymentPreview previewRepayment({
    required List<LedgerEvent> events,
    required InterestConfig config,
    required LedgerDate repaymentDate,
    required Money amount,
    List<RateChange> rateChanges = const [],
  }) {
    if (!amount.isPositive) {
      throw ArgumentError.value(amount, 'amount', 'must be positive');
    }
    var asOf = repaymentDate;
    for (final e in events) {
      if (e.date > asOf) asOf = e.date;
    }
    final before = calculate(
      events: events,
      config: config,
      asOf: asOf,
      rateChanges: rateChanges,
    );
    const previewId = '\u0000preview';
    final after = calculate(
      events: [
        ...events,
        LedgerEvent(
          id: previewId,
          date: repaymentDate,
          side: Side.jama,
          amountPaise: amount.paise,
          // Last of its day.
          createdAt: DateTime.utc(9999),
        ),
      ],
      config: config,
      asOf: asOf,
      rateChanges: rateChanges,
    );
    final row = after.schedule.firstWhere(
      (r) => r.kind == InterestRowKind.credit && r.eventId == previewId,
    );
    return LoanRepaymentPreview(
      interest: Money(row.payInterestPaise),
      principal: Money(row.payPrincipalPaise),
      surplus: Money(row.toCreditBalancePaise),
      payableBefore: Money(before.totalPayablePaise),
      payableAfter: Money(after.totalPayablePaise),
      principalAfter: Money(after.principalPaise),
      asOf: asOf,
    );
  }

  /// Problems with issuing a loan; empty = fine. [ratePa] is the text the
  /// person typed or the snapshot holds.
  static List<LoanProblem> validateIssue({
    required Money amount,
    required LedgerDate issueDate,
    required String partyId,
    required String ratePa,
    LedgerDate? dueDate,
    String? guarantorId,
  }) => [
    if (!amount.isPositive) LoanProblem.amountNotPositive,
    if (dueDate != null && dueDate < issueDate) LoanProblem.dueBeforeIssue,
    if (guarantorId != null && guarantorId == partyId)
      LoanProblem.guarantorIsBorrower,
    if (parseRate(ratePa) == null) LoanProblem.rateInvalid,
  ];

  /// Problems with a new effective-dated rate.
  static List<LoanProblem> validateRateChange({
    required String ratePa,
    required LedgerDate effectiveDate,
    required LedgerDate issueDate,
    required LoanStatus status,
  }) => [
    if (!status.isOpen) LoanProblem.notActive,
    if (parseRate(ratePa) == null) LoanProblem.rateInvalid,
    if (effectiveDate < issueDate) LoanProblem.effectiveBeforeIssue,
  ];

  /// Closing needs an open loan with nothing left to pay.
  static List<LoanProblem> validateClose({
    required LoanPosition position,
    required LedgerDate closedOn,
    required LedgerDate issueDate,
    required LedgerDate lastEventDate,
  }) =>
      position.health == LoanHealth.closed ||
          position.health == LoanHealth.writtenOff
      ? [LoanProblem.notActive]
      : [
          if (position.payable.isPositive) LoanProblem.amountStillDue,
          if (closedOn < lastEventDate || closedOn < issueDate)
            LoanProblem.closedBeforeLastEntry,
        ];

  /// Writing off needs an open loan with something left, and a reason.
  static List<LoanProblem> validateWriteOff({
    required LoanPosition position,
    required LedgerDate closedOn,
    required LedgerDate issueDate,
    required LedgerDate lastEventDate,
    required String reason,
  }) =>
      position.health == LoanHealth.closed ||
          position.health == LoanHealth.writtenOff
      ? [LoanProblem.notActive]
      : [
          if (!position.payable.isPositive) LoanProblem.nothingToWriteOff,
          if (reason.trim().isEmpty) LoanProblem.reasonMissing,
          if (closedOn < lastEventDate || closedOn < issueDate)
            LoanProblem.closedBeforeLastEntry,
        ];

  /// How much of a party's khata can be adjusted against a loan: only a
  /// credit (we owe them, e.g. crop proceeds) counts. [balance] is the
  /// khata balance (Σ jama − Σ udhaar).
  static Money cropProceedsAvailable(Money balance) =>
      balance.isPositive ? balance : Money.zero;

  /// Permissions [action] needs (docs/domain/ledger-and-mandi.md). Cash vs
  /// bank and the payment limit are PaymentRules' business.
  static List<Permission> requiredPermissions(LoanAction action) =>
      switch (action) {
        LoanAction.issue ||
        LoanAction.changeRate ||
        LoanAction.close ||
        LoanAction.writeOff => const [Permission.loansManage],
        LoanAction.repay => const [Permission.paymentsCreate],
        // Two khata entries that cancel each other out: the repayment and a
        // journal line.
        LoanAction.adjustFromCrop => const [
          Permission.paymentsCreate,
          Permission.entriesReverse,
        ],
      };
}
