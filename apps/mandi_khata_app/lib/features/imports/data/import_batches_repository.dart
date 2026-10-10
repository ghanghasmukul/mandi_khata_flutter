import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/period_lock.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/products/data/products_repository.dart';
import 'package:mandi_khata_app/features/products/domain/product.dart';
import 'package:mandi_khata_app/features/products/domain/product_import.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// What an import batch brought in.
enum ImportKind {
  /// Parties with an opening balance each (file or Tally).
  openingBalances('opening_balance_imports'),
  products('product_imports');

  const ImportKind(this.auditTable);

  /// The `audit_log.table_name` its batch record is written under.
  final String auditTable;
}

/// One import, as the owner sees it in "Past imports".
class ImportBatch {
  const ImportBatch({
    required this.id,
    required this.kind,
    required this.rows,
    required this.importedAt,
    this.fileName,
    this.source,
    this.rolledBackAt,
  });

  final String id;
  final ImportKind kind;

  /// Rows written (entries for balances, products for products).
  final int rows;
  final DateTime? importedAt;
  final String? fileName;

  /// `file` or `tally` for balances.
  final String? source;
  final DateTime? rolledBackAt;

  bool get rolledBack => rolledBackAt != null;
}

sealed class ProductImportResult {
  const ProductImportResult();
}

final class ProductsImported extends ProductImportResult {
  const ProductsImported(this.batchId, this.count);
  final String batchId;
  final int count;
}

final class ProductsAlreadyImported extends ProductImportResult {
  const ProductsAlreadyImported();
}

final class ProductsNothingToImport extends ProductImportResult {
  const ProductsNothingToImport();
}

final class ProductsNotPermitted extends ProductImportResult {
  const ProductsNotPermitted();
}

/// Something changed since the preview (a SKU was added from another
/// device). Nothing was written; preview again.
final class ProductsStale extends ProductImportResult {
  const ProductsStale(this.rowNumber);
  final int rowNumber;
}

enum RollbackRefusal { notOwner, notFound, alreadyRolledBack, lockedYear }

sealed class RollbackResult {
  const RollbackResult();
}

final class RolledBack extends RollbackResult {
  const RolledBack({
    required this.entries,
    required this.parties,
    required this.products,
    required this.kept,
  });

  /// Khata entries reversed.
  final int entries;

  /// Parties the import created that were removed (no other entries).
  final int parties;
  final int products;

  /// Parties / products left alone because they are used elsewhere now.
  final int kept;
}

final class RollbackRefused extends RollbackResult {
  const RollbackRefused(this.reason);
  final RollbackRefusal reason;
}

/// Lists past imports and rolls them back (step 6.5).
///
/// Every import writes a batch record to the audit log
/// (`opening_balance_imports` / `product_imports`, row id = batch id) in the same transaction as its rows.
/// Rolling back is owner only and append-only for money: each khata entry of
/// the batch gets a reversal entry; parties the batch created are retired
/// (soft delete) when nothing else touches them; products likewise when they
/// have no stock movement. A `import_rollbacks` audit row marks it done.
class ImportBatchesRepository {
  ImportBatchesRepository(this._db);

  final PowerSyncDatabase _db;

  static const _namespace = '3d7b9e52-84c1-4a06-b5f8-12e6a09c47d3';

  static const _tables = "('opening_balance_imports', 'product_imports')";

  Stream<List<ImportBatch>> watchBatches(String tenantId) => _db
      .watch(
        'SELECT a.row_id, a.table_name, a."after" AS after_json, '
        'a.created_at, (SELECT MIN(r.created_at) FROM audit_log r '
        "WHERE r.tenant_id = a.tenant_id AND r.table_name = 'import_rollbacks' "
        'AND r.row_id = a.row_id) AS rolled_at '
        'FROM audit_log a WHERE a.tenant_id = ? AND a.table_name IN $_tables '
        "AND a.action = 'insert' ORDER BY a.created_at DESC",
        parameters: [tenantId],
        triggerOnTables: const {'audit_log'},
      )
      .map((rows) => [for (final r in rows) _batchOf(r)]);

