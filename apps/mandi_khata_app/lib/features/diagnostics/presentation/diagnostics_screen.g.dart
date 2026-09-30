// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostics_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Size of the local database file in bytes (works on web too).

@ProviderFor(databaseSize)
final databaseSizeProvider = DatabaseSizeProvider._();

/// Size of the local database file in bytes (works on web too).

final class DatabaseSizeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Size of the local database file in bytes (works on web too).
  DatabaseSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseSizeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseSizeHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return databaseSize(ref);
  }
}

String _$databaseSizeHash() => r'10b92d4a871b2046ec2ce58ff24e532424f9b659';

@ProviderFor(syncErrorActions)
final syncErrorActionsProvider = SyncErrorActionsProvider._();

final class SyncErrorActionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncErrorActions>,
          SyncErrorActions,
          FutureOr<SyncErrorActions>
        >
    with $FutureModifier<SyncErrorActions>, $FutureProvider<SyncErrorActions> {
  SyncErrorActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncErrorActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncErrorActionsHash();

  @$internal
  @override
  $FutureProviderElement<SyncErrorActions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SyncErrorActions> create(Ref ref) {
    return syncErrorActions(ref);
  }
}

String _$syncErrorActionsHash() => r'1fd4a021faa65bba237031989588cb114e3031a4';
