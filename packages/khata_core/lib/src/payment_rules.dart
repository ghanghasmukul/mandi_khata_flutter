import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/permissions.dart';

/// Which way the money moved (`payments.direction`).
enum PaymentDirection {
  /// We paid the party (bhugtaan): udhaar on their khata, money out.
  toParty('to_party'),

  /// The party paid us (receipt): jama on their khata, money in.
  fromParty('from_party');

  const PaymentDirection(this.dbName);

  final String dbName;

  static PaymentDirection parse(String value) => values.firstWhere(
    (d) => d.dbName == value,
    orElse: () => throw FormatException('Unknown payment direction', value),
  );

  /// The khata side of the payment's entry.
  Side get side => this == toParty ? Side.udhaar : Side.jama;

  /// The ledger `ref_type`: a payment to a party, or a receipt from one.
  RefType get refType => this == toParty ? RefType.payment : RefType.receipt;

  /// The cash / bank book line is the opposite of the khata side: paying out
  /// credits the book, receiving debits it.
  BookDirection get book =>
      this == toParty ? BookDirection.moneyOut : BookDirection.moneyIn;
}

/// A line of the cash / bank book (`cash_bank_entries.direction`).
enum BookDirection {
  /// Money came in (debit).
  moneyIn('in'),

  /// Money went out (credit).
  moneyOut('out');

  const BookDirection(this.dbName);

  final String dbName;

  BookDirection get opposite => this == moneyIn ? moneyOut : moneyIn;

  static BookDirection parse(String value) => values.firstWhere(
    (d) => d.dbName == value,
    orElse: () => throw FormatException('Unknown book direction', value),
  );
}

/// How the money moved (`payments.mode`).
enum PaymentMode {
  cash,
  bank,
  upi,
  cheque;

  static PaymentMode parse(String value) => values.firstWhere(
    (m) => m.name == value,
    orElse: () => throw FormatException('Unknown payment mode', value),
  );

  /// Goes through the cash account; every other mode needs a bank account.
  bool get usesCashAccount => this == cash;
}

/// Where a cheque is (`payments.cheque_status`).
enum ChequeStatus {
  pending,
  cleared,
  bounced;

  static ChequeStatus parse(String value) => values.firstWhere(
    (s) => s.name == value,
    orElse: () => throw FormatException('Unknown cheque status', value),
  );

  /// A pending cheque clears or bounces; both are final.
  bool canMoveTo(ChequeStatus to) => this == pending && to != pending;
}

/// What is wrong with a payment before it is posted.
enum PaymentProblem {
  amountNotPositive,

  /// A cheque needs its number.
  chequeNoMissing,

  /// A cheque needs its date.
  chequeDateMissing,

  /// Bank, UPI and cheque payments need a bank account.
  bankAccountMissing,

  /// Cheque details were given for another mode.
  chequeDetailsNotAllowed,
}

/// Rules for payments and receipts (docs/domain/ledger-and-mandi.md,
/// "Payments"). Pure: the app and the server checks follow these.
abstract final class PaymentRules {
  /// Problems with a payment of [amount] by [mode]; empty = fine.
  static List<PaymentProblem> validate({
    required Money amount,
    required PaymentMode mode,
    String? chequeNo,
    LedgerDate? chequeDate,
    bool hasBankAccount = false,
  }) {
    final isCheque = mode == PaymentMode.cheque;
    return [
      if (!amount.isPositive) PaymentProblem.amountNotPositive,
      if (!mode.usesCashAccount && !hasBankAccount)
        PaymentProblem.bankAccountMissing,
      if (isCheque && (chequeNo == null || chequeNo.trim().isEmpty))
        PaymentProblem.chequeNoMissing,
      if (isCheque && chequeDate == null) PaymentProblem.chequeDateMissing,
      if (!isCheque && (chequeNo?.trim().isNotEmpty ?? false))
        PaymentProblem.chequeDetailsNotAllowed,
    ];
  }

  /// The khata balance (Σ jama − Σ udhaar) once [amount] is posted.
  static Money balanceAfter(
    Money balance,
    PaymentDirection direction,
    Money amount,
  ) => direction == PaymentDirection.toParty
      ? balance - amount
      : balance + amount;

  /// The amount that settles the khata ("Full baki"): what we owe the party
  /// when paying them, what they owe us when receiving. Null when there is
  /// nothing to settle in that direction.
  static Money? fullBaki(Money balance, PaymentDirection direction) {
    final due = direction == PaymentDirection.toParty ? balance : -balance;
    return due.isPositive ? due : null;
  }

  /// A payment to a party above a non-zero [limit] needs `entries.reverse`
  /// (setting `business.munshi_payment_limit`; 0 = no limit). Receipts are
  /// never limited.
  static bool exceedsLimit(
    PaymentDirection direction,
    Money amount,
    Money limit,
  ) =>
      direction == PaymentDirection.toParty &&
      limit.isPositive &&
      amount > limit;

  /// Permissions to record a payment: `payments.create`; above the limit
  /// also `entries.reverse`; any mode but cash also `finance.view` (bank
  /// accounts are finance details). Back-dating is checked by
  /// [LedgerPosting.requiredPermissions].
  static List<Permission> requiredPermissions({
    required PaymentDirection direction,
    required PaymentMode mode,
    required Money amount,
    required Money limit,
  }) => [
    Permission.paymentsCreate,
    if (!mode.usesCashAccount) Permission.financeView,
    if (exceedsLimit(direction, amount, limit)) Permission.entriesReverse,
  ];

  /// Marking a cheque cleared needs `payments.create`; a bounce reverses
  /// the khata entry, so it needs `entries.reverse`.
  static Permission cheque(ChequeStatus to) => to == ChequeStatus.bounced
      ? Permission.entriesReverse
      : Permission.paymentsCreate;
}