  static ImportBatch _batchOf(Map<String, Object?> r) {
    final kind = ImportKind.values.firstWhere(
      (k) => k.auditTable == r['table_name'],
    );
    final after = _json(r['after_json']);
    return ImportBatch(
      id: r['row_id']! as String,
      kind: kind,
      rows:
          (kind == ImportKind.products
                  ? after['products']
                  : after['entries'] ?? after['rows'])
              as int? ??
          0,
      importedAt: DateTime.tryParse((r['created_at'] as String?) ?? ''),
      fileName: after['file'] as String?,
      source: after['source'] as String?,
      rolledBackAt: DateTime.tryParse((r['rolled_at'] as String?) ?? ''),
    );
  }

  static Map<String, Object?> _json(Object? raw) {
    if (raw is! String || raw.isEmpty) return const {};
    try {
      return (jsonDecode(raw) as Map).cast<String, Object?>();
    } on Object {
      return const {};
    }
  }

  // -- products ------------------------------------------------------------

  static String productBatchId(String tenantId, ProductImportPreview p) =>
      const Uuid().v5(_namespace, '$tenantId|products|${p.fingerprint}');

  static String productId(String tenantId, String sku) =>
      const Uuid().v5(_namespace, '$tenantId|product|${sku.toLowerCase()}');

  /// Creates the valid rows of [preview] as products, in ONE transaction with
  /// the batch record. Needs `products.manage`.
  Future<ProductImportResult> importProducts(
    WriteContext ctx,
    ProductImportPreview preview, {
    required bool Function(Permission) can,
    String? fileName,
    DateTime? now,
  }) async {
    if (!can(Permission.productsManage)) return const ProductsNotPermitted();
    final rows = preview.valid;
    if (rows.isEmpty) return const ProductsNothingToImport();
    final when = (now ?? DateTime.now()).toUtc();
    final batch = productBatchId(ctx.tenantId, preview);
    return await _db
        .writeTransaction<ProductImportResult>((tx) async {
          final done = await tx.getOptional(
            'SELECT 1 FROM audit_log WHERE tenant_id = ? AND table_name = ? '
            'AND row_id = ?',
            [ctx.tenantId, ImportKind.products.auditTable, batch],
          );
          if (done != null) return const ProductsAlreadyImported();
          final ids = <String>[];
          for (final row in rows) {
            final id = productId(ctx.tenantId, row.input.sku);
            final r = await ProductsRepository.createIn(
              tx,
              ctx,
              row.input.normalised(),
              id,
              when,
            );
            if (r is! ProductSaved) {
              // Roll the whole import back: throw out of the transaction.
              throw _Stale(row.number);
            }
            ids.add(id);
          }
          await AuditWriter.record(
            tx,
            ctx,
            table: ImportKind.products.auditTable,
            rowId: batch,
            action: AuditAction.insert,
            after: {
              'file': fileName,
              'products': ids.length,
              'product_ids': ids,
            },
            at: when,
          );
          return ProductsImported(batch, ids.length);
        })
        .onError<_Stale>((e, _) => ProductsStale(e.row));
  }

  // -- rollback --------------------------------------------------------------

