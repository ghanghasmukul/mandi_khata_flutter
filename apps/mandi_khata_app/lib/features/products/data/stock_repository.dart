// Public read API for other features (purchases, POS, shop sales, reports).
//
// Get it from `stockApiProvider` (presentation/products_providers.dart): it
// is bound to the ACTIVE business, so every query is tenant-filtered.
//
//   Future<List<BatchStock>> batchesFor(String productId)
//       Every batch of the product, FEFO order (earliest expiry first, no
//       expiry last, then oldest). `BatchStock.remainingMilli` is
//       Σ stock_movements of the batch (the truth); `cachedMilli` is the
//       `batches.qty_milli` projection. `toStockBatch()` feeds `FefoPicker`.
//   Stream<List<ProductWithStock>> watchProducts({ProductFilter filter,
//       LedgerDate? today, int expiryWarnDays})
//       Live products with batches and stock (Σ movements). Retired
//       (`deleted_at`) products never show; inactive ones only when
//       `filter.includeInactive`.
//   Future<int> stockMilli(String productId)
//       Σ of ALL movements of the product, in milli-units (1000 = 1 unit),
//       including negative-stock sales that no batch covered.
//
// Writers that move stock (purchase, sale, returns) insert their movements
// with `StockMovementWriter.insert` inside their own transaction: it adds the
// movement AND the batch cache in step, as the server trigger does.
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/period_lock.dart';
import 'package:mandi_khata_app/features/products/domain/opening_stock_import.dart';
import 'package:mandi_khata_app/features/products/domain/stock.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart'
    show SqliteReadContext, SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// The stock book of one business, as other features see it.
class StockApi {
  StockApi(this._repo, this.tenantId);

  final StockRepository _repo;
  final String tenantId;

  Future<List<BatchStock>> batchesFor(String productId) =>
      _repo.batchesFor(tenantId, productId);

  Stream<List<ProductWithStock>> watchProducts({
    ProductFilter filter = const ProductFilter(),
    LedgerDate? today,
    int expiryWarnDays = 60,
  }) => _repo.watchProducts(
    tenantId,
    filter: filter,
    today: today,
    expiryWarnDays: expiryWarnDays,
  );

  Future<int> stockMilli(String productId) =>
      _repo.stockMilli(tenantId, productId);
}

/// Adds a stock movement. The cached `batches.qty_milli` is NOT written
/// here: the server trigger keeps it, and a member without stock rights
/// (a munshi selling) could not upload that update, which would reject the
/// whole sale. Local reads always sum the movements.
abstract final class StockMovementWriter {
  static Future<void> insert(
    SqliteWriteContext tx,
    WriteContext ctx, {
    required String id,
    required String productId,
    required String? batchId,
    required LedgerDate date,
    required int qtyMilli,
    required StockMovementReason reason,
    required String refType,
    required String refId,
    String? note,
    DateTime? at,
  }) async {
    final when = (at ?? DateTime.now()).toUtc();
    // Throws ArgumentError for a zero quantity or the wrong sign.
    StockMovement(
      productId: productId,
      qtyMilli: qtyMilli,
      reason: reason,
      batchId: batchId,
    );
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
        when.toIso8601String(),
      ],
    );
  }
}

enum StockAdjustProblem { noteMissing, zeroQuantity, wouldGoNegative, badDate }

/// How a stock write ended.
sealed class StockResult {
  const StockResult();
}

final class StockAdjusted extends StockResult {
  const StockAdjusted({
    required this.adjustmentId,
    required this.batchId,
    required this.remainingMilli,
    required this.value,
  });

  final String adjustmentId;
  final String batchId;

  /// Stock left in the batch afterwards.
  final int remainingMilli;

  /// Signed value at the batch's cost that went to the books.
  final Money value;
}

final class StockInvalid extends StockResult {
  const StockInvalid(this.problems);

  final List<StockAdjustProblem> problems;
}

final class StockNotPermitted extends StockResult {
  const StockNotPermitted(this.permission, {this.lockedYear = false});

  final Permission permission;

  /// The date is in a closed financial year.
  final bool lockedYear;
}

final class StockNotFound extends StockResult {
  const StockNotFound();
}

