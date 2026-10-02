import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/day_book.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late LedgerRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_day_book_perf');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = LedgerRepository(db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test('100k entries: day book pages and totals stay fast', () async {
    const parties = 2000;
    const entries = 100000;
    // Bulk-load like a first sync would (no audit needed for the timing).
    await db.writeTransaction((tx) async {
      await tx.executeBatch(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [
          for (var i = 0; i < parties; i++) ['p$i', t1, 'F-$i', 'Farmer $i'],
        ],
      );
      final start = DateTime.utc(2024, 4);
      await tx.executeBatch(
        'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, '
        'side, amount_paise, ref_type, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          for (var i = 0; i < entries; i++)
            () {
              final at = start.add(Duration(minutes: i * 10));
              return [
                'e${i.toString().padLeft(6, '0')}',
                t1,
                'p${i % parties}',
                LedgerDate.fromDateTime(at).toString(),
                if (i.isEven) 'jama' else 'udhaar',
                100 + i,
                if (i % 3 == 0) 'arrival' else 'payment',
                at.toIso8601String(),
              ];
            }(),
        ],
      );
    });

    Future<Duration> time(Future<void> Function() run) async {
      final sw = Stopwatch()..start();
      await run();
      return sw.elapsed;
    }

    late List<DayBookRow> top;
    late DayBookSummary summary;
    final first = await time(() async {
      top = await repo
          .watchDayBookPage(t1, const LedgerFilter(), offset: 0, limit: 100)
          .first;
    });
    final deep = await time(() async {
      await repo
          .watchDayBookPage(
            t1,
            const LedgerFilter(),
            offset: entries - 100,
            limit: 100,
          )
          .first;
    });
    final totals = await time(() async {
      summary = await repo.watchDayBookSummary(t1, const LedgerFilter()).first;
    });
    final party = await time(() async {
      await repo
          .watchDayBookPage(
            t1,
            const LedgerFilter(partyId: 'p7', refType: RefType.payment),
            offset: 0,
            limit: 100,
          )
          .first;
    });
    // ignore: avoid_print — timing is the point of this test.
    print(
      '100k entries: first page ${first.inMilliseconds} ms, '
      'last page ${deep.inMilliseconds} ms, '
      'totals ${totals.inMilliseconds} ms, '
      'one party ${party.inMilliseconds} ms',
    );

    expect(top, hasLength(100));
    expect(summary.count, entries);
    // The newest entry's baki is its party's whole khata.
    final newest = top.first;
    final all = [
      for (final r in await db.getAll(
        'SELECT * FROM ledger_entries WHERE party_id = ?',
        [newest.entry.partyId],
      ))
        LedgerRepository.fromRow(r),
    ];
    expect(newest.balance, LedgerCalculator.balance(all));
    // Generous bound so slow CI machines pass; locally it is far below.
    for (final d in [first, deep, totals, party]) {
      expect(d, lessThan(const Duration(seconds: 2)));
    }
  });
}
