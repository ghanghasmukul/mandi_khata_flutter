import 'package:decimal/decimal.dart';
import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

InterestResult run(
  List<LedgerEvent> events,
  InterestConfig config,
  String asOf, [
  List<RateChange> rateChanges = const [],
]) => calculate(
  events: events,
  config: config,
  asOf: d(asOf),
  rateChanges: rateChanges,
);

void main() {
  group('day count and basis', () {
    test('the start day counts, the end day does not', () {
      final r = run([udhaar('2026-06-01', 100000)], cfg(), '2026-06-02');
      // exactly one day: 100000 x 18% / 365 = 49.32
      expect(r.accruedUnpaidPaise, 4932);
    });

    test('asOf on the debit day: zero days, zero interest', () {
      final r = run([udhaar('2026-06-01', 100000)], cfg(), '2026-06-01');
      expect(r.accruedUnpaidPaise, 0);
      expect(r.principalPaise, rupees(100000));
    });

    test('360 day basis', () {
      final r = run(
        [udhaar('2026-06-01', 100000)],
        cfg(dayBasis: 360),
        '2026-07-01',
      );
      expect(r.accruedUnpaidPaise, 150000); // 1,500.00
    });

    test('slab values are not rounded one by one', () {
      // 29 same-rate "changes" cut 30 days into 30 one-day slabs. Rounding
      // each (49.32) would give 1,479.60; the exact total is 1,479.452.
      final changes = [
        for (var i = 2; i <= 30; i++)
          RateChange(
            effectiveDate: d('2026-06-${i.toString().padLeft(2, '0')}'),
            ratePa: Decimal.parse('18'),
          ),
      ];
      final r = run(
        [udhaar('2026-06-01', 100000)],
        cfg(),
        '2026-07-01',
        changes,
      );
      expect(r.accruedUnpaidPaise, 147945);
      expect(
        r.schedule.where((x) => x.kind == InterestRowKind.accrue),
        hasLength(30),
      );
    });
  });

  group('rounding modes (applied to the final total only)', () {
    final events = [udhaar('2026-08-04', 150000), jama('2026-08-19', 40000)];
    InterestResult withRounding(InterestRounding m) => run(
      events,
      cfg(appropriation: Appropriation.principalFirst, rounding: m),
      '2026-09-13',
    ); // exact accrued 2465.7534...

    test('paise', () {
      expect(withRounding(InterestRounding.paise).accruedUnpaidPaise, 246575);
    });
    test('rupee', () {
      expect(withRounding(InterestRounding.rupee).accruedUnpaidPaise, 246600);
    });
    test('ten rupee', () {
      expect(
        withRounding(InterestRounding.tenRupee).accruedUnpaidPaise,
        247000,
      );
    });
    test('half rounds up', () {
      // 100 rupees at 36.5% for 5 days = exactly 0.50
      final half = run(
        [udhaar('2026-06-01', 100)],
        cfg(rate: '36.5', rounding: InterestRounding.rupee),
        '2026-06-06',
      );
      expect(half.accruedUnpaidPaise, 100);
      final below = run(
        [udhaar('2026-06-01', 100)],
        cfg(rate: '36.5', rounding: InterestRounding.rupee),
        '2026-06-05',
      );
      expect(below.accruedUnpaidPaise, 0);
    });
    test('total payable uses the rounded interest', () {
      final r = withRounding(InterestRounding.rupee);
      expect(r.totalPayablePaise, rupees(110000) + 246600);
    });
  });

  group('appropriation', () {
    test(
      'interest_first: a credit smaller than the interest pays interest only',
      () {
        final r = run(
          [udhaar('2027-01-01', 100000), jama('2027-01-31', 100)],
          cfg(),
          '2027-01-31',
        );
        expect(r.interestRecoveredPaise, 10000);
        expect(r.principalRecoveredPaise, 0);
        expect(r.principalPaise, rupees(100000));
        expect(r.accruedUnpaidPaise, 137945); // 1479.452 - 100
      },
    );

    test(
      'principal_first: a credit bigger than everything leaves a surplus',
      () {
        final r = run(
          [udhaar('2027-01-01', 1000), jama('2027-01-31', 5000)],
          cfg(appropriation: Appropriation.principalFirst),
          '2027-02-15',
        );
        // interest 14.79 paid after principal 1000; surplus 3985.21
        expect(r.principalRecoveredPaise, rupees(1000));
        expect(r.interestRecoveredPaise, 1479);
        expect(r.creditBalancePaise, 398521);
        expect(r.principalPaise, 0);
        expect(r.accruedUnpaidPaise, 0);
      },
    );

    test('interest_first surplus beyond interest and principal', () {
      final r = run(
        [udhaar('2027-01-01', 1000), jama('2027-01-31', 5000)],
        cfg(),
        '2027-01-31',
      );
      expect(r.interestRecoveredPaise, 1479);
      expect(r.principalRecoveredPaise, rupees(1000));
      expect(r.creditBalancePaise, 398521);
    });

    test('a credit pays several tranches oldest first (partial tranche)', () {
      final r = run(
        [
          udhaar('2026-06-01', 10000),
          udhaar('2026-06-02', 10000),
          jama('2026-06-02', 15000),
        ],
        cfg(rate: '0'),
        '2026-06-03',
      );
      expect(r.principalPaise, rupees(5000));
    });
  });

  group('simple vs compound', () {
    test('simple mode never capitalises, whatever the compounding period', () {
      final r = run(
        [udhaar('2027-01-01', 100000)],
        cfg(compounding: CompoundingPeriod.monthly),
        '2028-01-01',
      );
      expect(r.principalPaise, rupees(100000));
      expect(
        r.schedule.where((x) => x.kind == InterestRowKind.compound),
        isEmpty,
      );
      // 365 days at 18% simple
      expect(r.accruedUnpaidPaise, rupees(18000));
    });

    test(
      'interest-first repayment mid-slab pays the interest accrued so far',
      () {
        // 1 Jan debit 1,00,000 at 12%, monthly compounding anchored on 1 Jan.
        // 16 Jan: accrued 493.15 is paid first, 4,506.85 off principal.
        // 1 Feb: 16 more days on 95,493.15 (+0.0007 carried) = 502.32
        // capitalised -> 95,995.47. 1 Mar: 28 days = 883.69 capitalised.
        final r = run(
          [udhaar('2027-01-01', 100000), jama('2027-01-16', 5000)],
          cfg(
            rate: '12',
            method: InterestMethod.compound,
            compounding: CompoundingPeriod.monthly,
          ),
          '2027-03-01',
        );
        expect(r.interestRecoveredPaise, 49315);
        expect(r.principalRecoveredPaise, 450685);
        final caps = r.schedule
            .where((x) => x.kind == InterestRowKind.compound)
            .map((x) => x.interestPaise);
        expect(caps, [50232, 88369]);
        expect(r.principalPaise, 9687916);
        expect(r.accruedUnpaidPaise, 0);
      },
    );

    test('compounding dates: quarterly, half-yearly, yearly', () {
      List<LedgerDate> dates(CompoundingPeriod p, String asOf) =>
          run(
                [udhaar('2027-01-01', 100000)],
                cfg(method: InterestMethod.compound, compounding: p),
                asOf,
              ).schedule
              .where((x) => x.kind == InterestRowKind.compound)
              .map((x) => x.from)
              .toList();
      expect(dates(CompoundingPeriod.quarterly, '2027-10-01'), [
        d('2027-04-01'),
        d('2027-07-01'),
        d('2027-10-01'),
      ]);
      expect(dates(CompoundingPeriod.halfyearly, '2028-01-01'), [
        d('2027-07-01'),
        d('2028-01-01'),
      ]);
      expect(dates(CompoundingPeriod.yearly, '2029-01-01'), [
        d('2028-01-01'),
        d('2029-01-01'),
      ]);
      expect(dates(CompoundingPeriod.yearly, '2027-12-31'), isEmpty);
    });

    test('month-end anchors clamp but never drift', () {
      final dates =
          run(
                [udhaar('2027-01-31', 100000)],
                cfg(
                  method: InterestMethod.compound,
                  compounding: CompoundingPeriod.monthly,
                ),
                '2027-04-30',
              ).schedule
              .where((x) => x.kind == InterestRowKind.compound)
              .map((x) => x.from);
      expect(dates, [d('2027-02-28'), d('2027-03-31'), d('2027-04-30')]);
    });

    test('on_fy_close: every 1 April after the first debit', () {
      final dates =
          run(
                [udhaar('2027-04-01', 100000)],
                cfg(
                  method: InterestMethod.compound,
                  compounding: CompoundingPeriod.onFyClose,
                ),
                '2029-04-02',
              ).schedule
              .where((x) => x.kind == InterestRowKind.compound)
              .map((x) => x.from);
      // the debit is on 1 April itself: its first FY close is 1 April 2028
      expect(dates, [d('2028-04-01'), d('2029-04-01')]);
    });

    test('nothing to capitalise: no compound row', () {
      final r = run(
        [udhaar('2027-01-01', 100000), jama('2027-01-20', 101000)],
        cfg(
          method: InterestMethod.compound,
          compounding: CompoundingPeriod.monthly,
        ),
        '2027-06-01',
      );
      expect(
        r.schedule.where((x) => x.kind == InterestRowKind.compound),
        isEmpty,
      );
    });
  });

  group('grace days (FIFO tranches)', () {
    test('each debit has its own window; repayment takes the oldest first', () {
      // A 10,000 on day 0, B 10,000 on day 10, grace 30; 10,000 repaid on
      // day 20 clears A. As of day 45 only B is left, free until day 40:
      // 5 days x 10,000 at 18% = 24.66. (Clearing B instead would leave A
      // charged for 15 days.)
      final r = run(
        [
          udhaar('2026-06-01', 10000),
          udhaar('2026-06-11', 10000),
          jama('2026-06-21', 10000),
        ],
        cfg(graceDays: 30, appropriation: Appropriation.principalFirst),
        '2026-07-16',
      );
      expect(r.accruedUnpaidPaise, 2466);
    });

    test('inside the grace window nothing accrues', () {
      final r = run(
        [udhaar('2026-06-01', 10000)],
        cfg(graceDays: 30),
        '2026-06-30',
      );
      expect(r.accruedUnpaidPaise, 0);
    });

    test('capitalised interest has no grace', () {
      final r = run(
        [udhaar('2027-01-01', 100000)],
        cfg(
          rate: '12',
          graceDays: 60,
          method: InterestMethod.compound,
          compounding: CompoundingPeriod.monthly,
        ),
        '2027-03-01',
      );
      // 1 Jan-1 Mar is 59 days: all inside the 60 day grace -> nothing.
      expect(r.principalPaise, rupees(100000));
      expect(r.accruedUnpaidPaise, 0);
    });
  });

  group('min days', () {
    test('a period shorter than min_days earns nothing; later ones do', () {
      final r = run(
        [udhaar('2026-06-01', 100000), jama('2026-06-03', 20000)],
        cfg(minDays: 5),
        '2026-06-20',
      );
      // 1-3 Jun is 2 days (< 5): 0. 3-20 Jun: 17 days on 80,000 = 670.68
      expect(r.accruedUnpaidPaise, 67068);
      expect(
        r.schedule.firstWhere((x) => x.kind == InterestRowKind.accrue).interest,
        Decimal.zero,
      );
    });

    test('a rate change does not shorten the period', () {
      final changes = [
        RateChange(effectiveDate: d('2026-06-04'), ratePa: Decimal.parse('24')),
      ];
      final events = [udhaar('2026-06-01', 100000)];
      // 10 day period split 3 + 7: still >= min_days 5, both slabs charged.
      expect(
        run(events, cfg(minDays: 5), '2026-06-11', changes).accruedUnpaidPaise,
        60822,
      );
      // ... but below min_days 11 the whole period earns nothing.
      expect(
        run(events, cfg(minDays: 11), '2026-06-11', changes).accruedUnpaidPaise,
        0,
      );
    });
  });

  group('rate changes', () {
    test('a change on or before the first event applies, with no row', () {
      final r = run(
        [udhaar('2026-06-01', 100000)],
        cfg(),
        '2026-07-01',
        [
          RateChange(
            effectiveDate: d('2026-05-01'),
            ratePa: Decimal.parse('24'),
          ),
        ],
      );
      expect(r.accruedUnpaidPaise, 197260);
      expect(
        r.schedule.where((x) => x.kind == InterestRowKind.rateChange),
        isEmpty,
      );
    });

    test('changes after asOf are ignored; same-day changes: last wins', () {
      final r = run(
        [udhaar('2026-06-01', 100000)],
        cfg(),
        '2026-07-01',
        [
          RateChange(
            effectiveDate: d('2026-08-01'),
            ratePa: Decimal.parse('99'),
          ),
          RateChange(
            effectiveDate: d('2026-06-10'),
            ratePa: Decimal.parse('12'),
          ),
          RateChange(
            effectiveDate: d('2026-06-10'),
            ratePa: Decimal.parse('36'),
          ),
        ],
      );
      // 9 days @18, 21 days @36
      // 100000x.18x9/365 = 443.836 ; 100000x.36x21/365 = 2071.233
      expect(r.accruedUnpaidPaise, 251507);
    });

    test('a change on an event day: rate row, then the event', () {
      final r = run(
        [udhaar('2026-06-01', 100000), jama('2026-06-11', 1000)],
        cfg(),
        '2026-06-21',
        [
          RateChange(
            effectiveDate: d('2026-06-11'),
            ratePa: Decimal.parse('24'),
            reason: 'renewed',
          ),
        ],
      );
      final kinds = r.schedule.map((x) => x.kind).toList();
      expect(kinds, [
        InterestRowKind.debit,
        InterestRowKind.accrue,
        InterestRowKind.rateChange,
        InterestRowKind.credit,
        InterestRowKind.accrue,
      ]);
      expect(
        r.schedule
            .singleWhere((x) => x.kind == InterestRowKind.rateChange)
            .note,
        'renewed',
      );
    });
  });

  group('apply_on and enabled', () {
    final events = [udhaar('2026-06-01', 100000)];
    test('none: no interest, principal still tracked', () {
      final r = run(events, cfg(applyOn: ApplyOn.none), '2027-06-01');
      expect(r.accruedUnpaidPaise, 0);
      expect(r.principalPaise, rupees(100000));
    });
    test('disabled: no interest', () {
      final r = run(events, cfg(enabled: false), '2027-06-01');
      expect(r.accruedUnpaidPaise, 0);
    });
    test('loans_only runs the same maths on the events it is given', () {
      expect(
        run(
          events,
          cfg(applyOn: ApplyOn.loansOnly),
          '2026-07-01',
        ).accruedUnpaidPaise,
        run(events, cfg(), '2026-07-01').accruedUnpaidPaise,
      );
    });
    test('no interest accrues while the party is in credit', () {
      final r = run([jama('2026-06-01', 50000)], cfg(), '2027-06-01');
      expect(r.accruedUnpaidPaise, 0);
      expect(r.creditBalancePaise, rupees(50000));
      expect(r.interestPayableToPartyPaise, 0);
    });
  });

  group('pay_on_jama', () {
    test('interest accrues in the party favour at pay_rate_pa', () {
      final r = run(
        [jama('2026-06-01', 50000)],
        cfg(payOnJama: true, payRate: '6'),
        '2026-07-01',
      );
      // 50000 x 6% x 30/365 = 246.575
      expect(r.interestPayableToPartyPaise, 24658);
      expect(r.accruedUnpaidPaise, 0);
      expect(r.totalPayablePaise, 0);
      final row = r.schedule.singleWhere(
        (x) => x.kind == InterestRowKind.accrue,
      );
      expect(row.inPartyFavour, isTrue);
      expect(row.ratePa, Decimal.parse('6'));
    });

    test('stops when a debit uses up the credit balance', () {
      final r = run(
        [jama('2026-06-01', 50000), udhaar('2026-06-11', 50000)],
        cfg(payOnJama: true, payRate: '6'),
        '2026-07-01',
      );
      // only the first 10 days: 50000 x 6% x 10/365 = 82.19; nothing owed
      expect(r.interestPayableToPartyPaise, 8219);
      expect(r.principalPaise, 0);
    });

    test('min_days applies to the party interest too', () {
      final r = run(
        [jama('2026-06-01', 50000)],
        cfg(payOnJama: true, payRate: '6', minDays: 60),
        '2026-07-01',
      );
      expect(r.interestPayableToPartyPaise, 0);
    });

    test('off by default', () {
      final r = run(
        [jama('2026-06-01', 50000)],
        cfg(payRate: '6'),
        '2026-07-01',
      );
      expect(r.interestPayableToPartyPaise, 0);
    });
  });

  group('event handling', () {
    test('events after asOf are ignored, events on asOf apply', () {
      final r = run(
        [
          udhaar('2026-06-01', 100000),
          jama('2026-06-11', 101000),
          udhaar('2026-07-01', 5000),
        ],
        cfg(),
        '2026-06-11',
      );
      expect(r.principalPaise, 0);
      expect(r.interestRecoveredPaise, greaterThan(0));
      expect(
        r.schedule.where((x) => x.kind == InterestRowKind.debit),
        hasLength(1),
      );
    });

    test('no events, or asOf before the first one: empty result', () {
      final none = run([], cfg(), '2026-06-11');
      expect(none.schedule, isEmpty);
      expect(none.totalPayablePaise, 0);
      final early = run([udhaar('2026-07-01', 100)], cfg(), '2026-06-11');
      expect(early.schedule, isEmpty);
    });

    test('posted interest entries are not principal (rule 8)', () {
      final posted = LedgerEvent(
        id: 'posted',
        date: d('2026-07-01'),
        side: Side.udhaar,
        amountPaise: 123456,
        isPostedInterest: true,
      );
      final events = [udhaar('2026-06-01', 100000), posted];
      final a = run(events, cfg(), '2026-08-01');
      final b = run([events.first], cfg(), '2026-08-01');
      expect(a.principalPaise, rupees(100000));
      expect(a.accruedUnpaidPaise, b.accruedUnpaidPaise);
      expect(a.schedule, hasLength(b.schedule.length));
    });

    test('input order does not matter (determinism)', () {
      final events = [
        udhaar('2026-06-01', 100000),
        jama('2026-06-11', 30000),
        udhaar('2026-06-21', 5000),
      ];
      final a = run(events, cfg(), '2026-08-01');
      final b = run(events.reversed.toList(), cfg(), '2026-08-01');
      expect(b.accruedUnpaidPaise, a.accruedUnpaidPaise);
      expect(b.principalPaise, a.principalPaise);
    });

    test('same day and createdAt: id breaks the tie', () {
      final credit = LedgerEvent(
        id: 'a',
        date: d('2026-06-01'),
        side: Side.jama,
        amountPaise: 1000,
      );
      final debit = LedgerEvent(
        id: 'b',
        date: d('2026-06-01'),
        side: Side.udhaar,
        amountPaise: 400,
      );
      final r = run([debit, credit], cfg(), '2026-06-01');
      expect(r.creditBalancePaise, 600); // 'a' (credit) sorts first
    });

    test('zero or negative amounts are rejected', () {
      expect(
        () => run(
          [
            LedgerEvent(
              id: 'x',
              date: d('2026-06-01'),
              side: Side.udhaar,
              amountPaise: 0,
            ),
          ],
          cfg(),
          '2026-07-01',
        ),
        throwsArgumentError,
      );
    });
  });

  group('InterestConfig.fromSettings', () {
    SettingRow row(
      String key,
      Object? value, [
      SettingScope? scope,
      String? id,
    ]) => SettingRow(
      scope: scope ?? SettingScope.tenant,
      scopeId: id,
      key: key,
      value: value,
    );

    test('constructor defaults match the system defaults', () {
      final c = InterestConfig(ratePa: Decimal.parse('18'));
      expect(c.payRatePa, Decimal.zero);
      expect(c.applicable, isTrue);
      expect(c.compounds, isFalse);
      expect(c.rounding, InterestRounding.rupee);
    });

    test('system defaults', () {
      final c = InterestConfig.fromSettings(SettingsResolver(const []));
      expect(c.enabled, isTrue);
      expect(c.ratePa, Decimal.parse('18'));
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

    test('reads every key through the cascade, party beating tenant', () {
      final resolver = SettingsResolver([
        row('interest.enabled', true),
        row('interest.rate_pa', '24'),
        row('interest.method', 'compound'),
        row('interest.compounding', 'on_fy_close'),
        row('interest.day_basis', 360),
        row('interest.grace_days', 7),
        row('interest.appropriation', 'principal_first'),
        row('interest.apply_on', 'loans_only'),
        row('interest.min_days', 3),
        row('interest.rounding', 'ten_rupee'),
        row('interest.pay_on_jama', true),
        row('interest.pay_rate_pa', '6'),
        row('interest.rate_pa', '12', SettingScope.party, 'ram'),
      ]);
      final c = InterestConfig.fromSettings(resolver, partyId: 'ram');
      expect(c.ratePa, Decimal.parse('12'));
      expect(c.method, InterestMethod.compound);
      expect(c.compounding, CompoundingPeriod.onFyClose);
      expect(c.dayBasis, 360);
      expect(c.graceDays, 7);
      expect(c.appropriation, Appropriation.principalFirst);
      expect(c.applyOn, ApplyOn.loansOnly);
      expect(c.minDays, 3);
      expect(c.rounding, InterestRounding.tenRupee);
      expect(c.payOnJama, isTrue);
      expect(c.payRatePa, Decimal.parse('6'));
    });

    test('supplier-only default is none, but explicit settings and other '
        'roles win', () {
      final resolver = SettingsResolver([
        row('interest.apply_on', 'net_udhaar', SettingScope.party, 'explicit'),
      ]);
      ApplyOn applyOn(String party, Set<PartyRole> roles) =>
          InterestConfig.fromSettings(
            resolver,
            partyId: party,
            partyRoles: roles,
          ).applyOn;
      expect(applyOn('p', {PartyRole.supplier}), ApplyOn.none);
      expect(applyOn('p', {PartyRole.agency}), ApplyOn.none);
      expect(
        applyOn('p', {PartyRole.supplier, PartyRole.farmer}),
        ApplyOn.netUdhaar,
      );
      expect(applyOn('p', {PartyRole.vendor}), ApplyOn.netUdhaar);
      expect(applyOn('p', {}), ApplyOn.netUdhaar);
      expect(applyOn('explicit', {PartyRole.supplier}), ApplyOn.netUdhaar);
    });

    test('a tenant-level apply_on of net_udhaar still defaults a supplier '
        'to none; a tenant that says loans_only is left alone', () {
      final tenant = SettingsResolver([row('interest.apply_on', 'loans_only')]);
      expect(
        InterestConfig.fromSettings(
          tenant,
          partyRoles: const {PartyRole.supplier},
        ).applyOn,
        ApplyOn.none,
      );
    });
  });

  group('rate unit helper', () {
    test('1.5 per 100 per month is 18% p.a. and back', () {
      final pa = InterestRate.paFromPer100PerMonth(Decimal.parse('1.5'));
      expect(pa, Decimal.parse('18'));
      expect(InterestRate.per100PerMonthFromPa(pa), Decimal.parse('1.5'));
    });
  });
}
