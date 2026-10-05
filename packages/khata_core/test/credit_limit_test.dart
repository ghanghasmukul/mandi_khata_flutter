import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('CreditLimit.excess', () {
    test('a party who owes more than the limit is over by the difference', () {
      // Balance is jama - udhaar: -1,20,000 means the party owes 1,20,000.
      expect(
        CreditLimit.excess(const Money.rupees(-120000), 10000000),
        const Money.rupees(20000),
      );
    });

    test('owing exactly the limit is not over it', () {
      expect(CreditLimit.excess(const Money.rupees(-100000), 10000000), isNull);
    });

    test('a limit of 0 means no limit', () {
      expect(CreditLimit.excess(const Money.rupees(-999999), 0), isNull);
    });

    test('a credit balance (we owe them) is never over the limit', () {
      expect(CreditLimit.excess(const Money.rupees(5000), 10000000), isNull);
      expect(CreditLimit.excess(Money.zero, 10000000), isNull);
    });
  });

  group('CreditLimit.isOver', () {
    test('matches excess', () {
      expect(CreditLimit.isOver(const Money.rupees(-100001), 10000000), isTrue);
      expect(
        CreditLimit.isOver(const Money.rupees(-100000), 10000000),
        isFalse,
      );
    });
  });
}
