import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// One line the user typed on the purchase entry screen.
@immutable
class PurchaseLineDraft {
  const PurchaseLineDraft({
    required this.productId,
    required this.batchNo,
    required this.qtyMilli,
    required this.unitCost,
    this.rateBp,
    this.hsn,
    this.mfgDate,
    this.expiry,
  });

  final String productId;
  final String batchNo;
  final int qtyMilli;

  /// Per whole unit, before tax.
  final Money unitCost;

  /// GST rate in basis points of a percent (1800 = 18%); null = no rate.
  final int? rateBp;
  final String? hsn;
  final LedgerDate? mfgDate;
  final LedgerDate? expiry;
}

/// A supplier invoice to record.
@immutable
class PurchaseDraft {
  const PurchaseDraft({
    required this.supplierId,
    required this.invoiceDate,
    required this.lines,
    this.date,
    this.supplierInvoiceNo,
    this.freight = Money.zero,
    this.otherCharges = Money.zero,
    this.roundOff = Money.zero,
    this.paid = Money.zero,
    this.paidInCash = true,
    this.bankAccountId,
    this.creditDays,
    this.notes,
  });

  final String supplierId;
  final String? supplierInvoiceNo;
  final LedgerDate invoiceDate;

  /// The business date it is booked on; today when null.
  final LedgerDate? date;
  final List<PurchaseLineDraft> lines;
  final Money freight;
  final Money otherCharges;

  /// Signed paise to reach the supplier's printed total.
  final Money roundOff;

  /// Paid now, from cash or [bankAccountId].
  final Money paid;
  final bool paidInCash;
  final String? bankAccountId;

  /// Null = the setting `shop.supplier_credit_days`.
  final int? creditDays;
  final String? notes;
}

enum PurchaseProblem {
  noLines,
  badLine,
  noBatchNo,
  badDates,
  noSupplier,
  notASupplier,
  unknownProduct,
  negativePaid,
  paidAboveTotal,
  noBankAccount,
  negativeCharges,
}

/// A request to send part of a purchase line back.
@immutable
class PurchaseReturnLineDraft {
  const PurchaseReturnLineDraft(this.purchaseLineId, this.qtyMilli);

  final String purchaseLineId;
  final int qtyMilli;
}

@immutable
class PurchaseReturnDraft {
  const PurchaseReturnDraft({
    required this.purchaseId,
    required this.lines,
    this.date,
    this.choice = RefundChoice.auto,
    this.refundInCash = true,
    this.bankAccountId,
    this.note,
  });

  final String purchaseId;
  final List<PurchaseReturnLineDraft> lines;
  final LedgerDate? date;

  /// How the supplier settles: credit note on the khata, money back, or
  /// credit up to what is still unpaid on the bill (auto).
  final RefundChoice choice;
  final bool refundInCash;
  final String? bankAccountId;
  final String? note;
}

sealed class PurchaseResult {
  const PurchaseResult();
}

final class PurchaseSaved extends PurchaseResult {
  const PurchaseSaved(this.id, this.number, {this.dueDate});

  final String id;

  /// `PB-W1-0001`, or `PR-W1-0001` for a return.
  final String number;
  final LedgerDate? dueDate;
}

final class PurchaseInvalid extends PurchaseResult {
  const PurchaseInvalid(this.problems);

  final List<PurchaseProblem> problems;
}

final class PurchaseReturnInvalid extends PurchaseResult {
  const PurchaseReturnInvalid(this.issues);

  final List<ReturnLineIssue> issues;
}

final class PurchaseNotPermitted extends PurchaseResult {
  const PurchaseNotPermitted(
    this.permission, {
    this.backdateDays,
    this.lockedYear = false,
  });

  final Permission permission;
  final int? backdateDays;
  final bool lockedYear;
}

final class PurchaseNotFound extends PurchaseResult {
  const PurchaseNotFound();
}

/// Already reversed, or an id that was used.
final class PurchaseLocked extends PurchaseResult {
  const PurchaseLocked();
}

/// Cannot be reversed: part of it was returned or sold already.
final class PurchaseInUse extends PurchaseResult {
  const PurchaseInUse();
}

/// A purchase in the list.
@immutable
class PurchaseSummary {
  const PurchaseSummary({
    required this.id,
    required this.purchaseNo,
    required this.supplierId,
    required this.supplierName,
    required this.invoiceDate,
    required this.date,
    required this.total,
    required this.paid,
    required this.outstanding,
    required this.isReversed,
    this.supplierInvoiceNo,
    this.dueDate,
    this.overdueDays = 0,
  });

  final String id;
  final String purchaseNo;
  final String supplierId;
  final String supplierName;
  final String? supplierInvoiceNo;
  final LedgerDate invoiceDate;
  final LedgerDate date;
  final LedgerDate? dueDate;
  final Money total;

  /// Paid at the time of purchase.
  final Money paid;

