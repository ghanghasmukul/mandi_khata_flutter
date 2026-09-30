// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_language.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's synced `app_users.preferred_language`.

@ProviderFor(profileLanguage)
final profileLanguageProvider = ProfileLanguageProvider._();

/// The signed-in user's synced `app_users.preferred_language`.

final class ProfileLanguageProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// The signed-in user's synced `app_users.preferred_language`.
  ProfileLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileLanguageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileLanguageHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return profileLanguage(ref);
  }
}

String _$profileLanguageHash() => r'414fc58656bf209354ee562f5aaa94f8a72992c2';

/// Language code for the UI, or null to follow the device (MaterialApp then
/// picks the closest of en / hi / pa).
///
/// Order: the choice made on this install → the user's profile language
/// (so it follows them to a new phone) → the device.

@ProviderFor(AppLanguage)
final appLanguageProvider = AppLanguageProvider._();

/// Language code for the UI, or null to follow the device (MaterialApp then
/// picks the closest of en / hi / pa).
///
/// Order: the choice made on this install → the user's profile language
/// (so it follows them to a new phone) → the device.
final class AppLanguageProvider
    extends $NotifierProvider<AppLanguage, String?> {
  /// Language code for the UI, or null to follow the device (MaterialApp then
  /// picks the closest of en / hi / pa).
  ///
  /// Order: the choice made on this install → the user's profile language
  /// (so it follows them to a new phone) → the device.
  AppLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLanguageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLanguageHash();

  @$internal
  @override
  AppLanguage create() => AppLanguage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$appLanguageHash() => r'21d25a9c2980d9e213ecec6520e3199bb7fb61f5';

/// Language code for the UI, or null to follow the device (MaterialApp then
/// picks the closest of en / hi / pa).
///
/// Order: the choice made on this install → the user's profile language
/// (so it follows them to a new phone) → the device.

abstract class _$AppLanguage extends $Notifier<String?> {
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
