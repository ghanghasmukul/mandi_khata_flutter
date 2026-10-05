import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

enum ReportKind {
  outstanding,
  arrivals,
  commission,
  payments,
  statements,
  karza,
  interestEarned,
}

/// Which side of the khata the outstanding report lists.
enum OutstandingSide { all, payable, receivable }

/// A name in the three app languages; falls back to English.
@immutable
class LocalName {
  const LocalName(this.en, {this.hi, this.pa});

  final String en;
  final String? hi;
  final String? pa;

  String pick(String languageCode) {
    final name = switch (languageCode) {
      'hi' => hi,
      'pa' => pa,
      _ => null,
    };
    return name == null || name.isEmpty ? en : name;
  }
}

/// One party with money outstanding. [balance] is Σ jama − Σ udhaar: positive
/// = we owe them, negative = they owe us.
@immutable
class OutstandingRow {
  const OutstandingRow({
    required this.partyId,
    required this.code,
    required this.name,
    required this.balance,
    required this.lastEntry,
    this.village,
  });

  final String partyId;
  final String code;
  final String name;
  final String? village;
  final Money balance;
  final LedgerDate lastEntry;

  bool get weOwe => balance.isPositive;
}

/// One lot of the arrival register.
@immutable
class ArrivalRow {
  const ArrivalRow({
    required this.lotNo,
    required this.date,
    required this.farmerName,
    required this.crop,
    required this.bags,
    required this.status,
    this.farmerCode,
    this.qtlMilli,
    this.ratePerQtl,
    this.gross,
    this.commission,
    this.netToFarmer,
    this.buyerName,
  });

  final String lotNo;
  final LedgerDate date;
  final String farmerName;
  final String? farmerCode;
  final LocalName crop;
  final int bags;
  final int? qtlMilli;
  final Money? ratePerQtl;
  final Money? gross;
  final Money? commission;
  final Money? netToFarmer;
  final String? buyerName;
  final LotStatus status;

  /// What was taken off the gross before the farmer's net (commission and
  /// the charges he bears); null until the lot is posted.
  Money? get deductions =>
      gross == null || netToFarmer == null ? null : gross! - netToFarmer!;
}

/// One crop's volume and earnings.
@immutable
class CommissionRow {
  const CommissionRow({
    required this.cropCode,
    required this.crop,
    required this.lots,
    required this.qtlMilli,
    required this.gross,
    required this.commission,
  });

  final String cropCode;
  final LocalName crop;
  final int lots;
  final int qtlMilli;
  final Money gross;
  final Money commission;
}

/// One payment or receipt of the payment register.
@immutable
class PaymentRow {
  const PaymentRow({
    required this.receiptNo,
    required this.date,
    required this.partyName,
    required this.direction,
    required this.mode,
    required this.amount,
    this.partyCode,
    this.reference,
  });

  final String receiptNo;
  final LedgerDate date;
  final String partyName;
  final String? partyCode;
  final PaymentDirection direction;
  final PaymentMode mode;
  final Money amount;
  final String? reference;
}

/// A farmer's statement for the bulk print.
@immutable
class PartyStatement {
  const PartyStatement({
    required this.partyId,
    required this.code,
    required this.name,
    required this.statement,
    this.village,
    this.mobile,
  });

  final String partyId;
  final String code;
  final String name;
  final String? village;
  final String? mobile;
  final Statement statement;
}

/// One loan of the karza register with its figures on the report day.
@immutable
class KarzaRow {
  const KarzaRow({
    required this.loanNo,
    required this.partyName,
    required this.issued,
    required this.principal,
    required this.repaid,
    required this.outstanding,
    required this.accrued,
    required this.interestRecovered,
    required this.health,
    this.partyCode,
    this.due,
    this.daysOverdue,
  });

  final String loanNo;
  final String partyName;
  final String? partyCode;
  final LedgerDate issued;
  final LedgerDate? due;

  /// Principal issued, principal repaid and principal still outstanding.
  final Money principal;
  final Money repaid;
  final Money outstanding;

  /// Interest accrued and not yet paid, and interest already recovered.
  final Money accrued;
  final Money interestRecovered;
  final LoanHealth health;

  /// Days past the due date; null unless the loan is open and overdue.
  final int? daysOverdue;
}

/// One party's interest in a period: posted and waived in it, and what has
/// accrued and is still not posted (as of the report day).
@immutable
class InterestEarnedRow {
  const InterestEarnedRow({
    required this.partyId,
    required this.name,
    required this.posted,
    required this.waived,
    required this.unposted,
    this.code,
  });

  final String partyId;
  final String name;
  final String? code;
  final Money posted;
  final Money waived;
  final Money unposted;

  /// Posted plus accrued: what the business earned from this party.
  Money get earned => posted + unposted;
}

/// The filters the report screen offers; each report uses the ones that
/// apply to it.
@immutable
class ReportFilter {
  const ReportFilter({
    this.from,
    this.to,
    this.asOf,
    this.side = OutstandingSide.all,
    this.cropId,
    this.mode,
    this.village,
  });

  final LedgerDate? from;
  final LedgerDate? to;

  /// Outstanding report: balances up to and including this day (null =
  /// today).
  final LedgerDate? asOf;
  final OutstandingSide side;
  final String? cropId;
  final PaymentMode? mode;
  final String? village;

  ReportFilter copyWith({
    LedgerDate? Function()? from,
    LedgerDate? Function()? to,
    LedgerDate? Function()? asOf,
    OutstandingSide? side,
    String? Function()? cropId,
    PaymentMode? Function()? mode,
    String? Function()? village,
  }) => ReportFilter(
    from: from == null ? this.from : from(),
    to: to == null ? this.to : to(),
    asOf: asOf == null ? this.asOf : asOf(),
    side: side ?? this.side,
    cropId: cropId == null ? this.cropId : cropId(),
    mode: mode == null ? this.mode : mode(),
    village: village == null ? this.village : village(),
  );

  @override
  bool operator ==(Object other) =>
      other is ReportFilter &&
      other.from == from &&
      other.to == to &&
      other.asOf == asOf &&
      other.side == side &&
      other.cropId == cropId &&
      other.mode == mode &&
      other.village == village;

  @override
  int get hashCode => Object.hash(from, to, asOf, side, cropId, mode, village);
}