  /// Undoes batch [batchId] (owner only). One transaction.
  Future<RollbackResult> rollback(
    WriteContext ctx,
    String batchId, {
    required bool isOwner,
    DateTime? now,
  }) async {
    if (!isOwner) return const RollbackRefused(RollbackRefusal.notOwner);
    final when = (now ?? DateTime.now()).toUtc();
    return await _db
        .writeTransaction<RollbackResult>((tx) async {
          final rec = await tx.getOptional(
            'SELECT table_name, "after" AS after_json FROM audit_log '
            'WHERE tenant_id = ? AND row_id = ? AND table_name IN $_tables '
            "AND action = 'insert'",
            [ctx.tenantId, batchId],
          );
          if (rec == null) {
            return const RollbackRefused(RollbackRefusal.notFound);
          }
          final already = await tx.getOptional(
            'SELECT 1 FROM audit_log WHERE tenant_id = ? AND row_id = ? '
            "AND table_name = 'import_rollbacks'",
            [ctx.tenantId, batchId],
          );
          if (already != null) {
            return const RollbackRefused(RollbackRefusal.alreadyRolledBack);
          }
          final after = _json(rec['after_json']);
          var entries = 0;
          var parties = 0;
          var products = 0;
          var kept = 0;

          if (rec['table_name'] == ImportKind.products.auditTable) {
            for (final id in (after['product_ids'] as List? ?? const [])) {
              final used = await tx.getOptional(
                'SELECT 1 FROM stock_movements WHERE tenant_id = ? '
                'AND product_id = ? LIMIT 1',
                [ctx.tenantId, id],
              );
              if (used != null) {
                kept++;
                continue;
              }
              final at = when.toIso8601String();
              await tx.execute(
                'UPDATE products SET deleted_at = ?, is_active = 0, '
                'updated_at = ? WHERE tenant_id = ? AND id = ? '
                'AND deleted_at IS NULL',
                [at, at, ctx.tenantId, id],
              );
              await AuditWriter.record(
                tx,
                ctx,
                table: 'products',
                rowId: id! as String,
                action: AuditAction.softDelete,
                before: {'import_batch': batchId},
                at: when,
              );
              products++;
            }
          } else {
            final open = await tx.getAll(
              'SELECT id, entry_date FROM ledger_entries e '
              'WHERE e.tenant_id = ? '
              'AND e.ref_id = ? AND e.reverses_id IS NULL AND NOT EXISTS ( '
              'SELECT 1 FROM ledger_entries r WHERE r.tenant_id = e.tenant_id '
              'AND r.reverses_id = e.id)',
              [ctx.tenantId, batchId],
            );
            for (final e in open) {
              final date = LedgerDate.parse(e['entry_date']! as String);
              if (await PeriodLock.refuses(tx, ctx, date)) {
                throw const _Locked();
              }
            }
            final touched = <String>{};
            for (final e in open) {
              final result = await LedgerRepository.reverseIn(
                tx,
                ctx,
                e['id']! as String,
                narration: 'Import rolled back',
                now: when,
              );
              if (result is LedgerPosted) {
                entries++;
                touched.add(result.entries.single.partyId);
              }
            }
            final batchEntryIds = {
              for (final r in await tx.getAll(
                'SELECT id FROM ledger_entries '
                'WHERE tenant_id = ? AND ref_id = ?',
                [ctx.tenantId, batchId],
              ))
                r['id']! as String,
            };
            for (final raw in (after['party_ids'] as List? ?? const [])) {
              final partyId = raw! as String;
              final others = await _otherEntries(
                tx,
                ctx.tenantId,
                partyId,
                batchEntryIds,
              );
              if (others > 0) {
                kept++;
                continue;
              }
              final at = when.toIso8601String();
              await tx.execute(
                'UPDATE parties SET deleted_at = ?, updated_at = ? '
                'WHERE tenant_id = ? AND id = ? AND deleted_at IS NULL',
                [at, at, ctx.tenantId, partyId],
              );
              await AuditWriter.record(
                tx,
                ctx,
                table: 'parties',
                rowId: partyId,
                action: AuditAction.softDelete,
                before: {'import_batch': batchId},
                at: when,
              );
              parties++;
            }
          }

          await AuditWriter.record(
            tx,
            ctx,
            table: 'import_rollbacks',
            rowId: batchId,
            action: AuditAction.reverse,
            after: {
              'entries': entries,
              'parties': parties,
              'products': products,
              'kept': kept,
            },
            at: when,
          );
          return RolledBack(
            entries: entries,
            parties: parties,
            products: products,
            kept: kept,
          );
        })
        .onError<_Locked>(
          (_, _) => const RollbackRefused(RollbackRefusal.lockedYear),
        );
  }

  /// Entries of [partyId] that are not part of the batch (its entries and
  /// the reversals of them).
  static Future<int> _otherEntries(
    SqliteWriteContext tx,
    String tenantId,
    String partyId,
    Set<String> batchEntryIds,
  ) async {
    final rows = await tx.getAll(
      'SELECT id, reverses_id FROM ledger_entries WHERE tenant_id = ? '
      'AND party_id = ?',
      [tenantId, partyId],
    );
    return rows.where((r) {
      final id = r['id']! as String;
      final reverses = r['reverses_id'] as String?;
      return !batchEntryIds.contains(id) &&
          !(reverses != null && batchEntryIds.contains(reverses));
    }).length;
  }
}

class _Stale implements Exception {
  const _Stale(this.row);
  final int row;
}

class _Locked implements Exception {
  const _Locked();
}
