// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productsRepository)
final productsRepositoryProvider = ProductsRepositoryProvider._();

final class ProductsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProductsRepository>,
          ProductsRepository,
          FutureOr<ProductsRepository>
        >
    with
        $FutureModifier<ProductsRepository>,
        $FutureProvider<ProductsRepository> {
  ProductsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ProductsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProductsRepository> create(Ref ref) {
    return productsRepository(ref);
  }
}

String _$productsRepositoryHash() =>
    r'00d209b012271cf1aa0b052da5e84d82bfea3c27';

@ProviderFor(stockRepository)
final stockRepositoryProvider = StockRepositoryProvider._();

final class StockRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<StockRepository>,
          StockRepository,
          FutureOr<StockRepository>
        >
    with $FutureModifier<StockRepository>, $FutureProvider<StockRepository> {
  StockRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<StockRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StockRepository> create(Ref ref) {
    return stockRepository(ref);
  }
}

String _$stockRepositoryHash() => r'91beaa8e4616f06d92bc87c445063ddc37f8efba';

/// The stock API of the ACTIVE business for other features (see the header
/// of `stock_repository.dart`); null while no business is picked.

@ProviderFor(stockApi)
final stockApiProvider = StockApiProvider._();

/// The stock API of the ACTIVE business for other features (see the header
/// of `stock_repository.dart`); null while no business is picked.

final class StockApiProvider
    extends
        $FunctionalProvider<
          AsyncValue<StockApi?>,
          StockApi?,
          FutureOr<StockApi?>
        >
    with $FutureModifier<StockApi?>, $FutureProvider<StockApi?> {
  /// The stock API of the ACTIVE business for other features (see the header
  /// of `stock_repository.dart`); null while no business is picked.
  StockApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockApiHash();

  @$internal
  @override
  $FutureProviderElement<StockApi?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<StockApi?> create(Ref ref) {
    return stockApi(ref);
  }
}

String _$stockApiHash() => r'5e0e054501f84f17eff0f1704a54e8c60ef25bc1';

/// `app.modules.shop`: the module switch (default on).

@ProviderFor(shopModuleEnabled)
final shopModuleEnabledProvider = ShopModuleEnabledProvider._();

/// `app.modules.shop`: the module switch (default on).

final class ShopModuleEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// `app.modules.shop`: the module switch (default on).
  ShopModuleEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shopModuleEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shopModuleEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return shopModuleEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shopModuleEnabledHash() => r'270c72d46d4f0bbf1075c3db96be99c72c17370b';

/// `shop.expiry_warn_days`

@ProviderFor(expiryWarnDays)
final expiryWarnDaysProvider = ExpiryWarnDaysProvider._();

/// `shop.expiry_warn_days`

