// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registrar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceRegistrar)
final deviceRegistrarProvider = DeviceRegistrarProvider._();

final class DeviceRegistrarProvider
    extends
        $FunctionalProvider<DeviceRegistrar, DeviceRegistrar, DeviceRegistrar>
    with $Provider<DeviceRegistrar> {
  DeviceRegistrarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceRegistrarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceRegistrarHash();

  @$internal
  @override
  $ProviderElement<DeviceRegistrar> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceRegistrar create(Ref ref) {
    return deviceRegistrar(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceRegistrar value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceRegistrar>(value),
    );
  }
}

String _$deviceRegistrarHash() => r'129f1a1b2d233430dadb31dd5df6438272eb459e';
