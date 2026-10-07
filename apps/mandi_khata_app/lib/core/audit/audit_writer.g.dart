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

String _$writeContextHash() => r'b490bf64b0c8dfe821224622167baea6dde7056e';

/// The owner's reason while a closed financial year is unlocked on this
/// device (Year close screen); cleared on restart. Only owners' writes
/// carry it (writeContextProvider).

@ProviderFor(LockOverride)
final lockOverrideProvider = LockOverrideProvider._();

/// The owner's reason while a closed financial year is unlocked on this
/// device (Year close screen); cleared on restart. Only owners' writes
/// carry it (writeContextProvider).
final class LockOverrideProvider
    extends $NotifierProvider<LockOverride, String?> {
  /// The owner's reason while a closed financial year is unlocked on this
  /// device (Year close screen); cleared on restart. Only owners' writes
  /// carry it (writeContextProvider).
  LockOverrideProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockOverrideProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockOverrideHash();

  @$internal
  @override
  LockOverride create() => LockOverride();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$lockOverrideHash() => r'a76cad9632af89251ae28df795bd417718aa6db6';

/// The owner's reason while a closed financial year is unlocked on this
/// device (Year close screen); cleared on restart. Only owners' writes
/// carry it (writeContextProvider).

abstract class _$LockOverride extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
