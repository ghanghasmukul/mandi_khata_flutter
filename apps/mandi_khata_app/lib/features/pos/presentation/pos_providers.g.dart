// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(posCatalogRepository)
final posCatalogRepositoryProvider = PosCatalogRepositoryProvider._();

final class PosCatalogRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PosCatalog>,
          PosCatalog,
          FutureOr<PosCatalog>
        >
    with $FutureModifier<PosCatalog>, $FutureProvider<PosCatalog> {
  PosCatalogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posCatalogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posCatalogRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<PosCatalog> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PosCatalog> create(Ref ref) {
    return posCatalogRepository(ref);
  }
}

String _$posCatalogRepositoryHash() =>
    r'8fc0581a13199e9cae7d6d144e7a1ff76800472e';

@ProviderFor(heldBillsRepository)
final heldBillsRepositoryProvider = HeldBillsRepositoryProvider._();

final class HeldBillsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<HeldBillsRepository>,
          HeldBillsRepository,
          FutureOr<HeldBillsRepository>
        >
    with
        $FutureModifier<HeldBillsRepository>,
        $FutureProvider<HeldBillsRepository> {
  HeldBillsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heldBillsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heldBillsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<HeldBillsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HeldBillsRepository> create(Ref ref) {
    return heldBillsRepository(ref);
  }
}

String _$heldBillsRepositoryHash() =>
    r'bc6d79bd48c0a04a79faf6459ac03141a290afc6';

/// Products with prices and stock for the counter. Live.

@ProviderFor(posCatalog)
final posCatalogProvider = PosCatalogProvider._();

/// Products with prices and stock for the counter. Live.

final class PosCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PosProduct>>,
          List<PosProduct>,
          Stream<List<PosProduct>>
        >
    with $FutureModifier<List<PosProduct>>, $StreamProvider<List<PosProduct>> {
  /// Products with prices and stock for the counter. Live.
  PosCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posCatalogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posCatalogHash();

  @$internal
  @override
  $StreamProviderElement<List<PosProduct>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PosProduct>> create(Ref ref) {
    return posCatalog(ref);
  }
}

String _$posCatalogHash() => r'35780682b44fce73749aca6585128d22942f6ae6';

/// Bills on hold on this device. Live.

@ProviderFor(heldBills)
final heldBillsProvider = HeldBillsProvider._();

/// Bills on hold on this device. Live.

final class HeldBillsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HeldBill>>,
          List<HeldBill>,
          Stream<List<HeldBill>>
        >
    with $FutureModifier<List<HeldBill>>, $StreamProvider<List<HeldBill>> {
  /// Bills on hold on this device. Live.
  HeldBillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heldBillsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heldBillsHash();

  @$internal
  @override
  $StreamProviderElement<List<HeldBill>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HeldBill>> create(Ref ref) {
    return heldBills(ref);
  }
}

String _$heldBillsHash() => r'861dce844c1ed15753c82e63032bb7013bc995b6';

/// The bill being made. Kept alive so a bill survives a trip to another
/// screen.

@ProviderFor(PosCartController)
final posCartControllerProvider = PosCartControllerProvider._();

/// The bill being made. Kept alive so a bill survives a trip to another
/// screen.
final class PosCartControllerProvider
    extends $NotifierProvider<PosCartController, PosCart> {
  /// The bill being made. Kept alive so a bill survives a trip to another
  /// screen.
  PosCartControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posCartControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posCartControllerHash();

  @$internal
  @override
  PosCartController create() => PosCartController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PosCart value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PosCart>(value),
    );
  }
}

String _$posCartControllerHash() => r'78ebbfa72cdd5806e83c2786317a53d507930cb3';

/// The bill being made. Kept alive so a bill survives a trip to another
/// screen.

abstract class _$PosCartController extends $Notifier<PosCart> {
  PosCart build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PosCart, PosCart>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PosCart, PosCart>,
              PosCart,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
