import 'dart:convert';

import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;

enum RetryResult {
  /// The changes are back in the upload queue.
  requeued,

  /// They cannot be sent again (a delete, an unknown table, the row no
  /// longer exists for an update, or an append-only row that is still on
  /// this device and must first be cleared by a sync). Nothing was changed;
  /// discard instead, or try again after the next sync.
  notRetryable,
}

/// Owner actions on changes the server rejected (local `sync_errors`).
///
/// The server applies each local transaction all-or-nothing, so its
/// rejected changes form one batch and are retried or discarded together:
/// retrying half a transaction could upload a ledger entry without its
/// document, or a reversal without its replacement.
///
/// Retry re-applies the rejected changes to the local rows, in their
/// original order and in one local transaction, which queues them for upload
/// again — useful once the cause is fixed (e.g. a permission was granted).
/// It adds no new audit entry: the original change was audited when it was
/// made, and that audit row is part of the same batch.
class SyncErrorActions {
  SyncErrorActions(this._db);

  final PowerSyncDatabase _db;

  /// Forgets the rejected change and the rest of its batch.
  Future<void> discard(String id) => _db.writeTransaction((tx) async {
    final ids = await _batchIds(tx, id);
    for (final errorId in ids) {
      await tx.execute('DELETE FROM sync_errors WHERE id = ?', [errorId]);
    }
  });

  Future<RetryResult> retry(String id) => _db.writeTransaction((tx) async {
    final ids = await _batchIds(tx, id);
    if (ids.isEmpty) return RetryResult.notRetryable;
    final errors = [
      for (final errorId in ids)
        await tx.get(
          'SELECT table_name, row_id, op, op_data FROM sync_errors '
          'WHERE id = ?',
          [errorId],
        ),
    ];

    // Plan every change before touching anything, so a batch is re-queued
    // whole or not at all.
    final willExist = <String>{};
    final replays = <_Replay>[];
    for (final error in errors) {
      final replay = await _plan(tx, error, willExist);
      if (replay == null) return RetryResult.notRetryable;
      replays.add(replay);
    }
    for (final replay in replays) {
      await tx.execute(replay.sql, replay.args);
    }
    for (final errorId in ids) {
      await tx.execute('DELETE FROM sync_errors WHERE id = ?', [errorId]);
    }
    return RetryResult.requeued;
  });

  /// Ids of [id] and the rest of its batch, in upload order.
  static Future<List<String>> _batchIds(
    SqliteWriteContext tx,
    String id,
  ) async {
    final row = await tx.getOptional(
      'SELECT batch_id FROM sync_errors WHERE id = ?',
      [id],
    );
    if (row == null) return const [];
    final batchId = row['batch_id'] as String?;
    if (batchId == null) return [id];
    final rows = await tx.getAll(
      'SELECT id FROM sync_errors WHERE batch_id = ? ORDER BY batch_seq',
      [batchId],
    );
    return [for (final r in rows) r['id']! as String];
  }

  static Future<_Replay?> _plan(
    SqliteWriteContext tx,
    Map<String, Object?> error,
    Set<String> willExist,
  ) async {
    final spec = syncedTable(error['table_name']! as String);
    final op = error['op']! as String;
    final raw = error['op_data'] as String?;
    if (spec == null || raw == null || op == 'DELETE') return null;
    // Only real columns of a known table: the names go into SQL.
    final data = {
      for (final MapEntry(:key, :value)
          in (jsonDecode(raw) as Map<String, Object?>).entries)
        if (spec.columns.containsKey(key)) key: value,
    };
    if (data.isEmpty) return null;
    final table = spec.name;
    final rowId = error['row_id']! as String;
    final key = '$table/$rowId';
    final exists =
        willExist.contains(key) ||
        await tx.getOptional('SELECT 1 FROM $table WHERE id = ?', [rowId]) !=
            null;

    if (exists) {
      // An update would upload as PATCH, which append-only tables refuse.
      // The rejected row leaves this device on the next sync; retry then.
      if (spec.appendOnly) return null;
      return _Replay(
        'UPDATE $table SET ${data.keys.map((k) => '$k = ?').join(', ')} '
        'WHERE id = ?',
        [...data.values, rowId],
      );
    }
    if (op != 'PUT') return null;
    willExist.add(key);
    final cols = ['id', ...data.keys];
    return _Replay(
      'INSERT INTO $table (${cols.join(', ')}) '
      'VALUES (${List.filled(cols.length, '?').join(', ')})',
      [rowId, ...data.values],
    );
  }
}

class _Replay {
  const _Replay(this.sql, this.args);

  final String sql;
  final List<Object?> args;
}
