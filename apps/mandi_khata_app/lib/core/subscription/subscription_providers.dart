import 'dart:async';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/env.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/subscription/entitlement_token.dart';
import 'package:mandi_khata_app/core/subscription/subscription_models.dart';
import 'package:mandi_khata_app/core/subscription/subscription_repository.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'subscription_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async =>
    SubscriptionRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Plan, add-ons and subscription of the active business. Null while the
/// first sync has not delivered them (the app then keeps working: the
/// server enforces the plan).
@riverpod
Stream<SubscriptionBundle?> subscriptionBundle(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(subscriptionRepositoryProvider.future);
  yield* repo.watchBundle(tenantId);
}

@riverpod
Stream<SubscriptionUsage?> subscriptionUsage(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(subscriptionRepositoryProvider.future);
  yield* repo.watchUsage(tenantId);
}

@riverpod
Stream<List<PlanRequestRow>> planRequests(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(subscriptionRepositoryProvider.future);
  yield* repo.watchRequests(tenantId);
}

@riverpod
Stream<List<SupportSessionRow>> supportSessions(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(subscriptionRepositoryProvider.future);
  yield* repo.watchSupportSessions(tenantId);
}

/// `offline_tolerance_days` (a public platform setting, default 7).
@riverpod
Stream<int> offlineToleranceDays(Ref ref) async* {
  final repo = await ref.watch(subscriptionRepositoryProvider.future);
  yield* repo.watchIntSetting('offline_tolerance_days', 7);
}

/// The current moment, refreshed every minute so a trial that ends or a
/// grace that runs out is noticed without a restart.
@riverpod
DateTime clockNow(Ref ref) {
  final timer = Timer.periodic(
    const Duration(minutes: 1),
    (_) => ref.invalidateSelf(),
  );
  ref.onDispose(timer.cancel);
  return DateTime.now().toUtc();
}

// ---------------------------------------------------------------------------
// The signed entitlement token
// ---------------------------------------------------------------------------

/// Fetches the signed token after each completed sync (online only), keeps it
/// on the device, and exposes its verified claims.
@Riverpod(keepAlive: true)
class EntitlementTokenStore extends _$EntitlementTokenStore {
  @override
  EntitlementClaims? build() {
    final tenantId = ref.watch(activeTenantProvider);
    if (tenantId == null || Env.entitlementPublicKey.isEmpty) return null;
    unawaited(_load(tenantId));
    // A fresh token after every sync that reached the server.
    ref.listen(syncStatusProvider, (prev, next) {
      final last = next.value?.lastSyncedAt;
      if (last != null && last != prev?.value?.lastSyncedAt) {
        unawaited(refresh(tenantId));
      }
    });
    return null;
  }

  Future<void> _load(String tenantId) async {
    try {
      final saved = ref.read(appPrefsProvider).entitlementToken(tenantId);
      if (saved != null) _accept(tenantId, saved);
    } on Object {
      // No stored token is fine: the synced row decides.
    }
  }

  void _accept(String tenantId, String token) {
    final claims = EntitlementTokenVerifier.verify(
      token,
      Env.entitlementPublicKey,
    );
    if (claims != null && claims.tenantId == tenantId && ref.mounted) {
      state = claims;
    }
  }

  /// Asks the server for a new token. Silent when offline or not configured.
  Future<void> refresh(String tenantId) async {
    if (!Env.hasSupabase) return;
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'entitlement-token',
        body: {'tenant_id': tenantId},
      );
      final data = res.data;
      final token = data is Map ? data['token'] : null;
      if (token is! String) return;
      await ref.read(appPrefsProvider).setEntitlementToken(tenantId, token);
      _accept(tenantId, token);
    } on Object {
      // Offline or the function is not deployed: keep what we have.
    }
  }
}

// ---------------------------------------------------------------------------
// Derived state
// ---------------------------------------------------------------------------

/// A token wins only when it is newer than the synced row (editing the local
/// database cannot extend a subscription); otherwise the synced row does.
({SubscriptionTerms terms, Entitlements entitlements})? _effective(
  SubscriptionBundle? bundle,
  EntitlementClaims? claims,
) {
  if (bundle == null) return null;
  final updated = bundle.subscription.updatedAt;
  if (claims != null && (updated == null || claims.issuedAt.isAfter(updated))) {
    return (terms: claims.terms, entitlements: claims.entitlements);
  }
  final plan = bundle.plan;
  return (
    terms: bundle.subscription.terms,
    // Plans not synced yet: unrestricted, the server enforces.
    entitlements: plan == null
        ? Entitlements.unrestricted
        : bundle.entitlements,
  );
}

/// Full access until a subscription says otherwise.
const openLifecycle = LifecycleState(
  effective: SubscriptionStatus.active,
  access: AccessLevel.full,
  reason: LifecycleReason.none,
);

/// When this device last completed a sync with the server (UTC), or null.
@riverpod
DateTime? lastSyncedAt(Ref ref) =>
    ref.watch(syncStatusProvider).value?.lastSyncedAt?.toUtc();

@riverpod
LifecycleState lifecycle(Ref ref) {
  final bundle = ref.watch(subscriptionBundleProvider).value;
  final eff = _effective(bundle, ref.watch(entitlementTokenStoreProvider));
  if (eff == null) return openLifecycle;
  return Lifecycle.evaluate(
    eff.terms,
    ref.watch(clockNowProvider),
    lastSyncedAt: ref.watch(lastSyncedAtProvider),
    offlineToleranceDays: ref.watch(offlineToleranceDaysProvider).value ?? 7,
  );
}

/// True when nothing new may be written (locked, cancelled, export only).
@riverpod
bool subscriptionReadOnly(Ref ref) => !ref.watch(lifecycleProvider).canWrite;

/// What the plan, add-ons and overrides allow. Everything while unknown.
@riverpod
Entitlements entitlements(Ref ref) {
  final bundle = ref.watch(subscriptionBundleProvider).value;
  return _effective(
        bundle,
        ref.watch(entitlementTokenStoreProvider),
      )?.entitlements ??
      Entitlements.unrestricted;
}

/// Plan default settings (the plan level of the settings cascade).
@riverpod
Map<String, Object?> planSettingDefaults(Ref ref) =>
    ref.watch(subscriptionBundleProvider).value?.planDefaults ?? const {};

/// Plan name and code for display.
@immutable
class PlanSummary {
  const PlanSummary(this.code, this.name);
  final String code;
  final String name;
}

@riverpod
PlanSummary? planSummary(Ref ref) {
  final plan = ref.watch(subscriptionBundleProvider).value?.plan;
  return plan == null ? null : PlanSummary(plan.code, plan.name);
}