/// A batch with that number already exists for the product.
final class StockBatchExists extends StockResult {
  const StockBatchExists();
}

/// Opening stock written.
final class OpeningStockImported extends StockResult {
  const OpeningStockImported({
    required this.importId,
    required this.rows,
    required this.skipped,
    required this.value,
  });

  final String importId;

  /// Movements written.
  final int rows;

  /// Rows already in the books from an earlier run (same deterministic id).
  final int skipped;
  final Money value;
}

/// Every row was in the books already.
final class OpeningStockAlready extends StockResult {
  const OpeningStockAlready();
}

/// The preview still has problems; nothing was written.
final class OpeningStockInvalid extends StockResult {
  const OpeningStockInvalid();
}

/// A product in the file is gone or not the same any more; nothing written.
final class OpeningStockStale extends StockResult {
  const OpeningStockStale(this.rowNumber);

  final int rowNumber;
}

class _Stale implements Exception {
  const _Stale(this.row);

  final int row;
}

/// Stock = Σ `stock_movements`, per product and per batch, in the local
/// database. The batch `qty_milli` column is only a cache, kept in step by
/// [StockMovementWriter] and repaired by [rebuildBatchQty].
class StockRepository {
  StockRepository(this._db);

  final PowerSyncDatabase _db;

  static const _ns = '3e7a1c52-90d4-4b68-a2f5-7c1d8e4b6a09';

  static const _tables = {'products', 'batches', 'stock_movements'};

  // -- reads ----------------------------------------------------------------

  Future<List<ProductWithStock>> _load(
    SqliteReadContext tx,
    String tenantId, {
    String? productId,
  }) async {
    final p = productId == null ? '' : ' AND id = ?';
    final pp = productId == null ? '' : ' AND product_id = ?';
    final extra = productId == null ? <Object?>[] : [productId];
    final products = await tx.getAll(
      'SELECT * FROM products WHERE tenant_id = ? AND deleted_at IS NULL$p '
      'ORDER BY name COLLATE NOCASE, sku',
      [tenantId, ...extra],
    );
    final batches = await tx.getAll(
      'SELECT * FROM batches WHERE tenant_id = ?$pp',
      [tenantId, ...extra],
    );
    final sums = await tx.getAll(
      'SELECT product_id, batch_id, SUM(qty_milli) AS q FROM stock_movements '
      'WHERE tenant_id = ?$pp GROUP BY product_id, batch_id',
      [tenantId, ...extra],
    );
    return StockProjection.build(
      productRows: products,
      batchRows: batches,
      movementSumRows: sums,
    );
  }

  Stream<List<ProductWithStock>> _watchAll(String tenantId) => _db
      .onChange(_tables)
      .asyncMap((_) => _db.readTransaction((tx) => _load(tx, tenantId)));

  /// Live products of [tenantId] with batches and stock, filtered.
  Stream<List<ProductWithStock>> watchProducts(
    String tenantId, {
    ProductFilter filter = const ProductFilter(),
    LedgerDate? today,
    int expiryWarnDays = 60,
  }) {
    final day = today ?? LedgerDate.fromDateTime(DateTime.now());
    return _watchAll(tenantId).map(
      (all) => [
        for (final p in all)
          if (filter.matches(p, today: day, warnDays: expiryWarnDays)) p,
      ],
    );
  }

  /// Live counts and stock value of the whole (active) range.
  Stream<StockSummary> watchSummary(
    String tenantId, {
    LedgerDate? today,
    int expiryWarnDays = 60,
  }) {
    final day = today ?? LedgerDate.fromDateTime(DateTime.now());
    return _watchAll(tenantId).map(
      (all) =>
          StockProjection.summary(all, today: day, warnDays: expiryWarnDays),
    );
  }

  /// One product with its stock; null when missing / retired.
  Stream<ProductWithStock?> watchProduct(String tenantId, String productId) =>
      _db
          .onChange(_tables)
          .asyncMap(
            (_) => _db.readTransaction(
              (tx) async =>
                  (await _load(tx, tenantId, productId: productId)).firstOrNull,
            ),
          );

