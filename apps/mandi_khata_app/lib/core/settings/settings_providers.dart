import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SettingsRepository> settingsRepository(Ref ref) async =>
    SettingsRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Values that come with the subscription plan. Plans arrive in step 5.1;
/// until then every key falls through to the system default.
@Riverpod(keepAlive: true)
Map<String, Object?> planDefaults(Ref ref) => const {};

/// Setting rows of the active business that can apply to [target]. Live.
@riverpod
Stream<List<SettingRow>> settingRows(Ref ref, SettingsTarget target) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(settingsRepositoryProvider.future);
  yield* repo.watch(tenantId, target);
}

/// A resolver over the rows for [target]; null while loading.
@riverpod
SettingsResolver? settingsResolver(Ref ref, SettingsTarget target) {
  final rows = ref.watch(settingRowsProvider(target)).value;
  if (rows == null) return null;
  return SettingsResolver(rows, planDefaults: ref.watch(planDefaultsProvider));
}

/// The resolved value of [key] for [target] and the level it came from,
/// updating live as settings change or sync. Null while loading.
///
/// ```dart
/// final rate = ref.watch(settingProvider('interest.rate_pa', (
///   partyId: party.id, partyGroupId: null, documentId: null,
/// )));
/// ```
@riverpod
ResolvedSetting? setting(Ref ref, String key, SettingsTarget target) => ref
    .watch(settingsResolverProvider(target))
    ?.resolve(
      key,
      partyId: target.partyId,
      partyGroupId: target.partyGroupId,
      documentId: target.documentId,
    );

/// Saves settings for the signed-in member in the active business.
class SettingsWriter {
  SettingsWriter(this._ref);

  final Ref _ref;

  Future<SettingWriteFailure?> write({
    required SettingScope scope,
    required String key,
    required Object? value,
    String? scopeId,
  }) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) return const SettingNotPermitted();
    final repo = await _ref.read(settingsRepositoryProvider.future);
    return await repo.write(
      ctx,
      scope: scope,
      scopeId: scopeId,
      key: key,
      value: value,
      can: member.can,
    );
  }
}

@Riverpod(keepAlive: true)
SettingsWriter settingsWriter(Ref ref) => SettingsWriter(ref);
