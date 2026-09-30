import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/sync/supabase_connector.dart';
import 'package:mandi_khata_app/core/sync/upload_policy.dart';
import 'package:powersync/powersync.dart';

/// Records what would be sent, a whole transaction at a time; fails a
/// transaction according to [fail] (and then applies none of it, like the
/// server).
class FakeApplier implements CrudApplier {
  FakeApplier([this.fail]);

  final Exception? Function(List<CrudEntry> entries)? fail;
  final transactions = <List<CrudEntry>>[];

  List<CrudEntry> get applied => [for (final t in transactions) ...t];

  @override
  Future<void> applyTransaction(List<CrudEntry> entries) async {
    final error = fail?.call(entries);
    if (error != null) throw error;
    transactions.add(entries);
  }
}

const tenant = '11111111-1111-4111-8111-111111111111';

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  final waits = <Duration>[];
  Future<void> recordWait(Duration d) async => waits.add(d);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_sync_test');
    db = PowerSyncDatabase(
      schema: powerSyncSchema,
      path: '${dir.path}/test.db',
    );
    await db.initialize();
    waits.clear();
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> addPartyOffline(String id, String code) =>
      db.writeTransaction((tx) async {
        await tx.execute(
          'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
          [id, tenant, code, 'Party $code'],
        );
        await tx.execute(
          'INSERT INTO audit_log (id, tenant_id, table_name, row_id, action, '
          'user_id, after) VALUES (?, ?, ?, ?, ?, ?, ?)',
          ['a-$id', tenant, 'parties', id, 'insert', 'u1', '{"code":"$code"}'],
        );
      });

  Future<int> queued() async =>
      (await db.get('SELECT count(*) AS n FROM ps_crud'))['n'] as int;
  Future<int> rejected() async =>
      (await db.get('SELECT count(*) AS n FROM sync_errors'))['n'] as int;

  test(
    'offline writes queue up as one transaction and upload in order',
    () async {
      await addPartyOffline('p1', 'F-1');
      expect(await queued(), 2);

      final applier = FakeApplier();
      await uploadPending(db, applier, UploadBackoff(), wait: recordWait);

      expect(applier.applied.map((e) => e.table), ['parties', 'audit_log']);
      expect(applier.applied.first.op, UpdateType.put);
      expect(applier.applied.first.opData?['tenant_id'], tenant);
      expect(await queued(), 0);
      expect(await rejected(), 0);
      expect(waits, isEmpty);
    },
  );

  test(
    'a rejected transaction goes to sync_errors whole and unblocks the queue',
    () async {
      await addPartyOffline('p1', 'F-1');
      await addPartyOffline('p2', 'F-2');

      final applier = FakeApplier(
        (entries) => entries.first.id == 'p1'
            ? const UploadException(
                'duplicate key',
                code: '23505',
                failedIndex: 0,
              )
            : null,
      );
      await uploadPending(db, applier, UploadBackoff(), wait: recordWait);
      await uploadPending(db, applier, UploadBackoff(), wait: recordWait);

      // p1's audit row is NOT uploaded without its party.
      expect(applier.applied.map((e) => e.id), ['p2', 'a-p2']);
      expect(await queued(), 0);
      expect(waits, isEmpty);

      final errors = await db.getAll(
        'SELECT * FROM sync_errors ORDER BY batch_seq',
      );
      expect(errors.map((e) => e['row_id']), ['p1', 'a-p1']);
      expect(errors.map((e) => e['batch_seq']), [0, 1]);
      expect(errors.map((e) => e['batch_id']).toSet(), hasLength(1));
      expect(errors.map((e) => e['error_code']).toSet(), {'23505'});
      expect(errors[0]['message'], 'duplicate key');
      expect(
        errors[1]['message'],
        'Not saved: parties/p1 in the same save was rejected (duplicate key)',
      );
    },
  );

  test(
    'without a failing position every change keeps the server message',
    () async {
      await addPartyOffline('p1', 'F-1');
      final applier = FakeApplier(
        (_) => const UploadException('RLS', code: '42501'),
      );
      await uploadPending(db, applier, UploadBackoff(), wait: recordWait);
      final messages = await db.getAll('SELECT message FROM sync_errors');
      expect(messages.map((m) => m['message']), ['RLS', 'RLS']);
    },
  );

  test('a network failure keeps the queue and backs off', () async {
    await addPartyOffline('p1', 'F-1');
    final backoff = UploadBackoff();
    final offline = FakeApplier((_) => const SocketException('no network'));

    for (var i = 0; i < 3; i++) {
      await expectLater(
        uploadPending(db, offline, backoff, wait: recordWait),
        throwsA(isA<SocketException>()),
      );
    }
    expect(waits, const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ]);
    expect(await queued(), 2);
    expect(await rejected(), 0);

    // Back online: everything uploads and the backoff resets.
    await uploadPending(db, FakeApplier(), backoff, wait: recordWait);
    expect(await queued(), 0);
    expect(backoff.failures, 0);
  });

  test('a transient server error (no code) is retried, not dropped', () async {
    await addPartyOffline('p1', 'F-1');
    final flaky = FakeApplier((_) => const UploadException('timeout'));
    await expectLater(
      uploadPending(db, flaky, UploadBackoff(), wait: recordWait),
      throwsA(isA<UploadException>()),
    );
    expect(await queued(), 2);
    expect(await rejected(), 0);
  });

  test('sync_errors is local only: recording one queues nothing', () async {
    await addPartyOffline('p1', 'F-1');
    final applier = FakeApplier(
      (_) => const UploadException('check violation', code: '23514'),
    );
    await uploadPending(db, applier, UploadBackoff(), wait: recordWait);
    expect(await rejected(), 2);
    expect(await queued(), 0);
  });
}
