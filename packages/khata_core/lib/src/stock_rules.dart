import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/shop_math.dart';
import 'package:meta/meta.dart';

/// Why stock moved (`stock_movements.reason`).
enum StockMovementReason {
  purchase('purchase', 1),
  sale('sale', -1),
  saleReturn('sale_return', 1),
  purchaseReturn('purchase_return', -1),

  /// Count difference, damage, write-off: either sign.
  adjustment('adjustment', 0),
  opening('opening', 1);

  const StockMovementReason(this.dbName, this.sign);

  final String dbName;

  /// +1 inbound only, -1 outbound only, 0 either.
  final int sign;

  /// Whether a movement of [qtyMilli] is allowed for this reason: never 0,
  /// and the sign must agree with [sign].
  bool accepts(int qtyMilli) =>
      qtyMilli != 0 && (sign == 0 || qtyMilli.sign == sign);

  static StockMovementReason parse(String value) => values.firstWhere(
    (r) => r.dbName == value,
    orElse: () => throw FormatException('Unknown stock reason', value),
  );
}

/// Quantities are whole thousandths of a unit (`qty_milli`): 2.5 kg = 2500.
abstract final class Qty {
  static const unit = 1000;
  static final _pattern = RegExp(r'^(\d{0,9})(?:\.(\d{0,3}))?$');

  static int fromUnits(int units) => units * unit;

  /// `2.5` -> 2500, `12` -> 12000, `.5` -> 500; null when empty, malformed
  /// or with more than 3 decimals. Spaces and commas are ignored.
  static int? parse(String text) {
    final m = _pattern.firstMatch(text.replaceAll(RegExp(r'[\s,]'), ''));
    if (m == null) return null;
    final whole = m[1]!;
    final fraction = m[2] ?? '';
    if (whole.isEmpty && fraction.isEmpty) return null;
    return int.parse(whole.isEmpty ? '0' : whole) * unit +
        int.parse(fraction.padRight(3, '0'));
  }

  /// 2500 -> `2.5`, 3000 -> `3`, -1250 -> `-1.25`: decimals only when needed.
  static String format(int milli) {
    final v = milli.abs();
    final fraction = (v % unit)
        .toString()
        .padLeft(3, '0')
        .replaceFirst(RegExp(r'0+$'), '');
    final body = fraction.isEmpty ? '${v ~/ unit}' : '${v ~/ unit}.$fraction';
    return milli < 0 ? '-$body' : body;
  }
}

/// One line of the stock book.
@immutable
final class StockMovement {
  /// Throws [ArgumentError] when [qtyMilli] is 0 or has the wrong sign for
  /// [reason].
  StockMovement({
    required this.productId,
    required this.qtyMilli,
    required this.reason,
    this.batchId,
  }) {
    if (!reason.accepts(qtyMilli)) {
      throw ArgumentError.value(
        qtyMilli,
        'qtyMilli',
        'not allowed for ${reason.dbName}',
      );
    }
  }

  final String productId;

  /// Null only for a negative-stock sale that no batch covered.
  final String? batchId;
  final int qtyMilli;
  final StockMovementReason reason;
}

/// Stock = Σ movements (docs/domain/shop-rules.md section 1).
abstract final class StockBalance {
  static Map<String, int> byProduct(Iterable<StockMovement> movements) {
    final out = <String, int>{};
    for (final m in movements) {
      out.update(
        m.productId,
        (v) => v + m.qtyMilli,
        ifAbsent: () => m.qtyMilli,
      );
    }
    return out;
  }

  /// Per batch; movements without a batch are left out.
  static Map<String, int> byBatch(Iterable<StockMovement> movements) {
    final out = <String, int>{};
    for (final m in movements) {
      final b = m.batchId;
      if (b == null) continue;
      out.update(b, (v) => v + m.qtyMilli, ifAbsent: () => m.qtyMilli);
    }
    return out;
  }

  static int total(Iterable<StockMovement> movements) =>
      movements.fold(0, (a, m) => a + m.qtyMilli);
}

/// A batch of a product with what is left of it.
@immutable
final class StockBatch {
  const StockBatch({
    required this.id,
    required this.productId,
    required this.batchNo,
    required this.cost,
    required this.remainingMilli,
    required this.createdAt,
    this.expiry,
  });

  final String id;
  final String productId;
  final String batchNo;

