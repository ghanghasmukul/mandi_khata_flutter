// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(saleRepository)
final saleRepositoryProvider = SaleRepositoryProvider._();

final class SaleRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaleRepository>,
          SaleRepository,
          FutureOr<SaleRepository>
        >
    with $FutureModifier<SaleRepository>, $FutureProvider<SaleRepository> {
  SaleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SaleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SaleRepository> create(Ref ref) {
    return saleRepository(ref);
  }
}

String _$saleRepositoryHash() => r'ccb011ec2371fc4be352bd365ea039af0622ecda';

@ProviderFor(returnRepository)
final returnRepositoryProvider = ReturnRepositoryProvider._();

final class ReturnRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReturnRepository>,
          ReturnRepository,
          FutureOr<ReturnRepository>
        >
    with $FutureModifier<ReturnRepository>, $FutureProvider<ReturnRepository> {
  ReturnRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'returnRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$returnRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ReturnRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReturnRepository> create(Ref ref) {
    return returnRepository(ref);
  }
}

String _$returnRepositoryHash() => r'deae7e498e01fe8bd092ea9d9d8a2cdee8140a70';

/// The shop settings of the active business, live; null while loading.

@ProviderFor(shopSettings)
final shopSettingsProvider = ShopSettingsProvider._();

/// The shop settings of the active business, live; null while loading.

final class ShopSettingsProvider
    extends $FunctionalProvider<ShopSettings?, ShopSettings?, ShopSettings?>
    with $Provider<ShopSettings?> {
  /// The shop settings of the active business, live; null while loading.
  ShopSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shopSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shopSettingsHash();

  @$internal
  @override
  $ProviderElement<ShopSettings?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShopSettings? create(Ref ref) {
    return shopSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShopSettings? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShopSettings?>(value),
    );
  }
}

String _$shopSettingsHash() => r'b2d0639321de3465579d10d4bd85435904860b5a';

/// Whether the shop module is switched on (`app.modules.shop`).

@ProviderFor(shopModuleEnabled)
final shopModuleEnabledProvider = ShopModuleEnabledProvider._();

/// Whether the shop module is switched on (`app.modules.shop`).

final class ShopModuleEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the shop module is switched on (`app.modules.shop`).
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

String _$shopModuleEnabledHash() => r'2829a821aa5623ec489d02c8dbbc29ae3d9bc5b0';

/// Bills of the active business matching [filter], newest first. Live.

@ProviderFor(saleList)
final saleListProvider = SaleListFamily._();

/// Bills of the active business matching [filter], newest first. Live.

final class SaleListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SaleRecord>>,
          List<SaleRecord>,
          Stream<List<SaleRecord>>
        >
    with $FutureModifier<List<SaleRecord>>, $StreamProvider<List<SaleRecord>> {
  /// Bills of the active business matching [filter], newest first. Live.
  SaleListProvider._({
    required SaleListFamily super.from,
    required SaleFilter super.argument,
  }) : super(
         retry: null,
         name: r'saleListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleListHash();

  @override
  String toString() {
    return r'saleListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SaleRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SaleRecord>> create(Ref ref) {
    final argument = this.argument as SaleFilter;
    return saleList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SaleListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleListHash() => r'e3830d0e9f27f8afbbd780dc262bdda8963c39fe';

/// Bills of the active business matching [filter], newest first. Live.

final class SaleListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SaleRecord>>, SaleFilter> {
  SaleListFamily._()
    : super(
        retry: null,
        name: r'saleListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Bills of the active business matching [filter], newest first. Live.

  SaleListProvider call(SaleFilter filter) =>
      SaleListProvider._(argument: filter, from: this);

  @override
  String toString() => r'saleListProvider';
}

/// One bill with lines and returns; null if missing. Live.

@ProviderFor(saleDetail)
final saleDetailProvider = SaleDetailFamily._();

/// One bill with lines and returns; null if missing. Live.

final class SaleDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaleDetail?>,
          SaleDetail?,
          Stream<SaleDetail?>
        >
    with $FutureModifier<SaleDetail?>, $StreamProvider<SaleDetail?> {
  /// One bill with lines and returns; null if missing. Live.
  SaleDetailProvider._({
    required SaleDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'saleDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleDetailHash();

  @override
  String toString() {
    return r'saleDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SaleDetail?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SaleDetail?> create(Ref ref) {
    final argument = this.argument as String;
    return saleDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SaleDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleDetailHash() => r'5339978120afbd89d66f7e571c0d623b11cdcb84';

/// One bill with lines and returns; null if missing. Live.

final class SaleDetailFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SaleDetail?>, String> {
  SaleDetailFamily._()
    : super(
        retry: null,
        name: r'saleDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One bill with lines and returns; null if missing. Live.

  SaleDetailProvider call(String id) =>
      SaleDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'saleDetailProvider';
}

@ProviderFor(saleWriter)
final saleWriterProvider = SaleWriterProvider._();

final class SaleWriterProvider
    extends $FunctionalProvider<SaleWriter, SaleWriter, SaleWriter>
    with $Provider<SaleWriter> {
  SaleWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleWriterHash();

  @$internal
  @override
  $ProviderElement<SaleWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaleWriter create(Ref ref) {
    return saleWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleWriter>(value),
    );
  }
}

String _$saleWriterHash() => r'f5a7d09130141315ff951511807bed4b77cbeed8';
