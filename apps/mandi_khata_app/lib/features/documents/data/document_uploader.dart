import 'dart:convert';
import 'dart:typed_data';

import 'package:powersync/powersync.dart';

/// Sends one file to Storage: bucket, path, bytes, content type.
typedef DocumentUploadFn =
    Future<void> Function(
      String bucket,
      String path,
      Uint8List bytes,
      String contentType,
    );

/// Uploads queued party documents (`document_uploads`, local-only) when
/// online. Failures stay queued with the error and are retried next time; a
/// document row never waits for its file.
class DocumentUploader {
  DocumentUploader(this._db, this._upload);

  final PowerSyncDatabase _db;
  final DocumentUploadFn _upload;
  bool _running = false;

  /// Uploads what is waiting (oldest first, [max] at a time); returns how
  /// many went up. Does nothing while a run is in progress.
  Future<int> uploadPending({int max = 20, DateTime? now}) async {
    if (_running) return 0;
    _running = true;
    var done = 0;
    try {
      final rows = await _db.getAll(
        'SELECT id, bucket, path, content_type, data FROM document_uploads '
        'WHERE uploaded_at IS NULL ORDER BY attempts, created_at LIMIT ?',
        [max],
      );
      for (final r in rows) {
        final id = r['id']! as String;
        try {
          await _upload(
            r['bucket']! as String,
            r['path']! as String,
            base64Decode(r['data']! as String),
            r['content_type'] as String? ?? 'image/jpeg',
          );
          await _db.execute(
            'UPDATE document_uploads SET uploaded_at = ?, last_error = NULL, '
            // The bytes are on the server now; keep the row, drop the copy.
            "data = '' WHERE id = ?",
            [(now ?? DateTime.now()).toUtc().toIso8601String(), id],
          );
          done++;
        } on Object catch (e) {
          await _db.execute(
            'UPDATE document_uploads SET attempts = attempts + 1, '
            'last_error = ? WHERE id = ?',
            ['$e', id],
          );
        }
      }
    } finally {
      _running = false;
    }
    return done;
  }

  /// How many files wait for upload. Live.
  Stream<int> watchPending({String? tenantId}) => _db
      .watch(
        'SELECT COUNT(*) AS n FROM document_uploads WHERE uploaded_at IS NULL '
        'AND (? IS NULL OR tenant_id = ?)',
        parameters: [tenantId, tenantId],
        triggerOnTables: const {'document_uploads'},
      )
      .map((rows) => rows.first['n']! as int);

  /// The file at [path] if this device still has it (not yet uploaded).
  Future<Uint8List?> localBytes(String path) async {
    final r = await _db.getOptional(
      "SELECT data FROM document_uploads WHERE path = ? AND data <> '' "
      'ORDER BY created_at DESC',
      [path],
    );
    return r == null ? null : base64Decode(r['data']! as String);
  }
}
