// SaleCalculator throws ArgumentError for an impossible discount; that is
// turned into a SaleInvalid result.
// ignore_for_file: avoid_catching_errors

import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/numbering/number_series_service.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/book_line_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/period_lock.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/products/data/stock_repository.dart';
import 'package:mandi_khata_app/features/shop_sales/data/sale_reader.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_settings.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart'
    show SqliteReadContext, SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Counter sales in the local database (offline-first).
///
/// [create] writes the bill, its lines (one per batch, FEFO), the stock
/// movements, the udhaar khata entry, the cash / UPI book lines, the journal
/// entry (sale + COGS) and every audit row in ONE local transaction. All maths
/// is khata_core. Every refusal happens before the first write.
class SaleRepository {
  SaleRepository(this._db, {this.planDefaults = const {}});

  final PowerSyncDatabase _db;
  final Map<String, Object?> planDefaults;

  /// Bills of [tenantId] matching [filter], newest first. Live.
  Stream<List<SaleRecord>> watchAll(String tenantId, SaleFilter filter) {
    final (sql, args) = SaleReader.listQuery(tenantId, filter);
    return _db
        .watch(sql, parameters: args, triggerOnTables: SaleReader.tables)
        .map((rows) => [for (final r in rows) SaleReader.record(r)]);
  }

  /// One bill with lines and returns. Live.
  Stream<SaleDetail?> watchOne(String tenantId, String id) => _db
      .watch('SELECT 1 AS x', triggerOnTables: SaleReader.tables)
      .asyncMap(
        (_) =>
            _db.readTransaction((tx) => SaleReader.detailIn(tx, tenantId, id)),
      );

  Future<SaleDetail?> detail(String tenantId, String id) =>
      _db.readTransaction((tx) => SaleReader.detailIn(tx, tenantId, id));

  /// The number the next bill on this device will get.
  Future<String> previewNextNo(WriteContext ctx) => _db.readTransaction(
    (tx) => NumberSeriesService.peek(tx, ctx, DocumentSeries.salesInvoice),
  );

  /// The settings of the business, resolved inside [tx].
  static Future<ShopSettings> settingsIn(
    SqliteReadContext tx,
    String tenantId, {
    Map<String, Object?> planDefaults = const {},
  }) async => ShopSettings.from(
    SettingsResolver(
      await SettingsRepository.rowsIn(tx, tenantId, businessTarget),
      planDefaults: planDefaults,
    ),
  );

  /// Problems with `draft` that need no database.
  static Set<SaleProblem> validate(SaleDraft d) {
    final p = <SaleProblem>{};
    if (d.lines.isEmpty) p.add(SaleProblem.noLines);
    for (final l in d.lines) {
      if (l.qtyMilli <= 0) p.add(SaleProblem.badQuantity);
      if (l.unitPrice.isNegative) p.add(SaleProblem.badPrice);
      if (l.lineDiscount.isNegative) p.add(SaleProblem.badDiscount);
    }
    final pay = d.payment;
    if (pay.cash.isNegative || pay.upi.isNegative || pay.udhaar.isNegative) {
      p.add(SaleProblem.negativePayment);
    }
    if (pay.udhaar.isPositive && (d.partyId == null || d.partyId!.isEmpty)) {
      p.add(SaleProblem.udhaarNeedsParty);
    }
    if (pay.upi.isPositive && d.upiAccountId == null) {
      p.add(SaleProblem.upiNeedsAccount);
    }
    return p;
  }

