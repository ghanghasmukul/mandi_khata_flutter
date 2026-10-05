import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

import 'helpers.dart';

LedgerEvent waiver(String date, int rupeesAmount) => LedgerEvent(
  id: 'w$date',
  date: d(date),
  side: Side.jama,
  amountPaise: rupees(rupeesAmount),
  interestOnly: true,
);

void main() {
  // 1,00,000 at 18% for 100 days = 4,931.51 (49315.07 paise rounded).
  final debit = udhaar('2027-01-01', 100000);

  test('a waiver pays interest only, even when principal is paid first', () {
    final r = calculate(
      events: [debit, waiver('2027-04-11', 1000)],
      config: cfg(appropriation: Appropriation.principalFirst),
      asOf: d('2027-04-11'),
    );
    expect(r.principalPaise, rupees(100000));
    expect(r.principalRecoveredPaise, 0);
    expect(r.interestWaivedPaise, rupees(1000));
    expect(r.interestRecoveredPaise, 0);
    expect(r.accruedUnpaidPaise, 493151 - rupees(1000));
    final credit = r.schedule.singleWhere(
      (x) => x.kind == InterestRowKind.credit,
    );
    expect(credit.payInterestPaise, rupees(1000));
    expect(credit.payPrincipalPaise, 0);
  });

  test('waiver above the accrued interest spills into principal', () {
    final r = calculate(
      events: [debit, waiver('2027-04-11', 6000)],
      config: cfg(appropriation: Appropriation.principalFirst),
      asOf: d('2027-04-11'),
    );
    expect(r.interestWaivedPaise, 493151);
    expect(r.accruedUnpaidPaise, 0);
    expect(r.principalRecoveredPaise, rupees(6000) - 493151);
  });

  test('an ordinary credit is never counted as waived', () {
    final r = calculate(
      events: [debit, jama('2027-04-11', 1000)],
      config: cfg(),
      asOf: d('2027-04-11'),
    );
    expect(r.interestWaivedPaise, 0);
    expect(r.interestRecoveredPaise, rupees(1000));
  });
}
