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

  group('a rejected transaction is one batch', () {
    Future<void> rejectBatch(
      List<(String table, String rowId, String op, Map<String, Object?>)> rows,
    ) async {
      for (final (i, (table, rowId, op, data)) in rows.indexed) {
        await db.execute(
          'INSERT INTO sync_errors (id, table_name, row_id, op, op_data, '
          'error_code, message, created_at, batch_id, batch_seq) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            'b$i',
            table,
            rowId,
            op,
            jsonEncode(data),
            '42501',
            'row-level security',
            '2026-09-30T10:00:00Z',
            'batch-1',
            i,
          ],
        );
      }
    }

    final party = (
      'parties',
      'p1',
      'PUT',
      <String, Object?>{'tenant_id': tenant, 'code': 'F-1', 'name': 'Ram'},
    );
    final partyEdit = (
      'parties',
      'p1',
      'PATCH',
      <String, Object?>{'village': 'Mansa'},
    );
    final entry = (
      'ledger_entries',
      'l1',
      'PUT',
      <String, Object?>{
        'tenant_id': tenant,
        'party_id': 'p1',
        'entry_date': '2026-04-01',
        'side': 'udhaar',
        'amount_paise': 125000,
        'ref_type': 'opening_balance',
        'created_at': '2026-09-30T10:00:00Z',
      },
    );

    test(
      'retry re-queues every change, in order, as one transaction',
      () async {
        await rejectBatch([party, partyEdit, entry]);

        expect(await actions.retry('b2'), RetryResult.requeued);

        expect(await db.getAll('SELECT * FROM sync_errors'), isEmpty);
        final row = await db.get('SELECT * FROM parties WHERE id = ?', ['p1']);
        expect((row['name'], row['village']), ('Ram', 'Mansa'));
        final crud = await db.getAll('SELECT tx_id, data FROM ps_crud');
        expect(
          crud.map((c) => (jsonDecode(c['data']! as String) as Map)['type']),
          ['parties', 'parties', 'ledger_entries'],
        );
        expect(crud.map((c) => c['tx_id']).toSet(), hasLength(1));
      },
    );

    test('discard forgets the whole batch', () async {
      await rejectBatch([party, entry]);
      await actions.discard('b0');
      expect(await db.getAll('SELECT * FROM sync_errors'), isEmpty);
      expect(await queued(), 0);
    });

    test('one change that cannot be retried keeps the whole batch', () async {
      await rejectBatch([
        party,
        ('parties', 'p9', 'DELETE', <String, Object?>{'x': 1}),
      ]);
      expect(await actions.retry('b0'), RetryResult.notRetryable);
      expect(await db.getAll('SELECT * FROM sync_errors'), hasLength(2));
      expect(await db.getAll('SELECT * FROM parties'), isEmpty);
      expect(await queued(), 0);
    });

    test('an append-only row still on this device waits for a sync', () async {
      await db.execute(
        'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, '
        'side, amount_paise, ref_type, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          'l1',
          tenant,
          'p1',
          '2026-04-01',
          'udhaar',
          125000,
          'opening_balance',
          '2026-09-30T10:00:00Z',
        ],
      );
      await db.execute('DELETE FROM ps_crud');
      await rejectBatch([entry]);

      expect(await actions.retry('b0'), RetryResult.notRetryable);
      expect(await queued(), 0);
    });
  });
}
