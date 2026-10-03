import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

Map<String, Object?> decodePermissions(Object? raw) {
  if (raw is Map<String, Object?>) return raw;
  if (raw is String && raw.isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) return decoded;
    } on FormatException {
      // Unreadable overrides grant nothing extra.
    }
  }
  return const {};
}

DateTime? _time(Object? raw) =>
    raw is String ? DateTime.tryParse(raw)?.toLocal() : null;

/// One person in the business (`tenant_members` + their profile).
@immutable
class TeamMember {
  const TeamMember({
    required this.id,
    required this.userId,
    required this.role,
    required this.customPermissions,
    required this.isActive,
    required this.deviceLimit,
    this.fullName,
    this.phone,
  });

  factory TeamMember.fromRow(Map<String, Object?> r) => TeamMember(
    id: r['id']! as String,
    userId: r['user_id']! as String,
    fullName: r['full_name'] as String?,
    phone: r['phone'] as String?,
    role: MemberRole.parse(r['role']! as String),
    customPermissions: decodePermissions(r['custom_permissions']),
    isActive: (r['is_active'] as int? ?? 1) != 0,
    deviceLimit: r['device_limit'] as int? ?? 5,
  );

  final String id;
  final String userId;
  final String? fullName;
  final String? phone;
  final MemberRole role;
  final Map<String, Object?> customPermissions;
  final bool isActive;
  final int deviceLimit;

  bool get isOwner => role == MemberRole.owner;

  /// Name to show: profile name, else the phone, else a short id.
  String get displayName {
    final n = fullName?.trim();
    if (n != null && n.isNotEmpty) return n;
    final p = phone;
    if (p != null && p.isNotEmpty) return TeamRules.displayPhone(p);
    return userId.substring(0, userId.length < 8 ? userId.length : 8);
  }

  Set<Permission> get effective => TeamRules.effective(role, customPermissions);
}

/// An install of the app (`devices`).
@immutable
class TeamDevice {
  const TeamDevice({
    required this.id,
    required this.userId,
    required this.code,
    required this.platform,
    this.userName,
    this.name,
    this.lastSeenAt,
    this.revokedAt,
  });

  factory TeamDevice.fromRow(Map<String, Object?> r) => TeamDevice(
    id: r['id']! as String,
    userId: r['user_id']! as String,
    userName: r['full_name'] as String?,
    code: r['device_code']! as String,
    platform: r['platform']! as String,
    name: r['name'] as String?,
    lastSeenAt: _time(r['last_seen_at']),
    revokedAt: _time(r['revoked_at']),
  );

  final String id;
  final String userId;
  final String? userName;
  final String code;
  final String platform;
  final String? name;
  final DateTime? lastSeenAt;
  final DateTime? revokedAt;

  bool get isRevoked => revokedAt != null;
}

/// An invitation that has not turned into a membership yet.
@immutable
class TeamInvite {
  const TeamInvite({
    required this.id,
    required this.phone,
    required this.role,
    required this.customPermissions,
    required this.status,
    this.fullName,
    this.expiresAt,
    this.createdAt,
  });

  factory TeamInvite.fromRow(Map<String, Object?> r) => TeamInvite(
    id: r['id']! as String,
    phone: r['phone']! as String,
    fullName: r['full_name'] as String?,
    role: MemberRole.parse(r['role']! as String),
    customPermissions: decodePermissions(r['custom_permissions']),
    status: r['status']! as String,
    expiresAt: _time(r['expires_at']),
    createdAt: _time(r['created_at']),
  );

  final String id;
  final String phone;
  final String? fullName;
  final MemberRole role;
  final Map<String, Object?> customPermissions;
  final String status;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  bool isExpired(DateTime now) => expiresAt != null && expiresAt!.isBefore(now);
}

/// Outcome of a team change.
sealed class TeamResult {
  const TeamResult();
}

class TeamSaved extends TeamResult {
  const TeamSaved();
}

class TeamNotPermitted extends TeamResult {
  const TeamNotPermitted();
}

class TeamNotFound extends TeamResult {
  const TeamNotFound();
}

/// The change would leave the business without an active owner.
class TeamLastOwner extends TeamResult {
  const TeamLastOwner();
}

/// Only an owner may change an owner (or hand out the owner role), and
/// nobody changes their own access.
class TeamProtected extends TeamResult {
  const TeamProtected();
}
