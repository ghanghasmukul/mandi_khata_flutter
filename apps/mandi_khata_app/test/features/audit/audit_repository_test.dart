import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/audit/data/audit_repository.dart';
import 'package:mandi_khata_app/features/audit/domain/audit_entry.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late AuditRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_audit_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = AuditRepository(db);

    await db.execute(
      'INSERT INTO app_users (id, full_name) '
      "VALUES ('u-owner', 'Naresh Gupta')",
    );
    await db.execute(
      "INSERT INTO app_users (id, full_name) VALUES ('u-munshi', 'Rajinder')",
    );
    await db.execute(
      'INSERT INTO devices (id, tenant_id, user_id, device_code, platform) '
      "VALUES ('d-w1', '$t1', 'u-owner', 'W1', 'windows')",
    );
    await db.execute(
      'INSERT INTO devices (id, tenant_id, user_id, device_code, platform) '
      "VALUES ('d-a1', '$t1', 'u-munshi', 'A1', 'android')",
    );
    await db.execute(
      'INSERT INTO parties (id, tenant_id, code, name) '
      "VALUES ('p-1', '$t1', 'F-1', 'Gurmeet Singh')",
    );
    await db.execute(
      'INSERT INTO payments (id, tenant_id, receipt_no) '
      "VALUES ('pay-1', '$t1', 'R-W1-0007')",
    );

    var n = 0;
    Future<void> log({
      required String tenant,
      required String table,
      required String row,
      required String action,
      required String user,
      required String at,
      String? device,
      String? role,
      String? before,
      String? after,
    }) => db.execute(
      'INSERT INTO audit_log (id, tenant_id, table_name, row_id, action, '
      'before, after, user_id, device_id, role, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'a${n++}',
        tenant,
        table,
        row,
        action,
        before,
        after,
        user,
        device,
        role,
        at,
      ],
    );

    await log(
      tenant: t1,
      table: 'parties',
      row: 'p-1',
      action: 'insert',
      user: 'u-munshi',
      device: 'd-a1',
      role: 'munshi',
      at: '2026-10-01T05:00:00.000Z',
      after: '{"name":"Gurmeet Singh"}',
    );
    await log(
      tenant: t1,
      table: 'payments',
      row: 'pay-1',
      action: 'reverse',
      user: 'u-owner',
      device: 'd-w1',
      role: 'owner',
      at: '2026-10-02T05:00:00.000Z',
      before: '{"status":"posted"}',
      after: '{"status":"reversed"}',
    );
    await log(
      tenant: t1,
      table: 'lots',
      row: 'l-1',
      action: 'update',
      user: 'u-owner',
      at: '2026-10-03T05:00:00.000Z',
      before: '{"gross":100000,"note":"a"}',
      after: '{"gross":120000,"note":"b"}',
    );
    await log(
      tenant: t1,
      table: 'lots',
      row: 'l-2',
      action: 'update',
      user: 'u-owner',
      at: '2026-10-03T06:00:00.000Z',
      before: '{"note":"a"}',
      after: '{"note":"b"}',
    );
    await log(
      tenant: t2,
      table: 'parties',
      row: 'p-x',
      action: 'insert',
      user: 'u-owner',
      at: '2026-10-03T07:00:00.000Z',
    );
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<List<AuditEntry>> read([AuditFilter f = const AuditFilter()]) =>
      repo.watch(t1, f).first;

  test('newest first, only this business, with names and devices', () async {
    final all = await read();
    expect(all, hasLength(4));
    expect(
      [for (final e in all) e.table],
      ['lots', 'lots', 'payments', 'parties'],
    );
    final party = all.last;
    expect(party.userName, 'Rajinder');
    expect(party.deviceCode, 'A1');
    expect(party.role, 'munshi');
    expect(party.subject, 'Gurmeet Singh');
    expect(all[2].subject, 'R-W1-0007');
  });

  test(
    'reversals and money edits are highlighted; a note edit is not',
    () async {
      final all = await read();
      final byRow = {for (final e in all) e.rowId: e};
      expect(byRow['pay-1']!.kind, AuditKind.reversal);
      expect(byRow['l-1']!.kind, AuditKind.moneyEdit);
      expect(byRow['l-1']!.changedKeys, ['gross', 'note']);
      expect(byRow['l-2']!.kind, AuditKind.normal);
      expect(byRow['p-1']!.kind, AuditKind.normal);
    },
  );

  test('filter by person', () async {
    final e = await read(const AuditFilter(userId: 'u-munshi'));
    expect([for (final x in e) x.rowId], ['p-1']);
  });

  test('filter by record type', () async {
    final e = await read(const AuditFilter(table: 'lots'));
    expect([for (final x in e) x.rowId], ['l-2', 'l-1']);
  });

  test('filter by local date range, inclusive', () async {
    final e = await read(
      AuditFilter(
        from: LedgerDate.fromDateTime(DateTime.parse('2026-10-02T12:00:00')),
        to: LedgerDate.fromDateTime(DateTime.parse('2026-10-02T12:00:00')),
      ),
    );
    expect([for (final x in e) x.rowId], ['pay-1']);
  });

  test('only money edits and reversals', () async {
    final e = await read(const AuditFilter(onlyHighlighted: true));
    expect([for (final x in e) x.rowId], ['l-1', 'pay-1']);
  });

  test('a limit pages the log', () async {
    final first = await repo.watch(t1, const AuditFilter(), limit: 2).first;
    expect(first, hasLength(2));
  });

  test('writers list for the person filter, this business only', () async {
    final writers = await repo.watchWriters(t1).first;
    expect({for (final w in writers) w.name}, {'Naresh Gupta', 'Rajinder'});
  });
}
