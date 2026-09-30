import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:powersync/powersync.dart';

const ctx = WriteContext(
  tenantId: '11111111-1111-4111-8111-111111111111',
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_audit_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test('writes who, where, what and when', () async {
    final at = DateTime.utc(2026, 9, 30, 10, 15);
    await db.writeTransaction(
      (tx) => AuditWriter.record(
        tx,
        ctx,
        table: 'parties',
        rowId: 'p1',
        action: AuditAction.softDelete,
        before: {'name': 'Ram Singh', 'deleted_at': null},
        after: {'name': 'Ram Singh', 'deleted_at': '2026-09-30'},
        at: at,
      ),
    );
    final row = await db.get('SELECT * FROM audit_log');
    expect(row['tenant_id'], ctx.tenantId);
    expect(row['table_name'], 'parties');
    expect(row['row_id'], 'p1');
    expect(row['action'], 'soft_delete');
    expect(row['user_id'], 'user-a');
    expect(row['device_id'], 'device-w1');
    expect(row['created_at'], at.toIso8601String());
    expect(jsonDecode(row['before']! as String), {
      'name': 'Ram Singh',
      'deleted_at': null,
    });
    // The server sets the role from the membership; the device never does.
    expect(row['role'], isNull);
  });

  test('rolls back with the write it belongs to', () async {
    await expectLater(
      db.writeTransaction((tx) async {
        await AuditWriter.record(
          tx,
          ctx,
          table: 'parties',
          rowId: 'p1',
          action: AuditAction.insert,
          after: const {'name': 'x'},
        );
        throw StateError('write failed');
      }),
      throwsStateError,
    );
    expect(await db.getAll('SELECT * FROM audit_log'), isEmpty);
    expect(await db.getAll('SELECT * FROM ps_crud'), isEmpty);
  });

  test('every action maps to the database check values', () {
    const allowed = {'insert', 'update', 'reverse', 'soft_delete', 'restore'};
    expect(
      AuditAction.values.length,
      allowed.length,
      reason: 'audit_log.action check in the migration',
    );
  });
}
