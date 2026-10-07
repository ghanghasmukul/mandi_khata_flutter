import 'package:khata_core/src/credit_limit.dart';
import 'package:khata_core/src/gst.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/shop_math.dart';
import 'package:khata_core/src/stock_rules.dart';
import 'package:meta/meta.dart';

/// One line of the cart. [unitPrice] is per whole unit, tax-inclusive or
/// not as `shop.prices_include_gst` says.
@immutable
final class CartLine {
  const CartLine({
    required this.productId,
    required this.qtyMilli,
    required this.unitPrice,
    this.name = '',
    this.lineDiscount = Money.zero,
    this.rateBp,
    this.hsn,
  });

  final String productId;
  final String name;
  final int qtyMilli;
  final Money unitPrice;

  /// Absolute amount off this line.
  final Money lineDiscount;

  /// GST rate in basis points; null = not set (taxed at 0, flagged).
  final int? rateBp;
  final String? hsn;

  /// `unitPrice × qty`, half-up.
  Money get gross => ShopMath.valueOf(unitPrice, qtyMilli);
}

/// A bill-level discount: a percentage or a fixed amount.
@immutable
final class InvoiceDiscount {
  const InvoiceDiscount.none() : percentBp = null, amount = null;

  /// [basisPoints] of the lines' value after line discounts (1000 = 10%).
  const InvoiceDiscount.percent(int basisPoints)
    : percentBp = basisPoints,
      amount = null;

  const InvoiceDiscount.amount(Money this.amount) : percentBp = null;

  final int? percentBp;
  final Money? amount;
}

/// A sold line split by the batch it came from; the unit of a sales return.
@immutable
final class SoldLine {
  const SoldLine({
    required this.productId,
    required this.batchId,
    required this.qtyMilli,
    required this.unitCost,
    required this.split,
    this.rateBp,
    this.hsn,
    this.returnedMilli = 0,
    this.returned = GstSplit.zero,
    this.returnedCost = Money.zero,
  });

  final String productId;

  /// Null for a negative-stock sale no batch covered.
  final String? batchId;
  final int qtyMilli;
  final Money unitCost;
  final int? rateBp;
  final String? hsn;

  /// Taxable and tax of this part of the line.
  final GstSplit split;

  /// Already taken back by earlier returns.
  final int returnedMilli;
  final GstSplit returned;

  /// Cost of goods already taken back.
  final Money returnedCost;

  /// Cost of goods sold for this part: `unitCost × qty`.
  Money get cost => ShopMath.valueOf(unitCost, qtyMilli);

  /// Taxable + tax (what the customer paid for it, before round-off).
  Money get total => split.total;

  int get returnableMilli => qtyMilli - returnedMilli;
}

/// A cart line worked out.
@immutable
final class SaleLineResult {
  const SaleLineResult({
    required this.line,
    required this.gross,
    required this.invoiceDiscountShare,
    required this.net,
    required this.split,
  });

  final CartLine line;
  final Money gross;

  /// Part of the bill discount that fell on this line.
  final Money invoiceDiscountShare;

  /// Gross less line and bill discount: the amount that is taxed.
  final Money net;
  final GstSplit split;

  /// What the customer pays for the line (tax included).
  Money get total => split.total;

  /// Splits the line over the batches FEFO picked, by quantity, with the
  /// amounts adding up exactly. A shortfall (negative stock) becomes one
  /// part without a batch at zero cost.
  List<SoldLine> allocate(List<BatchAllocation> allocations) {
    final parts = <(String?, int, Money)>[
      for (final a in allocations) (a.batchId, a.qtyMilli, a.unitCost),
    ];
    final covered = parts.fold<int>(0, (s, p) => s + p.$2);
    if (covered < line.qtyMilli) {
      parts.add((null, line.qtyMilli - covered, Money.zero));
    }
    final weights = [for (final p in parts) p.$2];
    List<int> share(Money m) => ShopMath.apportion(m.paise, weights);
    final taxable = share(split.taxable);
    final cgst = share(split.cgst);
    final sgst = share(split.sgst);
    final igst = share(split.igst);
    return [
      for (var i = 0; i < parts.length; i++)
        SoldLine(
          productId: line.productId,
          batchId: parts[i].$1,
          qtyMilli: parts[i].$2,
          unitCost: parts[i].$3,
          rateBp: line.rateBp,
          hsn: line.hsn,
          split: GstSplit(
            taxable: Money(taxable[i]),
            cgst: Money(cgst[i]),
            sgst: Money(sgst[i]),
            igst: Money(igst[i]),
          ),
        ),
    ];
  }
}

/// A bill worked out.
@immutable
final class SaleTotals {
  const SaleTotals({
    required this.lines,
    required this.subtotal,
    required this.lineDiscounts,
    required this.invoiceDiscount,
    required this.gst,
    required this.gstIssues,
    required this.beforeRoundOff,
    required this.roundOff,
  });

  final List<SaleLineResult> lines;

  /// Σ unit price × qty.
  final Money subtotal;
  final Money lineDiscounts;

  /// The whole bill discount.
  final Money invoiceDiscount;

  /// Taxable and tax of the bill.
  final GstSplit gst;

  /// Missing or invalid HSN / rate by line index.
  final Map<int, List<GstIssue>> gstIssues;

  /// Taxable + tax.
  final Money beforeRoundOff;

  /// Signed paise added to reach the whole rupee (0 when not rounding).
  final Money roundOff;

  /// What the customer pays.
  Money get total => beforeRoundOff + roundOff;

