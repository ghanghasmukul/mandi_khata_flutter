import 'package:decimal/decimal.dart';
import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

Decimal d(String s) => Decimal.parse(s);

/// The system defaults from docs/domain/settings-cascade.md.
final defaults = MandiConfig.resolve(SettingsResolver(const []));

SettingRow tenant(String key, Object? value) =>
    SettingRow(scope: SettingScope.tenant, key: key, value: value);

void main() {
  group('worked example: Wheat, 18 bags, 8.64 qtl @ ₹2,425 (defaults)', () {
    final b = MandiCharges.calculate(
      const LotInput(bags: 18, qtlMilli: 8640, rate: Money.rupees(2425)),
      defaults,
    );

    // gross      = 8.64 × 2,425            = ₹20,952.00
    // commission = 2.5% of 20,952          = ₹523.80
    // palledari  = 18 × ₹12                = ₹216.00
    // bardana    = 18 × ₹8                 = ₹144.00
    // tulai      = 8.64 × ₹3               = ₹25.92
    // mandi fee  = 1% of 20,952            = ₹209.52
    // deductions (all borne by farmer)     = ₹1,119.24
    // net to farmer = 20,952 − 1,119.24    = ₹19,832.76
    test('gross', () => expect(b.gross, const Money(2095200)));

    test('each line, in order, all borne by the farmer', () {
      expect(
        [for (final l in b.lines) (l.charge, l.amount.paise, l.payer)],
        [
          (MandiCharge.commission, 52380, ChargePayer.farmer),
          (MandiCharge.palledari, 21600, ChargePayer.farmer),
          (MandiCharge.bardana, 14400, ChargePayer.farmer),
          (MandiCharge.tulai, 2592, ChargePayer.farmer),
          (MandiCharge.mandiFee, 20952, ChargePayer.farmer),
        ],
      );
    });

    test('totals', () {
      expect(b.farmerDeductions, const Money(111924));
      expect(b.netToFarmer, const Money(1983276));
      expect(b.netToFarmer.format(), '₹19,832.76');
      expect(b.buyerCharges, Money.zero);
      expect(b.buyerTotal, b.gross);
      expect(b.arhtiyaCharges, Money.zero);
      expect(b.commission, const Money(52380));
      expect(b.commissionEarned, const Money(52380));
    });
  });

  group('worked example: Paddy PR-126 with cess and split payers', () {
    // 40 bags, 15.375 qtl @ ₹2,369; business sets for paddy: commission
    // 2.5%, mandi fee 2% and RDF 2% + cess 1.5%, all paid by the buyer;
    // labour (palledari, tulai) by the buyer too; bardana by the arhtiya.
    final r = SettingsResolver([
      tenant('mandi.mandi_fee_pct.paddy_pr126', '2'),
      tenant('mandi.cess.paddy_pr126', [
        {'name': 'RDF', 'pct': '2'},
        {'name': 'Cess', 'pct': '1.5'},
      ]),
      tenant('mandi.charges_borne_by.paddy_pr126', {
        'commission': 'buyer',
        'palledari': 'buyer',
        'bardana': 'arhtiya',
        'tulai': 'buyer',
        'mandi_fee': 'buyer',
        'cess': 'buyer',
      }),
    ]);
    final config = MandiConfig.resolve(r, cropCode: 'paddy_pr126');
    final b = MandiCharges.calculate(
      const LotInput(bags: 40, qtlMilli: 15375, rate: Money.rupees(2369)),
      config,
    );

    // gross      = 15.375 × 2,369 = 36,423.375 → ₹36,423.38 (half-up)
    // commission = 2.5% × 36,423.38 = 910.5845 → ₹910.58
    // palledari  = 40 × ₹12 = ₹480
    // bardana    = 40 × ₹8  = ₹320 (arhtiya)
    // tulai      = 15.375 × ₹3 = 46.125 → ₹46.13
    // mandi fee  = 2% → 728.4676 → ₹728.47
    // RDF        = 2% → ₹728.47
    // Cess       = 1.5% → 546.3507 → ₹546.35
    test('lines', () {
      expect(b.gross, const Money(3642338));
      expect(
        [for (final l in b.lines) (l.charge, l.name, l.amount.paise, l.payer)],
        [
          (MandiCharge.commission, null, 91058, ChargePayer.buyer),
          (MandiCharge.palledari, null, 48000, ChargePayer.buyer),
          (MandiCharge.bardana, null, 32000, ChargePayer.arhtiya),
          (MandiCharge.tulai, null, 4613, ChargePayer.buyer),
          (MandiCharge.mandiFee, null, 72847, ChargePayer.buyer),
          (MandiCharge.cess, 'RDF', 72847, ChargePayer.buyer),
          (MandiCharge.cess, 'Cess', 54635, ChargePayer.buyer),
        ],
      );
    });

    test('farmer gets the full gross; the buyer pays gross + charges', () {
      expect(b.farmerDeductions, Money.zero);
      expect(b.netToFarmer, b.gross);
      // 91058 + 48000 + 4613 + 72847 + 72847 + 54635
      expect(b.buyerCharges, const Money(344000));
      expect(b.buyerTotal, const Money(3642338 + 344000));
      expect(b.arhtiyaCharges, const Money(32000));
      expect(b.commissionEarned, const Money(91058));
    });

    test('other crops still use the business / system defaults', () {
      final wheat = MandiConfig.resolve(r, cropCode: 'wheat');
      expect(wheat.mandiFeePct, d('1'));
      expect(wheat.cess, isEmpty);
      expect(wheat.payerOf(MandiCharge.bardana), ChargePayer.farmer);
    });
  });

  group('cascade inside MandiConfig.resolve', () {
    test('lot beats party beats business crop beats business', () {
      final r = SettingsResolver([
        tenant('mandi.commission_pct', '2'),
        tenant('mandi.commission_pct.wheat', '2.25'),
        const SettingRow(
          scope: SettingScope.party,
          scopeId: 'ram',
          key: 'mandi.commission_pct',
          value: '1.75',
        ),
        const SettingRow(
          scope: SettingScope.lot,
          scopeId: 'lot-1',
          key: 'mandi.commission_pct.wheat',
          value: '1.5',
        ),
      ]);
      expect(MandiConfig.resolve(r).commissionPct, d('2'));
      expect(
        MandiConfig.resolve(r, cropCode: 'wheat').commissionPct,
        d('2.25'),
      );
      expect(
        MandiConfig.resolve(r, cropCode: 'wheat', partyId: 'ram').commissionPct,
        d('1.75'),
      );
      expect(
        MandiConfig.resolve(
          r,
          cropCode: 'wheat',
          partyId: 'ram',
          lotId: 'lot-1',
        ).commissionPct,
        d('1.5'),
      );
    });

    test('a partial charges_borne_by map falls back to farmer', () {
      final r = SettingsResolver([
        tenant('mandi.charges_borne_by', {'mandi_fee': 'buyer'}),
      ]);
      final c = MandiConfig.resolve(r);
      expect(c.payerOf(MandiCharge.mandiFee), ChargePayer.buyer);
      expect(c.payerOf(MandiCharge.commission), ChargePayer.farmer);
    });

    test('defaults match the settings schema', () {
      expect(defaults.commissionPct, d('2.5'));
      expect(defaults.palledariPerBag, const Money(1200));
      expect(defaults.bardanaPerBag, const Money(800));
      expect(defaults.tulaiPerQtl, const Money(300));
      expect(defaults.mandiFeePct, d('1'));
      expect(defaults.bagWeightKg, d('50'));
      expect(defaults.cess, isEmpty);
      for (final c in MandiCharge.values) {
        expect(defaults.payerOf(c), ChargePayer.farmer);
      }
    });
  });

  group('rounding', () {
    test('gross rounds half-up to the paisa', () {
      // 0.001 qtl × ₹0.05 = 0.00005 → 0; 0.01 qtl × ₹0.50 = ₹0.005 → 1 paisa
      MandiBreakdown calc(int milli, int ratePaise) => MandiCharges.calculate(
        LotInput(bags: 0, qtlMilli: milli, rate: Money(ratePaise)),
        defaults,
      );
      expect(calc(1, 5).gross, Money.zero);
      expect(calc(10, 50).gross, const Money(1));
      expect(calc(10, 49).gross, Money.zero);
    });

    test('each percentage line is rounded on its own', () {
      // gross ₹1.00: 2.5% = 2.5 paise → 3, 1% = 1 paisa
      final b = MandiCharges.calculate(
        const LotInput(bags: 0, qtlMilli: 1000, rate: Money(100)),
        defaults,
      );
      expect(b.commission, const Money(3));
      expect(
        b.lines.singleWhere((l) => l.charge == MandiCharge.mandiFee).amount,
        const Money(1),
      );
    });

    test('zero charges are still listed (the breakdown shows every line)', () {
      final b = MandiCharges.calculate(
        const LotInput(bags: 0, qtlMilli: 0, rate: Money.zero),
        defaults,
      );
      expect(b.lines, hasLength(5));
      expect(b.netToFarmer, Money.zero);
    });

    test('a large lot stays exact', () {
      // 9,999.999 qtl @ ₹99,999.99 — beyond any real lot, still exact.
      final b = MandiCharges.calculate(
        const LotInput(bags: 20000, qtlMilli: 9999999, rate: Money(9999999)),
        defaults,
      );
      // 9999999 × 9999999 / 1000 = 99999980000.001 → 99999980000
      expect(b.gross, const Money(99999980000));
    });
  });

  group('input checks', () {
    test('negative inputs are rejected', () {
      expect(
        () => MandiCharges.calculate(
          const LotInput(bags: -1, qtlMilli: 0, rate: Money.zero),
          defaults,
        ),
        throwsArgumentError,
      );
      expect(
        () => MandiCharges.calculate(
          const LotInput(bags: 0, qtlMilli: -1, rate: Money.zero),
          defaults,
        ),
        throwsArgumentError,
      );
      expect(
        () => MandiCharges.calculate(
          const LotInput(bags: 0, qtlMilli: 0, rate: Money(-1)),
          defaults,
        ),
        throwsArgumentError,
      );
    });
  });

  group('commission borne by the arhtiya = waived', () {
    final r = SettingsResolver([
      tenant('mandi.charges_borne_by', {'commission': 'arhtiya'}),
    ]);
    final b = MandiCharges.calculate(
      const LotInput(bags: 10, qtlMilli: 5000, rate: Money.rupees(2000)),
      MandiConfig.resolve(r),
    );

    test('it is shown but neither deducted, charged nor earned', () {
      expect(b.commission, const Money(25000));
      expect(b.commissionEarned, Money.zero);
      expect(b.arhtiyaCharges, Money.zero);
      // gross 10,000; farmer pays palledari 120 + bardana 80 + tulai 15 +
      // mandi fee 100
      expect(b.farmerDeductions, const Money(31500));
      expect(b.netToFarmer, const Money(1000000 - 31500));
    });
  });

  group('qtl from bags × bag weight', () {
    test('18 bags × 50 kg = 9 qtl', () {
      expect(MandiCharges.qtlMilliFromBags(18, d('50')), 9000);
    });

    test('bag weight with a fraction, rounded to 0.1 kg', () {
      // 37 bags × 37.5 kg = 1,387.5 kg = 13.875 qtl
      expect(MandiCharges.qtlMilliFromBags(37, d('37.5')), 13875);
      // 3 bags × 33.33 kg = 99.99 kg → 999.9 → 1000 (half-up)
      expect(MandiCharges.qtlMilliFromBags(3, d('33.33')), 1000);
    });

    test('negative input is rejected', () {
      expect(
        () => MandiCharges.qtlMilliFromBags(-1, d('50')),
        throwsArgumentError,
      );
      expect(
        () => MandiCharges.qtlMilliFromBags(1, d('-50')),
        throwsArgumentError,
      );
    });
  });

  group('snapshot JSON (stored in lots.charges_snapshot)', () {
    final r = SettingsResolver([
      tenant('mandi.cess', [
        {'name': 'RDF', 'pct': '2'},
      ]),
      tenant('mandi.charges_borne_by', {'mandi_fee': 'buyer'}),
      tenant('mandi.bag_weight_kg', '37.5'),
    ]);
    final config = MandiConfig.resolve(r);

    test('round-trips exactly', () {
      final json = config.toJson();
      expect(json, {
        'commission_pct': '2.5',
        'palledari_per_bag': 1200,
        'bardana_per_bag': 800,
        'tulai_per_qtl': 300,
        'mandi_fee_pct': '1',
        'cess': [
          {'name': 'RDF', 'pct': '2'},
        ],
        'charges_borne_by': {
          'commission': 'farmer',
          'palledari': 'farmer',
          'bardana': 'farmer',
          'tulai': 'farmer',
          'mandi_fee': 'buyer',
          'cess': 'farmer',
        },
        'bag_weight_kg': '37.5',
      });
      expect(MandiConfig.fromJson(json), config);
      expect(MandiConfig.fromJson(json).hashCode, config.hashCode);
    });

    test('a broken snapshot is a FormatException', () {
      expect(
        () => MandiConfig.fromJson(const {'commission_pct': 'x'}),
        throwsFormatException,
      );
      final bad = config.toJson()..['charges_borne_by'] = {'cess': 'nobody'};
      expect(() => MandiConfig.fromJson(bad), throwsFormatException);
      final badCess = config.toJson()
        ..['cess'] = [
          {'name': '', 'pct': '1'},
        ];
      expect(() => MandiConfig.fromJson(badCess), throwsFormatException);
      for (final (key, value) in [
        ('commission_pct', 'x'),
        ('commission_pct', '25'), // above the schema's 20% limit
        ('bag_weight_kg', null),
        ('palledari_per_bag', -1),
        ('tulai_per_qtl', '300'),
      ]) {
        final broken = config.toJson()..[key] = value;
        expect(
          () => MandiConfig.fromJson(broken),
          throwsFormatException,
          reason: '$key = $value',
        );
      }
    });
  });

  group('names', () {
    test('charge names match the settings schema', () {
      expect([
        for (final c in MandiCharge.values) c.key,
      ], SettingsSchema.chargeNames);
      expect([
        for (final p in ChargePayer.values) p.name,
      ], SettingsSchema.chargePayers);
      expect(MandiCharge.parse('mandi_fee'), MandiCharge.mandiFee);
      expect(MandiCharge.parse('nope'), isNull);
      expect(ChargePayer.parse('buyer'), ChargePayer.buyer);
      expect(ChargePayer.parse('nope'), isNull);
    });
  });
}
