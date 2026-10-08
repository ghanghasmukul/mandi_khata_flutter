import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/purchase_rules.dart';
import 'package:meta/meta.dart';

/// The unpaid part of one supplier invoice, as it was booked on the
/// supplier's khata (jama, `ref_type = purchase`).
@immutable
final class PayableBill {
  const PayableBill({
    required this.purchaseId,
    required this.supplierId,
    required this.invoiceDate,
    required this.dueDate,
    required this.booked,
    this.billNo,
    this.creditNote = Money.zero,
  });

  final String purchaseId;
  final String supplierId;
  final String? billNo;
  final LedgerDate invoiceDate;
  final LedgerDate dueDate;

  /// The khata jama this invoice made (total less paid now).
  final Money booked;

  /// Credit notes (purchase returns settled on the khata) against this
  /// invoice: they reduce exactly this invoice.
  final Money creditNote;
}

/// One invoice after payments were allocated.
@immutable
final class PayableBillState {
  const PayableBillState({
    required this.bill,
    required this.outstanding,
    required this.overdueDays,
  });

  final PayableBill bill;
  final Money outstanding;
  final int overdueDays;

  bool get isOpen => outstanding.isPositive;
}

/// What one supplier is owed for purchases that are not settled yet.
@immutable
final class SupplierPayableTotals {
  const SupplierPayableTotals({
    required this.supplierId,
    required this.outstanding,
    required this.bills,
    required this.dueDate,
    required this.overdueDays,
  });

  final String supplierId;

  /// Σ of the open invoices.
  final Money outstanding;

  /// Open invoices, oldest due first.
  final List<PayableBillState> bills;

  /// Earliest due date among the open invoices.
  final LedgerDate dueDate;

  /// Days the most overdue invoice is late (0 when none is).
  final int overdueDays;

  bool get isOverdue => overdueDays > 0;
}

/// Supplier payables: a **breakdown** of the supplier's single khata by
/// `ref_type`, never an amount added on top of the party balance (docs:
/// ledger-and-mandi.md "One party, many roles").
///
/// Derivation (kept deliberately simple):
///  1. Each invoice contributes its `purchase` khata jama
///     ([PayableBill.booked]).
///  2. A credit note reduces its own invoice first; a credit above what that
///     invoice has left is treated as a payment.
///  3. The supplier's payments (udhaar entries of `payment` / `voucher`
///     type, not reversed) are allocated **FIFO by due date** (then invoice
///     date) across what is left.
///  4. Whatever stays open is the invoice's outstanding amount; a payment
///     above all open invoices is simply an advance and shows nothing.
///
/// Limit: when one party is also a farmer, payments made to him settle the
/// purchases first. The party's net position is still the khata balance.
abstract final class Payables {
  static List<SupplierPayableTotals> derive({
    required Iterable<PayableBill> bills,
    required Map<String, Money> paidBySupplier,
    required LedgerDate today,
  }) {
    final bySupplier = <String, List<PayableBill>>{};
    for (final b in bills) {
      bySupplier.putIfAbsent(b.supplierId, () => []).add(b);
    }
    final out = <SupplierPayableTotals>[];
    for (final MapEntry(key: supplier, value: list) in bySupplier.entries) {
      list.sort((a, b) {
        final byDue = a.dueDate.compareTo(b.dueDate);
        if (byDue != 0) return byDue;
        final byDate = a.invoiceDate.compareTo(b.invoiceDate);
        return byDate != 0 ? byDate : a.purchaseId.compareTo(b.purchaseId);
      });
      var pool = paidBySupplier[supplier] ?? Money.zero;
      final left = <Money>[];
      for (final b in list) {
        final net = b.booked - b.creditNote;
        if (net.isNegative) {
          pool += -net;
          left.add(Money.zero);
        } else {
          left.add(net);
        }
      }
      final open = <PayableBillState>[];
      var total = Money.zero;
      var worst = 0;
      for (var i = 0; i < list.length; i++) {
        var rest = left[i];
        if (pool.isPositive && rest.isPositive) {
          final take = pool < rest ? pool : rest;
          pool -= take;
          rest -= take;
        }
        if (!rest.isPositive) continue;
        final days = PurchaseRules.daysOverdue(list[i].dueDate, today, rest);
        if (days > worst) worst = days;
        total += rest;
        open.add(
          PayableBillState(bill: list[i], outstanding: rest, overdueDays: days),
        );
      }
      if (open.isEmpty) continue;
      out.add(
        SupplierPayableTotals(
          supplierId: supplier,
          outstanding: total,
          bills: open,
          dueDate: open.first.bill.dueDate,
          overdueDays: worst,
        ),
      );
    }
    out.sort((a, b) {
      final byDue = a.dueDate.compareTo(b.dueDate);
      return byDue != 0 ? byDue : a.supplierId.compareTo(b.supplierId);
    });
    return out;
  }
}
