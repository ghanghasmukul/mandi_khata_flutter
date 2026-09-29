import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('Money basics', () {
    test('stores whole paise and exposes rupees', () {
      const m = Money(15558050);
      expect(m.paise, 15558050);
      expect(m.rupees, 155580);
      expect(const Money.rupees(250).paise, 25000);
    });

    test('arithmetic stays in integer paise', () {
      const a = Money(110959);
      const b = Money(136616);
      expect((a + b).paise, 247575);
      expect((a - b).paise, -25657);
      expect((-a).paise, -110959);
      expect(const Money(-5).abs(), const Money(5));
    });

    test('comparison and equality', () {
      expect(const Money(100), const Money(100));
      expect(const Money(100).hashCode, const Money(100).hashCode);
      expect(const Money(99) < const Money(100), isTrue);
      expect(const Money(100) >= const Money(100), isTrue);
      expect(const Money(-1).isNegative, isTrue);
      expect(Money.zero.isZero, isTrue);
      expect(const Money(1).isPositive, isTrue);
      final sorted = [const Money(3), const Money(-2), const Money(1)]..sort();
      expect(sorted, [const Money(-2), const Money(1), const Money(3)]);
    });
  });

  group('Money.format (Indian grouping)', () {
    final cases = <int, String>{
      0: '₹0',
      5: '₹0.05',
      100: '₹1',
      99900: '₹999',
      100000: '₹1,000',
      1234500: '₹12,345',
      15558000: '₹1,55,580',
      132800000: '₹13,28,000',
      12000000000: '₹12,00,00,000',
      110959: '₹1,109.59',
      1328: '₹13.28',
      150: '₹1.50',
    };
    for (final MapEntry(key: paise, value: text) in cases.entries) {
      test('$paise paise → $text', () {
        expect(Money(paise).format(), text);
      });
    }

    test('negative amounts put the sign before the symbol', () {
      expect(const Money(-15558000).format(), '-₹1,55,580');
      expect(const Money(-110959).format(), '-₹1,109.59');
    });

    test('paise display modes', () {
      expect(
        const Money(15558000).format(paise: PaiseDisplay.always),
        '₹1,55,580.00',
      );
      // Display rounding is half-up, away from zero.
      expect(const Money(110959).format(paise: PaiseDisplay.never), '₹1,110');
      expect(const Money(110949).format(paise: PaiseDisplay.never), '₹1,109');
      expect(const Money(150).format(paise: PaiseDisplay.never), '₹2');
      expect(const Money(-150).format(paise: PaiseDisplay.never), '-₹2');
    });

    test('symbol can be left out (for table columns)', () {
      expect(const Money(15558000).format(symbol: false), '1,55,580');
      expect(const Money(-100).format(symbol: false), '-1');
    });
  });

  group('Money.short (lakh / crore)', () {
    final cases = <int, String>{
      0: '₹0',
      4560000: '₹45,600',
      // Below one lakh the full rupee amount is shown, paise rounded.
      9999949: '₹99,999',
      // Rounds up to exactly one lakh → switches to the lakh form.
      9999950: '₹1.00 L',
      10000000: '₹1.00 L',
      132800000: '₹13.28 L',
      // 13.285 L rounds half-up to 13.29 L.
      132850000: '₹13.29 L',
      132849999: '₹13.28 L',
      // 99.995 L rounds to 100.00 L, which is shown as crore.
      999950000: '₹1.00 Cr',
      1000000000: '₹1.00 Cr',
      1200000000: '₹1.20 Cr',
      123456789000: '₹123.46 Cr',
      1234567890000: '₹1,234.57 Cr',
    };
    for (final MapEntry(key: paise, value: text) in cases.entries) {
      test('$paise paise → $text', () {
        expect(Money(paise).short(), text);
      });
    }

    test('negative amounts', () {
      expect(const Money(-132800000).short(), '-₹13.28 L');
      expect(const Money(-4560000).short(), '-₹45,600');
    });
  });

  group('Money.tryParse', () {
    final valid = <String, int>{
      '0': 0,
      '1': 100,
      '1234': 123400,
      '1,55,580': 15558000,
      '1,109.59': 110959,
      '₹1,109.59': 110959,
      '₹ 1,109.5': 110950,
      '12.': 1200,
      '.5': 50,
      '0.05': 5,
      ' 250 ': 25000,
      '-40': -4000,
      '-₹40.25': -4025,
      '₹-40.25': -4025,
    };
    for (final MapEntry(key: input, value: paise) in valid.entries) {
      test('"$input" → $paise paise', () {
        expect(Money.tryParse(input), Money(paise));
      });
    }

    final invalid = [
      '',
      '   ',
      '.',
      '₹',
      '-',
      'abc',
      '12a',
      '1.234', // more than two decimals is rejected, never rounded
      '1.2.3',
      '--5',
      '1e5',
      '10000000000000000', // beyond the safe range for web integers
    ];
    for (final input in invalid) {
      test('"$input" is rejected', () {
        expect(Money.tryParse(input), isNull);
      });
    }

    test('round-trips with format()', () {
      for (final p in [0, 5, 1328, 110959, 15558000, -4025]) {
        expect(Money.tryParse(Money(p).format()), Money(p));
      }
    });
  });
}
