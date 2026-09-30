// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Opened once in `main()` and injected with an override.

@ProviderFor(appPrefs)
final appPrefsProvider = AppPrefsProvider._();

/// Opened once in `main()` and injected with an override.

final class AppPrefsProvider
    extends $FunctionalProvider<AppPrefs, AppPrefs, AppPrefs>
    with $Provider<AppPrefs> {
  /// Opened once in `main()` and injected with an override.
  AppPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPrefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPrefsHash();

  @$internal
  @override
  $ProviderElement<AppPrefs> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppPrefs create(Ref ref) {
    return appPrefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppPrefs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppPrefs>(value),
    );
  }
}

String _$appPrefsHash() => r'77a0295cd2f6a68e8d137ef3992c2f164d83ef06';
