import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

/// The system defaults from docs/domain/settings-cascade.md: commission
/// 2.5%, palledari ₹12/bag, bardana ₹8/bag, tulai ₹3/qtl, mandi fee 1%,
/// everything paid by the farmer.
final defaults = MandiConfig.resolve(SettingsResolver(const []));

SettingRow tenant(String key, Object? value) =>
    SettingRow(scope: SettingScope.tenant, key: key, value: value);

const farmer = 'farmer-1';
const buyer = 'buyer-1';

void main() {
  group('Quintals', () {
    test('parses to thousandths of a quintal', () {
      expect(Quintals.parseMilli('8.64'), 8640);
      expect(Quintals.parseMilli('12'), 12000);
      expect(Quintals.parseMilli('15.375'), 15375);
      expect(Quintals.parseMilli('.5'), 500);
      expect(Quintals.parseMilli('7.'), 7000);
      expect(Quintals.parseMilli(' 1,234.5 '), 1234500);
      expect(Quintals.parseMilli('0'), 0);
    });

    test('rejects empty, malformed and over-precise input', () {
      for (final bad in ['', '.', 'abc', '8.6401', '-2', '1.2.3', '1234567']) {
        expect(Quintals.parseMilli(bad), isNull, reason: bad);
      }
    });

    test('formats with two decimals, three when needed', () {
      expect(Quintals.format(8640), '8.64');
      expect(Quintals.format(8000), '8.00');
      expect(Quintals.format(15375), '15.375');
      expect(Quintals.format(500), '0.50');
      expect(Quintals.format(0), '0.00');
      expect(Quintals.format(-1250), '-1.25');
    });

    test('format and parse round-trip', () {
      for (final v in [1, 10, 999, 8640, 15375, 123456789]) {
        expect(Quintals.parseMilli(Quintals.format(v)), v);
      }
    });
  });

  group('LotStatus', () {
    test('parses database values', () {
      for (final s in LotStatus.values) {
        expect(LotStatus.parse(s.name), s);
      }
      expect(() => LotStatus.parse('sold_out'), throwsFormatException);
    });

    test('draft status follows what is filled in', () {
      expect(LotStatus.draftFor(), LotStatus.arrived);
      expect(
        LotStatus.draftFor(rate: const Money.rupees(2425)),
        LotStatus.arrived,
        reason: 'a rate without a weight is still only an arrival',
      );
      expect(LotStatus.draftFor(qtlMilli: 8640), LotStatus.weighed);
      expect(
        LotStatus.draftFor(qtlMilli: 8640, rate: const Money.rupees(2425)),
        LotStatus.sold,
      );
    });

    test('open lots move freely, posted only to reversed, reversed never', () {
      const s = LotStatus.values;
      final allowed = {
        for (final from in s)
          for (final to in s)
            if (from.canMoveTo(to)) '${from.name}>${to.name}',
      };
      expect(allowed, {
        for (final from in ['arrived', 'weighed', 'sold'])
          for (final to in s) '$from>${to.name}',
        'posted>reversed',
      });
      expect(LotStatus.posted.isOpen, isFalse);
      expect(LotStatus.reversed.isOpen, isFalse);
      expect(LotStatus.sold.isOpen, isTrue);
    });
  });

  group('validate', () {
    test('a plain arrival is fine', () {
      expect(LotRules.validate(farmerId: farmer, bags: 18), isEmpty);
      expect(
        LotRules.validate(farmerId: farmer, bags: 0),
        isEmpty,
        reason: 'loose crop (khulla) has no bags',
      );
    });

    test('reports every problem', () {
      expect(
        LotRules.validate(
          farmerId: farmer,
          bags: -1,
          qtlMilli: 0,
          rate: Money.zero,
          buyerId: farmer,
        ),
        {
          LotProblem.bagsNegative,
          LotProblem.weightNotPositive,
          LotProblem.rateNotPositive,
          LotProblem.buyerIsFarmer,
        },
      );
    });
  });

  test('posting lines are values', () {
    const a = LotPostingLine(
      partyId: farmer,
      side: Side.jama,
      amount: Money(5),
    );
    const b = LotPostingLine(
      partyId: farmer,
      side: Side.jama,
      amount: Money(5),
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a.toString(), contains('jama'));
  });

  group('planPosting', () {
    test('worked example: Wheat 18 bags 8.64 qtl @ ₹2,425, no buyer', () {
      // net to farmer ₹19,832.76 (see mandi_charges_test.dart).
      final r = LotRules.planPosting(
        farmerId: farmer,
        bags: 18,
        qtlMilli: 8640,
        rate: const Money.rupees(2425),
        config: defaults,
      );
      expect(r.problems, isEmpty);
      expect(
        r.plan!.farmer,
        const LotPostingLine(
          partyId: farmer,
          side: Side.jama,
          amount: Money(1983276),
        ),
      );
      expect(r.plan!.buyer, isNull);
      expect(r.plan!.lines, [r.plan!.farmer]);
      expect(r.plan!.breakdown.gross, const Money(2095200));
    });

    test('with a buyer: udhaar of the gross when the farmer pays all', () {
      final r = LotRules.planPosting(
        farmerId: farmer,
        buyerId: buyer,
        bags: 18,
        qtlMilli: 8640,
        rate: const Money.rupees(2425),
        config: defaults,
      );
      expect(r.plan!.lines, [
        const LotPostingLine(
          partyId: farmer,
          side: Side.jama,
          amount: Money(1983276),
        ),
        const LotPostingLine(
          partyId: buyer,
          side: Side.udhaar,
          amount: Money(2095200),
        ),
      ]);
    });

    group('buyer pays mandi fee and labour (Paddy PR-126, 40 bags)', () {
      // 15.375 qtl @ ₹2,369 → gross ₹36,423.38. Buyer pays palledari ₹480,
      // tulai ₹46.13, mandi fee 1% ₹364.23 = ₹890.36. Farmer pays
      // commission 2.5% ₹910.58 + bardana ₹320 = ₹1,230.58.
      final config = MandiConfig.resolve(
        SettingsResolver([
          tenant('mandi.charges_borne_by', {
            'commission': 'farmer',
            'palledari': 'buyer',
            'bardana': 'farmer',
            'tulai': 'buyer',
            'mandi_fee': 'buyer',
            'cess': 'farmer',
          }),
        ]),
      );

      test('posts net to the farmer and gross + charges to the buyer', () {
        final r = LotRules.planPosting(
          farmerId: farmer,
          buyerId: buyer,
          bags: 40,
          qtlMilli: 15375,
          rate: const Money.rupees(2369),
          config: config,
        );
        expect(r.problems, isEmpty);
        expect(r.plan!.breakdown.buyerCharges, const Money(89036));
        expect(r.plan!.lines, [
          const LotPostingLine(
            partyId: farmer,
            side: Side.jama,
            amount: Money(3642338 - 123058),
          ),
          const LotPostingLine(
            partyId: buyer,
            side: Side.udhaar,
            amount: Money(3642338 + 89036),
          ),
        ]);
      });

      test('needs a buyer to bill', () {
        final r = LotRules.planPosting(
          farmerId: farmer,
          bags: 40,
          qtlMilli: 15375,
          rate: const Money.rupees(2369),
          config: config,
        );
        expect(r.plan, isNull);
        expect(r.problems, {LotProblem.buyerRequired});
      });
    });

    test('buyer-borne charges of zero do not need a buyer', () {
      final config = MandiConfig.resolve(
        SettingsResolver([
          tenant('mandi.mandi_fee_pct', '0'),
          tenant('mandi.charges_borne_by', {'mandi_fee': 'buyer'}),
        ]),
      );
      final r = LotRules.planPosting(
        farmerId: farmer,
        bags: 18,
        qtlMilli: 8640,
        rate: const Money.rupees(2425),
        config: config,
      );
      expect(r.problems, isEmpty);
    });

    test('waived commission is neither deducted nor billed', () {
      final config = MandiConfig.resolve(
        SettingsResolver([
          tenant('mandi.charges_borne_by', {'commission': 'arhtiya'}),
        ]),
      );
      final r = LotRules.planPosting(
        farmerId: farmer,
        buyerId: buyer,
        bags: 18,
        qtlMilli: 8640,
        rate: const Money.rupees(2425),
        config: config,
      );
      // 19,832.76 + 523.80 commission not deducted.
      expect(r.plan!.farmer.amount, const Money(1983276 + 52380));
      expect(r.plan!.buyer!.amount, const Money(2095200));
    });

    test('needs weight and rate', () {
      final r = LotRules.planPosting(
        farmerId: farmer,
        bags: 18,
        qtlMilli: null,
        rate: null,
        config: defaults,
      );
      expect(r.problems, {LotProblem.noWeight, LotProblem.noRate});
    });

    test('carries validation problems', () {
      final r = LotRules.planPosting(
        farmerId: farmer,
        buyerId: farmer,
        bags: 18,
        qtlMilli: 8640,
        rate: const Money.rupees(2425),
        config: defaults,
      );
      expect(r.problems, {LotProblem.buyerIsFarmer});
    });

    test('refuses a lot whose charges eat the whole sale', () {
      // 1 bag, 0.01 qtl @ ₹1: gross ₹0.01, palledari alone ₹12.
      final r = LotRules.planPosting(
        farmerId: farmer,
        bags: 1,
        qtlMilli: 10,
        rate: const Money.rupees(1),
        config: defaults,
      );
      expect(r.problems, {LotProblem.netNotPositive});
    });
  });
}
