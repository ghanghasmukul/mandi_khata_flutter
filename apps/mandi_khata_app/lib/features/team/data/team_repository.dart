import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/team/domain/team_models.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;

/// People, invites and devices of one business in the local database.
///
/// Reads are live. Changes (role, permission overrides, device limit,
/// deactivate, revoke a device, cancel an invite) are local writes with an
/// audit row in the same transaction, so they work offline and upload later;
/// RLS and guard triggers enforce the same rules on the server
/// (`admin.manage`, owner-only changes to owners).
///
/// Creating an invite is the one online action: it goes through the
/// `invite-member` Edge Function (see `InviteService`).
class TeamRepository {
  TeamRepository(this._db);

  final PowerSyncDatabase _db;

  Stream<List<TeamMember>> watchMembers(String tenantId) => _db
      .watch(
        'SELECT m.*, u.full_name, u.phone FROM tenant_members m '
        'LEFT JOIN app_users u ON u.id = m.user_id '
        'WHERE m.tenant_id = ? '
        "ORDER BY m.is_active DESC, CASE m.role WHEN 'owner' THEN 0 "
        "WHEN 'accountant' THEN 1 WHEN 'munshi' THEN 2 ELSE 3 END, "
        'u.full_name COLLATE NOCASE',
        parameters: [tenantId],
        triggerOnTables: const {'tenant_members', 'app_users'},
      )
      .map((rows) => [for (final r in rows) TeamMember.fromRow(r)]);

  Stream<List<TeamDevice>> watchDevices(String tenantId) => _db
      .watch(
        'SELECT d.*, u.full_name FROM devices d '
        'LEFT JOIN app_users u ON u.id = d.user_id '
        'WHERE d.tenant_id = ? '
        'ORDER BY (d.revoked_at IS NOT NULL), d.last_seen_at DESC',
        parameters: [tenantId],
        triggerOnTables: const {'devices', 'app_users'},
      )
      .map((rows) => [for (final r in rows) TeamDevice.fromRow(r)]);

  /// Invites still waiting (not accepted / cancelled).
  Stream<List<TeamInvite>> watchPendingInvites(String tenantId) => _db
      .watch(
        'SELECT * FROM member_invites WHERE tenant_id = ? '
        "AND status = 'pending' ORDER BY created_at DESC",
        parameters: [tenantId],
        triggerOnTables: const {'member_invites'},
      )
      .map((rows) => [for (final r in rows) TeamInvite.fromRow(r)]);