  Future<List<BatchStock>> batchesFor(String tenantId, String productId) async {
    final all = await _db.readTransaction(
      (tx) => _load(tx, tenantId, productId: productId),
    );
    return all.isEmpty ? const [] : all.first.batches;
  }

  /// Σ of every movement of the product (also those with no batch).
  Future<int> stockMilli(String tenantId, String productId) async {
    final row = await _db.get(
      'SELECT COALESCE(SUM(qty_milli), 0) AS q FROM stock_movements '
      'WHERE tenant_id = ? AND product_id = ?',
      [tenantId, productId],
    );
    return row['q']! as int;
  }

  /// The movements of a product (or of one batch), newest first.
  Stream<List<StockMovementRow>> watchMovements(
    String tenantId,
    String productId, {
    String? batchId,
  }) => _db
      .watch(
        'SELECT * FROM stock_movements WHERE tenant_id = ? AND product_id = ? '
        '${batchId == null ? '' : 'AND batch_id = ? '}'
        'ORDER BY entry_date DESC, created_at DESC',
        parameters: [tenantId, productId, ?batchId],
        triggerOnTables: const {'stock_movements'},
      )
      .map((rows) => [for (final r in rows) StockMovementRow.fromRow(r)]);

  /// Active products as references for the import preview.
  Future<List<ProductRef>> productRefs(String tenantId) async {
    final rows = await _db.getAll(
      'SELECT id, sku, barcode, name FROM products WHERE tenant_id = ? '
      'AND deleted_at IS NULL AND is_active = 1',
      [tenantId],
    );
    return [
      for (final r in rows)
        ProductRef(
          id: r['id']! as String,
          sku: r['sku']! as String,
          barcode: r['barcode'] as String?,
          name: r['name']! as String,
        ),
    ];
  }

  // -- writes ---------------------------------------------------------------

  /// Corrects the stock of one batch by [deltaMilli] (+ found, - lost).
  ///
  /// Needs `stock.adjust` and a reason in [note]. One transaction: the
  /// `adjustment` movement, the batch cache, the journal entry (Dr/Cr Stock
  /// Adjustment against Stock-in-Hand at the batch cost) and the audit rows.
  Future<StockResult> adjust(
    WriteContext ctx, {
    required String productId,
    required String batchId,
    required int deltaMilli,
    required String note,
    required bool Function(Permission) can,
    LedgerDate? date,
    DateTime? now,
  }) async {
    if (!can(Permission.stockAdjust)) {
      return const StockNotPermitted(Permission.stockAdjust);
    }
    final when = (now ?? DateTime.now()).toUtc();
    final today = LedgerDate.fromDateTime(when.toLocal());
    final day = date ?? today;
    final cleanNote = note.trim();
    final problems = [
      if (cleanNote.isEmpty) StockAdjustProblem.noteMissing,
      if (deltaMilli == 0) StockAdjustProblem.zeroQuantity,
      if (day > today) StockAdjustProblem.badDate,
    ];
    if (problems.isNotEmpty) return StockInvalid(problems);

    return await _db.writeTransaction<StockResult>((tx) async {
      if (await PeriodLock.refuses(tx, ctx, day)) {
        return const StockNotPermitted(
          Permission.adminManage,
          lockedYear: true,
        );
      }
      final batch = await tx.getOptional(
        'SELECT b.* FROM batches b JOIN products p ON p.id = b.product_id '
        'AND p.tenant_id = b.tenant_id WHERE b.tenant_id = ? AND b.id = ? '
        'AND b.product_id = ? AND p.deleted_at IS NULL',
        [ctx.tenantId, batchId, productId],
      );
      if (batch == null) return const StockNotFound();
      final left = await _batchSum(tx, ctx.tenantId, batchId);
      if (left + deltaMilli < 0) {
        return const StockInvalid([StockAdjustProblem.wouldGoNegative]);
      }
      final adjustmentId = const Uuid().v4();
      await StockMovementWriter.insert(
        tx,
        ctx,
        id: const Uuid().v4(),
        productId: productId,
        batchId: batchId,
        date: day,
        qtyMilli: deltaMilli,
        reason: StockMovementReason.adjustment,
        refType: 'stock_adjustment',
        refId: adjustmentId,
        note: cleanNote,
        at: when,
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'stock_movements',
        rowId: adjustmentId,
        action: AuditAction.insert,
        before: {'batch_id': batchId, 'qty_milli': left},
        after: {
          'product_id': productId,
          'batch_id': batchId,
          'delta_milli': deltaMilli,
          'qty_milli': left + deltaMilli,
          'reason': 'adjustment',
          'note': cleanNote,
          'entry_date': day.toString(),
        },
        at: when,
      );
      final value = ShopMath.valueOf(
        Money(batch['cost_paise']! as int),
        deltaMilli,
      );
      if (!value.isZero) {
        await JournalWriter.post(
          tx,
          ctx,
          ShopPosting.stockAdjustment(
            adjustmentId: adjustmentId,
            date: day,
            value: value,
            narration: cleanNote,
          ),
          now: when,
        );
      }
      return StockAdjusted(
        adjustmentId: adjustmentId,
        batchId: batchId,
        remainingMilli: left + deltaMilli,
        value: value,
      );
    });
  }

