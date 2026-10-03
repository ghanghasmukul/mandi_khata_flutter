import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/team/data/team_repository.dart';
import 'package:mandi_khata_app/features/team/domain/team_models.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';

const ownerCtx = WriteContext(
  tenantId: t1,
  userId: 'u-owner',
  deviceId: 'd-owner',
  deviceCode: 'W1',
);

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late TeamRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_team_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = TeamRepository(db);

    Future<void> user(String id, String name, String phone) => db.execute(
      'INSERT INTO app_users (id, full_name, phone) VALUES (?, ?, ?)',
      [id, name, phone],
    );
    await user('u-owner', 'Naresh Gupta', '919814022110');
    await user('u-acct', 'Meena Devi', '919814022111');
    await user('u-munshi', 'Rajinder Kumar', '919814022112');
    await user('u-other', 'Suresh Sharma', '919896033220');

    Future<void> member(String id, String tenant, String user, String role) =>
        db.execute(
          'INSERT INTO tenant_members (id, tenant_id, user_id, role, '
          'custom_permissions, is_active, device_limit) '
          "VALUES (?, ?, ?, ?, '{}', 1, 5)",
          [id, tenant, user, role],
        );
    await member('m-owner', t1, 'u-owner', 'owner');
    await member('m-acct', t1, 'u-acct', 'accountant');
    await member('m-munshi', t1, 'u-munshi', 'munshi');
    await member('m-other', t2, 'u-other', 'owner');

    Future<void> device(
      String id,
      String tenant,
      String user,
      String code,
    ) => db.execute(
      'INSERT INTO devices (id, tenant_id, user_id, device_code, platform, '
      "last_seen_at) VALUES (?, ?, ?, ?, 'android', '2026-10-03T05:00:00Z')",
      [id, tenant, user, code],
    );
    await device('d-owner', t1, 'u-owner', 'W1');
    await device('d-munshi', t1, 'u-munshi', 'A1');
    await device('d-other', t2, 'u-other', 'W1');

    await db.execute(
      'INSERT INTO member_invites (id, tenant_id, phone, role, '
      "custom_permissions, status) VALUES ('i-1', ?, '919000000001', "
      "'munshi', '{}', 'pending')",
      [t1],
    );
    // Setup rows are not changes to upload.
    await db.execute('DELETE FROM ps_crud');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<List<Map<String, Object?>>> audit() =>
      db.getAll('SELECT * FROM audit_log ORDER BY created_at');

  Future<List<Map<String, Object?>>> crud() async => [
    for (final r in await db.getAll('SELECT data FROM ps_crud ORDER BY id'))
      jsonDecode(r['data']! as String) as Map<String, Object?>,
  ];

  group('reads', () {
    test(
      'members come with their profile, owner first, one business only',
      () async {
        final members = await repo.watchMembers(t1).first;
        expect(
          [for (final m in members) m.displayName],
          ['Naresh Gupta', 'Meena Devi', 'Rajinder Kumar'],
        );
        expect(members.first.role, MemberRole.owner);
        expect(members.first.phone, '919814022110');
        expect(await repo.watchMembers(t2).first, hasLength(1));
      },
    );

    test('devices of one business, with who owns them', () async {
      final devices = await repo.watchDevices(t1).first;
      expect({for (final d in devices) d.code}, {'W1', 'A1'});
      expect(
        devices.firstWhere((d) => d.code == 'A1').userName,
        'Rajinder Kumar',
      );
    });

    test('only pending invites, only this business', () async {
      await db.execute(
        'INSERT INTO member_invites (id, tenant_id, phone, role, '
        "custom_permissions, status) VALUES ('i-2', ?, '919000000002', "
        "'munshi', '{}', 'cancelled')",
        [t1],
      );
      await db.execute(
        'INSERT INTO member_invites (id, tenant_id, phone, role, '
        "custom_permissions, status) VALUES ('i-3', ?, '919000000003', "
        "'munshi', '{}', 'pending')",
        [t2],
      );
      final invites = await repo.watchPendingInvites(t1).first;
      expect([for (final i in invites) i.id], ['i-1']);
    });
  });

  group('updateMember', () {
    test('saves role, overrides and limit; audits before and after; '
        'uploads only the changed columns', () async {
      final r = await repo.updateMember(
        ownerCtx,
        'm-munshi',
        role: MemberRole.accountant,
        overrides: {'finance.view': false},
        deviceLimit: 3,
        actorRole: MemberRole.owner,
        can: owner,
      );
      expect(r, isA<TeamSaved>());
      final m = (await repo.watchMembers(t1).first).firstWhere(
        (m) => m.id == 'm-munshi',
      );
      expect(m.role, MemberRole.accountant);
      expect(m.customPermissions, {'finance.view': false});
      expect(m.deviceLimit, 3);

      final rows = await audit();
      expect(rows, hasLength(1));
      expect(rows.single['table_name'], 'tenant_members');
      expect(rows.single['action'], 'update');
      expect(rows.single['row_id'], 'm-munshi');
      expect(rows.single['user_id'], 'u-owner');
      expect(rows.single['device_id'], 'd-owner');
      expect(jsonDecode(rows.single['before']! as String), {
        'role': 'munshi',
        'device_limit': 5,
        'custom_permissions': <String, Object?>{},
      });
      expect(jsonDecode(rows.single['after']! as String), {
        'role': 'accountant',
        'device_limit': 3,
        'custom_permissions': {'finance.view': false},
      });

      final ops = await crud();
      final patch = ops.firstWhere(
        (o) => o['type'] == 'tenant_members' && o['op'] == 'PATCH',
      );
      expect((patch['data']! as Map).keys.toSet(), {
        'role',
        'custom_permissions',
        'device_limit',
        'updated_at',
      });
    });

    test('nothing changed: nothing written, nothing audited', () async {
      final r = await repo.updateMember(
        ownerCtx,
        'm-munshi',
        role: MemberRole.munshi,
        overrides: const {},
        deviceLimit: 5,
        actorRole: MemberRole.owner,
        can: owner,
      );
      expect(r, isA<TeamSaved>());
      expect(await audit(), isEmpty);
      expect(await crud(), isEmpty);
    });

    test('needs admin.manage', () async {
      final r = await repo.updateMember(
        ownerCtx,
        'm-acct',
        role: MemberRole.munshi,
        overrides: const {},
        deviceLimit: 5,
        actorRole: MemberRole.munshi,
        can: munshi,
      );
      expect(r, isA<TeamNotPermitted>());
      expect(await audit(), isEmpty);
    });

    test('a delegated admin cannot touch an owner, hand out the owner role '
        'or change their own access', () async {
      const adminCtx = WriteContext(
        tenantId: t1,
        userId: 'u-acct',
        deviceId: 'd-acct',
        deviceCode: 'W2',
      );
      bool adminCan(Permission p) =>
          p == Permission.adminManage || MemberRole.accountant.allows(p);

      Future<TeamResult> as_(String id, MemberRole role) => repo.updateMember(
        adminCtx,
        id,
        role: role,
        overrides: const {},
        deviceLimit: 5,
        actorRole: MemberRole.accountant,
        can: adminCan,
      );
      expect(await as_('m-owner', MemberRole.munshi), isA<TeamProtected>());
      expect(await as_('m-munshi', MemberRole.owner), isA<TeamProtected>());
      expect(await as_('m-acct', MemberRole.custom), isA<TeamProtected>());
      expect(await as_('m-munshi', MemberRole.custom), isA<TeamSaved>());
    });

    test('the last owner cannot be demoted, two owners can', () async {
      Future<TeamResult> demote() => repo.updateMember(
        ownerCtx,
        'm-owner',
        role: MemberRole.accountant,
        overrides: const {},
        deviceLimit: 5,
        actorRole: MemberRole.owner,
        can: owner,
      );
      expect(await demote(), isA<TeamLastOwner>());

      await db.execute(
        "UPDATE tenant_members SET role = 'owner' WHERE id = 'm-acct'",
      );
      expect(await demote(), isA<TeamSaved>());
    });

    test("another business's member is not found", () async {
      final r = await repo.updateMember(
        ownerCtx,
        'm-other',
        role: MemberRole.munshi,
        overrides: const {},
        deviceLimit: 5,
        actorRole: MemberRole.owner,
        can: owner,
      );
      expect(r, isA<TeamNotFound>());
      final other = await db.get(
        "SELECT role FROM tenant_members WHERE id = 'm-other'",
      );
      expect(other['role'], 'owner');
    });
  });

  group('setActive', () {
    test('deactivates and reactivates with audit rows', () async {
      expect(
        await repo.setActive(
          ownerCtx,
          'm-munshi',
          active: false,
          actorRole: MemberRole.owner,
          can: owner,
        ),
        isA<TeamSaved>(),
      );
      var m = (await repo.watchMembers(t1).first).firstWhere(
        (m) => m.id == 'm-munshi',
      );
      expect(m.isActive, isFalse);

      await repo.setActive(
        ownerCtx,
        'm-munshi',
        active: true,
        actorRole: MemberRole.owner,
        can: owner,
      );
      m = (await repo.watchMembers(t1).first).firstWhere(
        (m) => m.id == 'm-munshi',
      );
      expect(m.isActive, isTrue);

      final rows = await audit();
      expect(rows, hasLength(2));
      expect(jsonDecode(rows.first['after']! as String), {'is_active': false});
      expect(jsonDecode(rows.last['after']! as String), {'is_active': true});
    });

    test('the only owner cannot be deactivated', () async {
      expect(
        await repo.setActive(
          ownerCtx,
          'm-owner',
          active: false,
          actorRole: MemberRole.owner,
          can: owner,
        ),
        isA<TeamLastOwner>(),
      );
    });

    test('already in that state: no write', () async {
      await repo.setActive(
        ownerCtx,
        'm-munshi',
        active: true,
        actorRole: MemberRole.owner,
        can: owner,
      );
      expect(await audit(), isEmpty);
    });
  });

  group('revokeDevice', () {
    test('marks it revoked by the owner, audited', () async {
      expect(
        await repo.revokeDevice(ownerCtx, 'd-munshi', can: owner),
        isA<TeamSaved>(),
      );
      final d = (await repo.watchDevices(t1).first).firstWhere(
        (d) => d.id == 'd-munshi',
      );
      expect(d.isRevoked, isTrue);
      final row = await db.get(
        "SELECT revoked_by FROM devices WHERE id = 'd-munshi'",
      );
      expect(row['revoked_by'], 'u-owner');

      final rows = await audit();
      expect(rows.single['table_name'], 'devices');
      expect(rows.single['row_id'], 'd-munshi');
      expect(
        jsonDecode(rows.single['before']! as String),
        containsPair('revoked_at', null),
      );
    });

    test('not the device in use, not twice, not another business', () async {
      expect(
        await repo.revokeDevice(ownerCtx, 'd-owner', can: owner),
        isA<TeamProtected>(),
      );
      expect(
        await repo.revokeDevice(ownerCtx, 'd-other', can: owner),
        isA<TeamNotFound>(),
      );
      await repo.revokeDevice(ownerCtx, 'd-munshi', can: owner);
      await repo.revokeDevice(ownerCtx, 'd-munshi', can: owner);
      expect(await audit(), hasLength(1));
    });

    test('needs admin.manage', () async {
      expect(
        await repo.revokeDevice(ownerCtx, 'd-munshi', can: munshi),
        isA<TeamNotPermitted>(),
      );
    });
  });

  group('cancelInvite', () {
    test('cancels a pending invite, audited, once', () async {
      expect(
        await repo.cancelInvite(ownerCtx, 'i-1', can: owner),
        isA<TeamSaved>(),
      );
      expect(await repo.watchPendingInvites(t1).first, isEmpty);
      await repo.cancelInvite(ownerCtx, 'i-1', can: owner);
      final rows = await audit();
      expect(rows, hasLength(1));
      expect(rows.single['table_name'], 'member_invites');
      expect(
        await repo.cancelInvite(ownerCtx, 'nope', can: owner),
        isA<TeamNotFound>(),
      );
    });
  });
}
