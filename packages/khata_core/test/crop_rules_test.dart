import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('CropRules.isValidCode', () {
    test('lowercase identifiers are valid', () {
      for (final c in ['wheat', 'paddy_pr126', 'cotton_narma', 'a1']) {
        expect(CropRules.isValidCode(c), isTrue, reason: c);
      }
    });

    test('anything else is not', () {
      for (final c in [
        '',
        'Wheat',
        '1509',
        '_wheat',
        'paddy-1509',
        'gehun ',
        'x' * 25,
      ]) {
        expect(CropRules.isValidCode(c), isFalse, reason: c);
      }
    });

    test('every valid code is a valid per-crop settings key', () {
      expect(
        SettingsSchema.parse('mandi.commission_pct.paddy_pr126'),
        isNotNull,
      );
    });
  });

  group('CropRules.suggestCode', () {
    test('from an English name', () {
      expect(CropRules.suggestCode('Wheat'), 'wheat');
      expect(CropRules.suggestCode('Paddy PR-126'), 'paddy_pr_126');
      expect(CropRules.suggestCode('  Cotton (Narma) '), 'cotton_narma');
      expect(CropRules.suggestCode('1121 Basmati'), 'basmati');
    });

    test('nothing usable → empty', () {
      expect(CropRules.suggestCode('1509'), '');
      expect(CropRules.suggestCode('गेहूं'), '');
    });

    test('long names are cut to a valid code', () {
      final code = CropRules.suggestCode('a very long crop name that goes on');
      expect(code.length, lessThanOrEqualTo(CropRules.maxCodeLength));
      expect(CropRules.isValidCode(code), isTrue);
      expect(code, 'a_very_long_crop_name_th');
    });

    test('a cut never ends in an underscore', () {
      // 23 letters + space: the cut lands just after the underscore.
      final code = CropRules.suggestCode('${'a' * 23} bcd');
      expect(code, 'a' * 23);
    });
  });
}
