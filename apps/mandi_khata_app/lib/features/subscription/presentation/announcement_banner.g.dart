// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_banner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(announcements)
final announcementsProvider = AnnouncementsProvider._();

final class AnnouncementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnnouncementRow>>,
          List<AnnouncementRow>,
          Stream<List<AnnouncementRow>>
        >
    with
        $FutureModifier<List<AnnouncementRow>>,
        $StreamProvider<List<AnnouncementRow>> {
  AnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementsHash();

  @$internal
  @override
  $StreamProviderElement<List<AnnouncementRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AnnouncementRow>> create(Ref ref) {
    return announcements(ref);
  }
}

String _$announcementsHash() => r'f55d3d43160e4ac19a793ddcc8db55307c389643';

/// Announcements this device has already dismissed (kept on the device).

@ProviderFor(DismissedAnnouncements)
final dismissedAnnouncementsProvider = DismissedAnnouncementsProvider._();

/// Announcements this device has already dismissed (kept on the device).
final class DismissedAnnouncementsProvider
    extends $NotifierProvider<DismissedAnnouncements, Set<String>> {
  /// Announcements this device has already dismissed (kept on the device).
  DismissedAnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dismissedAnnouncementsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dismissedAnnouncementsHash();

  @$internal
  @override
  DismissedAnnouncements create() => DismissedAnnouncements();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$dismissedAnnouncementsHash() =>
    r'167528a5259dae9130ce6645cd9caa5d9881b9f4';

/// Announcements this device has already dismissed (kept on the device).

abstract class _$DismissedAnnouncements extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The newest announcement that is current, for this plan and not yet
/// dismissed, translated into the app language.

@ProviderFor(currentAnnouncement)
final currentAnnouncementProvider = CurrentAnnouncementProvider._();

/// The newest announcement that is current, for this plan and not yet
/// dismissed, translated into the app language.

final class CurrentAnnouncementProvider
    extends
        $FunctionalProvider<
          AnnouncementRow?,
          AnnouncementRow?,
          AnnouncementRow?
        >
    with $Provider<AnnouncementRow?> {
  /// The newest announcement that is current, for this plan and not yet
  /// dismissed, translated into the app language.
  CurrentAnnouncementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAnnouncementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAnnouncementHash();

  @$internal
  @override
  $ProviderElement<AnnouncementRow?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnnouncementRow? create(Ref ref) {
    return currentAnnouncement(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnnouncementRow? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnnouncementRow?>(value),
    );
  }
}

String _$currentAnnouncementHash() =>
    r'c7af164d717bd69ef7abf03bd0175774be32b447';
