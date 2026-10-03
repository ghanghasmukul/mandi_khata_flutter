import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/reports/data/reports_repository.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reports_providers.g.dart';

@Riverpod(keepAlive: true)
Future<ReportsRepository> reportsRepository(Ref ref) async =>
    ReportsRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Each report is read once per filter (a report is a snapshot; the screen's
/// refresh re-reads it). Empty without an active business.
@riverpod
Future<List<OutstandingRow>> outstandingReport(
  Ref ref,
  ReportFilter filter,
  LedgerDate today,
) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const [];
  final repo = await ref.watch(reportsRepositoryProvider.future);
  return await repo.outstanding(
    tenantId,
    asOf: filter.asOf ?? today,
    side: filter.side,
  );
}

@riverpod
Future<List<ArrivalRow>> arrivalsReport(Ref ref, ReportFilter filter) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const [];
  final repo = await ref.watch(reportsRepositoryProvider.future);
  return await repo.arrivals(
    tenantId,
    from: filter.from,
    to: filter.to,
    cropId: filter.cropId,
  );
}

@riverpod
Future<List<CommissionRow>> commissionReport(
  Ref ref,
  ReportFilter filter,
) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const [];
  final repo = await ref.watch(reportsRepositoryProvider.future);
  return await repo.commission(tenantId, from: filter.from, to: filter.to);
}

@riverpod
Future<List<PaymentRow>> paymentsReport(Ref ref, ReportFilter filter) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const [];
  final repo = await ref.watch(reportsRepositoryProvider.future);
  return await repo.payments(
    tenantId,
    from: filter.from,
    to: filter.to,
    mode: filter.mode,
  );
}

@riverpod
Future<List<PartyStatement>> statementsReport(
  Ref ref,
  ReportFilter filter,
) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const [];
  final repo = await ref.watch(reportsRepositoryProvider.future);
  return await repo.farmerStatements(
    tenantId,
    village: filter.village,
    from: filter.from,
    to: filter.to,
  );
}

@riverpod
Future<List<String>> farmerVillages(Ref ref) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const [];
  final repo = await ref.watch(reportsRepositoryProvider.future);
  return await repo.farmerVillages(tenantId);
}
