import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  Object? d(String key) {
    final k = SettingsSchema.parse(key)!;
    return k.def.defaultFor(k.suffix);
  }

  SettingError? check(String key, Object? value) =>
      SettingsSchema.parse(key)!.def.validate(value);

  test('phase 4 defaults (docs/domain/shop-rules.md section 8)', () {
    expect(d('shop.prices_include_gst'), true);
    expect(d('shop.default_tier'), 'retail');
    expect(d('shop.block_expired'), true);
    expect(d('shop.allow_negative_stock'), false);
    expect(d('shop.expiry_warn_days'), 60);
    expect(d('shop.supplier_credit_days'), 30);
    expect(d('shop.round_invoice_to_rupee'), true);
    expect(d('shop.default_gst_rate'), '5');
    expect(d('business.gstin'), '');
    expect(d('business.state_code'), '');
    expect(d('business.number_series.sales_return'), {
      'prefix': 'SR-',
      'next': 1,
    });
    expect(d('business.number_series.purchase_bill'), {
      'prefix': 'PB-',
      'next': 1,
    });
    expect(d('business.number_series.purchase_return'), {
      'prefix': 'PR-',
      'next': 1,
    });
  });

  test('validation', () {
    expect(check('shop.default_gst_rate', '18'), isNull);
    expect(check('shop.default_gst_rate', '7'), SettingError.notAllowed);
    expect(check('shop.supplier_credit_days', 400), SettingError.tooLarge);
    expect(check('shop.default_tier', 'Wholesale!'), SettingError.invalid);
    expect(check('shop.default_tier', 'wholesale'), isNull);
    expect(check('business.state_code', '03'), isNull);
    expect(check('business.state_code', ''), isNull);
    expect(check('business.state_code', '25'), SettingError.invalid);
    expect(check('business.gstin', ''), isNull);
    expect(check('business.gstin', '27AAPFU0939F1ZV'), isNull);
    expect(check('business.gstin', '27AAPFU0939F1ZX'), SettingError.invalid);
    expect(check('business.gstin', 5), SettingError.invalid);
  });

  test('document series for the shop', () {
    expect(DocumentSeries.salesReturn.code, 'SR');
    expect(DocumentSeries.purchaseBill.code, 'PB');
    expect(
      DocumentSeries.purchaseReturn.settingKey,
      'business.number_series.purchase_return',
    );
    for (final s in DocumentSeries.values) {
      expect(SettingsSchema.parse(s.settingKey), isNotNull, reason: s.doc);
    }
  });
}
