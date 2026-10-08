import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/dues_models.dart';

/// Report tables of the shop reports not built by khata_core, in the same
/// shape ([ReportTable]) so screen, PDF, CSV and Excel agree.
abstract final class ShopReportTables {
  static String _en(String s) => s;

  /// khata_core marks product quantities as `quantity` (a weight in
  /// quintals for the mandi reports); shop quantities are plain units, so
  /// those columns become text such as `2.5`.
  static ReportTable units(ReportTable t) {
    final qty = {
      for (final (i, c) in t.columns.indexed)
        if (c.kind == ReportColumnKind.quantity) i,
    };
    if (qty.isEmpty) return t;
    Object? cell(int i, Object? v) =>
        qty.contains(i) && v is int ? Qty.format(v) : v;
    List<Object?> fix(List<Object?> row) => [
      for (final (i, v) in row.indexed) cell(i, v),
    ];
    ReportColumn col(int i, ReportColumn c) =>
        qty.contains(i) ? ReportColumn(c.title, ReportColumnKind.text) : c;
    return ReportTable(
      columns: [
        for (final (i, c) in t.columns.indexed) col(i, c),
      ],
      rows: [for (final r in t.rows) fix(r)],
      totals: t.totals == null ? null : fix(t.totals!),
    );
  }

  static String _invoiceType(Gstr1Invoice inv, ReportTitle title) {
    if (inv.isCreditNote) return title('Credit note');
    return inv.isRegistered ? 'B2B' : 'B2C';
  }

  static String bucketTitle(ExpiryBucket b, ReportTitle t) => switch (b) {
    ExpiryBucket.expired => t('Expired'),
    ExpiryBucket.within30 => t('Within 30 days'),
    ExpiryBucket.within60 => t('31 to 60 days'),
    ExpiryBucket.within90 => t('61 to 90 days'),
    ExpiryBucket.later => t('Later'),
  };

  /// Batches that expire, soonest first. [withCost] adds the stock value at
  /// cost (needs `shop.view_profit`).
  static ReportTable expiry(
    List<ExpiryRow> rows, {
    required bool withCost,
    ReportTitle title = _en,
  }) {
    var value = Money.zero;
    var qty = 0;
    for (final r in rows) {
      value += r.value;
      qty += r.batch.remainingMilli;
    }
    return ReportTable(
      columns: [
        ReportColumn(title('Product'), ReportColumnKind.text),
        ReportColumn(title('Batch'), ReportColumnKind.text),
        ReportColumn(title('Expiry'), ReportColumnKind.date),
        ReportColumn(title('Days left'), ReportColumnKind.number),
        ReportColumn(title('Status'), ReportColumnKind.text),
        ReportColumn(title('Qty'), ReportColumnKind.text),
        if (withCost)
          ReportColumn(title('Value at cost'), ReportColumnKind.money),
      ],
      rows: [
        for (final r in rows)
          [
            r.productName,
            r.batch.batchNo,
            r.batch.expiry,
            r.daysLeft,
            bucketTitle(r.bucket, title),
            Qty.format(r.batch.remainingMilli),
            if (withCost) r.value,
          ],
      ],
      totals: [
        title('Total'),
        null,
        null,
        null,
        null,
        Qty.format(qty),
        if (withCost) value,
      ],
    );
  }

  static ReportTable reorder(
    List<ReorderSuggestion> rows, {
    ReportTitle title = _en,
  }) => ReportTable(
    columns: [
      ReportColumn(title('Product'), ReportColumnKind.text),
      ReportColumn(title('In stock'), ReportColumnKind.text),
      ReportColumn(title('Reorder level'), ReportColumnKind.text),
      ReportColumn(title('Sold in 30 days'), ReportColumnKind.text),
      ReportColumn(title('Days of stock'), ReportColumnKind.number),
      ReportColumn(title('Suggested purchase'), ReportColumnKind.text),
    ],
    rows: [
      for (final r in rows)
        [
          r.name,
          Qty.format(r.stockMilli),
          Qty.format(r.reorderLevelMilli),
          Qty.format(r.soldLast30Milli),
          r.daysOfStock,
          Qty.format(r.suggestedMilli),
        ],
    ],
  );

