// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(biometricAuth)
final biometricAuthProvider = BiometricAuthProvider._();

final class BiometricAuthProvider
    extends $FunctionalProvider<BiometricAuth, BiometricAuth, BiometricAuth>
    with $Provider<BiometricAuth> {
  BiometricAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricAuthHash();

  @$internal
  @override
  $ProviderElement<BiometricAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BiometricAuth create(Ref ref) {
    return biometricAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiometricAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiometricAuth>(value),
    );
  }
}

String _$biometricAuthHash() => r'99041038f07efa15d22ea11f2beb9f2ac4efdada';

@ProviderFor(biometricAvailable)
final biometricAvailableProvider = BiometricAvailableProvider._();

final class BiometricAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  BiometricAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricAvailableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricAvailableHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return biometricAvailable(ref);
  }
}

String _$biometricAvailableHash() =>
    r'f79c5247272b1ea547ab008886f0421c8dc6f4cd';
