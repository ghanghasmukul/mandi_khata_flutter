import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

BookLine line(String id, LedgerDate d, int rupees, {String? at}) => BookLine(
  id: id,
  date: d,
  isIn: rupees > 0,
  amount: Money.rupees(rupees.abs()),
  createdAt: at,
);

void main() {
  final d1 = LedgerDate(2027, 4, 1);
  final d2 = LedgerDate(2027, 4, 2);
  final d3 = LedgerDate(2027, 4, 3);
  final d5 = LedgerDate(2027, 4, 5);

  group('CashBook.build', () {
    final lines = [
      line('a', d1, 10000),
      line('b', d2, -2500),
      line('c', d2, 700, at: '2027-04-02T05:00:00Z'),
      line('d', d3, -300),
      line('e', d5, 50),
    ];

    test('worked example: opening, days, closing', () {
      final b = CashBook.build(lines, from: d2, to: d3);
      expect(b.opening, const Money.rupees(10000));
      expect(b.days.map((d) => d.date), [d2, d3]);
      final day2 = b.days.first;
      expect(day2.opening, const Money.rupees(10000));
      expect(day2.receipts, const Money.rupees(700));
      expect(day2.payments, const Money.rupees(2500));
      expect(day2.closing, const Money.rupees(8200));
      expect(b.days.last.opening, const Money.rupees(8200));
      expect(b.days.last.closing, const Money.rupees(7900));
      expect(b.receipts, const Money.rupees(700));
      expect(b.payments, const Money.rupees(2800));
      expect(b.closing, const Money.rupees(7900));
    });

    test('open ends: everything; lines are ordered in a day', () {
      final b = CashBook.build(lines.reversed);
      expect(b.opening, Money.zero);
      expect(b.days, hasLength(4));
      expect(b.closing, const Money.rupees(7950));
      expect(b.days[1].lines.map((l) => l.id), ['b', 'c']);
    });

    test('an empty period keeps the opening as closing', () {
      final b = CashBook.build(
        lines,
        from: LedgerDate(2027, 4, 4),
        to: LedgerDate(2027, 4, 4),
      );
      expect(b.days, isEmpty);
      expect(b.opening, const Money.rupees(7900));
      expect(b.closing, const Money.rupees(7900));
    });

    test('a reversal pair nets to nothing', () {
      final b = CashBook.build([
        line('x', d1, -500),
        BookLine(
          id: 'y',
          date: d1,
          isIn: true,
          amount: const Money.rupees(500),
          reversesId: 'x',
        ),
      ]);
      expect(b.closing, Money.zero);
      expect(b.days.single.receipts, const Money.rupees(500));
    });
  });
}
