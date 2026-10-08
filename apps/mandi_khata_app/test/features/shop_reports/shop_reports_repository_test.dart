import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/shop_reports/data/shop_reports_repository.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/dues_models.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/gst_models.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const farmer = 'f0000000-0000-4000-8000-000000000001';
const cust = 'f0000000-0000-4000-8000-000000000002';
const supp = 'f0000000-0000-4000-8000-000000000003';
const urea = 'a0000000-0000-4000-8000-000000000001';
const dap = 'a0000000-0000-4000-8000-000000000002';
const cat = 'c0000000-0000-4000-8000-000000000001';

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late ShopReportsRepository repo;
  var n = 0;
  String id() => 'e0000000-0000-4000-8000-${(n++).toString().padLeft(12, '0')}';

  Future<void> party(String pid, String name, {String tenant = t1}) =>
      db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [pid, tenant, 'C-$pid'.substring(0, 6), name],
      );

  Future<String> entry(
    String party,
    String side,
    int amt,
    String refType, {
    String? refId,
    String date = '2026-10-01',
    String tenant = t1,
    String? reverses,
  }) async {
    final eid = id();
    await db.execute(
      'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, side, '
      'amount_paise, ref_type, ref_id, reverses_id, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        eid,
        tenant,
        party,
        date,
        side,
        amt,
        refType,
        refId,
        reverses,
        '${date}T00:00:00Z',
      ],
    );
    return eid;
  }

  Future<String> purchase(
    String no,
    String date,
    int due,
    int khata, {
    String tenant = t1,
    String status = 'posted',
    String party = supp,
  }) async {
    final pid = id();
    await db.execute(
      'INSERT INTO purchases (id, tenant_id, purchase_no, party_id, '
      'invoice_date, entry_date, total_paise, paid_paise, credit_days, '
      'due_date, status) VALUES (?, ?, ?, ?, ?, ?, ?, 0, 30, ?, ?)',
      [
        pid,
        tenant,
        no,
        party,
        date,
        date,
        khata,
        due == 0 ? null : date,
        status,
      ],
    );
    return pid;
  }

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_shop_reports');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = ShopReportsRepository(db);
    await party(farmer, 'Gurmeet');
    await party(cust, 'Baldev');
    await party(supp, 'Agro Supplies');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test(
    'no double counting: farmer with lot proceeds and urea on credit',
    () async {
      // Lot proceeds: we owe him 10,000. Urea on credit: he owes 4,000.
      await entry(farmer, 'jama', 1000000, 'arrival');
      final sale = id();
      await db.execute(
        'INSERT INTO shop_sales (id, tenant_id, sale_no, party_id, entry_date, '
        "total_paise, status) VALUES (?, ?, 'SI-1', ?, '2026-10-02', 400000, "
        "'posted')",
        [sale, t1, farmer],
      );
      await entry(farmer, 'udhaar', 400000, 'shop_sale', refId: sale);
      // Other tenant's noise on the same party id must never leak in.
      await party(
        farmer + '9'.substring(0, 0),
        'x',
        tenant: t2,
      ).catchError((_) {});

      final b = await repo.khataBreakdown(t1, farmer);
      // One net balance: udhaar - jama = -6,000 (we owe him).
      expect(b.balance, const Money(-600000));
      expect(b.parts, {
        'arrival': const Money(-1000000),
        'shop_sale': const Money(400000),
      });
      expect(b.partsTotal, b.balance);

      final recv = await repo.customerReceivables(t1);
      final row = recv.single;
      expect(row.shopNet, const Money(400000));
      expect(row.khataBalance, const Money(-600000));
      // He owes us nothing net, so nothing is collectible and nothing is
      // added on top of the balance.
      expect(row.receivable, Money.zero);
      final screenTotal = recv.fold<Money>(
        Money.zero,
        (a, r) => a + r.receivable,
      );
      expect(
        screenTotal <= (b.balance.isPositive ? b.balance : Money.zero),
        isTrue,
      );
      expect(
        await repo.supplierPayables(t1, today: LedgerDate(2026, 10, 5)),
        isEmpty,
      );
    },
  );

  test('receivable is capped by the khata after a payment', () async {
    final sale = id();
    await db.execute(
      'INSERT INTO shop_sales (id, tenant_id, sale_no, party_id, entry_date, '
      "total_paise, status) VALUES (?, ?, 'SI-2', ?, '2026-10-02', 1000000, "
      "'posted')",
      [sale, t1, cust],
    );
    await entry(cust, 'udhaar', 1000000, 'shop_sale', refId: sale);
    await entry(cust, 'jama', 300000, 'payment');
    await entry(cust, 'jama', 100000, 'shop_return');
    final r = (await repo.customerReceivables(t1)).single;
    expect(r.shopNet, const Money(900000));
    expect(r.khataBalance, const Money(600000));
    expect(r.receivable, const Money(600000));
    final b = await repo.khataBreakdown(t1, cust);
    expect(b.partsTotal, b.balance);
  });

  test('reversed shop sale drops out of receivables', () async {
    final e = await entry(cust, 'udhaar', 500000, 'shop_sale');
    await entry(cust, 'jama', 500000, 'reversal', reverses: e);
    expect(await repo.customerReceivables(t1), isEmpty);
    final b = await repo.khataBreakdown(t1, cust);
    expect(b.balance, Money.zero);
    expect(b.partsTotal, Money.zero);
  });

  test('supplier payments are allocated oldest due date first', () async {
    final p1 = await purchase('PB-1', '2026-08-01', 1, 1000000);
    final p2 = await purchase('PB-2', '2026-09-01', 1, 500000);
    await entry(supp, 'jama', 1000000, 'purchase', refId: p1);
    await entry(supp, 'jama', 500000, 'purchase', refId: p2);
    await entry(supp, 'udhaar', 1200000, 'payment');
    final today = LedgerDate(2026, 10, 10);
    final s = (await repo.supplierPayables(t1, today: today)).single;
    expect(s.outstanding, const Money(300000));
    expect(s.openBills.single.bill.purchaseNo, 'PB-2');
    expect(s.openBills.single.outstanding, const Money(300000));
    // PB-2 invoice 2026-09-01, due the same day per the stored due date.
    expect(s.oldestDue, LedgerDate(2026, 9, 1));
    expect(s.daysOverdue, 39);
    expect(s.khataBalance, const Money(-300000));
  });

  test('paid bills and other tenants are not payables', () async {
    final p1 = await purchase('PB-1', '2026-08-01', 1, 100000);
    await entry(supp, 'jama', 100000, 'purchase', refId: p1);
    await entry(supp, 'udhaar', 100000, 'payment');
    await party('f0000000-0000-4000-8000-0000000000aa', 'Other', tenant: t2);
    final p2 = await purchase(
      'PB-9',
      '2026-08-01',
      1,
      700000,
      tenant: t2,
      party: 'f0000000-0000-4000-8000-0000000000aa',
    );
    await entry(
      'f0000000-0000-4000-8000-0000000000aa',
      'jama',
      700000,
      'purchase',
      refId: p2,
      tenant: t2,
    );
    final today = LedgerDate(2026, 10, 10);
    expect(await repo.supplierPayables(t1, today: today), isEmpty);
    expect(await repo.supplierPayables(t2, today: today), hasLength(1));
  });

  group('profit and GST', () {
    Future<void> seedShop() async {
      await db.execute(
        "INSERT INTO product_categories (id, tenant_id, name, sort_order, "
        "is_active) VALUES (?, ?, 'Fertiliser', 0, 1)",
        [cat, t1],
      );
      for (final (pid, name, hsn, rate) in [
        (urea, 'Urea', '3102', 5.0),
        (dap, 'DAP', null, 5.0),
      ]) {
        await db.execute(
          'INSERT INTO products (id, tenant_id, sku, name, category_id, '
          'unit, hsn, gst_rate, reorder_level_milli, prices, is_active) '
          "VALUES (?, ?, ?, ?, ?, 'bag', ?, ?, 10000, '{}', 1)",
          [pid, t1, name, name, cat, hsn, rate],
        );
      }
      Future<String> sale(
        String no,
        String date,
        String? gstin,
        String? pos,
        List<(String, int, int, int, int)> lines,
      ) async {
        final sid = id();
        await db.execute(
          'INSERT INTO shop_sales (id, tenant_id, sale_no, entry_date, '
          'customer_name, customer_gstin, place_of_supply, round_off_paise, '
          "total_paise, status) VALUES (?, ?, ?, ?, 'Cust', ?, ?, 0, 0, "
          "'posted')",
          [sid, t1, no, date, gstin, pos],
        );
        var i = 0;
        for (final (prod, qty, taxable, cost, tax) in lines) {
          await db.execute(
            'INSERT INTO shop_sale_lines (id, tenant_id, sale_id, line_no, '
            'product_id, qty_milli, taxable_paise, gst_rate, cgst_paise, '
            'sgst_paise, igst_paise, hsn, cost_paise) VALUES '
            "(?, ?, ?, ?, ?, ?, ?, 5, ?, ?, ?, '3102', ?)",
            [
              id(),
              t1,
              sid,
              i++,
              prod,
              qty,
              taxable,
              pos == '07' ? 0 : tax ~/ 2,
              pos == '07' ? 0 : tax - tax ~/ 2,
              pos == '07' ? tax : 0,
              cost,
            ],
          );
        }
        return sid;
      }

      // 2 bags urea: revenue 1000.00, unit cost 400.00 -> COGS 800.00.
      final s1 = await sale('SI-1', '2026-10-03', null, '03', [
        (urea, 2000, 100000, 40000, 5000),
      ]);
      // 1.5 bags DAP: revenue 600.00, unit cost 300.00 -> COGS 450.00.
      await sale('SI-2', '2026-10-04', '07AAACG2115R1ZN', '07', [
        (dap, 1500, 60000, 30000, 3000),
      ]);
      // Outside the period.
      await sale('SI-3', '2026-11-04', null, '03', [
        (urea, 1000, 50000, 40000, 2500),
      ]);
      // Return of 1 bag urea: taxable 500, cost 400.
      final sl =
          (await db.getAll('SELECT id FROM shop_sale_lines WHERE sale_id = ?', [
                s1,
              ])).single['id']!
              as String;
      final rid = id();
      await db.execute(
        'INSERT INTO shop_returns (id, tenant_id, sale_id, return_no, '
        "entry_date, round_off_paise, status) VALUES (?, ?, ?, 'SR-1', "
        "'2026-10-05', 0, 'posted')",
        [rid, t1, s1],
      );
      await db.execute(
        'INSERT INTO shop_return_lines (id, tenant_id, shop_return_id, '
        'line_no, sale_line_id, product_id, qty_milli, taxable_paise, '
        'cgst_paise, sgst_paise, igst_paise) VALUES '
        '(?, ?, ?, 0, ?, ?, 1000, 50000, 1250, 1250, 0)',
        [id(), t1, rid, sl, urea],
      );
    }

    test(
      'profit by product, category and month matches hand calculation',
      () async {
        await seedShop();
        final rec = await repo.profitRecords(
          t1,
          from: LedgerDate(2026, 10, 1),
          to: LedgerDate(2026, 10, 31),
        );
        final byProduct = {
          for (final r in ShopProfit.byProduct(rec)) r.label: r,
        };
        // Urea: sold 2 bags, returned 1 -> qty 1, revenue 500, COGS 400.
        expect(byProduct['Urea']!.qtyMilli, 1000);
        expect(byProduct['Urea']!.revenue, const Money(50000));
        expect(byProduct['Urea']!.cogs, const Money(40000));
        expect(byProduct['Urea']!.profit, const Money(10000));
        expect(byProduct['Urea']!.marginText, '20%');
        expect(byProduct['DAP']!.cogs, const Money(45000));
        expect(byProduct['DAP']!.profit, const Money(15000));
        final cats = ShopProfit.byCategory(rec);
        expect(cats.single.label, 'Fertiliser');
        expect(cats.single.revenue, const Money(110000));
        expect(cats.single.profit, const Money(25000));
        expect(ShopProfit.byMonth(rec).single.key, '2026-10');
        // Tenant isolation.
        expect(
          await repo.profitRecords(
            t2,
            from: LedgerDate(2026, 10, 1),
            to: LedgerDate(2026, 10, 31),
          ),
          isEmpty,
        );
      },
    );

    test('GSTR-1 rows come out of the core builder', () async {
      await seedShop();
      final inv = await repo.gstInvoices(
        t1,
        year: 2026,
        month: 10,
        tenantStateCode: '03',
      );
      expect(
        inv.map((i) => i.number),
        unorderedEquals(['SI-1', 'SI-2', 'SR-1']),
      );
      final report = Gstr1Report.build(
        invoices: inv,
        tenantGstin: '03AAACG2115R1ZN',
        tenantStateCode: '03',
        year: 2026,
        month: 10,
      );
      expect(report.b2b.map((i) => i.number), ['SI-2']);
      expect(report.b2b.single.lines.single.split.igst, const Money(3000));
      // SI-1 is B2CS intra-state 5%, SR-1 nets in as a negative row.
      final b2cs = report.b2cs.single;
      expect(b2cs.rateBp, 500);
      expect(b2cs.split.taxable, const Money(50000));
      expect(b2cs.split.cgst, const Money(1250));
      expect(report.cdnr, isEmpty);
      final s = GstSummary.of(inv);
      expect(s.b2b.count, 1);
      expect(s.creditNotes.count, 1);
      expect(s.net.taxable, const Money(110000));
      expect(report.toJson()['b2b'], isNotEmpty);
      // DAP has no HSN.
      final flags = await repo.gstProductFlags(t1);
      expect(flags.single.name, 'DAP');
      expect(flags.single.issues, [GstIssue.missingHsn]);
      expect(
        await repo.gstInvoices(
          t2,
          year: 2026,
          month: 10,
          tenantStateCode: '03',
        ),
        isEmpty,
      );
    });
  });

  test('expiry and reorder use stock movements', () async {
    await db.execute(
      'INSERT INTO products (id, tenant_id, sku, name, unit, gst_rate, '
      "reorder_level_milli, prices, is_active) VALUES (?, ?, 'U', 'Urea', "
      "'bag', 5, 10000, '{}', 1)",
      [urea, t1],
    );
    const b1 = 'b0000000-0000-4000-8000-000000000001';
    await db.execute(
      'INSERT INTO batches (id, tenant_id, product_id, batch_no, '
      'expiry_date, cost_paise, qty_milli, created_at) VALUES '
      "(?, ?, ?, 'B1', '2026-10-20', 40000, 0, '2026-01-01T00:00:00Z')",
      [b1, t1, urea],
    );
    Future<void> move(int q, String reason, String date) => db.execute(
      'INSERT INTO stock_movements (id, tenant_id, product_id, batch_id, '
      'entry_date, qty_milli, reason) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id(), t1, urea, b1, date, q, reason],
    );
    await move(20000, 'purchase', '2026-09-01');
    await move(-12000, 'sale', '2026-10-02');
    final today = LedgerDate(2026, 10, 10);
    final ex = await repo.expiryRows(t1, today: today);
    expect(ex.single.batch.remainingMilli, 8000);
    expect(ex.single.bucket, ExpiryBucket.within30);
    expect(ex.single.value, const Money(32000));
    final re = await repo.reorderSuggestions(t1, today: today);
    // 8 bags <= level 10; sold 12 in 30 days -> cover 12 - 8 = 4 < level
    // 10 - 8 = 2 ... target max(12, 10) = 12, short 4 bags.
    expect(re.single.suggestedMilli, 4000);
    expect(await repo.expiryRows(t2, today: today), isEmpty);
  });
}
