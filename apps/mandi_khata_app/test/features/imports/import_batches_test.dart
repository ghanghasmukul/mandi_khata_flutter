import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/imports/data/import_batches_repository.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/opening_balances/data/opening_balances_repository.dart';
import 'package:mandi_khata_app/features/products/domain/product_import.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

final now = DateTime(2026, 10, 3, 11);
final asOn = LedgerDate(2026, 4, 1);

const csv =
    'Name,Village,Amount,Type\n'
    'Ramesh Kumar,Rampura,"15,000",Dr\n'
    'Sita Devi,Rampura,4000,Cr\n';

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late OpeningBalancesRepository opening;
  late ImportBatchesRepository batches;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_batches_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    opening = OpeningBalancesRepository(db);
    batches = ImportBatchesRepository(db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<OpeningImported> importBalances({String source = 'file'}) async {
    final p = OpeningBalanceImport.preview(
      DelimitedText.parse(csv),
      existing: await opening.existingParties(t1),
    );
    return await opening.import(
          ctx,
          p,
          asOn: asOn,
          can: owner,
          fileName: 'f.csv',
          source: source,
          now: now,
        )
        as OpeningImported;
  }

  Future<Map<String, int>> balances() async {
    final m = await LedgerRepository(db).watchBalances(t1).first;
    return {for (final e in m.entries) e.key: e.value.paise};
  }

  Future<int> count(String sql) async =>
      (await db.get('SELECT COUNT(*) AS n FROM $sql'))['n']! as int;

  test('an import shows up as a batch, with its source and size', () async {
    final done = await importBalances(source: 'tally');
    final list = await batches.watchBatches(t1).first;
    expect(list, hasLength(1));
    expect(list.single.id, done.batchId);
    expect(list.single.kind, ImportKind.openingBalances);
    expect(list.single.rows, 2);
    expect(list.single.source, 'tally');
    expect(list.single.fileName, 'f.csv');
    expect(list.single.rolledBack, isFalse);
  });

  test(
    'rollback reverses every entry, retires new parties, keeps history',
    () async {
      final done = await importBalances();
      expect((await balances()).values.where((v) => v != 0), hasLength(2));

      final result = await batches.rollback(
        ctx,
        done.batchId,
        isOwner: true,
        now: now,
      );
      final r = result as RolledBack;
      expect(r.entries, 2);
      expect(r.parties, 2);
      expect(r.kept, 0);

      // Append-only: nothing deleted, each entry has a reversal, net zero.
      expect(await count('ledger_entries'), 4);
      expect(await count('ledger_entries WHERE reverses_id IS NOT NULL'), 2);
      expect((await balances()).values.every((v) => v == 0), isTrue);
      expect(await count('parties WHERE deleted_at IS NULL'), 0);
      expect(await count('parties'), 2, reason: 'soft delete, not delete');

      final list = await batches.watchBatches(t1).first;
      expect(list.single.rolledBack, isTrue);
      expect(await count("audit_log WHERE table_name = 'import_rollbacks'"), 1);
    },
  );

  test('rollback is owner only and happens once', () async {
    final done = await importBalances();
    final refused = await batches.rollback(
      ctx,
      done.batchId,
      isOwner: false,
      now: now,
    );
    expect((refused as RollbackRefused).reason, RollbackRefusal.notOwner);
    expect(await count('ledger_entries'), 2);

    await batches.rollback(ctx, done.batchId, isOwner: true, now: now);
    final again = await batches.rollback(
      ctx,
      done.batchId,
      isOwner: true,
      now: now,
    );
    expect(
      (again as RollbackRefused).reason,
      RollbackRefusal.alreadyRolledBack,
    );
    expect(await count('ledger_entries'), 4, reason: 'no second reversal');

    final unknown = await batches.rollback(ctx, 'nope', isOwner: true);
    expect((unknown as RollbackRefused).reason, RollbackRefusal.notFound);
  });

  test('a party that has other entries now is kept', () async {
    final done = await importBalances();
    final party =
        (await db.getAll('SELECT id FROM parties')).first['id']! as String;
    await LedgerRepository(db).append(
      ctx,
      LedgerDraft(
        partyId: party,
        side: Side.udhaar,
        amount: const Money.rupees(100),
        refType: RefType.journal,
        entryDate: LedgerDate(2026, 9, 1),
      ),
      can: owner,
      now: now,
    );
    final r =
        await batches.rollback(ctx, done.batchId, isOwner: true, now: now)
            as RolledBack;
    expect(r.parties, 1);
    expect(r.kept, 1);
    expect(await count('parties WHERE deleted_at IS NULL'), 1);
  });

  test(
    'a closed financial year blocks the rollback, nothing changes',
    () async {
      final done = await importBalances();
      await db.execute(
        'INSERT INTO financial_years (id, tenant_id, start_date, end_date, '
        "status, profit_paise) VALUES ('fy', ?, '2026-04-01', '2027-03-31', "
        "'closed', 0)",
        [t1],
      );
      final r = await batches.rollback(
        ctx,
        done.batchId,
        isOwner: true,
        now: now,
      );
      expect((r as RollbackRefused).reason, RollbackRefusal.lockedYear);
      expect(await count('ledger_entries'), 2);
      expect(await count('parties WHERE deleted_at IS NULL'), 2);
    },
  );

  group('products', () {
    ProductImportPreview preview(List<List<String>> rows) =>
        ProductImport.preview(
          Sheet([for (final (i, r) in rows.indexed) SheetRow(i + 1, r)]),
          existing: const [],
          categoriesByName: const {},
        );

    final file = [
      ['name', 'sku', 'unit', 'gst', 'price'],
      ['Urea 45kg', 'UREA45', 'bag', '5', '1266.50'],
      ['DAP 50kg', 'DAP50', 'bag', '5', '1350'],
    ];

    test('imports all valid rows once; the same file is refused', () async {
      final r = await batches.importProducts(
        ctx,
        preview(file),
        can: owner,
        fileName: 'p.csv',
        now: now,
      );
      expect((r as ProductsImported).count, 2);
      expect(await count('products'), 2);
      expect(await count("audit_log WHERE table_name = 'product_imports'"), 1);
      final again = await batches.importProducts(
        ctx,
        preview(file),
        can: owner,
        now: now,
      );
      expect(again, isA<ProductsAlreadyImported>());
      expect(await count('products'), 2);
    });

    test('needs products.manage', () async {
      final r = await batches.importProducts(
        ctx,
        preview(file),
        can: munshi,
        now: now,
      );
      expect(r, isA<ProductsNotPermitted>());
      expect(await count('products'), 0);
    });

    test(
      'a SKU added elsewhere since the preview stops the whole import',
      () async {
        final p = preview(file);
        await db.execute(
          'INSERT INTO products (id, tenant_id, sku, name, unit, gst_rate, '
          "reorder_level_milli, prices, is_active) VALUES ('x', ?, 'dap50', "
          "'DAP', 'bag', 0, 0, '{}', 1)",
          [t1],
        );
        final r = await batches.importProducts(ctx, p, can: owner, now: now);
        expect(r, isA<ProductsStale>());
        expect(
          await count('products'),
          1,
          reason: 'UREA45 was rolled back too',
        );
      },
    );

    test('rollback retires products without stock, keeps those with', () async {
      final r = await batches.importProducts(
        ctx,
        preview(file),
        can: owner,
        now: now,
      );
      final batch = (r as ProductsImported).batchId;
      final urea = ImportBatchesRepository.productId(t1, 'UREA45');
      await db.execute(
        'INSERT INTO stock_movements (id, tenant_id, product_id, qty_milli) '
        "VALUES ('m1', ?, ?, 5000)",
        [t1, urea],
      );
      final out =
          await batches.rollback(ctx, batch, isOwner: true, now: now)
              as RolledBack;
      expect(out.products, 1);
      expect(out.kept, 1);
      expect(await count('products WHERE deleted_at IS NULL'), 1);
    });
  });
}
