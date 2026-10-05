import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

import 'interest/helpers.dart';

InterestResult run(
  List<LedgerEvent> events,
  String asOf, {
  InterestConfig? config,
}) => calculate(events: events, config: config ?? cfg(), asOf: d(asOf));

void main() {
  // 1,00,000 at 18% p.a./365: 100 days = 4,931.51; 130 days = 6,410.96.
  final debit = udhaar('2027-01-01', 100000);

  group('InterestPosting.charged / unposted', () {
    test('nothing posted: all accrued interest is unposted', () {
      final r = run([debit], '2027-04-11');
      expect(InterestPosting.charged(r), 493151);
      expect(InterestPosting.unposted(r, postedPaise: 0), 493151);
    });

    test('posted interest is taken off, later days add up', () {
      final r = run([debit], '2027-05-11');
      expect(InterestPosting.unposted(r, postedPaise: 493151), 641096 - 493151);
    });

    test('a repayment of interest does not make it unposted again', () {
      // 4,931.51 posted on 11 Apr, then the party pays 10,000 (interest
      // first): the charged total is unchanged, so nothing new to post.
      final r = run([debit, jama('2027-04-11', 10000)], '2027-04-11');
      expect(InterestPosting.charged(r), 493151);
      expect(InterestPosting.unposted(r, postedPaise: 493151), 0);
    });

    test('a waiver keeps the charged total (it was charged, then waived)', () {
      final w = LedgerEvent(
        id: 'w',
        date: d('2027-04-11'),
        side: Side.jama,
        amountPaise: 493151,
        interestOnly: true,
      );
      final r = run([debit, w], '2027-04-11');
      expect(r.accruedUnpaidPaise, 0);
      expect(InterestPosting.charged(r), 493151);
      expect(InterestPosting.unposted(r, postedPaise: 493151), 0);
    });

    test('compounded interest counts as charged', () {
      final r = run(
        [debit],
        '2027-07-01',
        config: cfg(method: InterestMethod.compound),
      );
      final capital = r.schedule
          .where((x) => x.kind == InterestRowKind.compound)
          .fold<int>(0, (sum, x) => sum + x.amountPaise);
      expect(capital, greaterThan(0));
      expect(InterestPosting.charged(r), r.accruedUnpaidPaise + capital);
    });

    test('never negative when more was posted than charged', () {
      final r = run([debit], '2027-04-11');
      expect(InterestPosting.unposted(r, postedPaise: 999999), 0);
    });
  });

  group('InterestPosting.plan', () {
    final result = run([debit], '2027-04-11');

    test('builds the preview with its period and key', () {
      final plan = InterestPosting.plan(
        scope: PostingScope.khata,
        partyId: 'p1',
        result: result,
        config: cfg(),
        firstEventDate: d('2027-01-01'),
        asOf: d('2027-04-11'),
        postedPaise: 0,
      )!;
      expect(plan.amountPaise, 493151);
      expect(plan.amount, const Money(493151));
      expect(plan.from, d('2027-01-01'));
      expect(plan.to, d('2027-04-11'));
      expect(plan.periodKey, 'interest:khata:p1:2027-04-11');
      expect(plan.ratePa.toString(), '18');
      expect(plan.method, InterestMethod.simple);
      expect(plan.loanId, isNull);
    });

    test('the next period starts where the last posting ended', () {
      final later = run([debit], '2027-05-11');
      final plan = InterestPosting.plan(
        scope: PostingScope.khata,
        partyId: 'p1',
        result: later,
        config: cfg(),
        firstEventDate: d('2027-01-01'),
        lastPostedTo: d('2027-04-11'),
        asOf: d('2027-05-11'),
        postedPaise: 493151,
      )!;
      expect(plan.from, d('2027-04-11'));
      expect(plan.amountPaise, 147945);
    });

    test('a loan has its own key', () {
      final plan = InterestPosting.plan(
        scope: PostingScope.loan,
        partyId: 'p1',
        loanId: 'L1',
        result: result,
        config: cfg(),
        firstEventDate: d('2027-01-01'),
        asOf: d('2027-04-11'),
        postedPaise: 0,
      )!;
      expect(plan.periodKey, 'interest:loan:L1:2027-04-11');
      expect(plan.loanId, 'L1');
    });

    test('nothing to post gives no plan', () {
      expect(
        InterestPosting.plan(
          scope: PostingScope.khata,
          partyId: 'p1',
          result: result,
          config: cfg(),
          firstEventDate: d('2027-01-01'),
          asOf: d('2027-04-11'),
          postedPaise: 493151,
        ),
        isNull,
      );
    });

    test('interest switched off gives no plan', () {
      final off = cfg(enabled: false);
      expect(
        InterestPosting.plan(
          scope: PostingScope.khata,
          partyId: 'p1',
          result: run([debit], '2027-04-11', config: off),
          config: off,
          firstEventDate: d('2027-01-01'),
          asOf: d('2027-04-11'),
          postedPaise: 0,
        ),
        isNull,
      );
    });

    test('loan scope needs a loan id, khata scope refuses one', () {
      expect(
        () => InterestPosting.plan(
          scope: PostingScope.loan,
          partyId: 'p1',
          result: result,
          config: cfg(),
          firstEventDate: d('2027-01-01'),
          asOf: d('2027-04-11'),
          postedPaise: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => InterestPosting.plan(
          scope: PostingScope.khata,
          partyId: 'p1',
          loanId: 'L1',
          result: result,
          config: cfg(),
          firstEventDate: d('2027-01-01'),
          asOf: d('2027-04-11'),
          postedPaise: 0,
        ),
        throwsArgumentError,
      );
    });

    test('the narration says what the amount is for', () {
      final plan = InterestPosting.plan(
        scope: PostingScope.khata,
        partyId: 'p1',
        result: result,
        config: cfg(),
        firstEventDate: d('2027-01-01'),
        asOf: d('2027-04-11'),
        postedPaise: 0,
      )!;
      expect(plan.meta, {
        'from': '2027-01-01',
        'to': '2027-04-11',
        'rate_pa': '18',
        'method': 'simple',
        'amount_paise': 493151,
      });
    });
  });

  group('KhataInterest.events with waivers', () {
    test('flags the entries that are waivers', () {
      LedgerEntry e(String id, String? ref) => LedgerEntry(
        id: id,
        partyId: 'p1',
        entryDate: d('2027-04-11'),
        side: Side.jama,
        amount: const Money(1000),
        refType: RefType.journal,
        refId: ref,
        createdAt: DateTime.utc(2027),
      );
      final events = KhataInterest.events(
        [e('a', null), e('b', 'waiver-1')],
        waiverIds: {'waiver-1'},
      );
      expect(events.map((x) => x.interestOnly), [false, true]);
    });
  });

  group('Settlement', () {
    SettlementSource source(int unposted, {String? loanId}) => SettlementSource(
      scope: loanId == null ? PostingScope.khata : PostingScope.loan,
      loanId: loanId,
      unpostedPaise: unposted,
    );

    test('farmer owes principal and interest: receivable', () {
      // balance -1,00,000 (udhaar), interest 4,931.51 not posted yet.
      final s = Settlement.compute(
        balance: const Money(-10000000),
        sources: [source(493151)],
      );
      expect(s.unposted, const Money(493151));
      expect(s.finalBalance, const Money(-10493151));
      expect(s.direction, SettlementDirection.receivable);
    });

    test('a waiver lowers what is due', () {
      final s = Settlement.compute(
        balance: const Money(-10000000),
        sources: [source(493151)],
        waivers: const {SettlementSource.khataKey: 93151},
      );
      expect(s.waiver, const Money(93151));
      expect(s.finalBalance, const Money(-10400000));
    });

    test('credit balance (we owe the party) and interest net off', () {
      final s = Settlement.compute(
        balance: const Money(500000),
        sources: [source(120000)],
      );
      expect(s.finalBalance, const Money(380000));
      expect(s.direction, SettlementDirection.payable);
    });

    test('zero is settled', () {
      final s = Settlement.compute(balance: Money.zero, sources: const []);
      expect(s.direction, SettlementDirection.settled);
    });

    test('waiver problems: too much, no reason, unknown source', () {
      final sources = [source(1000), source(500, loanId: 'L1')];
      expect(
        Settlement.validate(
          sources: sources,
          waivers: {SettlementSource.khataKey: 1001},
          reason: 'x',
        ),
        [SettlementProblem.waiverExceedsInterest],
      );
      expect(
        Settlement.validate(
          sources: sources,
          waivers: {SettlementSource.khataKey: 100},
          reason: '  ',
        ),
        [SettlementProblem.reasonRequired],
      );
      expect(
        Settlement.validate(
          sources: sources,
          waivers: {'loan:L9': 100},
          reason: 'x',
        ),
        [SettlementProblem.unknownSource],
      );
      expect(
        Settlement.validate(
          sources: sources,
          waivers: {SettlementSource.khataKey: -5},
          reason: 'x',
        ),
        [SettlementProblem.waiverNegative],
      );
      expect(
        Settlement.validate(
          sources: sources,
          waivers: {SettlementSource.khataKey: 1000, 'loan:L1': 500},
          reason: 'diwali',
        ),
        isEmpty,
      );
      expect(
        Settlement.validate(sources: sources, waivers: {}, reason: ''),
        isEmpty,
      );
    });
  });

  group('PostingSchedule.suggestedAsOf', () {
    LedgerDate on(String frequency, String today) =>
        PostingSchedule.suggestedAsOf(frequency, d(today));

    test('on demand: today', () {
      expect(on('on_demand', '2027-05-17'), d('2027-05-17'));
    });

    test('monthly: the 1st of this month (interest up to the month end)', () {
      expect(on('monthly', '2027-05-17'), d('2027-05-01'));
      expect(on('monthly', '2027-05-01'), d('2027-05-01'));
    });

    test('quarterly: the latest 1 Apr / 1 Jul / 1 Oct / 1 Jan', () {
      expect(on('quarterly', '2027-05-17'), d('2027-04-01'));
      expect(on('quarterly', '2027-07-01'), d('2027-07-01'));
      expect(on('quarterly', '2027-12-31'), d('2027-10-01'));
      expect(on('quarterly', '2027-02-10'), d('2027-01-01'));
    });

    test('fy close: 1 April, so interest runs to 31 March', () {
      expect(on('fy_close', '2027-05-17'), d('2027-04-01'));
      expect(on('fy_close', '2027-03-31'), d('2026-04-01'));
      expect(on('fy_close', '2027-04-01'), d('2027-04-01'));
    });

    test('an unknown frequency is treated as on demand', () {
      expect(on('weekly', '2027-05-17'), d('2027-05-17'));
    });
  });

  group('InterestPostingPlan.entryDate', () {
    test('is the last day interest runs: the day before `to`', () {
      final plan = InterestPosting.plan(
        scope: PostingScope.khata,
        partyId: 'p1',
        result: run([debit], '2027-04-01'),
        config: cfg(),
        firstEventDate: d('2027-01-01'),
        asOf: d('2027-04-01'),
        postedPaise: 0,
      )!;
      expect(plan.entryDate, d('2027-03-31'));
    });
  });
}
