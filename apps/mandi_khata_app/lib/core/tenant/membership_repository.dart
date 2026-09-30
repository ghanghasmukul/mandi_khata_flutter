import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show immutable, mapEquals;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/db/app_database.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'membership_repository.g.dart';

/// A business the signed-in user belongs to, and their role in it.
@immutable
class Membership {
  const Membership({
    required this.tenantId,
    required this.tenantName,
    required this.role,
    this.mandiName,
    this.customPermissions = const {},
  });

  final String tenantId;
  final String tenantName;
  final String? mandiName;
  final MemberRole role;

  /// `{"permission.key": true|false}` overrides of the role defaults.
  final Map<String, Object?> customPermissions;

  bool can(Permission permission) =>
      hasPermission(role, customPermissions, permission);

  @override
  bool operator ==(Object other) =>
      other is Membership &&
      other.tenantId == tenantId &&
      other.tenantName == tenantName &&
      other.mandiName == mandiName &&
      other.role == role &&
      mapEquals(other.customPermissions, customPermissions);

  @override
  int get hashCode => Object.hash(tenantId, tenantName, mandiName, role);
}

/// Reads memberships from the local (synced) database, so the business
/// picker works offline once the first sync has run.
///
/// This is the one query that is not filtered by the active tenant: it is
/// what chooses the tenant. It is filtered by user instead.
class MembershipRepository {
  MembershipRepository(this._db);

  final AppDatabase _db;

  Stream<List<Membership>> watchActive(String userId) {
    final query = _db.customSelect(
      'SELECT m.tenant_id, m.role, m.custom_permissions, t.name, t.mandi_name '
      'FROM tenant_members m JOIN tenants t ON t.id = m.tenant_id '
      'WHERE m.user_id = ? AND m.is_active = 1 '
      'ORDER BY t.name COLLATE NOCASE',
      variables: [Variable.withString(userId)],
      readsFrom: {_db.tenantMembers, _db.tenants},
    );
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          Membership(
            tenantId: r.read<String>('tenant_id'),
            tenantName: r.read<String>('name'),
            mandiName: r.readNullable<String>('mandi_name'),
            role: MemberRole.parse(r.read<String>('role')),
            customPermissions: _decodePermissions(
              r.readNullable<String>('custom_permissions'),
            ),
          ),
      ],
    );
  }
}

Map<String, Object?> _decodePermissions(String? json) {
  if (json == null) return const {};
  try {
    final decoded = jsonDecode(json);
    return decoded is Map<String, Object?> ? decoded : const {};
  } on FormatException {
    // Unreadable overrides grant nothing extra (role defaults apply).
    return const {};
  }
}

@Riverpod(keepAlive: true)
Future<MembershipRepository> membershipRepository(Ref ref) async =>
    MembershipRepository(await ref.watch(appDatabaseProvider.future));

/// Active memberships of the signed-in user (empty when signed out).
@riverpod
Stream<List<Membership>> myMemberships(Ref ref) async* {
  final session = ref.watch(sessionProvider);
  if (session is! SignedIn) {
    yield const [];
    return;
  }
  final repo = await ref.watch(membershipRepositoryProvider.future);
  yield* repo.watchActive(session.user.id);
}
