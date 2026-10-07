import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

CartLine line(
  int qty,
  int price, {
  int discount = 0,
  int? rate = 500,
  String id = 'p',
}) => CartLine(
  productId: id,
  name: id,
  qtyMilli: qty,
  unitPrice: Money(price),
  lineDiscount: Money(discount),
  rateBp: rate,
  hsn: '3102',
);

void main() {
  const exclusive = GstMode(pricesIncludeGst: false);

  group('SaleCalculator worked example (exclusive, 5%, 10% bill discount)', () {
    // 2 bags x 100.00 + 1 bag x 50.00 = 250.00; 10% = 25.00 apportioned
    // 20.00 / 5.00; taxed on 180.00 and 45.00 -> 9.00 + 2.25.
    final t = SaleCalculator.compute(
      lines: [
        line(2000, 10000, id: 'a'),
        line(1000, 5000, id: 'b'),
      ],
      mode: exclusive,
      discount: const InvoiceDiscount.percent(1000),
    );

    test('amounts', () {
      expect(t.subtotal, const Money(25000));
      expect(t.invoiceDiscount, const Money(2500));
      expect(t.lines.map((l) => l.invoiceDiscountShare), [
        const Money(2000),
        const Money(500),
      ]);
      expect(t.lines.map((l) => l.net), [
        const Money(18000),
        const Money(4500),
      ]);
      expect(t.gst.taxable, const Money(22500));
      expect(t.gst.tax, const Money(1125));
      expect(t.gst.cgst, const Money(450 + 112));
      expect(t.gst.sgst, const Money(450 + 113));
      expect(t.beforeRoundOff, const Money(23625));
      expect(t.roundOff, const Money(-25));
      expect(t.total, const Money(23600));
      expect(t.totalDiscount, const Money(2500));
      expect(t.lines[0].total, const Money(18900));
    });

    test('without round-off', () {
      final u = SaleCalculator.compute(
        lines: [line(2000, 10000), line(1000, 5000)],
        mode: exclusive,
        discount: const InvoiceDiscount.percent(1000),
        roundToRupee: false,
      );
      expect(u.roundOff, Money.zero);
      expect(u.total, const Money(23625));
    });

    test('rounding half-up goes up at 50 paise', () {
      final u = SaleCalculator.compute(
        lines: [line(1000, 10050, rate: 0)],
        mode: exclusive,
      );
      expect(u.total, const Money(10100));
      expect(u.roundOff, const Money(50));
    });
  });

  group('inclusive prices', () {
    test('the bill total is the sum of the prices', () {
      final t = SaleCalculator.compute(
        lines: [
          line(2000, 26650),
          line(1500, 80000, discount: 5000, rate: 1800),
        ],
        roundToRupee: false,
      );
      // 533.00 + (1200.00 - 50.00) = 1683.00
      expect(t.total, const Money(168300));
      expect(t.gst.total, const Money(168300));
      expect(t.gst.tax.paise, greaterThan(0));
    });

    test('GST off: prices are the bill', () {
      final t = SaleCalculator.compute(
        lines: [line(1000, 10000)],
        mode: const GstMode(enabled: false),
        roundToRupee: false,
      );
      expect(t.gst.tax, Money.zero);
      expect(t.total, const Money(10000));
      expect(t.gstIssues, isEmpty);
    });

    test('inter-state is IGST and missing HSN is flagged', () {
      final t = SaleCalculator.compute(
        lines: [
          const CartLine(
            productId: 'p',
            qtyMilli: 1000,
            unitPrice: Money(11800),
            rateBp: 1800,
          ),
        ],
        mode: const GstMode(interState: true),
        roundToRupee: false,
      );
      expect(t.gst.igst, const Money(1800));
      expect(t.gstIssues[0], [GstIssue.missingHsn]);
    });
  });

  group('invoice discount', () {
    test('largest remainder: leftover paise to the earlier equal line', () {
      final t = SaleCalculator.compute(
        lines: [
          line(1000, 10000, id: 'a', rate: 0),
          line(1000, 10000, id: 'b', rate: 0),
          line(1000, 10000, id: 'c', rate: 0),
        ],
        mode: exclusive,
        discount: const InvoiceDiscount.amount(Money(1000)),
        roundToRupee: false,
      );
      expect(t.lines.map((l) => l.invoiceDiscountShare.paise), [334, 333, 333]);
      expect(t.total, const Money(29000));
    });

    test('shares always add up to the discount', () {
      for (var bp = 1; bp < 10000; bp += 313) {
        final t = SaleCalculator.compute(
          lines: [
            line(1333, 7777, id: 'a'),
            line(2500, 12345, id: 'b', discount: 123),
            line(700, 999, id: 'c'),
          ],
          mode: exclusive,
          discount: InvoiceDiscount.percent(bp),
        );
        final sum = t.lines.fold(0, (a, l) => a + l.invoiceDiscountShare.paise);
        expect(sum, t.invoiceDiscount.paise, reason: 'bp $bp');
        expect(
          t.beforeRoundOff,
          t.lines.fold(Money.zero, (a, l) => a + l.total),
        );
      }
    });

    test('a 100% discount leaves a zero bill', () {
      final t = SaleCalculator.compute(
        lines: [line(1000, 10000)],
        mode: exclusive,
        discount: const InvoiceDiscount.percent(10000),
      );
      expect(t.total, Money.zero);
    });

    test('free items with a discount do not divide by zero', () {
      final t = SaleCalculator.compute(
        lines: [line(1000, 0)],
        discount: const InvoiceDiscount.percent(500),
      );
      expect(t.total, Money.zero);
    });
  });

  group('SaleCalculator input checks', () {
    test('bad carts throw', () {
      void bad(void Function() f) => expect(f, throwsArgumentError);
      bad(() => SaleCalculator.compute(lines: const []));
      bad(() => SaleCalculator.compute(lines: [line(0, 100)]));
      bad(() => SaleCalculator.compute(lines: [line(1000, -1)]));
      bad(
        () => SaleCalculator.compute(lines: [line(1000, 100, discount: 101)]),
      );
      bad(() => SaleCalculator.compute(lines: [line(1000, 100, discount: -1)]));
      bad(
        () => SaleCalculator.compute(
          lines: [line(1000, 100)],
          discount: const InvoiceDiscount.percent(10001),
        ),
      );
      bad(
        () => SaleCalculator.compute(
          lines: [line(1000, 100)],
          discount: const InvoiceDiscount.percent(-1),
        ),
      );
      bad(
        () => SaleCalculator.compute(
          lines: [line(1000, 100)],
          discount: const InvoiceDiscount.amount(Money(101)),
        ),
      );
    });

    test('gross rounds half-up', () {
      expect(line(1500, 9999).gross, const Money(14999)); // 149.985
    });
  });

  group('SaleLineResult.allocate', () {
    test('splits amounts over batches by quantity, exactly', () {
      final t = SaleCalculator.compute(
        lines: [line(5000, 20020)],
        mode: exclusive,
        roundToRupee: false,
      );
      final parts = t.lines.single.allocate(const [
        BatchAllocation(
          batchId: 'b1',
          qtyMilli: 3000,
          unitCost: Money(8000),
          expiry: null,
          expired: false,
        ),
        BatchAllocation(
          batchId: 'b2',
          qtyMilli: 2000,
          unitCost: Money(9000),
          expiry: null,
          expired: false,
        ),
      ]);
      expect(parts.map((p) => p.qtyMilli), [3000, 2000]);
      expect(
        parts.fold(Money.zero, (a, p) => a + p.split.taxable),
        t.gst.taxable,
      );
      expect(parts.fold(Money.zero, (a, p) => a + p.total), t.total);
      expect(parts.first.split.taxable, const Money(60060));
      expect(parts.first.cost, const Money(24000));
      expect(parts.last.cost, const Money(18000));
      expect(parts.first.hsn, '3102');
      expect(parts.first.returnableMilli, 3000);
    });

    test('a negative-stock shortfall becomes a batch-less free-cost part', () {
      final t = SaleCalculator.compute(
        lines: [line(5000, 10000)],
        mode: exclusive,
        roundToRupee: false,
      );
      final parts = t.lines.single.allocate(const [
        BatchAllocation(
          batchId: 'b1',
          qtyMilli: 2000,
          unitCost: Money(8000),
          expiry: null,
          expired: false,
        ),
      ]);
      expect(parts.map((p) => p.batchId), ['b1', null]);
      expect(parts.last.qtyMilli, 3000);
      expect(parts.last.unitCost, Money.zero);
    });
  });

  group('PaymentChecks', () {
    const total = Money(10000);

    test('cash + upi + udhaar must equal the total', () {
      final ok = PaymentChecks.validate(
        total: total,
        payment: const PaymentSplit(
          cash: Money(4000),
          upi: Money(1000),
          udhaar: Money(5000),
        ),
        partyId: 'p1',
      );
      expect(ok.ok, isTrue);
      expect(ok.overCreditLimit, isNull);
      expect(
        PaymentChecks.validate(
          total: total,
          payment: const PaymentSplit(cash: Money(9000)),
        ).errors,
        [PaymentIssue.mismatch],
      );
      expect(
        PaymentChecks.validate(
          total: total,
          payment: const PaymentSplit.allCash(total),
        ).ok,
        isTrue,
      );
    });

    test('udhaar needs a party; negatives and a zero bill are errors', () {
      expect(
        PaymentChecks.validate(
          total: total,
          payment: const PaymentSplit(udhaar: total),
        ).errors,
        [PaymentIssue.udhaarNeedsParty],
      );
      expect(
        PaymentChecks.validate(
          total: total,
          payment: const PaymentSplit(udhaar: total),
          partyId: '',
        ).errors,
        [PaymentIssue.udhaarNeedsParty],
      );
      final neg = PaymentChecks.validate(
        total: total,
        payment: const PaymentSplit(cash: Money(12000), upi: Money(-2000)),
      );
      expect(neg.errors, [PaymentIssue.negativeAmount]);
      expect(
        PaymentChecks.validate(
          total: Money.zero,
          payment: const PaymentSplit(),
        ).errors,
        [PaymentIssue.zeroTotal],
      );
    });

    test('over the credit limit only warns', () {
      final c = PaymentChecks.validate(
        total: total,
        payment: const PaymentSplit(udhaar: total),
        partyId: 'p1',
        partyBalance: const Money(-45000),
        creditLimitPaise: 50000,
      );
      expect(c.ok, isTrue);
      expect(c.overCreditLimit, const Money(5000));
    });

    test('helpers', () {
      const p = PaymentSplit(cash: Money(100), upi: Money(50));
      expect(p.paidNow, const Money(150));
      expect(p.sum, const Money(150));
      expect(p.remainingAfterPaid(const Money(400)), const Money(250));
    });
  });
}
