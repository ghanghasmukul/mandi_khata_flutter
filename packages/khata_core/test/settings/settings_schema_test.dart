import 'package:decimal/decimal.dart';
import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('SettingsSchema.parse', () {
    test('finds plain keys', () {
      final k = SettingsSchema.parse('interest.rate_pa')!;
      expect(k.def.key, 'interest.rate_pa');
      expect(k.suffix, isNull);
      expect(k.full, 'interest.rate_pa');
    });

    test('finds per-crop mandi keys', () {
      final k = SettingsSchema.parse('mandi.commission_pct.wheat')!;
      expect(k.def.key, 'mandi.commission_pct');
      expect(k.suffix, 'wheat');
      expect(k.full, 'mandi.commission_pct.wheat');
    });

    test('suffixes restricted to a list reject anything else', () {
      expect(
        SettingsSchema.parse('shop.default_tier_for_role.farmer'),
        isNotNull,
      );
      expect(SettingsSchema.parse('shop.default_tier_for_role.alien'), isNull);
      expect(SettingsSchema.parse('business.number_series.receipt'), isNotNull);
      expect(SettingsSchema.parse('app.modules.karza'), isNotNull);
    });

    test('unknown or malformed keys are null', () {
      expect(SettingsSchema.parse('interest.nope'), isNull);
      expect(SettingsSchema.parse('interest.rate_pa.wheat'), isNull);
      expect(SettingsSchema.parse('mandi.commission_pct.Wheat'), isNull);
      expect(SettingsSchema.parse('shop.default_tier_for_role'), isNull);
      expect(SettingsSchema.parse(''), isNull);
    });

    test('every v1 key from docs/domain/settings-cascade.md is defined', () {
      for (final key in [
        'interest.enabled',
        'interest.rate_pa',
        'interest.rate_unit_display',
        'interest.method',
        'interest.compounding',
        'interest.day_basis',
        'interest.grace_days',
        'interest.appropriation',
        'interest.apply_on',
        'interest.min_days',
        'interest.rounding',
        'interest.post_frequency',
        'interest.pay_on_jama',
        'interest.pay_rate_pa',
        'mandi.commission_pct',
        'mandi.palledari_per_bag',
        'mandi.bardana_per_bag',
        'mandi.tulai_per_qtl',
        'mandi.mandi_fee_pct',
        'mandi.cess',
        'mandi.charges_borne_by',
        'mandi.bag_weight_kg',
        'shop.price_tiers',
        'shop.allow_negative_stock',
        'shop.expiry_warn_days',
        'shop.gst_enabled',
        'shop.post_credit_sale_to_khata',
        'business.fy_start_month',
        'app.languages',
        'app.default_language',
        'print.receipt_size',
        'notify.whatsapp_receipts',
      ]) {
        expect(SettingsSchema.parse(key), isNotNull, reason: key);
      }
    });

    test('keys are unique and match the database key pattern', () {
      final keys = SettingsSchema.all.map((d) => d.key).toList();
      expect(keys.toSet(), hasLength(keys.length));
      final dbPattern = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$');
      for (final k in keys) {
        expect(dbPattern.hasMatch(k), isTrue, reason: k);
      }
    });
  });

  group('system defaults (docs/domain/settings-cascade.md)', () {
    Object? d(String key) {
      final k = SettingsSchema.parse(key)!;
      return k.def.defaultFor(k.suffix);
    }

    test('interest', () {
      expect(d('interest.enabled'), true);
      expect(d('interest.rate_pa'), '18');
      expect(d('interest.method'), 'simple');
      expect(d('interest.compounding'), 'quarterly');
      expect(d('interest.day_basis'), 365);
      expect(d('interest.appropriation'), 'interest_first');
      expect(d('interest.apply_on'), 'net_udhaar');
      expect(d('interest.rounding'), 'rupee');
      expect(d('interest.pay_rate_pa'), '0');
    });

    test('mandi (money in paise, % as decimal strings)', () {
      expect(d('mandi.commission_pct'), '2.5');
      expect(d('mandi.commission_pct.wheat'), '2.5');
      expect(d('mandi.palledari_per_bag'), 1200);
      expect(d('mandi.bardana_per_bag'), 800);
      expect(d('mandi.tulai_per_qtl'), 300);
      expect(d('mandi.mandi_fee_pct'), '1');
      expect(d('mandi.cess'), isEmpty);
      expect(d('mandi.bag_weight_kg'), '50');
      final borne = d('mandi.charges_borne_by')! as Map<String, Object?>;
      expect(borne.values.toSet(), {'farmer'});
    });

    test('shop, business, app', () {
      expect(d('shop.price_tiers'), [
        'farmer',
        'retail',
        'vendor',
        'wholesale',
      ]);
      expect(d('shop.default_tier_for_role.farmer'), 'farmer');
      expect(d('shop.default_tier_for_role.vendor'), 'vendor');
      expect(d('shop.default_tier_for_role.customer'), 'retail');
      expect(d('shop.expiry_warn_days'), 180);
      expect(d('business.fy_start_month'), 4);
      expect(d('business.number_series.receipt'), {'prefix': 'R-', 'next': 1});
      expect(d('business.number_series.lot'), {'prefix': 'L-', 'next': 1});
      expect(d('app.modules.shop'), true);
      expect(d('app.languages'), ['en', 'hi', 'pa']);
      expect(d('print.receipt_size'), 'a5');
    });

    test('every default passes its own validation', () {
      for (final def in SettingsSchema.all) {
        for (final suffix in [null, ...?def.suffixValues]) {
          expect(
            def.validate(def.defaultFor(suffix)),
            isNull,
            reason: '${def.key} $suffix',
          );
        }
      }
    });
  });

  group('validate', () {
    SettingError? v(String key, Object? value) =>
        SettingsSchema.parse(key)!.def.validate(value);

    test('null means inherit and is always valid', () {
      expect(v('interest.rate_pa', null), isNull);
    });

    test('bool', () {
      expect(v('interest.enabled', false), isNull);
      expect(v('interest.enabled', 'true'), SettingError.wrongType);
    });

    test('percent: decimal string within range; numbers from old rows '
        'accepted', () {
      expect(v('interest.rate_pa', '18'), isNull);
      expect(v('interest.rate_pa', '13.25'), isNull);
      expect(v('interest.rate_pa', 18), isNull);
      expect(v('interest.rate_pa', '-1'), SettingError.tooSmall);
      expect(v('interest.rate_pa', '100.01'), SettingError.tooLarge);
      expect(v('interest.rate_pa', 'abc'), SettingError.wrongType);
      expect(v('mandi.commission_pct', '20.5'), SettingError.tooLarge);
    });

    test('paise: whole numbers only, never fractions', () {
      expect(v('mandi.palledari_per_bag', 1250), isNull);
      expect(v('mandi.palledari_per_bag', 12.5), SettingError.wrongType);
      expect(v('mandi.palledari_per_bag', -1), SettingError.tooSmall);
    });

    test('integer ranges and allowed values', () {
      expect(v('interest.day_basis', 360), isNull);
      expect(v('interest.day_basis', 364), SettingError.notAllowed);
      expect(v('business.fy_start_month', 0), SettingError.tooSmall);
      expect(v('business.fy_start_month', 13), SettingError.tooLarge);
      expect(v('interest.grace_days', 1.5), SettingError.wrongType);
    });

    test('choices', () {
      expect(v('interest.method', 'compound'), isNull);
      expect(v('interest.method', 'magic'), SettingError.notAllowed);
      expect(v('interest.method', 1), SettingError.wrongType);
    });

    test('structured values', () {
      expect(
        v('mandi.cess', [
          {'name': 'RDF', 'pct': '2'},
        ]),
        isNull,
      );
      expect(
        v('mandi.cess', [
          {'name': 'RDF', 'pct': 'x'},
        ]),
        SettingError.invalid,
      );
      expect(v('mandi.charges_borne_by', {'commission': 'buyer'}), isNull);
      expect(
        v('mandi.charges_borne_by', {'commission': 'nobody'}),
        SettingError.invalid,
      );
      expect(v('shop.price_tiers', <String>[]), SettingError.invalid);
      expect(v('app.languages', ['en', 'ta']), SettingError.invalid);
      expect(
        v('business.number_series.receipt', {'prefix': 'RC-', 'next': 5}),
        isNull,
      );
      expect(
        v('business.number_series.receipt', {'prefix': '', 'next': 0}),
        SettingError.invalid,
      );
    });
  });

  group('where a key may be set', () {
    test('interest and mandi keys at every level', () {
      final def = SettingsSchema.parse('interest.rate_pa')!.def;
      for (final scope in SettingScope.values) {
        expect(def.allowedAt(scope), isTrue, reason: '$scope');
      }
      expect(
        SettingsSchema.parse(
          'mandi.commission_pct.wheat',
        )!.def.allowedAt(SettingScope.lot),
        isTrue,
      );
    });

    test('shop, business, app, print, notify only for the business', () {
      for (final key in [
        'shop.gst_enabled',
        'business.fy_start_month',
        'app.default_language',
        'print.receipt_size',
        'notify.whatsapp_receipts',
      ]) {
        final def = SettingsSchema.parse(key)!.def;
        expect(def.allowedAt(SettingScope.tenant), isTrue, reason: key);
        expect(def.allowedAt(SettingScope.party), isFalse, reason: key);
      }
    });
  });

  group('interest rate units', () {
    test('₹ per 100 per month ↔ % per annum', () {
      expect(
        InterestRate.paFromPer100PerMonth(Decimal.parse('1.5')),
        Decimal.fromInt(18),
      );
      expect(
        InterestRate.paFromPer100PerMonth(Decimal.parse('1.25')),
        Decimal.fromInt(15),
      );
      expect(
        InterestRate.per100PerMonthFromPa(Decimal.fromInt(18)),
        Decimal.parse('1.5'),
      );
      // 20 / 12 = 1.6666… shown to 4 places.
      expect(
        InterestRate.per100PerMonthFromPa(Decimal.fromInt(20)),
        Decimal.parse('1.6667'),
      );
    });
  });

  test('decimalOf reads strings and numbers exactly', () {
    expect(SettingsSchema.decimalOf('2.5'), Decimal.parse('2.5'));
    expect(SettingsSchema.decimalOf(2.5), Decimal.parse('2.5'));
    expect(SettingsSchema.decimalOf(18), Decimal.fromInt(18));
    expect(SettingsSchema.decimalOf('x'), isNull);
    expect(SettingsSchema.decimalOf(null), isNull);
  });
}
