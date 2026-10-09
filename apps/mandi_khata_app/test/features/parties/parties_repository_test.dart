import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/parties/data/parties_repository.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
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
bool custom(Permission _) => false;

PartyInput gurmeet({String code = ''}) => PartyInput(
  code: code,
  name: '  Gurmeet   Singh ',
  roles: const {PartyRole.farmer, PartyRole.customer},
  relation: Relation.sonOf,
  fatherOrHusbandName: 'Bachan Singh',
  village: 'Rampura',
  mobile: '+91 98140-22110',
  bankAccount: '0012 3456 7890',
  ifsc: 'sbin0001234',
);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late PartiesRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_parties_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = PartiesRepository(db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<String> add(PartyInput input, {WriteContext c = ctx}) async {
    final r = await repo.create(c, input, can: owner);
    return (r as PartySaved).id;
  }

  Future<List<Map<String, Object?>>> audit() =>
      db.getAll('SELECT * FROM audit_log ORDER BY created_at, table_name');

  Future<List<Map<String, Object?>>> crud() async => [
    for (final r in await db.getAll('SELECT data FROM ps_crud ORDER BY id'))
      jsonDecode(r['data']! as String) as Map<String, Object?>,
  ];

  group('plan party limit', () {
    test(
      'the party over the limit is refused and nothing is written',
      () async {
        await add(gurmeet(code: 'A'));
        await add(gurmeet(code: 'B'));
        final r = await repo.create(
          ctx,
          gurmeet(code: 'C'),
          can: owner,
          maxParties: 2,
        );
        expect(r, isA<PartyLimitReached>());
        expect((r as PartyLimitReached).limit, 2);
        final n = await db.get('SELECT count(*) AS n FROM parties');
        expect(n['n'], 2);
        expect((await audit()).where((a) => a['row_id'] == null), isEmpty);
      },
    );

    test('room left, no limit, or another business: saved', () async {
      await add(gurmeet(code: 'A'));
      expect(
        await repo.create(ctx, gurmeet(code: 'B'), can: owner, maxParties: 2),
        isA<PartySaved>(),
      );
      expect(
        await repo.create(ctx, gurmeet(code: 'C'), can: owner),
        isA<PartySaved>(),
      );
      // The other business has none of its own yet.
      expect(
        await repo.create(
          otherTenant,
          gurmeet(code: 'A'),
          can: owner,
          maxParties: 1,
        ),
        isA<PartySaved>(),
      );
    });

    test('deleted parties do not count', () async {
      final id = await add(gurmeet(code: 'A'));
      await db.execute(
        "UPDATE parties SET deleted_at = '2027-01-01' WHERE id = ?",
        [id],
      );
      expect(
        await repo.create(ctx, gurmeet(code: 'B'), can: owner, maxParties: 1),
        isA<PartySaved>(),
      );
    });
  });

  group('create', () {
    test('stores clean values, auto code, roles and audit rows', () async {
      final r = await repo.create(ctx, gurmeet(), can: owner);
      expect(r, isA<PartySaved>());
      expect((r as PartySaved).code, 'P-W1-0001');

      final p = (await repo.watchOne(t1, r.id).first)!;
      expect(p.name, 'Gurmeet Singh');
      expect(p.mobile, '9814022110');
      expect(p.ifsc, 'SBIN0001234');
      expect(p.bankAccountMasked, 'XXXX7890');
      expect(p.relation, Relation.sonOf);
      expect(p.roles, {PartyRole.farmer, PartyRole.customer});

      final log = await audit();
      expect(log.map((e) => (e['table_name'], e['action'])).toList(), [
        ('parties', 'insert'),
        ('party_roles', 'insert'),
        ('party_roles', 'insert'),
      ]);
      expect(log.every((e) => e['device_id'] == 'device-w1'), isTrue);
    });

    test('auto codes count up per device', () async {
      await add(gurmeet());
      final second = await repo.create(ctx, gurmeet(), can: owner);
      expect((second as PartySaved).code, 'P-W1-0002');
    });

    test('an auto code skips a code someone typed by hand', () async {
      await add(gurmeet(code: 'p-w1-0001'));
      final r = await repo.create(ctx, gurmeet(), can: owner);
      expect((r as PartySaved).code, 'P-W1-0002');
    });

    test('a taken code (any case) is refused and nothing is written', () async {
      await add(gurmeet(code: 'F-101'));
      final before = (await crud()).length;
      expect(
        await repo.create(ctx, gurmeet(code: 'f-101'), can: owner),
        isA<PartyCodeTaken>(),
      );
      expect((await crud()).length, before);
    });

    test('invalid input is refused before anything is written', () async {
      final r = await repo.create(
        ctx,
        const PartyInput(code: '', name: '', roles: {}, mobile: '123'),
        can: owner,
      );
      expect((r as PartyInvalid).errors.keys, {
        PartyField.name,
        PartyField.roles,
        PartyField.mobile,
      });
      expect(await crud(), isEmpty);
      // No number was used up.
      expect(await repo.previewNextCode(ctx), 'P-W1-0001');
    });

    test('needs parties.manage', () async {
      expect(
        await repo.create(ctx, gurmeet(), can: custom),
        isA<PartyNotPermitted>(),
      );
      expect(await repo.create(ctx, gurmeet(), can: munshi), isA<PartySaved>());
    });
  });

  group('update', () {
    test(
      'writes only the changed fields (per-field last write wins)',
      () async {
        final id = await add(gurmeet());
        await db.execute('DELETE FROM ps_crud');
        final p = (await repo.watchOne(t1, id).first)!;

        final r = await repo.update(
          ctx,
          id,
          p.toInput().copyWith(village: 'Mansa'),
          can: owner,
        );
        expect(r, isA<PartySaved>());

        final ops = await crud();
        expect(ops.first['op'], 'PATCH');
        expect(ops.first['type'], 'parties');
        final data = ops.first['data']! as Map;
        expect(data.keys.toSet(), {'village', 'updated_at'});

        final log = (await audit()).last;
        expect(log['action'], 'update');
        expect(jsonDecode(log['before']! as String), {'village': 'Rampura'});
        expect(jsonDecode(log['after']! as String), {'village': 'Mansa'});
      },
    );

    test('saving without changes writes nothing', () async {
      final id = await add(gurmeet());
      await db.execute('DELETE FROM ps_crud');
      final p = (await repo.watchOne(t1, id).first)!;
      await repo.update(ctx, id, p.toInput(), can: owner);
      expect(await crud(), isEmpty);
    });

    test(
      'roles: removing soft-deletes, adding back restores the same row',
      () async {
        final id = await add(gurmeet());
        final p = (await repo.watchOne(t1, id).first)!;
        await repo.update(
          ctx,
          id,
          p.toInput().copyWith(roles: {PartyRole.farmer}),
          can: owner,
        );
        expect((await repo.watchOne(t1, id).first)!.roles, {PartyRole.farmer});

        await repo.update(
          ctx,
          id,
          p.toInput().copyWith(roles: {PartyRole.farmer, PartyRole.customer}),
          can: owner,
        );
        final rows = await db.getAll(
          'SELECT id, role, deleted_at FROM party_roles WHERE party_id = ?',
          [id],
        );
        expect(rows, hasLength(2));
        expect(rows.every((r) => r['deleted_at'] == null), isTrue);
        expect(rows.map((r) => r['id']).toSet(), {
          PartiesRepository.roleRowId(id, PartyRole.farmer),
          PartiesRepository.roleRowId(id, PartyRole.customer),
        });
        final actions = (await audit())
            .where((e) => e['table_name'] == 'party_roles')
            .map((e) => e['action']);
        expect(actions, ['insert', 'insert', 'soft_delete', 'restore']);
      },
    );

    test('changing to a taken code is refused', () async {
      await add(gurmeet(code: 'F-101'));
      final id = await add(gurmeet(code: 'F-102'));
      final p = (await repo.watchOne(t1, id).first)!;
      expect(
        await repo.update(
          ctx,
          id,
          p.toInput().copyWith(code: 'F-101'),
          can: owner,
        ),
        isA<PartyCodeTaken>(),
      );
    });
  });

  group('soft delete', () {
    test('owner only (master.delete); hides the party; audited', () async {
      final id = await add(gurmeet());
      expect(
        await repo.softDelete(ctx, id, can: munshi),
        isA<PartyNotPermitted>(),
      );
      expect(await repo.softDelete(ctx, id, can: owner), isA<PartySaved>());

      expect(await repo.watchOne(t1, id).first, isNull);
      expect(await repo.watchAll(t1).first, isEmpty);
      final row = await db.get('SELECT deleted_at FROM parties WHERE id = ?', [
        id,
      ]);
      expect(row['deleted_at'], isNotNull);
      expect((await audit()).last['action'], 'soft_delete');
      // Deleted again: nothing to delete.
      expect(await repo.softDelete(ctx, id, can: owner), isA<PartyNotFound>());
    });
  });

  group('search and filter', () {
    setUp(() async {
      await add(gurmeet(code: 'F-101'));
      await add(
        const PartyInput(
          code: 'B-201',
          name: 'Aggarwal Traders',
          roles: {PartyRole.buyer},
          village: 'Mansa',
          mobile: '9876500001',
        ),
      );
      await add(
        const PartyInput(
          code: 'F-102',
          name: 'Harpreet Kaur',
          roles: {PartyRole.farmer},
          relation: Relation.wifeOf,
          fatherOrHusbandName: 'Jaswant Singh',
          village: 'Rampura',
        ),
      );
      await add(
        const PartyInput(
          code: 'X-1',
          name: 'Other business party',
          roles: {PartyRole.farmer},
        ),
        c: otherTenant,
      );
    });

    Future<List<String>> codes({String q = '', PartyRole? role}) async => [
      for (final p in await repo.watchAll(t1, query: q, role: role).first)
        p.code,
    ];

    test('all, by name, only this business', () async {
      expect(await codes(), ['B-201', 'F-101', 'F-102']);
    });

    test('by name, father / husband, village, code, mobile', () async {
      expect(await codes(q: 'harp'), ['F-102']);
      expect(await codes(q: 'jaswant'), ['F-102']);
      expect(await codes(q: 'RAMPURA'), ['F-101', 'F-102']);
      expect(await codes(q: 'b-2'), ['B-201']);
      expect(await codes(q: '98765 00'), ['B-201']);
      expect(await codes(q: '22110'), ['F-101']);
    });

    test('wildcards in the search are literal', () async {
      expect(await codes(q: '%'), isEmpty);
      expect(await codes(q: '_'), isEmpty);
    });

    test('role filter, alone and with search', () async {
      expect(await codes(role: PartyRole.buyer), ['B-201']);
      expect(await codes(role: PartyRole.customer), ['F-101']);
      expect(await codes(q: 'rampura', role: PartyRole.customer), ['F-101']);
    });

    test('the list updates live', () async {
      final stream = repo.watchAll(t1, query: 'singh');
      final expectation = expectLater(
        stream.map((l) => l.length),
        emitsInOrder([2, emitsThrough(3)]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await add(
        const PartyInput(
          code: 'F-103',
          name: 'Kulwant Singh',
          roles: {PartyRole.farmer},
        ),
      );
      await expectation;
    });
  });

  test('10k parties: search stays fast', () async {
    // Bulk-load like a first sync would (no audit needed for the timing).
    await db.writeTransaction((tx) async {
      await tx.executeBatch(
        'INSERT INTO parties (id, tenant_id, code, name, village, mobile) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        [
          for (var i = 0; i < 10000; i++)
            [
              'p$i',
              t1,
              'F-$i',
              'Farmer ${i.toString().padLeft(5, '0')}',
              'Village ${i % 300}',
              '98${10000000 + i}',
            ],
        ],
      );
      await tx.executeBatch(
        'INSERT INTO party_roles (id, tenant_id, party_id, role) '
        'VALUES (?, ?, ?, ?)',
        [
          for (var i = 0; i < 10000; i++)
            ['r$i', t1, 'p$i', if (i.isEven) 'farmer' else 'buyer'],
        ],
      );
    });

    Future<(int, Duration)> time({String q = '', PartyRole? role}) async {
      final sw = Stopwatch()..start();
      final list = await repo.watchAll(t1, query: q, role: role).first;
      return (list.length, sw.elapsed);
    }

    final all = await time();
    final search = await time(q: 'village 12');
    final filtered = await time(q: 'farmer 0', role: PartyRole.buyer);
    // ignore: avoid_print — timing is the point of this test.
    print(
      '10k parties: all ${all.$2.inMilliseconds} ms, '
      'search ${search.$2.inMilliseconds} ms, '
      'search+role ${filtered.$2.inMilliseconds} ms',
    );

    expect(all.$1, 10000);
    expect(search.$1, greaterThan(0));
    expect(filtered.$1, greaterThan(0));
    // Generous bound so slow CI machines pass; locally it is far below.
    for (final d in [all.$2, search.$2, filtered.$2]) {
      expect(d, lessThan(const Duration(seconds: 2)));
    }
  });
}
