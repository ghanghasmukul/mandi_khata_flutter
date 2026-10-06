import 'dart:convert';
import 'dart:typed_data';

import 'package:powersync/powersync.dart';

/// Sends one file to Storage (bucket `bills`) at its path.
typedef BillUploadFn =
    Future<void> Function(String path, Uint8List bytes, String contentType);

/// Uploads queued bill photos (`bill_uploads`, local-only) when online.
/// Failures stay queued with the error and are tried again next time; the
/// expense never waits for its photo.
class BillUploader {
  BillUploader(this._db, this._upload);

  final PowerSyncDatabase _db;
  final BillUploadFn _upload;
  bool _running = false;

  /// Uploads what is waiting (oldest first, [max] at a time). Returns how
  /// many went up. Does nothing while a run is in progress.
  Future<int> uploadPending({int max = 20, DateTime? now}) async {
    if (_running) return 0;
    _running = true;
    var done = 0;
    try {
      final rows = await _db.getAll(
        'SELECT id, path, content_type, data FROM bill_uploads '
        'WHERE uploaded_at IS NULL ORDER BY attempts, created_at LIMIT ?',
        [max],
      );
      for (final r in rows) {
        final id = r['id']! as String;
        try {
          await _upload(
            r['path']! as String,
            base64Decode(r['data']! as String),
            r['content_type'] as String? ?? 'image/jpeg',
          );
          await _db.execute(
            'UPDATE bill_uploads SET uploaded_at = ?, last_error = NULL '
            'WHERE id = ?',
            [(now ?? DateTime.now()).toUtc().toIso8601String(), id],
          );
          done++;
        } on Object catch (e) {
          await _db.execute(
            'UPDATE bill_uploads SET attempts = attempts + 1, last_error = ? '
            'WHERE id = ?',
            ['$e', id],
          );
        }
      }
    } finally {
      _running = false;
    }
    return done;
  }

  /// How many photos wait for upload: of [tenantId], or of every business
  /// on this device (the uploader sends them all: each path names its
  /// business, and Storage checks the member belongs to it). Live.
  Stream<int> watchPending({String? tenantId}) => _db
      .watch(
        'SELECT COUNT(*) AS n FROM bill_uploads WHERE uploaded_at IS NULL '
        'AND (? IS NULL OR tenant_id = ?)',
        parameters: [tenantId, tenantId],
        triggerOnTables: const {'bill_uploads'},
      )
      .map((rows) => rows.first['n']! as int);

  /// The photo at [path] if this device still has it.
  Future<Uint8List?> localBytes(String path) async {
    final r = await _db.getOptional(
      'SELECT data FROM bill_uploads WHERE path = ? ORDER BY created_at DESC',
      [path],
    );
    return r == null ? null : base64Decode(r['data']! as String);
  }
}
