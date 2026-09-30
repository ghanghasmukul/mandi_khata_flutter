import 'dart:async';

import 'package:drift/drift.dart';
import 'package:mandi_khata_app/app/env.dart';
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

    final sub = client.auth.onAuthStateChange.listen((state) async {
      final event = state.event;
      if (event == AuthChangeEvent.signedOut) {
        await db.disconnect();
      } else if ((event == AuthChangeEvent.initialSession ||
              event == AuthChangeEvent.signedIn) &&
          state.session != null) {
        await db.connect(connector: connector);
      }
    });
    ref.onDispose(sub.cancel);
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

/// Local changes not yet uploaded.
@riverpod
Stream<int> uploadQueueCount(Ref ref) async* {
  final db = await ref.watch(powerSyncDatabaseProvider.future);
  yield* db
      .watch(
        'SELECT count(*) AS n FROM ps_crud',
        triggerOnTables: const {'ps_crud'},
      )
      .map((rows) => rows.first['n'] as int);
}

/// A change the server rejected for good (a row of local `sync_errors`).
typedef RejectedChange = ({
  String table,
  String rowId,
  String op,
  String? code,
  String message,
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
          table: r.tableNameValue,
          rowId: r.rowId,
          op: r.op,
          code: r.errorCode,
          message: r.message,
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
