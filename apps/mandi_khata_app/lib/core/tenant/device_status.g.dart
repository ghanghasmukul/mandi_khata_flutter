// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// True once the owner has revoked THIS install in the active business (the
/// `devices` row synced down with `revoked_at`). The gate then blocks the
/// app; the server already refuses this device's writes.

@ProviderFor(deviceRevoked)
final deviceRevokedProvider = DeviceRevokedProvider._();

/// True once the owner has revoked THIS install in the active business (the
/// `devices` row synced down with `revoked_at`). The gate then blocks the
/// app; the server already refuses this device's writes.

final class DeviceRevokedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// True once the owner has revoked THIS install in the active business (the
  /// `devices` row synced down with `revoked_at`). The gate then blocks the
  /// app; the server already refuses this device's writes.
  DeviceRevokedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceRevokedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceRevokedHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return deviceRevoked(ref);
  }
}

String _$deviceRevokedHash() => r'77841596a9fafb81dfc16cc2e9eb7d7048df2abe';
