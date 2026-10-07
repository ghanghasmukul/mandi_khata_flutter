import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

LedgerDate d(String s) => LedgerDate.parse(s);

void main() {
  group('PurchaseRules.compute worked example', () {
    // 10 bags x 250.00 at 5%, 4 bags x 100.00 at 12%, freight 60.00.
    final t = PurchaseRules.compute(
      lines: [
        PurchaseLine(
          productId: 'urea',
          batchNo: 'U1',
          qtyMilli: 10000,
          unitCost: const Money.rupees(250),
          rateBp: 500,
          hsn: '3102',
          expiry: d('2027-03-31'),
        ),
        const PurchaseLine(
          productId: 'zinc',
          batchNo: 'Z1',
          qtyMilli: 4000,
          unitCost: Money.rupees(100),
          rateBp: 1200,
          hsn: '3105',
        ),
      ],
      freight: const Money.rupees(60),
    );

    test('totals', () {
      expect(t.gst.taxable, const Money(290000));
      expect(t.gst.tax, const Money(17300));
      expect(t.charges, const Money(6000));
      expect(t.stockValue, const Money(296000));
      expect(t.total, const Money(313300));
      expect(t.lines.map((l) => l.chargeShare.paise), [5172, 828]);
      expect(t.lines[0].landed, const Money(255172));
      expect(t.lines[0].landedUnitCost, const Money(25517));
      expect(t.lines[1].landedUnitCost, const Money(10207));
      expect(t.lines[0].total, const Money(262500));
      expect(t.lines[0].line.gross, const Money(250000));
      expect(t.freight, const Money(6000));
      expect(t.otherCharges, Money.zero);
      expect(t.gstIssues, isEmpty);
    });

    test('landed values add up to the stock value', () {
      expect(t.lines.fold(Money.zero, (a, l) => a + l.landed), t.stockValue);
    });

    test('round-off adjusts the total only', () {
      final r = PurchaseRules.compute(
        lines: [
          const PurchaseLine(
            productId: 'p',
            batchNo: 'b',
            qtyMilli: 1000,
            unitCost: Money(10033),
            rateBp: 500,
            hsn: '3102',
          ),
        ],
        roundOff: const Money(-1),
        otherCharges: const Money(100),
      );
      expect(r.total, const Money(10033 + 502 + 100 - 1));
      expect(r.stockValue, const Money(10133));
    });

    test('tax-inclusive costs and free lines', () {
      final r = PurchaseRules.compute(
        lines: [
          const PurchaseLine(
            productId: 'p',
            batchNo: 'b',
            qtyMilli: 1000,
            unitCost: Money(10500),
            rateBp: 500,
            hsn: '3102',
            lineDiscount: Money(500),
          ),
          const PurchaseLine(
            productId: 'q',
            batchNo: 'c',
            qtyMilli: 2000,
            unitCost: Money.zero,
          ),
        ],
        mode: const GstMode(),
        freight: const Money(300),
      );
      expect(r.gst.taxable, const Money(9524));
      expect(r.lines[1].chargeShare, Money.zero);
      expect(r.gstIssues.keys, [1]);
    });

    test('charges on all-free lines are spread by quantity', () {
      final r = PurchaseRules.compute(
        lines: [
          const PurchaseLine(
            productId: 'p',
            batchNo: 'b',
            qtyMilli: 1000,
            unitCost: Money.zero,
          ),
          const PurchaseLine(
            productId: 'q',
            batchNo: 'c',
            qtyMilli: 3000,
            unitCost: Money.zero,
          ),
        ],
        freight: const Money(100),
        mode: const GstMode(enabled: false),
      );
      expect(r.lines.map((l) => l.chargeShare.paise), [25, 75]);
    });

    test('bad input throws', () {
      PurchaseLine l(int q, int c, {int disc = 0}) => PurchaseLine(
        productId: 'p',
        batchNo: 'b',
        qtyMilli: q,
        unitCost: Money(c),
        lineDiscount: Money(disc),
      );
      expect(() => PurchaseRules.compute(lines: const []), throwsArgumentError);
      expect(
        () => PurchaseRules.compute(lines: [l(0, 1)]),
        throwsArgumentError,
      );
      expect(
        () => PurchaseRules.compute(lines: [l(1000, -1)]),
        throwsArgumentError,
      );
      expect(
        () => PurchaseRules.compute(lines: [l(1000, 100, disc: 101)]),
        throwsArgumentError,
      );
      expect(
        () => PurchaseRules.compute(lines: [l(1000, 100, disc: -1)]),
        throwsArgumentError,
      );
      expect(
        () => PurchaseRules.compute(
          lines: [l(1000, 100)],
          freight: const Money(-1),
        ),
        throwsArgumentError,
      );
      expect(
        () => PurchaseRules.compute(
          lines: [l(1000, 100)],
          otherCharges: const Money(-1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('settlement and due dates', () {
    test('paid now and unpaid', () {
      final s = PurchaseRules.settle(
        total: const Money(313300),
        paidNow: const Money(100000),
        supplierId: 's1',
      );
      expect(s.ok, isTrue);
      expect(s.unpaid, const Money(213300));
      expect(s.paid, const Money(100000));
    });

    test('errors', () {
      List<PurchaseIssue> e(Money total, Money paid, [String? s]) =>
          PurchaseRules.settle(
            total: total,
            paidNow: paid,
            supplierId: s,
          ).errors;
      expect(e(const Money(100), const Money(100)), isEmpty);
      expect(e(const Money(100), Money.zero), [PurchaseIssue.noSupplier]);
      expect(e(const Money(100), Money.zero, ''), [PurchaseIssue.noSupplier]);
      expect(e(const Money(100), const Money(200), 's'), [
        PurchaseIssue.paidAboveTotal,
      ]);
      expect(e(const Money(100), const Money(-5), 's'), [
        PurchaseIssue.negativePaid,
      ]);
      expect(e(Money.zero, Money.zero, 's'), [PurchaseIssue.noLines]);
    });

    test('due date and overdue', () {
      final due = PurchaseRules.dueDate(d('2026-09-15'), 30);
      expect(due, d('2026-10-15'));
      expect(PurchaseRules.dueDate(d('2026-09-15'), -3), d('2026-09-15'));
      expect(
        PurchaseRules.daysOverdue(due, d('2026-10-15'), const Money(1)),
        0,
      );
      expect(
        PurchaseRules.daysOverdue(due, d('2026-10-20'), const Money(1)),
        5,
      );
      expect(PurchaseRules.daysOverdue(due, d('2026-10-20'), Money.zero), 0);
      expect(
        PurchaseRules.isOverdue(due, d('2026-10-16'), const Money(1)),
        isTrue,
      );
      expect(
        PurchaseRules.isOverdue(due, d('2026-10-01'), const Money(1)),
        isFalse,
      );
    });
  });

  group('purchase return to the original batch', () {
    GstSplit split(int taxable) =>
        GstSplit.of(Money(taxable), 500, inclusive: false, interState: false);

    PurchasedLine line({
      int returned = 0,
      GstSplit returnedSplit = GstSplit.zero,
      Money returnedLanded = Money.zero,
      int remaining = 10000,
    }) => PurchasedLine(
      batchId: 'b1',
      qtyMilli: 10000,
      split: split(100001),
      landed: const Money(100501),
      batchRemainingMilli: remaining,
      returnedMilli: returned,
      returned: returnedSplit,
      returnedLanded: returnedLanded,
    );

    test('validation', () {
      final l = line(returned: 2000, remaining: 3000);
      List<ReturnLineIssue> v(int idx, int qty) =>
          PurchaseRules.validateReturn([l], [ReturnRequest(idx, qty)]);
      expect(v(0, 3000), isEmpty);
      expect(v(0, 0), [const ReturnLineIssue(0, ReturnIssue.nonPositiveQty)]);
      expect(v(0, 8001), [
        const ReturnLineIssue(0, ReturnIssue.exceedsReturnable),
      ]);
      expect(v(0, 3001), [
        const ReturnLineIssue(0, ReturnIssue.exceedsBatchStock),
      ]);
      expect(v(5, 1), [const ReturnLineIssue(5, ReturnIssue.lineNotFound)]);
      expect(
        PurchaseRules.validateReturn(
          [l],
          const [ReturnRequest(0, 1000), ReturnRequest(0, 1000)],
        ),
        [const ReturnLineIssue(0, ReturnIssue.exceedsReturnable)],
      );
      expect(l.returnableMilli, 8000);
      expect(
        const ReturnLineIssue(0, ReturnIssue.noParty).toString(),
        'line 0: noParty',
      );
      expect(
        const ReturnLineIssue(1, ReturnIssue.noParty).hashCode,
        const ReturnLineIssue(1, ReturnIssue.noParty).hashCode,
      );
    });

    test('proportional, and the last return takes the exact remainder', () {
      final first = PurchaseRules.computeReturn(
        [line()],
        [const ReturnRequest(0, 3333)],
      );
      // 1000.01 x 3.333 / 10 = 333.30
      expect(first.split.taxable, const Money(33330));
      expect(first.stockValue, const Money(33497));
      expect(first.refund, first.stockValue + first.split.tax);
      expect(first.lines.single.stockValue, first.stockValue);

      final last = PurchaseRules.computeReturn(
        [
          line(
            returned: 3333,
            returnedSplit: first.split,
            returnedLanded: first.stockValue,
          ),
        ],
        [const ReturnRequest(0, 6667)],
      );
      expect(first.split.taxable + last.split.taxable, const Money(100001));
      expect(first.split.tax + last.split.tax, split(100001).tax);
      expect(first.stockValue + last.stockValue, const Money(100501));
    });

    test('invalid returns throw', () {
      expect(
        () => PurchaseRules.computeReturn(
          [line()],
          [const ReturnRequest(0, 20000)],
        ),
        throwsArgumentError,
      );
      expect(
        () => PurchaseRules.computeReturn([line()], const []),
        throwsArgumentError,
      );
    });
  });

  group('ReturnSettlement.split', () {
    final khata = ReturnSettlement.split(
      refund: const Money(5000),
      choice: RefundChoice.khata,
      hasParty: true,
    );
    test('khata needs a party; cash does not', () {
      expect(khata.khata, const Money(5000));
      expect(khata.ok, isTrue);
      final noParty = ReturnSettlement.split(
        refund: const Money(5000),
        choice: RefundChoice.khata,
        hasParty: false,
      );
      expect(noParty.errors, [ReturnIssue.noParty]);
      final cash = ReturnSettlement.split(
        refund: const Money(5000),
        choice: RefundChoice.cash,
        hasParty: false,
      );
      expect(cash.cash, const Money(5000));
      expect(cash.khata, Money.zero);
    });

    test('auto credits the khata up to the unpaid part of the bill', () {
      ReturnSettlement auto(int refund, int unpaid, {bool party = true}) =>
          ReturnSettlement.split(
            refund: Money(refund),
            choice: RefundChoice.auto,
            hasParty: party,
            unpaidOnBill: Money(unpaid),
          );
      expect(auto(5000, 3000).khata, const Money(3000));
      expect(auto(5000, 3000).cash, const Money(2000));
      expect(auto(5000, 9000).khata, const Money(5000));
      expect(auto(5000, 9000).cash, Money.zero);
      expect(auto(5000, 0).cash, const Money(5000));
      expect(auto(5000, -10).khata, Money.zero);
      expect(auto(5000, 3000, party: false).khata, Money.zero);
      expect(auto(5000, 3000, party: false).ok, isTrue);
    });
  });
}
