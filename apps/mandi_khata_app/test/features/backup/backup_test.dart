import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/backup/data/backup_codec.dart';
import 'package:mandi_khata_app/features/backup/data/backup_runner.dart';
import 'package:mandi_khata_app/features/backup/data/backup_service.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'u',
  deviceId: 'd',
  deviceCode: 'W1',
);
const quick = 1000; // PBKDF2 iterations: fast in tests

Future<PowerSyncDatabase> open(Directory dir, String name) async {
  final db = PowerSyncDatabase(
    schema: powerSyncSchema,
    path: '${dir.path}/$name.db',
  );
  await db.initialize();
  return db;
}

Future<void> seed(PowerSyncDatabase db) async {
  for (final (id, tenant, name) in [
    ('p1', t1, 'Gurdev'),
    ('p2', t1, 'Harbans'),
    ('p3', t2, 'Other business'),
  ]) {
    await db.execute(
      'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
      [id, tenant, 'C-$id', name],
    );
  }
  await db.execute(
    'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, '
    'side, amount_paise, ref_type) VALUES (?, ?, ?, ?, ?, ?, ?)',
    ['e1', t1, 'p1', '2027-04-01', 'jama', 155580, 'opening'],
  );
}

void main() {
  late Directory dir;
  late PowerSyncDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_backup_test');
    db = await open(dir, 'a');
    await seed(db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  group('codec', () {
    test('round trips; wrong passphrase and damage are told apart', () async {
      final data = {
        'a': 1,
        'b': ['x', null],
      };
      final file = await BackupCodec.encrypt(
        data,
        'secret1',
        iterations: quick,
      );
      expect(await BackupCodec.decrypt(file, 'secret1'), data);
      await expectLater(
        BackupCodec.decrypt(file, 'secret2'),
        throwsA(isA<BackupWrongPassphrase>()),
      );
      final damaged = Uint8List.fromList(file)..[file.length - 20] ^= 1;
      await expectLater(
        BackupCodec.decrypt(damaged, 'secret1'),
        throwsA(isA<BackupWrongPassphrase>()),
        reason: 'GCM cannot tell a flipped bit from a wrong key',
      );
      await expectLater(
        BackupCodec.decrypt(Uint8List(5), 'x'),
        throwsA(isA<BackupCorrupt>()),
      );
    });

    test('the file does not contain the plain text', () async {
      final file = await BackupCodec.encrypt(
        {'name': 'Gurdev Singh'},
        'secret1',
        iterations: quick,
      );
      expect(String.fromCharCodes(file).contains('Gurdev'), isFalse);
    });
  });

  test('snapshot holds only this business', () async {
    final s = await BackupService(db).snapshot(t1);
    final counts = BackupService.rowCounts(s);
    expect(counts['parties'], 2);
    expect(counts['ledger_entries'], 1);
    expect(counts.containsKey('tenant_members'), isFalse);
  });

  test('backup -> fresh install -> restore gives the same data', () async {
    final service = BackupService(db);
    final file = await BackupCodec.encrypt(
      await service.snapshot(t1, tenantName: 'Test'),
      'pass12',
      iterations: quick,
    );

    final fresh = await open(dir, 'b');
    addTearDown(fresh.close);
    final target = BackupService(fresh);
    final snap = await BackupCodec.decrypt(file, 'pass12');
    final n = await target.restore(ctx, snap);
    expect(n, 3);
    expect((await fresh.get('SELECT COUNT(*) AS n FROM parties'))['n'], 2);
    final e = await fresh.get('SELECT * FROM ledger_entries');
    expect(e['amount_paise'], 155580);
    expect(
      (await fresh.get(
        'SELECT COUNT(*) AS n FROM audit_log '
        "WHERE table_name = 'backup_restore'",
      ))['n'],
      1,
    );
    // The second restore is refused: the install is no longer empty.
    await expectLater(
      target.restore(ctx, snap),
      throwsA(
        isA<RestoreRefused>().having(
          (e) => e.reason,
          'reason',
          RestoreRefusal.notEmpty,
        ),
      ),
    );
  });

  test('another business, or a newer format, is refused', () async {
    final s = await BackupService(db).snapshot(t1);
    final fresh = await open(dir, 'c');
    addTearDown(fresh.close);
    final target = BackupService(fresh);
    await expectLater(
      target.restore(
        const WriteContext(
          tenantId: t2,
          userId: 'u',
          deviceId: 'd',
          deviceCode: 'W1',
        ),
        s,
      ),
      throwsA(isA<RestoreRefused>()),
    );
    await expectLater(
      target.restore(ctx, {...s, 'format': 99}),
      throwsA(isA<RestoreRefused>()),
    );
  });

  test(
    'export zip has one xlsx per non-empty table, never other tenants',
    () async {
      final zip = await BackupService(db).exportZip(
        t1,
        tenantName: 'Test',
        statementsPdf: Uint8List.fromList([1, 2, 3]),
      );
      final names = ZipDecoder()
          .decodeBytes(zip)
          .files
          .map((f) => f.name)
          .toSet();
      expect(
        names,
        containsAll([
          'xlsx/parties.xlsx',
          'xlsx/ledger_entries.xlsx',
          'README.txt',
          'statements.pdf',
        ]),
      );
      expect(names.contains('xlsx/crops.xlsx'), isFalse);
    },
  );

  group('runner', () {
    test('writes an encrypted file and keeps only the newest 14', () async {
      final out = Directory('${dir.path}/usb')..createSync();
      final runner = BackupRunner(BackupService(db));
      String? last;
      for (var i = 0; i < 16; i++) {
        last = await runner.run(
          tenantId: t1,
          tenantName: 'Sandhu & Sons',
          folder: out.path,
          passphrase: 'pass12',
          now: DateTime.utc(2027, 4, 1 + i, 6),
          iterations: quick,
        );
      }
      final files = out.listSync().map((e) => e.path).toList()..sort();
      expect(files, hasLength(14));
      expect(last, endsWith('MandiKhata-Sandhu_Sons-20270416-0600.mkbak'));
      expect(files.first, contains('20270403'));
      expect(files.any((f) => f.endsWith('.part')), isFalse);
      final snap = await BackupCodec.decrypt(
        File(last!).readAsBytesSync(),
        'pass12',
      );
      expect(BackupService.rowCounts(snap)['parties'], 2);
    });

    test('due after 24 h or when never run', () {
      final now = DateTime.utc(2027, 4, 2, 6);
      expect(BackupRunner.isDue(null, now), isTrue);
      expect(BackupRunner.isDue(DateTime.utc(2027, 4, 1, 7), now), isFalse);
      expect(BackupRunner.isDue(DateTime.utc(2027, 4, 1, 6), now), isTrue);
    });
  });
}
