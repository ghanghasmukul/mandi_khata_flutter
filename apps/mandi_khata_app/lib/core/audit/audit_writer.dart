import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

part 'audit_writer.g.dart';

/// Who is writing, where: everything a business write needs besides its
/// data. Null from [writeContextProvider] until someone is signed in with a
/// business picked and this device registered in it.
@immutable
class WriteContext {
  const WriteContext({
    required this.tenantId,
    required this.userId,
    required this.deviceId,
    required this.deviceCode,
  });

  final String tenantId;
  final String userId;

  /// `devices.id` of this install in [tenantId].
  final String deviceId;

  /// Short code (`W1`, `A3`) used in document numbers.
  final String deviceCode;

  @override
  bool operator ==(Object other) =>
      other is WriteContext &&
      other.tenantId == tenantId &&
      other.userId == userId &&
      other.deviceId == deviceId &&
      other.deviceCode == deviceCode;

  @override
  int get hashCode => Object.hash(tenantId, userId, deviceId, deviceCode);
}

@riverpod
WriteContext? writeContext(Ref ref) {
  final session = ref.watch(sessionProvider);
  final tenantId = ref.watch(activeTenantProvider);
  final device = ref.watch(activeDeviceProvider);
  if (session is! SignedIn || tenantId == null || device == null) return null;
  return WriteContext(
    tenantId: tenantId,
    userId: session.user.id,
    deviceId: device.id,
    deviceCode: device.code,
  );
}

/// Values of `audit_log.action`.
enum AuditAction { insert, update, reverse, softDelete, restore }

extension on AuditAction {
  String get dbName => switch (this) {
    AuditAction.softDelete => 'soft_delete',
    _ => name,
  };
}

/// Writes one `audit_log` row per business write, inside the SAME local
/// transaction as the write, so a change and its audit entry are uploaded
/// together or not at all (CLAUDE.md rule 8).
///
/// `role` is filled in by the server from the uploader's membership, never
/// trusted from the device.
abstract final class AuditWriter {
  static Future<void> record(
    SqliteWriteContext tx,
    WriteContext ctx, {
    required String table,
    required String rowId,
    required AuditAction action,
    Map<String, Object?>? before,
    Map<String, Object?>? after,
    DateTime? at,
  }) => tx.execute(
    'INSERT INTO audit_log (id, tenant_id, table_name, row_id, action, '
    'before, after, user_id, device_id, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      const Uuid().v4(),
      ctx.tenantId,
      table,
      rowId,
      action.dbName,
      if (before == null) null else jsonEncode(before),
      if (after == null) null else jsonEncode(after),
      ctx.userId,
      ctx.deviceId,
      (at ?? DateTime.now()).toUtc().toIso8601String(),
    ],
  );
}
