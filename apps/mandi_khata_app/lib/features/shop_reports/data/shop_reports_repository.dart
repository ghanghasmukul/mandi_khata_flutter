import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/dues_models.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/gst_models.dart';
import 'package:powersync/powersync.dart';

/// Read-only queries behind the shop reports (phase 4, steps 4.4 / 4.5),
/// all on the local database so they work offline.
///
/// Every query filters by tenant. Money is whole paise, quantities are
/// thousandths of a unit. Documents that were reversed (`status =
/// 'reversed'`) are left out; khata entries that were reversed cancel with
/// their reversal and are skipped.
/// The customer name of a counter sale without a name or a party; the
/// screens show it translated.
const walkInCustomer = 'Walk-in';

class ShopReportsRepository {
  ShopReportsRepository(this._db);

  final PowerSyncDatabase _db;

  /// An entry that still counts: not a reversal and not reversed.
  static const _effective =
      'e.reverses_id IS NULL AND NOT EXISTS (SELECT 1 FROM ledger_entries r '
      'WHERE r.tenant_id = e.tenant_id AND r.reverses_id = e.id)';

  /// [query] again whenever one of [tables] changes (and once at once).
  Stream<T> live<T>(Iterable<String> tables, Future<T> Function() query) =>
      _db.onChange(tables).asyncMap((_) => query());

  // ---------------------------------------------------------------------
  // Payables and receivables (breakdowns of the khata, never added to it)
  // ---------------------------------------------------------------------

  /// Net khata position (`udhaar - jama`) of every party in [partyIds].
  Future<Map<String, Money>> _balances(
    String tenantId,
    Iterable<String> partyIds,
  ) async {
    if (partyIds.isEmpty) return {};
    final rows = await _db.getAll(
      "SELECT party_id, SUM(CASE side WHEN 'udhaar' THEN amount_paise "
      'ELSE -amount_paise END) AS bal FROM ledger_entries '
      'WHERE tenant_id = ?1 GROUP BY party_id',
      [tenantId],
    );
    final wanted = partyIds.toSet();
    return {
      for (final r in rows)
        if (wanted.contains(r['party_id']))
          r['party_id']! as String: Money(r['bal']! as int),
    };
  }

  Future<Map<String, ({String name, String? code})>> _names(
    String tenantId,
  ) async {
    final rows = await _db.getAll(
      'SELECT id, name, code FROM parties WHERE tenant_id = ?1',
      [tenantId],
    );
    return {
      for (final r in rows)
        r['id']! as String: (
          name: r['name']! as String,
          code: r['code'] as String?,
        ),
    };
  }

