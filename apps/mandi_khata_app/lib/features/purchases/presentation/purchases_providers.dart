import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/purchases/data/purchase_repository.dart';
import 'package:mandi_khata_app/features/purchases/domain/purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchases_providers.g.dart';

@Riverpod(keepAlive: true)
Future<PurchaseRepository> purchaseRepository(Ref ref) async =>
    PurchaseRepository(
      await ref.watch(powerSyncDatabaseProvider.future),
      planDefaults: ref.watch(planDefaultsProvider),
    );

/// Purchases of the active business matching [filter]. Live.
@riverpod
Stream<List<PurchaseSummary>> purchaseList(
  Ref ref,
  PurchaseFilter filter,
) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(purchaseRepositoryProvider.future);
  yield* repo.watchPurchases(tenantId, filter);
}

@riverpod
Stream<PurchaseDetail?> purchaseDetail(Ref ref, String id) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(purchaseRepositoryProvider.future);
  yield* repo.watchPurchase(tenantId, id);
}

/// What each supplier is owed (step 4.4). A breakdown of the khata, never
/// added to the party balance. Live.
@riverpod
Stream<List<SupplierPayable>> supplierPayables(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(purchaseRepositoryProvider.future);
  yield* repo.watchSupplierPayables(tenantId);
}

@riverpod
Stream<List<SupplierOption>> supplierOptions(Ref ref, String query) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(purchaseRepositoryProvider.future);
  yield* repo.watchSuppliers(tenantId, query: query);
}

@riverpod
Future<List<PurchaseProduct>> purchaseProductSearch(
  Ref ref,
  String query,
) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const [];
  final repo = await ref.watch(purchaseRepositoryProvider.future);
  return await repo.searchProducts(tenantId, query);
}

@riverpod
Future<List<PurchaseBatchHint>> purchaseBatchHints(
  Ref ref,
  String productId,
) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const [];
  final repo = await ref.watch(purchaseRepositoryProvider.future);
  return await repo.batchHints(tenantId, productId);
}

/// Credit days default (`shop.supplier_credit_days`).
@riverpod
int supplierCreditDays(Ref ref) =>
    (ref
            .watch(
              settingProvider('shop.supplier_credit_days', (
                partyId: null,
                partyGroupId: null,
                documentId: null,
              )),
            )
            ?.value
        as int?) ??
    30;

/// Records, reverses and returns purchases as the signed-in member.
class PurchaseWriter {
  PurchaseWriter(this._ref);

  final Ref _ref;

  Future<PurchaseResult> _run(
    Future<PurchaseResult> Function(
      PurchaseRepository repo,
      WriteContext ctx,
      bool Function(Permission) can,
    )
    action,
  ) async {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const PurchaseNotPermitted(Permission.purchasesCreate);
    }
    final repo = await _ref.read(purchaseRepositoryProvider.future);
    return await action(repo, ctx, member.can);
  }

  Future<PurchaseResult> create(PurchaseDraft draft) =>
      _run((repo, ctx, can) => repo.create(ctx, draft, can: can));

  Future<PurchaseResult> reverse(String id) =>
      _run((repo, ctx, can) => repo.reverse(ctx, id, can: can));

  Future<PurchaseResult> createReturn(PurchaseReturnDraft draft) =>
      _run((repo, ctx, can) => repo.createReturn(ctx, draft, can: can));

  Future<PurchaseResult> reverseReturn(String id) =>
      _run((repo, ctx, can) => repo.reverseReturn(ctx, id, can: can));
}

@Riverpod(keepAlive: true)
PurchaseWriter purchaseWriter(Ref ref) => PurchaseWriter(ref);
