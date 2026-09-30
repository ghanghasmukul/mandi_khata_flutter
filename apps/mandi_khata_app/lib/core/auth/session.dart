import 'dart:async';

import 'package:logging/logging.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session.g.dart';

final _log = Logger('auth');

sealed class SessionState {
  const SessionState();
}

/// Someone new signed in and the previous user's local data is being
/// removed first.
final class SessionPreparing extends SessionState {
  const SessionPreparing();
}

final class SignedOut extends SessionState {
  const SignedOut();
}

final class SignedIn extends SessionState {
  const SignedIn(this.user);

  final AuthUser user;
}

/// Empties the local database (synced tables, upload queue and local-only
/// tables). Overridable so tests need no real database.
@Riverpod(keepAlive: true)
Future<void> Function() localDataWiper(Ref ref) => () async {
  final db = await ref.read(powerSyncDatabaseProvider.future);
  await db.disconnectAndClear();
};

/// Who is signed in. Offline launches keep the cached session, so the app
/// opens without a network.
///
/// The local database belongs to one user at a time: when a different user
/// signs in on this install, it is wiped before they see anything.
@Riverpod(keepAlive: true)
class Session extends _$Session {
  @override
  SessionState build() {
    final repo = ref.watch(authRepositoryProvider);
    final sub = repo.userChanges.listen(_onUser);
    ref.onDispose(sub.cancel);

    final user = repo.currentUser;
    if (user == null) return const SignedOut();
    if (_ownsLocalData(user)) return SignedIn(user);
    scheduleMicrotask(() => _adopt(user));
    return const SessionPreparing();
  }

  AppPrefs get _prefs => ref.read(appPrefsProvider);

  bool _ownsLocalData(AuthUser user) => _prefs.dataOwnerUserId == user.id;

  void _onUser(AuthUser? user) {
    if (user == null) {
      state = const SignedOut();
    } else if (_ownsLocalData(user)) {
      final current = state;
      if (current is! SignedIn || current.user != user) {
        state = SignedIn(user);
      }
    } else if (state is! SessionPreparing) {
      state = const SessionPreparing();
      unawaited(_adopt(user));
    }
  }

  Future<void> _adopt(AuthUser user) async {
    _log.info('New user on this device: clearing previous local data');
    try {
      await ref.read(localDataWiperProvider)();
      await _prefs.clearAll();
      await _prefs.setDataOwnerUserId(user.id);
    } on Object catch (e, st) {
      // Never show one user another user's data: stay signed out.
      _log.severe('Could not clear local data', e, st);
      try {
        await ref.read(authRepositoryProvider).signOut();
      } on AuthFailure catch (_) {}
      state = const SignedOut();
      return;
    }
    // The user may have changed again while clearing.
    final now = ref.read(authRepositoryProvider).currentUser;
    if (now == null) {
      state = const SignedOut();
    } else if (now.id == user.id) {
      state = SignedIn(now);
    } else {
      await _adopt(now);
    }
  }
}
