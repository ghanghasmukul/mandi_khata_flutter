// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parties_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(partiesRepository)
final partiesRepositoryProvider = PartiesRepositoryProvider._();

final class PartiesRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PartiesRepository>,
          PartiesRepository,
          FutureOr<PartiesRepository>
        >
    with
        $FutureModifier<PartiesRepository>,
        $FutureProvider<PartiesRepository> {
  PartiesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partiesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partiesRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<PartiesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PartiesRepository> create(Ref ref) {
    return partiesRepository(ref);
  }
}

String _$partiesRepositoryHash() => r'592dee277eeb7e96146382219b6b048a1e98a7eb';

/// Active parties of the active business matching [query] and [role].

@ProviderFor(partyList)
final partyListProvider = PartyListFamily._();

/// Active parties of the active business matching [query] and [role].

final class PartyListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Party>>,
          List<Party>,
          Stream<List<Party>>
        >
    with $FutureModifier<List<Party>>, $StreamProvider<List<Party>> {
  /// Active parties of the active business matching [query] and [role].
  PartyListProvider._({
    required PartyListFamily super.from,
    required (String, PartyRole?) super.argument,
  }) : super(
         retry: null,
         name: r'partyListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyListHash();

  @override
  String toString() {
    return r'partyListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Party>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Party>> create(Ref ref) {
    final argument = this.argument as (String, PartyRole?);
    return partyList(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyListHash() => r'9e69e900e1038ca5a33238c4b1e0aaee8593b3ae';

/// Active parties of the active business matching [query] and [role].

final class PartyListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Party>>, (String, PartyRole?)> {
  PartyListFamily._()
    : super(
        retry: null,
        name: r'partyListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Active parties of the active business matching [query] and [role].

  PartyListProvider call(String query, PartyRole? role) =>
      PartyListProvider._(argument: (query, role), from: this);

  @override
  String toString() => r'partyListProvider';
}

/// One party of the active business; null if missing or deleted.

@ProviderFor(party)
final partyProvider = PartyFamily._();

/// One party of the active business; null if missing or deleted.

final class PartyProvider
    extends $FunctionalProvider<AsyncValue<Party?>, Party?, Stream<Party?>>
    with $FutureModifier<Party?>, $StreamProvider<Party?> {
  /// One party of the active business; null if missing or deleted.
  PartyProvider._({
    required PartyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyHash();

  @override
  String toString() {
    return r'partyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Party?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Party?> create(Ref ref) {
    final argument = this.argument as String;
    return party(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyHash() => r'8ae599796745516cd29c006c6e363c1ba0b70e44';

/// One party of the active business; null if missing or deleted.

final class PartyFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Party?>, String> {
  PartyFamily._()
    : super(
        retry: null,
        name: r'partyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One party of the active business; null if missing or deleted.

  PartyProvider call(String id) => PartyProvider._(argument: id, from: this);

  @override
  String toString() => r'partyProvider';
}

/// The automatic code a new party would get (form hint).

@ProviderFor(nextPartyCode)
final nextPartyCodeProvider = NextPartyCodeProvider._();

/// The automatic code a new party would get (form hint).

final class NextPartyCodeProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The automatic code a new party would get (form hint).
  NextPartyCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextPartyCodeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextPartyCodeHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return nextPartyCode(ref);
  }
}

String _$nextPartyCodeHash() => r'86a065536d36268086738a0d70932b9716f7aac8';

@ProviderFor(partyWriter)
final partyWriterProvider = PartyWriterProvider._();

final class PartyWriterProvider
    extends $FunctionalProvider<PartyWriter, PartyWriter, PartyWriter>
    with $Provider<PartyWriter> {
  PartyWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyWriterHash();

  @$internal
  @override
  $ProviderElement<PartyWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PartyWriter create(Ref ref) {
    return partyWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PartyWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PartyWriter>(value),
    );
  }
}

String _$partyWriterHash() => r'9b244bcb754a1d581f9cad38b1d6c591b6851494';
