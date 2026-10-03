// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider = OnboardingRepositoryProvider._();

final class OnboardingRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<OnboardingRepository>,
          OnboardingRepository,
          FutureOr<OnboardingRepository>
        >
    with
        $FutureModifier<OnboardingRepository>,
        $FutureProvider<OnboardingRepository> {
  OnboardingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<OnboardingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OnboardingRepository> create(Ref ref) {
    return onboardingRepository(ref);
  }
}

String _$onboardingRepositoryHash() =>
    r'b7aad676cd6f0fb135179e54cf22556d02baece7';

/// The active business already has parties or khata entries. Null while
/// loading.

@ProviderFor(tenantHasData)
final tenantHasDataProvider = TenantHasDataProvider._();

/// The active business already has parties or khata entries. Null while
/// loading.

final class TenantHasDataProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// The active business already has parties or khata entries. Null while
  /// loading.
  TenantHasDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenantHasDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantHasDataHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return tenantHasData(ref);
  }
}

String _$tenantHasDataHash() => r'6f6e633faa67f477abf394fa32b8e9f01da381c9';

/// The business's own row (name, state, mandi…). Live.

@ProviderFor(tenantRow)
final tenantRowProvider = TenantRowProvider._();

/// The business's own row (name, state, mandi…). Live.

final class TenantRowProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Object?>?>,
          Map<String, Object?>?,
          Stream<Map<String, Object?>?>
        >
    with
        $FutureModifier<Map<String, Object?>?>,
        $StreamProvider<Map<String, Object?>?> {
  /// The business's own row (name, state, mandi…). Live.
  TenantRowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenantRowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantRowHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, Object?>?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, Object?>?> create(Ref ref) {
    return tenantRow(ref);
  }
}

String _$tenantRowHash() => r'8df17d292d817d96f35d1f29a0b93b16460975ad';

/// `onboarding.status` of the active business; null while settings load.

@ProviderFor(onboardingStatus)
final onboardingStatusProvider = OnboardingStatusProvider._();

/// `onboarding.status` of the active business; null while settings load.

final class OnboardingStatusProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// `onboarding.status` of the active business; null while settings load.
  OnboardingStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingStatusHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return onboardingStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$onboardingStatusHash() => r'329db9d6a08b53d26a723a063fcd39580ddf3096';

/// Steps finished (`onboarding.step`); null while settings load.

@ProviderFor(onboardingFinished)
final onboardingFinishedProvider = OnboardingFinishedProvider._();

/// Steps finished (`onboarding.step`); null while settings load.

final class OnboardingFinishedProvider
    extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// Steps finished (`onboarding.step`); null while settings load.
  OnboardingFinishedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingFinishedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingFinishedHash();

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return onboardingFinished(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$onboardingFinishedHash() =>
    r'299cfee171bdaeb7f21ae008cf6842a7653515d8';

/// Open the wizard by itself? (khata_core `OnboardingRules.needsOnboarding`.)

@ProviderFor(onboardingNeeded)
final onboardingNeededProvider = OnboardingNeededProvider._();

/// Open the wizard by itself? (khata_core `OnboardingRules.needsOnboarding`.)

final class OnboardingNeededProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Open the wizard by itself? (khata_core `OnboardingRules.needsOnboarding`.)
  OnboardingNeededProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingNeededProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingNeededHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return onboardingNeeded(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onboardingNeededHash() => r'8b3d624f86f3ec6b43a7338b2d4f7e434fabdc0b';

@ProviderFor(onboardingActions)
final onboardingActionsProvider = OnboardingActionsProvider._();

final class OnboardingActionsProvider
    extends
        $FunctionalProvider<
          OnboardingActions,
          OnboardingActions,
          OnboardingActions
        >
    with $Provider<OnboardingActions> {
  OnboardingActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingActionsHash();

  @$internal
  @override
  $ProviderElement<OnboardingActions> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingActions create(Ref ref) {
    return onboardingActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingActions>(value),
    );
  }
}

String _$onboardingActionsHash() => r'7be0ed825514c4cf5197ddb07fbc631d0a393f2a';
