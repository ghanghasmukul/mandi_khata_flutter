import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('FinancialYear', () {
    test('April to December belong to the year that starts that April', () {
      final fy = FinancialYear.containing(LedgerDate(2026, 4, 1));
      expect(fy.startYear, 2026);
      expect(
        FinancialYear.containing(LedgerDate(2026, 12, 31)).startYear,
        2026,
      );
    });

    test(
      'January to March belong to the year that started the April before',
      () {
        expect(
          FinancialYear.containing(LedgerDate(2027, 1, 1)).startYear,
          2026,
        );
        expect(
          FinancialYear.containing(LedgerDate(2027, 3, 31)).startYear,
          2026,
        );
      },
    );

    test('runs 1 April to 31 March', () {
      final fy = FinancialYear.containing(LedgerDate(2026, 10, 3));
      expect(fy.start, LedgerDate(2026, 4, 1));
      expect(fy.end, LedgerDate(2027, 3, 31));
    });

    test('contains its first and last day, not the day around them', () {
      const fy = FinancialYear(2026);
      expect(fy.contains(LedgerDate(2026, 3, 31)), isFalse);
      expect(fy.contains(LedgerDate(2026, 4, 1)), isTrue);
      expect(fy.contains(LedgerDate(2027, 3, 31)), isTrue);
      expect(fy.contains(LedgerDate(2027, 4, 1)), isFalse);
    });

    test('label reads 2026-27, also across a century', () {
      expect(const FinancialYear(2026).label, '2026-27');
      expect(const FinancialYear(1999).label, '1999-00');
    });
  });
}
