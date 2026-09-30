// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Empties the local database (synced tables, upload queue and local-only
/// tables). Overridable so tests need no real database.

@ProviderFor(localDataWiper)
final localDataWiperProvider = LocalDataWiperProvider._();

/// Empties the local database (synced tables, upload queue and local-only
/// tables). Overridable so tests need no real database.

final class LocalDataWiperProvider
    extends
        $FunctionalProvider<
          Future<void> Function(),
          Future<void> Function(),
          Future<void> Function()
        >
    with $Provider<Future<void> Function()> {
  /// Empties the local database (synced tables, upload queue and local-only
  /// tables). Overridable so tests need no real database.
  LocalDataWiperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDataWiperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDataWiperHash();

  @$internal
  @override
  $ProviderElement<Future<void> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<void> Function() create(Ref ref) {
    return localDataWiper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<void> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<void> Function()>(value),
    );
  }
}

String _$localDataWiperHash() => r'd19dded377f04f807c8f6325de0954d7146c64e2';

/// Who is signed in. Offline launches keep the cached session, so the app
/// opens without a network.
///
/// The local database belongs to one user at a time: when a different user
/// signs in on this install, it is wiped before they see anything.

@ProviderFor(Session)
final sessionProvider = SessionProvider._();

/// Who is signed in. Offline launches keep the cached session, so the app
/// opens without a network.
///
/// The local database belongs to one user at a time: when a different user
/// signs in on this install, it is wiped before they see anything.
final class SessionProvider extends $NotifierProvider<Session, SessionState> {
  /// Who is signed in. Offline launches keep the cached session, so the app
  /// opens without a network.
  ///
  /// The local database belongs to one user at a time: when a different user
  /// signs in on this install, it is wiped before they see anything.
  SessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  Session create() => Session();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$sessionHash() => r'5b968b00c6c31ba0ce0c51a1ab9b80ed7ebf6151';

/// Who is signed in. Offline launches keep the cached session, so the app
/// opens without a network.
///
/// The local database belongs to one user at a time: when a different user
/// signs in on this install, it is wiped before they see anything.

abstract class _$Session extends $Notifier<SessionState> {
  SessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionState, SessionState>,
              SessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
