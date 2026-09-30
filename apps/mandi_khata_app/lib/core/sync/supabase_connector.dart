import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:mandi_khata_app/core/sync/upload_policy.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final _log = Logger('sync');

/// Applies one local transaction to the server, all or nothing. Split out
/// so the connector's queue handling can be tested without a network.
abstract interface class CrudApplier {
  /// Throws [UploadException] with the server's error code on rejection;
  /// then none of [entries] were applied.
  Future<void> applyTransaction(List<CrudEntry> entries);
}

/// A rejected upload, carrying the Postgres / PostgREST error code.
class UploadException implements Exception {
  const UploadException(this.message, {this.code, this.failedIndex});

  final String message;
  final String? code;

  /// Which change of the transaction was rejected (0-based), if known.
  final int? failedIndex;

  @override
  String toString() => 'UploadException($code): $message';
}

/// Sends a whole local transaction to `apply_crud_transaction`, which runs
/// it in one database transaction as the signed-in user, so RLS and the
/// guard triggers apply exactly as for a direct request, and a rejected
/// change never leaves the rest of its transaction on the server.
class SupabaseCrudApplier implements CrudApplier {
  SupabaseCrudApplier(this._client);

  final SupabaseClient _client;

  /// The server names the failing change in the error hint: "op 3".
  static final _opHint = RegExp(r'^op (\d+)$');

  /// The request body for [entries]; public for tests.
  static List<Map<String, Object?>> payload(List<CrudEntry> entries) => [
    for (final e in entries)
      {
        'op': e.op.toJson(),
        'table': e.table,
        'id': e.id,
        'data': toServerPayload(e.table, e.opData ?? const {}),
      },
  ];

  @override
  Future<void> applyTransaction(List<CrudEntry> entries) async {
    try {
      await _client.rpc<void>(
        'apply_crud_transaction',
        params: {'ops': payload(entries)},
      );
    } on PostgrestException catch (e) {
      final op = _opHint.firstMatch(e.hint ?? '')?.group(1);
      throw UploadException(
        e.message,
        code: e.code,
        failedIndex: op == null ? null : int.parse(op) - 1,
      );
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

/// Uploads the next local transaction as one unit. A permanent rejection
/// moves every change of that transaction to `sync_errors` as one batch and
/// completes it, so later changes are not blocked; transient failures wait
/// (exponential backoff) and rethrow so PowerSync retries the transaction.
Future<void> uploadPending(
  PowerSyncDatabase database,
  CrudApplier applier,
  UploadBackoff backoff, {
  Future<void> Function(Duration) wait = Future<void>.delayed,
}) async {
  final transaction = await database.getNextCrudTransaction();
  if (transaction == null) return;

  try {
    await applier.applyTransaction(transaction.crud);
  } on UploadException catch (e) {
    if (classifyUploadError(e.code) != UploadFailureKind.permanent) {
      await wait(backoff.nextDelay());
      rethrow;
    }
    _log.warning(
      'Server rejected a transaction of ${transaction.crud.length} '
      'change(s): $e',
    );
    await _recordRejected(database, transaction.crud, e);
  } on Object catch (e) {
    // Network and anything unexpected: retry later.
    _log.info('Upload failed, will retry: $e');
    await wait(backoff.nextDelay());
    rethrow;
  }
  await transaction.complete();
  backoff.reset();
}

Future<void> _recordRejected(
  PowerSyncDatabase database,
  List<CrudEntry> entries,
  UploadException error,
) {
  final batchId = const Uuid().v4();
  final at = DateTime.now().toUtc().toIso8601String();
  final failed = error.failedIndex;
  final culprit = failed != null && failed >= 0 && failed < entries.length
      ? entries[failed]
      : null;
  return database.writeTransaction((tx) async {
    for (final (i, entry) in entries.indexed) {
      final opData = entry.opData;
      final message = culprit == null || identical(culprit, entry)
          ? error.message
          : 'Not saved: ${culprit.table}/${culprit.id} in the same save '
                'was rejected (${error.message})';
      await tx.execute(
        'INSERT INTO sync_errors (id, table_name, row_id, op, op_data, '
        'error_code, message, created_at, batch_id, batch_seq) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          const Uuid().v4(),
          entry.table,
          entry.id,
          entry.op.toJson(),
          if (opData == null) null else jsonEncode(opData),
          error.code,
          message,
          at,
          batchId,
          i,
        ],
      );
    }
  });
}
