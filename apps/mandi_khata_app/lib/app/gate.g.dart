// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gate.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gateStep)
final gateStepProvider = GateStepProvider._();

final class GateStepProvider
    extends $FunctionalProvider<GateStep, GateStep, GateStep>
    with $Provider<GateStep> {
  GateStepProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gateStepProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gateStepHash();

  @$internal
  @override
  $ProviderElement<GateStep> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GateStep create(Ref ref) {
    return gateStep(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GateStep value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GateStep>(value),
    );
  }
}

String _$gateStepHash() => r'e43e87182a641023dd0be53e88d459a15e76ad9d';
