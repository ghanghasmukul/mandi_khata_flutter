import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// `bank_accounts.kind`.
enum AccountKind { cash, bank }

/// One of the business's own accounts: the Cash account or a bank account.
@immutable
class BankAccount {
  const BankAccount({
    required this.id,
    required this.kind,
    required this.name,
    required this.isActive,
    this.bankName,
    this.last4,
    this.ifsc,
    this.sortOrder = 0,
  });

  factory BankAccount.fromRow(Map<String, Object?> r) => BankAccount(
    id: r['id']! as String,
    kind: (r['kind'] as String?) == 'cash'
        ? AccountKind.cash
        : AccountKind.bank,
    name: r['name']! as String,
    bankName: r['bank_name'] as String?,
    last4: r['account_last4'] as String?,
    ifsc: r['ifsc'] as String?,
    sortOrder: (r['sort_order'] as int?) ?? 0,
    isActive: r['is_active'] == 1 || r['is_active'] == true,
  );

  final String id;
  final AccountKind kind;
  final String name;
  final String? bankName;

  /// Last 4 digits of the account number; nothing more is ever stored.
  final String? last4;
  final String? ifsc;
  final int sortOrder;
  final bool isActive;

  bool get isCash => kind == AccountKind.cash;

  /// "SBI Current · ••7890".
  String get label => last4 == null ? name : '$name · ••$last4';
}

/// What the bank account form holds.
@immutable
class BankAccountInput {
  const BankAccountInput({
    required this.name,
    this.bankName,
    this.last4,
    this.ifsc,
  });

  final String name;
  final String? bankName;
  final String? last4;
  final String? ifsc;

  static final _last4 = RegExp(r'^[0-9]{4}$');
  static final _ifsc = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  /// Field → what is wrong.
  Set<BankAccountProblem> validate() => {
    if (name.trim().isEmpty) BankAccountProblem.nameMissing,
    if (_clean(last4) case final l? when !_last4.hasMatch(l))
      BankAccountProblem.last4Invalid,
    if (_clean(ifsc)?.toUpperCase() case final i? when !_ifsc.hasMatch(i))
      BankAccountProblem.ifscInvalid,
  };

  Map<String, Object?> columns() => {
    'name': name.trim(),
    'bank_name': _clean(bankName),
    'account_last4': _clean(last4),
    'ifsc': _clean(ifsc)?.toUpperCase(),
  };

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}

enum BankAccountProblem { nameMissing, last4Invalid, ifscInvalid }

sealed class BankAccountResult {
  const BankAccountResult();
}

final class BankAccountSaved extends BankAccountResult {
  const BankAccountSaved(this.id);

  final String id;
}

final class BankAccountNotPermitted extends BankAccountResult {
  const BankAccountNotPermitted();
}

final class BankAccountInvalid extends BankAccountResult {
  const BankAccountInvalid(this.problems);

  final Set<BankAccountProblem> problems;
}

final class BankAccountNotFound extends BankAccountResult {
  const BankAccountNotFound();
}

/// Ties a payment to a loan (karza): the money out that disburses it, or the
/// money in that repays it.
@immutable
class LoanPaymentLink {
  const LoanPaymentLink.disbursal({required this.loanId, required this.loanNo})
    : isDisbursal = true;

  const LoanPaymentLink.repayment({required this.loanId, required this.loanNo})
    : isDisbursal = false;

  final String loanId;

  /// `KZ-W1-0001`, written into the khata narration.
  final String loanNo;
  final bool isDisbursal;

  /// The ledger `ref_type` of the payment's khata entry.
  RefType get refType =>
      isDisbursal ? RefType.loanDisbursal : RefType.loanRepayment;
}

/// A payment or receipt as stored locally, with the names the screens show.
@immutable
class Payment {
  const Payment({
    required this.id,
    required this.receiptNo,
    required this.entryDate,
    required this.partyId,
    required this.partyName,
    required this.direction,
    required this.mode,
    required this.amount,
    required this.bankAccountId,
    required this.status,
    required this.createdAt,
    this.partyCode,
    this.accountName,
    this.reference,
    this.chequeNo,
    this.chequeDate,
    this.chequeStatus,
    this.narration,
    this.reversedAt,
    this.loanId,
  });

  /// From a `payments` row joined with the party and account (see
  /// `PaymentsRepository`).
  factory Payment.fromRow(Map<String, Object?> r) => Payment(
    id: r['id']! as String,
    receiptNo: r['receipt_no']! as String,
    entryDate: LedgerDate.parse(r['entry_date']! as String),
    partyId: r['party_id']! as String,
    partyName: (r['party_name'] as String?) ?? '',
    partyCode: r['party_code'] as String?,
    direction: PaymentDirection.parse(r['direction']! as String),
    mode: PaymentMode.parse(r['mode']! as String),
    amount: Money(r['amount_paise']! as int),
    bankAccountId: r['bank_account_id']! as String,
    accountName: r['account_name'] as String?,
    reference: r['reference'] as String?,
    chequeNo: r['cheque_no'] as String?,
    chequeDate: switch (r['cheque_date']) {
      final String s => LedgerDate.parse(s),
      _ => null,
    },
    chequeStatus: switch (r['cheque_status']) {
      final String s => ChequeStatus.parse(s),
      _ => null,
    },
    narration: r['narration'] as String?,
    status: (r['status']! as String) == 'reversed'
        ? PaymentStatus.reversed
        : PaymentStatus.posted,
    reversedAt: switch (r['reversed_at']) {
      final String s => DateTime.parse(s),
      _ => null,
    },
    createdAt: DateTime.parse(r['created_at']! as String),
    loanId: r['loan_id'] as String?,
  );

