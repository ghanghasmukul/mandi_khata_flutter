// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khata_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ledgerRepository)
final ledgerRepositoryProvider = LedgerRepositoryProvider._();

final class LedgerRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<LedgerRepository>,
          LedgerRepository,
          FutureOr<LedgerRepository>
        >
    with $FutureModifier<LedgerRepository>, $FutureProvider<LedgerRepository> {
  LedgerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ledgerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ledgerRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<LedgerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LedgerRepository> create(Ref ref) {
    return ledgerRepository(ref);
  }
}

String _$ledgerRepositoryHash() => r'a275eb8741e488b9d1516c73fed4428f3e54866f';

/// A party's khata statement in the active business for [from]..[to]
/// (either open).

@ProviderFor(partyStatement)
final partyStatementProvider = PartyStatementFamily._();

/// A party's khata statement in the active business for [from]..[to]
/// (either open).

final class PartyStatementProvider
    extends
        $FunctionalProvider<AsyncValue<Statement>, Statement, Stream<Statement>>
    with $FutureModifier<Statement>, $StreamProvider<Statement> {
  /// A party's khata statement in the active business for [from]..[to]
  /// (either open).
  PartyStatementProvider._({
    required PartyStatementFamily super.from,
    required (String, {LedgerDate? from, LedgerDate? to}) super.argument,
  }) : super(
         retry: null,
         name: r'partyStatementProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyStatementHash();

  @override
  String toString() {
    return r'partyStatementProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<Statement> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Statement> create(Ref ref) {
    final argument =
        this.argument as (String, {LedgerDate? from, LedgerDate? to});
    return partyStatement(
      ref,
      argument.$1,
      from: argument.from,
      to: argument.to,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PartyStatementProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyStatementHash() => r'd8fa30fb9d0afc711dc6c3235244068b0dd74b85';

/// A party's khata statement in the active business for [from]..[to]
/// (either open).

final class PartyStatementFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Statement>,
          (String, {LedgerDate? from, LedgerDate? to})
        > {
  PartyStatementFamily._()
    : super(
        retry: null,
        name: r'partyStatementProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A party's khata statement in the active business for [from]..[to]
  /// (either open).

  PartyStatementProvider call(
    String partyId, {
    LedgerDate? from,
    LedgerDate? to,
  }) => PartyStatementProvider._(
    argument: (partyId, from: from, to: to),
    from: this,
  );

  @override
  String toString() => r'partyStatementProvider';
}

/// Balance of every party with entries in the active business.

@ProviderFor(partyBalances)
final partyBalancesProvider = PartyBalancesProvider._();

/// Balance of every party with entries in the active business.

final class PartyBalancesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Money>>,
          Map<String, Money>,
          Stream<Map<String, Money>>
        >
    with
        $FutureModifier<Map<String, Money>>,
        $StreamProvider<Map<String, Money>> {
  /// Balance of every party with entries in the active business.
  PartyBalancesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyBalancesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyBalancesHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, Money>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, Money>> create(Ref ref) {
    return partyBalances(ref);
  }
}

String _$partyBalancesHash() => r'85c412863cc9031e85a630a0bec22f8b7b3f8b6e';
