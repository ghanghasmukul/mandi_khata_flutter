// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_writer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(writeContext)
final writeContextProvider = WriteContextProvider._();

final class WriteContextProvider
    extends $FunctionalProvider<WriteContext?, WriteContext?, WriteContext?>
    with $Provider<WriteContext?> {
  WriteContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writeContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writeContextHash();

  @$internal
  @override
  $ProviderElement<WriteContext?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WriteContext? create(Ref ref) {
    return writeContext(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WriteContext? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WriteContext?>(value),
    );
  }
}

String _$writeContextHash() => r'3fe08a31c88a6eb70c2b806544800aa4dc0fc9cb';
