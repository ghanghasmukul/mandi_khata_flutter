import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/products/domain/product.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Product masters and categories in the local database (offline-first).
///
/// Every query filters by `tenant_id`; every write is one local transaction
/// with its audit row. Needs `products.manage`; retiring (`deleted_at`) a
/// product or category needs `master.delete`, as on the server.
class ProductsRepository {
  ProductsRepository(this._db);

  final PowerSyncDatabase _db;

  // -- categories -----------------------------------------------------------

  Stream<List<ProductCategory>> watchCategories(String tenantId) => _db
      .watch(
        'SELECT * FROM product_categories WHERE tenant_id = ? '
        'AND deleted_at IS NULL ORDER BY sort_order, name',
        parameters: [tenantId],
        triggerOnTables: const {'product_categories'},
      )
      .map((rows) => [for (final r in rows) ProductCategory.fromRow(r)]);

  /// Adds a category; null when refused or the name is empty / taken.
  Future<String?> addCategory(
    WriteContext ctx,
    String name, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty || !can(Permission.productsManage)) return null;
    final when = (now ?? DateTime.now()).toUtc();
    final id = const Uuid().v4();
    return await _db.writeTransaction((tx) async {
      final taken = await tx.getOptional(
        'SELECT 1 FROM product_categories WHERE tenant_id = ? '
        'AND deleted_at IS NULL AND lower(name) = lower(?)',
        [ctx.tenantId, clean],
      );
      if (taken != null) return null;
      final at = when.toIso8601String();
      await tx.execute(
        'INSERT INTO product_categories (id, tenant_id, name, sort_order, '
        'is_active, created_by, created_at, updated_at) '
        'VALUES (?, ?, ?, 100, 1, ?, ?, ?)',
        [id, ctx.tenantId, clean, ctx.userId, at, at],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'product_categories',
        rowId: id,
        action: AuditAction.insert,
        after: {'name': clean},
        at: when,
      );
      return id;
    });
  }

  /// Renames a category, or retires it (`master.delete`) when [delete].
  Future<bool> updateCategory(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    String? name,
    bool delete = false,
    DateTime? now,
  }) async {
    if (!can(Permission.productsManage)) return false;
    if (delete && !can(Permission.masterDelete)) return false;
    if (name != null && name.trim().isEmpty) return false;
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM product_categories WHERE tenant_id = ? AND id = ? '
        'AND deleted_at IS NULL',
        [ctx.tenantId, id],
      );
      if (row == null) return false;
      final at = when.toIso8601String();
      await tx.execute(
        'UPDATE product_categories SET name = ?, deleted_at = ?, '
        'updated_at = ? WHERE tenant_id = ? AND id = ?',
        [
          name?.trim() ?? row['name'],
          if (delete) at else null,
          at,
          ctx.tenantId,
          id,
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'product_categories',
        rowId: id,
        action: delete ? AuditAction.softDelete : AuditAction.update,
        before: {'name': row['name']},
        after: {'name': name?.trim() ?? row['name']},
        at: when,
      );
      return true;
    });
  }

  // -- products -------------------------------------------------------------

  Stream<Product?> watchProduct(String tenantId, String id) => _db
      .watch(
        'SELECT * FROM products WHERE tenant_id = ? AND id = ? '
        'AND deleted_at IS NULL',
        parameters: [tenantId, id],
        triggerOnTables: const {'products'},
      )
      .map((rows) => rows.isEmpty ? null : Product.fromRow(rows.first));

  Future<Product?> getProduct(String tenantId, String id) async {
    final row = await _db.getOptional(
      'SELECT * FROM products WHERE tenant_id = ? AND id = ? '
      'AND deleted_at IS NULL',
      [tenantId, id],
    );
    return row == null ? null : Product.fromRow(row);
  }

  /// Active products as import references.
  Future<List<Map<String, Object?>>> productRefRows(String tenantId) =>
      _db.getAll(
        'SELECT id, sku, barcode, name FROM products WHERE tenant_id = ? '
        'AND deleted_at IS NULL AND is_active = 1',
        [tenantId],
      );

  /// A free SKU to prefill the form: `P0001`, `P0002`…
  Future<String> suggestSku(String tenantId) async {
    final n =
        (await _db.get(
              'SELECT COUNT(*) AS n FROM products WHERE tenant_id = ?',
              [tenantId],
            ))['n']!
            as int;
    for (var i = n + 1; ; i++) {
      final sku = 'P${i.toString().padLeft(4, '0')}';
      final taken = await _db.getOptional(
        'SELECT 1 FROM products WHERE tenant_id = ? AND lower(sku) = ?',
        [tenantId, sku.toLowerCase()],
      );
      if (taken == null) return sku;
    }
  }

  Future<ProductResult> create(
    WriteContext ctx,
    ProductInput input, {
    required bool Function(Permission) can,
    String? id,
    DateTime? now,
  }) async {
    if (!can(Permission.productsManage)) {
      return const ProductNotPermitted(Permission.productsManage);
    }
    final clean = input.normalised();
    final problems = clean.problems();
    if (problems.isNotEmpty) return ProductInvalid(problems);
    final when = (now ?? DateTime.now()).toUtc();
    final productId = id ?? const Uuid().v4();
    return await _db.writeTransaction((tx) async {
      final dup = await _duplicate(tx, ctx.tenantId, clean, exceptId: null);
      if (dup != null) return dup;
      if (!await _categoryOk(tx, ctx.tenantId, clean.categoryId)) {
        return const ProductNotFound();
      }
      final at = when.toIso8601String();
      await tx.execute(
        'INSERT INTO products (id, tenant_id, sku, barcode, name, brand, '
        'category_id, unit, pack_size, hsn, gst_rate, reorder_level_milli, '
        'prices, is_active, created_by, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)',
        [productId, ctx.tenantId, ..._columns(clean), ctx.userId, at, at],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'products',
        rowId: productId,
        action: AuditAction.insert,
        after: _audit(clean),
        at: when,
      );
      return ProductSaved(productId);
    });
  }

  Future<ProductResult> update(
    WriteContext ctx,
    String id,
    ProductInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.productsManage)) {
      return const ProductNotPermitted(Permission.productsManage);
    }
    final clean = input.normalised();
    final problems = clean.problems();
    if (problems.isNotEmpty) return ProductInvalid(problems);
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM products WHERE tenant_id = ? AND id = ? '
        'AND deleted_at IS NULL',
        [ctx.tenantId, id],
      );
      if (row == null) return const ProductNotFound();
      final before = Product.fromRow(row);
      if (before.unit != clean.unit) {
        final hasBatches = await tx.getOptional(
          'SELECT 1 FROM batches WHERE tenant_id = ? AND product_id = ?',
          [ctx.tenantId, id],
        );
        if (hasBatches != null) return const ProductUnitLocked();
      }
      final dup = await _duplicate(tx, ctx.tenantId, clean, exceptId: id);
      if (dup != null) return dup;
      if (clean.categoryId != before.categoryId &&
          !await _categoryOk(tx, ctx.tenantId, clean.categoryId)) {
        return const ProductNotFound();
      }
      await tx.execute(
        'UPDATE products SET sku = ?, barcode = ?, name = ?, brand = ?, '
        'category_id = ?, unit = ?, pack_size = ?, hsn = ?, gst_rate = ?, '
        'reorder_level_milli = ?, prices = ?, updated_at = ? '
        'WHERE tenant_id = ? AND id = ?',
        [..._columns(clean), when.toIso8601String(), ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'products',
        rowId: id,
        action: AuditAction.update,
        before: _audit(
          ProductInput(
            sku: before.sku,
            barcode: before.barcode,
            name: before.name,
            brand: before.brand,
            categoryId: before.categoryId,
            unit: before.unit,
            packSize: before.packSize,
            hsn: before.hsn,
            gstRateBp: before.gstRateBp,
            reorderLevelMilli: before.reorderLevelMilli,
            prices: before.prices.toJson(),
          ),
        ),
        after: _audit(clean),
        at: when,
      );
      return ProductSaved(id);
    });
  }

  /// Switches a product on or off for sale (`is_active`); it stays in the
  /// books and reports.
  Future<ProductResult> setActive(
    WriteContext ctx,
    String id, {
    required bool active,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.productsManage)) {
      return const ProductNotPermitted(Permission.productsManage);
    }
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT is_active FROM products WHERE tenant_id = ? AND id = ? '
        'AND deleted_at IS NULL',
        [ctx.tenantId, id],
      );
      if (row == null) return const ProductNotFound();
      await tx.execute(
        'UPDATE products SET is_active = ?, updated_at = ? '
        'WHERE tenant_id = ? AND id = ?',
        [if (active) 1 else 0, when.toIso8601String(), ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'products',
        rowId: id,
        action: AuditAction.update,
        before: {'is_active': row['is_active'] == 1},
        after: {'is_active': active},
        at: when,
      );
      return ProductSaved(id);
    });
  }

  /// Soft delete (`deleted_at`, needs `master.delete`). Refused while the
  /// product still has stock: adjust it to zero first.
  Future<ProductResult> delete(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.productsManage)) {
      return const ProductNotPermitted(Permission.productsManage);
    }
    if (!can(Permission.masterDelete)) {
      return const ProductNotPermitted(Permission.masterDelete);
    }
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT sku, name FROM products WHERE tenant_id = ? AND id = ? '
        'AND deleted_at IS NULL',
        [ctx.tenantId, id],
      );
      if (row == null) return const ProductNotFound();
      final stock = await tx.get(
        'SELECT COALESCE(SUM(qty_milli), 0) AS q FROM stock_movements '
        'WHERE tenant_id = ? AND product_id = ?',
        [ctx.tenantId, id],
      );
      if ((stock['q']! as int) != 0) return const ProductHasStock();
      final at = when.toIso8601String();
      await tx.execute(
        'UPDATE products SET deleted_at = ?, is_active = 0, updated_at = ? '
        'WHERE tenant_id = ? AND id = ?',
        [at, at, ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'products',
        rowId: id,
        action: AuditAction.softDelete,
        before: {'sku': row['sku'], 'name': row['name']},
        at: when,
      );
      return ProductSaved(id);
    });
  }

  // -- helpers --------------------------------------------------------------

  static List<Object?> _columns(ProductInput p) => [
    p.sku,
    p.barcode,
    p.name,
    p.brand,
    p.categoryId,
    p.unit.dbName,
    p.packSize,
    p.hsn,
    p.gstRateBp / 100.0,
    p.reorderLevelMilli,
    jsonEncode(
      TierPrices({
        for (final e in p.prices.entries) e.key: Money(e.value),
      }).toJson(),
    ),
  ];

  static Map<String, Object?> _audit(ProductInput p) => {
    'sku': p.sku,
    'barcode': ?p.barcode,
    'name': p.name,
    'brand': ?p.brand,
    'category_id': ?p.categoryId,
    'unit': p.unit.dbName,
    'pack_size': ?p.packSize,
    'hsn': ?p.hsn,
    'gst_rate_bp': p.gstRateBp,
    'reorder_level_milli': p.reorderLevelMilli,
    'prices': p.prices,
  };

  /// SKU and barcode are unique per business, also against retired products
  /// (the server's unique constraints do not look at `deleted_at`).
  static Future<ProductDuplicate?> _duplicate(
    SqliteWriteContext tx,
    String tenantId,
    ProductInput p, {
    required String? exceptId,
  }) async {
    final sku = await tx.getOptional(
      'SELECT name FROM products WHERE tenant_id = ? AND lower(sku) = ? '
      'AND id <> ?',
      [tenantId, p.sku.toLowerCase(), exceptId ?? ''],
    );
    if (sku != null) {
      return ProductDuplicate(
        ProductDuplicateField.sku,
        sku['name']! as String,
      );
    }
    final barcode = p.barcode;
    if (barcode != null) {
      final b = await tx.getOptional(
        'SELECT name FROM products WHERE tenant_id = ? AND barcode = ? '
        'AND id <> ?',
        [tenantId, barcode, exceptId ?? ''],
      );
      if (b != null) {
        return ProductDuplicate(
          ProductDuplicateField.barcode,
          b['name']! as String,
        );
      }
    }
    return null;
  }

  static Future<bool> _categoryOk(
    SqliteWriteContext tx,
    String tenantId,
    String? categoryId,
  ) async {
    if (categoryId == null) return true;
    return await tx.getOptional(
          'SELECT 1 FROM product_categories WHERE tenant_id = ? AND id = ? '
          'AND deleted_at IS NULL',
          [tenantId, categoryId],
        ) !=
        null;
  }
}
