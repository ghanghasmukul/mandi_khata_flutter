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

String _$ledgerRepositoryHash() => r'6a81d7af6ab7e8045ec657c2e943feae26313fa0';

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

/// Every entry of one party's khata in the active business, oldest first.
/// Live. Feeds the interest engine.

@ProviderFor(partyEntries)
final partyEntriesProvider = PartyEntriesFamily._();

/// Every entry of one party's khata in the active business, oldest first.
/// Live. Feeds the interest engine.

final class PartyEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LedgerEntry>>,
          List<LedgerEntry>,
          Stream<List<LedgerEntry>>
        >
    with
        $FutureModifier<List<LedgerEntry>>,
        $StreamProvider<List<LedgerEntry>> {
  /// Every entry of one party's khata in the active business, oldest first.
  /// Live. Feeds the interest engine.
  PartyEntriesProvider._({
    required PartyEntriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyEntriesHash();

  @override
  String toString() {
    return r'partyEntriesProvider'
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
    return partyEntries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyEntriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyEntriesHash() => r'db787c588efbfbfb3c41fdb4cd13b966e7aa64ba';

/// Every entry of one party's khata in the active business, oldest first.
/// Live. Feeds the interest engine.

final class PartyEntriesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LedgerEntry>>, String> {
  PartyEntriesFamily._()
    : super(
        retry: null,
        name: r'partyEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every entry of one party's khata in the active business, oldest first.
  /// Live. Feeds the interest engine.

  PartyEntriesProvider call(String partyId) =>
      PartyEntriesProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyEntriesProvider';
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

/// Count and totals of the day book for [filter]. Live.

@ProviderFor(dayBookSummary)
final dayBookSummaryProvider = DayBookSummaryFamily._();

/// Count and totals of the day book for [filter]. Live.

final class DayBookSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DayBookSummary>,
          DayBookSummary,
          Stream<DayBookSummary>
        >
    with $FutureModifier<DayBookSummary>, $StreamProvider<DayBookSummary> {
  /// Count and totals of the day book for [filter]. Live.
  DayBookSummaryProvider._({
    required DayBookSummaryFamily super.from,
    required LedgerFilter super.argument,
  }) : super(
         retry: null,
         name: r'dayBookSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayBookSummaryHash();

  @override
  String toString() {
    return r'dayBookSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DayBookSummary> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DayBookSummary> create(Ref ref) {
    final argument = this.argument as LedgerFilter;
    return dayBookSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayBookSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayBookSummaryHash() => r'1ef96e33a131c6f283aa642aa98f1a9b30283b88';

/// Count and totals of the day book for [filter]. Live.

final class DayBookSummaryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DayBookSummary>, LedgerFilter> {
  DayBookSummaryFamily._()
    : super(
        retry: null,
        name: r'dayBookSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Count and totals of the day book for [filter]. Live.

  DayBookSummaryProvider call(LedgerFilter filter) =>
      DayBookSummaryProvider._(argument: filter, from: this);

  @override
  String toString() => r'dayBookSummaryProvider';
}

/// Page [page] (of [dayBookPageSize] rows) of the day book. Live; disposed
/// when scrolled away.

@ProviderFor(dayBookPage)
final dayBookPageProvider = DayBookPageFamily._();

/// Page [page] (of [dayBookPageSize] rows) of the day book. Live; disposed
/// when scrolled away.

final class DayBookPageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DayBookRow>>,
          List<DayBookRow>,
          Stream<List<DayBookRow>>
        >
    with $FutureModifier<List<DayBookRow>>, $StreamProvider<List<DayBookRow>> {
  /// Page [page] (of [dayBookPageSize] rows) of the day book. Live; disposed
  /// when scrolled away.
  DayBookPageProvider._({
    required DayBookPageFamily super.from,
    required (LedgerFilter, int) super.argument,
  }) : super(
         retry: null,
         name: r'dayBookPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayBookPageHash();

  @override
  String toString() {
    return r'dayBookPageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<DayBookRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DayBookRow>> create(Ref ref) {
    final argument = this.argument as (LedgerFilter, int);
    return dayBookPage(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DayBookPageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayBookPageHash() => r'bf2e0d07f2993f75753fdec48af08b0b46b708c3';

/// Page [page] (of [dayBookPageSize] rows) of the day book. Live; disposed
/// when scrolled away.

final class DayBookPageFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<DayBookRow>>,
          (LedgerFilter, int)
        > {
  DayBookPageFamily._()
    : super(
        retry: null,
        name: r'dayBookPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Page [page] (of [dayBookPageSize] rows) of the day book. Live; disposed
  /// when scrolled away.

  DayBookPageProvider call(LedgerFilter filter, int page) =>
      DayBookPageProvider._(argument: (filter, page), from: this);

  @override
  String toString() => r'dayBookPageProvider';
}

@ProviderFor(khataWriter)
final khataWriterProvider = KhataWriterProvider._();

final class KhataWriterProvider
    extends $FunctionalProvider<KhataWriter, KhataWriter, KhataWriter>
    with $Provider<KhataWriter> {
  KhataWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'khataWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$khataWriterHash();

  @$internal
  @override
  $ProviderElement<KhataWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KhataWriter create(Ref ref) {
    return khataWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KhataWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KhataWriter>(value),
    );
  }
}

String _$khataWriterHash() => r'2283a6f77dc2928d518d2fc348496129eb412f3d';
