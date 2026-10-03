import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/onboarding/data/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_providers.g.dart';

@Riverpod(keepAlive: true)
Future<OnboardingRepository> onboardingRepository(Ref ref) async =>
    OnboardingRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// The active business already has parties or khata entries. Null while
/// loading.
@riverpod
Stream<bool> tenantHasData(Ref ref) async* {
  // The gate may drop this provider before the stream is first listened to.
  if (!ref.mounted) return;
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return;
  final repo = await ref.watch(onboardingRepositoryProvider.future);
  if (!ref.mounted) return;
  yield* repo.watchHasData(tenantId);
}

/// The business's own row (name, state, mandi…). Live.
@riverpod
Stream<Map<String, Object?>?> tenantRow(Ref ref) async* {
  // The gate may drop this provider before the stream is first listened to.
  if (!ref.mounted) return;
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return;
  final repo = await ref.watch(onboardingRepositoryProvider.future);
  if (!ref.mounted) return;
  yield* repo.watchTenant(tenantId);
}

/// `onboarding.status` of the active business; null while settings load.
@riverpod
String? onboardingStatus(Ref ref) => ref
    .watch(settingsResolverProvider(businessTarget))
    ?.resolve('onboarding.status')
    .value
    ?.toString();

/// Steps finished (`onboarding.step`); null while settings load.
@riverpod
int? onboardingFinished(Ref ref) =>
    ref
            .watch(settingsResolverProvider(businessTarget))
            ?.resolve('onboarding.step')
            .value
        as int?;

/// Open the wizard by itself? (khata_core `OnboardingRules.needsOnboarding`.)
@riverpod
bool onboardingNeeded(Ref ref) {
  final member = ref.watch(activeMembershipProvider);
  final status = ref.watch(onboardingStatusProvider);
  final hasData = ref.watch(tenantHasDataProvider).value;
  if (member == null || status == null || hasData == null) return false;
  return OnboardingRules.needsOnboarding(
    role: member.role,
    status: status,
    // The wizard only looks at "any data": one flag covers both.
    hasParties: hasData,
    hasEntries: hasData,
    synced: ref.watch(hasSyncedProvider),
  );
}

/// What the wizard saves, as the signed-in member of the active business.
class OnboardingActions {
  OnboardingActions(this._ref);

  final Ref _ref;

  Future<OnboardingSaveFailure?> saveBusiness(
    Map<String, Object?> columns,
  ) async {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return OnboardingSaveFailure.notPermitted;
    }
    final repo = await _ref.read(onboardingRepositoryProvider.future);
    return await repo.updateTenant(ctx, columns, can: member.can);
  }

  Future<OnboardingSaveFailure?> saveCrops(Set<String> activeIds) async {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return OnboardingSaveFailure.notPermitted;
    }
    final repo = await _ref.read(onboardingRepositoryProvider.future);
    return (await repo.setActiveCrops(ctx, activeIds, can: member.can)).failure;
  }

  /// Writes every setting in [values] at business level; the first failure
  /// stops and is returned (nothing is guessed or skipped).
  Future<SettingWriteFailure?> saveSettings(Map<String, Object> values) async {
    final writer = _ref.read(settingsWriterProvider);
    for (final MapEntry(:key, :value) in values.entries) {
      final failure = await writer.write(
        scope: SettingScope.tenant,
        key: key,
        value: value,
      );
      if (failure != null) return failure;
    }
    return null;
  }

  /// Switches the UI to [code] and stores it as the business default.
  Future<SettingWriteFailure?> saveLanguage(String code) async {
    await _ref.read(appLanguageProvider.notifier).set(code);
    return await saveSettings({'app.default_language': code});
  }

  /// Remembers that [finished] steps are done (the wizard resumes there).
  /// A business that has not started becomes `in_progress`; one that is
  /// already `completed` or `skipped` (the wizard re-run from settings) keeps
  /// its status, so abandoning a re-run never forces the wizard open.
  Future<void> markProgress(int finished) async {
    final status = _ref.read(onboardingStatusProvider);
    await saveSettings({
      if (status == null || status == 'not_started')
        'onboarding.status': 'in_progress',
      'onboarding.step': finished,
    });
  }

  Future<SettingWriteFailure?> complete() async => await saveSettings({
    'onboarding.status': 'completed',
    'onboarding.step': OnboardingStep.values.length,
  });

  Future<SettingWriteFailure?> skip() async =>
      await saveSettings({'onboarding.status': 'skipped'});
}

@Riverpod(keepAlive: true)
OnboardingActions onboardingActions(Ref ref) => OnboardingActions(ref);
