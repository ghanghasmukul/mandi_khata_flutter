import 'package:decimal/decimal.dart';
import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// The ten scenarios of docs/interest-verification.md. Every expected figure
/// was worked out by hand (exact decimal arithmetic, half-up to paise) from
/// the rules in docs/domain/interest-engine.md BEFORE the engine was run on
/// them; the arithmetic is written next to each scenario. A mismatch is a
/// finding to report, never a number to edit.
///
/// All scenarios use whole-paise rounding, 365 days a year unless noted.
void main() {
  LedgerEvent debit(String date, int rupees) => udhaar(date, rupees);
  LedgerEvent credit(String date, int rupees) => jama(date, rupees);

  test('V1 simple: 50,000 at 24% for 181 days (1 Jan to 1 Jul)', () {
    // 50,000 x 24% x 181 / 365 = 5,950.684... -> 5,950.68
    final r = calculate(
      events: [debit('2027-01-01', 50000)],
      config: cfg(rate: '24'),
      asOf: d('2027-07-01'),
    );
    expect(r.accruedUnpaidPaise, 595068);
    expect(r.principalPaise, rupees(50000));
    expect(r.totalPayablePaise, rupees(50000) + 595068);
  });

  group('V2 / V3 one repayment, interest first vs principal first', () {
    // 18%. Debit 1,00,000 on 1 Jan, debit 50,000 on 1 Feb, credit 60,000 on
    // 1 Mar, as of 1 Apr. Interest before the credit:
    //   1 Jan - 1 Feb  31 d on 1,00,000 = 1,528.767...
    //   1 Feb - 1 Mar  28 d on 1,50,000 = 2,071.232...
    //   total 3,600.000 -> 3,600.00
    final events = [
      debit('2027-01-01', 100000),
      debit('2027-02-01', 50000),
      credit('2027-03-01', 60000),
    ];

    test('V2 interest first', () {
      // The credit pays 3,600.00 of interest, then 56,400.00 of principal:
      // principal 93,600.00. 1 Mar - 1 Apr 31 d on 93,600 = 1,430.93;
      // accrued unpaid 1,430.93 (+ the unrounded remainder, nil).
      final r = calculate(events: events, config: cfg(), asOf: d('2027-04-01'));
      expect(r.interestRecoveredPaise, 360000);
      expect(r.principalRecoveredPaise, 5640000);
      expect(r.principalPaise, 9360000);
      expect(r.accruedUnpaidPaise, 143093);
      expect(r.totalPayablePaise, 9503093);
    });

    test('V3 principal first', () {
      // The credit pays 60,000 of principal: principal 90,000.
      // Interest keeps the 3,600.00 and adds 31 d on 90,000 = 1,375.89.
      // accrued 4,975.89.
      final r = calculate(
        events: events,
        config: cfg(appropriation: Appropriation.principalFirst),
        asOf: d('2027-04-01'),
      );
      expect(r.interestRecoveredPaise, 0);
      expect(r.principalRecoveredPaise, 6000000);
      expect(r.principalPaise, 9000000);
      expect(r.accruedUnpaidPaise, 497589);
      expect(r.totalPayablePaise, 9497589);
    });
  });

  test('V4 monthly compounding: 1,00,000 at 12% for 3 months', () {
    // Steps on 1 Feb, 1 Mar, 1 Apr. At each step the accrued interest is
    // rounded to paise and joins the principal; the sub-paise left over stays
    // in the running accrued figure (it is not lost).
    //   31 d: 1,019.178 -> 1,019.18   principal 1,01,019.18
    //   28 d:   929.93  ->   929.93   principal 1,01,949.11
    //   31 d: 1,039.04  -> 1,039.04   principal 1,02,988.15
    // (1 Apr is a step day, so everything is principal and nothing is accrued.)
    final r = calculate(
      events: [debit('2027-01-01', 100000)],
      config: cfg(
        rate: '12',
        method: InterestMethod.compound,
        compounding: CompoundingPeriod.monthly,
      ),
      asOf: d('2027-04-01'),
    );
    expect(r.principalPaise, 10298815);
    expect(r.accruedUnpaidPaise, 0);
    expect(r.totalPayablePaise, 10298815);
  });

  test('V5 quarterly compounding: 2,00,000 at 15% for 9 months', () {
    // Steps 1 Apr (90 d), 1 Jul (91 d), 1 Oct (92 d), rounded to paise with
    // the sub-paise carried:
    //   90 d: 7,397.26   principal 2,07,397.26
    //   91 d: 7,756.09   principal 2,15,153.35
    //   92 d: 8,134.56   principal 2,23,287.91
    final r = calculate(
      events: [debit('2027-01-01', 200000)],
      config: cfg(rate: '15', method: InterestMethod.compound),
      asOf: d('2027-10-01'),
    );
    expect(r.principalPaise, 22328791);
    expect(r.accruedUnpaidPaise, 0);
    expect(r.totalPayablePaise, 22328791);
  });

  test('V6 yearly compounding: 1,00,000 at 10% for 2 years 6 months', () {
    // 1 Jan 2027 to 1 Jul 2029. Steps 1 Jan 2028 (365 d) and 1 Jan 2029
    // (366 d, 2028 is a leap year; the basis stays 365), then 181 d.
    //   year 1: 10,000.00            principal 1,10,000.00
    //   year 2: 1,10,000 x 10% x 366/365 = 11,030.14   principal 1,21,030.14
    //   half:   1,21,030.14 x 10% x 181/365 = 6,001.77
    final r = calculate(
      events: [debit('2027-01-01', 100000)],
      config: cfg(
        rate: '10',
        method: InterestMethod.compound,
        compounding: CompoundingPeriod.yearly,
      ),
      asOf: d('2029-07-01'),
    );
    expect(r.principalPaise, 12103014);
    expect(r.accruedUnpaidPaise, 600177);
    expect(r.totalPayablePaise, 12703191);
  });

  test('V7 grace days 30 with two debits and a part payment (FIFO)', () {
    // 18%. Debit 10,000 on 1 Jan (interest from 31 Jan), debit 20,000 on
    // 21 Jan (interest from 20 Feb), credit 5,000 on 10 Feb, as of 1 Mar.
    //   31 Jan - 10 Feb: 10 d on 10,000 = 49.32 (paid first by the credit)
    //   principal paid 4,950.68, taken from the OLDEST debit: 5,049.32 left
    //   10 Feb - 1 Mar: 19 d on 5,049.32 = 47.30...
    //   20 Feb - 1 Mar:  9 d on 20,000   = 88.77...
    //   accrued unpaid 49.32 - 49.32 + 47.31 + 88.77 -> 136.07 (exact 136.07)
    final r = calculate(
      events: [
        debit('2027-01-01', 10000),
        debit('2027-01-21', 20000),
        credit('2027-02-10', 5000),
      ],
      config: cfg(graceDays: 30),
      asOf: d('2027-03-01'),
    );
    expect(r.interestRecoveredPaise, 4932);
    expect(r.principalPaise, 2504932);
    expect(r.accruedUnpaidPaise, 13607);
    expect(r.totalPayablePaise, 2518539);
  });

  test('V8 surplus credit: jama 50,000, then udhaar 80,000 a month later', () {
    // The 50,000 credit sets off against the later debit; only 30,000 earns
    // interest, from 1 Feb: 30,000 x 18% x 28 / 365 = 414.25. Nothing is
    // charged on the 50,000 that was already in the khata as jama.
    final r = calculate(
      events: [credit('2027-01-01', 50000), debit('2027-02-01', 80000)],
      config: cfg(),
      asOf: d('2027-03-01'),
    );
    expect(r.creditBalancePaise, 0);
    expect(r.principalPaise, rupees(30000));
    expect(r.accruedUnpaidPaise, 41425);
  });

  test('V9 rate change: 18% until 1 Mar, then 24%, as of 1 Jun', () {
    // 1,00,000 x 18% x 59 / 365 = 2,909.589  (1 Jan - 1 Mar)
    // 1,00,000 x 24% x 92 / 365 = 6,049.315  (1 Mar - 1 Jun)
    // total 8,958.904 -> 8,958.90
    final r = calculate(
      events: [debit('2027-01-01', 100000)],
      config: cfg(),
      rateChanges: [
        RateChange(effectiveDate: d('2027-03-01'), ratePa: Decimal.parse('24')),
      ],
      asOf: d('2027-06-01'),
    );
    expect(r.accruedUnpaidPaise, 895890);
    expect(r.principalPaise, rupees(100000));
  });

  test('V10 compounding on the financial year close, 360-day basis', () {
    // 3,00,000 at 12%, basis 360. Steps on 1 Apr 2027 (90 d) and 1 Apr 2028
    // (366 d), each rounded to paise.
    //   90 d:  3,00,000 x 12% x 90 / 360  =  9,000.00   principal 3,09,000.00
    //  366 d:  3,09,000 x 12% x 366 / 360 = 37,698.00   principal 3,46,698.00
    final r = calculate(
      events: [debit('2027-01-01', 300000)],
      config: cfg(
        rate: '12',
        method: InterestMethod.compound,
        compounding: CompoundingPeriod.onFyClose,
        dayBasis: 360,
      ),
      asOf: d('2028-04-01'),
    );
    expect(r.principalPaise, 34669800);
    expect(r.accruedUnpaidPaise, 0);
    expect(r.totalPayablePaise, 34669800);
  });
}