  /// Opening stock of one new batch (the "add stock" dialog). Needs
  /// `stock.adjust` and `products.manage` (it creates the batch).
  Future<StockResult> addOpeningBatch(
    WriteContext ctx, {
    required String productId,
    required String batchNo,
    required int qtyMilli,
    required Money cost,
    required bool Function(Permission) can,
    LedgerDate? mfgDate,
    LedgerDate? expiry,
    LedgerDate? date,
    DateTime? now,
  }) async {
    final row = OpeningStockRow(
      number: 1,
      reference: productId,
      productId: productId,
      batchNo: batchNo.trim().isEmpty
          ? OpeningStockImport.defaultBatchNo
          : batchNo.trim(),
      qtyMilli: qtyMilli,
      cost: cost,
      mfgDate: mfgDate,
      expiry: expiry,
      problems: [
        if (qtyMilli <= 0) StockRowProblem.qtyInvalid,
        if (cost.isNegative) StockRowProblem.costInvalid,
        if (mfgDate != null && expiry != null && expiry < mfgDate)
          StockRowProblem.expiryBeforeMfg,
      ],
    );
    if (!row.isValid) return const OpeningStockInvalid();
    final result = await _postOpening(
      ctx,
      [row],
      importId: const Uuid().v4(),
      asOn: date ?? LedgerDate.fromDateTime(DateTime.now()),
      can: can,
      now: now,
      failIfBatchExists: true,
    );
    return result;
  }

