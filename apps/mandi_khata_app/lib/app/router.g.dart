// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The root navigator's key: lets app-wide shortcuts (the command palette)
/// open dialogs on top of whatever screen is showing.

@ProviderFor(rootNavigatorKey)
final rootNavigatorKeyProvider = RootNavigatorKeyProvider._();

/// The root navigator's key: lets app-wide shortcuts (the command palette)
/// open dialogs on top of whatever screen is showing.

final class RootNavigatorKeyProvider
    extends
        $FunctionalProvider<
          GlobalKey<NavigatorState>,
          GlobalKey<NavigatorState>,
          GlobalKey<NavigatorState>
        >
    with $Provider<GlobalKey<NavigatorState>> {
  /// The root navigator's key: lets app-wide shortcuts (the command palette)
  /// open dialogs on top of whatever screen is showing.
  RootNavigatorKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rootNavigatorKeyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rootNavigatorKeyHash();

  @$internal
  @override
  $ProviderElement<GlobalKey<NavigatorState>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GlobalKey<NavigatorState> create(Ref ref) {
    return rootNavigatorKey(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GlobalKey<NavigatorState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GlobalKey<NavigatorState>>(value),
    );
  }
}

String _$rootNavigatorKeyHash() => r'9a794ba32b194946dc7f4d87aa7193c8ec1d51d3';

/// The app's router. Guards follow [gateStepProvider]: signed out → login,
/// locked → PIN, no business → picker.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// The app's router. Guards follow [gateStepProvider]: signed out → login,
/// locked → PIN, no business → picker.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's router. Guards follow [gateStepProvider]: signed out → login,
  /// locked → PIN, no business → picker.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'6025341d71b29a880cac97141aff1d707188dfa5';
