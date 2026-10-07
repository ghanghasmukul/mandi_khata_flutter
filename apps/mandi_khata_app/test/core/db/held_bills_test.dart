import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:powersync/powersync.dart';

/// Hold bills (phase 4, step 4.3) live in the local-only `held_bills` table:
/// they never reach the upload queue and are wiped with the rest of the local
/// database when another user signs in.
void main() {
  late Directory dir;
  late PowerSyncDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_held_bills_test');
    db = PowerSyncDatabase(
      schema: powerSyncSchema,
      path: '${dir.path}/test.db',
    );
    await db.initialize();
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> hold() => db.execute(
    'INSERT INTO held_bills (id, tenant_id, device_id, payload, created_at) '
    "VALUES ('h1', 't1', 'd1', '{\"lines\":[]}', '2026-10-07T10:00:00Z')",
  );

  Future<int> count(String sql) async => (await db.get(sql))['n'] as int;

  test('a held bill is local only: nothing is queued for upload', () async {
    await hold();
    expect(await count('SELECT count(*) AS n FROM held_bills'), 1);
    expect(await count('SELECT count(*) AS n FROM ps_crud'), 0);
  });

  test('disconnectAndClear wipes held bills with the rest', () async {
    await hold();
    await db.disconnectAndClear();
    expect(await count('SELECT count(*) AS n FROM held_bills'), 0);
  });

  test('held_bills is not a synced table', () {
    expect(syncedTable('held_bills'), isNull);
  });
}
