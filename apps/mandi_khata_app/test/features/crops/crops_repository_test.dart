import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/crops/data/crops_repository.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const otherTenant = WriteContext(
  tenantId: t2,
  userId: 'user-b',
  deviceId: 'device-b',
  deviceCode: 'W1',
);

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);
bool accountant(Permission p) => MemberRole.accountant.allows(p);

const sunflower = CropInput(
  code: 'sunflower',
  nameEn: '  Sunflower  ',
  nameHi: 'सूरजमुखी',
  namePa: '  ',
  stdRate: Money.rupees(7721),
);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late CropsRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_crops_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = CropsRepository(db);
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

  test('ids match the server seed (UUID v5 of tenant|code)', () {
    // Same value is asserted in supabase/tests/05_crops.test.sql.
    expect(
      CropsRepository.idFor(t1, 'wheat'),
      '60776cdf-4643-5e45-ae83-c04307fcd84c',
    );
  });

  group('create', () {
    test('stores clean values with an audit row, in one upload', () async {
      final r = await repo.create(ctx, sunflower, can: owner);
      expect(r, isA<CropSaved>());
      final id = (r as CropSaved).id;
      expect(id, CropsRepository.idFor(t1, 'sunflower'));

      final c = (await repo.watchOne(t1, id).first)!;
      expect(c.nameEn, 'Sunflower');
      expect(c.nameHi, 'सूरजमुखी');
      expect(c.namePa, isNull);
      expect(c.nameIn('pa'), 'Sunflower');
      expect(c.nameIn('hi'), 'सूरजमुखी');
      expect(c.stdRate, const Money(772100));
      expect(c.unit, 'qtl');
      expect(c.isActive, isTrue);
      expect(c.sortOrder, 10);

      final a = await audit();
      expect(a, hasLength(1));
      expect(a.single['table_name'], 'crops');
      expect(a.single['action'], 'insert');
      expect(a.single['row_id'], id);
      expect(a.single['device_id'], 'device-w1');

      final ops = await crud();
      expect([for (final o in ops) o['type']], ['crops', 'audit_log']);
      expect(
        (await db.getAll('SELECT DISTINCT tx_id FROM ps_crud')).length,
        1,
        reason: 'crop and audit row are one local transaction',
      );
    });

    test('new crops go to the end of the list', () async {
      await repo.create(ctx, sunflower, can: owner);
      await repo.create(
        ctx,
        const CropInput(code: 'jowar', nameEn: 'Jowar'),
        can: owner,
      );
      final crops = await repo.watchAll(t1).first;
      expect(
        [for (final c in crops) (c.code, c.sortOrder)],
        [('sunflower', 10), ('jowar', 20)],
      );
    });

    test('a code is used once per business, active or not', () async {
      await repo.create(ctx, sunflower, can: owner);
      final id = CropsRepository.idFor(t1, 'sunflower');
      await repo.update(
        ctx,
        id,
        const CropInput(
          code: 'sunflower',
          nameEn: 'Sunflower',
          isActive: false,
        ),
        can: owner,
      );
      expect(
        await repo.create(ctx, sunflower, can: owner),
        isA<CropCodeTaken>(),
      );
      // Another business may use the same code.
      expect(
        await repo.create(otherTenant, sunflower, can: owner),
        isA<CropSaved>(),
      );
    });

    test('invalid input is rejected without writing', () async {
      final r = await repo.create(
        ctx,
        const CropInput(code: 'Sun Flower', nameEn: ' ', stdRate: Money(-1)),
        can: owner,
      );
      expect((r as CropInvalid).errors, {
        CropFieldError.code,
        CropFieldError.nameEn,
        CropFieldError.stdRate,
      });
      expect(await crud(), isEmpty);
    });

    test('only settings.manage may add crops', () async {
      expect(
        await repo.create(ctx, sunflower, can: munshi),
        isA<CropNotPermitted>(),
      );
      expect(
        await repo.create(ctx, sunflower, can: accountant),
        isA<CropNotPermitted>(),
      );
      expect(await crud(), isEmpty);
    });
  });

  group('update', () {
    late String id;

    setUp(() async {
      id = ((await repo.create(ctx, sunflower, can: owner)) as CropSaved).id;
      await db.execute('DELETE FROM audit_log');
      await db.execute('DELETE FROM ps_crud');
    });

    test('writes only changed columns, audited before → after', () async {
      final r = await repo.update(
        ctx,
        id,
        const CropInput(
          code: 'sunflower',
          nameEn: 'Sunflower',
          nameHi: 'सूरजमुखी',
          namePa: 'ਸੂਰਜਮੁਖੀ',
          stdRate: Money.rupees(7721),
          isActive: false,
        ),
        can: owner,
      );
      expect(r, isA<CropSaved>());
      final patch = (await crud()).firstWhere((o) => o['type'] == 'crops');
      expect(patch['op'], 'PATCH');
      expect(patch['data'], {
        'name_pa': 'ਸੂਰਜਮੁਖੀ',
        'is_active': 0,
        'updated_at': isA<String>(),
      });

      final a = (await audit()).single;
      expect(a['action'], 'update');
      expect(jsonDecode(a['before']! as String), {
        'name_pa': null,
        'is_active': 1,
      });
      expect(jsonDecode(a['after']! as String), {
        'name_pa': 'ਸੂਰਜਮੁਖੀ',
        'is_active': 0,
      });

      expect(await repo.watchAll(t1).first, isEmpty);
      final all = await repo.watchAll(t1, includeInactive: true).first;
      expect(all.single.isActive, isFalse);
    });

    test('no change → nothing written', () async {
      expect(
        await repo.update(ctx, id, sunflower, can: owner),
        isA<CropSaved>(),
      );
      expect(await crud(), isEmpty);
      expect(await audit(), isEmpty);
    });

    test('the code cannot change', () async {
      final r = await repo.update(
        ctx,
        id,
        const CropInput(code: 'sun_flower', nameEn: 'Sunflower'),
        can: owner,
      );
      expect((r as CropInvalid).errors, {CropFieldError.code});
      expect(await crud(), isEmpty);
    });

    test('another business cannot see or change it', () async {
      expect(await repo.watchOne(t2, id).first, isNull);
      expect(await repo.watchAll(t2, includeInactive: true).first, isEmpty);
      expect(
        await repo.update(otherTenant, id, sunflower, can: owner),
        isA<CropNotFound>(),
      );
    });

    test('a munshi cannot change crops', () async {
      expect(
        await repo.update(ctx, id, sunflower, can: munshi),
        isA<CropNotPermitted>(),
      );
    });
  });
}
