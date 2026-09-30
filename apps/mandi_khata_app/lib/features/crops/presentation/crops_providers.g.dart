// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crops_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cropsRepository)
final cropsRepositoryProvider = CropsRepositoryProvider._();

final class CropsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<CropsRepository>,
          CropsRepository,
          FutureOr<CropsRepository>
        >
    with $FutureModifier<CropsRepository>, $FutureProvider<CropsRepository> {
  CropsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cropsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cropsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<CropsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CropsRepository> create(Ref ref) {
    return cropsRepository(ref);
  }
}

String _$cropsRepositoryHash() => r'a93501b64cecf4d91c664b081223081d615d856c';

/// Crops of the active business in display order. Live.

@ProviderFor(cropList)
final cropListProvider = CropListFamily._();

/// Crops of the active business in display order. Live.

final class CropListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Crop>>,
          List<Crop>,
          Stream<List<Crop>>
        >
    with $FutureModifier<List<Crop>>, $StreamProvider<List<Crop>> {
  /// Crops of the active business in display order. Live.
  CropListProvider._({
    required CropListFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'cropListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cropListHash();

  @override
  String toString() {
    return r'cropListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Crop>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Crop>> create(Ref ref) {
    final argument = this.argument as bool;
    return cropList(ref, includeInactive: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CropListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cropListHash() => r'cf3a1e68f2643be51e73e0c598cf746698e22507';

/// Crops of the active business in display order. Live.

final class CropListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Crop>>, bool> {
  CropListFamily._()
    : super(
        retry: null,
        name: r'cropListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Crops of the active business in display order. Live.

  CropListProvider call({bool includeInactive = false}) =>
      CropListProvider._(argument: includeInactive, from: this);

  @override
  String toString() => r'cropListProvider';
}

/// One crop of the active business; null if missing.

@ProviderFor(crop)
final cropProvider = CropFamily._();

/// One crop of the active business; null if missing.

final class CropProvider
    extends $FunctionalProvider<AsyncValue<Crop?>, Crop?, Stream<Crop?>>
    with $FutureModifier<Crop?>, $StreamProvider<Crop?> {
  /// One crop of the active business; null if missing.
  CropProvider._({
    required CropFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cropProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cropHash();

  @override
  String toString() {
    return r'cropProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Crop?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Crop?> create(Ref ref) {
    final argument = this.argument as String;
    return crop(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CropProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cropHash() => r'518b43f83c28eb25248d3ec8805ee369b64694cf';

/// One crop of the active business; null if missing.

final class CropFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Crop?>, String> {
  CropFamily._()
    : super(
        retry: null,
        name: r'cropProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One crop of the active business; null if missing.

  CropProvider call(String id) => CropProvider._(argument: id, from: this);

  @override
  String toString() => r'cropProvider';
}

@ProviderFor(cropWriter)
final cropWriterProvider = CropWriterProvider._();

final class CropWriterProvider
    extends $FunctionalProvider<CropWriter, CropWriter, CropWriter>
    with $Provider<CropWriter> {
  CropWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cropWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cropWriterHash();

  @$internal
  @override
  $ProviderElement<CropWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CropWriter create(Ref ref) {
    return cropWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CropWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CropWriter>(value),
    );
  }
}

String _$cropWriterHash() => r'2b3c6dcf47d42380a3f42d3be01587b5441aa8a4';