  /// Posts a checked preview as opening stock: all or nothing, safe to run
  /// twice (deterministic ids: the second run finds every row already there).
  Future<StockResult> importOpening(
    WriteContext ctx,
    OpeningStockPreview preview, {
    required LedgerDate asOn,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.stockAdjust)) {
      return const StockNotPermitted(Permission.stockAdjust);
    }
    if (!preview.canImport) return const OpeningStockInvalid();
    final importId = const Uuid().v5(
      _ns,
      '${ctx.tenantId}|opening|${preview.fingerprint}|$asOn',
    );
    return await _postOpening(
      ctx,
      preview.valid,
      importId: importId,
      asOn: asOn,
      can: can,
      now: now,
    );
  }

  Future<StockResult> _postOpening(
    WriteContext ctx,
    List<OpeningStockRow> rows, {
    required String importId,
    required LedgerDate asOn,
    required bool Function(Permission) can,
    DateTime? now,
    bool failIfBatchExists = false,
  }) async {
    if (!can(Permission.stockAdjust)) {
      return const StockNotPermitted(Permission.stockAdjust);
    }
    if (!can(Permission.productsManage)) {
      return const StockNotPermitted(Permission.productsManage);
    }
    final when = (now ?? DateTime.now()).toUtc();
    if (asOn > LedgerDate.fromDateTime(when.toLocal())) {
      return const StockInvalid([StockAdjustProblem.badDate]);
    }
    try {
      return await _db.writeTransaction<StockResult>((tx) async {
        if (await PeriodLock.refuses(tx, ctx, asOn)) {
          return const StockNotPermitted(
            Permission.adminManage,
            lockedYear: true,
          );
        }
        var written = 0;
        var skipped = 0;
        var value = Money.zero;
        for (final row in rows) {
          final productId = row.productId!;
          final product = await tx.getOptional(
            'SELECT 1 FROM products WHERE tenant_id = ? AND id = ? '
            'AND deleted_at IS NULL',
            [ctx.tenantId, productId],
          );
          if (product == null) {
            if (failIfBatchExists) return const StockNotFound();
            throw _Stale(row.number);
          }
          final existing = await tx.getOptional(
            'SELECT id, cost_paise FROM batches WHERE tenant_id = ? '
            'AND product_id = ? AND batch_no = ?',
            [ctx.tenantId, productId, row.batchNo],
          );
          if (existing != null && failIfBatchExists) {
            return const StockBatchExists();
          }
          final batchId =
              (existing?['id'] as String?) ??
              const Uuid().v5(
                _ns,
                '${ctx.tenantId}|batch|$productId|${row.batchNo}',
              );
          final movementId = failIfBatchExists
              ? const Uuid().v4()
              : const Uuid().v5(
                  _ns,
                  '${ctx.tenantId}|opening-movement|$importId|$productId|'
                  '${row.batchNo}',
                );
          if (await tx.getOptional(
                'SELECT 1 FROM stock_movements WHERE tenant_id = ? AND id = ?',
                [ctx.tenantId, movementId],
              ) !=
              null) {
            skipped++;
            continue;
          }
          final cost = existing == null
              ? row.cost
              : Money(existing['cost_paise']! as int);
          if (existing == null) {
            final at = when.toIso8601String();
            await tx.execute(
              'INSERT INTO batches (id, tenant_id, product_id, batch_no, '
              'mfg_date, expiry_date, cost_paise, qty_milli, created_by, '
              'created_at, updated_at) '
              'VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?)',
              [
                batchId,
                ctx.tenantId,
                productId,
                row.batchNo,
                row.mfgDate?.toString(),
                row.expiry?.toString(),
                row.cost.paise,
                ctx.userId,
                at,
                at,
              ],
            );
            await AuditWriter.record(
              tx,
              ctx,
              table: 'batches',
              rowId: batchId,
              action: AuditAction.insert,
              after: {
                'product_id': productId,
                'batch_no': row.batchNo,
                'cost_paise': row.cost.paise,
                'mfg_date': ?row.mfgDate?.toString(),
                'expiry_date': ?row.expiry?.toString(),
              },
              at: when,
            );
          }
          await StockMovementWriter.insert(
            tx,
            ctx,
            id: movementId,
            productId: productId,
            batchId: batchId,
            date: asOn,
            qtyMilli: row.qtyMilli,
            reason: StockMovementReason.opening,
            refType: 'opening',
            refId: importId,
            note: 'Opening stock',
            at: when,
          );
          await AuditWriter.record(
            tx,
            ctx,
            table: 'stock_movements',
            rowId: movementId,
            action: AuditAction.insert,
            after: {
              'product_id': productId,
              'batch_id': batchId,
              'qty_milli': row.qtyMilli,
              'reason': 'opening',
              'entry_date': asOn.toString(),
              'ref_id': importId,
            },
            at: when,
          );
          written++;
          value += ShopMath.valueOf(cost, row.qtyMilli);
        }
        if (written == 0) return const OpeningStockAlready();
        if (!value.isZero) {
          await JournalWriter.post(
            tx,
            ctx,
            ShopPosting.stockAdjustment(
              adjustmentId: importId,
              date: asOn,
              value: value,
              reason: StockMovementReason.opening,
              narration: 'Opening stock',
            ),
            now: when,
          );
        }
        return OpeningStockImported(
          importId: importId,
          rows: written,
          skipped: skipped,
          value: value,
        );
      });
    } on _Stale catch (e) {
      return OpeningStockStale(e.row);
    }
  }

  /// Changes a batch's cost or dates (`products.manage`). Its number, product
  /// and quantity never change (quantity only moves with movements).
  Future<bool> updateBatch(
    WriteContext ctx,
    String batchId, {
    required bool Function(Permission) can,
    Money? cost,
    LedgerDate? mfgDate,
    LedgerDate? expiry,
    bool clearMfg = false,
    bool clearExpiry = false,
    DateTime? now,
  }) async {
    if (!can(Permission.productsManage)) return false;
    if (cost != null && cost.isNegative) return false;
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM batches WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, batchId],
      );
      if (row == null) return false;
      final newMfg = clearMfg ? null : (mfgDate?.toString() ?? row['mfg_date']);
      final newExp = clearExpiry
          ? null
          : (expiry?.toString() ?? row['expiry_date']);
      if (newMfg != null &&
          newExp != null &&
          (newExp as String).compareTo(newMfg as String) < 0) {
        return false;
      }
      final newCost = cost?.paise ?? row['cost_paise']! as int;
      await tx.execute(
        'UPDATE batches SET cost_paise = ?, mfg_date = ?, expiry_date = ?, '
        'updated_at = ? WHERE tenant_id = ? AND id = ?',
        [
          newCost,
          newMfg,
          newExp,
          when.toIso8601String(),
          ctx.tenantId,
          batchId,
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'batches',
        rowId: batchId,
        action: AuditAction.update,
        before: {
          'cost_paise': row['cost_paise'],
          'mfg_date': row['mfg_date'],
          'expiry_date': row['expiry_date'],
        },
        after: {
          'cost_paise': newCost,
          'mfg_date': newMfg,
          'expiry_date': newExp,
        },
        at: when,
      );
      return true;
    });
  }

  /// Repairs `batches.qty_milli` from the movements (the truth), like the
  /// server's `rebuild_batch_qty`. Returns how many batches were wrong;
  /// null when not permitted (`stock.adjust`).
  Future<int?> rebuildBatchQty(
    WriteContext ctx, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.stockAdjust)) return null;
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final rows = await tx.getAll(
        'SELECT b.id, b.qty_milli, '
        '(SELECT COALESCE(SUM(m.qty_milli), 0) FROM stock_movements m '
        'WHERE m.tenant_id = b.tenant_id AND m.batch_id = b.id) AS q '
        'FROM batches b WHERE b.tenant_id = ?',
        [ctx.tenantId],
      );
      var fixed = 0;
      for (final r in rows) {
        if (r['qty_milli'] == r['q']) continue;
        fixed++;
        await tx.execute(
          'UPDATE batches SET qty_milli = ?, updated_at = ? '
          'WHERE tenant_id = ? AND id = ?',
          [r['q'], when.toIso8601String(), ctx.tenantId, r['id']],
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'batches',
          rowId: r['id']! as String,
          action: AuditAction.update,
          before: {'qty_milli': r['qty_milli']},
          after: {'qty_milli': r['q'], 'rebuilt': true},
          at: when,
        );
      }
      return fixed;
    });
  }

  static Future<int> _batchSum(
    SqliteReadContext tx,
    String tenantId,
    String batchId,
  ) async {
    final r = await tx.get(
      'SELECT COALESCE(SUM(qty_milli), 0) AS q FROM stock_movements '
      'WHERE tenant_id = ? AND batch_id = ?',
      [tenantId, batchId],
    );
    return r['q']! as int;
  }
}

/// One line of the stock book, for the batch detail.
class StockMovementRow {
  const StockMovementRow({
    required this.id,
    required this.productId,
    required this.entryDate,
    required this.qtyMilli,
    required this.reason,
    this.batchId,
    this.note,
    this.refType,
    this.refId,
  });

  factory StockMovementRow.fromRow(Map<String, Object?> r) => StockMovementRow(
    id: r['id']! as String,
    productId: r['product_id']! as String,
    batchId: r['batch_id'] as String?,
    entryDate: LedgerDate.parse(r['entry_date']! as String),
    qtyMilli: r['qty_milli']! as int,
    reason: StockMovementReason.parse(r['reason']! as String),
    note: r['note'] as String?,
    refType: r['ref_type'] as String?,
    refId: r['ref_id'] as String?,
  );

  final String id;
  final String productId;
  final String? batchId;
  final LedgerDate entryDate;
  final int qtyMilli;
  final StockMovementReason reason;
  final String? note;
  final String? refType;
  final String? refId;
}
