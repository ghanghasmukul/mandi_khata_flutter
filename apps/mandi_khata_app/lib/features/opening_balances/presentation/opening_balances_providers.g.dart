// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_balances_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(openingBalancesRepository)
final openingBalancesRepositoryProvider = OpeningBalancesRepositoryProvider._();

final class OpeningBalancesRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<OpeningBalancesRepository>,
          OpeningBalancesRepository,
          FutureOr<OpeningBalancesRepository>
        >
    with
        $FutureModifier<OpeningBalancesRepository>,
        $FutureProvider<OpeningBalancesRepository> {
  OpeningBalancesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openingBalancesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openingBalancesRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<OpeningBalancesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OpeningBalancesRepository> create(Ref ref) {
    return openingBalancesRepository(ref);
  }
}

String _$openingBalancesRepositoryHash() =>
    r'e471e5b5c1e1def311ecc92ebc22f096d66ae1df';

@ProviderFor(importFilePicker)
final importFilePickerProvider = ImportFilePickerProvider._();

final class ImportFilePickerProvider
    extends $FunctionalProvider<FilePickerFn, FilePickerFn, FilePickerFn>
    with $Provider<FilePickerFn> {
  ImportFilePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importFilePickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importFilePickerHash();

  @$internal
  @override
  $ProviderElement<FilePickerFn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FilePickerFn create(Ref ref) {
    return importFilePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilePickerFn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilePickerFn>(value),
    );
  }
}

String _$importFilePickerHash() => r'63a0df05c17dadb6ea0171823711fd5b598e9e6b';

@ProviderFor(openingBalanceImporter)
final openingBalanceImporterProvider = OpeningBalanceImporterProvider._();

final class OpeningBalanceImporterProvider
    extends
        $FunctionalProvider<
          OpeningBalanceImporter,
          OpeningBalanceImporter,
          OpeningBalanceImporter
        >
    with $Provider<OpeningBalanceImporter> {
  OpeningBalanceImporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openingBalanceImporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openingBalanceImporterHash();

  @$internal
  @override
  $ProviderElement<OpeningBalanceImporter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OpeningBalanceImporter create(Ref ref) {
    return openingBalanceImporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpeningBalanceImporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpeningBalanceImporter>(value),
    );
  }
}

String _$openingBalanceImporterHash() =>
    r'a7c0e9af060ad330c1e7898516470326260fe9c1';