  /// Suppliers with purchase bills still unpaid as of [today]: the khata
  /// part of each posted purchase (`purchase` entries), the supplier's
  /// payments allocated to the oldest due date first, the rest as the
  /// outstanding. Most overdue first.
  Future<List<SupplierPayable>> supplierPayables(
    String tenantId, {
    required LedgerDate today,
  }) async {
    final billRows = await _db.getAll(
      'SELECT p.id, p.party_id, p.purchase_no, p.invoice_date, '
      "COALESCE(p.due_date, date(p.invoice_date, '+' || p.credit_days || "
      "' days')) AS due, SUM(e.amount_paise) AS amt "
      'FROM purchases p JOIN ledger_entries e ON e.tenant_id = p.tenant_id '
      "AND e.ref_id = p.id AND e.ref_type = 'purchase' AND e.side = 'jama' "
      "WHERE p.tenant_id = ?1 AND p.status = 'posted' AND $_effective "
      'GROUP BY p.id',
      [tenantId],
    );
    if (billRows.isEmpty) return const [];
    final creditRows = await _db.getAll(
      'SELECT e.party_id, SUM(e.amount_paise) AS amt FROM ledger_entries e '
      "WHERE e.tenant_id = ?1 AND e.side = 'udhaar' AND e.ref_type IN "
      "(${supplierSettlementRefTypes.map((t) => "'$t'").join(', ')}) "
      'AND $_effective '
      'AND e.party_id IN (SELECT party_id FROM purchases '
      'WHERE tenant_id = ?1) GROUP BY e.party_id',
      [tenantId],
    );
    final credits = {
      for (final r in creditRows)
        r['party_id']! as String: Money(r['amt']! as int),
    };
    final bills = <String, List<SupplierBill>>{};
    for (final r in billRows) {
      bills
          .putIfAbsent(r['party_id']! as String, () => [])
          .add(
            SupplierBill(
              purchaseId: r['id']! as String,
              purchaseNo: r['purchase_no']! as String,
              invoiceDate: LedgerDate.parse(r['invoice_date']! as String),
              dueDate: LedgerDate.parse(r['due']! as String),
              amount: Money(r['amt']! as int),
            ),
          );
    }
    final balances = await _balances(tenantId, bills.keys);
    final names = await _names(tenantId);
    final out = <SupplierPayable>[];
    for (final e in bills.entries) {
      final p = DuesCalc.payable(
        partyId: e.key,
        name: names[e.key]?.name ?? '',
        code: names[e.key]?.code,
        bills: e.value,
        credits: credits[e.key] ?? Money.zero,
        khataBalance: balances[e.key] ?? Money.zero,
        today: today,
      );
      if (p.outstanding.isPositive) out.add(p);
    }
    return out..sort((a, b) {
      final c = b.daysOverdue.compareTo(a.daysOverdue);
      if (c != 0) return c;
      final o = b.outstanding.compareTo(a.outstanding);
      return o != 0 ? o : a.name.compareTo(b.name);
    });
  }

  Stream<List<SupplierPayable>> watchSupplierPayables(
    String tenantId, {
    required LedgerDate today,
  }) => live(
    const ['purchases', 'ledger_entries', 'parties'],
    () => supplierPayables(tenantId, today: today),
  );

  /// Customers with shop credit: `shop_sale` (udhaar) less `shop_return`
  /// (jama) entries, limited to what the party owes on the whole khata.
  /// Biggest first.
  Future<List<CustomerReceivable>> customerReceivables(
    String tenantId,
  ) async {
    final rows = await _db.getAll(
      'SELECT e.party_id, '
      "SUM(CASE WHEN e.ref_type = 'shop_sale' AND e.side = 'udhaar' "
      'THEN e.amount_paise ELSE 0 END) AS sales, '
      "SUM(CASE WHEN e.ref_type = 'shop_return' AND e.side = 'jama' "
      'THEN e.amount_paise ELSE 0 END) AS returns, '
      "MAX(CASE WHEN e.ref_type = 'shop_sale' THEN e.entry_date END) "
      'AS last_sale FROM ledger_entries e '
      "WHERE e.tenant_id = ?1 AND e.ref_type IN ('shop_sale', "
      "'shop_return') AND $_effective GROUP BY e.party_id",
      [tenantId],
    );
    if (rows.isEmpty) return const [];
    final balances = await _balances(tenantId, [
      for (final r in rows) r['party_id']! as String,
    ]);
    final names = await _names(tenantId);
    final out = <CustomerReceivable>[];
    for (final r in rows) {
      final id = r['party_id']! as String;
      final sales = Money(r['sales']! as int);
      final returns = Money(r['returns']! as int);
      final balance = balances[id] ?? Money.zero;
      final receivable = DuesCalc.receivable(sales - returns, balance);
      if (!(sales - returns).isPositive) continue;
      out.add(
        CustomerReceivable(
          partyId: id,
          name: names[id]?.name ?? '',
          code: names[id]?.code,
          shopSales: sales,
          shopReturns: returns,
          receivable: receivable,
          khataBalance: balance,
          lastSale: switch (r['last_sale']) {
            final String s => LedgerDate.parse(s),
            _ => null,
          },
        ),
      );
    }
    return out..sort((a, b) {
      final c = b.receivable.compareTo(a.receivable);
      return c != 0 ? c : a.name.compareTo(b.name);
    });
  }