  /// Still owed on this bill after later payments and credit notes (the
  /// FIFO allocation of khata_core `Payables`).
  final Money outstanding;
  final int overdueDays;
  final bool isReversed;

  bool get isUnpaid => !isReversed && outstanding.isPositive;
}

@immutable
class PurchaseLineView {
  const PurchaseLineView({
    required this.id,
    required this.lineNo,
    required this.productId,
    required this.productName,
    required this.batchId,
    required this.batchNo,
    required this.qtyMilli,
    required this.returnedMilli,
    required this.unitCost,
    required this.gstRateBp,
    required this.taxable,
    required this.gst,
    this.mfgDate,
    this.expiry,
  });

  final String id;
  final int lineNo;
  final String productId;
  final String productName;
  final String batchId;
  final String batchNo;
  final LedgerDate? mfgDate;
  final LedgerDate? expiry;
  final int qtyMilli;
  final int returnedMilli;
  final Money unitCost;
  final int gstRateBp;
  final Money taxable;
  final Money gst;

  Money get total => taxable + gst;
  int get returnableMilli => qtyMilli - returnedMilli;
}

@immutable
class PurchaseReturnView {
  const PurchaseReturnView({
    required this.id,
    required this.returnNo,
    required this.date,
    required this.total,
    required this.creditedToKhata,
    required this.refundedPaid,
    required this.isReversed,
  });

  final String id;
  final String returnNo;
  final LedgerDate date;
  final Money total;
  final Money creditedToKhata;
  final Money refundedPaid;
  final bool isReversed;
}

@immutable
class PurchaseDetail {
  const PurchaseDetail({
    required this.summary,
    required this.lines,
    required this.returns,
    required this.taxable,
    required this.gst,
    required this.freight,
    required this.otherCharges,
    required this.roundOff,
    required this.paidInCash,
    required this.creditDays,
    this.accountName,
    this.notes,
  });

  final PurchaseSummary summary;
  final List<PurchaseLineView> lines;
  final List<PurchaseReturnView> returns;
  final Money taxable;
  final Money gst;
  final Money freight;
  final Money otherCharges;
  final Money roundOff;
  final bool paidInCash;
  final String? accountName;
  final int creditDays;
  final String? notes;

  bool get canReturn =>
      !summary.isReversed && lines.any((l) => l.returnableMilli > 0);
}

/// What one supplier is owed for purchases (step 4.4 payables).
@immutable
class SupplierPayable {
  const SupplierPayable({
    required this.supplierId,
    required this.supplierName,
    required this.supplierCode,
    required this.outstanding,
    required this.dueDate,
    required this.overdueDays,
    required this.bills,
  });

  final String supplierId;
  final String supplierName;
  final String supplierCode;
  final Money outstanding;
  final LedgerDate dueDate;
  final int overdueDays;
  final List<PayableBillState> bills;

  bool get isOverdue => overdueDays > 0;
}

enum PurchaseStatusFilter { all, unpaid, reversed }

@immutable
class PurchaseFilter {
  const PurchaseFilter({
    this.supplierId,
    this.from,
    this.to,
    this.status = PurchaseStatusFilter.all,
  });

  final String? supplierId;
  final LedgerDate? from;
  final LedgerDate? to;
  final PurchaseStatusFilter status;

  @override
  bool operator ==(Object other) =>
      other is PurchaseFilter &&
      other.supplierId == supplierId &&
      other.from == from &&
      other.to == to &&
      other.status == status;

  @override
  int get hashCode => Object.hash(supplierId, from, to, status);
}

/// A product as the entry screen needs it.
@immutable
class PurchaseProduct {
  const PurchaseProduct({
    required this.id,
    required this.name,
    required this.unit,
    required this.gstRateBp,
    this.sku,
    this.hsn,
    this.brand,
  });

  factory PurchaseProduct.fromRow(Map<String, Object?> r) => PurchaseProduct(
    id: r['id']! as String,
    name: r['name']! as String,
    unit: r['unit']! as String,
    sku: r['sku'] as String?,
    brand: r['brand'] as String?,
    hsn: r['hsn'] as String?,
    gstRateBp: (((r['gst_rate'] as num?) ?? 0) * 100).round(),
  );

  final String id;
  final String name;
  final String unit;
  final String? sku;
  final String? brand;
  final String? hsn;

  /// The product's default GST rate in basis points.
  final int gstRateBp;
}

/// An existing batch of a product, to prefill a line.
@immutable
class PurchaseBatchHint {
  const PurchaseBatchHint({
    required this.batchNo,
    required this.cost,
    this.mfgDate,
    this.expiry,
  });

  final String batchNo;
  final Money cost;
  final LedgerDate? mfgDate;
  final LedgerDate? expiry;
}

/// A party that can be picked as supplier.
@immutable
class SupplierOption {
  const SupplierOption({
    required this.id,
    required this.name,
    required this.code,
    this.gstin,
    this.village,
  });

  final String id;
  final String name;
  final String code;
  final String? gstin;
  final String? village;
}
