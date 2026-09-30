import 'dart:async';

import 'package:drift/drift.dart';
import 'package:mandi_khata_app/app/env.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/db/app_database.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/sync/supabase_connector.dart';
import 'package:mandi_khata_app/core/sync/sync_indicator.dart';
import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'sync_providers.g.dart';

/// Whether this build can sync at all.
bool get syncConfigured => Env.hasSupabase && Env.hasPowerSync;

/// Connects PowerSync while someone is signed in and disconnects on sign-out.
/// The app works fully offline either way; this only moves data.
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  PowerSyncDatabase? _db;
  SupabaseConnector? _connector;

  @override
  Future<void> build() async {
    if (!syncConfigured) return;
    final db = await ref.watch(powerSyncDatabaseProvider.future);
    _db = db;
    final client = Supabase.instance.client;
    final connector = SupabaseConnector(
      client: client,
      powerSyncUrl: Env.powersyncUrl,
    );
    _connector = connector;

    // Follows the session (not raw auth events) so a new user's first sync
    // starts only after the previous user's data has been cleared.
    ref.listen(sessionProvider, (previous, session) async {
      if (previous is SignedIn &&
          session is SignedIn &&
          previous.user.id == session.user.id) {
        return;
      }
      switch (session) {
        case SignedIn():
          await db.connect(connector: connector);
        case SignedOut():
        case SessionPreparing():
          await db.disconnect();
      }
    }, fireImmediately: true);
  }

  /// Stops syncing (local work continues). Used by the dev sync page to
  /// simulate going offline.
  Future<void> pause() async {
    await _db?.disconnect();
  }

  /// Resumes syncing if signed in.
  Future<void> resume() async {
    final db = _db;
    final connector = _connector;
    if (db == null || connector == null) return;
    if (Supabase.instance.client.auth.currentSession == null) return;
    await db.connect(connector: connector);
  }
}

@riverpod
Stream<SyncStatus> syncStatus(Ref ref) async* {
  final db = await ref.watch(powerSyncDatabaseProvider.future);
  yield db.currentStatus;
  yield* db.statusStream;
}

/// Whether a full sync has completed at least once on this database (so an
/// empty table means "really empty", not "not downloaded yet").
@riverpod
bool hasSynced(Ref ref) =>
    ref.watch(syncStatusProvider).value?.hasSynced ?? false;

/// Number of local changes not yet uploaded, live.
Stream<int> watchUploadQueue(PowerSyncDatabase db) => db
    .watch(
      'SELECT count(*) AS n FROM ps_crud',
      triggerOnTables: const {'ps_crud'},
    )
    .map((rows) => rows.first['n'] as int);

/// Local changes not yet uploaded.
@riverpod
Stream<int> uploadQueueCount(Ref ref) async* {
  final db = await ref.watch(powerSyncDatabaseProvider.future);
  yield* watchUploadQueue(db);
}

/// A change the server rejected for good (a row of local `sync_errors`).
typedef RejectedChange = ({
  String id,
  String table,
  String rowId,
  String op,
  String? code,
  String message,
  DateTime? at,
});

/// Changes the server rejected for good, newest first.
@riverpod
Stream<List<RejectedChange>> syncErrors(Ref ref) async* {
  final db = await ref.watch(appDatabaseProvider.future);
  final query = db.select(db.syncErrors)
    ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]);
  yield* query.watch().map(
    (rows) => [
      for (final r in rows)
        (
          id: r.id,
          table: r.tableNameValue,
          rowId: r.rowId,
          op: r.op,
          code: r.errorCode,
          message: r.message,
          at: DateTime.tryParse(r.createdAt),
        ),
    ],
  );
}

/// Clears the rejected-changes list (local only; nothing is uploaded).
Future<void> dismissSyncErrors(AppDatabase db) => db.delete(db.syncErrors).go();

/// What the top-bar chip shows. Null while the database is still opening.
@riverpod
SyncIndicator? syncIndicator(Ref ref) {
  if (!syncConfigured) return const SyncOff();
  final status = ref.watch(syncStatusProvider).value;
  final queued = ref.watch(uploadQueueCountProvider).value;
  final rejected = ref.watch(syncErrorsProvider).value;
  if (status == null || queued == null || rejected == null) return null;
  return syncIndicatorFor(
    configured: true,
    connected: status.connected,
    connecting: status.connecting,
    transferring: status.uploading || status.downloading,
    queued: queued,
    rejected: rejected.length,
    lastSyncedAt: status.lastSyncedAt,
  );
}
