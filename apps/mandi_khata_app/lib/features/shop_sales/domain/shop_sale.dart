import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

enum SaleStatus {
  posted,
  reversed;

  static SaleStatus parse(String? v) =>
      v == 'reversed' ? SaleStatus.reversed : SaleStatus.posted;
}

/// One row of `shop_sale_lines`: a cart line is one row per batch it was
/// served from. [unitCost] is the batch cost snapshot (COGS).
@immutable
class SaleLineRecord {
  const SaleLineRecord({
    required this.id,
    required this.lineNo,
    required this.productId,
    required this.productName,
    required this.qtyMilli,
    required this.unitPrice,
    required this.discount,
    required this.split,
    required this.unitCost,
    this.unit,
    this.batchId,
    this.batchNo,
    this.expiry,
    this.tier,
    this.rateBp,
    this.hsn,
    this.returnedMilli = 0,
    this.returned = GstSplit.zero,
    this.returnedCost = Money.zero,
  });

  final String id;
  final int lineNo;
  final String productId;
  final String productName;

  /// `bag`, `ltr`... of the product.
  final String? unit;

  /// Null for the part of a negative-stock sale no batch covered.
  final String? batchId;
  final String? batchNo;
  final LedgerDate? expiry;
  final int qtyMilli;

  /// Price per whole unit before discounts, from the tier.
  final Money unitPrice;
  final String? tier;

  /// Line and invoice discount that fell on this part.
  final Money discount;

  /// Taxable and tax of this part.
  final GstSplit split;
  final int? rateBp;
  final String? hsn;

  /// Batch cost per whole unit at the time of sale.
  final Money unitCost;

  /// Already taken back by posted returns.
  final int returnedMilli;
  final GstSplit returned;
  final Money returnedCost;

  /// What the customer paid for the part (tax included, before round-off).
  Money get total => split.total;

  /// Cost of goods sold for the part.
  Money get cost => ShopMath.valueOf(unitCost, qtyMilli);

  int get returnableMilli => qtyMilli - returnedMilli;

  SoldLine toSoldLine() => SoldLine(
    productId: productId,
    batchId: batchId,
    qtyMilli: qtyMilli,
    unitCost: unitCost,
    split: split,
    rateBp: rateBp,
    hsn: hsn,
    returnedMilli: returnedMilli,
    returned: returned,
    returnedCost: returnedCost,
  );
}

/// A bill as stored (`shop_sales`) with the names the screens show.
@immutable
class SaleRecord {
  const SaleRecord({
    required this.id,
    required this.saleNo,
    required this.entryDate,
    required this.subtotal,
    required this.lineDiscounts,
    required this.invoiceDiscount,
    required this.invoiceDiscountPct,
    required this.gst,
    required this.roundOff,
    required this.total,
    required this.paidCash,
    required this.paidUpi,
    required this.paidCredit,
    required this.status,
    required this.createdAt,
    this.partyId,
    this.partyName,
    this.partyCode,
    this.customerName,
    this.customerGstin,
    this.placeOfSupply,
    this.tier,
    this.upiAccountId,
    this.notes,
    this.itemCount = 0,
  });

  final String id;
  final String saleNo;
  final LedgerDate entryDate;
  final String? partyId;
  final String? partyName;
  final String? partyCode;

  /// Name typed for a walk-in, or the party's name at the time of sale.
  final String? customerName;
  final String? customerGstin;
  final String? placeOfSupply;
  final String? tier;

  /// Σ unit price × qty, before discounts.
  final Money subtotal;
  final Money lineDiscounts;
  final Money invoiceDiscount;

  /// The bill discount as a percent (0 when a fixed amount or none).
  final double invoiceDiscountPct;

  /// Taxable and tax of the whole bill.
  final GstSplit gst;
  final Money roundOff;
  final Money total;
  final Money paidCash;
  final Money paidUpi;

  /// The udhaar part, posted to the party's khata.
  final Money paidCredit;
  final String? upiAccountId;
  final String? notes;
  final SaleStatus status;
  final DateTime createdAt;

  /// Number of line rows (cart lines split by batch count more than once).
  final int itemCount;

  bool get isReversed => status == SaleStatus.reversed;
  bool get isWalkIn => partyId == null;

  Money get paidNow => paidCash + paidUpi;

  /// The name to print: the party's, else the walk-in's, else null.
  String? get displayName => partyName ?? customerName;
}

