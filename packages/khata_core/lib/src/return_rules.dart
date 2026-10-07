import 'package:khata_core/src/gst.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/sale_calc.dart';
import 'package:khata_core/src/shop_math.dart';
import 'package:meta/meta.dart';

/// Why a return line is refused.
enum ReturnIssue {
  lineNotFound,
  nonPositiveQty,

  /// More than was sold (or bought) less what was already returned.
  exceedsReturnable,

  /// A purchase return of stock that has since been sold.
  exceedsBatchStock,

  /// Credit to the khata chosen but there is no party.
  noParty,
}

@immutable
final class ReturnLineIssue {
  const ReturnLineIssue(this.index, this.issue);

  /// Index of the line in the document's line list.
  final int index;
  final ReturnIssue issue;

  @override
  bool operator ==(Object other) =>
      other is ReturnLineIssue && other.index == index && other.issue == issue;

  @override
  int get hashCode => Object.hash(index, issue);

  @override
  String toString() => 'line $index: ${issue.name}';
}

/// What the user chose for the money of a return.
enum RefundChoice {
  /// Credit the khata up to what is still unpaid on the bill, refund the
  /// rest.
  auto,

  /// Credit the party's khata with everything.
  khata,

  /// Refund everything in cash / bank.
  cash,
}

/// How the money of a return is settled.
@immutable
final class ReturnSettlement {
  const ReturnSettlement({
    required this.khata,
    required this.cash,
    required this.errors,
  });

  /// [refund] is the whole amount; [unpaidOnBill] what is still unpaid on
  /// the original bill (the udhaar of a sale, the unpaid part of a
  /// purchase).
  factory ReturnSettlement.split({
    required Money refund,
    required RefundChoice choice,
    required bool hasParty,
    Money unpaidOnBill = Money.zero,
  }) {
    switch (choice) {
      case RefundChoice.cash:
        return ReturnSettlement(
          khata: Money.zero,
          cash: refund,
          errors: const [],
        );
      case RefundChoice.khata:
        return ReturnSettlement(
          khata: refund,
          cash: Money.zero,
          errors: hasParty ? const [] : const [ReturnIssue.noParty],
        );
      case RefundChoice.auto:
        final credit = !hasParty || unpaidOnBill.isNegative
            ? Money.zero
            : (unpaidOnBill < refund ? unpaidOnBill : refund);
        return ReturnSettlement(
          khata: credit,
          cash: refund - credit,
          errors: const [],
        );
    }
  }

  /// Goes to the party's khata (`shop_return` jama, or `purchase_return`
  /// udhaar for a purchase).
  final Money khata;

  /// Paid out (sale) or received (purchase) in cash / bank.
  final Money cash;
  final List<ReturnIssue> errors;

  bool get ok => errors.isEmpty;
}

/// A request to take back part of a sold line.
@immutable
final class ReturnRequest {
  const ReturnRequest(this.lineIndex, this.qtyMilli);

  final int lineIndex;
  final int qtyMilli;
}

/// One line of a worked-out sales return.
@immutable
final class ReturnLineResult {
  const ReturnLineResult({
    required this.lineIndex,
    required this.line,
    required this.qtyMilli,
    required this.split,
    required this.cost,
  });

  final int lineIndex;
  final SoldLine line;
  final int qtyMilli;

  /// Taxable and tax given back for this part.
  final GstSplit split;

  /// Cost of goods to take back into stock (reverses COGS).
  final Money cost;
}

/// A sales return worked out.
@immutable
final class SalesReturnResult {
  const SalesReturnResult({
    required this.lines,
    required this.split,
    required this.cost,
    required this.roundOff,
    required this.completesInvoice,
  });

  final List<ReturnLineResult> lines;
  final GstSplit split;
  final Money cost;

  /// The invoice's round-off, given back with the last return.
  final Money roundOff;
  final bool completesInvoice;

  /// What the customer gets back.
  Money get refund => split.total + roundOff;
}

abstract final class SalesReturns {
  /// Problems with [requests] against the sold lines (empty = fine): a line
  /// that does not exist, a quantity not above zero, or above what is left
  /// to return. The same line may appear once.
  static List<ReturnLineIssue> validate(
    List<SoldLine> sold,
    List<ReturnRequest> requests,
  ) {
    final issues = <ReturnLineIssue>[];
    final seen = <int>{};
    for (final r in requests) {
      if (r.lineIndex < 0 || r.lineIndex >= sold.length) {
        issues.add(ReturnLineIssue(r.lineIndex, ReturnIssue.lineNotFound));
      } else if (r.qtyMilli <= 0) {
        issues.add(ReturnLineIssue(r.lineIndex, ReturnIssue.nonPositiveQty));
      } else if (r.qtyMilli > sold[r.lineIndex].returnableMilli ||
          !seen.add(r.lineIndex)) {
        issues.add(ReturnLineIssue(r.lineIndex, ReturnIssue.exceedsReturnable));
      }
    }
    return issues;
  }

  /// Refund, tax and cost for taking back [requests]; proportional to each
  /// line, the return that completes a line takes exactly what is left of
  /// it. [invoiceRoundOff] / [roundOffReturned] are the invoice's round-off
  /// and the part already refunded; the rest is refunded when this return
  /// completes the whole invoice. Throws [ArgumentError] when [validate]
  /// finds a problem.
  static SalesReturnResult compute(
    List<SoldLine> sold,
    List<ReturnRequest> requests, {
    Money invoiceRoundOff = Money.zero,
    Money roundOffReturned = Money.zero,
  }) {
    final issues = validate(sold, requests);
    if (issues.isNotEmpty || requests.isEmpty) {
      throw ArgumentError('Invalid return: $issues');
    }
    final taken = {for (final r in requests) r.lineIndex: r.qtyMilli};
    final lines = <ReturnLineResult>[];
    var total = GstSplit.zero;
    var cost = Money.zero;
    for (final r in requests) {
      final l = sold[r.lineIndex];
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
      final lineCost = Money(part(l.cost.paise, l.returnedCost.paise));
      lines.add(
        ReturnLineResult(
          lineIndex: r.lineIndex,
          line: l,
          qtyMilli: r.qtyMilli,
          split: split,
          cost: lineCost,
        ),
      );
      total += split;
      cost += lineCost;
    }
    final completes = [
      for (var i = 0; i < sold.length; i++)
        sold[i].returnableMilli - (taken[i] ?? 0) == 0,
    ].every((done) => done);
    return SalesReturnResult(
      lines: lines,
      split: total,
      cost: cost,
      roundOff: completes ? invoiceRoundOff - roundOffReturned : Money.zero,
      completesInvoice: completes,
    );
  }
}
