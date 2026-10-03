import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/dashboard/data/dashboard_repository.dart';
import 'package:mandi_khata_app/features/dashboard/domain/dashboard.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const wheat = 'c0000000-0000-4000-8000-000000000001';
const paddy = 'c0000000-0000-4000-8000-000000000002';
const wheatT2 = 'c0000000-0000-4000-8000-000000000003';
const gurmeet = 'f0000000-0000-4000-8000-000000000001';
const baldev = 'f0000000-0000-4000-8000-000000000002';
const bansal = 'b0000000-0000-4000-8000-000000000001';
const other = 'f0000000-0000-4000-8000-000000000009';

final today = LedgerDate(2026, 10, 3);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late DashboardRepository repo;
  var n = 0;

  Future<void> lot({
    required String crop,
    required LedgerDate date,
    String tenant = t1,
    String status = 'posted',
    int qtl = 10000,
    int gross = 2000000,
    int commission = 50000,
  }) => db.execute(
    'INSERT INTO lots (id, tenant_id, lot_no, entry_date, farmer_id, crop_id, '
    'qtl_milli, status, gross, commission) VALUES (uuid(), ?, ?, ?, ?, ?, ?, '
    '?, ?, ?)',
    [
      tenant,
      'L-${n++}',
      date.toString(),
      gurmeet,
      crop,
      qtl,
      status,
      gross,
      commission,
    ],
  );

  Future<void> payment({
    required String direction,
    required int amount,
    String status = 'posted',
    String? chequeStatus,
    LedgerDate? chequeDate,
    String tenant = t1,
    LedgerDate? date,
  }) => db.execute(
    'INSERT INTO payments (id, tenant_id, receipt_no, entry_date, party_id, '
    'direction, mode, amount_paise, status, cheque_status, cheque_date) '
    'VALUES (uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      tenant,
      'V-${n++}',
      (date ?? today).toString(),
      gurmeet,
      direction,
      // A cheque has a status; anything else is cash.
      // ignore: prefer_if_elements_to_conditional_expressions
      chequeStatus == null ? 'cash' : 'cheque',
      amount,
      status,
      chequeStatus,
      chequeDate?.toString(),
    ],
  );

  Future<void> entry(
    String party,
    String side,
    int amount, {
    String tenant = t1,
  }) => db.execute(
    'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, side, '
    "amount_paise, ref_type, created_at) VALUES (uuid(), ?, ?, '2026-10-01', "
    "?, ?, 'journal', '2026-10-01T00:00:00Z')",
    [tenant, party, side, amount],
  );

  Future<void> audit(
    String user,
    String action,
    String table, {
    DateTime? at,
  }) => db.execute(
    'INSERT INTO audit_log (id, tenant_id, table_name, row_id, action, '
    'user_id, created_at) VALUES (uuid(), ?, ?, uuid(), ?, ?, ?)',
    [t1, table, action, user, (at ?? DateTime.now()).toUtc().toIso8601String()],
  );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_dashboard_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = DashboardRepository(db);
    for (final (id, tenant, code, en, hi) in [
      (wheat, t1, 'wheat', 'Wheat', 'गेहूँ'),
      (paddy, t1, 'paddy', 'Paddy', null),
      (wheatT2, t2, 'wheat', 'Wheat', null),
    ]) {
      await db.execute(
        'INSERT INTO crops (id, tenant_id, code, name_en, name_hi) '
        'VALUES (?, ?, ?, ?, ?)',
        [id, tenant, code, en, hi],
      );
    }
    for (final (id, tenant, role) in [
      (gurmeet, t1, 'farmer'),
      (baldev, t1, 'farmer'),
      (bansal, t1, 'buyer'),
      (other, t2, 'farmer'),
    ]) {
      await db.execute(
        'INSERT INTO party_roles (id, tenant_id, party_id, role) '
        'VALUES (uuid(), ?, ?, ?)',
        [tenant, id, role],
      );
    }
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  group('watchDay', () {
    test('is zero on an empty business', () async {
      expect(await repo.watchDay(t1, today).first, DaySummary.empty);
    });

    test(
      "counts the day's lots, weight, arhat, payments and receipts",
      () async {
        await lot(crop: wheat, date: today, qtl: 8640);
        await lot(crop: paddy, date: today, qtl: 12000, commission: 30000);
        await lot(crop: wheat, date: today, status: 'sold', commission: 99999);
        await payment(direction: 'to_party', amount: 500000);
        await payment(direction: 'to_party', amount: 100000);
        await payment(direction: 'from_party', amount: 250000);
        final day = await repo.watchDay(t1, today).first;
        expect(day.lots, 3);
        expect(day.qtlMilli, 8640 + 12000 + 10000);
        // Only posted lots earn: the sold one is not booked yet.
        expect(day.arhatEarned, const Money(80000));
        expect(day.paidOut, const Money(600000));
        expect(day.receipts, const Money(250000));
      },
    );

    test(
      'ignores other days, reversed lots and payments, other businesses',
      () async {
        await lot(crop: wheat, date: today.addDays(-1));
        await lot(crop: wheat, date: today, status: 'reversed');
        await lot(crop: wheatT2, date: today, tenant: t2);
        await payment(direction: 'to_party', amount: 1, status: 'reversed');
        await payment(
          direction: 'to_party',
          amount: 1,
          date: today.addDays(-1),
        );
        await payment(direction: 'to_party', amount: 1, tenant: t2);
        expect(await repo.watchDay(t1, today).first, DaySummary.empty);
      },
    );

    test('updates live when a lot is added', () async {
      final seen = <int>[];
      final sub = repo.watchDay(t1, today).listen((d) => seen.add(d.lots));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await lot(crop: wheat, date: today);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await sub.cancel();
      expect(seen.first, 0);
      expect(seen.last, 1);
    });
  });

  group('watchEarnedDays', () {
    test(
      'lists ten days oldest first, zero where nothing was earned',
      () async {
        await lot(crop: wheat, date: today, commission: 70000);
        await lot(crop: paddy, date: today, commission: 5000);
        await lot(crop: wheat, date: today.addDays(-9), commission: 10000);
        await lot(crop: wheat, date: today.addDays(-10), commission: 99999);
        await lot(crop: wheat, date: today.addDays(-3), status: 'reversed');
        final days = await repo.watchEarnedDays(t1, today).first;
        expect(days, hasLength(10));
        expect(days.first.date, LedgerDate(2026, 9, 24));
        expect(days.last.date, today);
        expect(days.first.amount, const Money(10000));
        expect(days.last.amount, const Money(75000));
        expect(days.sublist(1, 9).every((d) => d.amount.isZero), isTrue);
      },
    );
  });

  group('watchCropMix', () {
    test(
      'sums posted sales per crop for this financial year, biggest first',
      () async {
        await lot(crop: wheat, date: LedgerDate(2026, 4, 1), gross: 1000000);
        await lot(crop: wheat, date: today, gross: 500000);
        await lot(crop: paddy, date: today, gross: 2500000);
        // Last year, not posted, and another business: none count.
        await lot(crop: wheat, date: LedgerDate(2026, 3, 31), gross: 9);
        await lot(crop: wheat, date: today, status: 'sold', gross: 9);
        await lot(crop: wheatT2, date: today, tenant: t2, gross: 9);
        final mix = await repo.watchCropMix(t1, today).first;
        expect([for (final c in mix) c.code], ['paddy', 'wheat']);
        expect(mix[0].gross, const Money(2500000));
        expect(mix[1].gross, const Money(1500000));
        expect(mix[1].lots, 2);
        expect(mix[1].nameIn('hi'), 'गेहूँ');
        expect(mix[0].nameIn('hi'), 'Paddy');
      },
    );
  });

  group('watchPosition', () {
    test(
      'splits what farmers are owed, what they owe and what others owe',
      () async {
        await entry(gurmeet, 'jama', 1000000);
        await entry(gurmeet, 'udhaar', 200000);
        await entry(baldev, 'udhaar', 300000);
        await entry(bansal, 'udhaar', 700000);
        await entry(other, 'jama', 9, tenant: t2);
        final p = await repo.watchPosition(t1).first;
        expect(p.farmersPayable, const Money(800000));
        expect(p.farmersReceivable, const Money(300000));
        expect(p.othersReceivable, const Money(700000));
        expect(p.totalReceivable, const Money(1000000));
      },
    );

    test('nets jama against udhaar', () async {
      await entry(gurmeet, 'jama', 1234500);
      await entry(gurmeet, 'udhaar', 234500);
      final p = await repo.watchPosition(t1).first;
      expect(p.farmersPayable, const Money(1000000));
    });

    test('a settled party counts nowhere', () async {
      await entry(gurmeet, 'jama', 500);
      await entry(gurmeet, 'udhaar', 500);
      expect(await repo.watchPosition(t1).first, MoneyPosition.empty);
    });
  });

  group('watchAttention', () {
    test('counts pending posted cheques dated today or earlier', () async {
      await payment(
        direction: 'to_party',
        amount: 400000,
        chequeStatus: 'pending',
        chequeDate: today,
      );
      await payment(
        direction: 'to_party',
        amount: 100000,
        chequeStatus: 'pending',
        chequeDate: today.addDays(-5),
      );
      // Future, cleared, bounced-and-reversed, cash and other business.
      await payment(
        direction: 'to_party',
        amount: 1,
        chequeStatus: 'pending',
        chequeDate: today.addDays(1),
      );
      await payment(
        direction: 'to_party',
        amount: 1,
        chequeStatus: 'cleared',
        chequeDate: today,
      );
      await payment(
        direction: 'to_party',
        amount: 1,
        chequeStatus: 'pending',
        chequeDate: today,
        status: 'reversed',
      );
      await payment(direction: 'to_party', amount: 1);
      await payment(
        direction: 'to_party',
        amount: 1,
        chequeStatus: 'pending',
        chequeDate: today,
        tenant: t2,
      );
      final a = await repo.watchAttention(t1, today).first;
      expect(a.chequesDue, 2);
      expect(a.chequesDueAmount, const Money(500000));
    });

    test(
      'counts only munshi changes and reversals of the last 7 days',
      () async {
        await db.execute(
          'INSERT INTO tenant_members (id, tenant_id, user_id, role) VALUES '
          "(uuid(), ?, 'munshi-1', 'munshi'), (uuid(), ?, 'owner-1', 'owner')",
          [t1, t1],
        );
        await audit('munshi-1', 'update', 'lots');
        await audit('munshi-1', 'reverse', 'ledger_entries');
        await audit('munshi-1', 'insert', 'lots');
        await audit('munshi-1', 'update', 'parties');
        await audit('owner-1', 'reverse', 'lots');
        await audit(
          'munshi-1',
          'update',
          'payments',
          at: DateTime.now().subtract(const Duration(days: 8)),
        );
        final a = await repo.watchAttention(t1, today).first;
        expect(a.staffChanges, 2);
      },
    );
  });

  group('DashboardDays.chart', () {
    test('fills missing days with zero and keeps the order', () {
      final days = DashboardDays.chart(today, {today: const Money(5)});
      expect(days, hasLength(10));
      expect(days.first.date, today.addDays(-9));
      expect(days.last.amount, const Money(5));
      expect(days.first.amount, Money.zero);
    });
  });
}
