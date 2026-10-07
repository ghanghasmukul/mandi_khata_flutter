import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

String gstin(String first14) => first14 + Gstin.checkDigit(first14);

void main() {
  final punjab = gstin('03AAPFU0939F1Z');
  const maharashtra = '27AAPFU0939F1ZV';

  group('GstSplit', () {
    test('exclusive: tax is added, intra-state splits in two', () {
      final s = GstSplit.of(
        const Money.rupees(1000),
        500,
        inclusive: false,
        interState: false,
      );
      expect(s.taxable, const Money.rupees(1000));
      expect(s.cgst, const Money.rupees(25));
      expect(s.sgst, const Money.rupees(25));
      expect(s.igst, Money.zero);
      expect(s.tax, const Money.rupees(50));
      expect(s.total, const Money.rupees(1050));
    });

    test('inclusive: the amount already holds the tax', () {
      final s = GstSplit.of(
        const Money.rupees(1050),
        500,
        inclusive: true,
        interState: false,
      );
      expect(s.taxable, const Money.rupees(1000));
      expect(s.tax, const Money.rupees(50));
      expect(s.total, const Money.rupees(1050));
    });

    test('inclusive 18% of 100.00: 84.75 + 15.25, odd paisa to SGST', () {
      final s = GstSplit.of(
        const Money.rupees(100),
        1800,
        inclusive: true,
        interState: false,
      );
      expect(s.taxable, const Money(8475));
      expect(s.cgst, const Money(762));
      expect(s.sgst, const Money(763));
      expect(s.total, const Money.rupees(100));
    });

    test('inter-state is all IGST; rate 0 has no tax', () {
      final s = GstSplit.of(
        const Money.rupees(1000),
        1200,
        inclusive: false,
        interState: true,
      );
      expect(s.igst, const Money.rupees(120));
      expect(s.cgst, Money.zero);
      final z = GstSplit.of(
        const Money.rupees(10),
        0,
        inclusive: true,
        interState: false,
      );
      expect(z.tax, Money.zero);
      expect(z.taxable, const Money.rupees(10));
    });

    test('negative amount is refused; + and unary minus', () {
      expect(
        () => GstSplit.of(
          const Money(-1),
          500,
          inclusive: true,
          interState: false,
        ),
        throwsArgumentError,
      );
      final a = GstSplit.of(
        const Money.rupees(100),
        500,
        inclusive: false,
        interState: false,
      );
      expect((a + a).taxable, const Money.rupees(200));
      expect((-a).total, -a.total);
      expect(GstSplit.zero.total, Money.zero);
    });
  });

  group('GstInvoice', () {
    const lines = [
      GstLineInput(amount: Money(10500), rateBp: 500, hsn: '3102'),
      GstLineInput(amount: Money(11800), rateBp: 1800),
      GstLineInput(amount: Money(1000), rateBp: 777, hsn: '12'),
    ];

    test('tax per line, summed; issues by line', () {
      final r = GstInvoice.compute(lines, const GstMode());
      expect(r.lines[0].taxable, const Money(10000));
      expect(r.lines[1].taxable, const Money(10000));
      expect(r.total.total, const Money(23300));
      expect(r.issues.keys, [1, 2]);
      expect(r.issues[1], [GstIssue.missingHsn]);
      expect(r.issues[2], [GstIssue.invalidHsn, GstIssue.invalidRate]);
    });

    test('GST off: no tax, no flags', () {
      final r = GstInvoice.compute(lines, const GstMode(enabled: false));
      expect(r.total.tax, Money.zero);
      expect(r.total.taxable, const Money(23300));
      expect(r.issues, isEmpty);
    });

    test('a missing rate counts as 0 and is flagged', () {
      final r = GstInvoice.compute(const [
        GstLineInput(amount: Money(500), hsn: '31021000'),
      ], const GstMode(pricesIncludeGst: false));
      expect(r.total.total, const Money(500));
      expect(r.issues[0], [GstIssue.missingRate]);
    });
  });

  group('rates, HSN, states, GSTIN', () {
    test('valid rates and parsing', () {
      expect(GstRates.valid, [0, 25, 300, 500, 1200, 1800, 2800]);
      expect(GstRates.isValid(1800), isTrue);
      expect(GstRates.isValid(1700), isFalse);
      expect(GstRates.isValid(null), isFalse);
      expect(GstRates.parse('18'), 1800);
      expect(GstRates.parse('0.25'), 25);
      expect(GstRates.parse(5), 500);
      expect(GstRates.parse('0.255'), isNull);
      expect(GstRates.parse('abc'), isNull);
      expect(GstRates.parse(1.5), isNull);
      expect(GstRates.format(1800), '18');
      expect(GstRates.format(25), '0.25');
      expect(GstRates.format(250), '2.5');
    });

    test('HSN and rate checks', () {
      expect(GstChecks.issues(hsn: '3102', rateBp: 500), isEmpty);
      expect(GstChecks.issues(hsn: '31021000', rateBp: 0), isEmpty);
      expect(GstChecks.issues(), [GstIssue.missingHsn, GstIssue.missingRate]);
      expect(GstChecks.issues(hsn: ' ', rateBp: 1), [
        GstIssue.missingHsn,
        GstIssue.invalidRate,
      ]);
      expect(GstChecks.issues(hsn: '31a2', rateBp: 500), [GstIssue.invalidHsn]);
      expect(GstChecks.issues(hsn: '31022', rateBp: 500), [
        GstIssue.invalidHsn,
      ]);
    });

    test('states and GSTIN', () {
      expect(GstStates.isValid('03'), isTrue);
      expect(GstStates.isValid('25'), isFalse);
      expect(GstStates.nameOf('06'), 'Haryana');
      expect(GstStates.nameOf('99'), isNull);
      expect(GstStates.stateOfGstin(maharashtra), '27');
      expect(GstStates.stateOfGstin(' ${punjab.toLowerCase()} '), '03');
      expect(GstStates.stateOfGstin('27AAPFU0939F1ZW'), isNull);
      // Valid shape and check digit but no such state.
      expect(GstStates.stateOfGstin(gstin('25AAPFU0939F1Z')), isNull);
      expect(GstStates.isValidGstin(maharashtra), isTrue);
      expect(GstStates.isValidGstin('nope'), isFalse);
    });

    test('place of supply', () {
      expect(PlaceOfSupply.of(tenantStateCode: '03'), '03');
      expect(
        PlaceOfSupply.of(tenantStateCode: '03', customerGstin: maharashtra),
        '27',
      );
      expect(
        PlaceOfSupply.of(
          tenantStateCode: '03',
          customerGstin: 'bad',
          customerStateCode: '06',
        ),
        '06',
      );
      expect(
        PlaceOfSupply.of(tenantStateCode: '03', customerStateCode: '99'),
        '03',
      );
      expect(PlaceOfSupply.isInterState('03', '27'), isTrue);
      expect(PlaceOfSupply.isInterState('03', '03'), isFalse);
      expect(PlaceOfSupply.isInterState('', '27'), isFalse);
    });
  });

  group('HsnSummary', () {
    GstSplit s(int amount) =>
        GstSplit.of(Money(amount), 500, inclusive: false, interState: false);

    test('groups by HSN and rate, sorted', () {
      final rows = HsnSummary.build([
        HsnInput(hsn: '3808', rateBp: 1800, qtyMilli: 1000, split: s(10000)),
        HsnInput(hsn: '3102', rateBp: 500, qtyMilli: 2000, split: s(20000)),
        HsnInput(hsn: '3102', rateBp: 500, qtyMilli: 500, split: s(5000)),
        HsnInput(hsn: ' 3102 ', rateBp: 1200, qtyMilli: 1000, split: s(1000)),
        HsnInput(hsn: '', rateBp: 0, qtyMilli: 1000, split: s(100)),
      ]);
      expect(rows.map((r) => (r.hsn, r.rateBp, r.qtyMilli)), [
        ('', 0, 1000),
        ('3102', 500, 2500),
        ('3102', 1200, 1000),
        ('3808', 1800, 1000),
      ]);
      expect(rows[1].split.taxable, const Money(25000));
      expect(rows[1].split.tax, const Money(1250));
    });
  });
}
