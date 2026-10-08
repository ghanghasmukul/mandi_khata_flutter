import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/pos/domain/pos_cart.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

/// Products for the counter: price tiers and stock left (Σ movements), read
/// from the local database. Every query filters by tenant.
class PosCatalog {
  PosCatalog(this._db);

  final PowerSyncDatabase _db;

  /// Active products with stock; expired stock counted per [today].
  Stream<List<PosProduct>> watch(String tenantId, LedgerDate today) => _db
      .watch(
        'WITH mv AS (SELECT product_id, SUM(qty_milli) AS q '
        'FROM stock_movements WHERE tenant_id = ?1 GROUP BY product_id), '
        'bm AS (SELECT batch_id, SUM(qty_milli) AS q FROM stock_movements '
        'WHERE tenant_id = ?1 AND batch_id IS NOT NULL GROUP BY batch_id), '
        'bx AS (SELECT b.product_id, '
        'SUM(CASE WHEN b.expiry_date < ?2 THEN COALESCE(bm.q, 0) ELSE 0 END) '
        'AS expired, '
        'MIN(CASE WHEN COALESCE(bm.q, 0) > 0 AND b.expiry_date >= ?2 '
        'THEN b.expiry_date END) AS nearest '
        'FROM batches b LEFT JOIN bm ON bm.batch_id = b.id '
        'WHERE b.tenant_id = ?1 GROUP BY b.product_id) '
        'SELECT p.id, p.sku, p.barcode, p.name, p.brand, p.unit, p.hsn, '
        'p.gst_rate, p.prices, COALESCE(mv.q, 0) AS stock, '
        'COALESCE(bx.expired, 0) AS expired, bx.nearest AS nearest '
        'FROM products p LEFT JOIN mv ON mv.product_id = p.id '
        'LEFT JOIN bx ON bx.product_id = p.id '
        'WHERE p.tenant_id = ?1 AND p.is_active = 1 AND p.deleted_at IS NULL '
        'ORDER BY p.name COLLATE NOCASE',
        parameters: [tenantId, today.toString()],
        triggerOnTables: const {'products', 'stock_movements', 'batches'},
      )
      .map((rows) => [for (final r in rows) _product(r)]);

  static PosProduct _product(Map<String, Object?> r) {
    Map<String, Object?> prices;
    try {
      prices = Map<String, Object?>.from(
        jsonDecode((r['prices'] as String?) ?? '{}') as Map,
      );
    } on FormatException {
      prices = const {};
    }
    final rate = r['gst_rate'];
    final hsn = r['hsn'] as String?;
    return PosProduct(
      id: r['id']! as String,
      sku: r['sku']! as String,
      barcode: r['barcode'] as String?,
      name: r['name']! as String,
      brand: r['brand'] as String?,
      unit: r['unit']! as String,
      hsn: hsn == null || hsn.isEmpty ? null : hsn,
      rateBp: rate is num ? (rate.toDouble() * 100).round() : null,
      prices: TierPrices.fromJson(prices),
      stockMilli: r['stock']! as int,
      expiredMilli: r['expired']! as int,
      nearestExpiry: (r['nearest'] as String?) == null
          ? null
          : LedgerDate.parse(r['nearest']! as String),
    );
  }
}

/// A bill put on hold (local only: the `held_bills` table is never synced).
class HeldBill {
  const HeldBill({
    required this.id,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final Map<String, Object?> payload;
  final DateTime createdAt;

  String? get partyName => payload['party_name'] as String?;
  int get lineCount => (payload['lines'] as List?)?.length ?? 0;
}

/// Hold and recall of bills on this device.
class HeldBillsRepository {
  HeldBillsRepository(this._db);

  final PowerSyncDatabase _db;

  Stream<List<HeldBill>> watch(String tenantId, String deviceId) => _db
      .watch(
        'SELECT id, payload, created_at FROM held_bills '
        'WHERE tenant_id = ? AND device_id = ? ORDER BY created_at DESC',
        parameters: [tenantId, deviceId],
        triggerOnTables: const {'held_bills'},
      )
      .map(
        (rows) => [
          for (final r in rows)
            HeldBill(
              id: r['id']! as String,
              payload: Map<String, Object?>.from(
                jsonDecode(r['payload']! as String) as Map,
              ),
              createdAt:
                  DateTime.tryParse((r['created_at'] as String?) ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
            ),
        ],
      );

  Future<String> hold(
    WriteContext ctx,
    Map<String, Object?> payload, {
    DateTime? now,
  }) async {
    final id = const Uuid().v4();
    await _db.execute(
      'INSERT INTO held_bills (id, tenant_id, device_id, payload, created_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [
        id,
        ctx.tenantId,
        ctx.deviceId,
        jsonEncode(payload),
        (now ?? DateTime.now()).toUtc().toIso8601String(),
      ],
    );
    return id;
  }

  Future<void> delete(String tenantId, String id) => _db.execute(
    'DELETE FROM held_bills WHERE tenant_id = ? AND id = ?',
    [tenantId, id],
  );
}