  Future<SaleSaveResult> create(
    WriteContext ctx,
    SaleDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.salesCreate)) {
      return const SaleNotPermitted(Permission.salesCreate);
    }
    final problems = validate(draft);
    if (problems.isNotEmpty) return SaleInvalid(problems);
    final when = now ?? DateTime.now();
    return await _db.writeTransaction(
      (tx) => _createIn(tx, ctx, draft, can: can, when: when),
    );
  }

  Future<SaleSaveResult> _createIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    SaleDraft draft, {
    required bool Function(Permission) can,
    required DateTime when,
  }) async {
    final date = draft.entryDate ?? LedgerDate.fromDateTime(when);
    final refused = await LedgerRepository.checkDate(
      tx,
      ctx,
      RefType.shopSale,
      date,
      can: can,
      now: when,
      planDefaults: planDefaults,
    );
    if (refused != null) {
      return SaleNotPermitted(
        refused.permission,
        backdateDays: refused.backdateDays,
        lockedYear: refused.lockedYear,
      );
    }
    final settings = await settingsIn(
      tx,
      ctx.tenantId,
      planDefaults: planDefaults,
    );

    Map<String, Object?>? party;
    if (draft.partyId != null) {
      party = await tx.getOptional(
        'SELECT id, name, gstin, state FROM parties '
        'WHERE tenant_id = ? AND id = ? AND deleted_at IS NULL',
        [ctx.tenantId, draft.partyId],
      );
      if (party == null) return const SaleNotFound();
    }
    final place = SupplyPlace.of(
      settings,
      customerGstin: party?['gstin'] as String?,
      customerState: party?['state'] as String?,
    );

    // Products.
    final products = <String, Map<String, Object?>>{};
    for (final l in draft.lines) {
      if (products.containsKey(l.productId)) continue;
      final p = await tx.getOptional(
        'SELECT id, name, hsn, gst_rate FROM products WHERE tenant_id = ? '
        'AND id = ? AND is_active = 1 AND deleted_at IS NULL',
        [ctx.tenantId, l.productId],
      );
      if (p == null) return const SaleInvalid({SaleProblem.productMissing});
      products[l.productId] = p;
    }

    // Totals.
    final SaleTotals totals;
    try {
      totals = SaleCalculator.compute(
        lines: [
          for (final l in draft.lines)
            CartLine(
              productId: l.productId,
              name: products[l.productId]!['name']! as String,
              qtyMilli: l.qtyMilli,
              unitPrice: l.unitPrice,
              lineDiscount: l.lineDiscount,
              rateBp: _rateBp(products[l.productId]!['gst_rate']),
              hsn: products[l.productId]!['hsn'] as String?,
            ),
        ],
        mode: settings.gstMode(interState: place.interState),
        discount: draft.discount,
        roundToRupee: settings.roundToRupee,
      );
    } on ArgumentError {
      return const SaleInvalid({SaleProblem.badDiscount});
    }
    final check = PaymentChecks.validate(
      total: totals.total,
      payment: draft.payment,
      partyId: draft.partyId,
    );
    if (!check.ok) {
      return SaleInvalid({
        for (final e in check.errors)
          switch (e) {
            PaymentIssue.negativeAmount => SaleProblem.negativePayment,
            PaymentIssue.udhaarNeedsParty => SaleProblem.udhaarNeedsParty,
            _ => SaleProblem.paymentMismatch,
          },
      });
    }
    String? upiId;
    if (draft.payment.upi.isPositive) {
      final bank = await tx.getOptional(
        'SELECT id FROM bank_accounts WHERE tenant_id = ? AND id = ? '
        "AND kind = 'bank' AND is_active = 1",
        [ctx.tenantId, draft.upiAccountId],
      );
      if (bank == null) return const SaleInvalid({SaleProblem.upiNeedsAccount});
      upiId = bank['id']! as String;
    }

    // FEFO per line; earlier lines of the same product use up batches.
    final used = <String, int>{};
    final soldParts = <List<SoldLine>>[];
    final allocs = <List<BatchAllocation>>[];
    final issues = <SaleStockIssue>[];
    final warnings = <StockWarning>[];
    final today = LedgerDate.fromDateTime(when);
    final batchCache = <String, List<StockBatch>>{};
    for (var i = 0; i < draft.lines.length; i++) {
      final l = draft.lines[i];
      final all = batchCache[l.productId] ??= await _batches(
        tx,
        ctx.tenantId,
        l.productId,
      );
      final avail = [
        for (final b in all)
          StockBatch(
            id: b.id,
            productId: b.productId,
            batchNo: b.batchNo,
            cost: b.cost,
            remainingMilli: b.remainingMilli - (used[b.id] ?? 0),
            createdAt: b.createdAt,
            expiry: b.expiry,
          ),
      ];
      final fefo = FefoPicker.pick(
        batches: avail,
        qtyMilli: l.qtyMilli,
        today: today,
        policy: settings.policy,
      );
      if (!fefo.canSell) {
        issues.add(SaleStockIssue(i, l.productId, fefo.error!));
        continue;
      }
      for (final a in fefo.allocations) {
        used.update(
          a.batchId,
          (v) => v + a.qtyMilli,
          ifAbsent: () => a.qtyMilli,
        );
      }
      warnings.addAll(fefo.warnings);
      allocs.add(fefo.allocations);
      soldParts.add(totals.lines[i].allocate(fefo.allocations));
    }
    if (issues.isNotEmpty) return SaleStockRefused(issues);

    // ---- from here on, only writes ----
    final id = const Uuid().v4();
    final saleNo = await NumberSeriesService.next(
      tx,
      ctx,
      DocumentSeries.salesInvoice,
      now: when,
    );
    final at = when.toUtc().toIso8601String();
    final pay = draft.payment;
    final pct = draft.discount.percentBp == null
        ? 0.0
        : draft.discount.percentBp! / 100;
    final customerName = party != null
        ? party['name'] as String?
        : _clean(draft.customerName);
    final gstin = party?['gstin'] as String?;
    final header = <String, Object?>{
      'sale_no': saleNo,
      'party_id': draft.partyId,
      'customer_name': customerName,
      'customer_gstin': gstin != null && GstStates.isValidGstin(gstin)
          ? gstin
          : null,
      'place_of_supply': place.code.isEmpty ? null : place.code,
      'tier': draft.tier,
      'entry_date': date.toString(),
      'subtotal_paise': totals.subtotal.paise,
      'discount_paise': totals.lineDiscounts.paise,
      'invoice_discount_pct': pct,
      'invoice_discount_paise': totals.invoiceDiscount.paise,
      'taxable_paise': totals.gst.taxable.paise,
      'cgst_paise': totals.gst.cgst.paise,
      'sgst_paise': totals.gst.sgst.paise,
      'igst_paise': totals.gst.igst.paise,
      'round_off_paise': totals.roundOff.paise,
      'total_paise': totals.total.paise,
      'paid_cash_paise': pay.cash.paise,
      'paid_upi_paise': pay.upi.paise,
      'paid_credit_paise': pay.udhaar.paise,
      'upi_account_id': upiId,
      'notes': _clean(draft.notes),
      'status': 'posted',
    };
    await tx.execute(
      'INSERT INTO shop_sales (id, tenant_id, ${header.keys.join(', ')}, '
      'device_id, created_by, created_at, updated_at) VALUES '
      '(${List.filled(header.length + 6, '?').join(', ')})',
      [id, ctx.tenantId, ...header.values, ctx.deviceId, ctx.userId, at, at],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'shop_sales',
      rowId: id,
      action: AuditAction.insert,
      after: {for (final e in header.entries) e.key: ?e.value},
      at: when,
    );

    var lineNo = 0;
    var cogs = Money.zero;
    for (var i = 0; i < draft.lines.length; i++) {
      final l = draft.lines[i];
      final res = totals.lines[i];
      final parts = soldParts[i];
      final weights = [for (final p in parts) p.qtyMilli];
      final lineDisc = ShopMath.apportion(l.lineDiscount.paise, weights);
      final invDisc = ShopMath.apportion(
        res.invoiceDiscountShare.paise,
        weights,
      );
      for (var k = 0; k < parts.length; k++) {
        final p = parts[k];
        final lineId = const Uuid().v4();
        final cols = <String, Object?>{
          'sale_id': id,
          'line_no': lineNo++,
          'product_id': p.productId,
          'batch_id': p.batchId,
          'qty_milli': p.qtyMilli,
          'unit_price_paise': l.unitPrice.paise,
          'tier': draft.tier,
          'discount_paise': lineDisc[k] + invDisc[k],
          'taxable_paise': p.split.taxable.paise,
          'gst_rate': (p.rateBp ?? 0) / 100,
          'cgst_paise': p.split.cgst.paise,
          'sgst_paise': p.split.sgst.paise,
          'igst_paise': p.split.igst.paise,
          'line_total_paise': p.split.total.paise,
          'hsn': p.hsn,
          'cost_paise': p.unitCost.paise,
        };
        await tx.execute(
          'INSERT INTO shop_sale_lines (id, tenant_id, '
          '${cols.keys.join(', ')}, '
          'created_by, created_at) VALUES '
          '(${List.filled(cols.length + 4, '?').join(', ')})',
          [lineId, ctx.tenantId, ...cols.values, ctx.userId, at],
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'shop_sale_lines',
          rowId: lineId,
          action: AuditAction.insert,
          after: {for (final e in cols.entries) e.key: ?e.value},
          at: when,
        );
        cogs += p.cost;
      }
    }
    // Movements after all lines (document first, then stock).
    for (final parts in soldParts) {
      for (final p in parts) {
        final mid = const Uuid().v4();
        await StockMovementWriter.insert(
          tx,
          ctx,
          id: mid,
          productId: p.productId,
          batchId: p.batchId,
          date: date,
          qtyMilli: -p.qtyMilli,
          reason: StockMovementReason.sale,
          refType: 'shop_sale',
          refId: id,
          at: when,
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'stock_movements',
          rowId: mid,
          action: AuditAction.insert,
          after: {
            'product_id': p.productId,
            'batch_id': p.batchId,
            'qty_milli': -p.qtyMilli,
            'reason': 'sale',
            'ref_id': id,
          },
          at: when,
        );
      }
    }

    if (pay.udhaar.isPositive) {
      await LedgerRepository.post(
        tx,
        ctx,
        LedgerDraft(
          partyId: draft.partyId!,
          side: Side.udhaar,
          amount: pay.udhaar,
          refType: RefType.shopSale,
          refId: id,
          entryDate: date,
          narration: saleNo,
        ),
        now: when,
      );
    }
    final cashId = BankAccountsRepository.cashIdFor(ctx.tenantId);
    final paid = <BookPayment>[];
    if (pay.cash.isPositive) {
      paid.add(BookPayment(cashId, pay.cash));
      await BookLineWriter.insert(
        tx,
        ctx,
        source: BookSource.shopSale,
        sourceId: id,
        accountId: cashId,
        accountKind: 'cash',
        entryDate: date,
        direction: BookDirection.moneyIn,
        amount: pay.cash,
        narration: saleNo,
        when: when,
      );
    }
    if (pay.upi.isPositive) {
      paid.add(BookPayment(upiId!, pay.upi));
      await BookLineWriter.insert(
        tx,
        ctx,
        source: BookSource.shopSale,
        sourceId: id,
        accountId: upiId,
        accountKind: 'bank',
        entryDate: date,
        direction: BookDirection.moneyIn,
        amount: pay.upi,
        narration: saleNo,
        when: when,
      );
    }
    final plan = ShopPosting.sale(
      saleId: id,
      date: date,
      totals: totals,
      paid: paid,
      cogs: cogs,
      udhaar: pay.udhaar,
      partyId: draft.partyId,
      invoiceNo: saleNo,
    );
    await JournalWriter.post(tx, ctx, plan.journal, now: when);
    return SaleSaved(id, saleNo, warnings: warnings);
  }

  /// Reverses a whole bill (needs `entries.reverse` and `sales.return`):
  /// khata entry, book lines, journal entry and stock are mirrored, and the
  /// bill is marked reversed. Refused when returns exist.
  Future<SaleSaveResult> reverse(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse)) {
      return const SaleNotPermitted(Permission.entriesReverse);
    }
    if (!can(Permission.salesReturn)) {
      return const SaleNotPermitted(Permission.salesReturn);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM shop_sales WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (row == null) return const SaleNotFound();
      if (row['status'] != 'posted') return const SaleLocked();
      final returns = await tx.getOptional(
        'SELECT 1 FROM shop_returns WHERE tenant_id = ? AND sale_id = ? '
        "AND status = 'posted'",
        [ctx.tenantId, id],
      );
      if (returns != null) return const SaleLocked();
      final date = LedgerDate.parse(row['entry_date']! as String);
      if (await PeriodLock.refuses(tx, ctx, date)) {
        return const SaleNotPermitted(Permission.adminManage, lockedYear: true);
      }
      final saleNo = row['sale_no']! as String;
      final entries = await tx.getAll(
        'SELECT e.id FROM ledger_entries e WHERE e.tenant_id = ? '
        'AND e.ref_id = ? AND e.ref_type = ? AND NOT EXISTS ( '
        'SELECT 1 FROM ledger_entries r WHERE r.tenant_id = e.tenant_id '
        'AND r.reverses_id = e.id) ORDER BY e.created_at, e.id',
        [ctx.tenantId, id, RefType.shopSale.dbName],
      );
      for (final e in entries) {
        await LedgerRepository.reverseIn(
          tx,
          ctx,
          e['id']! as String,
          narration: saleNo,
          now: when,
        );
      }
      await BookLineWriter.reverseAll(
        tx,
        ctx,
        source: BookSource.shopSale,
        sourceId: id,
        narration: saleNo,
        when: when,
      );
      await JournalWriter.reverse(
        tx,
        ctx,
        'shop_sale:$id',
        narration: saleNo,
        now: when,
      );
      final moves = await tx.getAll(
        'SELECT product_id, batch_id, qty_milli FROM stock_movements '
        "WHERE tenant_id = ? AND ref_type = 'shop_sale' AND ref_id = ? "
        "AND reason = 'sale'",
        [ctx.tenantId, id],
      );
      for (final m in moves) {
        final mid = const Uuid().v4();
        await StockMovementWriter.insert(
          tx,
          ctx,
          id: mid,
          productId: m['product_id']! as String,
          batchId: m['batch_id'] as String?,
          date: date,
          qtyMilli: -(m['qty_milli']! as int),
          reason: StockMovementReason.saleReturn,
          refType: 'shop_sale',
          refId: id,
          note: 'reversal',
          at: when,
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'stock_movements',
          rowId: mid,
          action: AuditAction.reverse,
          after: {'ref_id': id, 'qty_milli': -(m['qty_milli']! as int)},
          at: when,
        );
      }
      final at = when.toUtc().toIso8601String();
      await tx.execute(
        "UPDATE shop_sales SET status = 'reversed', reversed_at = ?, "
        'updated_at = ? WHERE tenant_id = ? AND id = ?',
        [at, at, ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'shop_sales',
        rowId: id,
        action: AuditAction.reverse,
        before: {'status': 'posted'},
        after: {'status': 'reversed'},
        at: when,
      );
      return SaleSaved(id, saleNo);
    });
  }

  static int? _rateBp(Object? rate) =>
      rate is num ? (rate.toDouble() * 100).round() : null;

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  /// Every batch of [productId] with what is left (Σ movements).
  static Future<List<StockBatch>> _batches(
    SqliteReadContext tx,
    String tenantId,
    String productId,
  ) async {
    final rows = await tx.getAll(
      'SELECT b.id, b.batch_no, b.expiry_date, b.cost_paise, b.created_at, '
      'COALESCE((SELECT SUM(m.qty_milli) FROM stock_movements m '
      'WHERE m.tenant_id = b.tenant_id AND m.batch_id = b.id), 0) AS remaining '
      'FROM batches b WHERE b.tenant_id = ? AND b.product_id = ?',
      [tenantId, productId],
    );
    return [
      for (final r in rows)
        StockBatch(
          id: r['id']! as String,
          productId: productId,
          batchNo: r['batch_no']! as String,
          cost: Money(r['cost_paise']! as int),
          remainingMilli: r['remaining']! as int,
          createdAt:
              DateTime.tryParse((r['created_at'] as String?) ?? '')?.toUtc() ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          expiry: (r['expiry_date'] as String?) == null
              ? null
              : LedgerDate.parse(r['expiry_date']! as String),
        ),
    ];
  }
}

/// Used by tests and screens to print a draft's JSON (held bills).
String encodeJson(Object? v) => jsonEncode(v);
