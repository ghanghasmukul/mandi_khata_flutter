// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arrivals_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lotsRepository)
final lotsRepositoryProvider = LotsRepositoryProvider._();

final class LotsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<LotsRepository>,
          LotsRepository,
          FutureOr<LotsRepository>
        >
    with $FutureModifier<LotsRepository>, $FutureProvider<LotsRepository> {
  LotsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lotsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lotsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<LotsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LotsRepository> create(Ref ref) {
    return lotsRepository(ref);
  }
}

String _$lotsRepositoryHash() => r'cb17199132e5fc7b2d08ecfb6d19d690baf9b375';

/// Lots of the active business matching [filter], newest first. Live.

@ProviderFor(lotList)
final lotListProvider = LotListFamily._();

/// Lots of the active business matching [filter], newest first. Live.

final class LotListProvider
    extends
        $FunctionalProvider<AsyncValue<List<Lot>>, List<Lot>, Stream<List<Lot>>>
    with $FutureModifier<List<Lot>>, $StreamProvider<List<Lot>> {
  /// Lots of the active business matching [filter], newest first. Live.
  LotListProvider._({
    required LotListFamily super.from,
    required LotFilter super.argument,
  }) : super(
         retry: null,
         name: r'lotListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lotListHash();

  @override
  String toString() {
    return r'lotListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Lot>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Lot>> create(Ref ref) {
    final argument = this.argument as LotFilter;
    return lotList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LotListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lotListHash() => r'3177efd78921a9dbb4ef042558d1f3fbed7de6da';

/// Lots of the active business matching [filter], newest first. Live.

final class LotListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Lot>>, LotFilter> {
  LotListFamily._()
    : super(
        retry: null,
        name: r'lotListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Lots of the active business matching [filter], newest first. Live.

  LotListProvider call(LotFilter filter) =>
      LotListProvider._(argument: filter, from: this);

  @override
  String toString() => r'lotListProvider';
}

/// One lot of the active business; null if missing.

@ProviderFor(lot)
final lotProvider = LotFamily._();

/// One lot of the active business; null if missing.

final class LotProvider
    extends $FunctionalProvider<AsyncValue<Lot?>, Lot?, Stream<Lot?>>
    with $FutureModifier<Lot?>, $StreamProvider<Lot?> {
  /// One lot of the active business; null if missing.
  LotProvider._({required LotFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'lotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lotHash();

  @override
  String toString() {
    return r'lotProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Lot?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Lot?> create(Ref ref) {
    final argument = this.argument as String;
    return lot(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LotProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lotHash() => r'e2f94ee4ff09801a260988c95904c3f7ec264c66';

/// One lot of the active business; null if missing.

final class LotFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Lot?>, String> {
  LotFamily._()
    : super(
        retry: null,
        name: r'lotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One lot of the active business; null if missing.

  LotProvider call(String id) => LotProvider._(argument: id, from: this);

  @override
  String toString() => r'lotProvider';
}

/// The khata entries a lot posted, with their reversals. Live.

@ProviderFor(lotEntries)
final lotEntriesProvider = LotEntriesFamily._();

/// The khata entries a lot posted, with their reversals. Live.

final class LotEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LedgerEntry>>,
          List<LedgerEntry>,
          Stream<List<LedgerEntry>>
        >
    with
        $FutureModifier<List<LedgerEntry>>,
        $StreamProvider<List<LedgerEntry>> {
  /// The khata entries a lot posted, with their reversals. Live.
  LotEntriesProvider._({
    required LotEntriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'lotEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lotEntriesHash();

  @override
  String toString() {
    return r'lotEntriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LedgerEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LedgerEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return lotEntries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LotEntriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lotEntriesHash() => r'e315951fe925b51de46951767626f746ac7c78e1';

/// The khata entries a lot posted, with their reversals. Live.

final class LotEntriesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LedgerEntry>>, String> {
  LotEntriesFamily._()
    : super(
        retry: null,
        name: r'lotEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The khata entries a lot posted, with their reversals. Live.

  LotEntriesProvider call(String lotId) =>
      LotEntriesProvider._(argument: lotId, from: this);

  @override
  String toString() => r'lotEntriesProvider';
}

/// The number a new lot on this device will get (form hint).

@ProviderFor(nextLotNo)
final nextLotNoProvider = NextLotNoProvider._();

/// The number a new lot on this device will get (form hint).

final class NextLotNoProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The number a new lot on this device will get (form hint).
  NextLotNoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextLotNoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextLotNoHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return nextLotNo(ref);
  }
}

String _$nextLotNoHash() => r'49fda28e5b4239e4ec1289c50334a699a107e74b';

@ProviderFor(lotWriter)
final lotWriterProvider = LotWriterProvider._();

final class LotWriterProvider
    extends $FunctionalProvider<LotWriter, LotWriter, LotWriter>
    with $Provider<LotWriter> {
  LotWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lotWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lotWriterHash();

  @$internal
  @override
  $ProviderElement<LotWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LotWriter create(Ref ref) {
    return lotWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LotWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LotWriter>(value),
    );
  }
}

String _$lotWriterHash() => r'0b109131df85ef662ccd75eacd2f4e888eeb4698';
