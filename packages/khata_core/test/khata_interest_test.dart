import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

import 'interest/helpers.dart';

LedgerEntry entry(
  String id,
  String date,
  Side side,
  int rupeesAmount, {
  RefType refType = RefType.journal,
  String? reverses,
}) => LedgerEntry(
  id: id,
  partyId: 'p1',
  entryDate: d(date),
  side: side,
  amount: Money(rupees(rupeesAmount)),
  refType: refType,
  createdAt: DateTime.utc(2027),
  reversesId: reverses,
);

void main() {
  group('KhataInterest.events', () {
    test('drops reversals and the entries they reverse', () {
      final events = KhataInterest.events([
        entry('a', '2027-01-01', Side.udhaar, 1000),
        entry('b', '2027-01-02', Side.udhaar, 500),
        entry(
          'r',
          '2027-01-03',
          Side.jama,
          500,
          refType: RefType.reversal,
          reverses: 'b',
        ),
        entry('c', '2027-01-03', Side.udhaar, 700),
      ]);
      expect(events.map((e) => e.id), ['a', 'c']);
    });

    test('flags posted interest so the engine ignores it', () {
      final events = KhataInterest.events([
        entry('a', '2027-01-01', Side.udhaar, 1000),
        entry('i', '2027-02-01', Side.udhaar, 50, refType: RefType.interest),
      ]);
      expect(events.map((e) => e.isPostedInterest), [false, true]);
    });

    test('loan entries stay in the khata (net_udhaar: one account)', () {
      final events = KhataInterest.events([
        entry(
          'l',
          '2027-01-01',
          Side.udhaar,
          1000,
          refType: RefType.loanDisbursal,
        ),
        entry(
          'r',
          '2027-01-10',
          Side.jama,
          200,
          refType: RefType.loanRepayment,
        ),
      ]);
      expect(events, hasLength(2));
    });
  });

  group('KhataInterest.mode', () {
    test('follows apply_on and enabled', () {
      expect(KhataInterest.mode(cfg()), KhataInterestMode.khata);
      expect(
        KhataInterest.mode(cfg(applyOn: ApplyOn.loansOnly)),
        KhataInterestMode.loansOnly,
      );
      expect(
        KhataInterest.mode(cfg(applyOn: ApplyOn.none)),
        KhataInterestMode.off,
      );
      expect(KhataInterest.mode(cfg(enabled: false)), KhataInterestMode.off);
    });

    test('only khata mode swallows loans into the khata', () {
      expect(KhataInterest.includesLoans(cfg()), isTrue);
      expect(
        KhataInterest.includesLoans(cfg(applyOn: ApplyOn.loansOnly)),
        isFalse,
      );
      expect(KhataInterest.includesLoans(cfg(enabled: false)), isFalse);
    });
  });

  group('KhataInterest.calculate', () {
    final entries = [
      entry('a', '2027-01-01', Side.udhaar, 100000),
      entry('x', '2027-01-05', Side.udhaar, 999),
      entry(
        'rx',
        '2027-01-06',
        Side.jama,
        999,
        refType: RefType.reversal,
        reverses: 'x',
      ),
    ];

    test('khata mode: 1,00,000 for 30 days at 18% = 1,479.45', () {
      final r = KhataInterest.calculate(
        entries: entries,
        config: cfg(),
        asOf: d('2027-01-31'),
      );
      expect(r.principalPaise, rupees(100000));
      expect(r.accruedUnpaidPaise, 147945);
    });

    test('loans_only mode runs no khata engine (no double charge)', () {
      final r = KhataInterest.calculate(
        entries: entries,
        config: cfg(applyOn: ApplyOn.loansOnly),
        asOf: d('2027-01-31'),
      );
      expect(r.accruedUnpaidPaise, 0);
      expect(r.schedule, isEmpty);
    });

    test('off mode charges nothing but still tracks principal', () {
      final r = KhataInterest.calculate(
        entries: entries,
        config: cfg(applyOn: ApplyOn.none),
        asOf: d('2027-01-31'),
      );
      expect(r.accruedUnpaidPaise, 0);
      expect(r.principalPaise, rupees(100000));
    });
  });
}
