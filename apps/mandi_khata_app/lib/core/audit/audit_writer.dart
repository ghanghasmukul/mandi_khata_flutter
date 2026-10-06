import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart' show MemberRole;
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
    this.lockReason,
  });

  final String tenantId;
  final String userId;

  /// `devices.id` of this install in [tenantId].
  final String deviceId;

  /// Short code (`W1`, `A3`) used in document numbers.
  final String deviceCode;

  /// The owner's reason for writing inside a closed financial year, while
  /// they have unlocked it for this session (step 3.5); null otherwise.
  final String? lockReason;

  @override
  bool operator ==(Object other) =>
      other is WriteContext &&
      other.tenantId == tenantId &&
      other.userId == userId &&
      other.deviceId == deviceId &&
      other.deviceCode == deviceCode &&
      other.lockReason == lockReason;

  @override
  int get hashCode =>
      Object.hash(tenantId, userId, deviceId, deviceCode, lockReason);
}

@riverpod
WriteContext? writeContext(Ref ref) {
  final session = ref.watch(sessionProvider);
  final tenantId = ref.watch(activeTenantProvider);
  final device = ref.watch(activeDeviceProvider);
  if (session is! SignedIn || tenantId == null || device == null) return null;
  final isOwner = ref.watch(activeMembershipProvider)?.role == MemberRole.owner;
  return WriteContext(
    tenantId: tenantId,
    userId: session.user.id,
    deviceId: device.id,
    deviceCode: device.code,
    lockReason: isOwner ? ref.watch(lockOverrideProvider) : null,
  );
}

/// The owner's reason while a closed financial year is unlocked on this
/// device (Year close screen); cleared on restart. Only owners' writes
/// carry it (writeContextProvider).
@Riverpod(keepAlive: true)
class LockOverride extends _$LockOverride {
  @override
  String? build() => null;

  void set(String? reason) {
    final r = reason?.trim();
    state = r == null || r.isEmpty ? null : r;
  }
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
