// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interest_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The party's interest terms resolved through the cascade
/// (system → business → group → party), with the supplier / agency default
/// applied. Null while settings load.

@ProviderFor(partyInterestConfig)
final partyInterestConfigProvider = PartyInterestConfigFamily._();

/// The party's interest terms resolved through the cascade
/// (system → business → group → party), with the supplier / agency default
/// applied. Null while settings load.

final class PartyInterestConfigProvider
    extends
        $FunctionalProvider<InterestConfig?, InterestConfig?, InterestConfig?>
    with $Provider<InterestConfig?> {
  /// The party's interest terms resolved through the cascade
  /// (system → business → group → party), with the supplier / agency default
  /// applied. Null while settings load.
  PartyInterestConfigProvider._({
    required PartyInterestConfigFamily super.from,
    required Party super.argument,
  }) : super(
         retry: null,
         name: r'partyInterestConfigProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyInterestConfigHash();

  @override
  String toString() {
    return r'partyInterestConfigProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<InterestConfig?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InterestConfig? create(Ref ref) {
    final argument = this.argument as Party;
    return partyInterestConfig(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InterestConfig? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InterestConfig?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PartyInterestConfigProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyInterestConfigHash() =>
    r'39f83a359f5f3d4fa5fd4510b0b56c907e3d7501';

/// The party's interest terms resolved through the cascade
/// (system → business → group → party), with the supplier / agency default
/// applied. Null while settings load.

final class PartyInterestConfigFamily extends $Family
    with $FunctionalFamilyOverride<InterestConfig?, Party> {
  PartyInterestConfigFamily._()
    : super(
        retry: null,
        name: r'partyInterestConfigProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The party's interest terms resolved through the cascade
  /// (system → business → group → party), with the supplier / agency default
  /// applied. Null while settings load.

  PartyInterestConfigProvider call(Party party) =>
      PartyInterestConfigProvider._(argument: party, from: this);

  @override
  String toString() => r'partyInterestConfigProvider';
}

@ProviderFor(partyInterestWriter)
final partyInterestWriterProvider = PartyInterestWriterProvider._();

final class PartyInterestWriterProvider
    extends
        $FunctionalProvider<
          PartyInterestWriter,
          PartyInterestWriter,
          PartyInterestWriter
        >
    with $Provider<PartyInterestWriter> {
  PartyInterestWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyInterestWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyInterestWriterHash();

  @$internal
  @override
  $ProviderElement<PartyInterestWriter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PartyInterestWriter create(Ref ref) {
    return partyInterestWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PartyInterestWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PartyInterestWriter>(value),
    );
  }
}

String _$partyInterestWriterHash() =>
    r'a79630f4497214473c39a59ba1433f696fb88fa4';
