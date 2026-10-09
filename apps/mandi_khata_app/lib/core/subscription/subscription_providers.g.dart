// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subscriptionRepository)
final subscriptionRepositoryProvider = SubscriptionRepositoryProvider._();

final class SubscriptionRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SubscriptionRepository>,
          SubscriptionRepository,
          FutureOr<SubscriptionRepository>
        >
    with
        $FutureModifier<SubscriptionRepository>,
        $FutureProvider<SubscriptionRepository> {
  SubscriptionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SubscriptionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SubscriptionRepository> create(Ref ref) {
    return subscriptionRepository(ref);
  }
}

String _$subscriptionRepositoryHash() =>
    r'0931d7a1bb02d190b54f1acc812c8803be5ee9ce';

/// Plan, add-ons and subscription of the active business. Null while the
/// first sync has not delivered them (the app then keeps working: the
/// server enforces the plan).

@ProviderFor(subscriptionBundle)
final subscriptionBundleProvider = SubscriptionBundleProvider._();

/// Plan, add-ons and subscription of the active business. Null while the
/// first sync has not delivered them (the app then keeps working: the
/// server enforces the plan).

final class SubscriptionBundleProvider
    extends
        $FunctionalProvider<
          AsyncValue<SubscriptionBundle?>,
          SubscriptionBundle?,
          Stream<SubscriptionBundle?>
        >
    with
        $FutureModifier<SubscriptionBundle?>,
        $StreamProvider<SubscriptionBundle?> {
  /// Plan, add-ons and subscription of the active business. Null while the
  /// first sync has not delivered them (the app then keeps working: the
  /// server enforces the plan).
  SubscriptionBundleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionBundleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionBundleHash();

  @$internal
  @override
  $StreamProviderElement<SubscriptionBundle?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SubscriptionBundle?> create(Ref ref) {
    return subscriptionBundle(ref);
  }
}

String _$subscriptionBundleHash() =>
    r'7800073546f64ce65e7fa4e0ebd6ee1b27cc1ac4';

@ProviderFor(subscriptionUsage)
final subscriptionUsageProvider = SubscriptionUsageProvider._();

final class SubscriptionUsageProvider
    extends
        $FunctionalProvider<
          AsyncValue<SubscriptionUsage?>,
          SubscriptionUsage?,
          Stream<SubscriptionUsage?>
        >
    with
        $FutureModifier<SubscriptionUsage?>,
        $StreamProvider<SubscriptionUsage?> {
  SubscriptionUsageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionUsageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionUsageHash();

  @$internal
  @override
  $StreamProviderElement<SubscriptionUsage?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SubscriptionUsage?> create(Ref ref) {
    return subscriptionUsage(ref);
  }
}

String _$subscriptionUsageHash() => r'4a0d5426d0f6496de61719e61d3e7a189a271d08';

@ProviderFor(planRequests)
final planRequestsProvider = PlanRequestsProvider._();

final class PlanRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlanRequestRow>>,
          List<PlanRequestRow>,
          Stream<List<PlanRequestRow>>
        >
    with
        $FutureModifier<List<PlanRequestRow>>,
        $StreamProvider<List<PlanRequestRow>> {
  PlanRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<PlanRequestRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PlanRequestRow>> create(Ref ref) {
    return planRequests(ref);
  }
}

String _$planRequestsHash() => r'dab6337963c8a0c5b37544fae6630a7a57fd96b5';

@ProviderFor(supportSessions)
final supportSessionsProvider = SupportSessionsProvider._();

final class SupportSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SupportSessionRow>>,
          List<SupportSessionRow>,
          Stream<List<SupportSessionRow>>
        >
    with
        $FutureModifier<List<SupportSessionRow>>,
        $StreamProvider<List<SupportSessionRow>> {
  SupportSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportSessionsHash();

  @$internal
  @override
  $StreamProviderElement<List<SupportSessionRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SupportSessionRow>> create(Ref ref) {
    return supportSessions(ref);
  }
}

String _$supportSessionsHash() => r'48ebb370d97e3213028ef9d679fcb1509d34fb99';

/// `offline_tolerance_days` (a public platform setting, default 7).

@ProviderFor(offlineToleranceDays)
final offlineToleranceDaysProvider = OfflineToleranceDaysProvider._();

/// `offline_tolerance_days` (a public platform setting, default 7).

final class OfflineToleranceDaysProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// `offline_tolerance_days` (a public platform setting, default 7).
  OfflineToleranceDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineToleranceDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineToleranceDaysHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return offlineToleranceDays(ref);
  }
}

String _$offlineToleranceDaysHash() =>
    r'db329ddee8dd8bded4df428ef2dc2eb282c5f210';

/// The current moment, refreshed every minute so a trial that ends or a
/// grace that runs out is noticed without a restart.

@ProviderFor(clockNow)
final clockNowProvider = ClockNowProvider._();

/// The current moment, refreshed every minute so a trial that ends or a
/// grace that runs out is noticed without a restart.

final class ClockNowProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// The current moment, refreshed every minute so a trial that ends or a
  /// grace that runs out is noticed without a restart.
  ClockNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockNowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockNowHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return clockNow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$clockNowHash() => r'efa03c05ec9c468ec86b59d8e35e371a525014dc';

/// Fetches the signed token after each completed sync (online only), keeps it
/// on the device, and exposes its verified claims.

