import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

LedgerDate d(String s) => LedgerDate.parse(s);

StockBatch batch(
  String id, {
  required int qty,
  String? expiry,
  int created = 0,
  int cost = 10000,
  String product = 'p1',
}) => StockBatch(
  id: id,
  productId: product,
  batchNo: 'B-$id',
  cost: Money(cost),
  remainingMilli: qty,
  createdAt: DateTime.utc(2026, 1, 1 + created),
  expiry: expiry == null ? null : d(expiry),
);

void main() {
  final today = d('2026-10-07');

  group('Qty', () {
    test('parse and format', () {
      expect(Qty.parse('2.5'), 2500);
      expect(Qty.parse('12'), 12000);
      expect(Qty.parse('.5'), 500);
      expect(Qty.parse('1,250.125'), 1250125);
      expect(Qty.parse(''), isNull);
      expect(Qty.parse('.'), isNull);
      expect(Qty.parse('1.2345'), isNull);
      expect(Qty.parse('abc'), isNull);
      expect(Qty.fromUnits(3), 3000);
      expect(Qty.format(2500), '2.5');
      expect(Qty.format(3000), '3');
      expect(Qty.format(-1250), '-1.25');
      expect(Qty.format(1001), '1.001');
      expect(Qty.format(0), '0');
    });
  });

  group('StockMovement and balances', () {
    test('reason names and signs', () {
      for (final r in StockMovementReason.values) {
        expect(StockMovementReason.parse(r.dbName), r);
      }
      expect(() => StockMovementReason.parse('x'), throwsFormatException);
      expect(StockMovementReason.sale.accepts(-1), isTrue);
      expect(StockMovementReason.sale.accepts(1), isFalse);
      expect(StockMovementReason.purchase.accepts(1000), isTrue);
      expect(StockMovementReason.purchase.accepts(-1000), isFalse);
      expect(StockMovementReason.adjustment.accepts(-5), isTrue);
      expect(StockMovementReason.adjustment.accepts(5), isTrue);
      expect(StockMovementReason.adjustment.accepts(0), isFalse);
    });

    test('a movement of the wrong sign or zero is refused', () {
      expect(
        () => StockMovement(
          productId: 'p',
          qtyMilli: 5,
          reason: StockMovementReason.sale,
        ),
        throwsArgumentError,
      );
      expect(
        () => StockMovement(
          productId: 'p',
          qtyMilli: 0,
          reason: StockMovementReason.adjustment,
        ),
        throwsArgumentError,
      );
    });

    test('stock is the sum of movements', () {
      StockMovement m(String p, String? b, int q, StockMovementReason r) =>
          StockMovement(productId: p, batchId: b, qtyMilli: q, reason: r);
      final movements = [
        m('p1', 'b1', 10000, StockMovementReason.purchase),
        m('p1', 'b1', -3000, StockMovementReason.sale),
        m('p1', 'b2', 5000, StockMovementReason.opening),
        m('p1', 'b1', 1000, StockMovementReason.saleReturn),
        m('p1', 'b2', -500, StockMovementReason.adjustment),
        m('p2', 'b3', 2000, StockMovementReason.purchase),
        m('p2', 'b3', -2000, StockMovementReason.purchaseReturn),
        m('p2', null, -1000, StockMovementReason.sale),
      ];
      expect(StockBalance.byProduct(movements), {'p1': 12500, 'p2': -1000});
      expect(StockBalance.byBatch(movements), {
        'b1': 8000,
        'b2': 4500,
        'b3': 0,
      });
      expect(StockBalance.total(movements), 11500);
    });
  });

  group('StockBatch', () {
    test('expiry states and value', () {
      final b = batch('a', qty: 2500, expiry: '2026-10-07', cost: 9999);
      expect(b.isExpired(today), isFalse, reason: 'last day still sellable');
      expect(b.isExpiring(today, 0), isTrue);
      expect(batch('x', qty: 1, expiry: '2026-10-06').isExpired(today), isTrue);
      expect(
        batch('x', qty: 1, expiry: '2026-10-06').isExpiring(today, 90),
        isFalse,
      );
      expect(batch('x', qty: 1).isExpired(today), isFalse);
      expect(batch('x', qty: 1).isExpiring(today, 9999), isFalse);
      expect(
        batch('x', qty: 1, expiry: '2027-10-07').isExpiring(today, 60),
        isFalse,
      );
      expect(b.value, const Money(24998)); // 99.99 x 2.5 = 249.975 -> 249.98
    });
  });

  group('FefoPicker', () {
    final a = batch('A', qty: 5000, expiry: '2026-12-01', created: 1);
    final b = batch('B', qty: 3000, expiry: '2026-11-01', created: 2);
    final c = batch('C', qty: 10000, created: 3);
    final e = batch('E', qty: 2000, expiry: '2026-09-01');

    test('earliest expiry first, no expiry last', () {
      final r = FefoPicker.pick(
        batches: [c, a, b],
        qtyMilli: 9000,
        today: today,
      );
      expect(r.allocations.map((x) => (x.batchId, x.qtyMilli)), [
        ('B', 3000),
        ('A', 5000),
        ('C', 1000),
      ]);
      expect(r.canSell, isTrue);
      expect(r.shortMilli, 0);
      expect(r.allocatedMilli, 9000);
      expect(r.cost, const Money(90000)); // 9 units x 100.00
      expect(r.warnings.map((w) => (w.kind, w.batchId)), [
        (StockWarningKind.nearExpiry, 'B'),
        (StockWarningKind.nearExpiry, 'A'),
      ]);
    });

    test('same expiry: oldest created, then id', () {
      final x = batch('X', qty: 1000, expiry: '2027-01-01', created: 5);
      final y = batch('Y', qty: 1000, expiry: '2027-01-01', created: 2);
      final z = batch('Z', qty: 1000, expiry: '2027-01-01', created: 2);
      final r = FefoPicker.pick(
        batches: [x, z, y],
        qtyMilli: 3000,
        today: today,
      );
      expect(r.allocations.map((q) => q.batchId), ['Y', 'Z', 'X']);
      final n1 = batch('N1', qty: 1000, created: 4);
      final n2 = batch('N2', qty: 1000, created: 3);
      expect(
        FefoPicker.pick(
          batches: [n1, n2, a],
          qtyMilli: 7000,
          today: today,
        ).allocations.map((q) => q.batchId),
        ['A', 'N2', 'N1'],
      );
    });

    test('an expired batch is blocked by default', () {
      final r = FefoPicker.pick(
        batches: [a, b, c, e],
        qtyMilli: 20000,
        today: today,
      );
      expect(r.canSell, isFalse);
      expect(r.error, StockErrorKind.expiredBlocked);
      expect(r.shortMilli, 2000);
      expect(r.expiredBlockedMilli, 2000);
      expect(r.allocations.any((x) => x.batchId == 'E'), isFalse);
      // Fits in the fresh stock: fine.
      expect(
        FefoPicker.pick(batches: [a, e], qtyMilli: 5000, today: today).canSell,
        isTrue,
      );
    });

    test('expired batches are used last, with a warning, when allowed', () {
      final r = FefoPicker.pick(
        batches: [a, b, c, e],
        qtyMilli: 20000,
        today: today,
        policy: const StockPolicy(blockExpired: false),
      );
      expect(r.canSell, isTrue);
      expect(r.allocations.last.batchId, 'E');
      expect(r.allocations.last.expired, isTrue);
      expect(
        r.warnings.where((w) => w.kind == StockWarningKind.expiredSold),
        hasLength(1),
      );
    });

    test('shortage: error, or a negative-stock warning when allowed', () {
      final r = FefoPicker.pick(batches: [a], qtyMilli: 8000, today: today);
      expect(r.error, StockErrorKind.insufficientStock);
      expect(r.shortMilli, 3000);
      expect(r.allocatedMilli, 5000);

      final neg = FefoPicker.pick(
        batches: [a],
        qtyMilli: 8000,
        today: today,
        policy: const StockPolicy(allowNegative: true),
      );
      expect(neg.canSell, isTrue);
      expect(neg.shortMilli, 3000);
      expect(
        neg.warnings.last,
        isA<StockWarning>()
            .having((w) => w.kind, 'kind', StockWarningKind.negativeStock)
            .having((w) => w.qtyMilli, 'qty', 3000),
      );
      // Negative stock never bypasses the expired-batch block.
      final blocked = FefoPicker.pick(
        batches: [e],
        qtyMilli: 1000,
        today: today,
        policy: const StockPolicy(allowNegative: true),
      );
      expect(blocked.error, StockErrorKind.expiredBlocked);
    });

    test('empty batches are ignored and a bad quantity throws', () {
      final r = FefoPicker.pick(
        batches: [batch('Z', qty: 0), a],
        qtyMilli: 1000,
        today: today,
      );
      expect(r.allocations.single.batchId, 'A');
      expect(
        () => FefoPicker.pick(batches: [a], qtyMilli: 0, today: today),
        throwsArgumentError,
      );
    });
  });

  group('StockSummary', () {
    test('status, counts and value at cost', () {
      final products = [
        StockProduct(
          id: 'low',
          reorderLevelMilli: 5000,
          batches: [batch('l1', qty: 4000, cost: 5000)],
        ),
        StockProduct(id: 'out', batches: [batch('o1', qty: 0)]),
        StockProduct(
          id: 'expired',
          batches: [batch('x1', qty: 1000, expiry: '2026-10-01', cost: 2500)],
        ),
        StockProduct(
          id: 'expiring',
          reorderLevelMilli: 100,
          batches: [
            batch('y1', qty: 2000, expiry: '2026-11-15', cost: 1000),
            batch('y2', qty: 3000),
          ],
        ),
        const StockProduct(id: 'none', batches: []),
      ];
      final s = StockSummary.of(products, today: today);
      expect(s.lowCount, 1);
      expect(s.outCount, 2);
      expect(s.expiredCount, 1);
      expect(s.expiringCount, 1);
      // 4 x 50 + 1 x 25 + 2 x 10 + 3 x 100 = 200 + 25 + 20 + 300
      expect(s.valueAtCost, const Money.rupees(545));
      expect(StockSummary.statusOf(products[0]), ProductStockStatus.low);
      expect(StockSummary.statusOf(products[2]), ProductStockStatus.ok);
      expect(StockSummary.statusOf(products[1]), ProductStockStatus.out);
      expect(products[3].totalMilli, 5000);
    });

    test('a short window leaves the far batch out of expiring', () {
      final p = StockProduct(
        id: 'p',
        batches: [batch('y', qty: 1000, expiry: '2026-11-15')],
      );
      expect(
        StockSummary.of([p], today: today, expiryWarnDays: 20).expiringCount,
        0,
      );
    });
  });

  group('Margin', () {
    test('basis points and text', () {
      expect(
        Margin.basisPoints(const Money.rupees(120), const Money.rupees(90)),
        2500,
      );
      expect(Margin.basisPoints(const Money(10000), const Money(10325)), -325);
      expect(Margin.basisPoints(Money.zero, const Money.rupees(5)), isNull);
      expect(Margin.format(2500), '25%');
      expect(Margin.format(2550), '25.5%');
      expect(Margin.format(2505), '25.05%');
      expect(Margin.format(-325), '-3.25%');
      expect(Margin.format(0), '0%');
    });
  });
}
