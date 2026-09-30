import 'dart:async';

import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_out_service.g.dart';

/// Signing out removes this device's copy of the business data, so local
/// changes that have not been uploaded would be lost. The UI asks first
/// (see `confirmAndSignOut`).
class SignOutService {
  SignOutService({
    required this._queueCount,
    required this._wipeLocalData,
    required this._auth,
    required this._prefs,
  });

  final Stream<int> Function() _queueCount;
  final Future<void> Function() _wipeLocalData;
  final AuthRepository _auth;
  final AppPrefs _prefs;

  /// Local changes still waiting to upload.
  Future<int> pendingChanges() => _queueCount().first;

  /// Waits for the upload queue to empty (sync keeps running meanwhile).
  /// Returns false if it did not empty within [timeout].
  Future<bool> waitForUpload({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      await _queueCount().firstWhere((n) => n == 0).timeout(timeout);
      return true;
    } on TimeoutException {
      return false;
    }
  }

  /// Clears the local database and per-install data, then ends the session.
  /// Anything still queued is discarded — call [pendingChanges] first.
  Future<void> signOut() async {
    await _wipeLocalData();
    await _prefs.clearAll();
    await _auth.signOut();
  }
}

@riverpod
SignOutService signOutService(Ref ref) => SignOutService(
  queueCount: () async* {
    yield* watchUploadQueue(await ref.read(powerSyncDatabaseProvider.future));
  },
  wipeLocalData: ref.read(localDataWiperProvider),
  auth: ref.read(authRepositoryProvider),
  prefs: ref.read(appPrefsProvider),
);
