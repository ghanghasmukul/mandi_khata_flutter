import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteReadContext;

/// Reads bills from the local database. Every query filters by tenant
/// (CLAUDE.md rule 1). Used by the repository, the screens and the PDF.
abstract final class SaleReader {
  static const tables = {
    'shop_sales',
    'shop_sale_lines',
    'shop_returns',
    'shop_return_lines',
    'products',
    'batches',
    'parties',
  };

  static const _select =
      'SELECT s.*, pa.name AS party_name, pa.code AS party_code, '
      '(SELECT COUNT(DISTINCT l.product_id) FROM shop_sale_lines l '
      'WHERE l.sale_id = s.id AND l.tenant_id = s.tenant_id) AS item_count '
      'FROM shop_sales s '
      'LEFT JOIN parties pa ON pa.id = s.party_id '
      'AND pa.tenant_id = s.tenant_id ';

  static SaleRecord record(Map<String, Object?> r) => SaleRecord(
    id: r['id']! as String,
    saleNo: r['sale_no']! as String,
    entryDate: LedgerDate.parse(r['entry_date']! as String),
    partyId: r['party_id'] as String?,
    partyName: r['party_name'] as String?,
    partyCode: r['party_code'] as String?,
    customerName: r['customer_name'] as String?,
    customerGstin: r['customer_gstin'] as String?,
    placeOfSupply: r['place_of_supply'] as String?,
    tier: r['tier'] as String?,
    subtotal: Money(r['subtotal_paise']! as int),
    lineDiscounts: Money(r['discount_paise']! as int),
    invoiceDiscount: Money(r['invoice_discount_paise']! as int),
    invoiceDiscountPct: (r['invoice_discount_pct']! as num).toDouble(),
    gst: GstSplit(
      taxable: Money(r['taxable_paise']! as int),
      cgst: Money(r['cgst_paise']! as int),
      sgst: Money(r['sgst_paise']! as int),
      igst: Money(r['igst_paise']! as int),
    ),
    roundOff: Money(r['round_off_paise']! as int),
    total: Money(r['total_paise']! as int),
    paidCash: Money(r['paid_cash_paise']! as int),
    paidUpi: Money(r['paid_upi_paise']! as int),
    paidCredit: Money(r['paid_credit_paise']! as int),
    upiAccountId: r['upi_account_id'] as String?,
    notes: r['notes'] as String?,
    status: SaleStatus.parse(r['status'] as String?),
    createdAt: _time(r['created_at']),
    itemCount: (r['item_count'] as int?) ?? 0,
  );

