import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/db/schema_version.dart';
import 'package:powersync/powersync.dart';

/// Schema of each released layout: version -> fingerprint. Add a line when
/// you bump [localSchemaVersion]; never edit an old line.
const released = <int, String>{
  1: '97fe8f0c495accfcb30fac60e08bfc11d0674fb2de85bbd46b2cd8038be1dbdf',
};

String fingerprint(Schema schema) =>
    sha256.convert(utf8.encode(jsonEncode(schema.toJson()))).toString();

void main() {
  test('the schema fingerprint is pinned to localSchemaVersion', () {
    final actual = fingerprint(powerSyncSchema);
    expect(
      released[localSchemaVersion],
      actual,
      reason:
          'The local schema changed. Bump localSchemaVersion in '
          'core/db/schema_version.dart, add the new fingerprint to '
          '`released` here, extend the upgrade test with the layout you '
          'replace, and think about min_supported (docs/release.md).\n'
          'Fingerprint now: $actual',
    );
  });

  test('every released version is older than or equal to the current', () {
    expect(released.keys.every((v) => v <= localSchemaVersion), isTrue);
    expect(released.keys.reduce((a, b) => a > b ? a : b), localSchemaVersion);
  });

  group('upgrade path', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('mk_schema_test');
    });

    tearDown(() async {
      await dir.delete(recursive: true);
    });

    test(
      'a database written by the previous layout opens and keeps its data',
      () async {
        // The previous layout, simulated: today's schema without the Phase 6
        // table and without the newest column of an older table.
        final old = Schema([
          for (final t in syncedTables)
            if (t.name != 'party_documents') t.toPowerSync(),
          syncErrorsTable,
          billUploadsTable,
          heldBillsTable,
        ]);
        final path = '${dir.path}/upgrade.db';

        final before = PowerSyncDatabase(schema: old, path: path);
        await before.initialize();
        await before.execute(
          'INSERT INTO parties (id, tenant_id, code, name) '
          "VALUES ('p1', 't1', 'F-1', 'Gurdev')",
        );
        await before.execute(
          'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, '
          'side, amount_paise, ref_type) '
          "VALUES ('e1', 't1', 'p1', '2027-04-01', 'jama', 155580, 'opening')",
        );
        await before.close();

        final after = PowerSyncDatabase(schema: powerSyncSchema, path: path);
        await after.initialize();
        addTearDown(after.close);

        expect(
          (await after.get("SELECT name FROM parties WHERE id = 'p1'"))['name'],
          'Gurdev',
        );
        expect(
          (await after.get(
            'SELECT amount_paise FROM ledger_entries',
          ))['amount_paise'],
          155580,
        );
        // The new table exists and works on the upgraded file.
        await after.execute(
          'INSERT INTO party_documents (id, tenant_id, party_id, doc_type, '
          "file_path, content_type, size_bytes) VALUES ('d1', 't1', 'p1', "
          "'pan', 't1/p1/d1/a.jpg', 'image/jpeg', 10)",
        );
        expect(
          (await after.get('SELECT COUNT(*) AS n FROM party_documents'))['n'],
          1,
        );
      },
    );
  });
}