final class ExpiryWarnDaysProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// `shop.expiry_warn_days`
  ExpiryWarnDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expiryWarnDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expiryWarnDaysHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return expiryWarnDays(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$expiryWarnDaysHash() => r'df09b1ec337d7f1806bdc8e9b603196c8102182b';

/// `shop.price_tiers`

@ProviderFor(priceTiers)
final priceTiersProvider = PriceTiersProvider._();

/// `shop.price_tiers`

final class PriceTiersProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// `shop.price_tiers`
  PriceTiersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'priceTiersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$priceTiersHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return priceTiers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$priceTiersHash() => r'b589a2c753b424d0c6efaebfd20aa2c8e3589fbb';

@ProviderFor(productCategories)
final productCategoriesProvider = ProductCategoriesProvider._();

final class ProductCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductCategory>>,
          List<ProductCategory>,
          Stream<List<ProductCategory>>
        >
    with
        $FutureModifier<List<ProductCategory>>,
        $StreamProvider<List<ProductCategory>> {
  ProductCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<ProductCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProductCategory>> create(Ref ref) {
    return productCategories(ref);
  }
}

String _$productCategoriesHash() => r'ab2c4c7b422a1629141fc719466cffd6e3d62c72';

@ProviderFor(productList)
final productListProvider = ProductListFamily._();

final class ProductListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductWithStock>>,
          List<ProductWithStock>,
          Stream<List<ProductWithStock>>
        >
    with
        $FutureModifier<List<ProductWithStock>>,
        $StreamProvider<List<ProductWithStock>> {
  ProductListProvider._({
    required ProductListFamily super.from,
    required ProductFilter super.argument,
  }) : super(
         retry: null,
         name: r'productListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productListHash();

  @override
  String toString() {
    return r'productListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ProductWithStock>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProductWithStock>> create(Ref ref) {
    final argument = this.argument as ProductFilter;
    return productList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productListHash() => r'7cc92eac7948202315de06595d5bbad2f969ee26';

final class ProductListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<ProductWithStock>>,
          ProductFilter
        > {
  ProductListFamily._()
    : super(
        retry: null,
        name: r'productListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductListProvider call(ProductFilter filter) =>
      ProductListProvider._(argument: filter, from: this);

  @override
  String toString() => r'productListProvider';
}

@ProviderFor(stockSummary)
final stockSummaryProvider = StockSummaryProvider._();

final class StockSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<StockSummary?>,
          StockSummary?,
          Stream<StockSummary?>
        >
    with $FutureModifier<StockSummary?>, $StreamProvider<StockSummary?> {
  StockSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockSummaryHash();

  @$internal
  @override
  $StreamProviderElement<StockSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StockSummary?> create(Ref ref) {
    return stockSummary(ref);
  }
}

String _$stockSummaryHash() => r'233af322fc05d29b967e1e68eb4462f6cc8b08c0';

@ProviderFor(productWithStock)
final productWithStockProvider = ProductWithStockFamily._();

final class ProductWithStockProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProductWithStock?>,
          ProductWithStock?,
          Stream<ProductWithStock?>
        >
    with
        $FutureModifier<ProductWithStock?>,
        $StreamProvider<ProductWithStock?> {
  ProductWithStockProvider._({
    required ProductWithStockFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productWithStockProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productWithStockHash();

  @override
  String toString() {
    return r'productWithStockProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ProductWithStock?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ProductWithStock?> create(Ref ref) {
    final argument = this.argument as String;
    return productWithStock(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductWithStockProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productWithStockHash() => r'43e4655b22fa70572ad8e76185aaad6580e38177';

final class ProductWithStockFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ProductWithStock?>, String> {
  ProductWithStockFamily._()
    : super(
        retry: null,
        name: r'productWithStockProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductWithStockProvider call(String id) =>
      ProductWithStockProvider._(argument: id, from: this);

  @override
  String toString() => r'productWithStockProvider';
}

@ProviderFor(batchMovements)
final batchMovementsProvider = BatchMovementsFamily._();

final class BatchMovementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StockMovementRow>>,
          List<StockMovementRow>,
          Stream<List<StockMovementRow>>
        >
    with
        $FutureModifier<List<StockMovementRow>>,
        $StreamProvider<List<StockMovementRow>> {
  BatchMovementsProvider._({
    required BatchMovementsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'batchMovementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$batchMovementsHash();

  @override
  String toString() {
    return r'batchMovementsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<StockMovementRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StockMovementRow>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return batchMovements(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is BatchMovementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$batchMovementsHash() => r'2c6be853bc1a9824dfe856b5f775c4ecbc5cd2a3';

final class BatchMovementsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<StockMovementRow>>,
          (String, String)
        > {
  BatchMovementsFamily._()
    : super(
        retry: null,
        name: r'batchMovementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BatchMovementsProvider call(String productId, String batchId) =>
      BatchMovementsProvider._(argument: (productId, batchId), from: this);

  @override
  String toString() => r'batchMovementsProvider';
}

@ProviderFor(suggestedSku)
final suggestedSkuProvider = SuggestedSkuProvider._();

final class SuggestedSkuProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  SuggestedSkuProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestedSkuProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestedSkuHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return suggestedSku(ref);
  }
}

String _$suggestedSkuHash() => r'0455c61355f99483d6e4a89ea4853a8f5d4ebb38';

@ProviderFor(productsWriter)
final productsWriterProvider = ProductsWriterProvider._();

final class ProductsWriterProvider
    extends $FunctionalProvider<ProductsWriter, ProductsWriter, ProductsWriter>
    with $Provider<ProductsWriter> {
  ProductsWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsWriterHash();

  @$internal
  @override
  $ProviderElement<ProductsWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProductsWriter create(Ref ref) {
    return productsWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductsWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductsWriter>(value),
    );
  }
}

String _$productsWriterHash() => r'9693bc05b5ab9aa6dd533bd3827eb38e29dbf283';
