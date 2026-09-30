import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/numbering/number_series_service.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:powersync/powersync.dart';

const tenant = '11111111-1111-4111-8111-111111111111';
const w1 = WriteContext(
  tenantId: tenant,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const a1 = WriteContext(
  tenantId: tenant,
  userId: 'user-b',
  deviceId: 'device-a1',
  deviceCode: 'A1',
);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_numbering_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<String> next(WriteContext ctx, DocumentSeries series) =>
      db.writeTransaction((tx) => NumberSeriesService.next(tx, ctx, series));

  test(
    'first numbers use the default prefix and count up per device',
    () async {
      expect(await next(w1, DocumentSeries.receipt), 'R-W1-0001');
      expect(await next(w1, DocumentSeries.receipt), 'R-W1-0002');
      expect(await next(w1, DocumentSeries.lot), 'L-W1-0001');
      // Another device has its own counter, so offline numbers never collide.
      expect(await next(a1, DocumentSeries.receipt), 'R-A1-0001');
      expect(await next(w1, DocumentSeries.receipt), 'R-W1-0003');
    },
  );

  test('the counter row is stored per (series, device) and synced', () async {
    await next(w1, DocumentSeries.salesInvoice);
    await next(w1, DocumentSeries.salesInvoice);
    final row = await db.get('SELECT * FROM number_series');
    expect(row['series'], 'SI');
    expect(row['device_code'], 'W1');
    expect(row['next_value'], 3);
    expect(row['id'], NumberSeriesService.rowIdFor(tenant, 'SI', 'W1'));
    final queued = await db.getAll('SELECT data FROM ps_crud');
    expect(
      queued.map((r) => (jsonDecode(r['data']! as String) as Map)['type']),
      everyElement('number_series'),
    );
  });

  test("the business's prefix and start value are used", () async {
    await SettingsRepository(db).write(
      w1,
      scope: SettingScope.tenant,
      key: 'business.number_series.receipt',
      value: {'prefix': 'RC-', 'next': 3001},
      can: (_) => true,
    );
    expect(await next(w1, DocumentSeries.receipt), 'RC-W1-3001');
    expect(await next(w1, DocumentSeries.receipt), 'RC-W1-3002');
    // Changing the prefix later does not restart the counter.
    await SettingsRepository(db).write(
      w1,
      scope: SettingScope.tenant,
      key: 'business.number_series.receipt',
      value: {'prefix': 'R-', 'next': 1},
      can: (_) => true,
    );
    expect(await next(w1, DocumentSeries.receipt), 'R-W1-3003');
  });

  test('a failed document write does not use up a number', () async {
    await next(w1, DocumentSeries.receipt);
    await expectLater(
      db.writeTransaction((tx) async {
        await NumberSeriesService.next(tx, w1, DocumentSeries.receipt);
        throw StateError('document insert failed');
      }),
      throwsStateError,
    );
    expect(await next(w1, DocumentSeries.receipt), 'R-W1-0002');
  });
}