  static DateTime _time(Object? v) =>
      v is String ? DateTime.tryParse(v)?.toUtc() ?? _epoch : _epoch;

  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  static String escape(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

  /// SQL and arguments of the sales list for `filter`.
  static (String, List<Object?>) listQuery(String tenantId, SaleFilter f) {
    final text = f.query.trim().toLowerCase();
    final like = '%${escape(text)}%';
    final where = <String>['s.tenant_id = ?'];
    final args = <Object?>[tenantId];
    if (f.from != null) {
      where.add('s.entry_date >= ?');
      args.add(f.from.toString());
    }
    if (f.to != null) {
      where.add('s.entry_date <= ?');
      args.add(f.to.toString());
    }
    if (f.partyId != null) {
      where.add('s.party_id = ?');
      args.add(f.partyId);
    }
    if (f.tier != null) {
      where.add('s.tier = ?');
      args.add(f.tier);
    }
    if (!f.includeReversed) where.add("s.status = 'posted'");
    switch (f.payment) {
      case SalePaymentKind.cash:
        where.add('s.paid_cash_paise > 0');
      case SalePaymentKind.upi:
        where.add('s.paid_upi_paise > 0');
      case SalePaymentKind.udhaar:
        where.add('s.paid_credit_paise > 0');
      case null:
    }
    if (text.isNotEmpty) {
      where.add(
        r"(lower(s.sale_no) LIKE ? ESCAPE '\' "
        r"OR lower(pa.name) LIKE ? ESCAPE '\' "
        r"OR lower(pa.code) LIKE ? ESCAPE '\' "
        r"OR lower(s.customer_name) LIKE ? ESCAPE '\')",
      );
      args.addAll([like, like, like, like]);
    }
    return (
      '$_select WHERE ${where.join(' AND ')} '
          'ORDER BY s.entry_date DESC, s.created_at DESC, s.id DESC',
      args,
    );
  }

  /// One bill with lines and returns, or null.
  static Future<SaleDetail?> detailIn(
    SqliteReadContext tx,
    String tenantId,
    String saleId,
  ) async {
    final head = await tx.getOptional(
      '$_select WHERE s.tenant_id = ? AND s.id = ?',
      [tenantId, saleId],
    );
    if (head == null) return null;
    final village = head['party_id'] == null
        ? null
        : (await tx.getOptional(
                'SELECT village FROM parties WHERE tenant_id = ? AND id = ?',
                [tenantId, head['party_id']],
              ))?['village']
              as String?;
    final lineRows = await tx.getAll(
      'SELECT l.*, p.name AS product_name, p.unit AS unit, '
      'b.batch_no AS batch_no, b.expiry_date AS expiry_date '
      'FROM shop_sale_lines l '
      'LEFT JOIN products p ON p.id = l.product_id '
      'AND p.tenant_id = l.tenant_id '
      'LEFT JOIN batches b ON b.id = l.batch_id '
      'AND b.tenant_id = l.tenant_id '
      'WHERE l.tenant_id = ? AND l.sale_id = ? ORDER BY l.line_no',
      [tenantId, saleId],
    );
    final returnRows = await tx.getAll(
      'SELECT * FROM shop_returns WHERE tenant_id = ? AND sale_id = ? '
      'ORDER BY created_at, id',
      [tenantId, saleId],
    );
    final doneRows = await tx.getAll(
      'SELECT rl.sale_line_id, rl.qty_milli, rl.taxable_paise, '
      'rl.cgst_paise, rl.sgst_paise, rl.igst_paise '
      'FROM shop_return_lines rl '
      'JOIN shop_returns r ON r.id = rl.shop_return_id '
      'AND r.tenant_id = rl.tenant_id '
      "WHERE rl.tenant_id = ? AND r.sale_id = ? AND r.status = 'posted' "
      'ORDER BY r.created_at, r.id, rl.line_no',
      [tenantId, saleId],
    );

    // Replay earlier returns line by line so the cost taken back is exactly
    // what SalesReturns.compute gave each time.
    final done = <String, ({int milli, GstSplit split, int cost})>{};
    final unitCostOf = {
      for (final l in lineRows)
        l['id']! as String: (
          qty: l['qty_milli']! as int,
          cost: ShopMath.valueOf(
            Money(l['cost_paise']! as int),
            l['qty_milli']! as int,
          ).paise,
        ),
    };
    for (final d in doneRows) {
      final id = d['sale_line_id']! as String;
      final before = done[id] ?? (milli: 0, split: GstSplit.zero, cost: 0);
      final base = unitCostOf[id];
      if (base == null) continue;
      final qty = d['qty_milli']! as int;
      final part = ShopMath.proportional(
        total: base.cost,
        partMilli: qty,
        wholeMilli: base.qty,
        doneMilli: before.milli,
        doneAmount: before.cost,
      );
      done[id] = (
        milli: before.milli + qty,
        split:
            before.split +
            GstSplit(
              taxable: Money(d['taxable_paise']! as int),
              cgst: Money(d['cgst_paise']! as int),
              sgst: Money(d['sgst_paise']! as int),
              igst: Money(d['igst_paise']! as int),
            ),
        cost: before.cost + part,
      );
    }

    final lines = [
      for (final l in lineRows)
        InvoiceLine(
          id: l['id']! as String,
          lineNo: l['line_no']! as int,
          productId: l['product_id']! as String,
          productName: (l['product_name'] as String?) ?? '',
          unit: l['unit'] as String?,
          batchId: l['batch_id'] as String?,
          batchNo: l['batch_no'] as String?,
          expiry: (l['expiry_date'] as String?) == null
              ? null
              : LedgerDate.parse(l['expiry_date']! as String),
          qtyMilli: l['qty_milli']! as int,
          unitPrice: Money(l['unit_price_paise']! as int),
          tier: l['tier'] as String?,
          discount: Money(l['discount_paise']! as int),
          split: GstSplit(
            taxable: Money(l['taxable_paise']! as int),
            cgst: Money(l['cgst_paise']! as int),
            sgst: Money(l['sgst_paise']! as int),
            igst: Money(l['igst_paise']! as int),
          ),
          rateBp: ((l['gst_rate']! as num).toDouble() * 100).round(),
          hsn: l['hsn'] as String?,
          unitCost: Money(l['cost_paise']! as int),
          returnedMilli: done[l['id']]?.milli ?? 0,
          returned: done[l['id']]?.split ?? GstSplit.zero,
          returnedCost: Money(done[l['id']]?.cost ?? 0),
        ),
    ];
    return SaleDetail(
      sale: record(head),
      lines: lines,
      partyVillage: village,
      returns: [
        for (final r in returnRows)
          SaleReturnRecord(
            id: r['id']! as String,
            returnNo: r['return_no']! as String,
            saleId: saleId,
            entryDate: LedgerDate.parse(r['entry_date']! as String),
            total: Money(r['total_paise']! as int),
            refundKhata: Money(r['refund_khata_paise']! as int),
            refundCash: Money(r['refund_cash_paise']! as int),
            refundUpi: Money(r['refund_upi_paise']! as int),
            mode: r['refund_mode']! as String,
            status: SaleStatus.parse(r['status'] as String?),
            createdAt: _time(r['created_at']),
            note: r['note'] as String?,
          ),
      ],
    );
  }
}
