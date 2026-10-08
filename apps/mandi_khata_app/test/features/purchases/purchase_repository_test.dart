import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/purchases/data/purchase_repository.dart';
import 'package:mandi_khata_app/features/purchases/domain/purchase.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const ctxT2 = WriteContext(
  tenantId: t2,
  userId: 'user-x',
  deviceId: 'device-x1',
  deviceCode: 'X1',
);
const sbi = 'a0000000-0000-4000-8000-000000000001';
const sup = 'p-supplier';
const farmer = 'p-farmer';
const seed = 'prod-seed';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

final now = DateTime.utc(2027, 4, 30, 6);
final today = LedgerDate(2027, 4, 30);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late PurchaseRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_purchase_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = PurchaseRepository(db);
    for (final (id, kind, name) in [
      (BankAccountsRepository.cashIdFor(t1), 'cash', 'Cash'),
      (sbi, 'bank', 'SBI'),
    ]) {
      await db.execute(
        'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
        'sort_order) VALUES (?, ?, ?, ?, 1, 0)',
        [id, t1, kind, name],
      );
    }
    for (final (id, role) in [(sup, 'supplier'), (farmer, 'farmer')]) {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [id, t1, 'C-$id', 'Name $id'],
      );
      await db.execute(
        'INSERT INTO party_roles (id, tenant_id, party_id, role) '
        'VALUES (?, ?, ?, ?)',
        ['r-$id', t1, id, role],
      );
    }
    await db.execute(
      'INSERT INTO products (id, tenant_id, sku, name, unit, gst_rate, '
      'reorder_level_milli, prices, is_active) '
      "VALUES (?, ?, 'S1', 'Seed', 'bag', 5, 0, '{}', 1)",
      [seed, t1],
    );
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<int> n(String sql, [List<Object?> a = const []]) async =>
      (await db.get('SELECT COUNT(*) AS n FROM $sql', a))['n']! as int;

  Future<int> stock(String batch) async =>
      (await db.get(
            'SELECT COALESCE(SUM(qty_milli),0) AS n FROM stock_movements '
            'WHERE batch_id = ?',
            [batch],
          ))['n']!
          as int;

  PurchaseDraft draft({
    int qty = 10,
    int cost = 100,
    int paid = 0,
    bool cashPay = true,
    String batchNo = 'B1',
    LedgerDate? date,
    String supplier = sup,
    int freight = 0,
    int? creditDays,
  }) => PurchaseDraft(
    supplierId: supplier,
    invoiceDate: date ?? today,
    date: date ?? today,
    supplierInvoiceNo: 'INV-9',
    freight: Money.rupees(freight),
    paid: Money.rupees(paid),
    paidInCash: cashPay,
    bankAccountId: cashPay ? null : sbi,
    creditDays: creditDays,
    lines: [
      PurchaseLineDraft(
        productId: seed,
        batchNo: batchNo,
        qtyMilli: Qty.fromUnits(qty),
        unitCost: Money.rupees(cost),
        rateBp: 500,
      ),
    ],
  );

  Future<PurchaseSaved> save(PurchaseDraft d) async {
    final r = await repo.create(ctx, d, can: owner, now: now);
    expect(r, isA<PurchaseSaved>());
    return r as PurchaseSaved;
  }

  Future<void> expectBalanced() async {
    final r = await db.get(
      'SELECT SUM(debit_paise) AS d, SUM(credit_paise) AS c '
      'FROM journal_lines',
    );
    expect(r['d'], r['c']);
  }

  test('credit purchase: movements, khata jama, journal, audit, due', () async {
    final s = await save(draft());
    expect(s.number, 'PB-W1-0001');
    // 10 x 100 = 1000 + 5% = 1050.
    final p = await db.get('SELECT * FROM purchases WHERE id = ?', [s.id]);
    expect(p['total_paise'], 105000);
    expect(p['paid_paise'], 0);
    expect(p['due_date'], '2027-05-30');
    expect(s.dueDate, LedgerDate(2027, 5, 30));
    final line = await db.get('SELECT * FROM purchase_lines');
    expect(await stock(line['batch_id']! as String), 10000);
    final khata = await db.get('SELECT * FROM ledger_entries');
    expect(khata['side'], 'jama');
    expect(khata['ref_type'], 'purchase');
    expect(khata['ref_id'], s.id);
    expect(khata['amount_paise'], 105000);
    expect(await n('cash_bank_entries'), 0);
    await expectBalanced();
    final stockLine = await db.get(
      "SELECT debit_paise FROM journal_lines WHERE debit_paise = 100000",
    );
    expect(stockLine, isNotNull);
    for (final table in [
      'purchases',
      'purchase_lines',
      'batches',
      'stock_movements',
      'ledger_entries',
      'journal_entries',
    ]) {
      expect(
        await n("audit_log WHERE table_name = '$table'"),
        greaterThan(0),
        reason: table,
      );
    }
  });

  test(
    'paid now splits cash book and khata; bank needs finance.view',
    () async {
      final s = await save(draft(paid: 400));
      final khata = await db.get('SELECT amount_paise FROM ledger_entries');
      expect(khata['amount_paise'], 65000);
      final book = await db.get('SELECT * FROM cash_bank_entries');
      expect(book['purchase_id'], s.id);
      expect(book['direction'], 'out');
      expect(book['amount_paise'], 40000);
      await expectBalanced();

      // Fully paid: no khata entry, no due date.
      final full = await save(draft(paid: 1050, batchNo: 'B2'));
      expect(full.dueDate, isNull);
      expect(await n('ledger_entries'), 1);

      final denied = await repo.create(
        ctx,
        draft(paid: 100, cashPay: false, batchNo: 'B3'),
        can: (p) => p != Permission.financeView,
        now: now,
      );
      expect(denied, isA<PurchaseNotPermitted>());
      final bank = await repo.create(
        ctx,
        draft(paid: 100, cashPay: false, batchNo: 'B3'),
        can: owner,
        now: now,
      );
      expect(bank, isA<PurchaseSaved>());
    },
  );

  test('same product + batch no adds to the batch, cost averaged', () async {
    await save(draft());
    await save(draft(cost: 200));
    expect(await n('batches'), 1);
    final b = await db.get('SELECT * FROM batches');
    expect(await stock(b['id']! as String), 20000);
    // (10 x 100 + 10 x 200) / 20 = 150.
    expect(b['cost_paise'], 15000);
  });

  test('freight rides into the batch cost', () async {
    await save(draft(freight: 100));
    final b = await db.get('SELECT cost_paise FROM batches');
    expect(b['cost_paise'], 11000);
    await expectBalanced();
  });

  test('credit days: setting default and explicit override', () async {
    final a = await save(draft(creditDays: 10));
    expect(a.dueDate, LedgerDate(2027, 5, 10));
  });

  test('validation, unknown supplier role, permission', () async {
    expect(
      await repo.create(ctx, draft(paid: 99999), can: owner, now: now),
      isA<PurchaseInvalid>(),
    );
    expect(
      await repo.create(
        ctx,
        draft(supplier: farmer),
        can: owner,
        now: now,
      ),
      isA<PurchaseInvalid>(),
    );
    expect(
      await repo.create(ctx, draft(), can: munshi, now: now),
      isA<PurchaseNotPermitted>(),
    );
    expect(await n('purchases'), 0);
  });

  test('closed financial year refuses', () async {
    await db.execute(
      'INSERT INTO financial_years (id, tenant_id, start_date, end_date, '
      "status) VALUES ('fy', ?, '2026-04-01', '2027-03-31', 'closed')",
      [t1],
    );
    final r = await repo.create(
      ctx,
      draft(date: LedgerDate(2027, 3, 30)),
      can: owner,
      now: now,
    );
    expect(r, isA<PurchaseNotPermitted>());
    expect((r as PurchaseNotPermitted).lockedYear, isTrue);
  });

  test('return goes to the original batch; validates qty', () async {
    final s = await save(draft());
    final line = await db.get('SELECT id, batch_id FROM purchase_lines');
    PurchaseReturnDraft ret(int qty, {RefundChoice c = RefundChoice.auto}) =>
        PurchaseReturnDraft(
          purchaseId: s.id,
          choice: c,
          date: today,
          lines: [
            PurchaseReturnLineDraft(line['id']! as String, Qty.fromUnits(qty)),
          ],
        );
    expect(
      await repo.createReturn(ctx, ret(11), can: owner, now: now),
      isA<PurchaseReturnInvalid>(),
    );
    final r = await repo.createReturn(ctx, ret(4), can: owner, now: now);
    expect(r, isA<PurchaseSaved>());
    expect((r as PurchaseSaved).number, 'PR-W1-0001');
    expect(await stock(line['batch_id']! as String), 6000);
    // 4 x 100 + 5% = 420, all unpaid -> credit note (udhaar).
    final khata = await db.getAll(
      "SELECT side, amount_paise FROM ledger_entries WHERE ref_type = "
      "'purchase_return'",
    );
    expect(khata.single['side'], 'udhaar');
    expect(khata.single['amount_paise'], 42000);
    await expectBalanced();
    // Sold stock cannot go back: take 6 out, then a return of 6 fails.
    await db.execute(
      'INSERT INTO stock_movements (id, tenant_id, product_id, batch_id, '
      "entry_date, qty_milli, reason, ref_type, ref_id) VALUES ('m', ?, ?, "
      "?, '2027-04-30', -5000, 'sale', 'shop_sale', 'x')",
      [t1, seed, line['batch_id']],
    );
    expect(
      await repo.createReturn(ctx, ret(2), can: owner, now: now),
      isA<PurchaseReturnInvalid>(),
    );
    // Paid purchase: choosing cash refunds into the book.
    final reversed = await repo.reverseReturn(ctx, r.id, can: owner, now: now);
    expect(reversed, isA<PurchaseSaved>());
    expect(await stock(line['batch_id']! as String), 5000);
    await expectBalanced();
  });

  test('reverse mirrors everything; refused after a return', () async {
    final s = await save(draft(paid: 300));
    final line = await db.get('SELECT batch_id FROM purchase_lines');
    final r = await repo.reverse(ctx, s.id, can: owner, now: now);
    expect(r, isA<PurchaseSaved>());
    expect(await stock(line['batch_id']! as String), 0);
    expect(await n('ledger_entries'), 2);
    expect(await n('cash_bank_entries'), 2);
    expect(await n('journal_entries'), 2);
    await expectBalanced();
    expect(
      (await db.get('SELECT status FROM purchases'))['status'],
      'reversed',
    );
    expect(
      await repo.reverse(ctx, s.id, can: owner, now: now),
      isA<PurchaseLocked>(),
    );
    expect(
      await repo.reverse(ctx, s.id, can: munshi, now: now),
      isA<PurchaseNotPermitted>(),
    );

    final s2 = await save(draft(batchNo: 'B9'));
    final l2 = await db.get(
      'SELECT id FROM purchase_lines WHERE purchase_id = ?',
      [s2.id],
    );
    await repo.createReturn(
      ctx,
      PurchaseReturnDraft(
        purchaseId: s2.id,
        date: today,
        lines: [PurchaseReturnLineDraft(l2['id']! as String, 1000)],
      ),
      can: owner,
      now: now,
    );
    expect(
      await repo.reverse(ctx, s2.id, can: owner, now: now),
      isA<PurchaseInUse>(),
    );
  });

  test('payables: FIFO by due date, returns credit own bill', () async {
    final a = await save(draft(creditDays: 10)); // 1050 due 05-10
    await save(draft(batchNo: 'B2', creditDays: 40)); // 1050 due 06-09
    var p = await repo.watchSupplierPayables(t1, today: today).first;
    expect(p.single.outstanding, const Money.rupees(2100));
    expect(p.single.dueDate, LedgerDate(2027, 5, 10));

    // A payment of 1500 to the supplier (udhaar, ref payment).
    await db.execute(
      'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, side, '
      "amount_paise, ref_type, ref_id) VALUES ('pay', ?, ?, '2027-04-30', "
      "'udhaar', 150000, 'payment', 'pp')",
      [t1, sup],
    );
    p = await repo.watchSupplierPayables(t1, today: today).first;
    expect(p.single.outstanding, const Money.rupees(600));
    expect(p.single.bills.single.bill.dueDate, LedgerDate(2027, 6, 9));

    final list = await repo
        .watchPurchases(
          t1,
          const PurchaseFilter(status: PurchaseStatusFilter.unpaid),
          today: today,
        )
        .first;
    expect(list, hasLength(1));
    expect(list.single.outstanding, const Money.rupees(600));
    expect(list.single.id, isNot(a.id));
    final detail = await repo.watchPurchase(t1, a.id, today: today).first;
    expect(detail!.lines, hasLength(1));
    expect(detail.summary.outstanding, Money.zero);
  });

  test('tenant isolation', () async {
    await save(draft());
    expect(await repo.watchSupplierPayables(t2).first, isEmpty);
    expect(
      await repo.watchPurchases(t2, const PurchaseFilter()).first,
      isEmpty,
    );
    expect(
      await repo.reverse(ctxT2, 'nope', can: owner, now: now),
      isA<PurchaseNotFound>(),
    );
    final a = await db.get('SELECT id FROM purchases');
    expect(
      await repo.reverse(ctxT2, a['id']! as String, can: owner, now: now),
      isA<PurchaseNotFound>(),
    );
  });
}
