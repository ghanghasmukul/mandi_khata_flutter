import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/onboarding/data/onboarding_repository.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late OnboardingRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_onboarding_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = OnboardingRepository(db);
    for (final (id, name) in [(t1, 'Gupta'), (t2, 'Other')]) {
      await db.execute(
        'INSERT INTO tenants (id, name, created_at, updated_at) '
        "VALUES (?, ?, '2026-10-01T00:00:00Z', '2026-10-01T00:00:00Z')",
        [id, name],
      );
    }
    for (final (n, id) in [(1, 'c1'), (2, 'c2'), (3, 'c3')]) {
      await db.execute(
        'INSERT INTO crops (id, tenant_id, code, name_en, is_active, '
        'sort_order) VALUES (?, ?, ?, ?, 1, ?)',
        [id, t1, 'code$n', 'Crop $n', n],
      );
    }
    await db.execute(
      'INSERT INTO crops (id, tenant_id, code, name_en, is_active, '
      "sort_order) VALUES ('x1', ?, 'other', 'Other', 1, 1)",
      [t2],
    );
    // The seed rows above are not part of what the tests look at.
    await db.execute('DELETE FROM ps_crud');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<List<Map<String, Object?>>> audit() =>
      db.getAll('SELECT * FROM audit_log ORDER BY created_at');

  group('updateTenant', () {
    test('writes only changed columns and audits them', () async {
      final failure = await repo.updateTenant(ctx, {
        'name': 'Gupta',
        'mandi_name': 'Khanna',
        'state_code': '03',
      }, can: owner);
      expect(failure, isNull);
      final t = (await repo.watchTenant(t1).first)!;
      expect(t['mandi_name'], 'Khanna');
      expect(t['state_code'], '03');
      final log = await audit();
      expect(log, hasLength(1));
      expect(log.single['table_name'], 'tenants');
      expect(jsonDecode(log.single['after']! as String), {
        'mandi_name': 'Khanna',
        'state_code': '03',
      });
      // The other business is untouched.
      expect((await repo.watchTenant(t2).first)!['mandi_name'], isNull);
    });

    test('nothing changed writes nothing', () async {
      await repo.updateTenant(ctx, {'name': 'Gupta'}, can: owner);
      expect(await audit(), isEmpty);
      expect(await db.getAll('SELECT * FROM ps_crud'), isEmpty);
    });

    test('billing columns and non-owners are refused', () async {
      expect(
        await repo.updateTenant(ctx, {'plan_code': 'pro'}, can: owner),
        OnboardingSaveFailure.invalid,
      );
      expect(
        await repo.updateTenant(ctx, {'name': 'X'}, can: munshi),
        OnboardingSaveFailure.notPermitted,
      );
      expect((await repo.watchTenant(t1).first)!['name'], 'Gupta');
    });
  });

  group('setActiveCrops', () {
    test('switches exactly the chosen crops, never deletes', () async {
      final r = await repo.setActiveCrops(ctx, {'c1', 'c3'}, can: owner);
      expect(r.failure, isNull);
      expect(r.changed, 1);
      final rows = await db.getAll(
        'SELECT id, is_active FROM crops WHERE tenant_id = ? ORDER BY id',
        [t1],
      );
      expect(rows.map((e) => e['is_active']), [1, 0, 1]);
      expect(await audit(), hasLength(1));
      // Another business's crop is never touched.
      expect(
        (await db.get(
          "SELECT is_active FROM crops WHERE id = 'x1'",
        ))['is_active'],
        1,
      );
    });

    test('needs settings.manage', () async {
      final r = await repo.setActiveCrops(ctx, {'c1'}, can: munshi);
      expect(r.failure, OnboardingSaveFailure.notPermitted);
      expect(await audit(), isEmpty);
    });
  });

  test('watchHasData: parties or entries of THIS business only', () async {
    expect(await repo.watchHasData(t1).first, isFalse);
    await db.execute(
      'INSERT INTO parties (id, tenant_id, code, name) '
      "VALUES ('p1', ?, 'A', 'Ram')",
      [t2],
    );
    expect(await repo.watchHasData(t1).first, isFalse);
    expect(await repo.watchHasData(t2).first, isTrue);
  });
}