  Stream<List<CustomerReceivable>> watchCustomerReceivables(String tenantId) =>
      live(
        const ['ledger_entries', 'parties'],
        () => customerReceivables(tenantId),
      );

  /// One party's khata by `ref_type`; the parts add up to the balance.
  Future<KhataBreakdown> khataBreakdown(
    String tenantId,
    String partyId,
  ) async {
    final rows = await _db.getAll(
      "SELECT e.ref_type, SUM(CASE e.side WHEN 'udhaar' "
      'THEN e.amount_paise ELSE -e.amount_paise END) AS amt '
      'FROM ledger_entries e WHERE e.tenant_id = ?1 AND e.party_id = ?2 '
      'AND $_effective GROUP BY e.ref_type ORDER BY e.ref_type',
      [tenantId, partyId],
    );
    final balance = await _balances(tenantId, [partyId]);
    return KhataBreakdown(
      parts: {
        for (final r in rows) r['ref_type']! as String: Money(r['amt']! as int),
      },
      balance: balance[partyId] ?? Money.zero,
    );
  }

  // ---------------------------------------------------------------------
  // Profit
  // ---------------------------------------------------------------------

  /// Sold lines (and returned ones, negative) dated [from]..[to], summed per
  /// product and month. Revenue is the taxable value; cost is the batch
  /// cost snapshot of the sale line times the quantity, rounded half-up per
  /// line.
  Future<List<SaleLineRecord>> profitRecords(
    String tenantId, {
    required LedgerDate from,
    required LedgerDate to,
  }) async {
    // `cost` is the sale line's batch cost per unit; a return takes back
    // the cost of the line it returns, in proportion to the quantity.
    String query(String lines, String cost) =>
        'SELECT l.product_id, p.name, p.sku, p.category_id, c.name AS cat, '
        'substr(s.entry_date, 1, 7) AS ym, SUM(l.qty_milli) AS qty, '
        'SUM(l.taxable_paise) AS rev, '
        'SUM(($cost * l.qty_milli + 500) / 1000) AS cogs FROM $lines '
        'LEFT JOIN products p ON p.id = l.product_id '
        'AND p.tenant_id = l.tenant_id '
        'LEFT JOIN product_categories c ON c.id = p.category_id '
        'AND c.tenant_id = p.tenant_id '
        "WHERE l.tenant_id = ?1 AND s.status = 'posted' "
        'AND s.entry_date >= ?2 AND s.entry_date <= ?3 '
        'GROUP BY l.product_id, ym';
    final args = [tenantId, from.toString(), to.toString()];
    final sales = await _db.getAll(
      query(
        'shop_sale_lines l JOIN shop_sales s ON s.id = l.sale_id '
        'AND s.tenant_id = l.tenant_id',
        'l.cost_paise',
      ),
      args,
    );
    final returns = await _db.getAll(
      query(
        'shop_return_lines l JOIN shop_returns s '
        'ON s.id = l.shop_return_id AND s.tenant_id = l.tenant_id '
        'JOIN shop_sale_lines sl ON sl.id = l.sale_line_id '
        'AND sl.tenant_id = l.tenant_id',
        'sl.cost_paise',
      ),
      args,
    );
    SaleLineRecord record(Map<String, Object?> r, {required bool negate}) {
      final sign = negate ? -1 : 1;
      final ym = (r['ym']! as String).split('-');
      return SaleLineRecord(
        productId: r['product_id']! as String,
        productName: (r['name'] as String?) ?? (r['sku'] as String?) ?? '',
        categoryId: r['category_id'] as String?,
        categoryName: r['cat'] as String?,
        date: LedgerDate(int.parse(ym[0]), int.parse(ym[1]), 1),
        qtyMilli: sign * (r['qty']! as int),
        revenue: Money(sign * (r['rev']! as int)),
        cogs: Money(sign * (r['cogs']! as int)),
      );
    }

    return [
      for (final r in sales) record(r, negate: false),
      for (final r in returns) record(r, negate: true),
    ];
  }

