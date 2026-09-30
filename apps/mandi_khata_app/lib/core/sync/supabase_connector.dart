import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:mandi_khata_app/core/sync/upload_policy.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final _log = Logger('sync');

/// Applies one local change to the server. Split out so the connector's
/// queue handling can be tested without a network.
abstract interface class CrudApplier {
  /// Throws [UploadException] with the server's error code on rejection.
  Future<void> apply(CrudEntry entry);
}

/// A rejected upload, carrying the Postgres / PostgREST error code.
class UploadException implements Exception {
  const UploadException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'UploadException($code): $message';
}

/// Writes changes through PostgREST, so RLS and the guard triggers apply
/// exactly as they would for any client.
class SupabaseCrudApplier implements CrudApplier {
  SupabaseCrudApplier(this._client);

  final SupabaseClient _client;

  @override
  Future<void> apply(CrudEntry entry) async {
    final table = _client.from(entry.table);
    final data = toServerPayload(entry.table, entry.opData ?? const {});
    try {
      switch (entry.op) {
        case UpdateType.put:
          await table.upsert({...data, 'id': entry.id});
        case UpdateType.patch:
          await table.update(data).eq('id', entry.id);
        case UpdateType.delete:
          // No table allows client deletes; the server rejects this and it
          // lands in sync_errors, which is what we want to see.
          await table.delete().eq('id', entry.id);
      }
    } on PostgrestException catch (e) {
      throw UploadException(e.message, code: e.code);
    }
  }
}

/// PowerSync ⇄ Supabase: credentials from the Supabase session, uploads via
/// [CrudApplier], one local transaction at a time.
class SupabaseConnector extends PowerSyncBackendConnector {
  SupabaseConnector({
    required SupabaseClient client,
    required this._powerSyncUrl,
    CrudApplier? applier,
    UploadBackoff? backoff,
  }) : _client = client,
       _applier = applier ?? SupabaseCrudApplier(client),
       _backoff = backoff ?? UploadBackoff();

  final SupabaseClient _client;
  final String _powerSyncUrl;
  final CrudApplier _applier;
  final UploadBackoff _backoff;

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    var session = _client.auth.currentSession;
    if (session == null) return null;
    if (session.isExpired) {
      session = (await _client.auth.refreshSession()).session;
      if (session == null) return null;
    }
    final expiresAt = session.expiresAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
    return PowerSyncCredentials(
      endpoint: _powerSyncUrl,
      token: session.accessToken,
      userId: session.user.id,
      expiresAt: expiresAt,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) =>
      uploadPending(database, _applier, _backoff);
}

/// Uploads the next local transaction. Permanent rejections are moved to
/// `sync_errors` and the transaction completes, so later changes are not
/// blocked; transient failures wait (exponential backoff) and rethrow so
/// PowerSync retries the whole transaction.
Future<void> uploadPending(
  PowerSyncDatabase database,
  CrudApplier applier,
  UploadBackoff backoff, {
  Future<void> Function(Duration) wait = Future<void>.delayed,
}) async {
  final transaction = await database.getNextCrudTransaction();
  if (transaction == null) return;

  for (final entry in transaction.crud) {
    try {
      await applier.apply(entry);
    } on UploadException catch (e) {
      if (classifyUploadError(e.code) == UploadFailureKind.permanent) {
        _log.warning('Server rejected ${entry.table}/${entry.id}: $e');
        await _recordSyncError(database, entry, e);
        continue;
      }
      await wait(backoff.nextDelay());
      rethrow;
    } on Object catch (e) {
      // Network and anything unexpected: retry later.
      _log.info('Upload failed, will retry: $e');
      await wait(backoff.nextDelay());
      rethrow;
    }
  }
  await transaction.complete();
  backoff.reset();
}

Future<void> _recordSyncError(
  PowerSyncDatabase database,
  CrudEntry entry,
  UploadException error,
) {
  final opData = entry.opData;
  return database.execute(
    'INSERT INTO sync_errors '
    '(id, table_name, row_id, op, op_data, error_code, message, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [
      const Uuid().v4(),
      entry.table,
      entry.id,
      entry.op.toJson(),
      if (opData == null) null else jsonEncode(opData),
      error.code,
      error.message,
      DateTime.now().toUtc().toIso8601String(),
    ],
  );
}
