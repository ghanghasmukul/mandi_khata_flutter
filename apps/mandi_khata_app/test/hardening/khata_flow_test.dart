import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/sync/supabase_connector.dart';
import 'package:mandi_khata_app/core/sync/upload_policy.dart';
import 'package:powersync/powersync.dart';

import '../../integration_test/support/khata_flow.dart';

const tenant = '11111111-1111-4111-8111-111111111111';
const ctx = WriteContext(
  tenantId: tenant,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);

/// A stand-in server: records what it is sent, or refuses everything while
/// "offline".
class RecordingServer implements CrudApplier {
  bool online = false;
  final received = <CrudEntry>[];

  @override
  Future<void> applyTransaction(List<CrudEntry> entries) async {
    if (!online) throw StateError('no network');
    received.addAll(entries);
  }
}

void main() {
  late Directory dir;
  late PowerSyncDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_flow_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test('farmer -> arrival -> post -> payment -> statement, offline then '
      'online', () async {
    await seedBusiness(db, tenant);
    final result = await runKhataFlow(
      db,
      ctx,
      now: DateTime.utc(2026, 4, 10, 6),
    );
    expect(result.lotNo, 'L-W1-0001');
    expect(result.receiptNo, 'V-W1-0001');
    expect(result.closing, const Money(1483276));

    // Offline: everything is queued locally, nothing has been sent.
    final server = RecordingServer();
    final backoff = UploadBackoff();
    final queued = await db.getAll('SELECT * FROM ps_crud');
    expect(queued, isNotEmpty);
    await expectLater(
      uploadPending(db, server, backoff, wait: (_) async {}),
      throwsStateError,
      reason: 'offline upload fails and keeps the queue',
    );
    expect(await db.getAll('SELECT * FROM ps_crud'), hasLength(queued.length));
    expect(server.received, isEmpty);

    // Back online: the queue drains in order, one transaction at a time.
    server.online = true;
    while (await db.getNextCrudTransaction() != null) {
      await uploadPending(db, server, backoff, wait: (_) async {});
    }
    expect(await db.getAll('SELECT * FROM ps_crud'), isEmpty);

    final tables = server.received.map((e) => e.table).toSet();
    expect(
      tables,
      containsAll([
        'parties',
        'party_roles',
        'lots',
        'ledger_entries',
        'payments',
        'cash_bank_entries',
        'audit_log',
        'number_series',
      ]),
    );
    // Every row that reached the server carries this business's tenant.
    for (final e in server.received) {
      final data = e.opData;
      if (data != null && data.containsKey('tenant_id')) {
        expect(data['tenant_id'], tenant, reason: '${e.table} ${e.id}');
      }
    }
    // The ledger rows sent add up to the balance shown locally.
    final jama = server.received
        .where(
          (e) => e.table == 'ledger_entries' && e.opData!['side'] == 'jama',
        )
        .fold<int>(0, (s, e) => s + (e.opData!['amount_paise']! as int));
    final udhaar = server.received
        .where(
          (e) => e.table == 'ledger_entries' && e.opData!['side'] == 'udhaar',
        )
        .fold<int>(0, (s, e) => s + (e.opData!['amount_paise']! as int));
    expect(Money(jama - udhaar), result.closing);
  });
}