  Stream<List<SaleLineRecord>> watchProfitRecords(
    String tenantId, {
    required LedgerDate from,
    required LedgerDate to,
  }) => live(
    const [
      'shop_sales',
      'shop_sale_lines',
      'shop_returns',
      'shop_return_lines',
      'products',
      'product_categories',
    ],
    () => profitRecords(
      tenantId,
      from: from,
      to: to,
    ),
  );

  // ---------------------------------------------------------------------
  // GST
  // ---------------------------------------------------------------------

  static int _rateBp(Object? rate) =>
      rate is num ? (rate * 100).round() : 0;

  static String _monthStart(int year, int month) =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-01';

  /// The month's sales invoices and credit notes (sales returns) in the
  /// shape of the GSTR-1 builder. [tenantStateCode] is the place of supply
  /// of a counter sale that did not record one.
  Future<List<Gstr1Invoice>> gstInvoices(
    String tenantId, {
    required int year,
    required int month,
    required String tenantStateCode,
  }) async {
    final start = _monthStart(year, month);
    final next = month == 12
        ? _monthStart(year + 1, 1)
        : _monthStart(year, month + 1);
    final sales = await _db.getAll(
      'SELECT s.id, s.sale_no, s.entry_date, s.customer_name, '
      's.customer_gstin, s.place_of_supply, s.round_off_paise, '
      'pt.name AS party_name FROM shop_sales s '
      'LEFT JOIN parties pt ON pt.id = s.party_id '
      'AND pt.tenant_id = s.tenant_id '
      "WHERE s.tenant_id = ?1 AND s.status = 'posted' "
      'AND s.entry_date >= ?2 AND s.entry_date < ?3',
      [tenantId, start, next],
    );
    final saleLines = await _db.getAll(
      'SELECT l.sale_id, l.hsn, l.gst_rate, l.qty_milli, l.taxable_paise, '
      'l.cgst_paise, l.sgst_paise, l.igst_paise, p.unit '
      'FROM shop_sale_lines l JOIN shop_sales s ON s.id = l.sale_id '
      'AND s.tenant_id = l.tenant_id '
      'LEFT JOIN products p ON p.id = l.product_id '
      'AND p.tenant_id = l.tenant_id '
      "WHERE l.tenant_id = ?1 AND s.status = 'posted' "
      'AND s.entry_date >= ?2 AND s.entry_date < ?3 '
      'ORDER BY l.sale_id, l.line_no',
      [tenantId, start, next],
    );
    final returns = await _db.getAll(
      'SELECT h.id, h.return_no, h.entry_date, h.round_off_paise, '
      's.customer_name, s.customer_gstin, s.place_of_supply, '
      'pt.name AS party_name FROM shop_returns h '
      'JOIN shop_sales s ON s.id = h.sale_id AND s.tenant_id = h.tenant_id '
      'LEFT JOIN parties pt ON pt.id = s.party_id '
      'AND pt.tenant_id = s.tenant_id '
      "WHERE h.tenant_id = ?1 AND h.status = 'posted' "
      'AND h.entry_date >= ?2 AND h.entry_date < ?3',
      [tenantId, start, next],
    );
    final returnLines = await _db.getAll(
      'SELECT l.shop_return_id, sl.hsn, sl.gst_rate, l.qty_milli, '
      'l.taxable_paise, l.cgst_paise, l.sgst_paise, l.igst_paise, p.unit '
      'FROM shop_return_lines l '
      'JOIN shop_returns h ON h.id = l.shop_return_id '
      'AND h.tenant_id = l.tenant_id '
      'JOIN shop_sale_lines sl ON sl.id = l.sale_line_id '
      'AND sl.tenant_id = l.tenant_id '
      'LEFT JOIN products p ON p.id = l.product_id '
      'AND p.tenant_id = l.tenant_id '
      "WHERE l.tenant_id = ?1 AND h.status = 'posted' "
      'AND h.entry_date >= ?2 AND h.entry_date < ?3 '
      'ORDER BY l.shop_return_id, l.line_no',
      [tenantId, start, next],
    );

    Gstr1Line line(Map<String, Object?> r) => Gstr1Line(
      hsn: (r['hsn'] as String?) ?? '',
      rateBp: _rateBp(r['gst_rate']),
      qtyMilli: r['qty_milli']! as int,
      uqc: Gstr1Uqc.of((r['unit'] as String?) ?? ''),
      split: GstSplit(
        taxable: Money(r['taxable_paise']! as int),
        cgst: Money(r['cgst_paise']! as int),
        sgst: Money(r['sgst_paise']! as int),
        igst: Money(r['igst_paise']! as int),
      ),
    );

    Map<String, List<Gstr1Line>> group(
      Iterable<Map<String, Object?>> rows,
      String key,
    ) {
      final out = <String, List<Gstr1Line>>{};
      for (final r in rows) {
        out.putIfAbsent(r[key]! as String, () => []).add(line(r));
      }
      return out;
    }

    String name(Map<String, Object?> r) {
      final typed = (r['customer_name'] as String?)?.trim() ?? '';
      if (typed.isNotEmpty) return typed;
      final party = (r['party_name'] as String?)?.trim() ?? '';
      return party.isNotEmpty ? party : walkInCustomer;
    }

    String? gstin(Map<String, Object?> r) {
      final g = (r['customer_gstin'] as String?)?.trim() ?? '';
      return g.isEmpty ? null : g;
    }

    String pos(Map<String, Object?> r) {
      final p = (r['place_of_supply'] as String?)?.trim() ?? '';
      return p.isEmpty ? tenantStateCode : p;
    }

    final byInvoice = group(saleLines, 'sale_id');
    final byReturn = group(returnLines, 'shop_return_id');
    return [
      for (final r in sales)
        if (byInvoice[r['id']] != null)
          Gstr1Invoice(
            number: r['sale_no']! as String,
            date: LedgerDate.parse(r['entry_date']! as String),
            customerName: name(r),
            gstin: gstin(r),
            placeOfSupply: pos(r),
            lines: byInvoice[r['id']]!,
            roundOff: Money(r['round_off_paise']! as int),
          ),
      for (final r in returns)
        if (byReturn[r['id']] != null)
          Gstr1Invoice(
            number: r['return_no']! as String,
            date: LedgerDate.parse(r['entry_date']! as String),
            customerName: name(r),
            gstin: gstin(r),
            placeOfSupply: pos(r),
            lines: byReturn[r['id']]!,
            roundOff: Money(r['round_off_paise']! as int),
            isCreditNote: true,
          ),
    ];
  }