/// A posted sales return as stored.
@immutable
class SaleReturnRecord {
  const SaleReturnRecord({
    required this.id,
    required this.returnNo,
    required this.saleId,
    required this.entryDate,
    required this.total,
    required this.refundKhata,
    required this.refundCash,
    required this.refundUpi,
    required this.mode,
    required this.status,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String returnNo;
  final String saleId;
  final LedgerDate entryDate;
  final Money total;
  final Money refundKhata;
  final Money refundCash;
  final Money refundUpi;
  final String mode;
  final SaleStatus status;
  final DateTime createdAt;
  final String? note;
}

/// A bill with everything behind it.
@immutable
class SaleDetail {
  const SaleDetail({
    required this.sale,
    required this.lines,
    this.returns = const [],
    this.partyVillage,
  });

  final SaleRecord sale;
  final List<SaleLineRecord> lines;
  final List<SaleReturnRecord> returns;
  final String? partyVillage;

  List<SaleReturnRecord> get postedReturns => [
    for (final r in returns)
      if (r.status == SaleStatus.posted) r,
  ];

  /// Udhaar of the bill not yet given back as khata credit by returns.
  Money get unpaidOnBill {
    var left = sale.paidCredit;
    for (final r in postedReturns) {
      left -= r.refundKhata;
    }
    return left.isNegative ? Money.zero : left;
  }

  bool get canReturn =>
      sale.status == SaleStatus.posted &&
      lines.any((l) => l.returnableMilli > 0);

  /// Σ cost of goods sold, net of what came back.
  Money get costOfGoods => lines.fold(
    Money.zero,
    (a, l) => a + l.cost - l.returnedCost,
  );
}

/// What the sales list filters on.
@immutable
class SaleFilter {
  const SaleFilter({
    this.from,
    this.to,
    this.partyId,
    this.query = '',
    this.payment,
    this.tier,
    this.includeReversed = true,
  });

  final LedgerDate? from;
  final LedgerDate? to;
  final String? partyId;
  final String query;

  /// Only bills with a part paid this way.
  final SalePaymentKind? payment;
  final String? tier;
  final bool includeReversed;

  SaleFilter copyWith({
    LedgerDate? from,
    LedgerDate? to,
    String? partyId,
    String? query,
    SalePaymentKind? payment,
    String? tier,
    bool? includeReversed,
    bool clearDates = false,
    bool clearParty = false,
    bool clearPayment = false,
    bool clearTier = false,
  }) => SaleFilter(
    from: clearDates ? null : from ?? this.from,
    to: clearDates ? null : to ?? this.to,
    partyId: clearParty ? null : partyId ?? this.partyId,
    query: query ?? this.query,
    payment: clearPayment ? null : payment ?? this.payment,
    tier: clearTier ? null : tier ?? this.tier,
    includeReversed: includeReversed ?? this.includeReversed,
  );

  @override
  bool operator ==(Object other) =>
      other is SaleFilter &&
      other.from == from &&
      other.to == to &&
      other.partyId == partyId &&
      other.query == query &&
      other.payment == payment &&
      other.tier == tier &&
      other.includeReversed == includeReversed;

  @override
  int get hashCode =>
      Object.hash(from, to, partyId, query, payment, tier, includeReversed);
}

enum SalePaymentKind { cash, upi, udhaar }

/// Totals of the bills on screen (reversed bills are left out).
@immutable
class SalesSummary {
  const SalesSummary({
    required this.count,
    required this.total,
    required this.cash,
    required this.upi,
    required this.udhaar,
  });

  factory SalesSummary.of(Iterable<SaleRecord> sales) {
    var count = 0;
    var total = Money.zero;
    var cash = Money.zero;
    var upi = Money.zero;
    var udhaar = Money.zero;
    for (final s in sales) {
      if (s.isReversed) continue;
      count++;
      total += s.total;
      cash += s.paidCash;
      upi += s.paidUpi;
      udhaar += s.paidCredit;
    }
    return SalesSummary(
      count: count,
      total: total,
      cash: cash,
      upi: upi,
      udhaar: udhaar,
    );
  }

  final int count;
  final Money total;
  final Money cash;
  final Money upi;
  final Money udhaar;
}

/// One line the cashier wants to sell. The price is per whole unit (a manual
/// price is allowed); the batches are picked FEFO when it is saved.
@immutable
class SaleDraftLine {
  const SaleDraftLine({
    required this.productId,
    required this.qtyMilli,
    required this.unitPrice,
    this.lineDiscount = Money.zero,
  });

  final String productId;
  final int qtyMilli;
  final Money unitPrice;
  final Money lineDiscount;
}

/// Everything the cashier decided about a bill.
@immutable
class SaleDraft {
  const SaleDraft({
    required this.lines,
    required this.payment,
    this.entryDate,
    this.partyId,
    this.customerName,
    this.tier,
    this.discount = const InvoiceDiscount.none(),
    this.upiAccountId,
    this.notes,
  });

  /// Business date; today when null.
  final LedgerDate? entryDate;

  /// Null = walk-in (no udhaar).
  final String? partyId;

  /// Name for a walk-in's bill.
  final String? customerName;
  final String? tier;
  final List<SaleDraftLine> lines;
  final InvoiceDiscount discount;
  final PaymentSplit payment;

  /// Bank account the UPI part lands in; needed when UPI is used.
  final String? upiAccountId;
  final String? notes;
}

/// Why a draft cannot be saved.
enum SaleProblem {
  noLines,
  badQuantity,
  badPrice,
  badDiscount,
  productMissing,
  paymentMismatch,
  negativePayment,
  udhaarNeedsParty,
  upiNeedsAccount,
}

/// A line the stock cannot serve.
@immutable
class SaleStockIssue {
  const SaleStockIssue(this.lineIndex, this.productId, this.error);

  final int lineIndex;
  final String productId;
  final StockErrorKind error;
}

sealed class SaleSaveResult {
  const SaleSaveResult();
}

final class SaleSaved extends SaleSaveResult {
  const SaleSaved(this.id, this.saleNo, {this.warnings = const []});

  final String id;
  final String saleNo;

  /// Near-expiry or expired batches that were sold, negative stock.
  final List<StockWarning> warnings;
}

final class SaleNotPermitted extends SaleSaveResult {
  const SaleNotPermitted(
    this.permission, {
    this.backdateDays,
    this.lockedYear = false,
  });

  final Permission permission;
  final int? backdateDays;
  final bool lockedYear;
}

final class SaleInvalid extends SaleSaveResult {
  const SaleInvalid(this.problems);

  final Set<SaleProblem> problems;
}

final class SaleStockRefused extends SaleSaveResult {
  const SaleStockRefused(this.issues);

  final List<SaleStockIssue> issues;
}

final class SaleNotFound extends SaleSaveResult {
  const SaleNotFound();
}

/// The bill cannot change any more (reversed, or has returns).
final class SaleLocked extends SaleSaveResult {
  const SaleLocked();
}

/// A return the cashier asked for: part of one sale line row.
@immutable
class ReturnItem {
  const ReturnItem(this.saleLineId, this.qtyMilli);

  final String saleLineId;
  final int qtyMilli;
}

/// How a sales return is settled. [viaUpi] sends the cash part back from
/// [bankAccountId] instead of the cash drawer.
@immutable
class ReturnDraft {
  const ReturnDraft({
    required this.saleId,
    required this.items,
    this.choice = RefundChoice.auto,
    this.viaUpi = false,
    this.bankAccountId,
    this.note,
    this.entryDate,
  });

  final String saleId;
  final List<ReturnItem> items;
  final RefundChoice choice;
  final bool viaUpi;
  final String? bankAccountId;
  final String? note;
  final LedgerDate? entryDate;
}

enum ReturnProblem { noItems, badQuantity, noParty, upiNeedsAccount }

sealed class ReturnSaveResult {
  const ReturnSaveResult();
}

final class ReturnSaved extends ReturnSaveResult {
  const ReturnSaved(
    this.id,
    this.returnNo, {
    required this.refund,
    required this.toKhata,
    required this.toCash,
  });

  final String id;
  final String returnNo;
  final Money refund;
  final Money toKhata;
  final Money toCash;
}

final class ReturnNotPermitted extends ReturnSaveResult {
  const ReturnNotPermitted(
    this.permission, {
    this.backdateDays,
    this.lockedYear = false,
  });

  final Permission permission;
  final int? backdateDays;
  final bool lockedYear;
}

final class ReturnInvalid extends ReturnSaveResult {
  const ReturnInvalid(this.problems);

  final Set<ReturnProblem> problems;
}

final class ReturnNotFound extends ReturnSaveResult {
  const ReturnNotFound();
}

final class ReturnLocked extends ReturnSaveResult {
  const ReturnLocked();
}
