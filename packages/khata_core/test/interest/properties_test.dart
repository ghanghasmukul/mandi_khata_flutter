import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Property-based tests: many random accounts from a fixed seed, so a failure
/// is reproducible.
void main() {
  final base = LedgerDate(2026, 4, 1);
  final asOf = LedgerDate(2027, 6, 30);
  var ids = 0;

  LedgerEvent randomEvent(Random rnd, Side side, {int? maxDay}) => LedgerEvent(
    id: 'p${ids++}',
    date: base.addDays(rnd.nextInt(maxDay ?? 400)),
    side: side,
    amountPaise: 100 + rnd.nextInt(10000000), // up to ~1 lakh rupees
  );

  List<LedgerEvent> randomEvents(Random rnd) {
    final n = 1 + rnd.nextInt(8);
    return [
      for (var i = 0; i < n; i++)
        randomEvent(rnd, rnd.nextInt(3) == 0 ? Side.jama : Side.udhaar),
    ];
  }

  InterestConfig randomConfig(Random rnd, {String? rate}) => cfg(
    rate: rate ?? (rnd.nextInt(3000) / 100).toStringAsFixed(2),
    method: InterestMethod.values[rnd.nextInt(2)],
    compounding: CompoundingPeriod.values[rnd.nextInt(5)],
    dayBasis: rnd.nextBool() ? 365 : 360,
    graceDays: rnd.nextInt(12),
    appropriation: Appropriation.values[rnd.nextInt(2)],
    minDays: rnd.nextInt(6),
  );

  const runs = 300;

  test('(a) with rate 0 interest is always 0', () {
    final rnd = Random(1);
    for (var i = 0; i < runs; i++) {
      final r = calculate(
        events: randomEvents(rnd),
        config: randomConfig(rnd, rate: '0'),
        asOf: asOf,
      );
      expect(r.accruedUnpaidPaise, 0);
      expect(r.interestRecoveredPaise, 0);
      expect(r.schedule.every((x) => x.interestPaise == 0), isTrue);
    }
  });

  test('(b) total payable = principal + accrued, balances are sane', () {
    final rnd = Random(2);
    for (var i = 0; i < runs; i++) {
      final r = calculate(
        events: randomEvents(rnd),
        config: randomConfig(rnd),
        asOf: asOf,
      );
      expect(r.totalPayablePaise, r.principalPaise + r.accruedUnpaidPaise);
      expect(r.principalPaise, greaterThanOrEqualTo(0));
      expect(r.creditBalancePaise, greaterThanOrEqualTo(0));
      // Never both: a party is either in debt or in credit.
      expect(r.principalPaise > 0 && r.creditBalancePaise > 0, isFalse);
    }
  });

  test('(c) interest is never negative', () {
    final rnd = Random(3);
    for (var i = 0; i < runs; i++) {
      final r = calculate(
        events: randomEvents(rnd),
        config: randomConfig(rnd),
        asOf: asOf,
      );
      expect(r.accruedUnpaidPaise, greaterThanOrEqualTo(0));
      expect(r.interestRecoveredPaise, greaterThanOrEqualTo(0));
      expect(r.principalRecoveredPaise, greaterThanOrEqualTo(0));
      for (final row in r.schedule) {
        expect(row.interest >= Decimal.zero, isTrue);
        expect(row.payInterestPaise, greaterThanOrEqualTo(0));
        expect(row.payPrincipalPaise, greaterThanOrEqualTo(0));
      }
    }
  });

  test('(d) adding a jama never increases interest', () {
    final rnd = Random(4);
    for (var i = 0; i < runs; i++) {
      final events = randomEvents(rnd);
      final config = randomConfig(rnd);
      final extra = randomEvent(rnd, Side.jama);
      final before = calculate(events: events, config: config, asOf: asOf);
      final after = calculate(
        events: [...events, extra],
        config: config,
        asOf: asOf,
      );
      // All interest ever charged, wherever it now sits (still accrued,
      // capitalised into principal, or already recovered). Money in = money
      // out: debits that bear interest + interest = principal + accrued +
      // everything recovered. Each repayment's interest part is split in
      // whole paise and capitalisation rounds to paise, so allow a few paise.
      int interestOf(List<LedgerEvent> list, InterestResult r) {
        final debits = list
            .where((e) => e.side == Side.udhaar)
            .fold(0, (s, e) => s + e.amountPaise);
        final setOff = r.schedule.fold(
          0,
          (s, x) => s + x.fromCreditBalancePaise,
        );
        return r.principalPaise +
            r.accruedUnpaidPaise +
            r.principalRecoveredPaise +
            r.interestRecoveredPaise -
            (debits - setOff);
      }

      final totalBefore = interestOf(events, before);
      final totalAfter = interestOf([...events, extra], after);
      expect(
        totalAfter,
        lessThanOrEqualTo(totalBefore + 2 * events.length + 4),
        reason: 'run $i',
      );
    }
  });
}
