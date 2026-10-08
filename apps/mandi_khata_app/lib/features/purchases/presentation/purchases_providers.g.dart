// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchases_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(purchaseRepository)
final purchaseRepositoryProvider = PurchaseRepositoryProvider._();

final class PurchaseRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PurchaseRepository>,
          PurchaseRepository,
          FutureOr<PurchaseRepository>
        >
    with
        $FutureModifier<PurchaseRepository>,
        $FutureProvider<PurchaseRepository> {
  PurchaseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<PurchaseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PurchaseRepository> create(Ref ref) {
    return purchaseRepository(ref);
  }
}

String _$purchaseRepositoryHash() =>
    r'4ef7d52f7f13ebeca3ca1129f80c812f11cf222a';

/// Purchases of the active business matching [filter]. Live.

@ProviderFor(purchaseList)
final purchaseListProvider = PurchaseListFamily._();

/// Purchases of the active business matching [filter]. Live.

final class PurchaseListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PurchaseSummary>>,
          List<PurchaseSummary>,
          Stream<List<PurchaseSummary>>
        >
    with
        $FutureModifier<List<PurchaseSummary>>,
        $StreamProvider<List<PurchaseSummary>> {
  /// Purchases of the active business matching [filter]. Live.
  PurchaseListProvider._({
    required PurchaseListFamily super.from,
    required PurchaseFilter super.argument,
  }) : super(
         retry: null,
         name: r'purchaseListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseListHash();

  @override
  String toString() {
    return r'purchaseListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PurchaseSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PurchaseSummary>> create(Ref ref) {
    final argument = this.argument as PurchaseFilter;
    return purchaseList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseListHash() => r'ad9b8013be162781959dea4e9779ee6e17098698';

/// Purchases of the active business matching [filter]. Live.

final class PurchaseListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<PurchaseSummary>>,
          PurchaseFilter
        > {
  PurchaseListFamily._()
    : super(
        retry: null,
        name: r'purchaseListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Purchases of the active business matching [filter]. Live.

  PurchaseListProvider call(PurchaseFilter filter) =>
      PurchaseListProvider._(argument: filter, from: this);

  @override
  String toString() => r'purchaseListProvider';
}

@ProviderFor(purchaseDetail)
final purchaseDetailProvider = PurchaseDetailFamily._();

final class PurchaseDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<PurchaseDetail?>,
          PurchaseDetail?,
          Stream<PurchaseDetail?>
        >
    with $FutureModifier<PurchaseDetail?>, $StreamProvider<PurchaseDetail?> {
  PurchaseDetailProvider._({
    required PurchaseDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'purchaseDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseDetailHash();

  @override
  String toString() {
    return r'purchaseDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PurchaseDetail?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PurchaseDetail?> create(Ref ref) {
    final argument = this.argument as String;
    return purchaseDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseDetailHash() => r'9cbd7ddc9d0346315cafb10c540b33e4c145cecc';

final class PurchaseDetailFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PurchaseDetail?>, String> {
  PurchaseDetailFamily._()
    : super(
        retry: null,
        name: r'purchaseDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseDetailProvider call(String id) =>
      PurchaseDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'purchaseDetailProvider';
}

/// What each supplier is owed (step 4.4). A breakdown of the khata, never
/// added to the party balance. Live.

@ProviderFor(supplierPayables)
final supplierPayablesProvider = SupplierPayablesProvider._();

/// What each supplier is owed (step 4.4). A breakdown of the khata, never
/// added to the party balance. Live.

final class SupplierPayablesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SupplierPayable>>,
          List<SupplierPayable>,
          Stream<List<SupplierPayable>>
        >
    with
        $FutureModifier<List<SupplierPayable>>,
        $StreamProvider<List<SupplierPayable>> {
  /// What each supplier is owed (step 4.4). A breakdown of the khata, never
  /// added to the party balance. Live.
  SupplierPayablesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplierPayablesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplierPayablesHash();

  @$internal
  @override
  $StreamProviderElement<List<SupplierPayable>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SupplierPayable>> create(Ref ref) {
    return supplierPayables(ref);
  }
}

String _$supplierPayablesHash() => r'e9bcfa45bdbaf2c464ec45dba6ce67e7c2db7c17';

@ProviderFor(supplierOptions)
final supplierOptionsProvider = SupplierOptionsFamily._();

final class SupplierOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SupplierOption>>,
          List<SupplierOption>,
          Stream<List<SupplierOption>>
        >
    with
        $FutureModifier<List<SupplierOption>>,
        $StreamProvider<List<SupplierOption>> {
  SupplierOptionsProvider._({
    required SupplierOptionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'supplierOptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$supplierOptionsHash();

  @override
  String toString() {
    return r'supplierOptionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SupplierOption>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SupplierOption>> create(Ref ref) {
    final argument = this.argument as String;
    return supplierOptions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SupplierOptionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$supplierOptionsHash() => r'9966a6346163d547b7c728fa9ebc2f468351fff5';

final class SupplierOptionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SupplierOption>>, String> {
  SupplierOptionsFamily._()
    : super(
        retry: null,
        name: r'supplierOptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SupplierOptionsProvider call(String query) =>
      SupplierOptionsProvider._(argument: query, from: this);

  @override
  String toString() => r'supplierOptionsProvider';
}

@ProviderFor(purchaseProductSearch)
final purchaseProductSearchProvider = PurchaseProductSearchFamily._();

final class PurchaseProductSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PurchaseProduct>>,
          List<PurchaseProduct>,
          FutureOr<List<PurchaseProduct>>
        >
    with
        $FutureModifier<List<PurchaseProduct>>,
        $FutureProvider<List<PurchaseProduct>> {
  PurchaseProductSearchProvider._({
    required PurchaseProductSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'purchaseProductSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseProductSearchHash();

  @override
  String toString() {
    return r'purchaseProductSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PurchaseProduct>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PurchaseProduct>> create(Ref ref) {
    final argument = this.argument as String;
    return purchaseProductSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseProductSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseProductSearchHash() =>
    r'882eb8f03fca0ad0d0d382e1e32f63ae049ee886';

final class PurchaseProductSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PurchaseProduct>>, String> {
  PurchaseProductSearchFamily._()
    : super(
        retry: null,
        name: r'purchaseProductSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseProductSearchProvider call(String query) =>
      PurchaseProductSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'purchaseProductSearchProvider';
}

@ProviderFor(purchaseBatchHints)
final purchaseBatchHintsProvider = PurchaseBatchHintsFamily._();

final class PurchaseBatchHintsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PurchaseBatchHint>>,
          List<PurchaseBatchHint>,
          FutureOr<List<PurchaseBatchHint>>
        >
    with
        $FutureModifier<List<PurchaseBatchHint>>,
        $FutureProvider<List<PurchaseBatchHint>> {
  PurchaseBatchHintsProvider._({
    required PurchaseBatchHintsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'purchaseBatchHintsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseBatchHintsHash();

  @override
  String toString() {
    return r'purchaseBatchHintsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PurchaseBatchHint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PurchaseBatchHint>> create(Ref ref) {
    final argument = this.argument as String;
    return purchaseBatchHints(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseBatchHintsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseBatchHintsHash() =>
    r'46cf88fc9e1419f315dff7748d83bb2578746062';

final class PurchaseBatchHintsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PurchaseBatchHint>>, String> {
  PurchaseBatchHintsFamily._()
    : super(
        retry: null,
        name: r'purchaseBatchHintsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseBatchHintsProvider call(String productId) =>
      PurchaseBatchHintsProvider._(argument: productId, from: this);

  @override
  String toString() => r'purchaseBatchHintsProvider';
}

/// Credit days default (`shop.supplier_credit_days`).

@ProviderFor(supplierCreditDays)
final supplierCreditDaysProvider = SupplierCreditDaysProvider._();

/// Credit days default (`shop.supplier_credit_days`).

final class SupplierCreditDaysProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Credit days default (`shop.supplier_credit_days`).
  SupplierCreditDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplierCreditDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplierCreditDaysHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return supplierCreditDays(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$supplierCreditDaysHash() =>
    r'179a5b0ca31dee469b35dff9fbdc25ccb894d332';

@ProviderFor(purchaseWriter)
final purchaseWriterProvider = PurchaseWriterProvider._();

final class PurchaseWriterProvider
    extends $FunctionalProvider<PurchaseWriter, PurchaseWriter, PurchaseWriter>
    with $Provider<PurchaseWriter> {
  PurchaseWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseWriterHash();

  @$internal
  @override
  $ProviderElement<PurchaseWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PurchaseWriter create(Ref ref) {
    return purchaseWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseWriter>(value),
    );
  }
}

String _$purchaseWriterHash() => r'60d64e98831749429e3835d3610bef92a8c44ae3';
