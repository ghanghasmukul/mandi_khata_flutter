import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/subscription/module_access.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/shop_sales/data/return_repository.dart';
import 'package:mandi_khata_app/features/shop_sales/data/sale_repository.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sales_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SaleRepository> saleRepository(Ref ref) async => SaleRepository(
  await ref.watch(powerSyncDatabaseProvider.future),
  planDefaults: ref.watch(planDefaultsProvider),
);

@Riverpod(keepAlive: true)
Future<ReturnRepository> returnRepository(Ref ref) async => ReturnRepository(
  await ref.watch(powerSyncDatabaseProvider.future),
  planDefaults: ref.watch(planDefaultsProvider),
);

/// The shop settings of the active business, live; null while loading.
@riverpod
ShopSettings? shopSettings(Ref ref) {
  final resolver = ref.watch(settingsResolverProvider(businessTarget));
  return resolver == null ? null : ShopSettings.from(resolver);
}

/// Whether the shop module is switched on (`app.modules.shop`).
@riverpod
bool shopModuleEnabled(Ref ref) => ref.watch(moduleEnabledProvider('shop'));

/// Bills of the active business matching [filter], newest first. Live.
@riverpod
Stream<List<SaleRecord>> saleList(Ref ref, SaleFilter filter) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(saleRepositoryProvider.future);
  yield* repo.watchAll(tenantId, filter);
}

/// One bill with lines and returns; null if missing. Live.
@riverpod
Stream<SaleDetail?> saleDetail(Ref ref, String id) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(saleRepositoryProvider.future);
  yield* repo.watchOne(tenantId, id);
}

/// Saves, reverses and returns bills as the signed-in member.
class SaleWriter {
  SaleWriter(this._ref);

  final Ref _ref;

  Future<SaleSaveResult> create(SaleDraft draft) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const SaleNotPermitted(Permission.salesCreate);
    }
    final repo = await _ref.read(saleRepositoryProvider.future);
    return await repo.create(ctx, draft, can: member.can);
  }

  Future<SaleSaveResult> reverse(String id) async {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const SaleNotPermitted(Permission.entriesReverse);
    }
    final repo = await _ref.read(saleRepositoryProvider.future);
    return await repo.reverse(ctx, id, can: member.can);
  }

  Future<ReturnSaveResult> createReturn(ReturnDraft draft) async {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const ReturnNotPermitted(Permission.salesReturn);
    }
    final repo = await _ref.read(returnRepositoryProvider.future);
    return await repo.create(ctx, draft, can: member.can);
  }
}

@Riverpod(keepAlive: true)
SaleWriter saleWriter(Ref ref) => SaleWriter(ref);