  /// Active products whose HSN or GST rate would fail a filing.
  Future<List<GstProductFlag>> gstProductFlags(String tenantId) async {
    final rows = await _db.getAll(
      'SELECT id, sku, name, hsn, gst_rate FROM products '
      'WHERE tenant_id = ?1 AND deleted_at IS NULL AND is_active = 1 '
      'ORDER BY name',
      [tenantId],
    );
    final out = <GstProductFlag>[];
    for (final r in rows) {
      final rate = r['gst_rate'];
      final bp = rate is num ? _rateBp(rate) : null;
      final issues = GstChecks.issues(hsn: r['hsn'] as String?, rateBp: bp);
      if (issues.isEmpty) continue;
      out.add(
        GstProductFlag(
          productId: r['id']! as String,
          sku: r['sku']! as String,
          name: r['name']! as String,
          hsn: r['hsn'] as String?,
          rateBp: bp,
          issues: issues,
        ),
      );
    }
    return out;
  }

  Stream<List<Gstr1Invoice>> watchGstInvoices(
    String tenantId, {
    required int year,
    required int month,
    required String tenantStateCode,
  }) => live(
    const [
      'shop_sales',
      'shop_sale_lines',
      'shop_returns',
      'shop_return_lines',
      'parties',
      'products',
    ],
    () => gstInvoices(
      tenantId,
      year: year,
      month: month,
      tenantStateCode: tenantStateCode,
    ),
  );

