import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/shop_reports/data/shop_reports_repository.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/dues_models.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/gst_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shop_reports_providers.g.dart';

@Riverpod(keepAlive: true)
Future<ShopReportsRepository> shopReportsRepository(Ref ref) async =>
    ShopReportsRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// The shop module switch (`app.modules.shop`); on until the business turns
/// it off.
@riverpod
bool shopModuleEnabled(Ref ref) =>
    ref.watch(settingProvider('app.modules.shop', businessTarget))?.value !=
    false;

@riverpod
Stream<List<SupplierPayable>> supplierPayables(
  Ref ref,
  LedgerDate today,
) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(shopReportsRepositoryProvider.future);
  yield* repo.watchSupplierPayables(tenantId, today: today);
}

@riverpod
Stream<List<CustomerReceivable>> customerReceivables(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(shopReportsRepositoryProvider.future);
  yield* repo.watchCustomerReceivables(tenantId);
}

/// The khata of [partyId] by what created each entry (a snapshot when the
/// dialog opens).
@riverpod
Future<KhataBreakdown> khataBreakdown(Ref ref, String partyId) async {
  final tenantId = ref.watch(activeTenantProvider);
  final repo = await ref.watch(shopReportsRepositoryProvider.future);
  if (tenantId == null) {
    return const KhataBreakdown(parts: {}, balance: Money.zero);
  }
  return await repo.khataBreakdown(tenantId, partyId);
}

@riverpod
Stream<List<SaleLineRecord>> profitRecords(
  Ref ref,
  LedgerDate from,
  LedgerDate to,
) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(shopReportsRepositoryProvider.future);
  yield* repo.watchProfitRecords(tenantId, from: from, to: to);
}

/// One month of GSTR-1 data. Waits for the business settings (GSTIN and
/// state decide intra- or inter-state).
@riverpod
Stream<GstMonthData> gstMonth(Ref ref, int year, int month) async* {
  final tenantId = ref.watch(activeTenantProvider);
  final gstinSetting = ref.watch(
    settingProvider('business.gstin', businessTarget),
  );
  final stateSetting = ref.watch(
    settingProvider('business.state_code', businessTarget),
  );
  if (tenantId == null || gstinSetting == null || stateSetting == null) {
    return;
  }
  final gstin = (gstinSetting.value as String? ?? '').trim();
  final typedState = (stateSetting.value as String? ?? '').trim();
  final state = typedState.isNotEmpty
      ? typedState
      : (GstStates.stateOfGstin(gstin) ?? '');
  final repo = await ref.watch(shopReportsRepositoryProvider.future);
  await for (final invoices in repo.watchGstInvoices(
    tenantId,
    year: year,
    month: month,
    tenantStateCode: state,
  )) {
    yield GstMonthData(
      report: Gstr1Report.build(
        invoices: invoices,
        tenantGstin: gstin,
        tenantStateCode: state,
        year: year,
        month: month,
      ),
      invoices: invoices,
      summary: GstSummary.of(invoices),
      flags: await repo.gstProductFlags(tenantId),
      tenantGstin: gstin,
      tenantStateCode: state,
    );
  }
}

@riverpod
Stream<List<ExpiryRow>> expiryRows(Ref ref, LedgerDate today) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(shopReportsRepositoryProvider.future);
  yield* repo.watchExpiryRows(tenantId, today: today);
}

@riverpod
Stream<List<ReorderSuggestion>> reorderSuggestions(
  Ref ref,
  LedgerDate today,
) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(shopReportsRepositoryProvider.future);
  yield* repo.watchReorderSuggestions(tenantId, today: today);
}
