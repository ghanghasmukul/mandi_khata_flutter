// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SettingsRepository>,
          SettingsRepository,
          FutureOr<SettingsRepository>
        >
    with
        $FutureModifier<SettingsRepository>,
        $FutureProvider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsRepository> create(Ref ref) {
    return settingsRepository(ref);
  }
}

String _$settingsRepositoryHash() =>
    r'd9a8aa9148f60850fe2e8ba48cdc2d4ba4736e8b';

/// Values that come with the subscription plan. Plans arrive in step 5.1;
/// until then every key falls through to the system default.

@ProviderFor(planDefaults)
final planDefaultsProvider = PlanDefaultsProvider._();

/// Values that come with the subscription plan. Plans arrive in step 5.1;
/// until then every key falls through to the system default.

final class PlanDefaultsProvider
    extends
        $FunctionalProvider<
          Map<String, Object?>,
          Map<String, Object?>,
          Map<String, Object?>
        >
    with $Provider<Map<String, Object?>> {
  /// Values that come with the subscription plan. Plans arrive in step 5.1;
  /// until then every key falls through to the system default.
  PlanDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planDefaultsHash();

  @$internal
  @override
  $ProviderElement<Map<String, Object?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, Object?> create(Ref ref) {
    return planDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Object?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Object?>>(value),
    );
  }
}

String _$planDefaultsHash() => r'ff3e5e67e93a48dfbd9f253caaa75cbad734bf0b';

/// Setting rows of the active business that can apply to [target]. Live.

@ProviderFor(settingRows)
final settingRowsProvider = SettingRowsFamily._();

/// Setting rows of the active business that can apply to [target]. Live.

final class SettingRowsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SettingRow>>,
          List<SettingRow>,
          Stream<List<SettingRow>>
        >
    with $FutureModifier<List<SettingRow>>, $StreamProvider<List<SettingRow>> {
  /// Setting rows of the active business that can apply to [target]. Live.
  SettingRowsProvider._({
    required SettingRowsFamily super.from,
    required SettingsTarget super.argument,
  }) : super(
         retry: null,
         name: r'settingRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingRowsHash();

  @override
  String toString() {
    return r'settingRowsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SettingRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SettingRow>> create(Ref ref) {
    final argument = this.argument as SettingsTarget;
    return settingRows(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SettingRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingRowsHash() => r'09a8fa9d88694d79715a92cc40ab722e7985fe6f';

/// Setting rows of the active business that can apply to [target]. Live.

final class SettingRowsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SettingRow>>, SettingsTarget> {
  SettingRowsFamily._()
    : super(
        retry: null,
        name: r'settingRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Setting rows of the active business that can apply to [target]. Live.

  SettingRowsProvider call(SettingsTarget target) =>
      SettingRowsProvider._(argument: target, from: this);

  @override
  String toString() => r'settingRowsProvider';
}

/// A resolver over the rows for [target]; null while loading.

@ProviderFor(settingsResolver)
final settingsResolverProvider = SettingsResolverFamily._();

/// A resolver over the rows for [target]; null while loading.

final class SettingsResolverProvider
    extends
        $FunctionalProvider<
          SettingsResolver?,
          SettingsResolver?,
          SettingsResolver?
        >
    with $Provider<SettingsResolver?> {
  /// A resolver over the rows for [target]; null while loading.
  SettingsResolverProvider._({
    required SettingsResolverFamily super.from,
    required SettingsTarget super.argument,
  }) : super(
         retry: null,
         name: r'settingsResolverProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingsResolverHash();

  @override
  String toString() {
    return r'settingsResolverProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SettingsResolver?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsResolver? create(Ref ref) {
    final argument = this.argument as SettingsTarget;
    return settingsResolver(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsResolver? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsResolver?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsResolverProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingsResolverHash() => r'eb34bd8e4bd918a7ee537889573d992f5d56e4a1';

/// A resolver over the rows for [target]; null while loading.

final class SettingsResolverFamily extends $Family
    with $FunctionalFamilyOverride<SettingsResolver?, SettingsTarget> {
  SettingsResolverFamily._()
    : super(
        retry: null,
        name: r'settingsResolverProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A resolver over the rows for [target]; null while loading.

  SettingsResolverProvider call(SettingsTarget target) =>
      SettingsResolverProvider._(argument: target, from: this);

  @override
  String toString() => r'settingsResolverProvider';
}

/// The resolved value of [key] for [target] and the level it came from,
/// updating live as settings change or sync. Null while loading.
///
/// ```dart
/// final rate = ref.watch(settingProvider('interest.rate_pa', (
///   partyId: party.id, partyGroupId: null, documentId: null,
/// )));
/// ```

@ProviderFor(setting)
final settingProvider = SettingFamily._();

/// The resolved value of [key] for [target] and the level it came from,
/// updating live as settings change or sync. Null while loading.
///
/// ```dart
/// final rate = ref.watch(settingProvider('interest.rate_pa', (
///   partyId: party.id, partyGroupId: null, documentId: null,
/// )));
/// ```

final class SettingProvider
    extends
        $FunctionalProvider<
          ResolvedSetting?,
          ResolvedSetting?,
          ResolvedSetting?
        >
    with $Provider<ResolvedSetting?> {
  /// The resolved value of [key] for [target] and the level it came from,
  /// updating live as settings change or sync. Null while loading.
  ///
  /// ```dart
  /// final rate = ref.watch(settingProvider('interest.rate_pa', (
  ///   partyId: party.id, partyGroupId: null, documentId: null,
  /// )));
  /// ```
  SettingProvider._({
    required SettingFamily super.from,
    required (String, SettingsTarget) super.argument,
  }) : super(
         retry: null,
         name: r'settingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingHash();

  @override
  String toString() {
    return r'settingProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<ResolvedSetting?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ResolvedSetting? create(Ref ref) {
    final argument = this.argument as (String, SettingsTarget);
    return setting(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResolvedSetting? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResolvedSetting?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SettingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingHash() => r'e6ca836593840e3da5b1bc053ab0d78beaa538ac';

/// The resolved value of [key] for [target] and the level it came from,
/// updating live as settings change or sync. Null while loading.
///
/// ```dart
/// final rate = ref.watch(settingProvider('interest.rate_pa', (
///   partyId: party.id, partyGroupId: null, documentId: null,
/// )));
/// ```

final class SettingFamily extends $Family
    with $FunctionalFamilyOverride<ResolvedSetting?, (String, SettingsTarget)> {
  SettingFamily._()
    : super(
        retry: null,
        name: r'settingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The resolved value of [key] for [target] and the level it came from,
  /// updating live as settings change or sync. Null while loading.
  ///
  /// ```dart
  /// final rate = ref.watch(settingProvider('interest.rate_pa', (
  ///   partyId: party.id, partyGroupId: null, documentId: null,
  /// )));
  /// ```

  SettingProvider call(String key, SettingsTarget target) =>
      SettingProvider._(argument: (key, target), from: this);

  @override
  String toString() => r'settingProvider';
}

@ProviderFor(settingsWriter)
final settingsWriterProvider = SettingsWriterProvider._();

final class SettingsWriterProvider
    extends $FunctionalProvider<SettingsWriter, SettingsWriter, SettingsWriter>
    with $Provider<SettingsWriter> {
  SettingsWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsWriterHash();

  @$internal
  @override
  $ProviderElement<SettingsWriter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsWriter create(Ref ref) {
    return settingsWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsWriter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsWriter>(value),
    );
  }
}

String _$settingsWriterHash() => r'925ba596068c4ff96926ec4d0b505d726469c134';
