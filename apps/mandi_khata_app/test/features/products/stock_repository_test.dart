import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/products/data/products_repository.dart';
import 'package:mandi_khata_app/features/products/data/stock_repository.dart';
import 'package:mandi_khata_app/features/products/domain/opening_stock_import.dart';
import 'package:mandi_khata_app/features/products/domain/product.dart';
import 'package:mandi_khata_app/features/products/domain/stock.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const ctx2 = WriteContext(
  tenantId: t2,
  userId: 'user-x',
  deviceId: 'device-x1',
  deviceCode: 'X1',
);

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

final now = DateTime.utc(2027, 4, 30, 6);
final today = LedgerDate(2027, 4, 30);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late ProductsRepository products;
  late StockRepository stock;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_products_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    products = ProductsRepository(db);
    stock = StockRepository(db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  ProductInput input(String sku, {String? barcode, String name = 'Urea'}) =>
      ProductInput(
        sku: sku,
        barcode: barcode,
        name: name,
        unit: ProductUnit.bag,
        gstRateBp: 500,
        reorderLevelMilli: 5000,
        prices: const {'retail': 30000, 'farmer': 28000},
      );

  Future<String> make(
    String sku, {
    WriteContext c = ctx,
    String? barcode,
    String name = 'Urea',
  }) async {
    final r = await products.create(
      c,
      input(sku, barcode: barcode, name: name),
      can: owner,
      now: now,
    );
    return (r as ProductSaved).id;
  }

  Future<int> count(String sql, [List<Object?> args = const []]) async =>
      (await db.get('SELECT COUNT(*) AS n FROM $sql', args))['n']! as int;

  OpeningStockPreview preview(String text, List<ProductRef> refs) =>
      OpeningStockImport.preview(DelimitedText.parse(text), products: refs);

  /// Σ movements must equal the screen's numbers for every product / batch.
  Future<void> expectStockIsSumOfMovements(String tenant) async {
    final all = await stock
        .watchProducts(
          tenant,
          filter: const ProductFilter(includeInactive: true),
        )
        .first;
    for (final p in all) {
      final sum =
          (await db.get(
                'SELECT COALESCE(SUM(qty_milli),0) AS q FROM stock_movements '
                'WHERE tenant_id = ? AND product_id = ?',
                [tenant, p.product.id],
              ))['q']!
              as int;
      expect(p.totalMilli, sum, reason: p.product.name);
      expect(await stock.stockMilli(tenant, p.product.id), sum);
      for (final b in p.batches) {
        final bs =
            (await db.get(
                  'SELECT COALESCE(SUM(qty_milli),0) AS q FROM stock_movements '
                  'WHERE tenant_id = ? AND batch_id = ?',
                  [tenant, b.id],
                ))['q']!
                as int;
        expect(b.remainingMilli, bs);
      }
    }
  }

  test('create, SKU / barcode uniqueness, audit, permission', () async {
    final id = await make('P1', barcode: '890');
    expect(await count('audit_log WHERE table_name = ?', ['products']), 1);
    final dupSku = await products.create(ctx, input('p1'), can: owner);
    expect((dupSku as ProductDuplicate).field, ProductDuplicateField.sku);
    final dupBar = await products.create(
      ctx,
      input('P2', barcode: '890'),
      can: owner,
    );
    expect((dupBar as ProductDuplicate).field, ProductDuplicateField.barcode);
    // The same SKU in another business is fine.
    await make('P1', c: ctx2);
    final denied = await products.create(ctx, input('P9'), can: munshi);
    expect(denied, isA<ProductNotPermitted>());
    final bad = await products.create(
      ctx,
      const ProductInput(
        sku: ' ',
        name: '',
        unit: ProductUnit.kg,
        gstRateBp: 777,
        hsn: '12',
      ),
      can: owner,
    );
    expect(
      (bad as ProductInvalid).problems,
      containsAll([
        ProductProblem.nameMissing,
        ProductProblem.skuMissing,
        ProductProblem.gstRateInvalid,
        ProductProblem.hsnInvalid,
      ]),
    );
    final upd = await products.update(
      ctx,
      id,
      input('P1', barcode: '890', name: 'Urea 50kg'),
      can: owner,
    );
    expect(upd, isA<ProductSaved>());
    expect((await products.getProduct(t1, id))!.name, 'Urea 50kg');
    expect(await products.getProduct(t2, id), isNull);
  });

  test('opening import: movements, journal, audit; idempotent', () async {
    final a = await make('A');
    final b = await make('B', name: 'DAP');
    final refs = await stock.productRefs(t1);
    final p = preview(
      'sku,batch,expiry,qty,cost\n'
      'A,B1,31/12/2027,10,250\n'
      'A,B2,,5.5,260\n'
      'B,X1,2027-06-30,20,1000\n',
      refs,
    );
    expect(p.canImport, isTrue);
    final r = await stock.importOpening(
      ctx,
      p,
      asOn: today,
      can: owner,
      now: now,
    );
    expect(r, isA<OpeningStockImported>());
    expect((r as OpeningStockImported).rows, 3);
    // 10*250 + 5.5*260 + 20*1000 = 2500 + 1430 + 20000
    expect(r.value, const Money.rupees(23930));
    await expectStockIsSumOfMovements(t1);
    expect(await stock.stockMilli(t1, a), 15500);
    expect(await stock.stockMilli(t1, b), 20000);
    final batches = await stock.batchesFor(t1, a);
    // FEFO order: the batch with an expiry first.
    expect(batches.map((x) => x.batchNo), ['B1', 'B2']);

    final entries = await db.getAll(
      'SELECT * FROM journal_entries WHERE tenant_id = ?',
      [t1],
    );
    expect(entries, hasLength(1));
    expect(entries.first['source_key'], startsWith('stock_adjustment:'));
    final lines = await db.getAll(
      'SELECT SUM(debit_paise) AS d, SUM(credit_paise) AS c FROM journal_lines '
      'WHERE journal_entry_id = ?',
      [entries.first['id']],
    );
    expect(lines.first['d'], 2393000);
    expect(lines.first['c'], 2393000);
    expect(
      await count('audit_log WHERE table_name = ?', ['stock_movements']),
      3,
    );

    final again = await stock.importOpening(
      ctx,
      p,
      asOn: today,
      can: owner,
      now: now,
    );
    expect(again, isA<OpeningStockAlready>());
    expect(await count('stock_movements'), 3);
    expect(await count('batches'), 3);
    expect(await count('journal_entries'), 1);
  });

  test('import preview reports per-row problems and imports nothing', () async {
    await make('A');
    final refs = await stock.productRefs(t1);
    final p = preview(
      'sku,batch,qty,cost\nA,B1,10,250\nZZ,B1,3,10\nA,B1,2,250\nA,B3,x,5\n',
      refs,
    );
    expect(p.canImport, isFalse);
    expect(p.rows[1].problems, [StockRowProblem.unknownProduct]);
    expect(p.rows[2].problems, [StockRowProblem.duplicateInFile]);
    expect(p.rows[3].problems, [StockRowProblem.qtyInvalid]);
    final r = await stock.importOpening(ctx, p, asOn: today, can: owner);
    expect(r, isA<OpeningStockInvalid>());
    expect(await count('stock_movements'), 0);
  });

  test('import needs stock.adjust', () async {
    await make('A');
    final p = preview('sku,qty,cost\nA,1,10\n', await stock.productRefs(t1));
    final r = await stock.importOpening(ctx, p, asOn: today, can: munshi);
    expect(r, isA<StockNotPermitted>());
    expect(await count('stock_movements'), 0);
  });

  test(
    'adjustment: reason and permission required; cache and journal',
    () async {
      final a = await make('A');
      await stock.importOpening(
        ctx,
        preview(
          'sku,batch,qty,cost\nA,B1,10,100\n',
          await stock.productRefs(t1),
        ),
        asOn: today,
        can: owner,
        now: now,
      );
      final batchId = (await stock.batchesFor(t1, a)).single.id;

      Future<StockResult> adj(
        int d,
        String note, {
        bool Function(Permission)? can,
      }) => stock.adjust(
        ctx,
        productId: a,
        batchId: batchId,
        deltaMilli: d,
        note: note,
        can: can ?? owner,
        now: now,
      );

      expect((await adj(-2000, '  ') as StockInvalid).problems, [
        StockAdjustProblem.noteMissing,
      ]);
      expect(await adj(0, 'x'), isA<StockInvalid>());
      expect(
        await adj(-2000, 'damaged', can: munshi),
        isA<StockNotPermitted>(),
      );
      expect((await adj(-11000, 'too much') as StockInvalid).problems, [
        StockAdjustProblem.wouldGoNegative,
      ]);
      expect(await count('stock_movements'), 1);

      final ok = await adj(-2000, 'damaged') as StockAdjusted;
      expect(ok.remainingMilli, 8000);
      expect(ok.value, const Money.rupees(-200));
      await expectStockIsSumOfMovements(t1);
      final move = await db.get(
        "SELECT * FROM stock_movements WHERE reason = 'adjustment'",
      );
      expect(move['note'], 'damaged');
      expect(move['qty_milli'], -2000);
      // Loss: Dr Stock Adjustment, Cr Stock-in-Hand.
      expect(await count('journal_entries'), 2);
      final found = await adj(500, 'found') as StockAdjusted;
      expect(found.value, const Money.rupees(50));
      await expectStockIsSumOfMovements(t1);
    },
  );

  test('rebuildBatchQty repairs a stale cache', () async {
    final a = await make('A');
    await stock.importOpening(
      ctx,
      preview('sku,qty,cost\nA,4,10\n', await stock.productRefs(t1)),
      asOn: today,
      can: owner,
      now: now,
    );
    await db.execute('UPDATE batches SET qty_milli = 1');
    final b = (await stock.batchesFor(t1, a)).single;
    expect(b.cacheStale, isTrue);
    expect(b.remainingMilli, 4000);
    expect(await stock.rebuildBatchQty(ctx, can: munshi), isNull);
    expect(await stock.rebuildBatchQty(ctx, can: owner), 1);
    await expectStockIsSumOfMovements(t1);
  });

  test('tenant isolation: stock, summary and writes never cross', () async {
    final a = await make('A');
    final x = await make('A', c: ctx2, name: 'Other');
    await stock.importOpening(
      ctx,
      preview('sku,qty,cost\nA,4,10\n', await stock.productRefs(t1)),
      asOn: today,
      can: owner,
      now: now,
    );
    expect(await stock.stockMilli(t2, a), 0);
    expect(await stock.stockMilli(t1, x), 0);
    expect(await stock.batchesFor(t2, a), isEmpty);
    expect((await stock.watchProducts(t2).first).map((p) => p.product.name), [
      'Other',
    ]);
    final s2 = await stock.watchSummary(t2, today: today).first;
    expect(s2.valueAtCost, Money.zero);
    // Adjusting t1's batch from t2's context finds nothing.
    final batchId = (await stock.batchesFor(t1, a)).single.id;
    final r = await stock.adjust(
      ctx2,
      productId: a,
      batchId: batchId,
      deltaMilli: -1000,
      note: 'x',
      can: owner,
    );
    expect(r, isA<StockNotFound>());
    expect(await products.delete(ctx2, a, can: owner), isA<ProductNotFound>());
  });

  test('summary: value, low, out, expiring, expired', () async {
    await make('A'); // reorder 5 units
    await make('B', name: 'DAP');
    await make('C', name: 'Seed');
    await make('D', name: 'Empty');
    final refs = await stock.productRefs(t1);
    await stock.importOpening(
      ctx,
      preview(
        'sku,batch,expiry,qty,cost\n'
        'A,L,,3,100\n' // low (3 <= 5)
        'B,E,2027-03-01,10,100\n' // expired
        'C,S,2027-05-15,10,100\n', // expiring in 15 days
        refs,
      ),
      asOn: today,
      can: owner,
      now: now,
    );
    final s = await stock.watchSummary(t1, today: today).first;
    expect(s.valueAtCost, const Money.rupees(2300));
    expect(s.lowCount, 1);
    expect(s.expiredCount, 1);
    expect(s.expiringCount, 1);
    expect(s.outCount, 1); // D
    final low = await stock
        .watchProducts(
          t1,
          filter: const ProductFilter(stock: StockFilter.low),
          today: today,
        )
        .first;
    expect(low.single.product.name, 'Urea');
    final found = await stock
        .watchProducts(t1, filter: const ProductFilter(query: 'dap'))
        .first;
    expect(found.single.product.sku, 'B');
  });

  test('a product with stock cannot be deleted; categories', () async {
    final a = await make('A');
    await stock.importOpening(
      ctx,
      preview('sku,qty,cost\nA,4,10\n', await stock.productRefs(t1)),
      asOn: today,
      can: owner,
      now: now,
    );
    expect(await products.delete(ctx, a, can: owner), isA<ProductHasStock>());
    expect(
      await products.delete(ctx, a, can: munshi),
      isA<ProductNotPermitted>(),
    );
    final c = await products.addCategory(ctx, 'Fertiliser', can: owner);
    expect(c, isNotNull);
    expect(await products.addCategory(ctx, 'fertiliser', can: owner), isNull);
    expect(await products.addCategory(ctx, 'Seeds', can: munshi), isNull);
    final other = await make('Z', name: 'Empty');
    expect(await products.delete(ctx, other, can: owner), isA<ProductSaved>());
    expect(await products.getProduct(t1, other), isNull);
  });

  test('addOpeningBatch: new batch once, then batch exists', () async {
    final a = await make('A');
    final r = await stock.addOpeningBatch(
      ctx,
      productId: a,
      batchNo: 'N1',
      qtyMilli: 3000,
      cost: const Money.rupees(50),
      can: owner,
      date: today,
      now: now,
    );
    expect(r, isA<OpeningStockImported>());
    final again = await stock.addOpeningBatch(
      ctx,
      productId: a,
      batchNo: 'N1',
      qtyMilli: 1000,
      cost: const Money.rupees(50),
      can: owner,
      date: today,
      now: now,
    );
    expect(again, isA<StockBatchExists>());
    await expectStockIsSumOfMovements(t1);
  });
}
