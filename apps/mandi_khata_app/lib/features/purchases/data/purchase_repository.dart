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
import 'package:mandi_khata_app/features/purchases/domain/purchase.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart'
    show SqliteReadContext, SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Purchases from suppliers, in the local database (step 4.2,
/// docs/domain/posting-rules.md section 12 rows 19 and 20).
///
/// One purchase is written in ONE local transaction, in the order the
/// server needs: the document header (it opens the window in which its
/// lines may join), batches (new, or more stock into an existing batch of
/// the same product and batch no), lines, stock movements (reason
/// `purchase`), the supplier's khata jama for the unpaid part, the cash /
/// bank book line for the part paid now, the journal entry, audit rows.
///
/// Stock is the sum of `stock_movements`; this class never writes the
/// `batches.qty_milli` cache (the server keeps it).
class PurchaseRepository {
  PurchaseRepository(this._db, {this.planDefaults = const {}});

  final PowerSyncDatabase _db;
  final Map<String, Object?> planDefaults;

  static const _supplierRoles = ['supplier', 'agency'];

  // -- create ----------------------------------------------------------------

  /// The number the next purchase on this device will get.
  Future<String> previewNextNo(WriteContext ctx) => _db.readTransaction(
    (tx) => NumberSeriesService.peek(tx, ctx, DocumentSeries.purchaseBill),
  );

  /// Records a supplier invoice (needs `purchases.create`; `finance.view`
  /// when part of it is paid from a bank account).
  Future<PurchaseResult> create(
    WriteContext ctx,
    PurchaseDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    if (!can(Permission.purchasesCreate)) {
      return const PurchaseNotPermitted(Permission.purchasesCreate);
    }
    if (draft.paid.isPositive &&
        !draft.paidInCash &&
        !can(Permission.financeView)) {
      return const PurchaseNotPermitted(Permission.financeView);
    }
    final problems = _validate(draft);
    if (problems.isNotEmpty) return PurchaseInvalid(problems);
    return await _db.writeTransaction(
      (tx) => _createIn(tx, ctx, draft, can: can, when: when),
    );
  }

  static List<PurchaseProblem> _validate(PurchaseDraft d) => [
    if (d.supplierId.isEmpty) PurchaseProblem.noSupplier,
    if (d.lines.isEmpty) PurchaseProblem.noLines,
    if (d.lines.any((l) => l.qtyMilli <= 0 || l.unitCost.isNegative))
      PurchaseProblem.badLine,
    if (d.lines.any((l) => l.batchNo.trim().isEmpty)) PurchaseProblem.noBatchNo,
    if (d.lines.any(
      (l) => l.mfgDate != null && l.expiry != null && l.expiry! < l.mfgDate!,
    ))
      PurchaseProblem.badDates,
    if (d.freight.isNegative || d.otherCharges.isNegative)
      PurchaseProblem.negativeCharges,
    if (d.paid.isNegative) PurchaseProblem.negativePaid,
    if (d.paid.isPositive && !d.paidInCash && d.bankAccountId == null)
      PurchaseProblem.noBankAccount,
  ];

  Future<PurchaseResult> _createIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    PurchaseDraft draft, {
    required bool Function(Permission) can,
    required DateTime when,
  }) async {
    final date = draft.date ?? LedgerDate.fromDateTime(when);
    final refused = await LedgerRepository.checkDate(
      tx,
      ctx,
      RefType.purchase,
      date,
      can: can,
      now: when,
      planDefaults: planDefaults,
    );
    if (refused != null) {
      return PurchaseNotPermitted(
        refused.permission,
        backdateDays: refused.backdateDays,
        lockedYear: refused.lockedYear,
      );
    }

    final supplier = await _supplier(tx, ctx.tenantId, draft.supplierId);
    if (supplier == null) {
      return const PurchaseInvalid([PurchaseProblem.noSupplier]);
    }
    if (!supplier.isSupplier) {
      return const PurchaseInvalid([PurchaseProblem.notASupplier]);
    }
    for (final l in draft.lines) {
      final product = await tx.getOptional(
        'SELECT 1 FROM products WHERE tenant_id = ? AND id = ? '
        'AND deleted_at IS NULL',
        [ctx.tenantId, l.productId],
      );
      if (product == null) {
        return const PurchaseInvalid([PurchaseProblem.unknownProduct]);
      }
    }
    final String? bookAccountId;
    if (draft.paid.isPositive) {
      bookAccountId = await _bookAccount(
        tx,
        ctx.tenantId,
        isCash: draft.paidInCash,
        bankAccountId: draft.bankAccountId,
      );
      if (bookAccountId == null) {
        return const PurchaseInvalid([PurchaseProblem.noBankAccount]);
      }
    } else {
      bookAccountId = null;
    }

    final settings = SettingsResolver(
      await SettingsRepository.rowsIn(tx, ctx.tenantId, businessTarget),
      planDefaults: planDefaults,
    );
    final gstEnabled = settings.resolve('shop.gst_enabled').value! as bool;
    final tenantState =
        (settings.resolve('business.state_code').value as String?) ?? '';
    final supplierState = supplier.gstin == null
        ? null
        : GstStates.stateOfGstin(supplier.gstin!);
    final interState =
        tenantState.isNotEmpty &&
        supplierState != null &&
        supplierState != tenantState;
    final creditDays =
        draft.creditDays ??
        settings.resolve('shop.supplier_credit_days').value! as int;

    final PurchaseTotals totals;
    try {
      totals = PurchaseRules.compute(
        lines: [
          for (final l in draft.lines)
            PurchaseLine(
              productId: l.productId,
              batchNo: l.batchNo.trim(),
              qtyMilli: l.qtyMilli,
              unitCost: l.unitCost,
              rateBp: l.rateBp,
              hsn: l.hsn,
              mfgDate: l.mfgDate,
              expiry: l.expiry,
            ),
        ],
        mode: GstMode(
          enabled: gstEnabled,
          pricesIncludeGst: false,
          interState: interState,
        ),
        freight: draft.freight,
        otherCharges: draft.otherCharges,
        roundOff: draft.roundOff,
      );
      // PurchaseRules signals bad input with ArgumentError.
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return const PurchaseInvalid([PurchaseProblem.badLine]);
    }
    final settlement = PurchaseRules.settle(
      total: totals.total,
      paidNow: draft.paid,
      supplierId: draft.supplierId,
    );
    if (!settlement.ok) {
      return PurchaseInvalid([
        for (final e in settlement.errors)
          switch (e) {
            PurchaseIssue.noLines => PurchaseProblem.noLines,
            PurchaseIssue.negativePaid => PurchaseProblem.negativePaid,
            PurchaseIssue.paidAboveTotal => PurchaseProblem.paidAboveTotal,
            PurchaseIssue.noSupplier => PurchaseProblem.noSupplier,
          },
      ]);
    }

    final id = const Uuid().v4();
    final no = await NumberSeriesService.next(
      tx,
      ctx,
      DocumentSeries.purchaseBill,
      now: when,
    );
    final at = when.toUtc().toIso8601String();
    final dueDate = settlement.unpaid.isPositive
        ? PurchaseRules.dueDate(draft.invoiceDate, creditDays)
        : null;
    final invoiceNo = _clean(draft.supplierInvoiceNo);

    // 1. The document first: it opens the window for its lines.
    final header = <String, Object?>{
      'purchase_no': no,
      'party_id': draft.supplierId,
      'supplier_invoice_no': invoiceNo,
      'invoice_date': draft.invoiceDate.toString(),
      'entry_date': date.toString(),
      'freight_paise': totals.freight.paise,
      'other_charges_paise': totals.otherCharges.paise,
      'taxable_paise': totals.gst.taxable.paise,
      'gst_paise': totals.gst.tax.paise,
      'round_off_paise': totals.roundOff.paise,
      'total_paise': totals.total.paise,
      'paid_paise': draft.paid.paise,
      'payment_mode': draft.paid.isPositive
          ? (draft.paidInCash ? 'cash' : 'bank')
          : null,
      'bank_account_id': bookAccountId,
      'credit_days': creditDays,
      'due_date': dueDate?.toString(),
      'notes': _clean(draft.notes),
      'status': 'posted',
    };
    await tx.execute(
      'INSERT INTO purchases (id, tenant_id, ${header.keys.join(', ')}, '
      'device_id, created_by, created_at, updated_at) '
      'VALUES (${List.filled(header.length + 6, '?').join(', ')})',
      [id, ctx.tenantId, ...header.values, ctx.deviceId, ctx.userId, at, at],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'purchases',
      rowId: id,
      action: AuditAction.insert,
      after: {for (final MapEntry(:key, :value) in header.entries) key: ?value},
      at: when,
    );

    // 2. Batches, 3. lines, 4. stock movements.
    final batchIds = <String>[];
    for (final r in totals.lines) {
      batchIds.add(await _batchFor(tx, ctx, r, when));
    }
    for (var i = 0; i < totals.lines.length; i++) {
      final r = totals.lines[i];
      final l = r.line;
      final lineId = const Uuid().v4();
      final rateBp = gstEnabled ? (l.rateBp ?? 0) : 0;
      final line = <String, Object?>{
        'purchase_id': id,
        'line_no': i,
        'product_id': l.productId,
        'batch_id': batchIds[i],
        'batch_no': l.batchNo,
        'mfg_date': l.mfgDate?.toString(),
        'expiry_date': l.expiry?.toString(),
        'qty_milli': l.qtyMilli,
        'cost_paise': l.unitCost.paise,
        'gst_rate': rateBp / 100,
        'taxable_paise': r.split.taxable.paise,
        'gst_paise': r.split.tax.paise,
        'line_total_paise': r.split.total.paise,
      };
      await tx.execute(
        'INSERT INTO purchase_lines (id, tenant_id, ${line.keys.join(', ')}, '
        'created_by, created_at) '
        'VALUES (${List.filled(line.length + 4, '?').join(', ')})',
        [lineId, ctx.tenantId, ...line.values, ctx.userId, at],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'purchase_lines',
        rowId: lineId,
        action: AuditAction.insert,
        after: {for (final MapEntry(:key, :value) in line.entries) key: ?value},
        at: when,
      );
      await _movement(
        tx,
        ctx,
        productId: l.productId,
        batchId: batchIds[i],
        date: date,
        qtyMilli: l.qtyMilli,
        reason: StockMovementReason.purchase,
        refType: 'purchase',
        refId: id,
        when: when,
      );
    }

    // 5. Journal (row 19), supplier khata, cash / bank book.
    final plan = ShopPosting.purchase(
      purchaseId: id,
      date: date,
      totals: totals,
      supplierId: draft.supplierId,
      paid: [if (bookAccountId != null) BookPayment(bookAccountId, draft.paid)],
      billNo: no,
    );
    final khata = plan.khata;
    if (khata != null) {
      await LedgerRepository.post(
        tx,
        ctx,
        LedgerDraft(
          partyId: khata.partyId,
          side: khata.side,
          amount: khata.amount,
          refType: khata.refType,
          refId: id,
          entryDate: date,
          narration: [no, ?invoiceNo].join(' · '),
        ),
        now: when,
      );
    }
    if (bookAccountId != null) {
      await BookLineWriter.insert(
        tx,
        ctx,
        source: BookSource.purchase,
        sourceId: id,
        accountId: bookAccountId,
        accountKind: draft.paidInCash ? 'cash' : 'bank',
        entryDate: date,
        direction: BookDirection.moneyOut,
        amount: draft.paid,
        narration: no,
        when: when,
      );
    }
    await JournalWriter.post(tx, ctx, plan.journal, now: when);
    return PurchaseSaved(id, no, dueDate: dueDate);
  }

  /// The batch a line adds stock to: the existing batch of the same product
  /// and batch no (its cost becomes the weighted average of what is in it
  /// and what arrives), else a new one at the line's landed unit cost.
  Future<String> _batchFor(
    SqliteWriteContext tx,
    WriteContext ctx,
    PurchaseLineResult r,
    DateTime when,
  ) async {
    final l = r.line;
    final at = when.toUtc().toIso8601String();
    final existing = await tx.getOptional(
      'SELECT * FROM batches WHERE tenant_id = ? AND product_id = ? '
      'AND batch_no = ?',
      [ctx.tenantId, l.productId, l.batchNo],
    );
    if (existing == null) {
      final id = const Uuid().v4();
      final values = <String, Object?>{
        'product_id': l.productId,
        'batch_no': l.batchNo,
        'mfg_date': l.mfgDate?.toString(),
        'expiry_date': l.expiry?.toString(),
        'cost_paise': r.landedUnitCost.paise,
        // A cache the server maintains from the movements.
        'qty_milli': 0,
      };
      await tx.execute(
        'INSERT INTO batches (id, tenant_id, ${values.keys.join(', ')}, '
        'created_by, created_at, updated_at) '
        'VALUES (${List.filled(values.length + 5, '?').join(', ')})',
        [id, ctx.tenantId, ...values.values, ctx.userId, at, at],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'batches',
        rowId: id,
        action: AuditAction.insert,
        after: {
          for (final MapEntry(:key, :value) in values.entries) key: ?value,
        },
        at: when,
      );
      return id;
    }
    final id = existing['id']! as String;
    final inStock = await _batchStock(tx, ctx.tenantId, id);
    final oldCost = existing['cost_paise']! as int;
    final int newCost;
    if (inStock > 0) {
      final oldValue = ShopMath.mulDivRound(oldCost, inStock, 1000);
      newCost = ShopMath.mulDivRound(
        oldValue + r.landed.paise,
        1000,
        inStock + l.qtyMilli,
      );
    } else {
      newCost = r.landedUnitCost.paise;
    }
    final mfg = existing['mfg_date'] ?? l.mfgDate?.toString();
    final expiry = existing['expiry_date'] ?? l.expiry?.toString();
    if (newCost != oldCost ||
        mfg != existing['mfg_date'] ||
        expiry != existing['expiry_date']) {
      await tx.execute(
        'UPDATE batches SET cost_paise = ?, mfg_date = ?, expiry_date = ?, '
        'updated_at = ? WHERE tenant_id = ? AND id = ?',
        [newCost, mfg, expiry, at, ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'batches',
        rowId: id,
        action: AuditAction.update,
        before: {
          'cost_paise': oldCost,
          'mfg_date': ?existing['mfg_date'],
          'expiry_date': ?existing['expiry_date'],
        },
        after: {
          'cost_paise': newCost,
          'mfg_date': ?mfg,
          'expiry_date': ?expiry,
        },
        at: when,
      );
    }
    return id;
  }

  static Future<int> _batchStock(
    SqliteReadContext tx,
    String tenantId,
    String batchId,
  ) async =>
      (await tx.get(
            'SELECT COALESCE(SUM(qty_milli), 0) AS n FROM stock_movements '
            'WHERE tenant_id = ? AND batch_id = ?',
            [tenantId, batchId],
          ))['n']!
          as int;

  static Future<void> _movement(
    SqliteWriteContext tx,
    WriteContext ctx, {
    required String productId,
    required String batchId,
    required LedgerDate date,
    required int qtyMilli,
    required StockMovementReason reason,
    required String refType,
    required String refId,
    required DateTime when,
    String? note,
  }) async {
    // Throws for a quantity the reason does not accept.
    StockMovement(
      productId: productId,
      batchId: batchId,
      qtyMilli: qtyMilli,
      reason: reason,
    );
    final id = const Uuid().v4();
    final at = when.toUtc().toIso8601String();
    await tx.execute(
      'INSERT INTO stock_movements (id, tenant_id, product_id, batch_id, '
      'entry_date, qty_milli, reason, ref_type, ref_id, note, device_id, '
      'created_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        ctx.tenantId,
        productId,
        batchId,
        date.toString(),
        qtyMilli,
        reason.dbName,
        refType,
        refId,
        note,
        ctx.deviceId,
        ctx.userId,
        at,
      ],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'stock_movements',
      rowId: id,
      action: AuditAction.insert,
      after: {
        'product_id': productId,
        'batch_id': batchId,
        'qty_milli': qtyMilli,
        'reason': reason.dbName,
        'ref_type': refType,
        'ref_id': refId,
        'entry_date': date.toString(),
      },
      at: when,
    );
  }

  Future<({bool isSupplier, String? gstin})?> _supplier(
    SqliteReadContext tx,
    String tenantId,
    String partyId,
  ) async {
    final party = await tx.getOptional(
      'SELECT gstin FROM parties WHERE tenant_id = ? AND id = ? '
      'AND deleted_at IS NULL',
      [tenantId, partyId],
    );
    if (party == null) return null;
    final roles = await tx.getAll(
      'SELECT role FROM party_roles WHERE party_id = ? AND deleted_at IS NULL',
      [partyId],
    );
    return (
      isSupplier: roles.any((r) => _supplierRoles.contains(r['role'])),
      gstin: party['gstin'] as String?,
    );
  }

  static Future<String?> _bookAccount(
    SqliteReadContext tx,
    String tenantId, {
    required bool isCash,
    required String? bankAccountId,
  }) async {
    if (isCash) return BankAccountsRepository.cashIdFor(tenantId);
    final account = await tx.getOptional(
      'SELECT id FROM bank_accounts WHERE tenant_id = ? AND id = ? '
      "AND kind = 'bank' AND is_active = 1",
      [tenantId, bankAccountId],
    );
    return account?['id'] as String?;
  }

  // -- reverse ---------------------------------------------------------------

  /// Cancels a purchase (needs `entries.reverse` and `purchases.create`):
  /// stock movements, journal, supplier khata and book line are mirrored,
  /// the header becomes `reversed`. Refused once a part was returned or
  /// sold (reverse the return first / the stock is gone).
  Future<PurchaseResult> reverse(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    for (final p in [Permission.entriesReverse, Permission.purchasesCreate]) {
      if (!can(p)) return PurchaseNotPermitted(p);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM purchases WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (row == null) return const PurchaseNotFound();
      if (row['status'] != 'posted') return const PurchaseLocked();
      final date = LedgerDate.parse(row['entry_date']! as String);
      if (await PeriodLock.refuses(tx, ctx, date)) {
        return const PurchaseNotPermitted(
          Permission.adminManage,
          lockedYear: true,
        );
      }
      if (row['payment_mode'] == 'bank' && !can(Permission.financeView)) {
        return const PurchaseNotPermitted(Permission.financeView);
      }
      final returns = await tx.getOptional(
        'SELECT 1 FROM purchase_returns WHERE tenant_id = ? '
        "AND purchase_id = ? AND status = 'posted'",
        [ctx.tenantId, id],
      );
      if (returns != null) return const PurchaseInUse();
      final lines = await tx.getAll(
        'SELECT * FROM purchase_lines WHERE tenant_id = ? AND purchase_id = ? '
        'ORDER BY line_no',
        [ctx.tenantId, id],
      );
      final need = <String, int>{};
      for (final l in lines) {
        need.update(
          l['batch_id']! as String,
          (v) => v + (l['qty_milli']! as int),
          ifAbsent: () => l['qty_milli']! as int,
        );
      }
      for (final MapEntry(:key, :value) in need.entries) {
        if (await _batchStock(tx, ctx.tenantId, key) < value) {
          return const PurchaseInUse();
        }
      }
      final no = row['purchase_no']! as String;
      for (final l in lines) {
        await _movement(
          tx,
          ctx,
          productId: l['product_id']! as String,
          batchId: l['batch_id']! as String,
          date: date,
          qtyMilli: -(l['qty_milli']! as int),
          reason: StockMovementReason.purchaseReturn,
          refType: 'purchase',
          refId: id,
          note: 'Reversal of $no',
          when: when,
        );
      }
      await JournalWriter.reverse(
        tx,
        ctx,
        'purchase:$id',
        narration: no,
        now: when,
      );
      final khata = await tx.getOptional(
        'SELECT id FROM ledger_entries WHERE tenant_id = ? '
        "AND ref_type = 'purchase' AND ref_id = ? AND reverses_id IS NULL",
        [ctx.tenantId, id],
      );
      if (khata != null) {
        await LedgerRepository.reverseIn(
          tx,
          ctx,
          khata['id']! as String,
          narration: no,
          now: when,
        );
      }
      await BookLineWriter.reverseAll(
        tx,
        ctx,
        source: BookSource.purchase,
        sourceId: id,
        narration: no,
        when: when,
      );
      final at = when.toUtc().toIso8601String();
      await tx.execute(
        "UPDATE purchases SET status = 'reversed', reversed_at = ?, "
        'updated_at = ? WHERE tenant_id = ? AND id = ?',
        [at, at, ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'purchases',
        rowId: id,
        action: AuditAction.reverse,
        before: {'status': 'posted'},
        after: {'status': 'reversed'},
        at: when,
      );
      return PurchaseSaved(id, no);
    });
  }

  // -- purchase return -------------------------------------------------------

  /// The number the next purchase return on this device will get.
  Future<String> previewNextReturnNo(WriteContext ctx) => _db.readTransaction(
    (tx) => NumberSeriesService.peek(tx, ctx, DocumentSeries.purchaseReturn),
  );

  /// Sends goods back to the supplier, to the ORIGINAL batch (needs
  /// `purchases.create`). The refund (stock value + input tax) is split
  /// between a credit note on the supplier's khata (udhaar) and money back
  /// in cash / bank by [PurchaseReturnDraft.choice].
  Future<PurchaseResult> createReturn(
    WriteContext ctx,
    PurchaseReturnDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    if (!can(Permission.purchasesCreate)) {
      return const PurchaseNotPermitted(Permission.purchasesCreate);
    }
    if (draft.lines.isEmpty) {
      return const PurchaseReturnInvalid([
        ReturnLineIssue(0, ReturnIssue.lineNotFound),
      ]);
    }
    return await _db.writeTransaction(
      (tx) => _returnIn(tx, ctx, draft, can: can, when: when),
    );
  }

  Future<PurchaseResult> _returnIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    PurchaseReturnDraft draft, {
    required bool Function(Permission) can,
    required DateTime when,
  }) async {
    final purchase = await tx.getOptional(
      'SELECT * FROM purchases WHERE tenant_id = ? AND id = ?',
      [ctx.tenantId, draft.purchaseId],
    );
    if (purchase == null) return const PurchaseNotFound();
    if (purchase['status'] != 'posted') return const PurchaseLocked();
    final date = draft.date ?? LedgerDate.fromDateTime(when);
    final refused = await LedgerRepository.checkDate(
      tx,
      ctx,
      RefType.purchaseReturn,
      date,
      can: can,
      now: when,
      planDefaults: planDefaults,
    );
    if (refused != null) {
      return PurchaseNotPermitted(
        refused.permission,
        backdateDays: refused.backdateDays,
        lockedYear: refused.lockedYear,
      );
    }
    final supplierId = purchase['party_id']! as String;
    final bought = await _loadBought(tx, ctx.tenantId, purchase);

    // Requests in terms of the line list.
    final requests = <ReturnRequest>[];
    for (final r in draft.lines) {
      final index = bought.lineIds.indexOf(r.purchaseLineId);
      requests.add(ReturnRequest(index, r.qtyMilli));
    }
    final issues = <ReturnLineIssue>[
      ...PurchaseRules.validateReturn(bought.lines, requests),
    ];
    // Two lines of one batch together may not take more than is in it.
    final perBatch = <String, int>{};
    for (final r in requests) {
      if (r.lineIndex < 0 || r.lineIndex >= bought.lines.length) continue;
      final batch = bought.lines[r.lineIndex].batchId;
      final sum = perBatch.update(
        batch,
        (v) => v + r.qtyMilli,
        ifAbsent: () => r.qtyMilli,
      );
      if (sum > bought.lines[r.lineIndex].batchRemainingMilli &&
          !issues.any((i) => i.index == r.lineIndex)) {
        issues.add(ReturnLineIssue(r.lineIndex, ReturnIssue.exceedsBatchStock));
      }
    }
    if (issues.isNotEmpty) return PurchaseReturnInvalid(issues);
    final result = PurchaseRules.computeReturn(bought.lines, requests);

    // Credit up to what is still unpaid on this very bill.
    final owed = await _outstandingOf(tx, ctx.tenantId, draft.purchaseId, date);
    final settlement = ReturnSettlement.split(
      refund: result.refund,
      choice: draft.choice,
      hasParty: true,
      unpaidOnBill: owed,
    );
    if (!settlement.ok) {
      return const PurchaseReturnInvalid([
        ReturnLineIssue(0, ReturnIssue.noParty),
      ]);
    }
    String? bookAccountId;
    if (settlement.cash.isPositive) {
      if (!draft.refundInCash && !can(Permission.financeView)) {
        return const PurchaseNotPermitted(Permission.financeView);
      }
      bookAccountId = await _bookAccount(
        tx,
        ctx.tenantId,
        isCash: draft.refundInCash,
        bankAccountId: draft.bankAccountId,
      );
      if (bookAccountId == null) {
        return const PurchaseInvalid([PurchaseProblem.noBankAccount]);
      }
    }

    final id = const Uuid().v4();
    final no = await NumberSeriesService.next(
      tx,
      ctx,
      DocumentSeries.purchaseReturn,
      now: when,
    );
    final at = when.toUtc().toIso8601String();
    // total = taxable + gst + round_off: the share of freight and other
    // charges that comes back with the stock rides in round_off_paise.
    final charges = result.stockValue - result.split.taxable;
    final header = <String, Object?>{
      'return_no': no,
      'purchase_id': draft.purchaseId,
      'party_id': supplierId,
      'entry_date': date.toString(),
      'taxable_paise': result.split.taxable.paise,
      'gst_paise': result.split.tax.paise,
      'round_off_paise': charges.paise,
      'total_paise': result.refund.paise,
      'refund_khata_paise': settlement.khata.paise,
      'refund_paid_paise': settlement.cash.paise,
      'payment_mode': settlement.cash.isPositive
          ? (draft.refundInCash ? 'cash' : 'bank')
          : null,
      'bank_account_id': bookAccountId,
      'note': _clean(draft.note),
      'status': 'posted',
    };
    await tx.execute(
      'INSERT INTO purchase_returns (id, tenant_id, ${header.keys.join(', ')}, '
      'device_id, created_by, created_at, updated_at) '
      'VALUES (${List.filled(header.length + 6, '?').join(', ')})',
      [id, ctx.tenantId, ...header.values, ctx.deviceId, ctx.userId, at, at],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'purchase_returns',
      rowId: id,
      action: AuditAction.insert,
      after: {for (final MapEntry(:key, :value) in header.entries) key: ?value},
      at: when,
    );
    for (var i = 0; i < result.lines.length; i++) {
      final r = result.lines[i];
      final src = bought.rows[r.lineIndex];
      final lineId = const Uuid().v4();
      final line = <String, Object?>{
        'purchase_return_id': id,
        'line_no': i,
        'purchase_line_id': src['id'],
        'product_id': src['product_id'],
        'batch_id': src['batch_id'],
        'qty_milli': r.qtyMilli,
        'cost_paise': src['cost_paise'],
        'taxable_paise': r.split.taxable.paise,
        'gst_paise': r.split.tax.paise,
        'line_total_paise': r.split.total.paise,
      };
      await tx.execute(
        'INSERT INTO purchase_return_lines (id, tenant_id, '
        '${line.keys.join(', ')}, created_by, created_at) '
        'VALUES (${List.filled(line.length + 4, '?').join(', ')})',
        [lineId, ctx.tenantId, ...line.values, ctx.userId, at],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'purchase_return_lines',
        rowId: lineId,
        action: AuditAction.insert,
        after: {for (final MapEntry(:key, :value) in line.entries) key: ?value},
        at: when,
      );
      await _movement(
        tx,
        ctx,
        productId: src['product_id']! as String,
        batchId: src['batch_id']! as String,
        date: date,
        qtyMilli: -r.qtyMilli,
        reason: StockMovementReason.purchaseReturn,
        refType: 'purchase_return',
        refId: id,
        when: when,
      );
    }
    final plan = ShopPosting.purchaseReturn(
      returnId: id,
      date: date,
      result: result,
      settlement: settlement,
      received: [
        if (bookAccountId != null) BookPayment(bookAccountId, settlement.cash),
      ],
      supplierId: supplierId,
      returnNo: no,
    );
    final khata = plan.khata;
    if (khata != null) {
      await LedgerRepository.post(
        tx,
        ctx,
        LedgerDraft(
          partyId: khata.partyId,
          side: khata.side,
          amount: khata.amount,
          refType: khata.refType,
          refId: id,
          entryDate: date,
          narration: '$no · ${purchase['purchase_no']}',
        ),
        now: when,
      );
    }
    if (bookAccountId != null) {
      await BookLineWriter.insert(
        tx,
        ctx,
        source: BookSource.purchaseReturn,
        sourceId: id,
        accountId: bookAccountId,
        accountKind: draft.refundInCash ? 'cash' : 'bank',
        entryDate: date,
        direction: BookDirection.moneyIn,
        amount: settlement.cash,
        narration: no,
        when: when,
      );
    }
    await JournalWriter.post(tx, ctx, plan.journal, now: when);
    return PurchaseSaved(id, no);
  }

  /// Reverses a purchase return (needs `entries.reverse` and
  /// `purchases.create`): the goods go back into their batch.
  Future<PurchaseResult> reverseReturn(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    for (final p in [Permission.entriesReverse, Permission.purchasesCreate]) {
      if (!can(p)) return PurchaseNotPermitted(p);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM purchase_returns WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (row == null) return const PurchaseNotFound();
      if (row['status'] != 'posted') return const PurchaseLocked();
      final date = LedgerDate.parse(row['entry_date']! as String);
      if (await PeriodLock.refuses(tx, ctx, date)) {
        return const PurchaseNotPermitted(
          Permission.adminManage,
          lockedYear: true,
        );
      }
      if (row['payment_mode'] == 'bank' && !can(Permission.financeView)) {
        return const PurchaseNotPermitted(Permission.financeView);
      }
      final no = row['return_no']! as String;
      final lines = await tx.getAll(
        'SELECT * FROM purchase_return_lines WHERE tenant_id = ? '
        'AND purchase_return_id = ? ORDER BY line_no',
        [ctx.tenantId, id],
      );
      for (final l in lines) {
        await _movement(
          tx,
          ctx,
          productId: l['product_id']! as String,
          batchId: l['batch_id']! as String,
          date: date,
          qtyMilli: l['qty_milli']! as int,
          reason: StockMovementReason.purchase,
          refType: 'purchase_return',
          refId: id,
          when: when,
        );
      }
      await JournalWriter.reverse(
        tx,
        ctx,
        'purchase_return:$id',
        narration: no,
        now: when,
      );
      final khata = await tx.getOptional(
        'SELECT id FROM ledger_entries WHERE tenant_id = ? '
        "AND ref_type = 'purchase_return' AND ref_id = ? "
        'AND reverses_id IS NULL',
        [ctx.tenantId, id],
      );
      if (khata != null) {
        await LedgerRepository.reverseIn(
          tx,
          ctx,
          khata['id']! as String,
          narration: no,
          now: when,
        );
      }
      await BookLineWriter.reverseAll(
        tx,
        ctx,
        source: BookSource.purchaseReturn,
        sourceId: id,
        narration: no,
        when: when,
      );
      final at = when.toUtc().toIso8601String();
      await tx.execute(
        "UPDATE purchase_returns SET status = 'reversed', reversed_at = ?, "
        'updated_at = ? WHERE tenant_id = ? AND id = ?',
        [at, at, ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'purchase_returns',
        rowId: id,
        action: AuditAction.reverse,
        before: {'status': 'posted'},
        after: {'status': 'reversed'},
        at: when,
      );
      return PurchaseSaved(id, no);
    });
  }

  /// The lines of [purchase] as `khata_core` needs them for a return:
  /// landed value per line (taxable + its share of freight and other
  /// charges), earlier returns replayed in order, stock left in the batch.
  Future<_Bought> _loadBought(
    SqliteReadContext tx,
    String tenantId,
    Map<String, Object?> purchase,
  ) async {
    final id = purchase['id']! as String;
    final rows = await tx.getAll(
      'SELECT * FROM purchase_lines WHERE tenant_id = ? AND purchase_id = ? '
      'ORDER BY line_no',
      [tenantId, id],
    );
    final charges =
        (purchase['freight_paise']! as int) +
        (purchase['other_charges_paise']! as int);
    final taxables = [for (final r in rows) r['taxable_paise']! as int];
    final shares = charges == 0
        ? List.filled(rows.length, 0)
        : ShopMath.apportion(
            charges,
            taxables.fold<int>(0, (a, w) => a + w) > 0
                ? taxables
                : [for (final r in rows) r['qty_milli']! as int],
          );
    // IGST or CGST + SGST: read it from the journal the purchase posted.
    final igst = await tx.getOptional(
      'SELECT 1 FROM journal_lines l JOIN journal_entries e '
      'ON e.id = l.journal_entry_id AND e.tenant_id = l.tenant_id '
      'WHERE e.tenant_id = ? AND e.source_key = ? AND l.account_id = ?',
      [
        tenantId,
        'purchase:$id',
        JournalWriter.accountId(
          tenantId,
          const SystemJournalAccount(SystemAccount.gstInputIgst),
        ),
      ],
    );
    GstSplit split(int taxable, int tax) => igst != null
        ? GstSplit(
            taxable: Money(taxable),
            cgst: Money.zero,
            sgst: Money.zero,
            igst: Money(tax),
          )
        : GstSplit(
            taxable: Money(taxable),
            cgst: Money(tax ~/ 2),
            sgst: Money(tax - tax ~/ 2),
            igst: Money.zero,
          );
    final stock = <String, int>{};
    for (final r in rows) {
      final b = r['batch_id']! as String;
      stock[b] ??= await _batchStock(tx, tenantId, b);
    }
    var lines = <PurchasedLine>[
      for (var i = 0; i < rows.length; i++)
        PurchasedLine(
          batchId: rows[i]['batch_id']! as String,
          qtyMilli: rows[i]['qty_milli']! as int,
          split: split(taxables[i], rows[i]['gst_paise']! as int),
          landed: Money(taxables[i] + shares[i]),
          batchRemainingMilli: stock[rows[i]['batch_id']]! < 0
              ? 0
              : stock[rows[i]['batch_id']]!,
        ),
    ];
    final lineIds = [for (final r in rows) r['id']! as String];

    // Replay the earlier returns, oldest first, to know what each line has
    // given back (to the paisa) so the last return takes the exact rest.
    final prior = await tx.getAll(
      'SELECT l.purchase_line_id, l.qty_milli, r.id AS rid '
      'FROM purchase_return_lines l JOIN purchase_returns r '
      'ON r.id = l.purchase_return_id AND r.tenant_id = l.tenant_id '
      'WHERE l.tenant_id = ? AND r.purchase_id = ? AND r.status = ? '
      'ORDER BY r.created_at, r.id, l.line_no',
      [tenantId, id, 'posted'],
    );
    final groups = <String, List<ReturnRequest>>{};
    for (final p in prior) {
      groups
          .putIfAbsent(p['rid']! as String, () => [])
          .add(
            ReturnRequest(
              lineIds.indexOf(p['purchase_line_id']! as String),
              p['qty_milli']! as int,
            ),
          );
    }
    for (final requests in groups.values) {
      // Stock left is not the question while replaying history.
      final open = [
        for (final l in lines)
          PurchasedLine(
            batchId: l.batchId,
            qtyMilli: l.qtyMilli,
            split: l.split,
            landed: l.landed,
            batchRemainingMilli: l.qtyMilli,
            returnedMilli: l.returnedMilli,
            returned: l.returned,
            returnedLanded: l.returnedLanded,
          ),
      ];
      final done = PurchaseRules.computeReturn(open, requests);
      final next = [...lines];
      for (final r in done.lines) {
        final l = lines[r.lineIndex];
        next[r.lineIndex] = PurchasedLine(
          batchId: l.batchId,
          qtyMilli: l.qtyMilli,
          split: l.split,
          landed: l.landed,
          batchRemainingMilli: l.batchRemainingMilli,
          returnedMilli: l.returnedMilli + r.qtyMilli,
          returned: GstSplit(
            taxable: l.returned.taxable + r.split.taxable,
            cgst: l.returned.cgst + r.split.cgst,
            sgst: l.returned.sgst + r.split.sgst,
            igst: l.returned.igst + r.split.igst,
          ),
          returnedLanded: l.returnedLanded + r.stockValue,
        );
      }
      lines = next;
    }
    return _Bought(rows, lineIds, lines);
  }

  // -- payables --------------------------------------------------------------

  /// Everything `Payables.derive` needs for [tenantId].
  static Future<List<SupplierPayableTotals>> _derive(
    SqliteReadContext tx,
    String tenantId,
    LedgerDate today,
  ) async {
    final bills = await tx.getAll(
      'SELECT id, party_id, purchase_no, invoice_date, due_date, '
      'total_paise - paid_paise AS booked FROM purchases '
      "WHERE tenant_id = ? AND status = 'posted' AND total_paise > paid_paise",
      [tenantId],
    );
    final credits = <String, int>{};
    for (final r in await tx.getAll(
      'SELECT purchase_id, SUM(refund_khata_paise) AS n FROM purchase_returns '
      "WHERE tenant_id = ? AND status = 'posted' GROUP BY purchase_id",
      [tenantId],
    )) {
      credits[r['purchase_id']! as String] = r['n']! as int;
    }
    final paid = <String, Money>{};
    for (final r in await tx.getAll(
      'SELECT e.party_id, SUM(e.amount_paise) AS n FROM ledger_entries e '
      "WHERE e.tenant_id = ? AND e.side = 'udhaar' "
      "AND e.ref_type IN ('payment', 'voucher') AND e.reverses_id IS NULL "
      'AND NOT EXISTS (SELECT 1 FROM ledger_entries x '
      'WHERE x.tenant_id = e.tenant_id AND x.reverses_id = e.id) '
      'GROUP BY e.party_id',
      [tenantId],
    )) {
      paid[r['party_id']! as String] = Money(r['n']! as int);
    }
    return Payables.derive(
      bills: [
        for (final b in bills)
          PayableBill(
            purchaseId: b['id']! as String,
            supplierId: b['party_id']! as String,
            billNo: b['purchase_no'] as String?,
            invoiceDate: LedgerDate.parse(b['invoice_date']! as String),
            dueDate: LedgerDate.parse(
              (b['due_date'] ?? b['invoice_date'])! as String,
            ),
            booked: Money(b['booked']! as int),
            creditNote: Money(credits[b['id']] ?? 0),
          ),
      ],
      paidBySupplier: paid,
      today: today,
    );
  }

  static Future<Money> _outstandingOf(
    SqliteReadContext tx,
    String tenantId,
    String purchaseId,
    LedgerDate today,
  ) async {
    for (final s in await _derive(tx, tenantId, today)) {
      for (final b in s.bills) {
        if (b.bill.purchaseId == purchaseId) return b.outstanding;
      }
    }
    return Money.zero;
  }

  static const _watched = {
    'purchases',
    'purchase_lines',
    'purchase_returns',
    'purchase_return_lines',
    'ledger_entries',
    'parties',
    'stock_movements',
  };

  /// What each supplier is owed for purchases (step 4.4): outstanding,
  /// earliest due date, days overdue and the open bills. A BREAKDOWN of the
  /// supplier's khata by purchase, never to be added to the party balance.
  /// Live.
  Stream<List<SupplierPayable>> watchSupplierPayables(
    String tenantId, {
    LedgerDate? today,
  }) => _db.watch('SELECT 1', triggerOnTables: _watched).asyncMap((_) async {
    final day = today ?? LedgerDate.fromDateTime(DateTime.now());
    return await _db.readTransaction((tx) async {
      final totals = await _derive(tx, tenantId, day);
      final names = <String, Map<String, Object?>>{};
      for (final p in await tx.getAll(
        'SELECT id, name, code FROM parties WHERE tenant_id = ?',
        [tenantId],
      )) {
        names[p['id']! as String] = p;
      }
      return [
        for (final t in totals)
          SupplierPayable(
            supplierId: t.supplierId,
            supplierName: names[t.supplierId]?['name'] as String? ?? '',
            supplierCode: names[t.supplierId]?['code'] as String? ?? '',
            outstanding: t.outstanding,
            dueDate: t.dueDate,
            overdueDays: t.overdueDays,
            bills: t.bills,
          ),
      ];
    });
  });

  // -- reads -----------------------------------------------------------------

  /// Purchases matching [filter], newest first, with what is still owed on
  /// each. Live.
  Stream<List<PurchaseSummary>> watchPurchases(
    String tenantId,
    PurchaseFilter filter, {
    LedgerDate? today,
  }) => _db.watch('SELECT 1', triggerOnTables: _watched).asyncMap((_) async {
    final day = today ?? LedgerDate.fromDateTime(DateTime.now());
    return await _db.readTransaction((tx) async {
      final rows = await tx.getAll(
        '$_summarySelect WHERE p.tenant_id = ? '
        'AND (? IS NULL OR p.party_id = ?) '
        'AND (? IS NULL OR p.entry_date >= ?) '
        'AND (? IS NULL OR p.entry_date <= ?) '
        'ORDER BY p.entry_date DESC, p.created_at DESC LIMIT 1000',
        [
          tenantId,
          filter.supplierId,
          filter.supplierId,
          filter.from?.toString(),
          filter.from?.toString(),
          filter.to?.toString(),
          filter.to?.toString(),
        ],
      );
      final open = await _openBills(tx, tenantId, day);
      return [
        for (final r in rows) ?_summaryIf(r, open[r['id']], filter.status),
      ];
    });
  });

  PurchaseSummary? _summaryIf(
    Map<String, Object?> r,
    PayableBillState? open,
    PurchaseStatusFilter status,
  ) {
    final s = _summary(r, open);
    return switch (status) {
      PurchaseStatusFilter.all => s,
      PurchaseStatusFilter.unpaid => s.isUnpaid ? s : null,
      PurchaseStatusFilter.reversed => s.isReversed ? s : null,
    };
  }

  static const _summarySelect =
      'SELECT p.*, s.name AS supplier_name FROM purchases p '
      'LEFT JOIN parties s ON s.id = p.party_id AND s.tenant_id = p.tenant_id';

  static Future<Map<String, PayableBillState>> _openBills(
    SqliteReadContext tx,
    String tenantId,
    LedgerDate today,
  ) async => {
    for (final s in await _derive(tx, tenantId, today))
      for (final b in s.bills) b.bill.purchaseId: b,
  };

  PurchaseSummary _summary(Map<String, Object?> r, PayableBillState? open) {
    final reversed = r['status'] == 'reversed';
    return PurchaseSummary(
      id: r['id']! as String,
      purchaseNo: r['purchase_no']! as String,
      supplierId: r['party_id']! as String,
      supplierName: r['supplier_name'] as String? ?? '',
      supplierInvoiceNo: r['supplier_invoice_no'] as String?,
      invoiceDate: LedgerDate.parse(r['invoice_date']! as String),
      date: LedgerDate.parse(r['entry_date']! as String),
      dueDate: r['due_date'] == null
          ? null
          : LedgerDate.parse(r['due_date']! as String),
      total: Money(r['total_paise']! as int),
      paid: Money(r['paid_paise']! as int),
      outstanding: reversed ? Money.zero : (open?.outstanding ?? Money.zero),
      overdueDays: reversed ? 0 : (open?.overdueDays ?? 0),
      isReversed: reversed,
    );
  }

  /// One purchase with its lines and returns; null when missing. Live.
  Stream<PurchaseDetail?> watchPurchase(
    String tenantId,
    String id, {
    LedgerDate? today,
  }) => _db.watch('SELECT 1', triggerOnTables: _watched).asyncMap((_) async {
    final day = today ?? LedgerDate.fromDateTime(DateTime.now());
    return await _db.readTransaction((tx) async {
      final r = await tx.getOptional(
        '$_summarySelect WHERE p.tenant_id = ? AND p.id = ?',
        [tenantId, id],
      );
      if (r == null) return null;
      final open = await _openBills(tx, tenantId, day);
      final lines = await tx.getAll(
        'SELECT l.*, pr.name AS product_name, '
        '(SELECT COALESCE(SUM(x.qty_milli), 0) '
        'FROM purchase_return_lines x JOIN purchase_returns rr '
        'ON rr.id = x.purchase_return_id AND rr.tenant_id = x.tenant_id '
        "WHERE x.purchase_line_id = l.id AND rr.status = 'posted') "
        'AS returned_milli '
        'FROM purchase_lines l LEFT JOIN products pr '
        'ON pr.id = l.product_id AND pr.tenant_id = l.tenant_id '
        'WHERE l.tenant_id = ? AND l.purchase_id = ? ORDER BY l.line_no',
        [tenantId, id],
      );
      final returns = await tx.getAll(
        'SELECT * FROM purchase_returns WHERE tenant_id = ? '
        'AND purchase_id = ? ORDER BY created_at',
        [tenantId, id],
      );
      final account = r['bank_account_id'] == null
          ? null
          : await tx.getOptional(
              'SELECT name FROM bank_accounts WHERE tenant_id = ? '
              'AND id = ?',
              [tenantId, r['bank_account_id']],
            );
      return PurchaseDetail(
        summary: _summary(r, open[id]),
        lines: [
          for (final l in lines)
            PurchaseLineView(
              id: l['id']! as String,
              lineNo: l['line_no']! as int,
              productId: l['product_id']! as String,
              productName: l['product_name'] as String? ?? '',
              batchId: l['batch_id']! as String,
              batchNo: l['batch_no']! as String,
              mfgDate: _date(l['mfg_date']),
              expiry: _date(l['expiry_date']),
              qtyMilli: l['qty_milli']! as int,
              returnedMilli: l['returned_milli']! as int,
              unitCost: Money(l['cost_paise']! as int),
              gstRateBp: ((l['gst_rate']! as num) * 100).round(),
              taxable: Money(l['taxable_paise']! as int),
              gst: Money(l['gst_paise']! as int),
            ),
        ],
        returns: [
          for (final x in returns)
            PurchaseReturnView(
              id: x['id']! as String,
              returnNo: x['return_no']! as String,
              date: LedgerDate.parse(x['entry_date']! as String),
              total: Money(x['total_paise']! as int),
              creditedToKhata: Money(x['refund_khata_paise']! as int),
              refundedPaid: Money(x['refund_paid_paise']! as int),
              isReversed: x['status'] == 'reversed',
            ),
        ],
        taxable: Money(r['taxable_paise']! as int),
        gst: Money(r['gst_paise']! as int),
        freight: Money(r['freight_paise']! as int),
        otherCharges: Money(r['other_charges_paise']! as int),
        roundOff: Money(r['round_off_paise']! as int),
        paidInCash: r['payment_mode'] != 'bank',
        accountName: account?['name'] as String?,
        creditDays: r['credit_days']! as int,
        notes: r['notes'] as String?,
      );
    });
  });

  static LedgerDate? _date(Object? text) =>
      text == null ? null : LedgerDate.parse(text as String);

  // -- pickers ---------------------------------------------------------------

  /// Parties with the supplier or agency role matching [query] (name, code,
  /// village). Live.
  Stream<List<SupplierOption>> watchSuppliers(
    String tenantId, {
    String query = '',
  }) {
    final like = '%${query.trim().toLowerCase()}%';
    return _db
        .watch(
          'SELECT p.id, p.name, p.code, p.gstin, p.village FROM parties p '
          'WHERE p.tenant_id = ? AND p.deleted_at IS NULL '
          'AND EXISTS (SELECT 1 FROM party_roles r WHERE r.party_id = p.id '
          "AND r.role IN ('supplier', 'agency') AND r.deleted_at IS NULL) "
          "AND (? = '%%' OR lower(p.name) LIKE ? OR lower(p.code) LIKE ? "
          'OR lower(p.village) LIKE ?) '
          'ORDER BY p.name COLLATE NOCASE LIMIT 50',
          parameters: [tenantId, like, like, like, like],
          triggerOnTables: const {'parties', 'party_roles'},
        )
        .map(
          (rows) => [
            for (final r in rows)
              SupplierOption(
                id: r['id']! as String,
                name: r['name']! as String,
                code: r['code']! as String,
                gstin: r['gstin'] as String?,
                village: r['village'] as String?,
              ),
          ],
        );
  }

  /// Active products matching [query] (name, sku, brand, barcode).
  Future<List<PurchaseProduct>> searchProducts(
    String tenantId,
    String query, {
    int limit = 30,
  }) async {
    final text = query.trim().toLowerCase();
    final like = '%$text%';
    final rows = await _db.getAll(
      'SELECT id, sku, name, brand, unit, hsn, gst_rate FROM products '
      'WHERE tenant_id = ? AND deleted_at IS NULL AND is_active = 1 '
      "AND (? = '' OR lower(name) LIKE ? OR lower(sku) LIKE ? "
      'OR lower(brand) LIKE ? OR barcode = ?) '
      'ORDER BY name COLLATE NOCASE LIMIT ?',
      [tenantId, text, like, like, like, query.trim(), limit],
    );
    return [for (final r in rows) PurchaseProduct.fromRow(r)];
  }

  /// Batches already bought of [productId], newest first, to prefill a line.
  Future<List<PurchaseBatchHint>> batchHints(
    String tenantId,
    String productId,
  ) async {
    final rows = await _db.getAll(
      'SELECT batch_no, cost_paise, mfg_date, expiry_date FROM batches '
      'WHERE tenant_id = ? AND product_id = ? ORDER BY created_at DESC '
      'LIMIT 10',
      [tenantId, productId],
    );
    return [
      for (final r in rows)
        PurchaseBatchHint(
          batchNo: r['batch_no']! as String,
          cost: Money(r['cost_paise']! as int),
          mfgDate: _date(r['mfg_date']),
          expiry: _date(r['expiry_date']),
        ),
    ];
  }

  /// Stock of a product: the sum of its movements.
  Future<int> stockOf(String tenantId, String productId) async =>
      (await _db.get(
            'SELECT COALESCE(SUM(qty_milli), 0) AS n FROM stock_movements '
            'WHERE tenant_id = ? AND product_id = ?',
            [tenantId, productId],
          ))['n']!
          as int;

  static String? _clean(String? text) {
    final t = text?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}

class _Bought {
  const _Bought(this.rows, this.lineIds, this.lines);

  final List<Map<String, Object?>> rows;
  final List<String> lineIds;
  final List<PurchasedLine> lines;
}
