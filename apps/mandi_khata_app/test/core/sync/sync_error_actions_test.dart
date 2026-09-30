import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/sync/sync_error_actions.dart';
import 'package:powersync/powersync.dart';

const tenant = '11111111-1111-4111-8111-111111111111';

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late SyncErrorActions actions;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_sync_err_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    actions = SyncErrorActions(db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> reject(
    String id,
    String table,
    String rowId,
    String op,
    Map<String, Object?>? data,
  ) => db.execute(
    'INSERT INTO sync_errors (id, table_name, row_id, op, op_data, '
    'error_code, message, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [
      id,
      table,
      rowId,
      op,
      if (data == null) null else jsonEncode(data),
      '42501',
      'row-level security',
      '2026-09-30T10:00:00Z',
    ],
  );

  Future<int> queued() async =>
      (await db.get('SELECT count(*) AS n FROM ps_crud'))['n']! as int;

  test('discard forgets the error and uploads nothing', () async {
    await reject('e1', 'parties', 'p1', 'PUT', {'name': 'x'});
    await actions.discard('e1');
    expect(await db.getAll('SELECT * FROM sync_errors'), isEmpty);
    expect(await queued(), 0);
  });

  test(
    'retry of a rejected insert puts the row back and re-queues it',
    () async {
      await reject('e1', 'parties', 'p1', 'PUT', {
        'tenant_id': tenant,
        'code': 'F-001',
        'name': 'Ram Singh',
        'not_a_column': 'ignored',
      });
      expect(await actions.retry('e1'), RetryResult.requeued);

      final row = await db.get('SELECT * FROM parties WHERE id = ?', ['p1']);
      expect(row['name'], 'Ram Singh');
      expect(await db.getAll('SELECT * FROM sync_errors'), isEmpty);
      expect(await queued(), 1);
    },
  );

  test('retry of a rejected update re-applies it to the current row', () async {
    await db.execute(
      'INSERT INTO parties (id, tenant_id, code, name, village) '
      'VALUES (?, ?, ?, ?, ?)',
      ['p1', tenant, 'F-001', 'Ram Singh', 'Rampura'],
    );
    await db.execute('DELETE FROM ps_crud');
    await reject('e1', 'parties', 'p1', 'PATCH', {'village': 'Mansa'});

    expect(await actions.retry('e1'), RetryResult.requeued);
    final row = await db.get('SELECT * FROM parties WHERE id = ?', ['p1']);
    expect((row['name'], row['village']), ('Ram Singh', 'Mansa'));
    expect(await queued(), 1);
  });

  test('an update whose row is gone cannot be retried', () async {
    await reject('e1', 'parties', 'p1', 'PATCH', {'village': 'Mansa'});
    expect(await actions.retry('e1'), RetryResult.notRetryable);
    expect(await db.getAll('SELECT * FROM sync_errors'), hasLength(1));
  });

  test('deletes and unknown tables cannot be retried', () async {
    await reject('e1', 'parties', 'p1', 'DELETE', null);
    await reject('e2', 'ps_crud', 'x', 'PUT', {'data': 'x'});
    expect(await actions.retry('e1'), RetryResult.notRetryable);
    expect(await actions.retry('e2'), RetryResult.notRetryable);
    expect(await actions.retry('missing'), RetryResult.notRetryable);
    expect(await queued(), 0);
  });
}
