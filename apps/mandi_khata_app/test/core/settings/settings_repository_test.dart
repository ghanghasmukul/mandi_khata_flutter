import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ram = 'party-ram';
const shyam = 'party-shyam';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late SettingsRepository repo;
  final start = DateTime.utc(2026, 9, 30, 12);
  var writes = 0;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_settings_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = SettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<SettingWriteFailure?> write(
    String key,
    Object? value, {
    SettingScope scope = SettingScope.tenant,
    String? scopeId,
    String tenant = t1,
    bool Function(Permission) can = owner,
  }) => repo.write(
    tenantId: tenant,
    scope: scope,
    scopeId: scopeId,
    key: key,
    value: value,
    userId: 'user-a',
    deviceId: 'device-1',
    can: can,
    // Each write a second later, so the audit log has a clear order.
    now: start.add(Duration(seconds: writes++)),
  );

  Future<List<Map<String, Object?>>> audit() =>
      db.getAll('SELECT * FROM audit_log ORDER BY created_at');

  test('first write inserts the row and an insert audit entry', () async {
    expect(await write('mandi.commission_pct', '2.25'), isNull);

    final row = await db.get('SELECT * FROM settings');
    expect(row['tenant_id'], t1);
    expect(row['scope'], 'tenant');
    expect(row['scope_id'], isNull);
    expect(jsonDecode(row['value']! as String), '2.25');
    expect(
      row['id'],
      SettingsRepository.rowIdFor(
        t1,
        SettingScope.tenant,
        null,
        'mandi.commission_pct',
      ),
    );

    final log = await audit();
    expect(log, hasLength(1));
    expect(log.single['table_name'], 'settings');
    expect(log.single['row_id'], row['id']);
    expect(log.single['action'], 'insert');
    expect(log.single['before'], isNull);
    expect(jsonDecode(log.single['after']! as String), {
      'scope': 'tenant',
      'scope_id': null,
      'key': 'mandi.commission_pct',
      'value': '2.25',
    });
    expect(log.single['user_id'], 'user-a');
    expect(log.single['device_id'], 'device-1');
  });

  test('changing it updates the same row and audits before → after', () async {
    await write('interest.rate_pa', '18');
    await write('interest.rate_pa', '15');

    final rows = await db.getAll('SELECT value FROM settings');
    expect(rows.map((r) => jsonDecode(r['value']! as String)), ['15']);
    final log = await audit();
    expect(log.map((e) => e['action']), ['insert', 'update']);
    expect((jsonDecode(log.last['before']! as String) as Map)['value'], '18');
    expect((jsonDecode(log.last['after']! as String) as Map)['value'], '15');
  });

  test('saving the same value again writes nothing', () async {
    await write('interest.method', 'compound');
    await write('interest.method', 'compound');
    expect(await audit(), hasLength(1));
  });

  test('reset stores null (inherit) — rows are never deleted', () async {
    await write(
      'interest.rate_pa',
      '12',
      scope: SettingScope.party,
      scopeId: ram,
    );
    await write(
      'interest.rate_pa',
      null,
      scope: SettingScope.party,
      scopeId: ram,
    );

    final row = await db.get('SELECT value FROM settings');
    expect(row['value'], isNull);
    final log = await audit();
    expect((jsonDecode(log.last['after']! as String) as Map)['value'], isNull);
  });

  test('changes are queued for upload (offline-first)', () async {
    await write('mandi.palledari_per_bag', 1500);
    final queued = await db.getAll('SELECT data FROM ps_crud');
    final tables = queued
        .map((r) => (jsonDecode(r['data']! as String) as Map)['type'])
        .toSet();
    expect(tables, {'settings', 'audit_log'});
  });

  group('rejected writes change nothing', () {
    Future<void> expectNothingWritten() async {
      expect(await db.getAll('SELECT * FROM settings'), isEmpty);
      expect(await audit(), isEmpty);
    }

    test('unknown key', () async {
      expect(await write('interest.typo', true), isA<UnknownSetting>());
      await expectNothingWritten();
    });

    test('business-only key at party level', () async {
      expect(
        await write(
          'shop.gst_enabled',
          false,
          scope: SettingScope.party,
          scopeId: ram,
        ),
        isA<NotSettableHere>(),
      );
      await expectNothingWritten();
    });

    test('invalid value', () async {
      final f = await write('mandi.commission_pct', '25');
      expect(f, isA<InvalidSettingValue>());
      expect((f! as InvalidSettingValue).error, SettingError.tooLarge);
      expect(
        await write('mandi.palledari_per_bag', 12.5),
        isA<InvalidSettingValue>(),
      );
      await expectNothingWritten();
    });

    test('munshi: no business-wide keys, no interest anywhere', () async {
      expect(
        await write('mandi.commission_pct', '2', can: munshi),
        isA<SettingNotPermitted>(),
      );
      expect(
        await write(
          'interest.rate_pa',
          '12',
          scope: SettingScope.party,
          scopeId: ram,
          can: munshi,
        ),
        isA<SettingNotPermitted>(),
      );
      await expectNothingWritten();
    });

    test('munshi may set a party-level mandi charge', () async {
      expect(
        await write(
          'mandi.commission_pct',
          '2',
          scope: SettingScope.party,
          scopeId: ram,
          can: munshi,
        ),
        isNull,
      );
    });
  });

  test(
    'watch: only this business, and only rows that apply to the target',
    () async {
      await write('interest.rate_pa', '18');
      await write(
        'interest.rate_pa',
        '12',
        scope: SettingScope.party,
        scopeId: ram,
      );
      await write(
        'interest.rate_pa',
        '9',
        scope: SettingScope.party,
        scopeId: shyam,
      );
      await write('interest.rate_pa', '30', tenant: t2);
      await write(
        'mandi.commission_pct',
        '1',
        scope: SettingScope.lot,
        scopeId: 'lot-1',
      );

      final forRam = await repo.watch(t1, (
        partyId: ram,
        partyGroupId: null,
        documentId: null,
      )).first;
      expect(forRam.map((r) => (r.scope, r.scopeId, r.value)).toSet(), {
        (SettingScope.tenant, null, '18'),
        (SettingScope.party, ram, '12'),
      });
      final resolved = SettingsResolver(
        forRam,
      ).resolve('interest.rate_pa', partyId: ram);
      expect((resolved.value, resolved.level), ('12', SettingLevel.party));

      final business = await repo.watch(t1, businessTarget).first;
      expect(business.map((r) => r.value), ['18']);
    },
  );

  test('two devices creating the same setting offline get the same row id', () {
    // So their uploads become insert + update of ONE row (last write wins)
    // instead of a unique-constraint rejection.
    expect(
      SettingsRepository.rowIdFor(
        t1,
        SettingScope.party,
        ram,
        'interest.rate_pa',
      ),
      SettingsRepository.rowIdFor(
        t1,
        SettingScope.party,
        ram,
        'interest.rate_pa',
      ),
    );
    expect(
      SettingsRepository.rowIdFor(
        t1,
        SettingScope.party,
        ram,
        'interest.rate_pa',
      ),
      isNot(
        SettingsRepository.rowIdFor(
          t2,
          SettingScope.party,
          ram,
          'interest.rate_pa',
        ),
      ),
    );
  });
}
