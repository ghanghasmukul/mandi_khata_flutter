import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/accounts/data/books_invariants.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/shop_sales/data/return_repository.dart';
import 'package:mandi_khata_app/features/shop_sales/data/sale_repository.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
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
const farmer = 'p-farmer';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

final now = DateTime.utc(2027, 4, 30, 6);
final today = LedgerDate(2027, 4, 30);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late SaleRepository repo;
  late ReturnRepository returns;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_sale_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = SaleRepository(db);
    returns = ReturnRepository(db);
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
    await db.execute(
      'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
      [farmer, t1, 'F-1', 'Gurmeet'],
    );
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> product(String id, {String tenant = t1, int rate = 5}) =>
      db.execute(
        'INSERT INTO products (id, tenant_id, sku, name, unit, gst_rate, '
        'hsn, reorder_level_milli, prices, is_active) '
        "VALUES (?, ?, ?, ?, 'bag', ?, '3105', 0, '{}', 1)",
        [id, tenant, 'S-$id', 'Prod $id', rate],
      );

  /// A batch with [qty] units in stock (one purchase movement).
  Future<void> batch(
    String id,
    String productId, {
    int qty = 10,
    int costRupees = 60,
    String? expiry,
    String created = '2027-01-01T00:00:00Z',
  }) async {
    await db.execute(
      'INSERT INTO batches (id, tenant_id, product_id, batch_no, '
      'expiry_date, cost_paise, qty_milli, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        t1,
        productId,
        'N-$id',
        expiry,
        costRupees * 100,
        qty * 1000,
        created,
      ],
    );
    await db.execute(
      'INSERT INTO stock_movements (id, tenant_id, product_id, batch_id, '
      'entry_date, qty_milli, reason, ref_type, ref_id) '
      "VALUES (?, ?, ?, ?, '2027-01-01', ?, 'purchase', 'purchase', ?)",
      ['m-$id', t1, productId, id, qty * 1000, 'pur-$id'],
    );
  }

  Future<void> setting(String key, Object v) => db.execute(
    'INSERT INTO settings (id, tenant_id, scope, scope_id, key, value) '
    "VALUES (uuid(), ?, 'tenant', NULL, ?, ?)",
    [t1, key, jsonEncode(v)],
  );

  Future<int> stockOf(String productId) async =>
      (await db.get(
            'SELECT COALESCE(SUM(qty_milli),0) AS n FROM stock_movements '
            'WHERE tenant_id = ? AND product_id = ?',
            [t1, productId],
          ))['n']!
          as int;

  /// Stock of one batch = Σ its movements (the local cache is not written).
  Future<int> cache(String batchId) async =>
      (await db.get(
            'SELECT COALESCE(SUM(qty_milli),0) AS n FROM stock_movements '
            'WHERE batch_id = ?',
            [batchId],
          ))['n']!
          as int;

  SaleDraft sale(
    List<SaleDraftLine> lines, {
    PaymentSplit? payment,
    String? party,
    String? upi,
    InvoiceDiscount discount = const InvoiceDiscount.none(),
  }) => SaleDraft(
    entryDate: today,
    partyId: party,
    tier: 'retail',
    lines: lines,
    discount: discount,
    payment: payment ?? const PaymentSplit(),
    upiAccountId: upi,
  );

  SaleDraftLine line(String p, int qty, {int rupees = 105}) => SaleDraftLine(
    productId: p,
    qtyMilli: qty * 1000,
    unitPrice: Money.rupees(rupees),
  );

  Future<SaleSaved> save(SaleDraft d, {bool Function(Permission)? can}) async {
    final r = await repo.create(ctx, d, can: can ?? owner, now: now);
    expect(r, isA<SaleSaved>(), reason: '$r');
    return r as SaleSaved;
  }

  group('create', () {
    test(
      '5 items on udhaar: khata, balanced journal, COGS at batch cost',
      () async {
        for (final p in ['a', 'b', 'c', 'd', 'e']) {
          await product(p);
          await batch('b-$p', p);
        }
        // 5 x ₹105 (5% inclusive) = ₹525.
        final saved = await save(
          sale(
            [
              for (final p in ['a', 'b', 'c', 'd', 'e']) line(p, 1),
            ],
            party: farmer,
            payment: const PaymentSplit(udhaar: Money.rupees(525)),
          ),
        );
        expect(saved.saleNo, 'SI-W1-0001');
        final khata = await db.getAll(
          'SELECT side, amount_paise, ref_type, ref_id FROM ledger_entries '
          'WHERE tenant_id = ?',
          [t1],
        );
        expect(khata, hasLength(1));
        expect(khata.single['side'], 'udhaar');
        expect(khata.single['amount_paise'], 52500);
        expect(khata.single['ref_type'], 'shop_sale');
        expect(khata.single['ref_id'], saved.id);

        expect(await BooksInvariants.unbalancedEntriesIn(db, t1), isEmpty);
        final lines = await db.getAll(
          'SELECT debit_paise, credit_paise FROM journal_lines l JOIN '
          'journal_entries e ON e.id = l.journal_entry_id '
          'WHERE e.source_key = ? ORDER BY l.line_no',
          ['shop_sale:${saved.id}'],
        );
        // Cost: 5 units x ₹60 = ₹300, both Dr COGS and Cr Stock.
        expect(lines.where((l) => l['debit_paise'] == 30000), hasLength(1));
        expect(lines.where((l) => l['credit_paise'] == 30000), hasLength(1));
        final sl = await db.getAll(
          'SELECT cost_paise, hsn FROM shop_sale_lines WHERE sale_id = ?',
          [saved.id],
        );
        expect(sl, hasLength(5));
        expect(
          sl.every((r) => r['cost_paise'] == 6000 && r['hsn'] == '3105'),
          isTrue,
        );
        expect(await stockOf('a'), 9000);
        expect(await cache('b-a'), 9000);
        expect(
          await db.getAll(
            "SELECT 1 FROM audit_log WHERE table_name = 'shop_sales'",
          ),
          hasLength(1),
        );
      },
    );

    test(
      'FEFO takes the earliest expiry first and splits across batches',
      () async {
        await product('a');
        await batch('late', 'a', qty: 5, expiry: '2028-06-30');
        await batch('soon', 'a', qty: 3, expiry: '2027-08-31');
        await batch('none', 'a', qty: 5);
        final saved = await save(
          sale([
            line('a', 4),
          ], payment: const PaymentSplit(cash: Money.rupees(420))),
        );
        final rows = await db.getAll(
          'SELECT batch_id, qty_milli FROM shop_sale_lines WHERE sale_id = ? '
          'ORDER BY line_no',
          [saved.id],
        );
        expect(
          [for (final r in rows) (r['batch_id'], r['qty_milli'])],
          [('soon', 3000), ('late', 1000)],
        );
        expect(await stockOf('a'), 9000);
      },
    );

    test('expired stock is refused by default and sold last with a warning '
        'when the setting allows', () async {
      await product('a');
      await batch('old', 'a', qty: 5, expiry: '2027-03-01');
      final d = sale([
        line('a', 1),
      ], payment: const PaymentSplit(cash: Money.rupees(105)));
      final refused = await repo.create(ctx, d, can: owner, now: now);
      expect(refused, isA<SaleStockRefused>());
      expect(
        (refused as SaleStockRefused).issues.single.error,
        StockErrorKind.expiredBlocked,
      );
      expect(await stockOf('a'), 5000);
      expect(
        await db.getAll('SELECT 1 FROM shop_sales WHERE tenant_id = ?', [t1]),
        isEmpty,
      );
      await setting('shop.block_expired', false);
      final ok = await save(d);
      expect(
        ok.warnings.map((w) => w.kind),
        contains(StockWarningKind.expiredSold),
      );
    });

    test('negative stock is blocked unless allowed', () async {
      await product('a');
      await batch('b', 'a', qty: 2);
      final d = sale([
        line('a', 3),
      ], payment: const PaymentSplit(cash: Money.rupees(315)));
      final refused = await repo.create(ctx, d, can: owner, now: now);
      expect(
        (refused as SaleStockRefused).issues.single.error,
        StockErrorKind.insufficientStock,
      );
      await setting('shop.allow_negative_stock', true);
      final saved = await save(d);
      final rows = await db.getAll(
        'SELECT batch_id, qty_milli, cost_paise FROM shop_sale_lines '
        'WHERE sale_id = ? ORDER BY line_no',
        [saved.id],
      );
      expect(rows.map((r) => r['batch_id']), ['b', null]);
      expect(rows.last['cost_paise'], 0);
      expect(await stockOf('a'), -1000);
    });

    test('split payment: cash + UPI + udhaar', () async {
      await product('a');
      await batch('b', 'a');
      final saved = await save(
        sale(
          [line('a', 4)],
          party: farmer,
          upi: sbi,
          payment: const PaymentSplit(
            cash: Money.rupees(100),
            upi: Money.rupees(120),
            udhaar: Money.rupees(200),
          ),
        ),
      );
      final book = await db.getAll(
        'SELECT account_id, direction, amount_paise FROM cash_bank_entries '
        'WHERE shop_sale_id = ? ORDER BY amount_paise',
        [saved.id],
      );
      expect(
        [for (final b in book) (b['account_id'], b['amount_paise'])],
        [(BankAccountsRepository.cashIdFor(t1), 10000), (sbi, 12000)],
      );
      expect(book.every((b) => b['direction'] == 'in'), isTrue);
      final k = await db.get(
        'SELECT amount_paise FROM ledger_entries WHERE tenant_id = ?',
        [t1],
      );
      expect(k['amount_paise'], 20000);
      expect(await BooksInvariants.unbalancedEntriesIn(db, t1), isEmpty);
      final h = await db.get(
        'SELECT total_paise, paid_cash_paise + paid_upi_paise + '
        'paid_credit_paise AS s FROM shop_sales WHERE id = ?',
        [saved.id],
      );
      expect(h['s'], h['total_paise']);
    });

    test(
      'payment must add up; udhaar needs a party; UPI needs an account',
      () async {
        await product('a');
        await batch('b', 'a');
        Future<SaleSaveResult> go(SaleDraft d) =>
            repo.create(ctx, d, can: owner, now: now);
        var r = await go(
          sale([
            line('a', 1),
          ], payment: const PaymentSplit(cash: Money.rupees(5))),
        );
        expect(
          (r as SaleInvalid).problems,
          contains(SaleProblem.paymentMismatch),
        );
        r = await go(
          sale([
            line('a', 1),
          ], payment: const PaymentSplit(udhaar: Money.rupees(105))),
        );
        expect(
          (r as SaleInvalid).problems,
          contains(SaleProblem.udhaarNeedsParty),
        );
        r = await go(
          sale([
            line('a', 1),
          ], payment: const PaymentSplit(upi: Money.rupees(105))),
        );
        expect(
          (r as SaleInvalid).problems,
          contains(SaleProblem.upiNeedsAccount),
        );
        expect(await stockOf('a'), 10000);
      },
    );

    test('permission denied for a member without sales.create', () async {
      await product('a');
      await batch('b', 'a');
      final r = await repo.create(
        ctx,
        sale([
          line('a', 1),
        ], payment: const PaymentSplit(cash: Money.rupees(105))),
        can: (_) => false,
        now: now,
      );
      expect(r, isA<SaleNotPermitted>());
      expect(await stockOf('a'), 10000);
    });

    test('tenant isolation: another business product and bills', () async {
      await product('x', tenant: t2);
      final r = await repo.create(
        ctx,
        sale([
          line('x', 1),
        ], payment: const PaymentSplit(cash: Money.rupees(105))),
        can: owner,
        now: now,
      );
      expect(r, isA<SaleInvalid>());
      await product('a');
      await batch('b', 'a');
      await save(
        sale([
          line('a', 1),
        ], payment: const PaymentSplit(cash: Money.rupees(105))),
      );
      expect(await repo.watchAll(t1, const SaleFilter()).first, hasLength(1));
      expect(await repo.watchAll(t2, const SaleFilter()).first, isEmpty);
      expect(ctxT2.tenantId, t2);
    });

    test('the reversal mirrors khata, book, journal and stock', () async {
      await product('a');
      await batch('b', 'a');
      final saved = await save(
        sale(
          [line('a', 2)],
          party: farmer,
          payment: const PaymentSplit(
            cash: Money.rupees(110),
            udhaar: Money.rupees(100),
          ),
        ),
      );
      final denied = await repo.reverse(ctx, saved.id, can: munshi, now: now);
      expect(denied, isA<SaleNotPermitted>());
      final r = await repo.reverse(ctx, saved.id, can: owner, now: now);
      expect(r, isA<SaleSaved>());
      expect(await stockOf('a'), 10000);
      expect(await cache('b'), 10000);
      expect(await BooksInvariants.unbalancedEntriesIn(db, t1), isEmpty);
      expect(await BooksInvariants.partyDifferencesIn(db, t1), isEmpty);
      final net = await db.get(
        "SELECT SUM(CASE side WHEN 'jama' THEN amount_paise "
        'ELSE -amount_paise END) AS n FROM ledger_entries WHERE tenant_id = ?',
        [t1],
      );
      expect(net['n'], 0);
      final again = await repo.reverse(ctx, saved.id, can: owner, now: now);
      expect(again, isA<SaleLocked>());
    });
  });

  group('sales return', () {
    test('restocks the ORIGINAL batch and credits the khata (jama)', () async {
      await product('a');
      await batch('soon', 'a', qty: 3, expiry: '2027-08-31');
      await batch('late', 'a', qty: 5, expiry: '2028-06-30');
      final saved = await save(
        sale(
          [line('a', 4)],
          party: farmer,
          payment: const PaymentSplit(udhaar: Money.rupees(420)),
        ),
      );
      var detail = (await repo.detail(t1, saved.id))!;
      final late = detail.lines.firstWhere((l) => l.batchId == 'late');
      final r = await returns.create(
        ctx,
        ReturnDraft(
          saleId: saved.id,
          items: [ReturnItem(late.id, 1000)],
          entryDate: today,
        ),
        can: owner,
        now: now,
      );
      expect(r, isA<ReturnSaved>(), reason: '$r');
      final ok = r as ReturnSaved;
      expect(ok.returnNo, 'SR-W1-0001');
      expect(ok.toKhata, ok.refund);
      expect(ok.refund, const Money.rupees(105));
      // Original batch got the unit back.
      expect(await cache('late'), 5000);
      expect(await cache('soon'), 0);
      // Stock = Σ movements, per product and per batch cache.
      expect(await stockOf('a'), 5000);
      final jama = await db.get(
        "SELECT amount_paise, ref_type FROM ledger_entries WHERE side = 'jama' "
        'AND tenant_id = ?',
        [t1],
      );
      expect(jama['amount_paise'], 10500);
      expect(jama['ref_type'], 'shop_return');
      expect(await BooksInvariants.unbalancedEntriesIn(db, t1), isEmpty);
      expect(await BooksInvariants.partyDifferencesIn(db, t1), isEmpty);

      detail = (await repo.detail(t1, saved.id))!;
      expect(
        detail.lines.firstWhere((l) => l.id == late.id).returnedMilli,
        1000,
      );
      // Cannot return more than is left on the line.
      final more = await returns.create(
        ctx,
        ReturnDraft(saleId: saved.id, items: [ReturnItem(late.id, 1000)]),
        can: owner,
        now: now,
      );
      expect(more, isA<ReturnInvalid>());
      // A reversal is refused once there is a return.
      expect(
        await repo.reverse(ctx, saved.id, can: owner, now: now),
        isA<SaleLocked>(),
      );
    });

    test('cash refund for a paid bill; khata choice needs a party; '
        'munshi is refused', () async {
      await product('a');
      await batch('b', 'a');
      final saved = await save(
        sale([
          line('a', 2),
        ], payment: const PaymentSplit(cash: Money.rupees(210))),
      );
      final d = (await repo.detail(t1, saved.id))!;
      final item = ReturnItem(d.lines.single.id, 2000);
      expect(
        await returns.create(
          ctx,
          ReturnDraft(saleId: saved.id, items: [item]),
          can: munshi,
          now: now,
        ),
        isA<ReturnNotPermitted>(),
      );
      final noParty = await returns.create(
        ctx,
        ReturnDraft(
          saleId: saved.id,
          items: [item],
          choice: RefundChoice.khata,
        ),
        can: owner,
        now: now,
      );
      expect((noParty as ReturnInvalid).problems, {ReturnProblem.noParty});
      final r = await returns.create(
        ctx,
        ReturnDraft(saleId: saved.id, items: [item]),
        can: owner,
        now: now,
      );
      expect((r as ReturnSaved).toCash, const Money.rupees(210));
      final out = await db.get(
        'SELECT direction, amount_paise FROM cash_bank_entries '
        'WHERE shop_return_id = ?',
        [r.id],
      );
      expect(out['direction'], 'out');
      expect(out['amount_paise'], 21000);
      expect(await stockOf('a'), 10000);
      expect(await BooksInvariants.unbalancedEntriesIn(db, t1), isEmpty);
    });

    test('a UPI refund needs finance.view; cash refund does not', () async {
      await product('a');
      await batch('b', 'a');
      final saved = await save(
        sale([
          line('a', 2),
        ], payment: const PaymentSplit(cash: Money.rupees(210))),
      );
      final d = (await repo.detail(t1, saved.id))!;
      final item = ReturnItem(d.lines.single.id, 1000);
      bool noFinance(Permission p) => p != Permission.financeView;
      final refused = await returns.create(
        ctx,
        ReturnDraft(
          saleId: saved.id,
          items: [item],
          viaUpi: true,
          bankAccountId: sbi,
        ),
        can: noFinance,
        now: now,
      );
      expect(
        (refused as ReturnNotPermitted).permission,
        Permission.financeView,
      );
      expect(
        await db.getAll('SELECT id FROM shop_returns WHERE tenant_id = ?', [
          t1,
        ]),
        isEmpty,
      );
      final cash = await returns.create(
        ctx,
        ReturnDraft(saleId: saved.id, items: [item]),
        can: noFinance,
        now: now,
      );
      expect(cash, isA<ReturnSaved>());
    });

    test('a negative round-off cannot make the refund negative', () async {
      await product('a');
      await batch('b', 'a');
      final saved = await save(
        sale([
          line('a', 1),
        ], payment: const PaymentSplit(cash: Money.rupees(105))),
      );
      // Corrupt the bill's round-off so the final return would go below zero.
      await db.execute(
        'UPDATE shop_sales SET round_off_paise = -100000 WHERE id = ?',
        [saved.id],
      );
      final d = (await repo.detail(t1, saved.id))!;
      final r = await returns.create(
        ctx,
        ReturnDraft(
          saleId: saved.id,
          items: [ReturnItem(d.lines.single.id, 1000)],
        ),
        can: owner,
        now: now,
      );
      final ok = r as ReturnSaved;
      expect(ok.refund.paise, greaterThanOrEqualTo(0));
      final h = await db.get(
        'SELECT total_paise, refund_khata_paise + refund_cash_paise + '
        'refund_upi_paise AS s FROM shop_returns WHERE id = ?',
        [ok.id],
      );
      expect(h['s'], h['total_paise']);
    });
  });
}
