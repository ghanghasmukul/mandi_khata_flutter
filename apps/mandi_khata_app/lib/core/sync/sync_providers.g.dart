// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Connects PowerSync while someone is signed in and disconnects on sign-out.
/// The app works fully offline either way; this only moves data.

@ProviderFor(SyncController)
final syncControllerProvider = SyncControllerProvider._();

/// Connects PowerSync while someone is signed in and disconnects on sign-out.
/// The app works fully offline either way; this only moves data.
final class SyncControllerProvider
    extends $AsyncNotifierProvider<SyncController, void> {
  /// Connects PowerSync while someone is signed in and disconnects on sign-out.
  /// The app works fully offline either way; this only moves data.
  SyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncControllerHash();

  @$internal
  @override
  SyncController create() => SyncController();
}

String _$syncControllerHash() => r'b51abf3ce12b001213c31b57bf2c8e99ecc40897';

/// Connects PowerSync while someone is signed in and disconnects on sign-out.
/// The app works fully offline either way; this only moves data.

abstract class _$SyncController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(syncStatus)
final syncStatusProvider = SyncStatusProvider._();

final class SyncStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncStatus>,
          SyncStatus,
          Stream<SyncStatus>
        >
    with $FutureModifier<SyncStatus>, $StreamProvider<SyncStatus> {
  SyncStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusHash();

  @$internal
  @override
  $StreamProviderElement<SyncStatus> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<SyncStatus> create(Ref ref) {
    return syncStatus(ref);
  }
}

String _$syncStatusHash() => r'fbab0263ee61aef80cbd236bdfdbd3f339c0dbae';

/// Local changes not yet uploaded.

@ProviderFor(uploadQueueCount)
final uploadQueueCountProvider = UploadQueueCountProvider._();

/// Local changes not yet uploaded.

final class UploadQueueCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Local changes not yet uploaded.
  UploadQueueCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uploadQueueCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uploadQueueCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return uploadQueueCount(ref);
  }
}

String _$uploadQueueCountHash() => r'72c4ef6ec62a0aa67312e03c4c29f7374c735b97';

/// Changes the server rejected for good, newest first.

@ProviderFor(syncErrors)
final syncErrorsProvider = SyncErrorsProvider._();

/// Changes the server rejected for good, newest first.

final class SyncErrorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RejectedChange>>,
          List<RejectedChange>,
          Stream<List<RejectedChange>>
        >
    with
        $FutureModifier<List<RejectedChange>>,
        $StreamProvider<List<RejectedChange>> {
  /// Changes the server rejected for good, newest first.
  SyncErrorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncErrorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncErrorsHash();

  @$internal
  @override
  $StreamProviderElement<List<RejectedChange>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RejectedChange>> create(Ref ref) {
    return syncErrors(ref);
  }
}

String _$syncErrorsHash() => r'c536493be99fd7af71222bb5c06d2562dd9abc80';

/// What the top-bar chip shows. Null while the database is still opening.

@ProviderFor(syncIndicator)
final syncIndicatorProvider = SyncIndicatorProvider._();

/// What the top-bar chip shows. Null while the database is still opening.

final class SyncIndicatorProvider
    extends $FunctionalProvider<SyncIndicator?, SyncIndicator?, SyncIndicator?>
    with $Provider<SyncIndicator?> {
  /// What the top-bar chip shows. Null while the database is still opening.
  SyncIndicatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncIndicatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncIndicatorHash();

  @$internal
  @override
  $ProviderElement<SyncIndicator?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncIndicator? create(Ref ref) {
    return syncIndicator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncIndicator? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncIndicator?>(value),
    );
  }
}

String _$syncIndicatorHash() => r'1ad2048c9d9372b3f5532a4e0c6d9af696596c49';
