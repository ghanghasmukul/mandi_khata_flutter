import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/arrivals/data/lots_repository.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/crops/data/crops_repository.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
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

const farmer = 'f0000000-0000-4000-8000-000000000001';
const buyer = 'b0000000-0000-4000-8000-000000000001';
const farmerT2 = 'f0000000-0000-4000-8000-000000000002';
final String wheat = CropsRepository.idFor(t1, 'wheat');
final String paddy = CropsRepository.idFor(t1, 'paddy_pr126');
final String oldCrop = CropsRepository.idFor(t1, 'jowar');
final String wheatT2 = CropsRepository.idFor(t2, 'wheat');

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);
bool accountant(Permission p) => MemberRole.accountant.allows(p);
bool nobody(Permission _) => false;

final day = LedgerDate(2026, 4, 10);
final now = DateTime.utc(2026, 4, 10, 6);

/// Wheat, 18 bags, 8.64 qtl @ ₹2,425: net ₹19,832.76 with the defaults.
LotDraft wheatLot({
  int? qtlMilli = 8640,
  Money? rate = const Money.rupees(2425),
  String? buyerId,
  String cropId = '',
  LedgerDate? date,
}) => LotDraft(
  entryDate: date ?? day,
  farmerId: farmer,
  cropId: cropId.isEmpty ? wheat : cropId,
  bags: 18,
  qtlMilli: qtlMilli,
  rate: rate,
  buyerId: buyerId,
  vehicleNo: ' pb 03 ab 1234 ',
);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late LotsRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_lots_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = LotsRepository(db);
    for (final (id, tenant, name) in [
      (farmer, t1, 'Gurmeet Singh'),
      (buyer, t1, 'Bansal Traders'),
      (farmerT2, t2, 'Other Farmer'),
    ]) {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [id, tenant, 'C-$name', name],
      );
    }
    for (final (id, tenant, code, active) in [
      (wheat, t1, 'wheat', 1),
      (paddy, t1, 'paddy_pr126', 1),
      (oldCrop, t1, 'jowar', 0),
      (wheatT2, t2, 'wheat', 1),
    ]) {
      await db.execute(
        'INSERT INTO crops (id, tenant_id, code, name_en, unit, sort_order, '
        'is_active) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [id, tenant, code, code, 'qtl', 10, active],
      );
    }
    // Only what the repository writes counts below.
    await db.execute('DELETE FROM ps_crud');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> setting(String scope, String? scopeId, String key, Object v) =>
      db.execute(
        'INSERT INTO settings (id, tenant_id, scope, scope_id, key, value) '
        'VALUES (uuid(), ?, ?, ?, ?, ?)',
        [t1, scope, scopeId, key, jsonEncode(v)],
      );

  Future<Lot> lot(String id, [String tenant = t1]) async =>
      (await repo.watchOne(tenant, id).first)!;

  Future<List<Map<String, Object?>>> entries() => db.getAll(
    'SELECT * FROM ledger_entries ORDER BY created_at, ref_type, side',
  );

  Future<List<Map<String, Object?>>> audit() =>
      db.getAll('SELECT * FROM audit_log');

  Future<int> transactions() async =>
      (await db.getAll('SELECT DISTINCT tx_id FROM ps_crud')).length;

  Future<String> save(LotDraft d, {String? id, bool post = true}) async {
    final r = await repo.save(ctx, d, id: id, post: post, can: owner, now: now);
    expect(r, isA<LotSaved>());
    return (r as LotSaved).id;
  }

  group('arrival (no weight yet)', () {
    test(
      'saves as arrived with a device lot number and an audit row',
      () async {
        final id = await save(wheatLot(qtlMilli: null, rate: null));
        final l = await lot(id);
        expect(l.lotNo, 'L-W1-0001');
        expect(l.status, LotStatus.arrived);
        expect(l.farmerName, 'Gurmeet Singh');
        expect(l.cropCode, 'wheat');
        expect(l.bags, 18);
        expect(l.vehicleNo, 'PB 03 AB 1234');
        expect(l.snapshot, isNull);
        expect(await entries(), isEmpty);

        final a = await audit();
        expect(a.single['table_name'], 'lots');
        expect(a.single['action'], 'insert');
        final after = jsonDecode(a.single['after']! as String) as Map;
        expect(after['lot_no'], 'L-W1-0001');
        expect(await transactions(), 1);
      },
    );

    test('numbers follow on from this device', () async {
      await save(wheatLot(qtlMilli: null, rate: null));
      final id = await save(wheatLot(qtlMilli: null, rate: null));
      expect((await lot(id)).lotNo, 'L-W1-0002');
    });

    test('weight without rate is weighed', () async {
      final id = await save(wheatLot(rate: null));
      expect((await lot(id)).status, LotStatus.weighed);
    });
  });

  group('posting', () {
    test('worked example: net to farmer as jama, in one transaction', () async {
      final id = await save(wheatLot());
      final l = await lot(id);
      expect(l.status, LotStatus.posted);
      expect(l.gross, const Money(2095200));
      expect(l.commission, const Money(52380));
      expect(l.netToFarmer, const Money(1983276));
      expect(l.buyerTotal, const Money(2095200));
      expect(l.postedAt, now);
      expect(l.snapshot, MandiConfig.resolve(SettingsResolver(const [])));

      final e = await entries();
      expect(e, hasLength(1));
      expect(e.single['party_id'], farmer);
      expect(e.single['side'], 'jama');
      expect(e.single['amount_paise'], 1983276);
      expect(e.single['ref_type'], 'arrival');
      expect(e.single['ref_id'], id);
      expect(e.single['entry_date'], '2026-04-10');
      expect(e.single['narration'], 'L-W1-0001');

      expect([
        for (final a in await audit()) a['table_name'],
      ], unorderedEquals(['lots', 'ledger_entries', 'journal_entries']));
      expect(
        await transactions(),
        1,
        reason: 'lot, entry and audit rows upload together',
      );
    });

    test(
      'with a buyer: udhaar of gross + buyer charges to the buyer',
      () async {
        final id = await save(wheatLot(buyerId: buyer));
        final e = await entries();
        expect(
          [for (final r in e) (r['party_id'], r['side'], r['amount_paise'])],
          [(farmer, 'jama', 1983276), (buyer, 'udhaar', 2095200)],
        );
        expect((await lot(id)).buyerName, 'Bansal Traders');
      },
    );

    test('rates come from the cascade and are snapshotted', () async {
      await setting('tenant', null, 'mandi.commission_pct.wheat', '2');
      await setting('party', farmer, 'mandi.palledari_per_bag', 1000);
      final id = await save(wheatLot());
      final l = await lot(id);
      expect(l.snapshot!.commissionPct.toString(), '2');
      expect(l.snapshot!.palledariPerBag, const Money(1000));
      // 20,952 − (419.04 + 180 + 144 + 25.92 + 209.52) = 19,973.52
      expect(l.netToFarmer, const Money(1997352));

      // Changing the business rate later never changes a posted lot.
      await setting('tenant', null, 'mandi.commission_pct', '3');
      expect((await lot(id)).netToFarmer, const Money(1997352));
    });

    test('buyer-borne charges need a buyer; nothing is written', () async {
      await setting('tenant', null, 'mandi.charges_borne_by', {
        'mandi_fee': 'buyer',
      });
      final r = await repo.save(ctx, wheatLot(), can: owner, now: now);
      expect(r, isA<LotInvalid>());
      expect((r as LotInvalid).problems, {LotProblem.buyerRequired});
      expect(await db.getAll('SELECT * FROM lots'), isEmpty);
      expect(await db.getAll('SELECT * FROM number_series'), isEmpty);
      expect(await audit(), isEmpty);
    });

    test('hold keeps a complete lot open as sold', () async {
      final id = await save(wheatLot(), post: false);
      expect((await lot(id)).status, LotStatus.sold);
      expect(await entries(), isEmpty);
    });
  });

  group('editing', () {
    test(
      'the counter adds weight and rate; only changes are written',
      () async {
        final id = await save(wheatLot(qtlMilli: null, rate: null));
        await db.execute('DELETE FROM ps_crud');
        await save(wheatLot(), id: id);
        final l = await lot(id);
        expect(l.lotNo, 'L-W1-0001');
        expect(l.status, LotStatus.posted);
        expect(await entries(), hasLength(1));

        final update = (await audit()).firstWhere(
          (a) => a['action'] == 'update',
        );
        final before = jsonDecode(update['before']! as String) as Map;
        expect(before['status'], 'arrived');
        expect(before.containsKey('bags'), isFalse, reason: 'unchanged');
        expect(await transactions(), 1);
      },
    );

    test('a posted lot cannot be edited or cancelled', () async {
      final id = await save(wheatLot());
      final edit = await repo.save(ctx, wheatLot(), id: id, can: owner);
      expect(edit, isA<LotLocked>());
      expect(await repo.cancel(ctx, id, can: owner), isA<LotLocked>());
    });

    test('a switched-off crop takes no new lots', () async {
      final r = await repo.save(ctx, wheatLot(cropId: oldCrop), can: owner);
      expect(r, isA<LotNotFound>());
    });

    test('validation problems are returned', () async {
      final r = await repo.save(
        ctx,
        wheatLot(buyerId: farmer, rate: Money.zero),
        can: owner,
      );
      expect((r as LotInvalid).problems, {
        LotProblem.buyerIsFarmer,
        LotProblem.rateNotPositive,
      });
    });
  });

  group('reverse and cancel', () {
    test('reversal mirrors every entry and marks the lot', () async {
      final id = await save(wheatLot(buyerId: buyer));
      await db.execute('DELETE FROM ps_crud');
      final r = await repo.reverse(ctx, id, can: accountant, now: now);
      expect(r, isA<LotSaved>());
      final l = await lot(id);
      expect(l.status, LotStatus.reversed);
      expect(l.isReversedAfterPosting, isTrue);

      final e = await entries();
      expect(e, hasLength(4));
      final balances = await LedgerRepository(db).watchBalances(t1).first;
      expect(balances[farmer], Money.zero);
      expect(balances[buyer], Money.zero);
      final reversals = [
        for (final r in e)
          if (r['ref_type'] == 'reversal') r,
      ];
      expect(
        [for (final r in reversals) r['entry_date']],
        ['2026-04-10', '2026-04-10'],
      );
      expect([
        for (final a in await audit()) (a['table_name'], a['action']),
      ], containsAll([('ledger_entries', 'reverse'), ('lots', 'reverse')]));
      expect(await transactions(), 1);
      expect(
        (await repo.watchEntries(t1, id).first).length,
        4,
        reason: 'the lot shows its entries and their reversals',
      );

      expect(await repo.reverse(ctx, id, can: owner), isA<LotLocked>());
    });

    test('a munshi cannot reverse', () async {
      final id = await save(wheatLot());
      final r = await repo.reverse(ctx, id, can: munshi);
      expect(
        r,
        isA<LotNotPermitted>().having(
          (p) => p.permission,
          'permission',
          Permission.entriesReverse,
        ),
      );
      expect((await lot(id)).status, LotStatus.posted);
    });

    test('an open lot can be cancelled by a munshi; nothing posts', () async {
      final id = await save(wheatLot(qtlMilli: null, rate: null));
      expect(await repo.cancel(ctx, id, can: munshi), isA<LotSaved>());
      final l = await lot(id);
      expect(l.isCancelled, isTrue);
      expect(await entries(), isEmpty);
      expect(await repo.reverse(ctx, id, can: owner), isA<LotLocked>());
    });
  });

  group('permissions and tenants', () {
    test('lots need arrivals.manage', () async {
      final r = await repo.save(ctx, wheatLot(), can: nobody);
      expect(r, isA<LotNotPermitted>());
      expect(
        await repo.save(ctx, wheatLot(), can: munshi, now: now),
        isA<LotSaved>(),
      );
    });

    test('a munshi cannot post a lot dated outside the back-date window '
        '(business.backdate_days, default 3)', () async {
      final later = now.add(const Duration(days: 4));
      final r = await repo.save(ctx, wheatLot(), can: munshi, now: later);
      expect(
        r,
        isA<LotNotPermitted>()
            .having(
              (n) => n.permission,
              'permission',
              Permission.entriesReverse,
            )
            .having((n) => n.backdateDays, 'backdateDays', 3),
      );
      expect(await entries(), isEmpty);
      expect(await db.getAll('SELECT * FROM lots'), isEmpty);

      // Held (not posted) it can still be saved; three days back posts.
      expect(
        await repo.save(ctx, wheatLot(), can: munshi, now: later, post: false),
        isA<LotSaved>(),
      );
      expect(
        await repo.save(
          ctx,
          wheatLot(),
          can: munshi,
          now: now.add(const Duration(days: 3)),
        ),
        isA<LotSaved>(),
      );
      // The owner may back-date; a wider business window lets the munshi.
      expect(
        await repo.save(ctx, wheatLot(), can: owner, now: later),
        isA<LotSaved>(),
      );
      await setting('tenant', null, 'business.backdate_days', 7);
      expect(
        await repo.save(ctx, wheatLot(), can: munshi, now: later),
        isA<LotSaved>(),
      );
    });

    test('another business sees none of these lots', () async {
      final id = await save(wheatLot());
      expect(await repo.watchAll(t2, const LotFilter()).first, isEmpty);
      expect(await repo.watchOne(t2, id).first, isNull);
      expect(
        await repo.reverse(otherTenant, id, can: owner),
        isA<LotNotFound>(),
      );
    });

    test('farmers and crops of another business are refused', () async {
      final r = await repo.save(
        otherTenant,
        wheatLot(cropId: wheatT2),
        can: owner,
      );
      expect(r, isA<LotNotFound>(), reason: 'farmer belongs to business 1');
      final r2 = await repo.save(
        otherTenant,
        LotDraft(entryDate: day, farmerId: farmerT2, cropId: wheat),
        can: owner,
      );
      expect(r2, isA<LotNotFound>(), reason: 'crop belongs to business 1');
    });
  });

  group('list', () {
    test(
      'filters by date, crop, status and text; totals skip reversed',
      () async {
        final a = await save(wheatLot());
        await save(
          wheatLot(qtlMilli: null, rate: null, date: LedgerDate(2026, 4, 9)),
        );
        final c = await save(
          wheatLot(cropId: paddy, qtlMilli: null, rate: null),
        );
        await repo.cancel(ctx, c, can: owner);

        Future<List<String>> ids(LotFilter f) async => [
          for (final l in await repo.watchAll(t1, f).first) l.lotNo,
        ];
        final all = await ids(const LotFilter());
        expect(all.last, 'L-W1-0002', reason: 'newest business date first');
        expect(all.take(2), unorderedEquals(['L-W1-0001', 'L-W1-0003']));
        expect(
          await ids(LotFilter(from: day, to: day)),
          unorderedEquals(['L-W1-0001', 'L-W1-0003']),
        );
        expect(await ids(LotFilter(cropId: paddy)), ['L-W1-0003']);
        expect(await ids(const LotFilter(status: LotStatus.posted)), [
          'L-W1-0001',
        ]);
        expect(await ids(const LotFilter(query: 'w1-0002')), ['L-W1-0002']);
        expect(await ids(const LotFilter(query: 'gurmeet')), hasLength(3));
        expect(await ids(const LotFilter(query: 'nobody')), isEmpty);

        final totals = LotTotals.of(
          await repo.watchAll(t1, const LotFilter()).first,
        );
        expect(totals.count, 2, reason: 'the cancelled lot is left out');
        expect(totals.bags, 36);
        expect(totals.qtlMilli, 8640);
        expect(totals.netToFarmer, const Money(1983276));
        expect((await lot(a)).status, LotStatus.posted);
      },
    );
  });
}