  /// Cost per whole unit.
  final Money cost;
  final int remainingMilli;
  final DateTime createdAt;

  /// Last day it may be sold; null = does not expire.
  final LedgerDate? expiry;

  bool isExpired(LedgerDate today) => expiry != null && expiry! < today;

  /// Still sellable today but expiring within [warnDays].
  bool isExpiring(LedgerDate today, int warnDays) =>
      expiry != null &&
      !isExpired(today) &&
      today.daysUntil(expiry!) <= warnDays;

  /// Cost of what is left.
  Money get value => ShopMath.valueOf(cost, remainingMilli);
}

/// Stock policy from the settings.
@immutable
final class StockPolicy {
  const StockPolicy({
    this.blockExpired = true,
    this.allowNegative = false,
    this.expiryWarnDays = 60,
  });

  /// `shop.block_expired`
  final bool blockExpired;

  /// `shop.allow_negative_stock`
  final bool allowNegative;

  /// `shop.expiry_warn_days`
  final int expiryWarnDays;
}

/// Part of a sale line served from one batch.
@immutable
final class BatchAllocation {
  const BatchAllocation({
    required this.batchId,
    required this.qtyMilli,
    required this.unitCost,
    required this.expiry,
    required this.expired,
  });

  final String batchId;
  final int qtyMilli;
  final Money unitCost;
  final LedgerDate? expiry;
  final bool expired;

  /// Cost of goods sold for this part.
  Money get cost => ShopMath.valueOf(unitCost, qtyMilli);
}

enum StockWarningKind { nearExpiry, expiredSold, negativeStock }

enum StockErrorKind { insufficientStock, expiredBlocked }

@immutable
final class StockWarning {
  const StockWarning(this.kind, {this.batchId, this.qtyMilli = 0});

  final StockWarningKind kind;
  final String? batchId;

  /// For [StockWarningKind.negativeStock]: the part no batch covers.
  final int qtyMilli;
}

/// What [FefoPicker.pick] decided.
@immutable
final class FefoResult {
  const FefoResult({
    required this.allocations,
    required this.shortMilli,
    required this.expiredBlockedMilli,
    required this.warnings,
    required this.error,
  });

  final List<BatchAllocation> allocations;

  /// Quantity no batch could serve.
  final int shortMilli;

  /// Stock that exists but is expired and blocked by the policy.
  final int expiredBlockedMilli;
  final List<StockWarning> warnings;

  /// Null when the line can be sold (possibly with [warnings]).
  final StockErrorKind? error;

  bool get canSell => error == null;
  int get allocatedMilli => allocations.fold(0, (a, x) => a + x.qtyMilli);
  Money get cost => allocations.fold(Money.zero, (a, x) => a + x.cost);
}

/// First-expiry-first-out batch picking (shop-rules section 1).
abstract final class FefoPicker {
  /// Earliest expiry first, no expiry last, then oldest created, then id.
  static int compare(StockBatch a, StockBatch b) {
    final ea = a.expiry;
    final eb = b.expiry;
    if (ea != eb) {
      if (ea == null) return 1;
      if (eb == null) return -1;
      return ea.compareTo(eb);
    }
    final c = a.createdAt.compareTo(b.createdAt);
    return c != 0 ? c : a.id.compareTo(b.id);
  }

