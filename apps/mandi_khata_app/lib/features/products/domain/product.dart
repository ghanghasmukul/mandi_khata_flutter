import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// Unit a product is counted in (`products.unit`).
enum ProductUnit {
  bag,
  btl,
  ltr,
  kg,
  pkt,
  pc;

  String get dbName => name;

  static ProductUnit? tryParse(String? text) {
    final t = text?.trim().toLowerCase();
    if (t == null || t.isEmpty) return null;
    for (final u in values) {
      if (u.name == t) return u;
    }
    return switch (t) {
      'bottle' || 'bottles' || 'bot' => btl,
      'litre' || 'liter' || 'l' => ltr,
      'packet' || 'packets' || 'pack' => pkt,
      'piece' || 'pieces' || 'pcs' || 'nos' => pc,
      'bags' => bag,
      'kgs' => kg,
      _ => null,
    };
  }
}

/// A product category (`product_categories`).
@immutable
class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  factory ProductCategory.fromRow(Map<String, Object?> r) => ProductCategory(
    id: r['id']! as String,
    name: r['name']! as String,
    sortOrder: (r['sort_order'] as int?) ?? 0,
    isActive: r['is_active'] == 1,
  );

  final String id;
  final String name;
  final int sortOrder;
  final bool isActive;
}

/// A product master row.
@immutable
class Product {
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.unit,
    required this.gstRateBp,
    required this.reorderLevelMilli,
    required this.prices,
    required this.isActive,
    this.barcode,
    this.brand,
    this.categoryId,
    this.packSize,
    this.hsn,
  });

  factory Product.fromRow(Map<String, Object?> r) => Product(
    id: r['id']! as String,
    sku: r['sku']! as String,
    barcode: r['barcode'] as String?,
    name: r['name']! as String,
    brand: r['brand'] as String?,
    categoryId: r['category_id'] as String?,
    unit: ProductUnit.tryParse(r['unit'] as String?) ?? ProductUnit.pc,
    packSize: r['pack_size'] as String?,
    hsn: r['hsn'] as String?,
    gstRateBp: (((r['gst_rate'] as num?) ?? 0) * 100).round(),
    reorderLevelMilli: (r['reorder_level_milli'] as int?) ?? 0,
    prices: parsePrices(r['prices']),
    isActive: r['is_active'] == 1,
  );

  /// `{"retail": 12000}` -> tier prices; bad entries are dropped.
  static TierPrices parsePrices(Object? raw) {
    if (raw is! String || raw.isEmpty) return const TierPrices({});
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        return TierPrices.fromJson(json.cast<String, Object?>());
      }
    } on FormatException {
      // Fall through: a broken price list means no prices.
    }
    return const TierPrices({});
  }

  final String id;
  final String sku;
  final String? barcode;
  final String name;
  final String? brand;
  final String? categoryId;
  final ProductUnit unit;
  final String? packSize;
  final String? hsn;

  /// GST rate in basis points (500 = 5%).
  final int gstRateBp;
  final int reorderLevelMilli;
  final TierPrices prices;
  final bool isActive;
}

/// What a person types in the product form.
@immutable
class ProductInput {
  const ProductInput({
    required this.sku,
    required this.name,
    required this.unit,
    this.barcode,
    this.brand,
    this.categoryId,
    this.packSize,
    this.hsn,
    this.gstRateBp = 0,
    this.reorderLevelMilli = 0,
    this.prices = const {},
  });

  final String sku;
  final String? barcode;
  final String name;
  final String? brand;
  final String? categoryId;
  final ProductUnit unit;
  final String? packSize;
  final String? hsn;
  final int gstRateBp;
  final int reorderLevelMilli;

  /// Paise per unit by tier. A tier with no price is simply absent.
  final Map<String, int> prices;

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  /// Trimmed text, blank optional fields as null.
  ProductInput normalised() => ProductInput(
    sku: sku.trim(),
    barcode: _clean(barcode),
    name: name.trim(),
    brand: _clean(brand),
    categoryId: _clean(categoryId),
    unit: unit,
    packSize: _clean(packSize),
    hsn: _clean(hsn),
    gstRateBp: gstRateBp,
    reorderLevelMilli: reorderLevelMilli,
    prices: prices,
  );

  /// Everything wrong with the (normalised) input; empty when it can be saved.
  List<ProductProblem> problems() {
    final n = normalised();
    return [
      if (n.name.isEmpty) ProductProblem.nameMissing,
      if (n.sku.isEmpty) ProductProblem.skuMissing,
      if (!GstRates.isValid(n.gstRateBp)) ProductProblem.gstRateInvalid,
      if (n.hsn != null && !RegExp(r'^(\d{4}|\d{6}|\d{8})$').hasMatch(n.hsn!))
        ProductProblem.hsnInvalid,
      if (n.reorderLevelMilli < 0) ProductProblem.reorderInvalid,
      if (n.prices.values.any((p) => p < 0)) ProductProblem.priceInvalid,
    ];
  }
}

enum ProductProblem {
  nameMissing,
  skuMissing,
  gstRateInvalid,
  hsnInvalid,
  reorderInvalid,
  priceInvalid,
}

/// How a product save ended.
sealed class ProductResult {
  const ProductResult();
}

final class ProductSaved extends ProductResult {
  const ProductSaved(this.id);

  final String id;
}

final class ProductInvalid extends ProductResult {
  const ProductInvalid(this.problems);

  final List<ProductProblem> problems;
}

enum ProductDuplicateField { sku, barcode }

/// Another product of this business already has the SKU / barcode.
final class ProductDuplicate extends ProductResult {
  const ProductDuplicate(this.field, this.otherName);

  final ProductDuplicateField field;
  final String otherName;
}

final class ProductNotPermitted extends ProductResult {
  const ProductNotPermitted(this.permission);

  final Permission permission;
}

final class ProductNotFound extends ProductResult {
  const ProductNotFound();
}

/// The unit cannot change once the product has batches.
final class ProductUnitLocked extends ProductResult {
  const ProductUnitLocked();
}

/// A product with stock cannot be deleted.
final class ProductHasStock extends ProductResult {
  const ProductHasStock();
}
