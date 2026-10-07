import 'package:khata_core/src/gst.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/return_rules.dart';
import 'package:khata_core/src/shop_math.dart';
import 'package:meta/meta.dart';

/// One line of a supplier invoice. [unitCost] is per whole unit, before tax
/// unless the [GstMode] says prices include it.
@immutable
final class PurchaseLine {
  const PurchaseLine({
    required this.productId,
    required this.batchNo,
    required this.qtyMilli,
    required this.unitCost,
    this.lineDiscount = Money.zero,
    this.rateBp,
    this.hsn,
    this.mfgDate,
    this.expiry,
  });

  final String productId;
  final String batchNo;
  final int qtyMilli;
  final Money unitCost;
  final Money lineDiscount;
  final int? rateBp;
  final String? hsn;
  final LedgerDate? mfgDate;
  final LedgerDate? expiry;

  Money get gross => ShopMath.valueOf(unitCost, qtyMilli);
}

/// A purchase line worked out.
@immutable
final class PurchaseLineResult {
  const PurchaseLineResult({
    required this.line,
    required this.net,
    required this.split,
    required this.chargeShare,
  });

  final PurchaseLine line;

  /// Gross less discount: the amount that is taxed.
  final Money net;
  final GstSplit split;

  /// Freight and other charges that fell on this line.
  final Money chargeShare;

  /// What goes into stock: taxable + share of the charges.
  Money get landed => split.taxable + chargeShare;

  /// Batch cost per whole unit: `landed × 1000 / qty`, half-up.
  Money get landedUnitCost =>
      Money(ShopMath.mulDivRound(landed.paise, 1000, line.qtyMilli));

  /// Supplier's tax plus the line (without charges).
  Money get total => split.total;
}

/// A supplier invoice worked out.
@immutable
final class PurchaseTotals {
  const PurchaseTotals({
    required this.lines,
    required this.gst,
    required this.gstIssues,
    required this.freight,
    required this.otherCharges,
    required this.roundOff,
  });

  final List<PurchaseLineResult> lines;
  final GstSplit gst;
  final Map<int, List<GstIssue>> gstIssues;
  final Money freight;
  final Money otherCharges;

  /// Signed paise to reach the supplier's printed total.
  final Money roundOff;

  Money get charges => freight + otherCharges;

  /// The debit to Stock-in-Hand: taxable + freight + other charges.
  Money get stockValue => gst.taxable + charges;

  /// What the supplier is owed for the invoice.
  Money get total => gst.total + charges + roundOff;
}

/// How much of a purchase is paid now.
@immutable
final class PurchaseSettlement {
  const PurchaseSettlement({
    required this.paid,
    required this.unpaid,
    required this.errors,
  });

  final Money paid;
  final Money unpaid;
  final List<PurchaseIssue> errors;

  bool get ok => errors.isEmpty;
}

enum PurchaseIssue { noLines, negativePaid, paidAboveTotal, noSupplier }

/// A purchase line as saved, for returns (one per batch).
@immutable
final class PurchasedLine {
  const PurchasedLine({
    required this.batchId,
    required this.qtyMilli,
    required this.split,
    required this.landed,
    required this.batchRemainingMilli,
    this.returnedMilli = 0,
    this.returned = GstSplit.zero,
    this.returnedLanded = Money.zero,
  });

  final String batchId;
  final int qtyMilli;
  final GstSplit split;

  /// Stock value booked for the line.
  final Money landed;

  /// What is still in the batch (not sold).
  final int batchRemainingMilli;
  final int returnedMilli;
  final GstSplit returned;
  final Money returnedLanded;

  int get returnableMilli => qtyMilli - returnedMilli;
}

/// One line of a purchase return worked out.
@immutable
final class PurchaseReturnLineResult {
  const PurchaseReturnLineResult({
    required this.lineIndex,
    required this.line,
    required this.qtyMilli,
    required this.split,
    required this.stockValue,
  });

  final int lineIndex;
  final PurchasedLine line;
  final int qtyMilli;
  final GstSplit split;

  /// Credit to Stock-in-Hand for this part.
  final Money stockValue;
}

@immutable
final class PurchaseReturnResult {
  const PurchaseReturnResult({
    required this.lines,
    required this.split,
    required this.stockValue,
  });

  final List<PurchaseReturnLineResult> lines;
  final GstSplit split;
  final Money stockValue;

  /// What the supplier gives back: stock value plus input tax.
  Money get refund => stockValue + split.tax;
}

