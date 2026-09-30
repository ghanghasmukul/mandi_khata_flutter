import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/crops/data/crops_repository.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crops_providers.g.dart';

@Riverpod(keepAlive: true)
Future<CropsRepository> cropsRepository(Ref ref) async =>
    CropsRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Crops of the active business in display order. Live.
@riverpod
Stream<List<Crop>> cropList(Ref ref, {bool includeInactive = false}) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(cropsRepositoryProvider.future);
  yield* repo.watchAll(tenantId, includeInactive: includeInactive);
}

/// One crop of the active business; null if missing.
@riverpod
Stream<Crop?> crop(Ref ref, String id) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(cropsRepositoryProvider.future);
  yield* repo.watchOne(tenantId, id);
}

/// Saves crops as the signed-in member of the active business.
class CropWriter {
  CropWriter(this._ref);

  final Ref _ref;

  Future<CropSaveResult> _run(
    Future<CropSaveResult> Function(
      CropsRepository repo,
      WriteContext ctx,
      bool Function(Permission) can,
    )
    action,
  ) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) return const CropNotPermitted();
    final repo = await _ref.read(cropsRepositoryProvider.future);
    return await action(repo, ctx, member.can);
  }

  Future<CropSaveResult> create(CropInput input) =>
      _run((repo, ctx, can) => repo.create(ctx, input, can: can));

  Future<CropSaveResult> update(String id, CropInput input) =>
      _run((repo, ctx, can) => repo.update(ctx, id, input, can: can));
}

@Riverpod(keepAlive: true)
CropWriter cropWriter(Ref ref) => CropWriter(ref);

extension CropLabels on AppLocalizations {
  String? cropFieldError(CropFieldError? e) => switch (e) {
    null => null,
    CropFieldError.code => cropErrorCode,
    CropFieldError.nameEn => cropErrorName,
    CropFieldError.stdRate => cropErrorRate,
  };
}
