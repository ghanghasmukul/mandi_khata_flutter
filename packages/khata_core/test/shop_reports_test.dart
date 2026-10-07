import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

LedgerDate d(String s) => LedgerDate.parse(s);

String gstin(String first14) => first14 + Gstin.checkDigit(first14);

void main() {
  group('ShopProfit', () {
    SaleLineRecord rec(
      String id,
      String date,
      int qty,
      int revenue,
      int cogs, {
      String? cat,
    }) => SaleLineRecord(
      productId: id,
      productName: 'Prod $id',
      categoryId: cat,
      categoryName: cat == null ? null : 'Cat $cat',
      date: d(date),
      qtyMilli: qty,
      revenue: Money(revenue),
      cogs: Money(cogs),
    );

    final records = [
      rec('u', '2026-09-30', 5000, 100000, 80000, cat: 'f'),
      rec('u', '2026-10-02', 2000, 40000, 32000, cat: 'f'),
      rec('s', '2026-10-03', 1000, 50000, 30000, cat: 's'),
      rec('x', '2026-10-04', 1000, 20000, 20000),
      rec('u', '2026-10-05', -1000, -20000, -16000, cat: 'f'),
    ];

    test('by product: best profit first, returns subtract', () {
      final rows = ShopProfit.byProduct(records);
      expect(rows.map((r) => r.key), ['u', 's', 'x']);
      final u = rows.first;
      expect(u.qtyMilli, 6000);
      expect(u.revenue, const Money(120000));
      expect(u.cogs, const Money(96000));
      expect(u.profit, const Money(24000));
      expect(u.marginBp, 2000);
      expect(rows.last.marginBp, 0);
    });

    test('ties sort by label', () {
      final rows = ShopProfit.byProduct([
        rec('b', '2026-10-01', 1000, 100, 0),
        rec('a', '2026-10-01', 1000, 100, 0),
      ]);
      expect(rows.map((r) => r.key), ['a', 'b']);
    });

    test('by category and by month', () {
      final cats = ShopProfit.byCategory(records, uncategorised: 'None');
      expect(cats.map((r) => r.label), ['Cat f', 'Cat s', 'None']);
      final months = ShopProfit.byMonth(records);
      expect(months.map((r) => r.key), ['2026-09', '2026-10']);
      expect(months.last.revenue, const Money(90000));
    });

    test('table with totals and a margin text', () {
      final t = ShopProfit.table(
        ShopProfit.byProduct(records),
        title: (s) => s.toUpperCase(),
      );
      expect(t.columns.first.title, 'PRODUCT');
      expect(t.rows.first[0], 'Prod u');
      expect(t.rows.first[5], '20%');
      expect(t.totals![0], 'TOTAL');
      expect(t.totals![2], const Money(190000));
      expect(t.toCsv(), contains('Prod u,6.00,1200.00,960.00,240.00,20%'));
      final empty = ShopProfit.table(const []);
      expect(empty.totals![5], isNull);
    });
  });

  group('ReorderReport', () {
    ReorderInput p(String n, int stock, int level, int sold) => ReorderInput(
      productId: n,
      name: n,
      stockMilli: stock,
      reorderLevelMilli: level,
      soldLast30Milli: sold,
    );

    test('who needs buying, how much, most urgent first', () {
      final out = ReorderReport.suggest([
        p('plenty', 100000, 5000, 30000),
        p('atLevel', 4000, 5000, 3000),
        p('fast', 6000, 0, 30000),
        p('dead', 0, 2000, 0),
        p('negative', -1000, 0, 1500),
        p('noRule', 1000, 0, 0),
        p('weird', 5, 0, -5),
      ]);
      expect(out.map((s) => s.name), ['dead', 'negative', 'fast', 'atLevel']);
      final fast = out[2];
      // 30 bags in 30 days; 6 on hand lasts 6 days; cover 30 days = 30.
      expect(fast.daysOfStock, 6);
      expect(fast.suggestedMilli, 24000);
      final atLevel = out.last;
      // cover 3 bags, level 5 -> target 5, have 4 -> buy 1.
      expect(atLevel.suggestedMilli, 1000);
      expect(atLevel.daysOfStock, 40);
      expect(out[1].daysOfStock, 0);
      expect(out[1].suggestedMilli, 2000);
      expect(out[0].daysOfStock, 0);
      expect(out[0].suggestedMilli, 2000);
    });

    test('rounds up to whole units and never suggests nothing', () {
      final out = ReorderReport.suggest([
        p('a', 5000, 5000, 1000),
        p('b', 400, 0, 2250),
      ]);
      final a = out.firstWhere((s) => s.name == 'a');
      expect(a.suggestedMilli, 1000, reason: 'at the level: at least one');
      final b = out.firstWhere((s) => s.name == 'b');
      // runs out within the lead time; cover 2.25 units - 0.4 = 1.85 -> 2
      expect(b.suggestedMilli, 2000);
      expect(
        ReorderReport.suggest(
          [p('c', 1000, 0, 30000)],
          coverDays: 10,
          leadDays: 1,
        ),
        isEmpty,
      );
    });
  });

  group('ExpiryReport', () {
    StockBatch b(String id, String? expiry, int qty, {int cost = 10000}) =>
        StockBatch(
          id: id,
          productId: 'p',
          batchNo: id,
          cost: Money(cost),
          remainingMilli: qty,
          createdAt: DateTime.utc(2026),
          expiry: expiry == null ? null : d(expiry),
        );
    final today = d('2026-10-07');

    test('buckets', () {
      expect(
        ExpiryReport.bucketOf(d('2026-10-06'), today),
        ExpiryBucket.expired,
      );
      expect(
        ExpiryReport.bucketOf(d('2026-10-07'), today),
        ExpiryBucket.within30,
      );
      expect(
        ExpiryReport.bucketOf(d('2026-11-06'), today),
        ExpiryBucket.within30,
      );
      expect(
        ExpiryReport.bucketOf(d('2026-11-07'), today),
        ExpiryBucket.within60,
      );
      expect(
        ExpiryReport.bucketOf(d('2026-12-06'), today),
        ExpiryBucket.within60,
      );
      expect(
        ExpiryReport.bucketOf(d('2026-12-07'), today),
        ExpiryBucket.within90,
      );
      expect(
        ExpiryReport.bucketOf(d('2027-01-05'), today),
        ExpiryBucket.within90,
      );
      expect(ExpiryReport.bucketOf(d('2027-01-06'), today), ExpiryBucket.later);
    });

    test('rows sorted soonest first; value per bucket', () {
      final rows = ExpiryReport.rows([
        (b('far', '2027-06-01', 1000), 'Seed'),
        (b('old', '2026-09-01', 2000, cost: 5000), 'Urea'),
        (b('none', null, 5000), 'Zinc'),
        (b('empty', '2026-10-10', 0), 'Gone'),
        (b('soon', '2026-10-20', 1000, cost: 20000), 'Spray'),
        (b('soon2', '2026-10-20', 1000), 'Alpha'),
      ], today: today);
      expect(rows.map((r) => r.batch.id), ['old', 'soon2', 'soon', 'far']);
      expect(rows.first.daysLeft, -36);
      expect(rows.first.bucket, ExpiryBucket.expired);
      final values = ExpiryReport.valueByBucket(rows);
      expect(values[ExpiryBucket.expired], const Money(10000));
      expect(values[ExpiryBucket.within30], const Money(30000));
      expect(values[ExpiryBucket.within60], Money.zero);
      expect(values[ExpiryBucket.later], const Money(10000));
    });
  });

  group('Gstr1Report', () {
    final shopGstin = gstin('03AAPFU0939F1Z');
    final custGstin = gstin('06AAAPA1234A1Z');
    const hsnUrea = '3102';

    Gstr1Line line(
      int amount,
      int rate, {
      String hsn = hsnUrea,
      int qty = 1000,
    }) => Gstr1Line(
      hsn: hsn,
      rateBp: rate,
      qtyMilli: qty,
      uqc: 'BAG',
      split: GstSplit.of(
        Money(amount),
        rate,
        inclusive: false,
        interState: false,
      ),
    );

    Gstr1Line igstLine(int amount, int rate) => Gstr1Line(
      hsn: hsnUrea,
      rateBp: rate,
      qtyMilli: 1000,
      uqc: 'BAG',
      split: GstSplit.of(
        Money(amount),
        rate,
        inclusive: false,
        interState: true,
      ),
    );

    final invoices = [
      // B2B inter-state to Haryana, two rates.
      Gstr1Invoice(
        number: 'SI-W1-0002',
        date: d('2026-10-05'),
        customerName: 'Haryana Agro',
        gstin: custGstin,
        placeOfSupply: '06',
        lines: [igstLine(100000, 500), igstLine(50000, 1800)],
      ),
      // Walk-in, same state: B2CS.
      Gstr1Invoice(
        number: 'SI-W1-0001',
        date: d('2026-10-01'),
        customerName: 'Walk-in',
        placeOfSupply: '03',
        lines: [line(20000, 500), line(10000, 500)],
      ),
      // Unregistered inter-state, small: B2CS (INTER).
      Gstr1Invoice(
        number: 'SI-W1-0003',
        date: d('2026-10-06'),
        customerName: 'Raju',
        placeOfSupply: '08',
        lines: [igstLine(5000, 500)],
      ),
      // Unregistered inter-state, large: B2CL.
      Gstr1Invoice(
        number: 'SI-A2-0100',
        date: d('2026-10-07'),
        customerName: 'Big farm',
        placeOfSupply: '08',
        lines: [igstLine(20000000, 500)],
      ),
      // Credit notes: registered, unregistered small, unregistered large.
      Gstr1Invoice(
        number: 'SR-W1-0001',
        date: d('2026-10-08'),
        customerName: 'Haryana Agro',
        gstin: custGstin,
        placeOfSupply: '06',
        isCreditNote: true,
        lines: [igstLine(10000, 500)],
      ),
      Gstr1Invoice(
        number: 'SR-W1-0002',
        date: d('2026-10-09'),
        customerName: 'Walk-in',
        placeOfSupply: '03',
        isCreditNote: true,
        lines: [line(10000, 500)],
      ),
      Gstr1Invoice(
        number: 'SR-W1-0003',
        date: d('2026-10-10'),
        customerName: 'Big farm',
        placeOfSupply: '08',
        isCreditNote: true,
        lines: [igstLine(15000000, 500)],
      ),
      // Missing HSN and rate.
      Gstr1Invoice(
        number: 'SI-W1-0004',
        date: d('2026-10-11'),
        customerName: 'Walk-in',
        placeOfSupply: '03',
        roundOff: const Money(-10),
        lines: const [
          Gstr1Line(
            hsn: '',
            rateBp: null,
            qtyMilli: 2000,
            split: GstSplit(
              taxable: Money(1000),
              cgst: Money.zero,
              sgst: Money.zero,
              igst: Money.zero,
            ),
          ),
        ],
      ),
    ];

    final report = Gstr1Report.build(
      invoices: invoices,
      tenantGstin: shopGstin,
      tenantStateCode: '03',
      year: 2026,
      month: 10,
    );

    test('classification', () {
      expect(report.b2b.map((i) => i.number), ['SI-W1-0002']);
      expect(report.b2cl.map((i) => i.number), ['SI-A2-0100']);
      expect(report.cdnr.map((i) => i.number), ['SR-W1-0001']);
      expect(report.cdnur.map((i) => i.number), ['SR-W1-0003']);
      expect(report.filingPeriod, '102026');
    });

    test('B2CS groups by place of supply and rate, credit notes net off', () {
      final rows = report.b2cs;
      expect(rows.map((r) => (r.placeOfSupply, r.rateBp, r.interState)), [
        ('03', 0, false),
        ('03', 500, false),
        ('08', 500, true),
      ]);
      final intra = rows[1];
      // 200 + 100 - 100 (the small credit note)
      expect(intra.split.taxable, const Money(20000));
      expect(intra.split.cgst, const Money(500));
      expect(rows[2].split.igst, const Money(250));
      expect(rows[2].supplyType, 'INTER');
      expect(rows[1].supplyType, 'INTRA');
    });

    test('HSN summary subtracts credit notes', () {
      final urea = report.hsn.firstWhere(
        (h) => h.hsn == hsnUrea && h.rateBp == 500,
      );
      // 1000 + 200 + 100 + 50 + 200000 - 100 - 100 - 150000 (taxable, rupees)
      expect(
        urea.split.taxable,
        const Money(
          100000 + 20000 + 10000 + 5000 + 20000000 - 10000 - 10000 - 15000000,
        ),
      );
      expect(urea.qtyMilli, 5 * 1000 - 3 * 1000 - 1000 + 1000);
      expect(report.hsn.first.hsn, '');
    });

    test('document summary', () {
      expect(report.docs.map((x) => (x.nature, x.from, x.to, x.count)), [
        ('Credit Note', 'SR-W1-0001', 'SR-W1-0003', 3),
        ('Invoices for outward supply', 'SI-A2-0100', 'SI-A2-0100', 1),
        ('Invoices for outward supply', 'SI-W1-0001', 'SI-W1-0004', 4),
      ]);
    });

    test('lines without HSN or rate are flagged', () {
      expect(
        report.issues.map((i) => (i.invoiceNumber, i.lineIndex, i.issue)),
        [
          ('SI-W1-0004', 0, GstIssue.missingHsn),
          ('SI-W1-0004', 0, GstIssue.missingRate),
        ],
      );
    });

    test('invoice value includes round-off', () {
      final last = invoices.last;
      expect(last.value, const Money(990));
      expect(last.isRegistered, isFalse);
      expect(invoices.first.isRegistered, isTrue);
      expect(invoices.first.byRate.keys, [500, 1800]);
    });

    test('tables', () {
      final b2b = report.b2bTable();
      expect(b2b.rows, hasLength(2));
      expect(b2b.rows.first.first, custGstin);
      expect(b2b.rows.first[6], '5');
      expect(b2b.rows.first[8], const Money(5000));
      expect(report.b2clTable().rows, hasLength(1));
      expect(
        report.cdnTable(title: (s) => '<$s>').columns[2].title,
        '<Credit note no>',
      );
      expect(report.cdnTable().rows, hasLength(2));
      expect(report.b2csTable().rows.first[0], 'INTRA');
      final hsn = report.hsnTable();
      expect(hsn.rows.first[1], 'OTH');
      expect(hsn.rows.last[1], 'BAG');
      expect(report.docsTable().rows.last[3], 4);
      expect(
        report.docsTable().toCsv(),
        startsWith('Nature of document,From,To,Total'),
      );
    });

    test('JSON follows the portal layout', () {
      final j = report.toJson();
      expect(jsonDecode(jsonEncode(j)), isA<Map<String, Object?>>());
      expect(j['gstin'], shopGstin);
      expect(j['fp'], '102026');
      final b2b = (j['b2b']! as List).single as Map<String, Object?>;
      expect(b2b['ctin'], custGstin);
      final inv = (b2b['inv']! as List).single as Map<String, Object?>;
      expect(inv['inum'], 'SI-W1-0002');
      expect(inv['idt'], '05-10-2026');
      expect(inv['val'], 1640.0);
      expect(inv['pos'], '06');
      expect(inv['rchrg'], 'N');
      final items = inv['itms']! as List;
      expect(items, hasLength(2));
      final det = (items.first as Map)['itm_det'] as Map;
      expect(det['rt'], 5);
      expect(det['txval'], 1000.0);
      expect(det['iamt'], 50.0);
      expect(det.containsKey('camt'), isFalse);

      final cl = (j['b2cl']! as List).single as Map<String, Object?>;
      expect(cl['pos'], '08');
      final b2cs = j['b2cs']! as List;
      expect((b2b['inv']! as List).length, 1);
      expect((b2cs[1] as Map)['sply_ty'], 'INTRA');
      expect((b2cs[1] as Map)['camt'], 5.0);
      final cdnr = ((j['cdnr']! as List).single as Map)['nt'] as List;
      expect((cdnr.single as Map)['nt_num'], 'SR-W1-0001');
      expect((cdnr.single as Map)['ntty'], 'C');
      final cdnur = (j['cdnur']! as List).single as Map;
      expect(cdnur['typ'], 'B2CL');
      final hsn = ((j['hsn']! as Map)['data']! as List).last as Map;
      expect(hsn['uqc'], 'BAG');
      expect(hsn['hsn_sc'], hsnUrea);
      final docs = (j['doc_issue']! as Map)['doc_det']! as List;
      expect(docs, hasLength(2));
      expect((docs.last as Map)['docs']! as List, hasLength(2));
    });

    test('an empty month and the unit codes', () {
      final e = Gstr1Report.build(
        invoices: const [],
        tenantGstin: shopGstin,
        tenantStateCode: '03',
        year: 2026,
        month: 4,
      );
      expect(e.b2b, isEmpty);
      expect(e.docs, isEmpty);
      expect(e.filingPeriod, '042026');
      expect(Gstr1Uqc.of('bag'), 'BAG');
      expect(Gstr1Uqc.of('kg'), 'KGS');
      expect(Gstr1Uqc.of('pkt'), 'PAC');
      expect(Gstr1Uqc.of('weird'), 'OTH');
    });

    test('document numbers without a counter are their own series', () {
      final r = Gstr1Report.build(
        invoices: [
          Gstr1Invoice(
            number: 'ODD',
            date: d('2026-10-01'),
            customerName: 'x',
            placeOfSupply: '03',
            lines: [line(100, 500)],
          ),
          Gstr1Invoice(
            number: 'ODD',
            date: d('2026-10-02'),
            customerName: 'x',
            placeOfSupply: '03',
            lines: [line(100, 500)],
          ),
        ],
        tenantGstin: shopGstin,
        tenantStateCode: '03',
        year: 2026,
        month: 10,
      );
      expect(r.docs.single.from, 'ODD');
      expect(r.docs.single.count, 2);
    });
  });
}
