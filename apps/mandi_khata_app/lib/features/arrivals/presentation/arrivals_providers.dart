import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/arrivals/data/lots_repository.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'arrivals_providers.g.dart';

@Riverpod(keepAlive: true)
Future<LotsRepository> lotsRepository(Ref ref) async => LotsRepository(
  await ref.watch(powerSyncDatabaseProvider.future),
  planDefaults: ref.watch(planDefaultsProvider),
);

/// Lots of the active business matching [filter], newest first. Live.
@riverpod
Stream<List<Lot>> lotList(Ref ref, LotFilter filter) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(lotsRepositoryProvider.future);
  yield* repo.watchAll(tenantId, filter);
}

/// One lot of the active business; null if missing.
@riverpod
Stream<Lot?> lot(Ref ref, String id) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(lotsRepositoryProvider.future);
  yield* repo.watchOne(tenantId, id);
}

/// The khata entries a lot posted, with their reversals. Live.
@riverpod
Stream<List<LedgerEntry>> lotEntries(Ref ref, String lotId) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(lotsRepositoryProvider.future);
  yield* repo.watchEntries(tenantId, lotId);
}

/// The number a new lot on this device will get (form hint).
@riverpod
Future<String?> nextLotNo(Ref ref) async {
  final ctx = ref.watch(writeContextProvider);
  if (ctx == null) return null;
  final repo = await ref.watch(lotsRepositoryProvider.future);
  return await repo.previewNextLotNo(ctx);
}

/// Saves lots as the signed-in member of the active business.
class LotWriter {
  LotWriter(this._ref);

  final Ref _ref;

  Future<LotSaveResult> _run(
    Future<LotSaveResult> Function(
      LotsRepository repo,
      WriteContext ctx,
      bool Function(Permission) can,
    )
    action,
  ) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const LotNotPermitted(Permission.arrivalsManage);
    }
    final repo = await _ref.read(lotsRepositoryProvider.future);
    return await action(repo, ctx, member.can);
  }

  Future<LotSaveResult> save(LotDraft draft, {String? id, bool post = true}) =>
      _run(
        (repo, ctx, can) => repo.save(ctx, draft, id: id, post: post, can: can),
      );

  Future<LotSaveResult> reverse(String id) =>
      _run((repo, ctx, can) => repo.reverse(ctx, id, can: can));

  Future<LotSaveResult> cancel(String id) =>
      _run((repo, ctx, can) => repo.cancel(ctx, id, can: can));
}

@Riverpod(keepAlive: true)
LotWriter lotWriter(Ref ref) => LotWriter(ref);

extension LotLabels on AppLocalizations {
  String lotStatus(Lot lot) =>
      lot.isCancelled ? lotStatusCancelled : lotStatusName(lot.status);

  String lotStatusName(LotStatus s) => switch (s) {
    LotStatus.arrived => lotStatusArrived,
    LotStatus.weighed => lotStatusWeighed,
    LotStatus.sold => lotStatusSold,
    LotStatus.posted => lotStatusPosted,
    LotStatus.reversed => lotStatusReversed,
  };

  String lotProblem(LotProblem p) => switch (p) {
    LotProblem.bagsNegative => lotProblemBags,
    LotProblem.weightNotPositive => lotProblemWeight,
    LotProblem.rateNotPositive => lotProblemRate,
    LotProblem.buyerIsFarmer => lotProblemBuyerIsFarmer,
    LotProblem.noWeight => lotProblemNoWeight,
    LotProblem.noRate => lotProblemNoRate,
    LotProblem.buyerRequired => lotProblemBuyerRequired,
    LotProblem.netNotPositive => lotProblemNetNotPositive,
  };

  /// A message for a failed save, or null when it saved.
  String? lotSaveError(LotSaveResult r) => switch (r) {
    LotSaved() => null,
    LotNotPermitted(lockedYear: true) => yearLockedError,
    LotNotPermitted(:final backdateDays?) => khataErrorBackdated(backdateDays),
    LotNotPermitted() => lotErrorNotPermitted,
    LotNotFound() => lotErrorNotFound,
    LotInvalid(:final problems) => [
      for (final p in problems) lotProblem(p),
    ].join('\n'),
    LotLocked() => lotErrorLocked,
  };
}
