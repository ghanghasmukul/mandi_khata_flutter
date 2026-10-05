import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

import 'interest/helpers.dart';

void main() {
  final inherited = cfg();

  test('an untouched editor changes nothing', () {
    final diff = PartyInterestOverrides.diff(
      inherited: inherited,
      edited: PartyInterestOverrides.forEditing(inherited),
    );
    expect(diff.values.every((v) => v == null), isTrue);
  });

  test(
    'only what differs from the inherited value is set; the rest resets',
    () {
      final diff = PartyInterestOverrides.diff(
        inherited: inherited,
        edited: inherited.copyWith(
          ratePa: cfg(rate: '24').ratePa,
          graceDays: 15,
        ),
      );
      expect(diff['interest.rate_pa'], '24');
      expect(diff['interest.grace_days'], 15);
      expect(diff['interest.method'], isNull);
      expect(diff.containsKey('interest.method'), isTrue);
    },
  );

  test('values are stored in the settings formats', () {
    final diff = PartyInterestOverrides.diff(
      inherited: inherited,
      edited: inherited.copyWith(
        method: InterestMethod.compound,
        compounding: CompoundingPeriod.onFyClose,
        appropriation: Appropriation.principalFirst,
        dayBasis: 360,
        minDays: 3,
        rounding: InterestRounding.tenRupee,
      ),
    );
    expect(diff['interest.method'], 'compound');
    expect(diff['interest.compounding'], 'on_fy_close');
    expect(diff['interest.appropriation'], 'principal_first');
    expect(diff['interest.day_basis'], 360);
    expect(diff['interest.min_days'], 3);
    expect(diff['interest.rounding'], 'ten_rupee');
  });

  test('"no interest for this party" sets only interest.enabled', () {
    final diff = PartyInterestOverrides.diff(
      inherited: inherited,
      edited: inherited.copyWith(enabled: false),
    );
    expect(diff, {'interest.enabled': false});
  });

  test(
    'a supplier (apply_on none) shows as off; switching on asks for khata',
    () {
      final supplier = cfg(applyOn: ApplyOn.none);
      final shown = PartyInterestOverrides.forEditing(supplier);
      expect(shown.enabled, isFalse);

      final off = PartyInterestOverrides.diff(
        inherited: supplier,
        edited: shown,
      );
      expect(off.values.every((v) => v == null), isTrue);

      final on = PartyInterestOverrides.diff(
        inherited: supplier,
        edited: shown.copyWith(enabled: true),
      );
      expect(on['interest.enabled'], isTrue);
      expect(on['interest.apply_on'], 'net_udhaar');
    },
  );
  test('explicit writes every value, or only "off"', () {
    final all = PartyInterestOverrides.explicit(cfg(rate: '24'));
    expect(all['interest.rate_pa'], '24');
    expect(all['interest.apply_on'], 'net_udhaar');
    expect(all.values.every((v) => v != null), isTrue);
    expect(PartyInterestOverrides.explicit(cfg(enabled: false)), {
      'interest.enabled': false,
    });
  });
}
