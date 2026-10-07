import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  // Bill: urea 5 bags @ 266.50 incl. 5%, seed 2 kg @ 400.00 incl. 5%, with a
  // round-off. Each line is sold from one batch.
  final totals = SaleCalculator.compute(
    lines: const [
      CartLine(
        productId: 'urea',
        qtyMilli: 5000,
        unitPrice: Money(26650),
        rateBp: 500,
        hsn: '3102',
      ),
      CartLine(
        productId: 'seed',
        qtyMilli: 2000,
        unitPrice: Money(40000),
        rateBp: 500,
        hsn: '1209',
      ),
    ],
  );
  BatchAllocation alloc(String id, int qty, int cost) => BatchAllocation(
    batchId: id,
    qtyMilli: qty,
    unitCost: Money(cost),
    expiry: null,
    expired: false,
  );
  final sold = [
    ...totals.lines[0].allocate([alloc('b1', 5000, 20000)]),
    ...totals.lines[1].allocate([alloc('b2', 2000, 30000)]),
  ];

  test('the bill', () {
    // 1332.50 + 800.00 = 2132.50 -> rounded to 2133 (+0.50)
    expect(totals.beforeRoundOff, const Money(213250));
    expect(totals.roundOff, const Money(50));
    expect(totals.total, const Money(213300));
    expect(sold[0].cost, const Money(100000));
  });

  test('partial return: proportional refund and cost', () {
    final r = SalesReturns.compute(sold, const [
      ReturnRequest(0, 2000),
    ], invoiceRoundOff: totals.roundOff);
    // 2 of 5 bags: 533.00, taxable 507.62 (1332.50/1.05 = 1269.05 x 0.4)
    expect(r.split.total, const Money(53300));
    expect(r.cost, const Money(40000));
    expect(r.refund, const Money(53300), reason: 'no round-off yet');
    expect(r.completesInvoice, isFalse);
    expect(r.lines.single.qtyMilli, 2000);
    expect(r.lines.single.lineIndex, 0);
  });

  test('returns in pieces add up to the line, round-off with the last', () {
    final first = SalesReturns.compute(sold, const [
      ReturnRequest(0, 1700),
      ReturnRequest(1, 2000),
    ], invoiceRoundOff: totals.roundOff);
    expect(first.completesInvoice, isFalse);
    final soldAfter = [
      SoldLine(
        productId: sold[0].productId,
        batchId: sold[0].batchId,
        qtyMilli: sold[0].qtyMilli,
        unitCost: sold[0].unitCost,
        split: sold[0].split,
        rateBp: sold[0].rateBp,
        hsn: sold[0].hsn,
        returnedMilli: 1700,
        returned: first.lines[0].split,
        returnedCost: first.lines[0].cost,
      ),
      SoldLine(
        productId: sold[1].productId,
        batchId: sold[1].batchId,
        qtyMilli: sold[1].qtyMilli,
        unitCost: sold[1].unitCost,
        split: sold[1].split,
        returnedMilli: 2000,
        returned: first.lines[1].split,
        returnedCost: first.lines[1].cost,
      ),
    ];
    final last = SalesReturns.compute(soldAfter, const [
      ReturnRequest(0, 3300),
    ], invoiceRoundOff: totals.roundOff);
    expect(last.completesInvoice, isTrue);
    expect(last.roundOff, totals.roundOff);
    expect(
      first.split.total + last.split.total,
      totals.beforeRoundOff,
      reason: 'every paisa comes back exactly once',
    );
    expect(first.cost + last.cost, const Money(100000 + 60000));
    expect(first.refund + last.refund, totals.total);
  });

  test('round-off already refunded is not refunded twice', () {
    final r = SalesReturns.compute(
      [
        const SoldLine(
          productId: 'x',
          batchId: 'b',
          qtyMilli: 1000,
          unitCost: Money.zero,
          split: GstSplit.zero,
        ),
      ],
      const [ReturnRequest(0, 1000)],
      invoiceRoundOff: const Money(50),
      roundOffReturned: const Money(50),
    );
    expect(r.roundOff, Money.zero);
  });

  test('validation', () {
    List<ReturnLineIssue> v(List<ReturnRequest> r) =>
        SalesReturns.validate(sold, r);
    expect(v(const [ReturnRequest(0, 5000)]), isEmpty);
    expect(v(const [ReturnRequest(0, 5001)]), [
      const ReturnLineIssue(0, ReturnIssue.exceedsReturnable),
    ]);
    expect(v(const [ReturnRequest(1, 0)]), [
      const ReturnLineIssue(1, ReturnIssue.nonPositiveQty),
    ]);
    expect(v(const [ReturnRequest(2, 1)]), [
      const ReturnLineIssue(2, ReturnIssue.lineNotFound),
    ]);
    expect(v(const [ReturnRequest(-1, 1)]), [
      const ReturnLineIssue(-1, ReturnIssue.lineNotFound),
    ]);
    expect(v(const [ReturnRequest(0, 1000), ReturnRequest(0, 1000)]), [
      const ReturnLineIssue(0, ReturnIssue.exceedsReturnable),
    ]);
    expect(
      () => SalesReturns.compute(sold, const [ReturnRequest(0, 9000)]),
      throwsArgumentError,
    );
    expect(() => SalesReturns.compute(sold, const []), throwsArgumentError);
  });
}
