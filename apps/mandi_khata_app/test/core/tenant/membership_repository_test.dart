import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/db/app_database.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:powersync/powersync.dart';

void main() {
  late Directory dir;
  late PowerSyncDatabase ps;
  late AppDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_membership_test');
    ps = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await ps.initialize();
    db = AppDatabase(ps);

    // Two businesses; user A is in both (inactive in one), user B only in
    // the second. Written locally here; normally they arrive by sync.
    await ps.writeTransaction((tx) async {
      for (final (id, name, mandi) in [
        ('t1', 'Sharma Arhat Agency', 'Sirsa'),
        ('t2', 'gupta Trading Co.', null),
        ('t3', 'Bansal Traders', 'Hisar'),
      ]) {
        await tx.execute(
          'INSERT INTO tenants (id, name, mandi_name) VALUES (?, ?, ?)',
          [id, name, mandi],
        );
      }
      for (final (id, tenant, user, role, active) in [
        ('m1', 't1', 'user-a', 'munshi', 1),
        ('m2', 't2', 'user-a', 'owner', 1),
        ('m3', 't3', 'user-a', 'accountant', 0),
        ('m4', 't1', 'user-b', 'owner', 1),
      ]) {
        await tx.execute(
          'INSERT INTO tenant_members (id, tenant_id, user_id, role, '
          'is_active) VALUES (?, ?, ?, ?, ?)',
          [id, tenant, user, role, active],
        );
      }
    });
  });

  tearDown(() async {
    await db.close();
    await ps.close();
    await dir.delete(recursive: true);
  });

  test("lists only the user's active memberships, by name", () async {
    final list = await MembershipRepository(db).watchActive('user-a').first;
    expect(list, const [
      Membership(
        tenantId: 't2',
        tenantName: 'gupta Trading Co.',
        role: MemberRole.owner,
      ),
      Membership(
        tenantId: 't1',
        tenantName: 'Sharma Arhat Agency',
        mandiName: 'Sirsa',
        role: MemberRole.munshi,
      ),
    ]);
  });

  test('never shows another user their businesses', () async {
    final list = await MembershipRepository(db).watchActive('user-b').first;
    expect(list.map((m) => m.tenantId), ['t1']);
    expect(list.single.role, MemberRole.owner);
  });

  test('updates live when a membership is deactivated by sync', () async {
    final stream = MembershipRepository(db).watchActive('user-a');
    final expectation = expectLater(
      stream.map((l) => l.map((m) => m.tenantId).toList()),
      emitsInOrder([
        ['t2', 't1'],
        ['t2'],
      ]),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await ps.execute("UPDATE tenant_members SET is_active = 0 WHERE id = 'm1'");
    await expectation;
  });
}
