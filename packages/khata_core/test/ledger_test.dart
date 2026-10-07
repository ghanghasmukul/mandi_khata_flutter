import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

const _party = 'party-1';

var _seq = 0;

/// An entry on [date] (yyyy-mm-dd), recorded at [time] (UTC, same day by
/// default), for [rupees].
LedgerEntry entry(
  String date,
  Side side,
  int rupees, {
  String? id,
  RefType refType = RefType.journal,
  String? time,
  String? reversesId,
  String? replacesId,
}) {
  _seq++;
  return LedgerEntry(
    id: id ?? 'e$_seq',
    partyId: _party,
    entryDate: LedgerDate.parse(date),
    side: side,
    amount: Money(rupees * 100),
    refType: refType,
    createdAt: DateTime.parse('${date}T${time ?? '10:00:00'}Z'),
    reversesId: reversesId,
    replacesId: replacesId,
  );
}

Money rs(int rupees) => Money(rupees * 100);

void main() {
  group('LedgerDate', () {
    test('parses and prints yyyy-mm-dd', () {
      final d = LedgerDate.parse('2026-04-01');
      expect(d.toString(), '2026-04-01');
      expect(d, LedgerDate(2026, 4, 1));
      expect(d.hashCode, LedgerDate(2026, 4, 1).hashCode);
    });

    test('orders by calendar day', () {
      expect(LedgerDate(2026, 3, 31) < LedgerDate(2026, 4, 1), isTrue);
      expect(LedgerDate(2026, 4, 1) <= LedgerDate(2026, 4, 1), isTrue);
      expect(LedgerDate(2026, 4, 2) > LedgerDate(2026, 4, 1), isTrue);
      expect(LedgerDate(2026, 4, 1) >= LedgerDate(2026, 4, 2), isFalse);
      expect(LedgerDate(2025, 12, 31).compareTo(LedgerDate(2026, 1, 1)), -1);
    });

    test('from a DateTime keeps the calendar day', () {
      expect(
        LedgerDate.fromDateTime(DateTime(2026, 9, 30, 23, 59)),
        LedgerDate(2026, 9, 30),
      );
    });

    test('adds days across months and years; counts days between', () {
      expect(LedgerDate(2026, 3, 30).addDays(3), LedgerDate(2026, 4, 2));
      expect(LedgerDate(2026, 1, 2).addDays(-3), LedgerDate(2025, 12, 30));
      expect(LedgerDate(2028, 2, 28).addDays(1), LedgerDate(2028, 2, 29));
      expect(LedgerDate(2026, 3, 29).daysUntil(LedgerDate(2026, 4, 1)), 3);
      expect(LedgerDate(2026, 4, 1).daysUntil(LedgerDate(2026, 3, 29)), -3);
      expect(LedgerDate(2025, 4, 1).daysUntil(LedgerDate(2026, 4, 1)), 365);
    });

    test('rejects impossible dates and bad text', () {
      expect(() => LedgerDate(2026, 2, 30), throwsArgumentError);
      expect(() => LedgerDate.parse('30-09-2026'), throwsFormatException);
      expect(() => LedgerDate.parse('2026-13-01'), throwsFormatException);
    });
  });

  group('Side and RefType', () {
    test('db names round-trip', () {
      for (final s in Side.values) {
        expect(Side.parse(s.dbName), s);
      }
      for (final r in RefType.values) {
        expect(RefType.parse(r.dbName), r);
      }
      expect(RefType.shopSale.dbName, 'shop_sale');
      expect(RefType.openingBalance.dbName, 'opening_balance');
      expect(() => Side.parse('credit'), throwsFormatException);
      expect(() => RefType.parse('gift'), throwsFormatException);
    });

    test('opposite side', () {
      expect(Side.udhaar.opposite, Side.jama);
      expect(Side.jama.opposite, Side.udhaar);
    });
  });

  group('LedgerEntry', () {
    test('jama counts positive, udhaar negative', () {
      expect(entry('2026-04-01', Side.jama, 500).signed, rs(500));
      expect(entry('2026-04-01', Side.udhaar, 500).signed, rs(-500));
    });

    test('amount must be positive', () {
      expect(() => entry('2026-04-01', Side.jama, 0), throwsArgumentError);
      expect(() => entry('2026-04-01', Side.jama, -5), throwsArgumentError);
    });

    test('a reversal must point at the entry it reverses, and only then', () {
      expect(
        () => entry('2026-04-01', Side.jama, 5, refType: RefType.reversal),
        throwsArgumentError,
      );
      expect(
        () => entry('2026-04-01', Side.jama, 5, reversesId: 'x'),
        throwsArgumentError,
      );
    });
  });

  group('ReversalBuilder', () {
    final original = entry(
      '2026-04-10',
      Side.jama,
      15558,
      id: 'orig',
      refType: RefType.arrival,
    );

    test('opposite side, same amount and party, points back', () {
      final r = ReversalBuilder.reverse(
        original,
        id: 'rev',
        createdAt: DateTime.utc(2026, 4, 12, 9),
      );
      expect(r.side, Side.udhaar);
      expect(r.amount, original.amount);
      expect(r.partyId, original.partyId);
      expect(r.refType, RefType.reversal);
      expect(r.refId, isNull);
      expect(r.reversesId, 'orig');
      // Dated like the original so balances on past dates are corrected.
      expect(r.entryDate, original.entryDate);
      expect(original.signed + r.signed, Money.zero);
    });

    test('can be dated when the reversal happened (bounced cheque)', () {
      final r = ReversalBuilder.reverse(
        original,
        id: 'rev',
        createdAt: DateTime.utc(2026, 4, 20),
        entryDate: LedgerDate(2026, 4, 20),
        narration: 'Cheque 004512 bounced',
      );
      expect(r.entryDate, LedgerDate(2026, 4, 20));
      expect(r.narration, 'Cheque 004512 bounced');
    });

    test('a reversal cannot itself be reversed (post a new entry)', () {
      final r = ReversalBuilder.reverse(
        original,
        id: 'rev',
        createdAt: DateTime.utc(2026, 4, 12),
      );
      expect(
        () =>
            ReversalBuilder.reverse(r, id: 'x', createdAt: DateTime.utc(2026)),
        throwsArgumentError,
      );
    });

    test('correction = reversal + replacement linked to the original', () {
      final c = ReversalBuilder.correct(
        original,
        reversalId: 'rev',
        replacementId: 'new',
        createdAt: DateTime.utc(2026, 4, 12, 9),
        amount: rs(15000),
      );
      expect(c.reversal.reversesId, 'orig');
      expect(c.replacement.replacesId, 'orig');
      expect(c.replacement.amount, rs(15000));
      // Everything not changed is carried over.
      expect(c.replacement.side, original.side);
      expect(c.replacement.refType, RefType.arrival);
      expect(c.replacement.entryDate, original.entryDate);
      expect(c.replacement.partyId, original.partyId);
      final entries = [original, c.reversal, c.replacement];
      expect(LedgerCalculator.balance(entries), rs(15000));
    });

    test('a correction can change side, date and narration', () {
      final c = ReversalBuilder.correct(
        original,
        reversalId: 'rev',
        replacementId: 'new',
        createdAt: DateTime.utc(2026, 4, 12),
        side: Side.udhaar,
        entryDate: LedgerDate(2026, 4, 11),
        narration: 'typo',
      );
      expect(c.replacement.side, Side.udhaar);
      expect(c.replacement.entryDate, LedgerDate(2026, 4, 11));
      expect(c.replacement.narration, 'typo');
      expect(c.replacement.amount, original.amount);
    });
  });

  group('LedgerCalculator', () {
    // Worked example (one farmer, April 2026):
    //   01-04 opening balance, party owes  ₹2,000 (udhaar)  → −2,000
    //   05-04 crop sold, net to farmer    ₹15,558 (jama)    → 13,558
    //   05-04 cash paid                    ₹5,000 (udhaar)  →  8,558
    //   09-04 wrong entry                    ₹999 (jama)    →  9,557
    //   09-04 …reversed                      ₹999 (udhaar)  →  8,558
    //   12-04 fertiliser on credit         ₹1,250 (udhaar)  →  7,308
    late List<LedgerEntry> april;
    setUp(() {
      april = [
        entry(
          '2026-04-12',
          Side.udhaar,
          1250,
          id: 'shop',
          refType: RefType.shopSale,
        ),
        entry(
          '2026-04-05',
          Side.udhaar,
          5000,
          id: 'pay',
          refType: RefType.payment,
          time: '15:00:00',
        ),
        entry(
          '2026-04-05',
          Side.jama,
          15558,
          id: 'crop',
          refType: RefType.arrival,
          time: '11:00:00',
        ),
        entry(
          '2026-04-01',
          Side.udhaar,
          2000,
          id: 'open',
          refType: RefType.openingBalance,
        ),
        entry('2026-04-09', Side.jama, 999, id: 'oops'),
        entry(
          '2026-04-09',
          Side.udhaar,
          999,
          id: 'oops-rev',
          refType: RefType.reversal,
          reversesId: 'oops',
          time: '10:05:00',
        ),
      ];
    });

    test('balance = Σ jama − Σ udhaar', () {
      expect(LedgerCalculator.balance(april), rs(7308));
      expect(LedgerCalculator.balance(const []), Money.zero);
    });

    test('balance as of a date includes that whole day', () {
      const asOf = LedgerCalculator.balanceAsOf;
      expect(asOf(april, LedgerDate(2026, 3, 31)), Money.zero);
      expect(asOf(april, LedgerDate(2026, 4, 1)), rs(-2000));
      expect(asOf(april, LedgerDate(2026, 4, 5)), rs(8558));
      expect(asOf(april, LedgerDate(2026, 4, 9)), rs(8558));
      expect(asOf(april, LedgerDate(2026, 4, 30)), rs(7308));
    });

    test('order: entry date, then time recorded, then id', () {
      final sameMoment = [
        entry('2026-04-05', Side.jama, 1, id: 'b'),
        entry('2026-04-05', Side.jama, 1, id: 'a'),
        entry('2026-04-05', Side.jama, 1, id: 'c', time: '09:00:00'),
        entry('2026-04-04', Side.jama, 1, id: 'd', time: '23:00:00'),
      ];
      expect(LedgerCalculator.sorted(sameMoment).map((e) => e.id), [
        'd',
        'c',
        'a',
        'b',
      ]);
    });

    test('statement: running baki row by row', () {
      final s = LedgerCalculator.statement(april);
      expect(s.opening, Money.zero);
      expect(s.rows.map((r) => r.entry.id), [
        'open',
        'crop',
        'pay',
        'oops',
        'oops-rev',
        'shop',
      ]);
      expect(s.rows.map((r) => r.balance.paise ~/ 100), [
        -2000,
        13558,
        8558,
        9557,
        8558,
        7308,
      ]);
      expect(s.closing, rs(7308));
      expect(s.totalJama, rs(15558 + 999));
      expect(s.totalUdhaar, rs(2000 + 5000 + 999 + 1250));
    });

    test('statement marks both halves of a reversed pair', () {
      final rows = {
        for (final r in LedgerCalculator.statement(april).rows) r.entry.id: r,
      };
      expect(rows['oops']!.reversedById, 'oops-rev');
      expect(rows['oops']!.isStruck, isTrue);
      expect(rows['oops-rev']!.isStruck, isTrue);
      expect(rows['crop']!.isStruck, isFalse);
      expect(rows['crop']!.reversedById, isNull);
    });

    test('statement for a period starts from the balance brought forward', () {
      final s = LedgerCalculator.statement(
        april,
        from: LedgerDate(2026, 4, 6),
        to: LedgerDate(2026, 4, 10),
      );
      expect(s.opening, rs(8558));
      expect(s.rows.map((r) => r.entry.id), ['oops', 'oops-rev']);
      expect(s.closing, rs(8558));
      expect(s.totalJama, rs(999));
      expect(s.totalUdhaar, rs(999));
    });

    test('statement for a period with no entries', () {
      final s = LedgerCalculator.statement(april, from: LedgerDate(2026, 5, 1));
      expect(s.rows, isEmpty);
      expect(s.opening, rs(7308));
      expect(s.closing, rs(7308));
    });

    test('reversal pairing', () {
      expect(LedgerCalculator.reversalPairs(april), {'oops': 'oops-rev'});
    });

    test('totals by ref type: a reversal nets against what it reversed', () {
      final t = LedgerCalculator.totalsByRefType(april);
      expect(t[RefType.arrival], (udhaar: Money.zero, jama: rs(15558)));
      expect(t[RefType.payment], (udhaar: rs(5000), jama: Money.zero));
      expect(t[RefType.openingBalance], (udhaar: rs(2000), jama: Money.zero));
      expect(t[RefType.shopSale], (udhaar: rs(1250), jama: Money.zero));
      expect(t[RefType.journal], (udhaar: rs(999), jama: rs(999)));
      expect(t.containsKey(RefType.reversal), isFalse);
    });

    test('a reversal whose original is not in the list stays a reversal', () {
      final t = LedgerCalculator.totalsByRefType([
        entry(
          '2026-04-09',
          Side.udhaar,
          10,
          refType: RefType.reversal,
          reversesId: 'elsewhere',
        ),
      ]);
      expect(t[RefType.reversal], (udhaar: rs(10), jama: Money.zero));
    });

    test('an edit via reversal leaves only the corrected amount', () {
      final crop = april.firstWhere((e) => e.id == 'crop');
      final fix = ReversalBuilder.correct(
        crop,
        reversalId: 'crop-rev',
        replacementId: 'crop-2',
        createdAt: DateTime.utc(2026, 4, 13),
        amount: rs(15000),
      );
      final all = [...april, fix.reversal, fix.replacement];
      expect(LedgerCalculator.balance(all), rs(7308 - 558));
      // Back-dated with the original, so 05-04 is corrected as well.
      expect(
        LedgerCalculator.balanceAsOf(all, LedgerDate(2026, 4, 5)),
        rs(8000),
      );
      expect(LedgerCalculator.reversalPairs(all)['crop'], 'crop-rev');
      expect(LedgerCalculator.totalsByRefType(all)[RefType.arrival], (
        udhaar: rs(15558),
        jama: rs(15558 + 15000),
      ));
    });

    test('paise are never lost (no floating point)', () {
      final entries = [
        for (var i = 0; i < 1000; i++)
          LedgerEntry(
            id: 'p$i',
            partyId: _party,
            entryDate: LedgerDate(2026, 4, 1),
            side: Side.jama,
            amount: const Money(1),
            refType: RefType.journal,
            createdAt: DateTime.utc(2026, 4),
          ),
      ];
      expect(LedgerCalculator.balance(entries), const Money(1000));
    });
  });

  group('LedgerPosting (mirrors private.ledger_post_permission)', () {
    Permission? need(RefType t, {bool correction = false}) =>
        LedgerPosting.requiredPermission(t, isCorrection: correction);

    test('changing the books needs entries.reverse', () {
      expect(need(RefType.reversal), Permission.entriesReverse);
      expect(need(RefType.journal), Permission.entriesReverse);
      expect(need(RefType.openingBalance), Permission.entriesReverse);
      expect(
        need(RefType.payment, correction: true),
        Permission.entriesReverse,
      );
    });

    test('documents need their own permission', () {
      expect(need(RefType.arrival), Permission.arrivalsManage);
      expect(need(RefType.payment), Permission.paymentsCreate);
      expect(need(RefType.receipt), Permission.paymentsCreate);
      expect(need(RefType.loanRepayment), Permission.paymentsCreate);
      expect(need(RefType.loanDisbursal), Permission.loansManage);
      expect(need(RefType.interest), Permission.loansManage);
    });

    test('shop entries need their document right; expenses any member', () {
      expect(need(RefType.shopSale), Permission.salesCreate);
      expect(need(RefType.shopReturn), Permission.salesReturn);
      expect(need(RefType.purchase), Permission.purchasesCreate);
      expect(need(RefType.purchaseReturn), Permission.purchasesCreate);
      expect(need(RefType.expense), isNull);
    });

    test('a munshi posts payments and arrivals but cannot reverse', () {
      bool munshi(RefType t) {
        final p = need(t);
        return p == null || MemberRole.munshi.allows(p);
      }

      expect(munshi(RefType.payment), isTrue);
      expect(munshi(RefType.arrival), isTrue);
      expect(munshi(RefType.reversal), isFalse);
      expect(munshi(RefType.journal), isFalse);
      expect(munshi(RefType.loanDisbursal), isFalse);
    });
  });

  group(
    'LedgerPosting back-dating (mirrors private.ledger_date_restricted)',
    () {
      final today = LedgerDate(2026, 10, 1);
      bool restricted(LedgerDate d, {int days = 3}) =>
          LedgerPosting.dateNeedsOverride(
            entryDate: d,
            recordedOn: today,
            backdateDays: days,
          );

      test('today and up to N days back are open', () {
        expect(restricted(today), isFalse);
        expect(restricted(LedgerDate(2026, 9, 30)), isFalse);
        expect(restricted(LedgerDate(2026, 9, 28)), isFalse);
      });

      test('older than N days, or in the future, needs entries.reverse', () {
        expect(restricted(LedgerDate(2026, 9, 27)), isTrue);
        expect(restricted(LedgerDate(2025, 4, 1)), isTrue);
        expect(restricted(LedgerDate(2026, 10, 2)), isTrue);
      });

      test('N = 0 allows only the day it is recorded', () {
        expect(restricted(today, days: 0), isFalse);
        expect(restricted(LedgerDate(2026, 9, 30), days: 0), isTrue);
      });

      test('permission for a dated entry adds the back-date rule', () {
        Permission? need(RefType t, LedgerDate d) =>
            LedgerPosting.requiredPermissions(
              t,
              entryDate: d,
              recordedOn: today,
              backdateDays: 3,
            ).lastOrNull;
        expect(need(RefType.arrival, today), Permission.arrivalsManage);
        expect(
          LedgerPosting.requiredPermissions(
            RefType.arrival,
            entryDate: LedgerDate(2026, 9, 1),
            recordedOn: today,
            backdateDays: 3,
          ),
          [Permission.arrivalsManage, Permission.entriesReverse],
        );
        expect(
          LedgerPosting.requiredPermissions(
            RefType.expense,
            entryDate: LedgerDate(2026, 9, 1),
            recordedOn: today,
            backdateDays: 3,
          ),
          [Permission.entriesReverse],
        );
        expect(
          LedgerPosting.requiredPermissions(
            RefType.expense,
            entryDate: today,
            recordedOn: today,
            backdateDays: 3,
          ),
          isEmpty,
        );
        expect(
          LedgerPosting.requiredPermissions(
            RefType.journal,
            entryDate: LedgerDate(2026, 9, 1),
            recordedOn: today,
            backdateDays: 3,
          ),
          [Permission.entriesReverse],
        );
      });
    },
  );
}