  /// Saves the role, permission overrides and device limit of a member.
  ///
  /// Only changed columns are written. [actorRole] is the role of the person
  /// making the change; only owners may touch owners.
  Future<TeamResult> updateMember(
    WriteContext ctx,
    String memberId, {
    required MemberRole role,
    required Map<String, bool> overrides,
    required int deviceLimit,
    required MemberRole actorRole,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.adminManage)) return const TeamNotPermitted();
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM tenant_members WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, memberId],
      );
      if (row == null) return const TeamNotFound();
      final current = TeamMember.fromRow(row);
      final guard = await _guard(
        tx,
        ctx,
        current,
        actorRole: actorRole,
        changesAccess: true,
        newRole: role,
        stopsBeingOwner: current.isOwner && role != MemberRole.owner,
      );
      if (guard != null) return guard;

      final newOverrides = role == MemberRole.owner
          ? const <String, bool>{}
          : overrides;
      final before = <String, Object?>{};
      final after = <String, Object?>{};
      if (role != current.role) {
        before['role'] = current.role.name;
        after['role'] = role.name;
      }
      if (jsonEncode(_sorted(newOverrides)) !=
          jsonEncode(_sorted(current.customPermissions))) {
        before['custom_permissions'] = current.customPermissions;
        after['custom_permissions'] = newOverrides;
      }
      if (deviceLimit != current.deviceLimit) {
        before['device_limit'] = current.deviceLimit;
        after['device_limit'] = deviceLimit;
      }
      if (after.isEmpty) return const TeamSaved();

      final sets = <String>[];
      final args = <Object?>[];
      if (after.containsKey('role')) {
        sets.add('role = ?');
        args.add(role.name);
      }
      if (after.containsKey('custom_permissions')) {
        sets.add('custom_permissions = ?');
        args.add(jsonEncode(newOverrides));
      }
      if (after.containsKey('device_limit')) {
        sets.add('device_limit = ?');
        args.add(deviceLimit);
      }
      await tx.execute(
        'UPDATE tenant_members SET ${sets.join(', ')}, updated_at = ? '
        'WHERE tenant_id = ? AND id = ?',
        [...args, at, ctx.tenantId, memberId],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'tenant_members',
        rowId: memberId,
        action: AuditAction.update,
        before: before,
        after: after,
        at: when,
      );
      return const TeamSaved();
    });
  }

  /// Switches a member off (or back on). Their data leaves their devices on
  /// the next sync; their history stays.
  Future<TeamResult> setActive(
    WriteContext ctx,
    String memberId, {
    required bool active,
    required MemberRole actorRole,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.adminManage)) return const TeamNotPermitted();
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM tenant_members WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, memberId],
      );
      if (row == null) return const TeamNotFound();
      final current = TeamMember.fromRow(row);
      if (current.isActive == active) return const TeamSaved();
      final guard = await _guard(
        tx,
        ctx,
        current,
        actorRole: actorRole,
        changesAccess: true,
        newRole: current.role,
        stopsBeingOwner: current.isOwner && !active,
      );
      if (guard != null) return guard;
      await tx.execute(
        'UPDATE tenant_members SET is_active = ?, updated_at = ? '
        'WHERE tenant_id = ? AND id = ?',
        [
          if (active) 1 else 0,
          when.toUtc().toIso8601String(),
          ctx.tenantId,
          memberId,
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'tenant_members',
        rowId: memberId,
        action: AuditAction.update,
        before: {'is_active': current.isActive},
        after: {'is_active': active},
        at: when,
      );
      return const TeamSaved();
    });
  }

  /// Revokes a device: it cannot sync or register again, and writes it made
  /// offline are rejected by the server.
  Future<TeamResult> revokeDevice(
    WriteContext ctx,
    String deviceId, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.adminManage)) return const TeamNotPermitted();
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM devices WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, deviceId],
      );
      if (row == null) return const TeamNotFound();
      if (row['revoked_at'] != null) return const TeamSaved();
      if (deviceId == ctx.deviceId) return const TeamProtected();
      await tx.execute(
        'UPDATE devices SET revoked_at = ?, revoked_by = ?, updated_at = ? '
        'WHERE tenant_id = ? AND id = ?',
        [at, ctx.userId, at, ctx.tenantId, deviceId],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'devices',
        rowId: deviceId,
        action: AuditAction.update,
        before: {'revoked_at': null, 'device_code': row['device_code']},
        after: {'revoked_at': at, 'device_code': row['device_code']},
        at: when,
      );
      return const TeamSaved();
    });
  }

  /// Cancels a pending invite.
  Future<TeamResult> cancelInvite(
    WriteContext ctx,
    String inviteId, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.adminManage)) return const TeamNotPermitted();
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM member_invites WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, inviteId],
      );
      if (row == null) return const TeamNotFound();
      if (row['status'] != 'pending') return const TeamSaved();
      await tx.execute(
        "UPDATE member_invites SET status = 'cancelled', updated_at = ? "
        'WHERE tenant_id = ? AND id = ?',
        [at, ctx.tenantId, inviteId],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'member_invites',
        rowId: inviteId,
        action: AuditAction.update,
        before: {'status': 'pending', 'phone': row['phone']},
        after: {'status': 'cancelled', 'phone': row['phone']},
        at: when,
      );
      return const TeamSaved();
    });
  }

  /// Owner safety shared by role changes and deactivation. Mirrors the SQL
  /// `guard_tenant_members` trigger so the user gets a clear message instead
  /// of a rejected upload.
  Future<TeamResult?> _guard(
    SqliteWriteContext tx,
    WriteContext ctx,
    TeamMember target, {
    required MemberRole actorRole,
    required bool changesAccess,
    required MemberRole newRole,
    required bool stopsBeingOwner,
  }) async {
    final actorIsOwner = actorRole == MemberRole.owner;
    if (!actorIsOwner && (target.isOwner || newRole == MemberRole.owner)) {
      return const TeamProtected();
    }
    if (!actorIsOwner && changesAccess && target.userId == ctx.userId) {
      return const TeamProtected();
    }
    if (stopsBeingOwner && target.isActive) {
      final owners = await tx.getAll(
        'SELECT id FROM tenant_members WHERE tenant_id = ? '
        "AND role = 'owner' AND is_active = 1",
        [ctx.tenantId],
      );
      if (!TeamRules.keepsAnOwner([
        for (final o in owners) o['id']! as String,
      ], target.id)) {
        return const TeamLastOwner();
      }
    }
    return null;
  }

  static Map<String, Object?> _sorted(Map<String, Object?> m) => {
    for (final k in m.keys.toList()..sort()) k: m[k],
  };
}