  Stream<List<GstProductFlag>> watchGstProductFlags(String tenantId) =>
      live(const ['products'], () => gstProductFlags(tenantId));

  // ---------------------------------------------------------------------
  // Stock reports
  // ---------------------------------------------------------------------

  /// Batches with stock and an expiry date; the quantity is the sum of the
  /// batch's stock movements (the truth, not the cached column).
  Future<List<ExpiryRow>> expiryRows(
    String tenantId, {
    required LedgerDate today,
  }) async {
    final rows = await _db.getAll(
      'SELECT b.id, b.product_id, b.batch_no, b.cost_paise, b.expiry_date, '
      'b.created_at, p.name, COALESCE(m.qty, 0) AS qty FROM batches b '
      'JOIN products p ON p.id = b.product_id AND p.tenant_id = b.tenant_id '
      'LEFT JOIN (SELECT batch_id, SUM(qty_milli) AS qty '
      'FROM stock_movements WHERE tenant_id = ?1 GROUP BY batch_id) m '
      'ON m.batch_id = b.id '
      'WHERE b.tenant_id = ?1 AND b.expiry_date IS NOT NULL '
      'AND p.deleted_at IS NULL',
      [tenantId],
    );
    return ExpiryReport.rows([
      for (final r in rows)
        (
          StockBatch(
            id: r['id']! as String,
            productId: r['product_id']! as String,
            batchNo: r['batch_no']! as String,
            cost: Money(r['cost_paise']! as int),
            remainingMilli: r['qty']! as int,
            createdAt:
                DateTime.tryParse((r['created_at'] as String?) ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
            expiry: LedgerDate.parse(r['expiry_date']! as String),
          ),
          r['name']! as String,
        ),
    ], today: today);
  }

  Stream<List<ExpiryRow>> watchExpiryRows(
    String tenantId, {
    required LedgerDate today,
  }) => live(
    const ['batches', 'stock_movements', 'products'],
    () => expiryRows(tenantId, today: today),
  );

  /// Active products with their stock and the last 30 days' net sales.
  Future<List<ReorderSuggestion>> reorderSuggestions(
    String tenantId, {
    required LedgerDate today,
    int coverDays = 30,
    int leadDays = 7,
  }) async {
    final since = today.addDays(-30).toString();
    final rows = await _db.getAll(
      'SELECT p.id, p.name, p.reorder_level_milli, COALESCE(s.stock, 0) AS '
      'stock, COALESCE(s.sold, 0) AS sold FROM products p LEFT JOIN ( '
      'SELECT product_id, SUM(qty_milli) AS stock, '
      "SUM(CASE WHEN reason IN ('sale', 'sale_return') AND entry_date >= ?2 "
      'AND entry_date <= ?3 THEN -qty_milli ELSE 0 END) AS sold '
      'FROM stock_movements WHERE tenant_id = ?1 GROUP BY product_id) s '
      'ON s.product_id = p.id '
      'WHERE p.tenant_id = ?1 AND p.deleted_at IS NULL AND p.is_active = 1',
      [tenantId, since, today.toString()],
    );
    return ReorderReport.suggest(
      [
        for (final r in rows)
          ReorderInput(
            productId: r['id']! as String,
            name: r['name']! as String,
            stockMilli: r['stock']! as int,
            reorderLevelMilli: r['reorder_level_milli']! as int,
            soldLast30Milli: r['sold']! as int,
          ),
      ],
      coverDays: coverDays,
      leadDays: leadDays,
    );
  }

  Stream<List<ReorderSuggestion>> watchReorderSuggestions(
    String tenantId, {
    required LedgerDate today,
  }) => live(
    const ['products', 'stock_movements'],
    () => reorderSuggestions(tenantId, today: today),
  );
}
