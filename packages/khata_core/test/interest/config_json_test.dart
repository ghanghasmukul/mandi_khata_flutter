import 'package:decimal/decimal.dart';
import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// A loan stores its interest terms as a JSON snapshot (settings-cascade
/// "snapshot rule"), so the config must survive the round trip exactly.
void main() {
  test('toJson uses stable keys and exact decimal strings', () {
    final json = cfg(
      rate: '18.5',
      method: InterestMethod.compound,
      compounding: CompoundingPeriod.onFyClose,
      dayBasis: 360,
      graceDays: 7,
      appropriation: Appropriation.principalFirst,
      applyOn: ApplyOn.loansOnly,
      minDays: 3,
      rounding: InterestRounding.tenRupee,
      payOnJama: true,
      payRate: '6',
    ).toJson();
    expect(json, {
      'enabled': true,
      'rate_pa': '18.5',
      'method': 'compound',
      'compounding': 'on_fy_close',
      'day_basis': 360,
      'grace_days': 7,
      'appropriation': 'principal_first',
      'apply_on': 'loans_only',
      'min_days': 3,
      'rounding': 'ten_rupee',
      'pay_on_jama': true,
      'pay_rate_pa': '6',
    });
  });

  test('fromJson(toJson(x)) gives back the same terms', () {
    final original = cfg(
      rate: '24.0001',
      method: InterestMethod.compound,
      compounding: CompoundingPeriod.halfyearly,
      graceDays: 15,
      appropriation: Appropriation.principalFirst,
      applyOn: ApplyOn.loansOnly,
      rounding: InterestRounding.rupee,
      payOnJama: true,
      payRate: '4.5',
      enabled: false,
    );
    final back = InterestConfig.fromJson(original.toJson());
    expect(back.toJson(), original.toJson());
    expect(back.ratePa, Decimal.parse('24.0001'));
    expect(back.enabled, isFalse);
    expect(back.compounding, CompoundingPeriod.halfyearly);
  });

  test('missing optional keys fall back to the system defaults', () {
    final c = InterestConfig.fromJson(const {'rate_pa': '12'});
    expect(c.ratePa, Decimal.parse('12'));
    expect(c.enabled, isTrue);
    expect(c.method, InterestMethod.simple);
    expect(c.compounding, CompoundingPeriod.quarterly);
    expect(c.dayBasis, 365);
    expect(c.graceDays, 0);
    expect(c.appropriation, Appropriation.interestFirst);
    expect(c.applyOn, ApplyOn.netUdhaar);
    expect(c.minDays, 0);
    expect(c.rounding, InterestRounding.rupee);
    expect(c.payOnJama, isFalse);
    expect(c.payRatePa, Decimal.zero);
  });

  test('a snapshot without a rate is refused, not guessed', () {
    expect(() => InterestConfig.fromJson(const {}), throwsFormatException);
    expect(
      () => InterestConfig.fromJson(const {'rate_pa': 12}),
      throwsFormatException,
    );
    expect(
      () => InterestConfig.fromJson(const {'rate_pa': 'abc'}),
      throwsFormatException,
    );
  });

  test('unknown enum values are refused', () {
    expect(
      () => InterestConfig.fromJson(const {'rate_pa': '12', 'method': 'weird'}),
      throwsFormatException,
    );
  });

  test('a choice that is not text is refused', () {
    expect(
      () => InterestConfig.fromJson(const {'rate_pa': '12', 'method': 3}),
      throwsFormatException,
    );
  });

  test('copyWith changes only what is given', () {
    final c = cfg().copyWith(
      ratePa: Decimal.parse('24'),
      applyOn: ApplyOn.loansOnly,
    );
    expect(c.ratePa, Decimal.parse('24'));
    expect(c.applyOn, ApplyOn.loansOnly);
    expect(c.method, InterestMethod.simple);
    expect(c.dayBasis, 365);
    final all = c.copyWith(
      enabled: false,
      method: InterestMethod.compound,
      compounding: CompoundingPeriod.monthly,
      dayBasis: 360,
      graceDays: 2,
      appropriation: Appropriation.principalFirst,
      minDays: 1,
      rounding: InterestRounding.paise,
      payOnJama: true,
      payRatePa: Decimal.parse('3'),
    );
    expect(all.enabled, isFalse);
    expect(all.method, InterestMethod.compound);
    expect(all.compounding, CompoundingPeriod.monthly);
    expect(all.dayBasis, 360);
    expect(all.graceDays, 2);
    expect(all.appropriation, Appropriation.principalFirst);
    expect(all.minDays, 1);
    expect(all.rounding, InterestRounding.paise);
    expect(all.payOnJama, isTrue);
    expect(all.payRatePa, Decimal.parse('3'));
  });
}
