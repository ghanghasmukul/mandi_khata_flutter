import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  const cfg = PriceTiers(
    byRole: {
      PartyRole.farmer: 'farmer',
      PartyRole.vendor: 'vendor',
      PartyRole.customer: 'retail',
      PartyRole.buyer: 'ghost',
    },
  );

  group('PriceTiers.tierFor', () {
    test('walk-in gets the default tier', () {
      expect(cfg.tierFor({}), 'retail');
    });

    test('roles are asked in priority order', () {
      expect(cfg.tierFor({PartyRole.customer, PartyRole.farmer}), 'farmer');
      expect(cfg.tierFor({PartyRole.farmer, PartyRole.vendor}), 'vendor');
      expect(cfg.tierFor({PartyRole.customer}), 'retail');
    });

    test('no mapping, or a tier that no longer exists, falls back', () {
      expect(cfg.tierFor({PartyRole.agency}), 'retail');
      expect(cfg.tierFor({PartyRole.buyer}), 'retail');
    });

    test('default tier missing from the list falls back to the first', () {
      const odd = PriceTiers(tiers: ['a', 'b'], defaultTier: 'zzz');
      expect(odd.tierFor({PartyRole.farmer}), 'a');
    });
  });

  group('TierPrices', () {
    final prices = TierPrices.fromJson(const {
      'farmer': 9000,
      'retail': 10000,
      'wholesale': 8500,
      'bad': -1,
      'text': '5',
    });

    test('json round trip ignores bad entries', () {
      expect(prices.prices.keys, ['farmer', 'retail', 'wholesale']);
      expect(prices.toJson(), {
        'farmer': 9000,
        'retail': 10000,
        'wholesale': 8500,
      });
    });

    test('lookup: direct, then default, retail, first with a price', () {
      final direct = prices.lookup('farmer', cfg)!;
      expect(direct.price, const Money(9000));
      expect(direct.fellBack, isFalse);

      final fb = prices.lookup('vendor', cfg)!;
      expect(fb.price, const Money(10000));
      expect(fb.tier, 'retail');
      expect(fb.fellBack, isTrue);

      final only = TierPrices.fromJson(const {'wholesale': 8500});
      final last = only.lookup('vendor', cfg)!;
      expect(last.tier, 'wholesale');
      expect(const TierPrices({}).lookup('farmer', cfg), isNull);
    });
  });
}
