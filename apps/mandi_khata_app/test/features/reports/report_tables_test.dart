import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_tables.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final asOf = LedgerDate(2026, 10, 3);

  OutstandingRow row(String code, int balance, LedgerDate last) =>
      OutstandingRow(
        partyId: code,
        code: code,
        name: 'Name $code',
        balance: Money(balance),
        lastEntry: last,
      );

  group('outstanding', () {
    final rows = [
      row('A', 500000, LedgerDate(2026, 9, 20)), // we owe, 13 days
      row('B', -900000, LedgerDate(2026, 7, 1)), // they owe, 94 days
      row('C', -100000, LedgerDate(2026, 1, 1)), // they owe, 275 days
      row('D', 250000, LedgerDate(2026, 8, 1)), // we owe, 63 days
    ];

    test('splits each balance into we-owe / they-owe with age', () {
      final t = ReportTables.outstanding(l10n, rows, asOf);
      expect(t.rows[0].sublist(3, 8), [
        const Money(500000),
        null,
        LedgerDate(2026, 9, 20),
        13,
        '0–30 days',
      ]);
      expect(t.rows[1].sublist(3, 8), [
        null,
        const Money(900000),
        LedgerDate(2026, 7, 1),
        94,
        '91–180 days',
      ]);
      expect(t.rows[2][7], 'Over 180 days');
      expect(t.totals![3], const Money(750000));
      expect(t.totals![4], const Money(1000000));
    });

    test('ageing cards sum each bucket on its own side', () {
      final totals = ReportTables.ageingTotals(rows, asOf);
      expect(totals[AgeingBucket.upTo30]!.weOwe, const Money(500000));
      expect(totals[AgeingBucket.upTo90]!.weOwe, const Money(250000));
      expect(totals[AgeingBucket.upTo180]!.theyOwe, const Money(900000));
      expect(totals[AgeingBucket.over180]!.theyOwe, const Money(100000));
      expect(totals[AgeingBucket.over180]!.weOwe, Money.zero);
    });

    test('exports as CSV with plain rupees', () {
      final csv = ReportTables.outstanding(l10n, rows, asOf).toCsv();
      expect(csv.split('\r\n').first, startsWith('Code,Party,Village,We owe'));
      expect(csv, contains('A,Name A,,5000.00,,2026-09-20,13,0–30 days'));
      expect(csv, contains('Total,,,7500.00,10000.00,,,'));
    });
  });

  test('arrivals total only what is known', () {
    final t = ReportTables.arrivals(l10n, [
      ArrivalRow(
        lotNo: 'L-1',
        date: asOf,
        farmerName: 'Gurmeet',
        crop: const LocalName('Wheat', hi: 'गेहूँ'),
        bags: 10,
        qtlMilli: 8640,
        ratePerQtl: const Money(240000),
        gross: const Money(2073600),
        netToFarmer: const Money(1900000),
        status: LotStatus.posted,
      ),
      ArrivalRow(
        lotNo: 'L-2',
        date: asOf,
        farmerName: 'Baldev',
        crop: const LocalName('Wheat'),
        bags: 4,
        status: LotStatus.arrived,
      ),
    ], 'hi');
    expect(t.rows[0][3], 'गेहूँ');
    expect(t.rows[0][8], const Money(173600));
    expect(t.rows[1][7], isNull);
    expect(t.rows[1][11], 'Arrived');
    expect(t.totals, [
      'Total',
      null,
      null,
      null,
      14,
      8640,
      null,
      const Money(2073600),
      const Money(173600),
      const Money(1900000),
      null,
      null,
    ]);
  });

  test('payments put receipts and payments in separate columns', () {
    final rows = [
      PaymentRow(
        receiptNo: 'R-1',
        date: asOf,
        partyName: 'Gurmeet',
        partyCode: 'F-1',
        direction: PaymentDirection.fromParty,
        mode: PaymentMode.cash,
        amount: const Money(1000),
      ),
      PaymentRow(
        receiptNo: 'V-1',
        date: asOf,
        partyName: 'Baldev',
        direction: PaymentDirection.toParty,
        mode: PaymentMode.cash,
        amount: const Money(400),
      ),
      PaymentRow(
        receiptNo: 'V-2',
        date: asOf,
        partyName: 'Baldev',
        direction: PaymentDirection.toParty,
        mode: PaymentMode.upi,
        amount: const Money(50),
      ),
    ];
    final t = ReportTables.payments(l10n, rows);
    expect(t.rows[0][2], 'Gurmeet (F-1)');
    expect(t.rows[0].sublist(4, 6), [const Money(1000), null]);
    expect(t.rows[1].sublist(4, 6), [null, const Money(400)]);
    expect(t.totals!.sublist(4, 6), [const Money(1000), const Money(450)]);
    final modes = ReportTables.modeTotals(rows);
    expect(modes[PaymentMode.cash]!.received, const Money(1000));
    expect(modes[PaymentMode.cash]!.paid, const Money(400));
    expect(modes[PaymentMode.upi]!.paid, const Money(50));
  });

  test('commission totals the crops', () {
    final t = ReportTables.commission(l10n, const [
      CommissionRow(
        cropCode: 'wheat',
        crop: LocalName('Wheat'),
        lots: 2,
        qtlMilli: 10000,
        gross: Money(4000000),
        commission: Money(100000),
      ),
      CommissionRow(
        cropCode: 'paddy',
        crop: LocalName('Paddy'),
        lots: 1,
        qtlMilli: 500,
        gross: Money(1000),
        commission: Money(25),
      ),
    ], 'en');
    expect(t.totals, [
      'Total',
      3,
      10500,
      const Money(4001000),
      const Money(100025),
    ]);
  });
}
