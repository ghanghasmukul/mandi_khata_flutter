import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/products/domain/product.dart';

/// One batch of a product with what is left of it.
///
/// [remainingMilli] is the truth: the sum of the batch's stock movements.
/// [cachedMilli] is `batches.qty_milli` (the projection); they differ only
/// when the cache is stale, which `StockRepository.rebuildBatchQty` repairs.
@immutable
class BatchStock {
  const BatchStock({
    required this.id,
    required this.productId,
    required this.batchNo,
    required this.cost,
    required this.remainingMilli,
    required this.cachedMilli,
    required this.createdAt,
    this.mfgDate,
    this.expiry,
  });

  final String id;
  final String productId;
  final String batchNo;

  /// Cost per whole unit.
  final Money cost;
  final int remainingMilli;
  final int cachedMilli;
  final DateTime createdAt;
  final LedgerDate? mfgDate;
  final LedgerDate? expiry;

  bool get cacheStale => remainingMilli != cachedMilli;

  bool isExpired(LedgerDate today) => expiry != null && expiry! < today;

  bool isExpiring(LedgerDate today, int warnDays) =>
      toStockBatch().isExpiring(today, warnDays);

  /// Cost of what is left.
  Money get value => ShopMath.valueOf(cost, remainingMilli);

  /// The core type FEFO and the summary work on.
  StockBatch toStockBatch() => StockBatch(
    id: id,
    productId: productId,
    batchNo: batchNo,
    cost: cost,
    remainingMilli: remainingMilli,
    createdAt: createdAt,
    expiry: expiry,
  );
}

/// A product with its batches and stock (Σ of its movements).
@immutable
class ProductWithStock {
  const ProductWithStock({
    required this.product,
    required this.batches,
    this.uncoveredMilli = 0,
  });

  final Product product;

  /// Every batch, in FEFO order (earliest expiry first, no expiry last).
  final List<BatchStock> batches;

  /// Σ of movements with no batch (negative-stock sales); usually <= 0.
  final int uncoveredMilli;

  /// Batches that still hold stock.
  List<BatchStock> get stocked => [
    for (final b in batches)
      if (b.remainingMilli > 0) b,
  ];

  /// Stock = Σ movements of the product.
  int get totalMilli =>
      batches.fold(0, (a, b) => a + b.remainingMilli) + uncoveredMilli;

  /// Stock at cost: stocked batches only (as `StockSummary`).
  Money get valueAtCost => stocked.fold(Money.zero, (a, b) => a + b.value);

  /// Cost the margin is measured against: the batch FEFO would sell next,
  /// else the newest batch; null when the product has no batch yet.
  Money? get referenceCost {
    final s = stocked;
    if (s.isNotEmpty) return s.first.cost;
    if (batches.isEmpty) return null;
    final newest = [...batches]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return newest.first.cost;
  }

  /// Margin of the price for [tier] over [referenceCost], in basis points.
  int? marginBp(String tier) {
    final price = product.prices.prices[tier];
    final cost = referenceCost;
    if (price == null || cost == null) return null;
    return Margin.basisPoints(price, cost);
  }

  StockProduct toStockProduct() => StockProduct(
    id: product.id,
    reorderLevelMilli: product.reorderLevelMilli,
    batches: [
      for (final b in batches) b.toStockBatch(),
      if (uncoveredMilli != 0)
        // The part no batch covered counts against the total, costs nothing.
        StockBatch(
          id: '',
          productId: product.id,
          batchNo: '',
          cost: Money.zero,
          remainingMilli: uncoveredMilli,
          createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        ),
    ],
  );

  ProductStockStatus get status => StockSummary.statusOf(toStockProduct());

  bool hasExpired(LedgerDate today) =>
      stocked.any((b) => b.isExpired(today));

  bool hasExpiring(LedgerDate today, int warnDays) =>
      stocked.any((b) => b.isExpiring(today, warnDays));
}

/// Stock filter chips of the screen.
enum StockFilter { all, low, out, expiring, expired }

/// Search and filters of the product list.
@immutable
class ProductFilter {
  const ProductFilter({
    this.query = '',
    this.categoryId,
    this.stock = StockFilter.all,
    this.includeInactive = false,
  });

  final String query;
  final String? categoryId;
  final StockFilter stock;
  final bool includeInactive;

  bool matches(ProductWithStock p, {
    required LedgerDate today,
    required int warnDays,
  }) {
    final prod = p.product;
    if (!includeInactive && !prod.isActive) return false;
    if (categoryId != null && prod.categoryId != categoryId) return false;
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty &&
        ![prod.name, prod.sku, prod.barcode, prod.brand].any(
          (s) => s != null && s.toLowerCase().contains(q),
        )) {
      return false;
    }
    return switch (stock) {
      StockFilter.all => true,
      StockFilter.low => p.status == ProductStockStatus.low,
      StockFilter.out => p.status == ProductStockStatus.out,
      StockFilter.expiring => p.hasExpiring(today, warnDays),
      StockFilter.expired => p.hasExpired(today),
    };
  }
}

/// Builds [ProductWithStock] from raw rows; pure, so it is unit tested.
abstract final class StockProjection {
  /// [movementSums] maps `productId` -> `batchId` (or '' for no batch) -> Σ.
  static List<ProductWithStock> build({
    required Iterable<Map<String, Object?>> productRows,
    required Iterable<Map<String, Object?>> batchRows,
    required Iterable<Map<String, Object?>> movementSumRows,
  }) {
    final sums = <String, Map<String, int>>{};
    for (final r in movementSumRows) {
      final byBatch = sums.putIfAbsent(
        r['product_id']! as String,
        () => <String, int>{},
      );
      final key = (r['batch_id'] as String?) ?? '';
      byBatch[key] = (byBatch[key] ?? 0) + ((r['q'] as int?) ?? 0);
    }
    final batchesOf = <String, List<BatchStock>>{};
    for (final r in batchRows) {
      final productId = r['product_id']! as String;
      final id = r['id']! as String;
      final mfg = r['mfg_date'] as String?;
      final exp = r['expiry_date'] as String?;
      batchesOf
          .putIfAbsent(productId, () => [])
          .add(
            BatchStock(
              id: id,
              productId: productId,
              batchNo: r['batch_no']! as String,
              cost: Money((r['cost_paise'] as int?) ?? 0),
              remainingMilli: sums[productId]?[id] ?? 0,
              cachedMilli: (r['qty_milli'] as int?) ?? 0,
              createdAt:
                  DateTime.tryParse((r['created_at'] as String?) ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
              mfgDate: mfg == null || mfg.isEmpty
                  ? null
                  : LedgerDate.parse(mfg),
              expiry: exp == null || exp.isEmpty ? null : LedgerDate.parse(exp),
            ),
          );
    }
    final out = <ProductWithStock>[];
    for (final r in productRows) {
      final product = Product.fromRow(r);
      final batches = [...?batchesOf[product.id]]
        ..sort(
          (a, b) => FefoPicker.compare(a.toStockBatch(), b.toStockBatch()),
        );
      out.add(
        ProductWithStock(
          product: product,
          batches: batches,
          uncoveredMilli: sums[product.id]?[''] ?? 0,
        ),
      );
    }
    return out;
  }

  static StockSummary summary(
    Iterable<ProductWithStock> products, {
    required LedgerDate today,
    required int warnDays,
  }) => StockSummary.of(
    [
      for (final p in products)
        if (p.product.isActive) p.toStockProduct(),
    ],
    today: today,
    expiryWarnDays: warnDays,
  );
}