  final String id;

  /// `V-W1-0001` (paid to a party) or `R-W1-0001` (received).
  final String receiptNo;
  final LedgerDate entryDate;
  final String partyId;
  final String partyName;
  final String? partyCode;
  final PaymentDirection direction;
  final PaymentMode mode;
  final Money amount;
  final String bankAccountId;

  /// Null when the account is not on this device (a munshi's device has no
  /// bank accounts).
  final String? accountName;
  final String? reference;
  final String? chequeNo;
  final LedgerDate? chequeDate;
  final ChequeStatus? chequeStatus;
  final String? narration;
  final PaymentStatus status;
  final DateTime? reversedAt;
  final DateTime createdAt;

  /// The loan this payment disburses or repays; null for an ordinary one.
  final String? loanId;

  bool get isReversed => status == PaymentStatus.reversed;

  /// The money out of a loan: undone only from the loan, never here.
  bool get isLoanDisbursal =>
      loanId != null && direction == PaymentDirection.toParty;

  /// A cheque still waiting to clear or bounce.
  bool get isPendingCheque =>
      !isReversed && chequeStatus == ChequeStatus.pending;
}

enum PaymentStatus { posted, reversed }

/// What the record-payment dialog holds.
@immutable
class PaymentDraft {
  const PaymentDraft({
    required this.entryDate,
    required this.partyId,
    required this.direction,
    required this.mode,
    required this.amount,
    this.bankAccountId,
    this.reference,
    this.chequeNo,
    this.chequeDate,
    this.narration,
  });

  final LedgerDate entryDate;
  final String partyId;
  final PaymentDirection direction;
  final PaymentMode mode;
  final Money amount;

  /// A bank account for every mode but cash (cash uses the Cash account).
  final String? bankAccountId;
  final String? reference;
  final String? chequeNo;
  final LedgerDate? chequeDate;
  final String? narration;

  List<PaymentProblem> validate() => PaymentRules.validate(
    amount: amount,
    mode: mode,
    chequeNo: chequeNo,
    chequeDate: chequeDate,
    hasBankAccount: bankAccountId != null,
  );
}

/// Filters for the payments list. All null = every payment.
@immutable
class PaymentFilter {
  const PaymentFilter({
    this.from,
    this.to,
    this.partyId,
    this.direction,
    this.mode,
    this.pendingChequesOnly = false,
    this.query = '',
  });

  final LedgerDate? from;
  final LedgerDate? to;
  final String? partyId;
  final PaymentDirection? direction;
  final PaymentMode? mode;
  final bool pendingChequesOnly;

  /// Matches the party's name or code, the receipt number or cheque number.
  final String query;

  PaymentFilter copyWith({
    LedgerDate? Function()? from,
    LedgerDate? Function()? to,
    String? Function()? partyId,
    PaymentDirection? Function()? direction,
    PaymentMode? Function()? mode,
    bool? pendingChequesOnly,
    String? query,
  }) => PaymentFilter(
    from: from == null ? this.from : from(),
    to: to == null ? this.to : to(),
    partyId: partyId == null ? this.partyId : partyId(),
    direction: direction == null ? this.direction : direction(),
    mode: mode == null ? this.mode : mode(),
    pendingChequesOnly: pendingChequesOnly ?? this.pendingChequesOnly,
    query: query ?? this.query,
  );

  @override
  bool operator ==(Object other) =>
      other is PaymentFilter &&
      other.from == from &&
      other.to == to &&
      other.partyId == partyId &&
      other.direction == direction &&
      other.mode == mode &&
      other.pendingChequesOnly == pendingChequesOnly &&
      other.query == query;

  @override
  int get hashCode => Object.hash(
    from,
    to,
    partyId,
    direction,
    mode,
    pendingChequesOnly,
    query,
  );
}

/// Totals of a list of payments; reversed ones are left out.
@immutable
class PaymentTotals {
  const PaymentTotals({
    required this.count,
    required this.paid,
    required this.received,
  });

  factory PaymentTotals.of(Iterable<Payment> payments) {
    var count = 0;
    var paid = Money.zero;
    var received = Money.zero;
    for (final p in payments) {
      if (p.isReversed) continue;
      count++;
      if (p.direction == PaymentDirection.toParty) {
        paid += p.amount;
      } else {
        received += p.amount;
      }
    }
    return PaymentTotals(count: count, paid: paid, received: received);
  }

  final int count;
  final Money paid;
  final Money received;
}

sealed class PaymentSaveResult {
  const PaymentSaveResult();
}

final class PaymentSaved extends PaymentSaveResult {
  const PaymentSaved(this.id, this.receiptNo);

  final String id;
  final String receiptNo;
}

final class PaymentNotPermitted extends PaymentSaveResult {
  const PaymentNotPermitted(
    this.permission, {
    this.backdateDays,
    this.limit,
    this.lockedYear = false,
  });

  final Permission permission;

  /// The date is in a closed financial year.
  final bool lockedYear;

  /// Set when the date is outside the back-date window; the window in days.
  final int? backdateDays;

  /// Set when the amount is above the payment limit; the limit.
  final Money? limit;
}

/// The party or bank account does not exist in this business.
final class PaymentNotFound extends PaymentSaveResult {
  const PaymentNotFound();
}

final class PaymentInvalid extends PaymentSaveResult {
  const PaymentInvalid(this.problems);

  final List<PaymentProblem> problems;
}

/// The payment is already reversed (or the cheque is no longer pending).
final class PaymentLocked extends PaymentSaveResult {
  const PaymentLocked();
}
