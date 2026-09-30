import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:logging/logging.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

final _log = Logger('settings');

/// Which party / group / document the settings are being resolved for.
/// All null = business level only.
typedef SettingsTarget = ({
  String? partyId,
  String? partyGroupId,
  String? documentId,
});

const SettingsTarget businessTarget = (
  partyId: null,
  partyGroupId: null,
  documentId: null,
);

/// Why a setting could not be saved.
sealed class SettingWriteFailure {
  const SettingWriteFailure();
}

final class UnknownSetting extends SettingWriteFailure {
  const UnknownSetting();
}

/// The key cannot be set at this level (e.g. `shop.*` for a party).
final class NotSettableHere extends SettingWriteFailure {
  const NotSettableHere();
}

final class InvalidSettingValue extends SettingWriteFailure {
  const InvalidSettingValue(this.error);

  final SettingError error;
}

final class SettingNotPermitted extends SettingWriteFailure {
  const SettingNotPermitted();
}

/// Reads and writes `settings` in the local database only (offline-first).
class SettingsRepository {
  SettingsRepository(this._db);

  final PowerSyncDatabase _db;

  /// Namespace for deterministic setting row ids, so two devices that both
  /// create the same (tenant, scope, scope_id, key) offline write the SAME
  /// row (last write wins) instead of colliding on the unique constraint.
  static const _idNamespace = '6f1c0a52-3b0e-4f7e-9d58-2f3c1c6a9e41';

  static String rowIdFor(
    String tenantId,
    SettingScope scope,
    String? scopeId,
    String key,
  ) => const Uuid().v5(
    _idNamespace,
    '$tenantId|${scope.dbName}|${scopeId ?? ''}|$key',
  );

  /// Rows that can apply to [target] in [tenantId]: business rows, plus
  /// rows for the target's group, party and document. Live.
  Stream<List<SettingRow>> watch(String tenantId, SettingsTarget target) {
    return _db
        .watch(
          'SELECT scope, scope_id, key, value FROM settings '
          'WHERE tenant_id = ? AND ( '
          "scope = 'tenant' "
          "OR (scope = 'party_group' AND scope_id = ?) "
          "OR (scope = 'party' AND scope_id = ?) "
          "OR (scope IN ('loan', 'lot', 'invoice') AND scope_id = ?))",
          parameters: [
            tenantId,
            target.partyGroupId,
            target.partyId,
            target.documentId,
          ],
          triggerOnTables: const {'settings'},
        )
        .map((rows) => [for (final r in rows) ?_toRow(r)]);
  }

  static SettingRow? _toRow(Map<String, Object?> r) {
    final scope = SettingScope.parse(r['scope']! as String);
    if (scope == null) return null;
    final raw = r['value'] as String?;
    Object? value;
    if (raw != null) {
      try {
        value = jsonDecode(raw);
      } on FormatException {
        _log.warning('Unreadable setting ${r['key']}: $raw');
        return null;
      }
    }
    return SettingRow(
      scope: scope,
      scopeId: r['scope_id'] as String?,
      key: r['key']! as String,
      value: value,
    );
  }

  /// Sets [key] at [scope] / [scopeId] to [value] (null = back to
  /// inherited). Validates against the schema, checks [can] and writes the
  /// row and its audit entry ([AuditWriter]) in one local transaction.
  Future<SettingWriteFailure?> write(
    WriteContext ctx, {
    required SettingScope scope,
    required String key,
    required Object? value,
    required bool Function(Permission) can,
    String? scopeId,
    DateTime? now,
  }) async {
    assert(
      (scope == SettingScope.tenant) == (scopeId == null),
      'Only business-level rows have no scope id',
    );
    final parsed = SettingsSchema.parse(key);
    if (parsed == null) return const UnknownSetting();
    if (!parsed.def.allowedAt(scope)) return const NotSettableHere();
    final error = parsed.def.validate(value);
    if (error != null) return InvalidSettingValue(error);
    if (!canWriteSetting(key, scope, can)) return const SettingNotPermitted();

    final tenantId = ctx.tenantId;
    final userId = ctx.userId;
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();
    final json = value == null ? null : jsonEncode(value);
    await _db.writeTransaction((tx) async {
      final existing = await tx.getOptional(
        'SELECT id, value FROM settings WHERE tenant_id = ? AND scope = ? '
        'AND scope_id IS ? AND key = ?',
        [tenantId, scope.dbName, scopeId, key],
      );
      if (existing != null && existing['value'] == json) return;

      final String rowId;
      if (existing != null) {
        rowId = existing['id'] as String;
        await tx.execute(
          'UPDATE settings SET value = ?, updated_by = ?, updated_at = ? '
          'WHERE id = ?',
          [json, userId, at, rowId],
        );
      } else {
        rowId = rowIdFor(tenantId, scope, scopeId, key);
        await tx.execute(
          'INSERT INTO settings (id, tenant_id, scope, scope_id, key, value, '
          'created_by, updated_by, created_at, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            rowId,
            tenantId,
            scope.dbName,
            scopeId,
            key,
            json,
            userId,
            userId,
            at,
            at,
          ],
        );
      }

      Map<String, Object?> snapshot(String? v) => {
        'scope': scope.dbName,
        'scope_id': scopeId,
        'key': key,
        'value': v == null ? null : jsonDecode(v),
      };
      await AuditWriter.record(
        tx,
        ctx,
        table: 'settings',
        rowId: rowId,
        action: existing == null ? AuditAction.insert : AuditAction.update,
        before: existing == null
            ? null
            : snapshot(existing['value'] as String?),
        after: snapshot(json),
        at: when,
      );
    });
    return null;
  }
}