  /// Fills [qtyMilli] from [batches] (any product; pass only the product's
  /// own). Fresh batches go first; expired ones are skipped when the policy
  /// blocks them, else used last with a warning. A shortfall is an error
  /// unless negative stock is allowed and nothing was blocked by expiry.
  static FefoResult pick({
    required List<StockBatch> batches,
    required int qtyMilli,
    required LedgerDate today,
    StockPolicy policy = const StockPolicy(),
  }) {
    if (qtyMilli <= 0) {
      throw ArgumentError.value(qtyMilli, 'qtyMilli', 'must be positive');
    }
    final live = batches.where((b) => b.remainingMilli > 0).toList()
      ..sort(compare);
    final fresh = live.where((b) => !b.isExpired(today));
    final expired = live.where((b) => b.isExpired(today)).toList();
    final order = [...fresh, if (!policy.blockExpired) ...expired];
    final blocked = policy.blockExpired
        ? expired.fold<int>(0, (a, b) => a + b.remainingMilli)
        : 0;

    final allocations = <BatchAllocation>[];
    final warnings = <StockWarning>[];
    var left = qtyMilli;
    for (final b in order) {
      if (left == 0) break;
      final take = left < b.remainingMilli ? left : b.remainingMilli;
      left -= take;
      final isExpired = b.isExpired(today);
      allocations.add(
        BatchAllocation(
          batchId: b.id,
          qtyMilli: take,
          unitCost: b.cost,
          expiry: b.expiry,
          expired: isExpired,
        ),
      );
      if (isExpired) {
        warnings.add(StockWarning(StockWarningKind.expiredSold, batchId: b.id));
      } else if (b.isExpiring(today, policy.expiryWarnDays)) {
        warnings.add(StockWarning(StockWarningKind.nearExpiry, batchId: b.id));
      }
    }

    StockErrorKind? error;
    if (left > 0) {
      if (policy.allowNegative && blocked == 0) {
        warnings.add(
          StockWarning(StockWarningKind.negativeStock, qtyMilli: left),
        );
      } else {
        error = blocked > 0
            ? StockErrorKind.expiredBlocked
            : StockErrorKind.insufficientStock;
      }
    }
    return FefoResult(
      allocations: allocations,
      shortMilli: left,
      expiredBlockedMilli: blocked,
      warnings: warnings,
      error: error,
    );
  }
}

/// A product with its batches, for status and value.
@immutable
final class StockProduct {
  const StockProduct({
    required this.id,
    required this.batches,
    this.reorderLevelMilli = 0,
  });

  final String id;
  final List<StockBatch> batches;
  final int reorderLevelMilli;

  int get totalMilli => batches.fold(0, (a, b) => a + b.remainingMilli);
}

enum ProductStockStatus { ok, low, out }

/// The counts on the stock screen.
@immutable
final class StockSummary {
  const StockSummary({
    required this.valueAtCost,
    required this.lowCount,
    required this.outCount,
    required this.expiringCount,
    required this.expiredCount,
  });

  factory StockSummary.of(
    Iterable<StockProduct> products, {
    required LedgerDate today,
    int expiryWarnDays = 60,
  }) {
    var value = Money.zero;
    var low = 0;
    var out = 0;
    var expiring = 0;
    var expired = 0;
    for (final p in products) {
      final stocked = p.batches.where((b) => b.remainingMilli > 0);
      for (final b in stocked) {
        value += b.value;
      }
      switch (statusOf(p)) {
        case ProductStockStatus.out:
          out++;
        case ProductStockStatus.low:
          low++;
        case ProductStockStatus.ok:
      }
      if (stocked.any((b) => b.isExpired(today))) expired++;
      if (stocked.any((b) => b.isExpiring(today, expiryWarnDays))) expiring++;
    }
    return StockSummary(
      valueAtCost: value,
      lowCount: low,
      outCount: out,
      expiringCount: expiring,
      expiredCount: expired,
    );
  }

  /// Products at or under their reorder level, but not out.
  final int lowCount;

  /// Products with no stock left.
  final int outCount;

  /// Products with stock expiring within the warn days.
  final int expiringCount;

  /// Products with expired stock still on the shelf.
  final int expiredCount;
  final Money valueAtCost;

  /// Stock status of one product: out when nothing is left, low when it is
  /// at or under a reorder level above zero.
  static ProductStockStatus statusOf(StockProduct p) {
    final total = p.totalMilli;
    if (total <= 0) return ProductStockStatus.out;
    if (p.reorderLevelMilli > 0 && total <= p.reorderLevelMilli) {
      return ProductStockStatus.low;
    }
    return ProductStockStatus.ok;
  }
}

/// Margin of a selling price over cost.
abstract final class Margin {
  /// `(price - cost) / price` in basis points (2550 = 25.50%), half-up;
  /// null when [price] is not above zero. Negative when selling below cost.
  static int? basisPoints(Money price, Money cost) => price.isPositive
      ? ShopMath.mulDivRound(price.paise - cost.paise, 10000, price.paise)
      : null;

  /// `25.5%`, `-3.25%`, `12%`: up to two decimals, none when whole.
  static String format(int basisPoints) {
    final v = basisPoints.abs();
    final fraction = (v % 100)
        .toString()
        .padLeft(2, '0')
        .replaceFirst(RegExp(r'0+$'), '');
    final body = fraction.isEmpty ? '${v ~/ 100}' : '${v ~/ 100}.$fraction';
    return '${basisPoints < 0 ? '-' : ''}$body%';
  }
}
