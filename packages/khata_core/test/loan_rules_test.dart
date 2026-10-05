import 'package:decimal/decimal.dart';
import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

import 'interest/helpers.dart';

/// Worked examples: Rs 1,00,000 lent on 1 Jan 2027 at 18% p.a. simple,
/// 365-day basis, paise rounding.
///   30 days (to 31 Jan): 1,00,000 x 18% x 30 / 365 = 1,479.4520... -> 1,479.45
void main() {
  final issued = d('2027-01-01');
  final events = [udhaar('2027-01-01', 100000)];
  final config = cfg();

  LoanPosition position({
    LedgerDate? asOf,
    List<LedgerEvent>? evs,
    LoanStatus status = LoanStatus.active,
    LedgerDate? closedOn,
    LedgerDate? dueDate,
    List<RateChange> rateChanges = const [],
    InterestConfig? terms,
  }) => LoanRules.position(
    principal: const Money.rupees(100000),
    events: evs ?? events,
    config: terms ?? config,
    asOf: asOf ?? d('2027-01-31'),
    status: status,
    closedOn: closedOn,
    dueDate: dueDate,
    rateChanges: rateChanges,
  );

  group('LoanStatus', () {
    test('db names round-trip', () {
      expect(LoanStatus.writtenOff.dbName, 'written_off');
      for (final s in LoanStatus.values) {
        expect(LoanStatus.parse(s.dbName), s);
      }
      expect(() => LoanStatus.parse('nope'), throwsFormatException);
    });

    test('only an active loan is open', () {
      expect(LoanStatus.active.isOpen, isTrue);
      expect(LoanStatus.closed.isOpen, isFalse);
      expect(LoanStatus.writtenOff.isOpen, isFalse);
    });
  });

  group('position', () {
    test('30 days of simple interest on the full principal', () {
      final p = position();
      expect(p.principal, const Money.rupees(100000));
      expect(p.accrued, const Money(147945)); // 1,479.45
      expect(p.payable, const Money(10147945)); // 1,01,479.45
      expect(p.issued, const Money.rupees(100000));
      expect(p.recoveryPercent, 0);
      expect(p.interestRecovered, Money.zero);
      expect(p.asOf, d('2027-01-31'));
    });

    test('a repayment lowers principal and shows the recovery percent', () {
      final p = position(
        evs: [...events, jama('2027-01-31', 20000)],
        asOf: d('2027-01-31'),
      );
      // interest first: 1,479.45 interest, 18,520.55 principal
      expect(p.interestRecovered, const Money(147945));
      expect(p.principalRecovered, const Money(1852055));
      expect(p.principal, const Money(8147945));
      expect(p.recoveryPercent, 18); // 18.52% -> 18 (rounded down)
      expect(p.payable, const Money(8147945));
    });

    test('paying 1,01,479 leaves 45 paise: recovery is 99 percent', () {
      final p = position(
        evs: [...events, jama('2027-01-31', 101479.45.round())],
      );
      // interest 1,479.45 is paid first, then 99,999.55 of the principal.
      expect(p.recoveryPercent, 99);
    });

    test('rate changes split the slab (18% then 24% from 16 Jan)', () {
      final p = position(
        rateChanges: [
          RateChange(
            effectiveDate: d('2027-01-16'),
            ratePa: Decimal.parse('24'),
          ),
        ],
      );
      // 15 d x 18%: 739.726; 15 d x 24%: 986.301; total 1,726.027
      expect(p.accrued, const Money(172603));
    });

    test('a closed loan stops accruing on the day it was closed', () {
      final open = position(asOf: d('2027-03-31'));
      final closed = position(
        asOf: d('2027-03-31'),
        status: LoanStatus.writtenOff,
        closedOn: d('2027-01-31'),
      );
      expect(closed.accrued, const Money(147945));
      expect(closed.asOf, d('2027-01-31'));
      expect(open.accrued > closed.accrued, isTrue);
    });

    test('closed after the as-of date: the as-of date still wins', () {
      final p = position(
        asOf: d('2027-01-15'),
        status: LoanStatus.closed,
        closedOn: d('2027-02-28'),
      );
      expect(p.asOf, d('2027-01-15'));
    });

    test('interest off or rate zero: payable is the principal', () {
      final p = position(terms: cfg(rate: '0'));
      expect(p.accrued, Money.zero);
      expect(p.payable, const Money.rupees(100000));
      final off = position(terms: cfg(enabled: false));
      expect(off.accrued, Money.zero);
    });

    test('no events yet: zero principal, nothing recovered', () {
      final p = position(evs: const []);
      expect(p.principal, Money.zero);
      expect(p.payable, Money.zero);
      expect(p.recoveryPercent, 0);
    });

    test('an issued principal of zero never divides by zero', () {
      final p = LoanRules.position(
        principal: Money.zero,
        events: const [],
        config: config,
        asOf: issued,
        status: LoanStatus.active,
      );
      expect(p.recoveryPercent, 0);
    });
  });

  group('days left and health', () {
    final due = d('2027-03-01');
    LoanPosition at(String asOf, {LoanStatus s = LoanStatus.active}) =>
        position(asOf: d(asOf), dueDate: due, status: s);

    test('days left counts to the due date; negative when overdue', () {
      expect(at('2027-02-15').daysLeft, 14);
      expect(at('2027-03-01').daysLeft, 0);
      expect(at('2027-03-02').daysLeft, -1);
      expect(position().daysLeft, isNull);
    });

    test('on track, due soon (7 days or less), overdue', () {
      expect(at('2027-02-15').health, LoanHealth.onTrack);
      expect(at('2027-02-22').health, LoanHealth.dueSoon); // 7 days
      expect(at('2027-02-21').health, LoanHealth.onTrack); // 8 days
      expect(at('2027-03-01').health, LoanHealth.dueSoon); // due today
      expect(at('2027-03-02').health, LoanHealth.overdue);
      expect(position().health, LoanHealth.onTrack); // no due date
    });

    test('paid up but still open is settled; closed / written off win', () {
      final paid = position(
        evs: [...events, jama('2027-01-31', 101479.45.round())],
      );
      expect(paid.health, isNot(LoanHealth.settled)); // 45 paise remain
      final exact = LoanRules.position(
        principal: const Money.rupees(100000),
        events: [udhaar('2027-01-01', 100000), jama('2027-01-01', 100000)],
        config: config,
        asOf: d('2027-01-31'),
        status: LoanStatus.active,
        dueDate: due,
      );
      expect(exact.payable, Money.zero);
      expect(exact.health, LoanHealth.settled);
      expect(at('2027-03-05', s: LoanStatus.closed).health, LoanHealth.closed);
      expect(
        at('2027-03-05', s: LoanStatus.writtenOff).health,
        LoanHealth.writtenOff,
      );
    });
  });

  group('previewRepayment', () {
    LoanRepaymentPreview preview(
      int rupeeAmount, {
      String on = '2027-01-31',
      InterestConfig? terms,
      List<LedgerEvent>? evs,
      Money? exact,
    }) => LoanRules.previewRepayment(
      events: evs ?? events,
      config: terms ?? config,
      repaymentDate: d(on),
      amount: exact ?? Money.rupees(rupeeAmount),
    );

    test('interest first: 20,000 pays 1,479.45 interest then principal', () {
      final p = preview(20000);
      expect(p.interest, const Money(147945));
      expect(p.principal, const Money(1852055));
      expect(p.surplus, Money.zero);
      expect(p.payableBefore, const Money(10147945));
      expect(p.payableAfter, const Money(8147945));
      expect(p.principalAfter, const Money(8147945));
      expect(p.exceedsPayable, isFalse);
      expect(p.interest + p.principal + p.surplus, const Money.rupees(20000));
    });

    test('principal first: 20,000 pays principal, interest stays', () {
      final p = preview(
        20000,
        terms: cfg(appropriation: Appropriation.principalFirst),
      );
      expect(p.interest, Money.zero);
      expect(p.principal, const Money.rupees(20000));
      expect(p.principalAfter, const Money.rupees(80000));
      expect(p.payableAfter, const Money(8147945));
    });

    test('paying exactly what is due leaves nothing', () {
      final p = preview(0, exact: const Money(10147945));
      expect(p.exceedsPayable, isFalse);
      expect(p.payableAfter, Money.zero);
    });

    test('more than is due: the extra is surplus and flagged', () {
      final p = preview(150000);
      expect(p.interest, const Money(147945));
      expect(p.principal, const Money.rupees(100000));
      expect(p.surplus, const Money(4852055));
      expect(p.exceedsPayable, isTrue);
      expect(p.payableAfter, Money.zero);
    });

    test('a repayment dated before a later event still counts them all', () {
      final evs = [...events, jama('2027-02-10', 10000)];
      final p = preview(5000, evs: evs);
      // as of 10 Feb the earlier 10,000 repayment exists; the new one is
      // applied on 31 Jan, so its interest part is the 30 days of interest.
      expect(p.interest, const Money(147945));
      expect(p.payableBefore.paise, greaterThan(0));
      expect(p.asOf, d('2027-02-10'));
    });

    test('zero or negative amount is rejected', () {
      expect(
        () => LoanRules.previewRepayment(
          events: events,
          config: config,
          repaymentDate: d('2027-01-31'),
          amount: Money.zero,
        ),
        throwsArgumentError,
      );
    });
  });

  group('validateIssue', () {
    List<LoanProblem> check({
      Money? amount,
      LedgerDate? due,
      String? guarantor,
      String party = 'p1',
      String rate = '18',
    }) => LoanRules.validateIssue(
      amount: amount ?? const Money.rupees(1000),
      issueDate: issued,
      dueDate: due,
      partyId: party,
      guarantorId: guarantor,
      ratePa: rate,
    );

    test('a good loan has no problems', () {
      expect(check(due: d('2027-06-01'), guarantor: 'p2'), isEmpty);
    });

    test('amount must be positive', () {
      expect(check(amount: Money.zero), [LoanProblem.amountNotPositive]);
    });

    test('due date cannot be before the issue date, the same day is fine', () {
      expect(check(due: d('2026-12-31')), [LoanProblem.dueBeforeIssue]);
      expect(check(due: issued), isEmpty);
    });

    test('the borrower cannot guarantee their own loan', () {
      expect(check(guarantor: 'p1'), [LoanProblem.guarantorIsBorrower]);
    });

    test('rate: 0 to 100, at most 4 decimals', () {
      expect(check(rate: '0'), isEmpty);
      expect(check(rate: '100'), isEmpty);
      expect(check(rate: '24.5'), isEmpty);
      for (final bad in ['', 'abc', '-1', '100.01', '1.23456', '1e2', ' ']) {
        expect(check(rate: bad), [LoanProblem.rateInvalid], reason: bad);
      }
    });
  });

  group('parseRate', () {
    test('valid rates', () {
      expect(LoanRules.parseRate('18'), Decimal.parse('18'));
      expect(LoanRules.parseRate(' 1.5 '), Decimal.parse('1.5'));
      expect(LoanRules.parseRate('0.0001'), Decimal.parse('0.0001'));
    });
    test('invalid rates are null', () {
      expect(LoanRules.parseRate('x'), isNull);
      expect(LoanRules.parseRate('101'), isNull);
      expect(LoanRules.parseRate('-0.5'), isNull);
      expect(LoanRules.parseRate('1.00001'), isNull);
    });
  });

  group('validateRateChange', () {
    List<LoanProblem> check(String rate, String eff, {LedgerDate? closed}) =>
        LoanRules.validateRateChange(
          ratePa: rate,
          effectiveDate: d(eff),
          issueDate: issued,
          status: closed == null ? LoanStatus.active : LoanStatus.closed,
        );

    test('on or after the issue date, valid rate, open loan', () {
      expect(check('24', '2027-01-16'), isEmpty);
      expect(check('24', '2027-01-01'), isEmpty);
    });
    test('before the issue date is refused', () {
      expect(check('24', '2026-12-31'), [LoanProblem.effectiveBeforeIssue]);
    });
    test('bad rate is refused', () {
      expect(check('abc', '2027-01-16'), [LoanProblem.rateInvalid]);
    });
    test('a closed loan has no rate changes', () {
      expect(check('24', '2027-01-16', closed: issued), [
        LoanProblem.notActive,
      ]);
    });
  });

  group('close and write off', () {
    final open = position(asOf: d('2027-01-31'));
    final settled = LoanRules.position(
      principal: const Money.rupees(100000),
      events: [udhaar('2027-01-01', 100000), jama('2027-01-01', 100000)],
      config: config,
      asOf: d('2027-01-31'),
      status: LoanStatus.active,
    );

    test('close needs nothing left to pay', () {
      expect(
        LoanRules.validateClose(
          position: open,
          closedOn: d('2027-01-31'),
          issueDate: issued,
          lastEventDate: issued,
        ),
        [LoanProblem.amountStillDue],
      );
      expect(
        LoanRules.validateClose(
          position: settled,
          closedOn: d('2027-01-31'),
          issueDate: issued,
          lastEventDate: issued,
        ),
        isEmpty,
      );
    });

    test('close needs the interest posted, once nothing is payable', () {
      List<LoanProblem> close(LoanPosition p, int unposted) =>
          LoanRules.validateClose(
            position: p,
            closedOn: d('2027-01-31'),
            issueDate: issued,
            lastEventDate: issued,
            unpostedInterestPaise: unposted,
          );
      expect(close(settled, 1), [LoanProblem.interestNotPosted]);
      expect(close(settled, 0), isEmpty);
      // Still payable: only that is said.
      expect(close(open, 500), [LoanProblem.amountStillDue]);
    });

    test('write-off needs something to write off and a reason', () {
      expect(
        LoanRules.validateWriteOff(
          position: open,
          closedOn: d('2027-01-31'),
          issueDate: issued,
          lastEventDate: issued,
          reason: '  ',
        ),
        [LoanProblem.reasonMissing],
      );
      expect(
        LoanRules.validateWriteOff(
          position: open,
          closedOn: d('2027-01-31'),
          issueDate: issued,
          lastEventDate: issued,
          reason: 'Farmer died, family has no means',
        ),
        isEmpty,
      );
      expect(
        LoanRules.validateWriteOff(
          position: settled,
          closedOn: d('2027-01-31'),
          issueDate: issued,
          lastEventDate: issued,
          reason: 'x',
        ),
        [LoanProblem.nothingToWriteOff],
      );
    });

    test('the closing date cannot be before the last entry of the loan', () {
      expect(
        LoanRules.validateClose(
          position: settled,
          closedOn: d('2027-01-10'),
          issueDate: issued,
          lastEventDate: d('2027-01-20'),
        ),
        [LoanProblem.closedBeforeLastEntry],
      );
    });

    test('a write-off cannot be dated before the last entry either', () {
      expect(
        LoanRules.validateWriteOff(
          position: open,
          closedOn: d('2027-01-10'),
          issueDate: issued,
          lastEventDate: d('2027-01-20'),
          reason: 'Gone',
        ),
        [LoanProblem.closedBeforeLastEntry],
      );
    });

    test('a loan that is not active cannot be closed again', () {
      final closed = position(status: LoanStatus.closed, closedOn: issued);
      expect(
        LoanRules.validateClose(
          position: closed,
          closedOn: d('2027-01-31'),
          issueDate: issued,
          lastEventDate: issued,
        ),
        [LoanProblem.notActive],
      );
      expect(
        LoanRules.validateWriteOff(
          position: closed,
          closedOn: d('2027-01-31'),
          issueDate: issued,
          lastEventDate: issued,
          reason: 'x',
        ),
        [LoanProblem.notActive],
      );
    });
  });

  group('crop proceeds', () {
    test('only a credit (we owe the party) can be adjusted', () {
      expect(
        LoanRules.cropProceedsAvailable(const Money(500000)),
        const Money(500000),
      );
      expect(LoanRules.cropProceedsAvailable(Money.zero), Money.zero);
      expect(LoanRules.cropProceedsAvailable(const Money(-500000)), Money.zero);
    });
  });

  group('permissions', () {
    test('issue, rate change, close and write-off are owner-level', () {
      for (final a in [
        LoanAction.issue,
        LoanAction.changeRate,
        LoanAction.close,
        LoanAction.writeOff,
      ]) {
        expect(LoanRules.requiredPermissions(a), [Permission.loansManage]);
      }
    });
    test('a repayment needs payments.create, crop proceeds also reverse', () {
      expect(LoanRules.requiredPermissions(LoanAction.repay), [
        Permission.paymentsCreate,
      ]);
      expect(LoanRules.requiredPermissions(LoanAction.adjustFromCrop), [
        Permission.paymentsCreate,
        Permission.entriesReverse,
      ]);
    });
  });
}
