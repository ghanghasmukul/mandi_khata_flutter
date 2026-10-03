import 'package:decimal/decimal.dart';
import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// The eight worked examples of docs/domain/interest-engine.md. Expected
/// figures were worked out by hand (and checked with exact decimal
/// arithmetic) before the engine existed.
void main() {
  group('1. simple 18% p.a., 365: debit 1,50,000 on 4 Aug, credit 40,000 '
      'on 19 Aug, as of 13 Sep', () {
    final events = [udhaar('2026-08-04', 150000), jama('2026-08-19', 40000)];

    test('principal_first: 15d on 1,50,000 then 25d on 1,10,000', () {
      // 150000 x 18% x 15/365 = 1109.589...; 110000 x 18% x 25/365 = 1356.164
      final r = calculate(
        events: events,
        config: cfg(appropriation: Appropriation.principalFirst),
        asOf: d('2026-09-13'),
      );
      expect(r.principalPaise, rupees(110000));
      expect(r.accruedUnpaidPaise, 246575); // 2,465.75
      expect(r.principalRecoveredPaise, rupees(40000));
      expect(r.interestRecoveredPaise, 0);
      expect(r.totalPayablePaise, rupees(110000) + 246575);
      expect(r.creditBalancePaise, 0);
      final accruals = r.schedule
          .where((x) => x.kind == InterestRowKind.accrue)
          .toList();
      expect(accruals, hasLength(2));
      expect(accruals[0].days, 15);
      expect(accruals[0].interestPaise, 110959);
      expect(accruals[1].days, 25);
      expect(accruals[1].interestPaise, 135616);
    });

    test('interest_first: 1,109.59 interest paid first, then principal', () {
      final r = calculate(events: events, config: cfg(), asOf: d('2026-09-13'));
      // principal 1,50,000 - 38,890.41 = 1,11,109.59; x 18% x 25/365 = 1369.84
      expect(r.interestRecoveredPaise, 110959);
      expect(r.principalRecoveredPaise, 3889041);
      expect(r.principalPaise, 11110959);
      expect(r.accruedUnpaidPaise, 136984);
      expect(r.totalPayablePaise, 11110959 + 136984);
      final credit = r.schedule.singleWhere(
        (x) => x.kind == InterestRowKind.credit,
      );
      expect(credit.payInterestPaise, 110959);
      expect(credit.payPrincipalPaise, 3889041);
    });
  });

  test('2. surplus credit is not lost: jama 50,000 then udhaar 20,000', () {
    final r = calculate(
      events: [jama('2026-04-01', 50000), udhaar('2026-05-01', 20000)],
      config: cfg(),
      asOf: d('2026-09-01'),
    );
    expect(r.accruedUnpaidPaise, 0);
    expect(r.principalPaise, 0);
    expect(r.totalPayablePaise, 0);
    expect(r.creditBalancePaise, rupees(30000));
  });

  test('2b. a debit larger than the credit balance charges only the rest', () {
    // 10,000 credit, then 25,000 debit: 15,000 bears interest from 1 May.
    final r = calculate(
      events: [jama('2026-04-01', 10000), udhaar('2026-05-01', 25000)],
      config: cfg(),
      asOf: d('2026-05-31'), // 30 days
    );
    expect(r.creditBalancePaise, 0);
    expect(r.principalPaise, rupees(15000));
    // 15000 x 18% x 30/365 = 221.917...
    expect(r.accruedUnpaidPaise, 22192);
  });

  group('3. compounding', () {
    test('monthly, 3 months, no repayments', () {
      // 1 Jan -> 1 Apr 2027 (31, 28, 31 days), 12% p.a., 365 basis.
      // 1019.18 -> 929.93 -> 1039.04 (each capitalised to paise).
      final r = calculate(
        events: [udhaar('2027-01-01', 100000)],
        config: cfg(
          rate: '12',
          method: InterestMethod.compound,
          compounding: CompoundingPeriod.monthly,
        ),
        asOf: d('2027-04-01'),
      );
      expect(r.totalPayablePaise, 10298815); // 1,02,988.15
      expect(
        r.schedule.where((x) => x.kind == InterestRowKind.compound),
        hasLength(3),
      );
    });

    test('matches the day-count compound formula within 1 rupee', () {
      // P x prod(1 + r x days/365). The spec's P(1 + r/12)^3 formula assumes
      // every month is 1/12 of a year; real months are 31/28/31 days, so it
      // is ~42 rupees away. The day-count product is the right yardstick.
      var factor = 1.0;
      for (final days in [31, 28, 31]) {
        factor *= 1 + 0.12 * days / 365;
      }
      final expected = 100000 * factor;
      final r = calculate(
        events: [udhaar('2027-01-01', 100000)],
        config: cfg(
          rate: '12',
          method: InterestMethod.compound,
          compounding: CompoundingPeriod.monthly,
        ),
        asOf: d('2027-04-01'),
      );
      expect((r.totalPayablePaise / 100 - expected).abs(), lessThan(1));
    });
  });

  test('4. grace 30 days: debit 10,000, as of +45 days charges 15 days', () {
    final r = calculate(
      events: [udhaar('2026-06-01', 10000)],
      config: cfg(graceDays: 30),
      asOf: d('2026-07-16'), // 45 days later
    );
    // 10000 x 18% x 15/365 = 73.97
    expect(r.accruedUnpaidPaise, 7397);
  });

  test('5. a rate change mid-period splits the slab', () {
    final r = calculate(
      events: [udhaar('2027-01-01', 100000)],
      config: cfg(),
      asOf: d('2027-03-01'),
      rateChanges: [
        RateChange(effectiveDate: d('2027-02-01'), ratePa: Decimal.parse('24')),
      ],
    );
    // 31d @ 18% = 1528.767 ; 28d @ 24% = 1841.096 ; total 3369.863
    expect(r.accruedUnpaidPaise, 336986);
    final accruals = r.schedule
        .where((x) => x.kind == InterestRowKind.accrue)
        .toList();
    expect(accruals.map((x) => x.days), [31, 28]);
    expect(accruals.map((x) => x.ratePa.toString()), ['18', '24']);
    expect(
      r.schedule.where((x) => x.kind == InterestRowKind.rateChange),
      hasLength(1),
    );
  });

  test('6. supplier-only party with default settings gets zero interest', () {
    final resolver = SettingsResolver(const []);
    final config = InterestConfig.fromSettings(
      resolver,
      partyId: 'p1',
      partyRoles: const {PartyRole.supplier, PartyRole.agency},
    );
    expect(config.applyOn, ApplyOn.none);
    final r = calculate(
      events: [udhaar('2026-04-01', 100000)],
      config: config,
      asOf: d('2027-04-01'),
    );
    expect(r.accruedUnpaidPaise, 0);
    expect(r.principalPaise, rupees(100000));
  });

  test('7. on_fy_close compounding across 31 March', () {
    // 1 Jan -> 1 Apr 2027 = 90 days: 2958.90 capitalised at the FY close;
    // then 30 days on 1,02,958.90 = 1015.485 (+0.004 carried) -> 1015.49.
    final r = calculate(
      events: [udhaar('2027-01-01', 100000)],
      config: cfg(
        rate: '12',
        method: InterestMethod.compound,
        compounding: CompoundingPeriod.onFyClose,
      ),
      asOf: d('2027-05-01'),
    );
    final compounds = r.schedule
        .where((x) => x.kind == InterestRowKind.compound)
        .toList();
    expect(compounds, hasLength(1));
    expect(compounds.single.from, d('2027-04-01'));
    expect(compounds.single.interestPaise, 295890);
    expect(r.principalPaise, 10295890);
    expect(r.accruedUnpaidPaise, 101549);
  });

  group('8. same-day debit and credit', () {
    test('equal amounts cancel: no principal, no interest', () {
      final r = calculate(
        events: [udhaar('2026-08-04', 50000), jama('2026-08-04', 50000)],
        config: cfg(),
        asOf: d('2026-09-04'),
      );
      expect(r.principalPaise, 0);
      expect(r.accruedUnpaidPaise, 0);
      expect(r.creditBalancePaise, 0);
    });

    test('partial credit the same day: interest on the rest only', () {
      final r = calculate(
        events: [udhaar('2026-08-04', 50000), jama('2026-08-04', 20000)],
        config: cfg(),
        asOf: d('2026-09-03'), // 30 days
      );
      // 30000 x 18% x 30/365 = 443.84
      expect(r.principalPaise, rupees(30000));
      expect(r.accruedUnpaidPaise, 44384);
    });

    test('sort order decides: credit created first goes to credit balance', () {
      final t0 = DateTime.utc(2026, 8, 4, 9);
      final t1 = DateTime.utc(2026, 8, 4, 10);
      final r = calculate(
        events: [
          udhaar('2026-08-04', 20000, createdAt: t1),
          jama('2026-08-04', 50000, createdAt: t0),
        ],
        config: cfg(),
        asOf: d('2026-09-04'),
      );
      expect(r.creditBalancePaise, rupees(30000));
      expect(r.accruedUnpaidPaise, 0);
    });
  });
}
