import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('Ageing', () {
    test('buckets are 0–30, 31–90, 91–180 and 180+ days', () {
      expect(AgeingBucket.forDays(0), AgeingBucket.upTo30);
      expect(AgeingBucket.forDays(30), AgeingBucket.upTo30);
      expect(AgeingBucket.forDays(31), AgeingBucket.upTo90);
      expect(AgeingBucket.forDays(90), AgeingBucket.upTo90);
      expect(AgeingBucket.forDays(91), AgeingBucket.upTo180);
      expect(AgeingBucket.forDays(180), AgeingBucket.upTo180);
      expect(AgeingBucket.forDays(181), AgeingBucket.over180);
      expect(AgeingBucket.forDays(2000), AgeingBucket.over180);
    });

    test('an entry dated after the as-of day is not older than today', () {
      expect(AgeingBucket.forDays(-5), AgeingBucket.upTo30);
    });

    test('days are counted from the last entry to the as-of day', () {
      expect(
        Ageing.daysSince(LedgerDate(2026, 8, 1), LedgerDate(2026, 10, 3)),
        63,
      );
      expect(
        Ageing.bucketOf(LedgerDate(2026, 3, 31), LedgerDate(2026, 10, 3)),
        AgeingBucket.over180,
      );
    });
  });

  group('ReportTable.csv', () {
    const table = ReportTable(
      columns: [
        ReportColumn('Party', ReportColumnKind.text),
        ReportColumn('Date', ReportColumnKind.date),
        ReportColumn('Amount', ReportColumnKind.money),
        ReportColumn('Qtl', ReportColumnKind.number),
      ],
      rows: [
        ['Ram, "Lal"', null, Money(155580), 12],
        ['Sita\nDevi', null, Money(-4005), 0],
      ],
    );

    test('quotes commas, quotes and newlines; money is rupees with paise', () {
      expect(
        table.toCsv(),
        'Party,Date,Amount,Qtl\r\n'
        '"Ram, ""Lal""",,1555.80,12\r\n'
        '"Sita\nDevi",,-40.05,0\r\n',
      );
    });

    test('a date is written as yyyy-mm-dd', () {
      final t = ReportTable(
        columns: const [ReportColumn('Date', ReportColumnKind.date)],
        rows: [
          [LedgerDate(2026, 4, 1)],
        ],
      );
      expect(t.toCsv(), 'Date\r\n2026-04-01\r\n');
    });

    test('a totals row is appended', () {
      const t = ReportTable(
        columns: [
          ReportColumn('Name', ReportColumnKind.text),
          ReportColumn('Amount', ReportColumnKind.money),
        ],
        rows: [
          ['A', Money(100)],
        ],
        totals: ['Total', Money(100)],
      );
      expect(t.toCsv(), 'Name,Amount\r\nA,1.00\r\nTotal,1.00\r\n');
    });
  });

  test('a weight is written in quintals', () {
    const t = ReportTable(
      columns: [ReportColumn('Qtl', ReportColumnKind.quantity)],
      rows: [
        [8640],
        [15375],
      ],
    );
    expect(t.toCsv(), 'Qtl\r\n8.64\r\n15.375\r\n');
  });

  test('Money.plain has no symbol, grouping or rounding', () {
    expect(const Money(12345678).plainRupees, '123456.78');
    expect(const Money(5).plainRupees, '0.05');
    expect(const Money(-5).plainRupees, '-0.05');
    expect(Money.zero.plainRupees, '0.00');
  });
}