  Money get totalDiscount => lineDiscounts + invoiceDiscount;
}

/// How a bill is paid.
@immutable
final class PaymentSplit {
  const PaymentSplit({
    this.cash = Money.zero,
    this.upi = Money.zero,
    this.udhaar = Money.zero,
  });

  /// Everything in cash.
  const PaymentSplit.allCash(Money total)
    : cash = total,
      upi = Money.zero,
      udhaar = Money.zero;

  final Money cash;
  final Money upi;

  /// Goes to the party's khata.
  final Money udhaar;

  Money get sum => cash + upi + udhaar;

  /// Money paid at the counter (not on credit).
  Money get paidNow => cash + upi;

  /// What is left of [total] after cash and UPI: the udhaar to propose.
  Money remainingAfterPaid(Money total) => total - paidNow;
}

enum PaymentIssue { negativeAmount, mismatch, udhaarNeedsParty, zeroTotal }

/// Result of [PaymentChecks.validate].
@immutable
final class PaymentCheck {
  const PaymentCheck({required this.errors, this.overCreditLimit});

  final List<PaymentIssue> errors;

  /// How far past the party's limit the udhaar takes them (a warning).
  final Money? overCreditLimit;

  bool get ok => errors.isEmpty;
}

abstract final class PaymentChecks {
  /// cash + UPI + udhaar must equal [total]; udhaar needs a party. The
  /// credit limit never blocks: [PaymentCheck.overCreditLimit] only warns.
  /// [partyBalance] is the khata balance (Σ jama - Σ udhaar).
  static PaymentCheck validate({
    required Money total,
    required PaymentSplit payment,
    String? partyId,
    Money partyBalance = Money.zero,
    int creditLimitPaise = 0,
  }) {
    final errors = <PaymentIssue>[
      if (!total.isPositive) PaymentIssue.zeroTotal,
      if (payment.cash.isNegative ||
          payment.upi.isNegative ||
          payment.udhaar.isNegative)
        PaymentIssue.negativeAmount,
      if (payment.sum != total) PaymentIssue.mismatch,
      if (payment.udhaar.isPositive && (partyId == null || partyId.isEmpty))
        PaymentIssue.udhaarNeedsParty,
    ];
    final over = payment.udhaar.isPositive
        ? CreditLimit.excess(partyBalance - payment.udhaar, creditLimitPaise)
        : null;
    return PaymentCheck(errors: errors, overCreditLimit: over);
  }
}

/// Works out a bill (docs/domain/shop-rules.md sections 3 and 4).
abstract final class SaleCalculator {
  /// Throws [ArgumentError] for an empty cart, a quantity or price that is
  /// not positive / negative, a discount above its base, or a percentage
  /// above 100.
  static SaleTotals compute({
    required List<CartLine> lines,
    GstMode mode = const GstMode(),
    InvoiceDiscount discount = const InvoiceDiscount.none(),
    bool roundToRupee = true,
  }) {
    if (lines.isEmpty) throw ArgumentError('A bill needs at least one line');
    final afterLine = <Money>[];
    for (final l in lines) {
      if (l.qtyMilli <= 0) {
        throw ArgumentError.value(l.qtyMilli, 'qtyMilli', 'must be positive');
      }
      if (l.unitPrice.isNegative) {
        throw ArgumentError.value(l.unitPrice, 'unitPrice', 'is negative');
      }
      if (l.lineDiscount.isNegative || l.lineDiscount > l.gross) {
        throw ArgumentError.value(l.lineDiscount, 'lineDiscount', 'invalid');
      }
      afterLine.add(l.gross - l.lineDiscount);
    }
    final base = afterLine.fold(Money.zero, (a, m) => a + m);
    final bp = discount.percentBp;
    final d = bp != null
        ? (bp < 0 || bp > 10000
              ? throw ArgumentError.value(bp, 'percent', 'out of range')
              : Money(ShopMath.mulDivRound(base.paise, bp, 10000)))
        : discount.amount ?? Money.zero;
    if (d.isNegative || d > base) {
      throw ArgumentError.value(d, 'invoiceDiscount', 'invalid');
    }
    final shares = d.isZero || base.isZero
        ? List.filled(lines.length, 0)
        : ShopMath.apportion(d.paise, [for (final m in afterLine) m.paise]);

    final nets = [
      for (var i = 0; i < lines.length; i++) afterLine[i] - Money(shares[i]),
    ];
    final tax = GstInvoice.compute([
      for (var i = 0; i < lines.length; i++)
        GstLineInput(
          amount: nets[i],
          rateBp: lines[i].rateBp,
          hsn: lines[i].hsn,
        ),
    ], mode);

    final results = [
      for (var i = 0; i < lines.length; i++)
        SaleLineResult(
          line: lines[i],
          gross: lines[i].gross,
          invoiceDiscountShare: Money(shares[i]),
          net: nets[i],
          split: tax.lines[i],
        ),
    ];
    final totalTax = tax.total;
    final before = totalTax.total;
    final rounded = roundToRupee
        ? Money(ShopMath.mulDivRound(before.paise, 1, 100) * 100)
        : before;
    return SaleTotals(
      lines: results,
      subtotal: lines.fold(Money.zero, (a, l) => a + l.gross),
      lineDiscounts: lines.fold(Money.zero, (a, l) => a + l.lineDiscount),
      invoiceDiscount: d,
      gst: totalTax,
      gstIssues: tax.issues,
      beforeRoundOff: before,
      roundOff: rounded - before,
    );
  }
}
