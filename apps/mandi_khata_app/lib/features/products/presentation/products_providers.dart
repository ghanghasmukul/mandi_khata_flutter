import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/products/data/products_repository.dart';
import 'package:mandi_khata_app/features/products/data/stock_repository.dart';
import 'package:mandi_khata_app/features/products/domain/opening_stock_import.dart';
import 'package:mandi_khata_app/features/products/domain/product.dart';
import 'package:mandi_khata_app/features/products/domain/stock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'products_providers.g.dart';

@Riverpod(keepAlive: true)
Future<ProductsRepository> productsRepository(Ref ref) async =>
    ProductsRepository(await ref.watch(powerSyncDatabaseProvider.future));

@Riverpod(keepAlive: true)
Future<StockRepository> stockRepository(Ref ref) async =>
    StockRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// The stock API of the ACTIVE business for other features (see the header
/// of `stock_repository.dart`); null while no business is picked.
@riverpod
Future<StockApi?> stockApi(Ref ref) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  return StockApi(await ref.watch(stockRepositoryProvider.future), tenantId);
}

/// `app.modules.shop`: the module switch (default on).
@riverpod
bool shopModuleEnabled(Ref ref) =>
    ref.watch(settingProvider('app.modules.shop', businessTarget))?.asBool ??
    true;

/// `shop.expiry_warn_days`
@riverpod
int expiryWarnDays(Ref ref) =>
    ref.watch(settingProvider('shop.expiry_warn_days', businessTarget))?.asInt ??
    60;

/// `shop.price_tiers`
@riverpod
List<String> priceTiers(Ref ref) {
  final v = ref.watch(settingProvider('shop.price_tiers', businessTarget))?.value;
  if (v is List && v.isNotEmpty) return [for (final t in v) t.toString()];
  return PriceTiers.defaultTiers;
}

@riverpod
Stream<List<ProductCategory>> productCategories(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(productsRepositoryProvider.future);
  yield* repo.watchCategories(tenantId);
}

@riverpod
Stream<List<ProductWithStock>> productList(
  Ref ref,
  ProductFilter filter,
) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final warn = ref.watch(expiryWarnDaysProvider);
  final repo = await ref.watch(stockRepositoryProvider.future);
  yield* repo.watchProducts(tenantId, filter: filter, expiryWarnDays: warn);
}

@riverpod
Stream<StockSummary?> stockSummary(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final warn = ref.watch(expiryWarnDaysProvider);
  final repo = await ref.watch(stockRepositoryProvider.future);
  yield* repo.watchSummary(tenantId, expiryWarnDays: warn);
}

@riverpod
Stream<ProductWithStock?> productWithStock(Ref ref, String id) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(stockRepositoryProvider.future);
  yield* repo.watchProduct(tenantId, id);
}

@riverpod
Stream<List<StockMovementRow>> batchMovements(
  Ref ref,
  String productId,
  String batchId,
) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(stockRepositoryProvider.future);
  yield* repo.watchMovements(tenantId, productId, batchId: batchId);
}

@riverpod
Future<String?> suggestedSku(Ref ref) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  final repo = await ref.watch(productsRepositoryProvider.future);
  return await repo.suggestSku(tenantId);
}

/// Runs product and stock writes as the signed-in member.
class ProductsWriter {
  ProductsWriter(this._ref);

  final Ref _ref;

  ({WriteContext ctx, bool Function(Permission) can})? _who() {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) return null;
    return (ctx: ctx, can: member.can);
  }

  Future<ProductResult> save(ProductInput input, {String? id}) async {
    final who = _who();
    if (who == null) {
      return const ProductNotPermitted(Permission.productsManage);
    }
    final repo = await _ref.read(productsRepositoryProvider.future);
    return id == null
        ? await repo.create(who.ctx, input, can: who.can)
        : await repo.update(who.ctx, id, input, can: who.can);
  }

  Future<ProductResult> setActive(String id, {required bool active}) async {
    final who = _who();
    if (who == null) {
      return const ProductNotPermitted(Permission.productsManage);
    }
    final repo = await _ref.read(productsRepositoryProvider.future);
    return await repo.setActive(who.ctx, id, active: active, can: who.can);
  }

  Future<ProductResult> delete(String id) async {
    final who = _who();
    if (who == null) {
      return const ProductNotPermitted(Permission.masterDelete);
    }
    final repo = await _ref.read(productsRepositoryProvider.future);
    return await repo.delete(who.ctx, id, can: who.can);
  }

  Future<String?> addCategory(String name) async {
    final who = _who();
    if (who == null) return null;
    final repo = await _ref.read(productsRepositoryProvider.future);
    return await repo.addCategory(who.ctx, name, can: who.can);
  }

  Future<StockResult> adjust({
    required String productId,
    required String batchId,
    required int deltaMilli,
    required String note,
  }) async {
    final who = _who();
    if (who == null) return const StockNotPermitted(Permission.stockAdjust);
    final repo = await _ref.read(stockRepositoryProvider.future);
    return await repo.adjust(
      who.ctx,
      productId: productId,
      batchId: batchId,
      deltaMilli: deltaMilli,
      note: note,
      can: who.can,
    );
  }

  Future<StockResult> addBatch({
    required String productId,
    required String batchNo,
    required int qtyMilli,
    required Money cost,
    LedgerDate? mfgDate,
    LedgerDate? expiry,
  }) async {
    final who = _who();
    if (who == null) return const StockNotPermitted(Permission.stockAdjust);
    final repo = await _ref.read(stockRepositoryProvider.future);
    return await repo.addOpeningBatch(
      who.ctx,
      productId: productId,
      batchNo: batchNo,
      qtyMilli: qtyMilli,
      cost: cost,
      mfgDate: mfgDate,
      expiry: expiry,
      can: who.can,
    );
  }

  Future<int?> rebuild() async {
    final who = _who();
    if (who == null) return null;
    final repo = await _ref.read(stockRepositoryProvider.future);
    return await repo.rebuildBatchQty(who.ctx, can: who.can);
  }

  Future<List<ProductRef>> productRefs() async {
    final ctx = _ref.read(writeContextProvider);
    if (ctx == null) return const [];
    final repo = await _ref.read(stockRepositoryProvider.future);
    return await repo.productRefs(ctx.tenantId);
  }

  Future<StockResult> importOpening(
    OpeningStockPreview preview,
    LedgerDate asOn,
  ) async {
    final who = _who();
    if (who == null) return const StockNotPermitted(Permission.stockAdjust);
    final repo = await _ref.read(stockRepositoryProvider.future);
    return await repo.importOpening(
      who.ctx,
      preview,
      asOn: asOn,
      can: who.can,
    );
  }
}

@Riverpod(keepAlive: true)
ProductsWriter productsWriter(Ref ref) => ProductsWriter(ref);
