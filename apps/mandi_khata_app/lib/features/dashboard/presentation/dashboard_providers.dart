import 'dart:async';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/dashboard/data/dashboard_repository.dart';
import 'package:mandi_khata_app/features/dashboard/domain/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_providers.g.dart';

@Riverpod(keepAlive: true)
Future<DashboardRepository> dashboardRepository(Ref ref) async =>
    DashboardRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Today's date on this device; moves on at midnight so a dashboard left open
/// overnight shows the new day.
@riverpod
Stream<LedgerDate> today(Ref ref) {
  final controller = StreamController<LedgerDate>();
  Timer? timer;
  void emit() {
    final now = DateTime.now();
    controller.add(LedgerDate.fromDateTime(now));
    final midnight = DateTime(now.year, now.month, now.day + 1);
    timer = Timer(midnight.difference(now), emit);
  }

  ref.onDispose(() {
    timer?.cancel();
    unawaited(controller.close());
  });
  emit();
  return controller.stream;
}

/// Runs [watch] for the active business and today's date; empty [fallback]
/// without a business.
Stream<T> _forTenant<T>(
  Ref ref,
  T fallback,
  Stream<T> Function(
    DashboardRepository repo,
    String tenantId,
    LedgerDate today,
  )
  watch,
) async* {
  final tenantId = ref.watch(activeTenantProvider);
  final day = await ref.watch(todayProvider.future);
  if (tenantId == null) {
    yield fallback;
    return;
  }
  final repo = await ref.watch(dashboardRepositoryProvider.future);
  yield* watch(repo, tenantId, day);
}

/// Lots, arhat, payments and receipts of today. Live.
@riverpod
Stream<DaySummary> daySummary(Ref ref) => _forTenant(
  ref,
  DaySummary.empty,
  (repo, tenantId, day) => repo.watchDay(tenantId, day),
);

/// Arhat earned on each of the last ten days. Live.
@riverpod
Stream<List<DayAmount>> earnedDays(Ref ref) => _forTenant(
  ref,
  const [],
  (repo, tenantId, day) => repo.watchEarnedDays(tenantId, day),
);

/// This financial year's sales per crop. Live.
@riverpod
Stream<List<CropSale>> cropMix(Ref ref) => _forTenant(
  ref,
  const [],
  (repo, tenantId, day) => repo.watchCropMix(tenantId, day),
);

/// What we owe and are owed. Live.
@riverpod
Stream<MoneyPosition> moneyPosition(Ref ref) => _forTenant(
  ref,
  MoneyPosition.empty,
  (repo, tenantId, day) => repo.watchPosition(tenantId),
);

/// Cheques due and munshi changes. Live.
@riverpod
Stream<AttentionCounts> attentionCounts(Ref ref) => _forTenant(
  ref,
  AttentionCounts.none,
  (repo, tenantId, day) => repo.watchAttention(tenantId, day),
);