@ProviderFor(EntitlementTokenStore)
final entitlementTokenStoreProvider = EntitlementTokenStoreProvider._();

/// Fetches the signed token after each completed sync (online only), keeps it
/// on the device, and exposes its verified claims.
final class EntitlementTokenStoreProvider
    extends $NotifierProvider<EntitlementTokenStore, EntitlementClaims?> {
  /// Fetches the signed token after each completed sync (online only), keeps it
  /// on the device, and exposes its verified claims.
  EntitlementTokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitlementTokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitlementTokenStoreHash();

  @$internal
  @override
  EntitlementTokenStore create() => EntitlementTokenStore();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntitlementClaims? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntitlementClaims?>(value),
    );
  }
}

String _$entitlementTokenStoreHash() =>
    r'805084f48bd7f51842ef0cbf89dcfe37ad8bc30a';

/// Fetches the signed token after each completed sync (online only), keeps it
/// on the device, and exposes its verified claims.

abstract class _$EntitlementTokenStore extends $Notifier<EntitlementClaims?> {
  EntitlementClaims? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<EntitlementClaims?, EntitlementClaims?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EntitlementClaims?, EntitlementClaims?>,
              EntitlementClaims?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// When this device last completed a sync with the server (UTC), or null.

@ProviderFor(lastSyncedAt)
final lastSyncedAtProvider = LastSyncedAtProvider._();

/// When this device last completed a sync with the server (UTC), or null.

final class LastSyncedAtProvider
    extends $FunctionalProvider<DateTime?, DateTime?, DateTime?>
    with $Provider<DateTime?> {
  /// When this device last completed a sync with the server (UTC), or null.
  LastSyncedAtProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastSyncedAtProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastSyncedAtHash();

  @$internal
  @override
  $ProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime? create(Ref ref) {
    return lastSyncedAt(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$lastSyncedAtHash() => r'901caa927afa0e4a9cdfec0aea4719ed6eddcae9';

@ProviderFor(lifecycle)
final lifecycleProvider = LifecycleProvider._();

final class LifecycleProvider
    extends $FunctionalProvider<LifecycleState, LifecycleState, LifecycleState>
    with $Provider<LifecycleState> {
  LifecycleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lifecycleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lifecycleHash();

  @$internal
  @override
  $ProviderElement<LifecycleState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LifecycleState create(Ref ref) {
    return lifecycle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LifecycleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LifecycleState>(value),
    );
  }
}

String _$lifecycleHash() => r'f6cc06bc179801a54d4fbc4e19321ab7f0fcddf7';

/// True when nothing new may be written (locked, cancelled, export only).

@ProviderFor(subscriptionReadOnly)
final subscriptionReadOnlyProvider = SubscriptionReadOnlyProvider._();

/// True when nothing new may be written (locked, cancelled, export only).

final class SubscriptionReadOnlyProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// True when nothing new may be written (locked, cancelled, export only).
  SubscriptionReadOnlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionReadOnlyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionReadOnlyHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return subscriptionReadOnly(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$subscriptionReadOnlyHash() =>
    r'0c9aa223935f712d70ba6372c63fbeb5f7bf0828';

/// What the plan, add-ons and overrides allow. Everything while unknown.

@ProviderFor(entitlements)
final entitlementsProvider = EntitlementsProvider._();

/// What the plan, add-ons and overrides allow. Everything while unknown.

final class EntitlementsProvider
    extends $FunctionalProvider<Entitlements, Entitlements, Entitlements>
    with $Provider<Entitlements> {
  /// What the plan, add-ons and overrides allow. Everything while unknown.
  EntitlementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitlementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitlementsHash();

  @$internal
  @override
  $ProviderElement<Entitlements> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Entitlements create(Ref ref) {
    return entitlements(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Entitlements value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Entitlements>(value),
    );
  }
}

String _$entitlementsHash() => r'adf9c7ad51bb9278dd43d8a4351796a032f4e6d7';

/// Plan default settings (the plan level of the settings cascade).

@ProviderFor(planSettingDefaults)
final planSettingDefaultsProvider = PlanSettingDefaultsProvider._();

/// Plan default settings (the plan level of the settings cascade).

final class PlanSettingDefaultsProvider
    extends
        $FunctionalProvider<
          Map<String, Object?>,
          Map<String, Object?>,
          Map<String, Object?>
        >
    with $Provider<Map<String, Object?>> {
  /// Plan default settings (the plan level of the settings cascade).
  PlanSettingDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planSettingDefaultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planSettingDefaultsHash();

  @$internal
  @override
  $ProviderElement<Map<String, Object?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, Object?> create(Ref ref) {
    return planSettingDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Object?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Object?>>(value),
    );
  }
}

String _$planSettingDefaultsHash() =>
    r'2c5d003d01f8ff9477b3ffd13233126a27416e5e';

@ProviderFor(planSummary)
final planSummaryProvider = PlanSummaryProvider._();

final class PlanSummaryProvider
    extends $FunctionalProvider<PlanSummary?, PlanSummary?, PlanSummary?>
    with $Provider<PlanSummary?> {
  PlanSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planSummaryHash();

  @$internal
  @override
  $ProviderElement<PlanSummary?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlanSummary? create(Ref ref) {
    return planSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanSummary? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanSummary?>(value),
    );
  }
}

String _$planSummaryHash() => r'ea27f1a23b8b87fee72e8b85434b6554d0bd7e89';
