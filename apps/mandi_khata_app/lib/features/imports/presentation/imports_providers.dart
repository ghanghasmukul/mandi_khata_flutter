import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/imports/data/import_batches_repository.dart';
import 'package:mandi_khata_app/features/products/domain/product_import.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'imports_providers.g.dart';

@Riverpod(keepAlive: true)
Future<ImportBatchesRepository> importBatchesRepository(Ref ref) async =>
    ImportBatchesRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Past imports of the active business, newest first. Live.
@riverpod
Stream<List<ImportBatch>> importBatches(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(importBatchesRepositoryProvider.future);
  yield* repo.watchBatches(tenantId);
}

/// Products already in the active business (for duplicate checks), and its
/// category names.
@riverpod
Future<({List<ExistingProduct> products, Map<String, String> categories})>
productImportContext(Ref ref) async {
  final tenantId = ref.watch(activeTenantProvider);
  final db = await ref.watch(powerSyncDatabaseProvider.future);
  if (tenantId == null) {
    return (
      products: const <ExistingProduct>[],
      categories: const <String, String>{},
    );
  }
  // Retired products count too: SKU and barcode stay unique.
  final products = await db.getAll(
    'SELECT sku, barcode FROM products WHERE tenant_id = ?',
    [tenantId],
  );
  final cats = await db.getAll(
    'SELECT id, name FROM product_categories WHERE tenant_id = ? '
    'AND deleted_at IS NULL',
    [tenantId],
  );
  return (
    products: [
      for (final p in products)
        ExistingProduct(
          sku: p['sku']! as String,
          barcode: p['barcode'] as String?,
        ),
    ],
    categories: {
      for (final c in cats) c['name']! as String: c['id']! as String,
    },
  );
}

/// Imports / rolls back as the signed-in member of the active business.
class ImportActions {
  ImportActions(this._ref);

  final Ref _ref;

  Future<ProductImportResult> importProducts(
    ProductImportPreview preview, {
    String? fileName,
  }) async {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) return const ProductsNotPermitted();
    final repo = await _ref.read(importBatchesRepositoryProvider.future);
    return await repo.importProducts(
      ctx,
      preview,
      can: member.can,
      fileName: fileName,
    );
  }

  Future<RollbackResult> rollback(String batchId) async {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const RollbackRefused(RollbackRefusal.notOwner);
    }
    final repo = await _ref.read(importBatchesRepositoryProvider.future);
    return await repo.rollback(
      ctx,
      batchId,
      isOwner: member.role == MemberRole.owner,
    );
  }
}

@riverpod
ImportActions importActions(Ref ref) => ImportActions(ref);
