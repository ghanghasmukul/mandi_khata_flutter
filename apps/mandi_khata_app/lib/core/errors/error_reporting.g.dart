// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_reporting.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the Sentry tags in step with the active business and device.
/// Watched once by the app root.

@ProviderFor(errorReportingTags)
final errorReportingTagsProvider = ErrorReportingTagsProvider._();

/// Keeps the Sentry tags in step with the active business and device.
/// Watched once by the app root.

final class ErrorReportingTagsProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Keeps the Sentry tags in step with the active business and device.
  /// Watched once by the app root.
  ErrorReportingTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorReportingTagsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorReportingTagsHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return errorReportingTags(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$errorReportingTagsHash() =>
    r'd6d7bef39bbedd96592fa2b253469c0179cbc6c2';
