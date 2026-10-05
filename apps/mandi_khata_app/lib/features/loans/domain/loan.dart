import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';

/// A loan (karza) as stored locally, with the names the screens show.
@immutable
class Loan {
  const Loan({
    required this.id,
    required this.loanNo,
    required this.partyId,
    required this.partyName,
    required this.issueDate,
    required this.principal,
    required this.config,
    required this.status,
    required this.createdAt,
    this.partyCode,
    this.purpose,
    this.dueDate,
    this.guarantorId,
    this.guarantorName,
    this.closedOn,
    this.closeReason,
    this.notes,
  });

  /// From a `loans` row joined with the borrower (`party_name`,
  /// `party_code`) and guarantor (`guarantor_name`).
  factory Loan.fromRow(Map<String, Object?> r) => Loan(
    id: r['id']! as String,
    loanNo: r['loan_no']! as String,
    partyId: r['party_id']! as String,
    partyName: (r['party_name'] as String?) ?? '',
    partyCode: r['party_code'] as String?,
    issueDate: LedgerDate.parse(r['issue_date']! as String),
    principal: Money(r['principal_paise']! as int),
    purpose: r['purpose'] as String?,
    dueDate: switch (r['due_date']) {
      final String s => LedgerDate.parse(s),
      _ => null,
    },
    guarantorId: r['guarantor_party_id'] as String?,
    guarantorName: r['guarantor_name'] as String?,
    config: InterestConfig.fromJson(
      jsonDecode(r['interest_config_snapshot']! as String)
          as Map<String, Object?>,
    ),
    status: LoanStatus.parse(r['status']! as String),
    closedOn: switch (r['closed_on']) {
      final String s => LedgerDate.parse(s),
      _ => null,
    },
    closeReason: r['close_reason'] as String?,
    notes: r['notes'] as String?,
    createdAt: DateTime.parse(r['created_at']! as String),
  );

  final String id;

  /// `KZ-W1-0001`.
  final String loanNo;
  final String partyId;
  final String partyName;
  final String? partyCode;
  final LedgerDate issueDate;
  final Money principal;
  final String? purpose;
  final LedgerDate? dueDate;
  final String? guarantorId;
  final String? guarantorName;

  /// The interest terms snapshotted when the loan was issued.
  final InterestConfig config;
  final LoanStatus status;
  final LedgerDate? closedOn;
  final String? closeReason;
  final String? notes;
  final DateTime createdAt;

  bool get isOpen => status.isOpen;
}

/// One rate change of a loan.
@immutable
class LoanRateChange {
  const LoanRateChange({
    required this.id,
    required this.effectiveDate,
    required this.ratePa,
    required this.createdAt,
    this.reason,
  });

  factory LoanRateChange.fromRow(Map<String, Object?> r) => LoanRateChange(
    id: r['id']! as String,
    effectiveDate: LedgerDate.parse(r['effective_date']! as String),
    ratePa: Decimal.parse(r['rate_pa']! as String),
    reason: r['reason'] as String?,
    createdAt: DateTime.parse(r['created_at']! as String),
  );

  final String id;
  final LedgerDate effectiveDate;

  /// % per annum.
  final Decimal ratePa;
  final String? reason;
  final DateTime createdAt;

  RateChange toEngine() =>
      RateChange(effectiveDate: effectiveDate, ratePa: ratePa, reason: reason);
}

/// A khata entry that belongs to a loan (its disbursal or a repayment).
@immutable
class LoanEntry {
  const LoanEntry({required this.entry, this.paymentId, this.isWaiver = false});

  final LedgerEntry entry;

  /// The payment (voucher / receipt) behind it, when there is one.
  final String? paymentId;

  /// An interest waiver: a credit that only takes interest off.
  final bool isWaiver;

  bool get isDisbursal => entry.refType == RefType.loanDisbursal;

  LedgerEvent toEvent() => LedgerEvent(
    id: entry.id,
    date: entry.entryDate,
    side: entry.side,
    amountPaise: entry.amount.paise,
    createdAt: entry.createdAt,
    note: entry.narration,
    interestOnly: isWaiver,
  );
}

/// What the loan screens work on: the loan with everything the engine needs.
/// The figures for a day come from [position] (khata_core).
@immutable
class LoanDetail {
  const LoanDetail({
    required this.loan,
    required this.entries,
    required this.rateChanges,
  });

  final Loan loan;

  /// Disbursal and repayments that are not reversed.
  final List<LoanEntry> entries;

  /// Oldest first (same day: the one recorded later wins).
  final List<LoanRateChange> rateChanges;

  List<LedgerEvent> get events => [for (final e in entries) e.toEvent()];

  List<RateChange> get engineRateChanges => [
    for (final c in rateChanges) c.toEngine(),
  ];

  /// The day of the last entry (the issue date when there is none).
  LedgerDate get lastEntryDate {
    var last = loan.issueDate;
    for (final e in entries) {
      if (e.entry.entryDate > last) last = e.entry.entryDate;
    }
    return last;
  }

  /// The loan's figures on [asOf].
  LoanPosition position(LedgerDate asOf) => LoanRules.position(
    principal: loan.principal,
    events: events,
    config: loan.config,
    asOf: asOf,
    status: loan.status,
    closedOn: loan.closedOn,
    dueDate: loan.dueDate,
    rateChanges: engineRateChanges,
  );

  /// How a repayment of [amount] on [date] would be split.
  LoanRepaymentPreview previewRepayment(LedgerDate date, Money amount) =>
      LoanRules.previewRepayment(
        events: events,
        config: loan.config,
        repaymentDate: date,
        amount: amount,
        rateChanges: engineRateChanges,
      );
}

