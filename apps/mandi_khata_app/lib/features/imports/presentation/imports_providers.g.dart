// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imports_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(importBatchesRepository)
final importBatchesRepositoryProvider = ImportBatchesRepositoryProvider._();

final class ImportBatchesRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ImportBatchesRepository>,
          ImportBatchesRepository,
          FutureOr<ImportBatchesRepository>
        >
    with
        $FutureModifier<ImportBatchesRepository>,
        $FutureProvider<ImportBatchesRepository> {
  ImportBatchesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importBatchesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importBatchesRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ImportBatchesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ImportBatchesRepository> create(Ref ref) {
    return importBatchesRepository(ref);
  }
}

String _$importBatchesRepositoryHash() =>
    r'e86de700fae1d29c42ac16cb2c2af696e5e5dc19';

/// Past imports of the active business, newest first. Live.

@ProviderFor(importBatches)
final importBatchesProvider = ImportBatchesProvider._();

/// Past imports of the active business, newest first. Live.

final class ImportBatchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ImportBatch>>,
          List<ImportBatch>,
          Stream<List<ImportBatch>>
        >
    with
        $FutureModifier<List<ImportBatch>>,
        $StreamProvider<List<ImportBatch>> {
  /// Past imports of the active business, newest first. Live.
  ImportBatchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importBatchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importBatchesHash();

  @$internal
  @override
  $StreamProviderElement<List<ImportBatch>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ImportBatch>> create(Ref ref) {
    return importBatches(ref);
  }
}

String _$importBatchesHash() => r'27fa018cd5cfb343add56b0bd41dfa4d97bdb5ac';

/// Products already in the active business (for duplicate checks), and its
/// category names.

@ProviderFor(productImportContext)
final productImportContextProvider = ProductImportContextProvider._();

/// Products already in the active business (for duplicate checks), and its
/// category names.

final class ProductImportContextProvider
    extends
        $FunctionalProvider<
          AsyncValue<
            ({Map<String, String> categories, List<ExistingProduct> products})
          >,
          ({Map<String, String> categories, List<ExistingProduct> products}),
          FutureOr<
            ({Map<String, String> categories, List<ExistingProduct> products})
          >
        >
    with
        $FutureModifier<
          ({Map<String, String> categories, List<ExistingProduct> products})
        >,
        $FutureProvider<
          ({Map<String, String> categories, List<ExistingProduct> products})
        > {
  /// Products already in the active business (for duplicate checks), and its
  /// category names.
  ProductImportContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productImportContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productImportContextHash();

  @$internal
  @override
  $FutureProviderElement<
    ({Map<String, String> categories, List<ExistingProduct> products})
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({Map<String, String> categories, List<ExistingProduct> products})>
  create(Ref ref) {
    return productImportContext(ref);
  }
}

String _$productImportContextHash() =>
    r'bb0f0e3b0fc95ba8d099885c7d3d18bec6307b0d';

@ProviderFor(importActions)
final importActionsProvider = ImportActionsProvider._();

final class ImportActionsProvider
    extends $FunctionalProvider<ImportActions, ImportActions, ImportActions>
    with $Provider<ImportActions> {
  ImportActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importActionsHash();

  @$internal
  @override
  $ProviderElement<ImportActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImportActions create(Ref ref) {
    return importActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportActions>(value),
    );
  }
}

String _$importActionsHash() => r'9e3ce68b26893ba88f2b7ccc26c3bb4ee4b7f4fc';
