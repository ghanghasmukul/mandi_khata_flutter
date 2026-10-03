import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/opening_balances/data/opening_balances_repository.dart';
import 'package:mandi_khata_app/features/parties/data/parties_repository.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const otherTenant = WriteContext(
  tenantId: t2,
  userId: 'user-b',
  deviceId: 'device-b',
  deviceCode: 'W1',
);

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

final now = DateTime(2026, 10, 3, 11);
final asOn = LedgerDate(2026, 4, 1);

// Udhaar: Ramesh 15,000 + Gurmeet 2,500.50. Jama: Sita 4,000.
const csv =
    'Name,Village,Mobile,Amount,Type\n'
    'Ramesh Kumar,Rampura,98140 22110,"15,000",Dr\n'
    'Sita Devi,Rampura,,4000,Cr\n'
    'Gurmeet Singh,Nabha,,"2,500.50",Dr\n'
    'Balbir,,,,\n';

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late OpeningBalancesRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_opening_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = OpeningBalancesRepository(db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<OpeningPreview> preview(
    String text, {
    String tenant = t1,
    Side? defaultSide,
  }) async => OpeningBalanceImport.preview(
    DelimitedText.parse(text),
    existing: await repo.existingParties(tenant),
    defaultSide: defaultSide,
  );

  Future<OpeningImportResult> run(
    OpeningPreview p, {
    WriteContext c = ctx,
    bool Function(Permission) can = owner,
    LedgerDate? on,
  }) => repo.import(
    c,
    p,
    asOn: on ?? asOn,
    can: can,
    fileName: 'f.csv',
    now: now,
  );

  Future<Map<String, int>> balances(String tenant) async {
    final m = await LedgerRepository(db).watchBalances(tenant).first;
    return {for (final e in m.entries) e.key: e.value.paise};
  }

  Future<int> count(String table) async =>
      (await db.get('SELECT count(*) AS n FROM $table'))['n']! as int;

  group('import', () {
    test('creates parties and posts one opening entry each', () async {
      final result = await run(await preview(csv));
      final done = result as OpeningImported;
      expect(done.newParties, 4);
      expect(done.entries, 3);
      expect(done.totalUdhaar, const Money(1750050));
      expect(done.totalJama, const Money(400000));

      final parties = await PartiesRepository(db).watchAll(t1).first;
      expect(parties.map((p) => p.name), [
        'Balbir',
        'Gurmeet Singh',
        'Ramesh Kumar',
        'Sita Devi',
      ]);
      expect(parties.map((p) => p.code), everyElement(startsWith('P-W1-')));
      expect(parties.first.roles, {PartyRole.farmer});

      final byName = {for (final p in parties) p.name: p.id};
      final bal = await balances(t1);
      expect(bal[byName['Ramesh Kumar']], -1500000);
      expect(bal[byName['Sita Devi']], 400000);
      expect(bal[byName['Gurmeet Singh']], -250050);
      expect(bal.containsKey(byName['Balbir']), isFalse);
      // Σ jama − Σ udhaar of the whole book equals the preview's net.
      expect(bal.values.fold<int>(0, (a, b) => a + b), -1350050);

      final entries = await db.getAll('SELECT * FROM ledger_entries');
      expect(entries, hasLength(3));
      expect(entries.map((e) => e['ref_type']).toSet(), {'opening_balance'});
      expect(entries.map((e) => e['entry_date']).toSet(), {'2026-04-01'});
      expect(entries.map((e) => e['tenant_id']).toSet(), {t1});
      expect(entries.map((e) => e['ref_id']).toSet(), {done.batchId});
    });

    test('every write is audited, with a batch summary', () async {
      final done = await run(await preview(csv)) as OpeningImported;
      final log = await db.getAll('SELECT * FROM audit_log');
      Iterable<Object?> tables() => log.map((e) => e['table_name']);
      expect(tables().where((t) => t == 'parties'), hasLength(4));
      expect(tables().where((t) => t == 'party_roles'), hasLength(4));
      expect(tables().where((t) => t == 'ledger_entries'), hasLength(3));
      final batch = log.singleWhere(
        (e) => e['table_name'] == 'opening_balance_imports',
      );
      expect(batch['row_id'], done.batchId);
      final after = jsonDecode(batch['after']! as String) as Map;
      expect(after['entries'], 3);
      expect(after['udhaar_paise'], 1750050);
      expect(after['jama_paise'], 400000);
      expect(log.every((e) => e['tenant_id'] == t1), isTrue);
      expect(log.every((e) => e['device_id'] == 'device-w1'), isTrue);
    });

    test('everything is ONE upload transaction (all or nothing)', () async {
      await run(await preview(csv));
      final txIds = {
        for (final r in await db.getAll('SELECT tx_id FROM ps_crud'))
          r['tx_id'],
      };
      expect(txIds, hasLength(1));
    });

    test('a row matching an existing party only gets the entry', () async {
      final parties = PartiesRepository(db);
      final id =
          (await parties.create(
                    ctx,
                    const PartyInput(
                      code: 'F-7',
                      name: 'Ramesh Kumar',
                      roles: {PartyRole.farmer},
                      village: 'Rampura',
                    ),
                    can: owner,
                  )
                  as PartySaved)
              .id;
      final p = await preview(csv);
      expect(p.rows.first.matchedPartyId, id);
      final done = await run(p) as OpeningImported;
      expect(done.newParties, 3);
      expect(done.entries, 3);
      expect((await balances(t1))[id], -1500000);
      expect(await count('parties'), 4);
    });

    test('the same opening balance is never posted twice', () async {
      expect(await run(await preview(csv)), isA<OpeningImported>());
      final entries = await count('ledger_entries');
      final crud = await count('ps_crud');

      // Uploading the same file again: every row is refused in the preview…
      final again = await preview(csv);
      expect(again.canImport, isFalse);
      expect(
        again.rows
            .where((r) => r.postsEntry || r.hasError)
            .expand((r) => r.errors),
        everyElement(OpeningRowError.alreadyHasOpening),
      );
      // …and forcing the old preview through is refused by the batch id.
      final stale = await preview(csv, tenant: t2);
      expect(await run(stale), isA<OpeningAlreadyImported>());
      expect(await count('ledger_entries'), entries);
      expect(await count('ps_crud'), crud);
    });

    test(
      'a party that got an opening balance since the preview: stale',
      () async {
        final p = await preview(csv);
        // Another device's import of Ramesh arrives first.
        final first = await preview(
          'Name,Village,Mobile,Amount,Type\n'
          'Ramesh Kumar,Rampura,98140 22110,1,Dr\n',
        );
        await run(first, on: LedgerDate(2026, 4, 2));
        final entries = await count('ledger_entries');
        final parties = await count('parties');

        // p was read when Ramesh did not exist: it would create him again,
        // but his deterministic party already has an opening balance.
        final result = await run(p);
        expect(result, isA<OpeningStale>());
        expect(await count('ledger_entries'), entries);
        expect(await count('parties'), parties);
      },
    );

    test('needs entries.reverse (and parties.manage to add parties)', () async {
      final p = await preview(csv);
      expect(
        await run(p, can: munshi),
        isA<OpeningNotPermitted>().having(
          (r) => r.permission,
          'permission',
          Permission.entriesReverse,
        ),
      );
      final onlyEntries = await run(
        p,
        can: (perm) => perm == Permission.entriesReverse,
      );
      expect(
        (onlyEntries as OpeningNotPermitted).permission,
        Permission.partiesManage,
      );
      expect(await count('ledger_entries'), 0);
      expect(await count('parties'), 0);
      expect(await count('ps_crud'), 0);
    });

    test('an opening date in the future is refused', () async {
      expect(
        await run(await preview(csv), on: LedgerDate(2026, 10, 4)),
        isA<OpeningBadDate>(),
      );
      expect(await count('ledger_entries'), 0);
    });

    test(
      'only valid rows are posted when the person skips the bad ones',
      () async {
        final p = await preview(
          'Name,Amount,Type\nRamesh,100,Dr\n,5,Dr\n'
          'Sita,abc,Cr\nGurmeet,50,Cr\n',
        );
        expect(p.invalid, hasLength(2));
        final done = await run(p) as OpeningImported;
        expect(done.entries, 2);
        expect(await count('parties'), 2);
      },
    );

    test('nothing to do when all rows are already in the books', () async {
      await run(await preview(csv));
      final onlyNames = await preview('Name,Amount\nBalbir,\n');
      expect(onlyNames.valid.single.createsParty, isFalse);
      expect(await run(onlyNames), isA<OpeningNothingToImport>());
    });
  });

  test('a 2,000 row file imports in one transaction, quickly', () async {
    final text = StringBuffer('Name,Village,Amount,Type\n');
    for (var i = 0; i < 2000; i++) {
      text.writeln('Party $i,Village ${i % 40},${i + 1}.25,Dr');
    }
    final p = await preview(text.toString());
    expect(p.invalid, isEmpty);
    final sw = Stopwatch()..start();
    final done = await run(p) as OpeningImported;
    sw.stop();
    expect(done.entries, 2000);
    expect(await count('ledger_entries'), 2000);
    expect({
      for (final r in await db.getAll('SELECT tx_id FROM ps_crud')) r['tx_id'],
    }, hasLength(1));
    expect(sw.elapsed, lessThan(const Duration(seconds: 20)));
  });

  group('two devices, same file', () {
    test(
      'ids are deterministic so a double import lands on the same rows',
      () async {
        final p = await preview(csv);
        await run(p);
        final ids1 = {
          for (final r in await db.getAll('SELECT id FROM ledger_entries'))
            r['id']! as String,
        };
        final partyIds1 = {
          for (final r in await db.getAll('SELECT id FROM parties'))
            r['id']! as String,
        };

        final dir2 = await Directory.systemTemp.createTemp('mk_opening_test2');
        final db2 = PowerSyncDatabase(
          schema: powerSyncSchema,
          path: '${dir2.path}/t.db',
        );
        await db2.initialize();
        addTearDown(() async {
          await db2.close();
          await dir2.delete(recursive: true);
        });
        const ctx2 = WriteContext(
          tenantId: t1,
          userId: 'user-b',
          deviceId: 'device-a3',
          deviceCode: 'A3',
        );
        final repo2 = OpeningBalancesRepository(db2);
        final p2 = OpeningBalanceImport.preview(
          DelimitedText.parse(csv),
          existing: await repo2.existingParties(t1),
        );
        await repo2.import(ctx2, p2, asOn: asOn, can: owner, now: now);

        expect({
          for (final r in await db2.getAll('SELECT id FROM ledger_entries'))
            r['id']! as String,
        }, ids1);
        expect({
          for (final r in await db2.getAll('SELECT id FROM parties'))
            r['id']! as String,
        }, partyIds1);
        expect(
          OpeningBalancesRepository.batchId(t1, p, asOn),
          OpeningBalancesRepository.batchId(t1, p2, asOn),
        );
      },
    );
  });

  group('tenant isolation', () {
    test('another business never matches, blocks or sees the import', () async {
      await run(await preview(csv));
      // Business 2 has no parties yet: the same names are all new there.
      final other = await preview(csv, tenant: t2);
      expect(other.rows.every((r) => r.matchedPartyId == null), isTrue);
      expect(other.invalid, isEmpty);
      expect(await repo.existingParties(t2), isEmpty);
      expect(await repo.batchImported(t2, (await _batch(db))!), isFalse);

      await run(other, c: otherTenant);
      expect(await balances(t1), hasLength(3));
      expect(await balances(t2), hasLength(3));
      final t1Entries = await db.getAll(
        'SELECT * FROM ledger_entries WHERE tenant_id = ?',
        [t1],
      );
      expect(t1Entries, hasLength(3));
    });
  });

  test(
    'existingParties reports opening balances and ignores deleted ones',
    () async {
      await run(await preview(csv));
      final parties = PartiesRepository(db);
      final all = await repo.existingParties(t1);
      expect(all, hasLength(4));
      expect(
        {for (final p in all) p.name: p.hasOpeningBalance},
        {
          'Ramesh Kumar': true,
          'Sita Devi': true,
          'Gurmeet Singh': true,
          'Balbir': false,
        },
      );
      final balbir = all.singleWhere((p) => p.name == 'Balbir');
      await parties.softDelete(ctx, balbir.id, can: owner);
      expect(await repo.existingParties(t1), hasLength(3));
    },
  );
}

Future<String?> _batch(PowerSyncDatabase db) async =>
    (await db.getOptional(
          'SELECT ref_id FROM ledger_entries LIMIT 1',
        ))?['ref_id']
        as String?;
