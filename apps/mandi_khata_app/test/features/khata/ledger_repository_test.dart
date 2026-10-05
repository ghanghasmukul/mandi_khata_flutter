import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/day_book.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
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
bool accountant(Permission p) => MemberRole.accountant.allows(p);

Money rs(int rupees) => Money.rupees(rupees);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late LedgerRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_ledger_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = LedgerRepository(db);
    for (final (id, tenant) in [('p1', t1), ('p2', t1), ('px', t2)]) {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [id, tenant, id, 'Party $id'],
      );
    }
    await db.execute(
      "UPDATE parties SET deleted_at = '2026-09-01T00:00:00Z' WHERE id = 'p2'",
    );
    await db.execute('DELETE FROM ps_crud');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<LedgerEntry> add(
    String date,
    Side side,
    int rupees, {
    RefType refType = RefType.payment,
    String party = 'p1',
    WriteContext c = ctx,
    DateTime? at,
  }) async {
    final r = await repo.append(
      c,
      LedgerDraft(
        partyId: party,
        side: side,
        amount: rs(rupees),
        refType: refType,
        entryDate: LedgerDate.parse(date),
      ),
      can: owner,
      now: at,
    );
    return (r as LedgerPosted).entries.single;
  }

  Future<List<Map<String, Object?>>> crud() async => [
    for (final r in await db.getAll('SELECT data FROM ps_crud ORDER BY id'))
      jsonDecode(r['data']! as String) as Map<String, Object?>,
  ];

  Future<List<Map<String, Object?>>> audit() =>
      db.getAll('SELECT * FROM audit_log ORDER BY created_at, row_id');

  group('append', () {
    test('writes the entry and its audit row in one transaction', () async {
      final e = await add(
        '2026-04-05',
        Side.jama,
        15558,
        refType: RefType.arrival,
        at: DateTime.utc(2026, 4, 5, 11),
      );

      final row = await db.get('SELECT * FROM ledger_entries');
      expect(row['id'], e.id);
      expect(row['tenant_id'], t1);
      expect(row['party_id'], 'p1');
      expect(row['entry_date'], '2026-04-05');
      expect(row['side'], 'jama');
      expect(row['amount_paise'], 1555800);
      expect(row['ref_type'], 'arrival');
      expect(row['device_id'], 'device-w1');
      expect(row['created_by'], 'user-a');
      expect(row['created_at'], '2026-04-05T11:00:00.000Z');

      final ops = await crud();
      expect(ops.map((o) => '${o['op']} ${o['type']}'), [
        'PUT ledger_entries',
        'PUT audit_log',
      ]);
      expect(
        (await db.getAll('SELECT DISTINCT tx_id FROM ps_crud')).length,
        1,
        reason: 'uploaded all-or-nothing',
      );
      final log = (await audit()).single;
      expect(log['action'], 'insert');
      expect(log['table_name'], 'ledger_entries');
      expect(jsonDecode(log['after']! as String), {
        'party_id': 'p1',
        'entry_date': '2026-04-05',
        'side': 'jama',
        'amount_paise': 1555800,
        'ref_type': 'arrival',
      });
    });

    test('dated today when no date is given; narration trimmed', () async {
      final r = await repo.append(
        ctx,
        LedgerDraft(
          partyId: 'p1',
          side: Side.udhaar,
          amount: rs(10),
          refType: RefType.payment,
          narration: '  cash at gate  ',
        ),
        can: owner,
        now: DateTime(2026, 9, 30, 18),
      );
      final e = (r as LedgerPosted).entries.single;
      expect(e.entryDate, LedgerDate(2026, 9, 30));
      expect(e.narration, 'cash at gate');
    });

    test('refuses a reversal, a non-positive amount, a missing or deleted '
        'party, and a party of another business', () async {
      Future<LedgerPostResult> post(
        String party, {
        RefType type = RefType.payment,
        int paise = 100,
      }) => repo.append(
        ctx,
        LedgerDraft(
          partyId: party,
          side: Side.udhaar,
          amount: Money(paise),
          refType: type,
        ),
        can: owner,
      );

      expect(
        await post('p1', type: RefType.reversal),
        isA<LedgerInvalid>().having(
          (r) => r.problem,
          'problem',
          LedgerProblem.useReverse,
        ),
      );
      expect(
        await post('p1', paise: 0),
        isA<LedgerInvalid>().having(
          (r) => r.problem,
          'problem',
          LedgerProblem.amountNotPositive,
        ),
      );
      expect(await post('nobody'), isA<LedgerNotFound>());
      expect(await post('p2'), isA<LedgerNotFound>());
      expect(await post('px'), isA<LedgerNotFound>());
      expect(await db.getAll('SELECT * FROM ledger_entries'), isEmpty);
      expect(await crud(), isEmpty);
    });

    test('checks the posting permission (mirrors the server)', () async {
      Future<LedgerPostResult> post(RefType type) => repo.append(
        ctx,
        LedgerDraft(
          partyId: 'p1',
          side: Side.udhaar,
          amount: rs(1),
          refType: type,
        ),
        can: munshi,
      );
      expect(await post(RefType.payment), isA<LedgerPosted>());
      expect(
        await post(RefType.journal),
        isA<LedgerNotPermitted>().having(
          (r) => r.permission,
          'permission',
          Permission.entriesReverse,
        ),
      );
      expect(await post(RefType.loanDisbursal), isA<LedgerNotPermitted>());
    });

    test('back-dated or future entries need entries.reverse '
        '(business.backdate_days, mirrors the server)', () async {
      final today = DateTime(2026, 10, 1, 11);
      Future<LedgerPostResult> post(
        String date, {
        bool Function(Permission) can = munshi,
      }) => repo.append(
        ctx,
        LedgerDraft(
          partyId: 'p1',
          side: Side.udhaar,
          amount: rs(1),
          refType: RefType.payment,
          entryDate: LedgerDate.parse(date),
        ),
        can: can,
        now: today,
      );
      final refused = isA<LedgerNotPermitted>()
          .having((r) => r.permission, 'permission', Permission.entriesReverse)
          .having((r) => r.backdateDays, 'backdateDays', 3);

      expect(await post('2026-10-01'), isA<LedgerPosted>());
      expect(await post('2026-09-28'), isA<LedgerPosted>());
      expect(await post('2026-09-27'), refused);
      expect(await post('2026-10-02'), refused);
      expect(await post('2026-09-01', can: owner), isA<LedgerPosted>());
      expect(await post('2026-09-27', can: accountant), isA<LedgerPosted>());

      await db.execute(
        'INSERT INTO settings (id, tenant_id, scope, key, value) '
        "VALUES (uuid(), ?, 'tenant', 'business.backdate_days', '0')",
        [t1],
      );
      expect(await post('2026-10-01'), isA<LedgerPosted>());
      expect(
        await post('2026-09-30'),
        isA<LedgerNotPermitted>().having((r) => r.backdateDays, 'days', 0),
      );
      // Another business's setting does not apply here.
      await db.execute(
        'INSERT INTO settings (id, tenant_id, scope, key, value) '
        "VALUES (uuid(), ?, 'tenant', 'business.backdate_days', '30')",
        [t2],
      );
      expect(await post('2026-09-30'), isA<LedgerNotPermitted>());
    });
  });

  group('reverse', () {
    test('posts the mirror entry with its audit row', () async {
      final e = await add(
        '2026-04-05',
        Side.jama,
        999,
        refType: RefType.journal,
      );
      await db.execute('DELETE FROM ps_crud');

      final r = await repo.reverse(
        ctx,
        e.id,
        can: owner,
        narration: 'wrong party',
        now: DateTime.utc(2026, 4, 9, 10),
      );
      final rev = (r as LedgerPosted).entries.single;
      expect(rev.reversesId, e.id);
      expect(rev.side, Side.udhaar);
      expect(rev.amount, rs(999));
      expect(rev.entryDate, LedgerDate(2026, 4, 5));
      expect(rev.narration, 'wrong party');

      expect((await crud()).map((o) => o['type']), [
        'ledger_entries',
        'audit_log',
      ]);
      final log = (await audit()).singleWhere((a) => a['row_id'] == rev.id);
      expect(log['action'], 'reverse');
      expect((jsonDecode(log['before']! as String) as Map)['side'], 'jama');
      expect((jsonDecode(log['after']! as String) as Map)['reverses_id'], e.id);
    });

    test('can be dated on another day (bounced cheque)', () async {
      final e = await add(
        '2026-04-05',
        Side.jama,
        500,
        refType: RefType.receipt,
      );
      final r = await repo.reverse(
        ctx,
        e.id,
        can: owner,
        entryDate: LedgerDate(2026, 4, 20),
      );
      expect(
        (r as LedgerPosted).entries.single.entryDate,
        LedgerDate(2026, 4, 20),
      );
    });

    test('needs entries.reverse', () async {
      final e = await add('2026-04-05', Side.jama, 500);
      expect(
        await repo.reverse(ctx, e.id, can: munshi),
        isA<LedgerNotPermitted>(),
      );
    });

    test('only once, never a reversal, only in this business', () async {
      final e = await add('2026-04-05', Side.jama, 500);
      final rev = ((await repo.reverse(ctx, e.id, can: owner)) as LedgerPosted)
          .entries
          .single;

      LedgerProblem? problem(LedgerPostResult r) =>
          r is LedgerInvalid ? r.problem : null;
      expect(
        problem(await repo.reverse(ctx, e.id, can: owner)),
        LedgerProblem.alreadyReversed,
      );
      expect(
        problem(await repo.reverse(ctx, rev.id, can: owner)),
        LedgerProblem.isReversal,
      );
      expect(
        await repo.reverse(otherTenant, e.id, can: owner),
        isA<LedgerNotFound>(),
      );
      expect(
        await repo.reverse(ctx, 'missing', can: owner),
        isA<LedgerNotFound>(),
      );
    });
  });

  group('correct', () {
    test(
      'reversal + replacement in one transaction, audited before → after',
      () async {
        final e = await add(
          '2026-04-05',
          Side.jama,
          15558,
          refType: RefType.arrival,
        );
        await db.execute('DELETE FROM ps_crud');

        final r = await repo.correct(
          ctx,
          e.id,
          can: owner,
          amount: rs(15000),
          now: DateTime.utc(2026, 4, 6, 9),
        );
        final [rev, replacement] = (r as LedgerPosted).entries;
        expect(rev.reversesId, e.id);
        expect(replacement.replacesId, e.id);
        expect(replacement.amount, rs(15000));
        expect(replacement.refType, RefType.arrival);

        expect((await crud()).map((o) => o['type']), [
          'ledger_entries',
          'ledger_entries',
          'audit_log',
          'audit_log',
        ]);
        expect(
          (await db.getAll('SELECT DISTINCT tx_id FROM ps_crud')).length,
          1,
        );
        final log = (await audit()).where((a) => a['row_id'] == replacement.id);
        expect(log.single['action'], 'insert');
        expect(
          (jsonDecode(log.single['before']! as String) as Map)['amount_paise'],
          1555800,
        );
        expect(
          (jsonDecode(log.single['after']! as String) as Map)['amount_paise'],
          1500000,
        );

        final s = await repo.watchStatement(t1, 'p1').first;
        expect(s.closing, rs(15000));
      },
    );

    test('must change something; needs entries.reverse; amount > 0', () async {
      final e = await add('2026-04-05', Side.jama, 100);
      expect(
        await repo.correct(ctx, e.id, can: owner, amount: rs(100)),
        isA<LedgerInvalid>().having(
          (r) => r.problem,
          'problem',
          LedgerProblem.nothingChanged,
        ),
      );
      expect(
        await repo.correct(ctx, e.id, can: munshi, amount: rs(50)),
        isA<LedgerNotPermitted>(),
      );
      expect(
        await repo.correct(ctx, e.id, can: owner, amount: Money.zero),
        isA<LedgerInvalid>(),
      );
      expect(
        await repo.correct(ctx, e.id, can: owner, side: Side.udhaar),
        isA<LedgerPosted>(),
      );
      expect(
        await repo.correct(ctx, e.id, can: owner, amount: rs(5)),
        isA<LedgerInvalid>().having(
          (r) => r.problem,
          'problem',
          LedgerProblem.alreadyReversed,
        ),
      );
    });
  });

  group('reading', () {
    test('watchEntries: one party, this business only, reversals included, '
        'and the interest engine sees the net khata', () async {
      final a = await add('2027-01-01', Side.udhaar, 100000);
      final wrong = await add('2027-01-05', Side.udhaar, 999);
      await add('2027-01-02', Side.udhaar, 50, party: 'px', c: otherTenant);
      await repo.reverse(ctx, wrong.id, can: owner);

      final entries = await repo.watchEntries(t1, 'p1').first;
      expect(entries, hasLength(3));
      expect(entries.map((e) => e.partyId).toSet(), {'p1'});
      expect(await repo.watchEntries(t2, 'p1').first, isEmpty);

      final events = KhataInterest.events(entries);
      expect(events.map((e) => e.id), [a.id]);
    });

    test('statement: opening, running baki, struck pairs, this business '
        'only', () async {
      await add(
        '2026-04-01',
        Side.udhaar,
        2000,
        refType: RefType.openingBalance,
      );
      await add('2026-04-05', Side.jama, 15558, refType: RefType.arrival);
      final wrong = await add('2026-04-09', Side.jama, 999);
      await repo.reverse(ctx, wrong.id, can: owner);
      await add('2026-04-12', Side.udhaar, 1250);
      await add('2026-04-12', Side.jama, 7, party: 'px', c: otherTenant);

      final s = await repo
          .watchStatement(
            t1,
            'p1',
            from: LedgerDate(2026, 4, 2),
            to: LedgerDate(2026, 4, 30),
          )
          .first;
      expect(s.opening, rs(-2000));
      expect(s.rows.map((r) => r.balance.rupees), [13558, 14557, 13558, 12308]);
      expect(s.rows.map((r) => r.isStruck), [false, true, true, false]);
      expect(s.closing, rs(12308));

      expect(
        (await repo.watchStatement(t2, 'p1').first).rows,
        isEmpty,
        reason: 'another business sees nothing',
      );
    });

    test('balances per party match LedgerCalculator', () async {
      await add('2026-04-01', Side.udhaar, 2000);
      await add('2026-04-05', Side.jama, 15558);
      await add('2026-04-05', Side.jama, 7, party: 'px', c: otherTenant);

      final balances = await repo.watchBalances(t1).first;
      final entries = [
        for (final r in await db.getAll(
          "SELECT * FROM ledger_entries WHERE party_id = 'p1'",
        ))
          LedgerRepository.fromRow(r),
      ];
      expect(balances, {'p1': LedgerCalculator.balance(entries)});
      expect(balances['p1'], rs(13558));
      expect(await repo.watchBalances(t2).first, {'px': rs(7)});
    });

    test('the statement updates live', () async {
      final updates = repo.watchStatement(t1, 'p1').map((s) => s.closing);
      final seen = <Money>[];
      final sub = updates.listen(seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await add('2026-04-05', Side.jama, 10);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await sub.cancel();
      expect(seen.first, Money.zero);
      expect(seen.last, rs(10));
    });
  });

  test("post() joins the caller's transaction (documents post with the "
      'khata)', () async {
    await db.writeTransaction((tx) async {
      await tx.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        ['p9', t1, 'p9', 'New farmer'],
      );
      await LedgerRepository.post(
        tx,
        ctx,
        LedgerDraft(
          partyId: 'p9',
          side: Side.udhaar,
          amount: rs(500),
          refType: RefType.openingBalance,
          entryDate: LedgerDate(2026, 4, 1),
        ),
      );
    });
    expect((await db.getAll('SELECT DISTINCT tx_id FROM ps_crud')).length, 1);
    expect((await crud()).map((o) => o['type']), [
      'parties',
      'ledger_entries',
      'audit_log',
    ]);
  });

  test('a failed transaction leaves nothing behind', () async {
    await expectLater(
      db.writeTransaction((tx) async {
        await LedgerRepository.post(
          tx,
          ctx,
          LedgerDraft(
            partyId: 'p1',
            side: Side.udhaar,
            amount: rs(500),
            refType: RefType.payment,
          ),
        );
        throw StateError('document failed to save');
      }),
      throwsStateError,
    );
    expect(await db.getAll('SELECT * FROM ledger_entries'), isEmpty);
    expect(await db.getAll('SELECT * FROM audit_log'), isEmpty);
    expect(await crud(), isEmpty);
  });

  group('day book', () {
    setUp(() async {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        ['p3', t1, 'B-3', 'Buyer Three'],
      );
    });

    Future<List<DayBookRow>> page(
      LedgerFilter f, {
      int offset = 0,
      int limit = 50,
    }) => repo.watchDayBookPage(t1, f, offset: offset, limit: limit).first;

    test("newest first, each row with its party's running baki over the "
        'whole khata (equals the khata_core statement)', () async {
      await add('2026-04-01', Side.udhaar, 2000, refType: RefType.journal);
      await add('2026-04-05', Side.jama, 15558, refType: RefType.arrival);
      await add('2026-04-05', Side.udhaar, 20952, party: 'p3');
      final wrong = await add('2026-04-09', Side.jama, 999);
      await repo.reverse(ctx, wrong.id, can: owner);
      await add('2026-04-12', Side.udhaar, 1250);
      await add('2026-04-12', Side.jama, 7, party: 'px', c: otherTenant);

      final rows = await page(const LedgerFilter());
      expect(rows, hasLength(6), reason: 'only this business');
      expect(rows.first.entry.entryDate, LedgerDate(2026, 4, 12));
      expect(rows.last.entry.entryDate, LedgerDate(2026, 4, 1));

      final statement = LedgerCalculator.statement([
        for (final r in await db.getAll(
          "SELECT * FROM ledger_entries WHERE party_id = 'p1'",
        ))
          LedgerRepository.fromRow(r),
      ]);
      final fromCore = {for (final r in statement.rows) r.entry.id: r.balance};
      for (final r in rows.where((r) => r.entry.partyId == 'p1')) {
        expect(r.balance, fromCore[r.entry.id], reason: r.entry.id);
      }
      expect(
        rows.firstWhere((r) => r.entry.partyId == 'p3').balance,
        rs(-20952),
      );
      expect(rows.first.partyName, 'Party p1');
      expect(rows.where((r) => r.isStruck), hasLength(2));
      expect(
        rows.firstWhere((r) => r.entry.id == wrong.id).reversedById,
        isNotNull,
      );
    });

    test(
      'filters by date range, party and type; balances stay whole-khata',
      () async {
        await add('2026-04-01', Side.udhaar, 2000, refType: RefType.journal);
        await add('2026-04-05', Side.jama, 15558, refType: RefType.arrival);
        await add('2026-04-05', Side.udhaar, 300, party: 'p3');
        await add('2026-04-12', Side.udhaar, 1250);

        final april5 = await page(
          LedgerFilter(
            from: LedgerDate(2026, 4, 5),
            to: LedgerDate(2026, 4, 5),
          ),
        );
        expect(april5, hasLength(2));
        final p1 = await page(
          LedgerFilter(from: LedgerDate(2026, 4, 5), partyId: 'p1'),
        );
        expect(p1.map((r) => r.balance), [rs(12308), rs(13558)]);
        final arrivals = await page(
          const LedgerFilter(refType: RefType.arrival),
        );
        expect(arrivals.single.entry.amount, rs(15558));

        final summary = await repo
            .watchDayBookSummary(t1, const LedgerFilter(partyId: 'p1'))
            .first;
        expect(summary.count, 3);
        expect(summary.udhaar, rs(3250));
        expect(summary.jama, rs(15558));
        expect(
          (await repo.watchDayBookSummary(t2, const LedgerFilter()).first)
              .count,
          0,
        );
      },
    );

    test('pages by offset and limit', () async {
      for (var d = 1; d <= 9; d++) {
        await add('2026-04-0$d', Side.udhaar, d);
      }
      final first = await page(const LedgerFilter(), limit: 4);
      final second = await page(const LedgerFilter(), offset: 4, limit: 4);
      final last = await page(const LedgerFilter(), offset: 8, limit: 4);
      expect(first.map((r) => r.entry.amount.rupees), [9, 8, 7, 6]);
      expect(second.map((r) => r.entry.amount.rupees), [5, 4, 3, 2]);
      expect(last.map((r) => r.entry.amount.rupees), [1]);
      expect(last.single.balance, rs(-1));
      expect(first.first.balance, rs(-45));
    });

    test('updates live', () async {
      final seen = <int>[];
      final sub = repo
          .watchDayBookSummary(t1, const LedgerFilter())
          .listen((s) => seen.add(s.count));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await add('2026-04-05', Side.jama, 10);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await sub.cancel();
      expect(seen.first, 0);
      expect(seen.last, 1);
    });
  });
}