abstract final class PurchaseRules {
  /// Works out a supplier invoice. Charges are spread over the lines by
  /// taxable value (largest remainder). Throws [ArgumentError] for no lines,
  /// a quantity that is not positive, a negative cost or discount, or a
  /// discount above its line.
  static PurchaseTotals compute({
    required List<PurchaseLine> lines,
    GstMode mode = const GstMode(pricesIncludeGst: false),
    Money freight = Money.zero,
    Money otherCharges = Money.zero,
    Money roundOff = Money.zero,
  }) {
    if (lines.isEmpty) throw ArgumentError('A purchase needs a line');
    if (freight.isNegative || otherCharges.isNegative) {
      throw ArgumentError('Charges must not be negative');
    }
    final nets = <Money>[];
    for (final l in lines) {
      if (l.qtyMilli <= 0 || l.unitCost.isNegative) {
        throw ArgumentError.value(l.productId, 'line', 'qty or cost invalid');
      }
      if (l.lineDiscount.isNegative || l.lineDiscount > l.gross) {
        throw ArgumentError.value(l.lineDiscount, 'lineDiscount', 'invalid');
      }
      nets.add(l.gross - l.lineDiscount);
    }
    final tax = GstInvoice.compute([
      for (var i = 0; i < lines.length; i++)
        GstLineInput(
          amount: nets[i],
          rateBp: lines[i].rateBp,
          hsn: lines[i].hsn,
        ),
    ], mode);
    final charges = freight + otherCharges;
    final weights = [for (final s in tax.lines) s.taxable.paise];
    final shares = charges.isZero
        ? List.filled(lines.length, 0)
        : ShopMath.apportion(
            charges.paise,
            weights.fold<int>(0, (a, w) => a + w) > 0
                ? weights
                : [for (final l in lines) l.qtyMilli],
          );
    return PurchaseTotals(
      lines: [
        for (var i = 0; i < lines.length; i++)
          PurchaseLineResult(
            line: lines[i],
            net: nets[i],
            split: tax.lines[i],
            chargeShare: Money(shares[i]),
          ),
      ],
      gst: tax.total,
      gstIssues: tax.issues,
      freight: freight,
      otherCharges: otherCharges,
      roundOff: roundOff,
    );
  }

  /// Paid now vs on the supplier's khata. A supplier is always needed when
  /// something is unpaid.
  static PurchaseSettlement settle({
    required Money total,
    required Money paidNow,
    String? supplierId,
  }) {
    final unpaid = total - paidNow;
    return PurchaseSettlement(
      paid: paidNow,
      unpaid: unpaid,
      errors: [
        if (!total.isPositive) PurchaseIssue.noLines,
        if (paidNow.isNegative) PurchaseIssue.negativePaid,
        if (unpaid.isNegative) PurchaseIssue.paidAboveTotal,
        if (unpaid.isPositive && (supplierId == null || supplierId.isEmpty))
          PurchaseIssue.noSupplier,
      ],
    );
  }

  /// Invoice date + the supplier's credit days (`shop.supplier_credit_days`).
  static LedgerDate dueDate(LedgerDate invoiceDate, int creditDays) =>
      invoiceDate.addDays(creditDays < 0 ? 0 : creditDays);

  /// Days past [due] (0 when not due yet or nothing is unpaid).
  static int daysOverdue(LedgerDate due, LedgerDate today, Money unpaid) =>
      unpaid.isPositive && today > due ? due.daysUntil(today) : 0;

  static bool isOverdue(LedgerDate due, LedgerDate today, Money unpaid) =>
      daysOverdue(due, today, unpaid) > 0;

  /// Problems with returning [requests] to the original batches: unknown
  /// line, quantity not above zero, above what is left to return, or above
  /// what is still in the batch (it has been sold).
  static List<ReturnLineIssue> validateReturn(
    List<PurchasedLine> bought,
    List<ReturnRequest> requests,
  ) {
    final issues = <ReturnLineIssue>[];
    final seen = <int>{};
    for (final r in requests) {
      if (r.lineIndex < 0 || r.lineIndex >= bought.length) {
        issues.add(ReturnLineIssue(r.lineIndex, ReturnIssue.lineNotFound));
        continue;
      }
      final l = bought[r.lineIndex];
      if (r.qtyMilli <= 0) {
        issues.add(ReturnLineIssue(r.lineIndex, ReturnIssue.nonPositiveQty));
      } else if (r.qtyMilli > l.returnableMilli || !seen.add(r.lineIndex)) {
        issues.add(ReturnLineIssue(r.lineIndex, ReturnIssue.exceedsReturnable));
      } else if (r.qtyMilli > l.batchRemainingMilli) {
        issues.add(ReturnLineIssue(r.lineIndex, ReturnIssue.exceedsBatchStock));
      }
    }
    return issues;
  }

  /// Stock value and input tax to give back, proportional per line; the
  /// return that completes a line takes exactly what is left. Throws
  /// [ArgumentError] when [validateReturn] finds a problem.
  static PurchaseReturnResult computeReturn(
    List<PurchasedLine> bought,
    List<ReturnRequest> requests,
  ) {
    final issues = validateReturn(bought, requests);
    if (issues.isNotEmpty || requests.isEmpty) {
      throw ArgumentError('Invalid return: $issues');
    }
    final lines = <PurchaseReturnLineResult>[];
    var total = GstSplit.zero;
    var value = Money.zero;
    for (final r in requests) {
      final l = bought[r.lineIndex];
      int part(int whole, int done) => ShopMath.proportional(
        total: whole,
        partMilli: r.qtyMilli,
        wholeMilli: l.qtyMilli,
        doneMilli: l.returnedMilli,
        doneAmount: done,
      );
      final split = GstSplit(
        taxable: Money(part(l.split.taxable.paise, l.returned.taxable.paise)),
        cgst: Money(part(l.split.cgst.paise, l.returned.cgst.paise)),
        sgst: Money(part(l.split.sgst.paise, l.returned.sgst.paise)),
        igst: Money(part(l.split.igst.paise, l.returned.igst.paise)),
      );
      final stock = Money(part(l.landed.paise, l.returnedLanded.paise));
      lines.add(
        PurchaseReturnLineResult(
          lineIndex: r.lineIndex,
          line: l,
          qtyMilli: r.qtyMilli,
          split: split,
          stockValue: stock,
        ),
      );
      total += split;
      value += stock;
    }
    return PurchaseReturnResult(lines: lines, split: total, stockValue: value);
  }
}
