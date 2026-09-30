// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lock.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// PIN lock is for devices that stay signed in at a counter or in a pocket;
/// the web app relies on the browser session instead.

@ProviderFor(appLockSupported)
final appLockSupportedProvider = AppLockSupportedProvider._();

/// PIN lock is for devices that stay signed in at a counter or in a pocket;
/// the web app relies on the browser session instead.

final class AppLockSupportedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// PIN lock is for devices that stay signed in at a counter or in a pocket;
  /// the web app relies on the browser session instead.
  AppLockSupportedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockSupportedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockSupportedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return appLockSupported(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appLockSupportedHash() => r'813bc53d2298438e6d75f98a43786c4844febf31';

/// The local app lock: a 4–6 digit PIN (hashed, never leaves the device),
/// optionally fingerprint / face on Android.
///
/// Locks on a cold start and after [LockPolicy.backgroundTimeout] in the
/// background. Signing in never locks: the user just proved who they are.

@ProviderFor(AppLock)
final appLockProvider = AppLockProvider._();

/// The local app lock: a 4–6 digit PIN (hashed, never leaves the device),
/// optionally fingerprint / face on Android.
///
/// Locks on a cold start and after [LockPolicy.backgroundTimeout] in the
/// background. Signing in never locks: the user just proved who they are.
final class AppLockProvider extends $NotifierProvider<AppLock, AppLockState> {
  /// The local app lock: a 4–6 digit PIN (hashed, never leaves the device),
  /// optionally fingerprint / face on Android.
  ///
  /// Locks on a cold start and after [LockPolicy.backgroundTimeout] in the
  /// background. Signing in never locks: the user just proved who they are.
  AppLockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockHash();

  @$internal
  @override
  AppLock create() => AppLock();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLockState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLockState>(value),
    );
  }
}

String _$appLockHash() => r'792056831d949e9a3adb56722a049a035f4e45db';

/// The local app lock: a 4–6 digit PIN (hashed, never leaves the device),
/// optionally fingerprint / face on Android.
///
/// Locks on a cold start and after [LockPolicy.backgroundTimeout] in the
/// background. Signing in never locks: the user just proved who they are.

abstract class _$AppLock extends $Notifier<AppLockState> {
  AppLockState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppLockState, AppLockState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLockState, AppLockState>,
              AppLockState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
