// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The version this build was made as (`--build-name`).

@ProviderFor(currentVersion)
final currentVersionProvider = CurrentVersionProvider._();

/// The version this build was made as (`--build-name`).

final class CurrentVersionProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppVersion>,
          AppVersion,
          FutureOr<AppVersion>
        >
    with $FutureModifier<AppVersion>, $FutureProvider<AppVersion> {
  /// The version this build was made as (`--build-name`).
  CurrentVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentVersionHash();

  @$internal
  @override
  $FutureProviderElement<AppVersion> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppVersion> create(Ref ref) {
    return currentVersion(ref);
  }
}

String _$currentVersionHash() => r'0559a70514a143449c5c4e927721b985f1b89d54';

/// The result of the start-up check. Runs once per app start; offline it
/// simply ends as [UpdateCheckFailed].

@ProviderFor(updateStatus)
final updateStatusProvider = UpdateStatusProvider._();

/// The result of the start-up check. Runs once per app start; offline it
/// simply ends as [UpdateCheckFailed].

final class UpdateStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<UpdateStatus>,
          UpdateStatus,
          FutureOr<UpdateStatus>
        >
    with $FutureModifier<UpdateStatus>, $FutureProvider<UpdateStatus> {
  /// The result of the start-up check. Runs once per app start; offline it
  /// simply ends as [UpdateCheckFailed].
  UpdateStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateStatusHash();

  @$internal
  @override
  $FutureProviderElement<UpdateStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UpdateStatus> create(Ref ref) {
    return updateStatus(ref);
  }
}

String _$updateStatusHash() => r'0deb808af155f1c266f443cddee62d4cf88a8220';

/// Hides the (optional) banner for the version the user said "later" to.

@ProviderFor(DismissedUpdate)
final dismissedUpdateProvider = DismissedUpdateProvider._();

/// Hides the (optional) banner for the version the user said "later" to.
final class DismissedUpdateProvider
    extends $NotifierProvider<DismissedUpdate, String?> {
  /// Hides the (optional) banner for the version the user said "later" to.
  DismissedUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dismissedUpdateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dismissedUpdateHash();

  @$internal
  @override
  DismissedUpdate create() => DismissedUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$dismissedUpdateHash() => r'238d421240f898fa9d8e8fe2d89cb7f1583d567b';

/// Hides the (optional) banner for the version the user said "later" to.

abstract class _$DismissedUpdate extends $Notifier<String?> {
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