  /// Supplier payables; the total is a breakdown of the khata, not a
  /// balance.
  static ReportTable payables(
    List<SupplierPayable> rows, {
    ReportTitle title = _en,
  }) => ReportTable(
    columns: [
      ReportColumn(title('Supplier'), ReportColumnKind.text),
      ReportColumn(title('Unpaid bills'), ReportColumnKind.money),
      ReportColumn(title('Due date'), ReportColumnKind.date),
      ReportColumn(title('Days overdue'), ReportColumnKind.number),
      ReportColumn(title('Khata balance'), ReportColumnKind.money),
    ],
    rows: [
      for (final r in rows)
        [r.name, r.outstanding, r.oldestDue, r.daysOverdue, r.khataBalance],
    ],
    totals: [
      title('Total'),
      rows.fold<Money>(Money.zero, (a, r) => a + r.outstanding),
      null,
      null,
      null,
    ],
  );

  /// Customer receivables of the shop portion.
  static ReportTable receivables(
    List<CustomerReceivable> rows, {
    ReportTitle title = _en,
  }) => ReportTable(
    columns: [
      ReportColumn(title('Customer'), ReportColumnKind.text),
      ReportColumn(title('Shop sales'), ReportColumnKind.money),
      ReportColumn(title('Shop returns'), ReportColumnKind.money),
      ReportColumn(title('To collect'), ReportColumnKind.money),
      ReportColumn(title('Khata balance'), ReportColumnKind.money),
    ],
    rows: [
      for (final r in rows)
        [r.name, r.shopSales, r.shopReturns, r.receivable, r.khataBalance],
    ],
    totals: [
      title('Total'),
      null,
      null,
      rows.fold<Money>(Money.zero, (a, r) => a + r.receivable),
      null,
    ],
  );

  /// Every invoice and credit note of the month with its tax.
  static ReportTable invoices(
    List<Gstr1Invoice> invoices, {
    ReportTitle title = _en,
  }) {
    var totals = const _Sum();
    final rows = <List<Object?>>[];
    for (final inv in invoices) {
      var s = GstSplit.zero;
      for (final l in inv.lines) {
        s += l.split;
      }
      final sign = inv.isCreditNote ? -s : s;
      final value = inv.isCreditNote ? -inv.value : inv.value;
      totals = totals.add(sign, value);
      rows.add([
        inv.number,
        inv.date,
        inv.customerName,
        inv.gstin,
        _invoiceType(inv, title),
        sign.taxable,
        sign.cgst,
        sign.sgst,
        sign.igst,
        value,
      ]);
    }
    return ReportTable(
      columns: [
        ReportColumn(title('Invoice no'), ReportColumnKind.text),
        ReportColumn(title('Date'), ReportColumnKind.date),
        ReportColumn(title('Customer'), ReportColumnKind.text),
        ReportColumn(title('GSTIN'), ReportColumnKind.text),
        ReportColumn(title('Type'), ReportColumnKind.text),
        ReportColumn(title('Taxable value'), ReportColumnKind.money),
        ReportColumn(title('CGST'), ReportColumnKind.money),
        ReportColumn(title('SGST'), ReportColumnKind.money),
        ReportColumn(title('IGST'), ReportColumnKind.money),
        ReportColumn(title('Invoice value'), ReportColumnKind.money),
      ],
      rows: rows,
      totals: [
        title('Total'),
        null,
        null,
        null,
        null,
        totals.split.taxable,
        totals.split.cgst,
        totals.split.sgst,
        totals.split.igst,
        totals.value,
      ],
    );
  }
}

class _Sum {
  const _Sum([this.split = GstSplit.zero, this.value = Money.zero]);

  final GstSplit split;
  final Money value;

  _Sum add(GstSplit s, Money v) => _Sum(split + s, value + v);
}