/// One loan on the list with its figures as of a day.
@immutable
class LoanSummary {
  const LoanSummary({required this.loan, required this.position});

  final Loan loan;
  final LoanPosition position;
}

/// Which loans the list shows.
enum LoanStatusFilter {
  open,
  closed,
  all;

  /// The `loans.status` values selected, or null for every status.
  Set<LoanStatus>? get statuses => switch (this) {
    open => {LoanStatus.active},
    closed => {LoanStatus.closed, LoanStatus.writtenOff},
    all => null,
  };
}

@immutable
class LoanFilter {
  const LoanFilter({this.status = LoanStatusFilter.open, this.query = ''});

  final LoanStatusFilter status;

  /// Matches the borrower's name or code, or the loan number.
  final String query;

  LoanFilter copyWith({LoanStatusFilter? status, String? query}) =>
      LoanFilter(status: status ?? this.status, query: query ?? this.query);

  @override
  bool operator ==(Object other) =>
      other is LoanFilter && other.status == status && other.query == query;

  @override
  int get hashCode => Object.hash(status, query);
}

/// Totals of the loans on the list (open loans only count).
@immutable
class LoanTotals {
  const LoanTotals({
    required this.count,
    required this.principal,
    required this.interest,
    required this.overdue,
  });

  factory LoanTotals.of(Iterable<LoanSummary> loans) {
    var count = 0;
    var principal = Money.zero;
    var interest = Money.zero;
    var overdue = 0;
    for (final s in loans) {
      if (!s.loan.isOpen) continue;
      count++;
      principal += s.position.principal;
      interest += s.position.accrued;
      if (s.position.health == LoanHealth.overdue) overdue++;
    }
    return LoanTotals(
      count: count,
      principal: principal,
      interest: interest,
      overdue: overdue,
    );
  }

  final int count;

  /// Outstanding principal.
  final Money principal;

  /// Interest accrued and not yet paid.
  final Money interest;
  final int overdue;
}

/// What the "Issue loan" form holds.
@immutable
class LoanDraft {
  const LoanDraft({
    required this.partyId,
    required this.amount,
    required this.issueDate,
    required this.config,
    this.purpose,
    this.dueDate,
    this.guarantorPartyId,
    this.mode = PaymentMode.cash,
    this.bankAccountId,
    this.reference,
    this.chequeNo,
    this.chequeDate,
    this.notes,
  });

  final String partyId;
  final Money amount;
  final LedgerDate issueDate;

  /// The terms to snapshot (prefilled from the settings cascade, edited).
  final InterestConfig config;
  final String? purpose;
  final LedgerDate? dueDate;
  final String? guarantorPartyId;

  /// How the money leaves: the payment out.
  final PaymentMode mode;
  final String? bankAccountId;
  final String? reference;
  final String? chequeNo;
  final LedgerDate? chequeDate;
  final String? notes;

  PaymentDraft toPayment() => PaymentDraft(
    entryDate: issueDate,
    partyId: partyId,
    direction: PaymentDirection.toParty,
    mode: mode,
    amount: amount,
    bankAccountId: bankAccountId,
    reference: reference,
    chequeNo: chequeNo,
    chequeDate: chequeDate,
    narration: purpose,
  );
}

/// Where a repayment comes from.
enum RepaymentSource {
  /// Money handed over (cash, bank, UPI, cheque).
  payment,

  /// Set off against the borrower's crop proceeds already in the khata.
  cropProceeds,
}

/// What the "Record repayment" dialog holds.
@immutable
class LoanRepaymentDraft {
  const LoanRepaymentDraft({
    required this.loanId,
    required this.date,
    required this.amount,
    this.source = RepaymentSource.payment,
    this.mode = PaymentMode.cash,
    this.bankAccountId,
    this.reference,
    this.chequeNo,
    this.chequeDate,
    this.narration,
  });

  final String loanId;
  final LedgerDate date;
  final Money amount;
  final RepaymentSource source;
  final PaymentMode mode;
  final String? bankAccountId;
  final String? reference;
  final String? chequeNo;
  final LedgerDate? chequeDate;
  final String? narration;

  PaymentDraft toPayment(String partyId) => PaymentDraft(
    entryDate: date,
    partyId: partyId,
    direction: PaymentDirection.fromParty,
    mode: mode,
    amount: amount,
    bankAccountId: bankAccountId,
    reference: reference,
    chequeNo: chequeNo,
    chequeDate: chequeDate,
    narration: narration,
  );
}

sealed class LoanResult {
  const LoanResult();
}

final class LoanSaved extends LoanResult {
  const LoanSaved(this.id, this.loanNo);

  final String id;
  final String loanNo;
}

final class LoanNotPermitted extends LoanResult {
  const LoanNotPermitted(this.permission, {this.backdateDays, this.limit});

  final Permission permission;

  /// Set when the date is outside the back-date window.
  final int? backdateDays;

  /// Set when the amount is above the payment limit.
  final Money? limit;
}

final class LoanInvalid extends LoanResult {
  const LoanInvalid({
    this.problems = const [],
    this.paymentProblems = const [],
  });

  final List<LoanProblem> problems;
  final List<PaymentProblem> paymentProblems;
}

/// The loan, borrower, guarantor or bank account is not in this business.
final class LoanNotFound extends LoanResult {
  const LoanNotFound();
}

/// The loan is closed or written off.
final class LoanNotActive extends LoanResult {
  const LoanNotActive();
}

/// A repayment above what is due: it would only be credit with the party.
final class LoanExceedsPayable extends LoanResult {
  const LoanExceedsPayable(this.payable);

  final Money payable;
}

/// An adjustment above the crop proceeds the party has in the khata.
final class LoanExceedsCrop extends LoanResult {
  const LoanExceedsCrop(this.available);

  final Money available;
}
