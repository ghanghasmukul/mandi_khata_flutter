import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

StatementLine st(
  String id,
  LedgerDate d,
  int rupees, {
  String? ref,
  String? desc,
}) => StatementLine(
  id: id,
  date: d,
  isIn: rupees > 0,
  amount: Money.rupees(rupees.abs()),
  reference: ref,
  description: desc,
);

BookLine bk(String id, LedgerDate d, int rupees, {String? ref}) => BookLine(
  id: id,
  date: d,
  isIn: rupees > 0,
  amount: Money.rupees(rupees.abs()),
  reference: ref,
);

LedgerDate apr(int day) => LedgerDate(2027, 4, day);

void main() {
  group('StatementParser.parseDate', () {
    test('formats', () {
      expect(
        StatementParser.parseDate('31/03/2027', StatementDateFormat.dmy),
        LedgerDate(2027, 3, 31),
      );
      expect(
        StatementParser.parseDate('31-03-27', StatementDateFormat.dmyShort),
        LedgerDate(2027, 3, 31),
      );
      expect(
        StatementParser.parseDate('2027-03-31', StatementDateFormat.ymd),
        LedgerDate(2027, 3, 31),
      );
      expect(
        StatementParser.parseDate('31-Mar-2027', StatementDateFormat.dMonY),
        LedgerDate(2027, 3, 31),
      );
      expect(
        StatementParser.parseDate('31 March 2027', StatementDateFormat.dMonY),
        LedgerDate(2027, 3, 31),
      );
      expect(
        StatementParser.parseDate('03/31/2027', StatementDateFormat.mdy),
        LedgerDate(2027, 3, 31),
      );
      // Excel serial day 46477 = 2027-03-31.
      expect(
        StatementParser.parseDate('46477', StatementDateFormat.dmy),
        LedgerDate(2027, 3, 31),
      );
    });

    test('not a date', () {
      for (final t in ['', 'abc', '31/13/2027', '32/01/2027', '1/2']) {
        expect(
          StatementParser.parseDate(t, StatementDateFormat.dmy),
          isNull,
          reason: t,
        );
      }
      expect(
        StatementParser.parseDate('31-Xyz-2027', StatementDateFormat.dMonY),
        isNull,
      );
    });
  });

  group('StatementParser.parseAmount', () {
    test('Indian grouping, symbols, Dr/Cr, brackets, signs', () {
      ({int p, bool n})? a(String t) {
        final r = StatementParser.parseAmount(t);
        return r == null ? null : (p: r.amount.paise, n: r.negative);
      }

      expect(a('1,23,456.78'), (p: 12345678, n: false));
      expect(a('₹ 500'), (p: 50000, n: false));
      expect(a('Rs. 500.5'), (p: 50050, n: false));
      expect(a('500.00 Dr'), (p: 50000, n: true));
      expect(a('500.00 CR'), (p: 50000, n: false));
      expect(a('(200)'), (p: 20000, n: true));
      expect(a('-200'), (p: 20000, n: true));
      expect(a('+200'), (p: 20000, n: false));
      expect(a(''), isNull);
      expect(a('abc'), isNull);
      expect(a('1.234'), isNull);
    });
  });

  group('StatementParser.parse', () {
    test('debit / credit columns, header skipped, bad rows reported', () {
      final sheet = DelimitedText.parse(
        'Date,Narration,Ref,Withdrawal,Deposit,Balance\n'
        '01/04/2027,NEFT BANSAL,UTR123456,,25000.00,"1,25,000.00"\n'
        '02/04/2027,CHQ 000123 GURMEET,000123,"5,000.00",,"1,20,000.00"\n'
        'Opening balance,,,,,\n'
        '03/04/2027,BAD,,x,,\n'
        '04/04/2027,both,,1,2,\n'
        '05/04/2027,nothing,,,,\n',
      );
      const mapping = StatementMapping(
        date: 0,
        dateFormat: StatementDateFormat.dmy,
        description: 1,
        reference: 2,
        debit: 3,
        credit: 4,
        balance: 5,
      );
      final r = StatementParser.parse(sheet, mapping);
      expect(r.rows, hasLength(2));
      expect(r.rows.first.isIn, isTrue);
      expect(r.rows.first.amount, const Money.rupees(25000));
      expect(r.rows.first.balance, const Money.rupees(125000));
      expect(r.rows.first.reference, 'UTR123456');
      expect(r.rows[1].isIn, isFalse);
      expect(r.rows[1].description, 'CHQ 000123 GURMEET');
      expect(
        [for (final e in r.errors) (e.rowNumber, e.problem)],
        [
          (4, StatementRowProblem.badDate),
          (5, StatementRowProblem.badAmount),
          (6, StatementRowProblem.badAmount),
          (7, StatementRowProblem.noAmount),
        ],
      );
      expect(r.rows.first.fingerprint, isNot(r.rows[1].fingerprint));
    });

    test('one signed amount column', () {
      final sheet = DelimitedText.parse(
        'Txn Date\tParticulars\tAmount\n'
        '2027-04-01\tUPI from X\t1500.00 Cr\n'
        '2027-04-02\tATM\t-2000\n'
        '2027-04-03\tzero\t0\n'
        '2027-04-04\tjunk\tabc\n',
      );
      const mapping = StatementMapping(
        date: 0,
        dateFormat: StatementDateFormat.ymd,
        description: 1,
        amount: 2,
      );
      final r = StatementParser.parse(sheet, mapping);
      expect(
        [for (final x in r.rows) (x.isIn, x.amount.paise)],
        [(true, 150000), (false, 200000)],
      );
      expect(
        [for (final e in r.errors) e.problem],
        [StatementRowProblem.noAmount, StatementRowProblem.badAmount],
      );
    });
  });

  group('StatementMapping JSON', () {
    test('round trip and validity', () {
      const m = StatementMapping(
        date: 0,
        dateFormat: StatementDateFormat.dMonY,
        debit: 3,
        credit: 4,
        headerRows: 2,
      );
      final back = StatementMapping.fromJson(m.toJson())!;
      expect(back.toJson(), m.toJson());
      expect(StatementMapping.fromJson('x'), isNull);
      expect(StatementMapping.fromJson({'date': 0}), isNull);
      expect(
        StatementMapping.fromJson({'date': 0, 'date_format': 'dmy'}),
        isNull,
        reason: 'no amount columns',
      );
      expect(
        StatementMapping.fromJson({
          'date': 0,
          'date_format': 'dmy',
          'amount': 2,
        })!.headerRows,
        1,
      );
    });
  });

  group('BankReconciliation.autoMatch', () {
    test('amount + direction + ±3 days', () {
      final m = BankReconciliation.autoMatch(
        [st('s1', apr(4), 5000), st('s2', apr(10), -300)],
        [
          bk('b1', apr(1), 5000),
          bk('b2', apr(5), -300),
          bk('b3', apr(1), -5000),
        ],
      );
      expect(
        [for (final x in m) (x.statementLineId, x.bookLineId)],
        [('s1', 'b1')],
      );
    });

    test('a matching reference beats a closer date', () {
      final m = BankReconciliation.autoMatch(
        [st('s1', apr(5), -1000, desc: 'CHQ 000777 PAID')],
        [bk('near', apr(5), -1000), bk('ref', apr(3), -1000, ref: '000777')],
      );
      expect(m.single.bookLineId, 'ref');
      expect(m.single.byReference, isTrue);
    });

    test('references that disagree never match', () {
      final m = BankReconciliation.autoMatch(
        [st('s1', apr(5), 900, ref: 'UTR999999')],
        [bk('b1', apr(5), 900, ref: 'UTR111111')],
      );
      expect(m, isEmpty);
    });

    test('a book reference with no statement reference falls back', () {
      final m = BankReconciliation.autoMatch(
        [st('s1', apr(5), 900, desc: 'NEFT')],
        [bk('b1', apr(6), 900, ref: 'UTR111111')],
      );
      expect(m.single.byReference, isFalse);
    });

    test('a negative running balance is kept negative', () {
      final r = StatementParser.parse(
        DelimitedText.parse('d,a,b\n01/04/2027,100,(50.00)\n'),
        const StatementMapping(
          date: 0,
          dateFormat: StatementDateFormat.dmy,
          amount: 1,
          balance: 2,
        ),
      );
      expect(r.rows.single.balance, const Money(-5000));
    });

    test('ties: same distance, oldest book line, then ids', () {
      final m = BankReconciliation.autoMatch(
        [st('s2', apr(5), 100), st('s1', apr(5), 100)],
        [bk('b2', apr(5), 100), bk('b1', apr(5), 100)],
      );
      expect(
        {for (final x in m) x.statementLineId: x.bookLineId},
        {'s1': 'b1', 's2': 'b2'},
      );
      final n = BankReconciliation.autoMatch(
        [st('s1', apr(4), 100), st('s2', apr(6), 100)],
        [bk('b1', apr(5), 100)],
      );
      expect(n.single.statementLineId, 's1');
    });

    test('each line once; closest date, then oldest', () {
      final m = BankReconciliation.autoMatch(
        [st('s1', apr(5), 100), st('s2', apr(6), 100)],
        [bk('b1', apr(4), 100), bk('b2', apr(6), 100), bk('b3', apr(5), 100)],
      );
      expect(
        {for (final x in m) x.statementLineId: x.bookLineId},
        {'s1': 'b3', 's2': 'b2'},
      );
    });

    test('canMatch and referencesAgree', () {
      expect(
        BankReconciliation.canMatch(bk('b', apr(1), 5), st('s', apr(30), 5)),
        isTrue,
      );
      expect(
        BankReconciliation.canMatch(bk('b', apr(1), 5), st('s', apr(1), -5)),
        isFalse,
      );
      expect(
        BankReconciliation.referencesAgree(
          bk('b', apr(1), 5, ref: 'ab'),
          st('s', apr(1), 5, ref: 'X'),
        ),
        isNull,
        reason: 'references shorter than 4 characters are ignored',
      );
    });
  });
}
