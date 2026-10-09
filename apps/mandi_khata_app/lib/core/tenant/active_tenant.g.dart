// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_tenant.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The business the app is working in (its id), or null until one is
/// picked. Every business query filters by this (CLAUDE.md rule 1).
///
/// Restored from the last session without any network, so an offline launch
/// opens straight into the last business.

@ProviderFor(ActiveTenant)
final activeTenantProvider = ActiveTenantProvider._();

/// The business the app is working in (its id), or null until one is
/// picked. Every business query filters by this (CLAUDE.md rule 1).
///
/// Restored from the last session without any network, so an offline launch
/// opens straight into the last business.
final class ActiveTenantProvider
    extends $NotifierProvider<ActiveTenant, String?> {
  /// The business the app is working in (its id), or null until one is
  /// picked. Every business query filters by this (CLAUDE.md rule 1).
  ///
  /// Restored from the last session without any network, so an offline launch
  /// opens straight into the last business.
  ActiveTenantProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeTenantProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeTenantHash();

  @$internal
  @override
  ActiveTenant create() => ActiveTenant();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$activeTenantHash() => r'954325a103f0ae9debe5123667000e30cf4b77fa';

/// The business the app is working in (its id), or null until one is
/// picked. Every business query filters by this (CLAUDE.md rule 1).
///
/// Restored from the last session without any network, so an offline launch
/// opens straight into the last business.

abstract class _$ActiveTenant extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// This device's registration in the active business.

@ProviderFor(activeDevice)
final activeDeviceProvider = ActiveDeviceProvider._();

/// This device's registration in the active business.

final class ActiveDeviceProvider
    extends
        $FunctionalProvider<
          DeviceRegistration?,
          DeviceRegistration?,
          DeviceRegistration?
        >
    with $Provider<DeviceRegistration?> {
  /// This device's registration in the active business.
  ActiveDeviceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeDeviceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeDeviceHash();

  @$internal
  @override
  $ProviderElement<DeviceRegistration?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceRegistration? create(Ref ref) {
    return activeDevice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceRegistration? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceRegistration?>(value),
    );
  }
}

String _$activeDeviceHash() => r'dcdf229c5216870cfc44762bc45cbf036069e71b';

/// The signed-in user's membership in the active business, once loaded.

@ProviderFor(activeMembership)
final activeMembershipProvider = ActiveMembershipProvider._();

/// The signed-in user's membership in the active business, once loaded.

final class ActiveMembershipProvider
    extends $FunctionalProvider<Membership?, Membership?, Membership?>
    with $Provider<Membership?> {
  /// The signed-in user's membership in the active business, once loaded.
  ActiveMembershipProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeMembershipProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeMembershipHash();

  @$internal
  @override
  $ProviderElement<Membership?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Membership? create(Ref ref) {
    return activeMembership(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Membership? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Membership?>(value),
    );
  }
}

String _$activeMembershipHash() => r'7d04c63b995fda709b54c63f6581c1db8f7f947d';
