import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// Khata entries that settle what we owe a supplier (money paid to them, a
/// voucher or journal debit, a purchase return credit note). Everything else
/// on a supplier's khata is left out of the FIFO allocation.
const supplierSettlementRefTypes = <String>{
  'payment',
  'voucher',
  'journal',
  'purchase_return',
};

/// The unpaid (khata) part of one purchase bill.
@immutable
final class SupplierBill {
  const SupplierBill({
    required this.purchaseId,
    required this.purchaseNo,
    required this.invoiceDate,
    required this.dueDate,
    required this.amount,
  });

  final String purchaseId;
  final String purchaseNo;
  final LedgerDate invoiceDate;
  final LedgerDate dueDate;

  /// What the purchase put on the supplier's khata (`jama`, ref_type
  /// `purchase`): the total less what was paid at the counter.
  final Money amount;
}

/// A bill after the supplier payments were allocated to it.
@immutable
final class BillAllocation {
  const BillAllocation({
    required this.bill,
    required this.settled,
    required this.outstanding,
    required this.daysOverdue,
  });

  final SupplierBill bill;
  final Money settled;
  final Money outstanding;
  final int daysOverdue;

  bool get isOpen => outstanding.isPositive;
}

/// One supplier: the purchase bills still unpaid, as a breakdown of the
/// khata. [khataBalance] is the single net position of the party.
@immutable
final class SupplierPayable {
  const SupplierPayable({
    required this.partyId,
    required this.name,
    required this.code,
    required this.outstanding,
    required this.oldestDue,
    required this.daysOverdue,
    required this.openBills,
    required this.khataBalance,
  });

  final String partyId;
  final String name;
  final String? code;

  /// Unpaid purchase bills after FIFO allocation of the payments, never
  /// more than what we owe the supplier on the khata.
  final Money outstanding;

  /// Due date of the oldest bill that is still unpaid.
  final LedgerDate? oldestDue;

  /// Days past due of the oldest unpaid bill (0 = not overdue).
  final int daysOverdue;
  final List<BillAllocation> openBills;

  /// The party's net khata position, `udhaar - jama`: positive = they owe
  /// us, negative = we owe them. Comes from the ledger only.
  final Money khataBalance;

  bool get isOverdue => daysOverdue > 0;
}

/// One customer's shop credit, as a breakdown of the khata.
@immutable
final class CustomerReceivable {
  const CustomerReceivable({
    required this.partyId,
    required this.name,
    required this.code,
    required this.shopSales,
    required this.shopReturns,
    required this.receivable,
    required this.khataBalance,
    required this.lastSale,
  });

  final String partyId;
  final String name;
  final String? code;

  /// Sum of the `shop_sale` entries (udhaar).
  final Money shopSales;

  /// Sum of the `shop_return` entries (jama).
  final Money shopReturns;

  /// The shop portion still to collect: sales less returns, never above
  /// what the party owes us on the khata (payments they made, or farmer
  /// proceeds we owe them, already reduce it) and never negative.
  final Money receivable;

  /// Net khata position, `udhaar - jama`, from the ledger only.
  final Money khataBalance;
  final LedgerDate? lastSale;

  Money get shopNet => shopSales - shopReturns;
}

/// The khata of one party split by what created each entry. The parts add
/// up to the ledger balance; this is a view, never an addition to it.
@immutable
final class KhataBreakdown {
  const KhataBreakdown({required this.parts, required this.balance});

  /// `udhaar - jama` per `ref_type`, entries that were reversed (and their
  /// reversals) left out, they cancel.
  final Map<String, Money> parts;

  /// `udhaar - jama` over every entry of the party.
  final Money balance;

  Money get partsTotal => parts.values.fold(Money.zero, (a, m) => a + m);
}

/// Allocation of supplier payments to bills, oldest due date first.
abstract final class DuesCalc {
  /// [bills] in due-date order (then invoice date, then number) with
  /// [credits] applied from the oldest. Bills are returned in that order.
  static List<BillAllocation> allocateFifo(
    Iterable<SupplierBill> bills,
    Money credits, {
    required LedgerDate today,
  }) {
    final sorted = [...bills]
      ..sort((a, b) {
        var c = a.dueDate.compareTo(b.dueDate);
        if (c == 0) c = a.invoiceDate.compareTo(b.invoiceDate);
        return c != 0 ? c : a.purchaseNo.compareTo(b.purchaseNo);
      });
    var left = credits.isPositive ? credits : Money.zero;
    final out = <BillAllocation>[];
    for (final bill in sorted) {
      final settled = left < bill.amount ? left : bill.amount;
      left -= settled;
      final outstanding = bill.amount - settled;
      out.add(
        BillAllocation(
          bill: bill,
          settled: settled,
          outstanding: outstanding,
          daysOverdue: PurchaseRules.daysOverdue(
            bill.dueDate,
            today,
            outstanding,
          ),
        ),
      );
    }
    return out;
  }

  /// One supplier's payable from its bills, the settling [credits] and its
  /// net [khataBalance] (`udhaar - jama`). The payments are never allowed
  /// to leave more open than the khata says we owe: when the bills add up
  /// to more than that, the difference counts as paid too (it was settled
  /// by an entry this view does not follow, e.g. an opening balance).
  static SupplierPayable payable({
    required String partyId,
    required String name,
    required String? code,
    required Iterable<SupplierBill> bills,
    required Money credits,
    required Money khataBalance,
    required LedgerDate today,
  }) {
    final total = bills.fold(Money.zero, (a, b) => a + b.amount);
    final weOwe = khataBalance.isNegative ? -khataBalance : Money.zero;
    final capped = total - weOwe;
    final effective = capped > credits ? capped : credits;
    final all = allocateFifo(bills, effective, today: today);
    final open = [for (final a in all) if (a.isOpen) a];
    final outstanding = open.fold(Money.zero, (a, b) => a + b.outstanding);
    return SupplierPayable(
      partyId: partyId,
      name: name,
      code: code,
      outstanding: outstanding,
      oldestDue: open.isEmpty ? null : open.first.bill.dueDate,
      daysOverdue: open.isEmpty ? 0 : open.first.daysOverdue,
      openBills: open,
      khataBalance: khataBalance,
    );
  }

  /// The shop portion to collect: [shopNet] limited to what the party owes
  /// us on the khata ([khataBalance] positive = they owe us).
  static Money receivable(Money shopNet, Money khataBalance) {
    final owes = khataBalance.isPositive ? khataBalance : Money.zero;
    final portion = shopNet.isPositive ? shopNet : Money.zero;
    return portion < owes ? portion : owes;
  }
}
