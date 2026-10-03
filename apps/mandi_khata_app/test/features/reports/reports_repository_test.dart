import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/reports/data/reports_repository.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const wheat = 'c0000000-0000-4000-8000-000000000001';
const paddy = 'c0000000-0000-4000-8000-000000000002';
const gurmeet = 'f0000000-0000-4000-8000-000000000001';
const baldev = 'f0000000-0000-4000-8000-000000000002';
const bansal = 'b0000000-0000-4000-8000-000000000001';
const other = 'f0000000-0000-4000-8000-000000000009';

final asOf = LedgerDate(2026, 10, 3);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late ReportsRepository repo;
  var n = 0;

  Future<void> party(
    String id,
    String tenant,
    String code,
    String name, {
    String role = 'farmer',
    String? village,
  }) async {
    await db.execute(
      'INSERT INTO parties (id, tenant_id, code, name, village) '
      'VALUES (?, ?, ?, ?, ?)',
      [id, tenant, code, name, village],
    );
    await db.execute(
      'INSERT INTO party_roles (id, tenant_id, party_id, role) '
      'VALUES (uuid(), ?, ?, ?)',
      [tenant, id, role],
    );
  }

  Future<void> entry(
    String partyId,
    String side,
    int amount,
    String date, {
    String tenant = t1,
  }) => db.execute(
    'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, side, '
    'amount_paise, ref_type, created_at) VALUES (uuid(), ?, ?, ?, ?, ?, '
    "'journal', ?)",
    [tenant, partyId, date, side, amount, '${date}T00:00:00Z'],
  );

  Future<void> lot({
    required String crop,
    required String date,
    String farmer = gurmeet,
    String status = 'posted',
    int bags = 10,
    int qtl = 10000,
    int gross = 2000000,
    int commission = 50000,
    int net = 1900000,
    String tenant = t1,
  }) => db.execute(
    'INSERT INTO lots (id, tenant_id, lot_no, entry_date, farmer_id, crop_id, '
    'bags, qtl_milli, status, gross, commission, net_to_farmer) VALUES '
    '(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [tenant, 'L-${n++}', date, farmer, crop, bags, qtl, status, gross]
      ..insertAll(9, [commission, net]),
  );

  Future<void> payment({
    required String mode,
    required int amount,
    String direction = 'to_party',
    String status = 'posted',
    String date = '2026-10-01',
    String tenant = t1,
  }) => db.execute(
    'INSERT INTO payments (id, tenant_id, receipt_no, entry_date, party_id, '
    'direction, mode, amount_paise, status) VALUES (uuid(), ?, ?, ?, ?, ?, ?, '
    '?, ?)',
    [tenant, 'V-${n++}', date, gurmeet, direction, mode, amount, status],
  );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_reports_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = ReportsRepository(db);
    for (final (id, tenant, code, en, hi) in [
      (wheat, t1, 'wheat', 'Wheat', 'गेहूँ'),
      (paddy, t1, 'paddy', 'Paddy', null),
    ]) {
      await db.execute(
        'INSERT INTO crops (id, tenant_id, code, name_en, name_hi) '
        'VALUES (?, ?, ?, ?, ?)',
        [id, tenant, code, en, hi],
      );
    }
    await party(gurmeet, t1, 'F-1', 'Gurmeet', village: 'Rampura');
    await party(baldev, t1, 'F-2', 'Baldev', village: 'Rampura');
    await party(bansal, t1, 'B-1', 'Bansal', role: 'buyer');
    await party(other, t2, 'F-1', 'Other', village: 'Rampura');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  group('outstanding', () {
    test('lists non-zero balances by size with the last entry date', () async {
      await entry(gurmeet, 'jama', 500000, '2026-08-01');
      await entry(gurmeet, 'udhaar', 100000, '2026-09-20');
      await entry(bansal, 'udhaar', 900000, '2026-07-01');
      await entry(baldev, 'jama', 200000, '2026-06-01');
      await entry(baldev, 'udhaar', 200000, '2026-06-02');
      await entry(other, 'jama', 1, '2026-06-02', tenant: t2);

      final rows = await repo.outstanding(t1, asOf: asOf);
      expect(rows.map((r) => r.code), ['B-1', 'F-1']);
      expect(rows[0].balance, const Money(-900000));
      expect(rows[0].weOwe, isFalse);
      expect(rows[1].balance, const Money(400000));
      expect(rows[1].lastEntry, LedgerDate(2026, 9, 20));
      expect(rows[1].village, 'Rampura');
    });

    test('splits payable and receivable', () async {
      await entry(gurmeet, 'jama', 500000, '2026-08-01');
      await entry(bansal, 'udhaar', 900000, '2026-07-01');
      final payable = await repo.outstanding(
        t1,
        asOf: asOf,
        side: OutstandingSide.payable,
      );
      final receivable = await repo.outstanding(
        t1,
        asOf: asOf,
        side: OutstandingSide.receivable,
      );
      expect(payable.map((r) => r.code), ['F-1']);
      expect(receivable.map((r) => r.code), ['B-1']);
    });

    test('ignores entries after the as-of day', () async {
      await entry(gurmeet, 'jama', 500000, '2026-08-01');
      await entry(gurmeet, 'udhaar', 500000, '2026-10-04');
      final rows = await repo.outstanding(t1, asOf: asOf);
      expect(rows.single.balance, const Money(500000));
      expect(rows.single.lastEntry, LedgerDate(2026, 8, 1));
      expect(
        await repo.outstanding(t1, asOf: LedgerDate(2026, 10, 4)),
        isEmpty,
      );
    });
  });

  group('arrivals', () {
    test('lists the period oldest first without reversed lots', () async {
      await lot(crop: wheat, date: '2026-10-02');
      await lot(crop: paddy, date: '2026-10-01', gross: 100, net: 90);
      await lot(crop: wheat, date: '2026-10-01', status: 'reversed');
      await lot(crop: wheat, date: '2026-09-01');
      final rows = await repo.arrivals(
        t1,
        from: LedgerDate(2026, 10, 1),
        to: LedgerDate(2026, 10, 3),
      );
      expect(rows.length, 2);
      expect(rows.first.crop.en, 'Paddy');
      expect(rows.first.deductions, const Money(10));
      expect(rows.last.crop.pick('hi'), 'गेहूँ');
      expect(rows.last.crop.pick('pa'), 'Wheat');
      expect(rows.last.farmerName, 'Gurmeet');
      expect(rows.last.netToFarmer, const Money(1900000));
    });

    test('filters by crop and keeps an unsold lot without amounts', () async {
      await lot(crop: wheat, date: '2026-10-02');
      await db.execute(
        'INSERT INTO lots (id, tenant_id, lot_no, entry_date, farmer_id, '
        "crop_id, bags, status) VALUES (uuid(), ?, 'L-open', '2026-10-02', ?, "
        "?, 4, 'arrived')",
        [t1, gurmeet, paddy],
      );
      final paddyOnly = await repo.arrivals(t1, cropId: paddy);
      expect(paddyOnly.single.lotNo, 'L-open');
      expect(paddyOnly.single.gross, isNull);
      expect(paddyOnly.single.deductions, isNull);
    });
  });

  test('commission sums posted lots per crop, biggest sale first', () async {
    await lot(crop: wheat, date: '2026-10-01', qtl: 8640);
    await lot(crop: wheat, date: '2026-10-02', qtl: 1360);
    await lot(crop: paddy, date: '2026-10-02', gross: 5000000, commission: 1);
    await lot(crop: wheat, date: '2026-10-02', status: 'sold');
    await lot(crop: wheat, date: '2026-10-02', status: 'reversed');
    final rows = await repo.commission(t1);
    expect(rows.map((r) => r.cropCode), ['paddy', 'wheat']);
    expect(rows.last.lots, 2);
    expect(rows.last.qtlMilli, 10000);
    expect(rows.last.gross, const Money(4000000));
    expect(rows.last.commission, const Money(100000));
  });

  group('payments', () {
    test('groups by mode, hides reversed and other businesses', () async {
      await payment(mode: 'upi', amount: 300);
      await payment(mode: 'cash', amount: 100, date: '2026-10-02');
      await payment(mode: 'cash', amount: 50, direction: 'from_party');
      await payment(mode: 'cheque', amount: 700, status: 'reversed');
      await payment(mode: 'cash', amount: 9, tenant: t2);
      final rows = await repo.payments(t1);
      expect(rows.map((r) => r.mode), [
        PaymentMode.cash,
        PaymentMode.cash,
        PaymentMode.upi,
      ]);
      expect(rows.map((r) => r.amount.paise), [50, 100, 300]);
      expect(rows.first.direction, PaymentDirection.fromParty);
      expect(rows.first.partyName, 'Gurmeet');
    });

    test('filters by mode and dates', () async {
      await payment(mode: 'upi', amount: 300);
      await payment(mode: 'cash', amount: 100, date: '2026-10-02');
      final cash = await repo.payments(t1, mode: PaymentMode.cash);
      expect(cash.single.amount, const Money(100));
      final first = await repo.payments(t1, to: LedgerDate(2026, 10, 1));
      expect(first.single.amount, const Money(300));
    });
  });

  group('bulk farmer statements', () {
    setUp(() async {
      await party(
        'f0000000-0000-4000-8000-000000000003',
        t1,
        'F-3',
        'Charan',
        village: 'Sardulgarh',
      );
      await entry(gurmeet, 'jama', 500000, '2026-08-01');
      await entry(gurmeet, 'udhaar', 100000, '2026-09-20');
      await entry(baldev, 'jama', 70000, '2026-09-25');
      await entry(
        'f0000000-0000-4000-8000-000000000003',
        'jama',
        1,
        '2026-09-25',
      );
      await entry(bansal, 'udhaar', 5, '2026-09-25');
    });

    test('lists the farmers of a village by name with statements', () async {
      final list = await repo.farmerVillages(t1);
      expect(list, ['Rampura', 'Sardulgarh']);
      final rows = await repo.farmerStatements(
        t1,
        village: 'Rampura',
        from: LedgerDate(2026, 9, 1),
      );
      expect(rows.map((r) => r.name), ['Baldev', 'Gurmeet']);
      final g = rows.last.statement;
      expect(g.opening, const Money(500000));
      expect(g.totalUdhaar, const Money(100000));
      expect(g.closing, const Money(400000));
    });

    test('without a village lists every farmer, never buyers', () async {
      final rows = await repo.farmerStatements(t1);
      expect(rows.map((r) => r.code), ['F-2', 'F-3', 'F-1']);
    });

    test('a farmer with nothing up to the end date is left out', () async {
      final rows = await repo.farmerStatements(t1, to: LedgerDate(2026, 8, 31));
      expect(rows.map((r) => r.code), ['F-1']);
    });
  });

  test('a season of 20k lots reports in well under 2 s', () async {
    await db.writeTransaction((tx) async {
      for (var i = 0; i < 20000; i++) {
        await tx.execute(
          'INSERT INTO lots (id, tenant_id, lot_no, entry_date, farmer_id, '
          'crop_id, bags, qtl_milli, status, gross, commission, '
          "net_to_farmer) VALUES (uuid(), ?, ?, '2026-10-01', ?, ?, 10, "
          "10000, 'posted', 2000000, 50000, 1900000)",
          [
            t1,
            'P-$i',
            [gurmeet, baldev][i % 2],
            [wheat, paddy, paddy][i % 3],
          ],
        );
      }
    });
    final watch = Stopwatch()..start();
    final arrivals = await repo.arrivals(t1);
    final commission = await repo.commission(t1);
    watch.stop();
    expect(arrivals.length, 20000);
    expect(commission.fold(0, (a, c) => a + c.lots), 20000);
    expect(watch.elapsedMilliseconds, lessThan(2000));
  });
}
