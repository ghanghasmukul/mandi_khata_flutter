import 'dart:convert';

import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:powersync/powersync.dart';

enum RetryResult {
  /// The change is back in the upload queue.
  requeued,

  /// It cannot be sent again (a delete, an unknown table, or the row no
  /// longer exists for an update). Discard it instead.
  notRetryable,
}

/// Owner actions on changes the server rejected (local `sync_errors`).
///
/// Retry re-applies the rejected change to the local row, which queues it
/// for upload again — useful once the cause is fixed (e.g. a permission was
/// granted). It adds no new audit entry: the original change was audited
/// when it was made, and that audit row is retried the same way.
class SyncErrorActions {
  SyncErrorActions(this._db);

  final PowerSyncDatabase _db;

  Future<void> discard(String id) =>
      _db.execute('DELETE FROM sync_errors WHERE id = ?', [id]);

  Future<RetryResult> retry(String id) => _db.writeTransaction((tx) async {
    final error = await tx.getOptional(
      'SELECT table_name, row_id, op, op_data FROM sync_errors WHERE id = ?',
      [id],
    );
    if (error == null) return RetryResult.notRetryable;
    final spec = syncedTable(error['table_name']! as String);
    final op = error['op']! as String;
    final raw = error['op_data'] as String?;
    if (spec == null || raw == null || op == 'DELETE') {
      return RetryResult.notRetryable;
    }
    // Only real columns of a known table: the names go into SQL.
    final data = {
      for (final MapEntry(:key, :value)
          in (jsonDecode(raw) as Map<String, Object?>).entries)
        if (spec.columns.containsKey(key)) key: value,
    };
    if (data.isEmpty) return RetryResult.notRetryable;
    final table = spec.name;
    final rowId = error['row_id']! as String;
    final exists =
        await tx.getOptional('SELECT 1 FROM $table WHERE id = ?', [rowId]) !=
        null;

    if (exists) {
      await tx.execute(
        'UPDATE $table SET ${data.keys.map((k) => '$k = ?').join(', ')} '
        'WHERE id = ?',
        [...data.values, rowId],
      );
    } else if (op == 'PUT') {
      final cols = ['id', ...data.keys];
      await tx.execute(
        'INSERT INTO $table (${cols.join(', ')}) '
        'VALUES (${List.filled(cols.length, '?').join(', ')})',
        [rowId, ...data.values],
      );
    } else {
      return RetryResult.notRetryable;
    }
    await tx.execute('DELETE FROM sync_errors WHERE id = ?', [id]);
    return RetryResult.requeued;
  });
}
