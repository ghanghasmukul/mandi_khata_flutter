import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

LedgerDate d(String s) => LedgerDate.parse(s);

JournalAccount sys(SystemAccount a) => SystemJournalAccount(a);

/// Net (debit - credit) per account key.
Map<String, int> net(JournalEntryDraft e) {
  final out = <String, int>{};
  for (final l in e.lines) {
    out.update(
      l.account.key,
      (v) => v + l.debit.paise - l.credit.paise,
      ifAbsent: () => l.debit.paise - l.credit.paise,
    );
  }
  return out;
}

int dr(JournalEntryDraft e, JournalAccount a) => net(e)[a.key] ?? 0;

void main() {
  const cash = BookAccount('cash');
  const bank = BookAccount('sbi');
  final date = d('2026-10-07');

  group('sale (row 17)', () {
    // 2 bags @ 100.00 + 1 @ 50.00, 5% exclusive, 10% discount -> 236.25
    // rounded to 236.00; COGS 150.00.
    final totals = SaleCalculator.compute(
      lines: const [
        CartLine(
          productId: 'a',
          qtyMilli: 2000,
          unitPrice: Money(10000),
          rateBp: 500,
          hsn: '3102',
        ),
        CartLine(
          productId: 'b',
          qtyMilli: 1000,
          unitPrice: Money(5000),
          rateBp: 500,
          hsn: '3102',
        ),
      ],
      mode: const GstMode(pricesIncludeGst: false),
      discount: const InvoiceDiscount.percent(1000),
    );

    test('part cash, part UPI, part udhaar', () {
      final plan = ShopPosting.sale(
        saleId: 's1',
        date: date,
        totals: totals,
        paid: const [
          BookPayment('cash', Money(10000)),
          BookPayment('sbi', Money(5000)),
        ],
        udhaar: const Money(8600),
        partyId: 'farmer1',
        cogs: const Money(15000),
        invoiceNo: 'SI-W1-0001',
      );
      final e = plan.journal;
      expect(e.sourceKey, 'shop_sale:s1');
      expect(e.narration, 'SI-W1-0001');
      expect(dr(e, const PartyAccount('farmer1')), 8600);
      expect(dr(e, cash), 10000);
      expect(dr(e, bank), 5000);
      expect(dr(e, sys(SystemAccount.sales)), -22500);
      expect(dr(e, sys(SystemAccount.gstOutputCgst)), -562);
      expect(dr(e, sys(SystemAccount.gstOutputSgst)), -563);
      expect(dr(e, sys(SystemAccount.gstOutputIgst)), 0);
      expect(dr(e, sys(SystemAccount.roundOff)), 25);
      expect(dr(e, sys(SystemAccount.costOfGoodsSold)), 15000);
      expect(dr(e, sys(SystemAccount.stockInHand)), -15000);
      expect(plan.khata!.refType, RefType.shopSale);
      expect(plan.khata!.side, Side.udhaar);
      expect(plan.khata!.amount, const Money(8600));
      expect(plan.khata!.partyId, 'farmer1');
      // Party account mirrors the khata: Dr party = udhaar.
      expect(e.total, const Money(38625));
    });

    test('walk-in cash sale rounded up books Round Off as income', () {
      final t = SaleCalculator.compute(
        lines: const [
          CartLine(
            productId: 'a',
            qtyMilli: 1000,
            unitPrice: Money(10050),
            rateBp: 0,
            hsn: '3102',
          ),
        ],
        mode: const GstMode(pricesIncludeGst: false),
      );
      final plan = ShopPosting.sale(
        saleId: 's2',
        date: date,
        totals: t,
        paid: const [BookPayment('cash', Money(10100))],
        cogs: Money.zero,
      );
      expect(plan.khata, isNull);
      expect(dr(plan.journal, sys(SystemAccount.roundOff)), -50);
      expect(
        plan.journal.lines.any(
          (l) => l.account == sys(SystemAccount.costOfGoodsSold),
        ),
        isFalse,
      );
    });

    test('inter-state sale credits IGST', () {
      final t = SaleCalculator.compute(
        lines: const [
          CartLine(
            productId: 'a',
            qtyMilli: 1000,
            unitPrice: Money(10000),
            rateBp: 1800,
            hsn: '3808',
          ),
        ],
        mode: const GstMode(pricesIncludeGst: false, interState: true),
        roundToRupee: false,
      );
      final e = ShopPosting.sale(
        saleId: 's3',
        date: date,
        totals: t,
        paid: const [BookPayment('cash', Money(11800))],
        cogs: const Money(7000),
      ).journal;
      expect(dr(e, sys(SystemAccount.gstOutputIgst)), -1800);
      expect(dr(e, sys(SystemAccount.gstOutputCgst)), 0);
    });

    test('payment must match; udhaar needs a party', () {
      expect(
        () => ShopPosting.sale(
          saleId: 'x',
          date: date,
          totals: totals,
          paid: const [BookPayment('cash', Money(1))],
          cogs: Money.zero,
        ),
        throwsA(isA<JournalError>()),
      );
      expect(
        () => ShopPosting.sale(
          saleId: 'x',
          date: date,
          totals: totals,
          paid: const [],
          udhaar: totals.total,
          cogs: Money.zero,
        ),
        throwsA(isA<JournalError>()),
      );
    });
  });

  // Sold: urea 5 bags @ 266.50 incl. 5% (batch cost 200.00), rounded bill.
  final sale = SaleCalculator.compute(
    lines: const [
      CartLine(
        productId: 'urea',
        qtyMilli: 5000,
        unitPrice: Money(26650),
        rateBp: 500,
        hsn: '3102',
      ),
    ],
  );
  final sold = sale.lines.single.allocate(const [
    BatchAllocation(
      batchId: 'b1',
      qtyMilli: 5000,
      unitCost: Money(20000),
      expiry: null,
      expired: false,
    ),
  ]);

  group('sales return (row 18)', () {
    test('credited to the khata', () {
      final r = SalesReturns.compute(sold, const [ReturnRequest(0, 2000)]);
      final plan = ShopPosting.saleReturn(
        returnId: 'r1',
        date: date,
        result: r,
        settlement: ReturnSettlement.split(
          refund: r.refund,
          choice: RefundChoice.khata,
          hasParty: true,
        ),
        refunds: const [],
        partyId: 'farmer1',
        returnNo: 'SR-W1-0001',
      );
      final e = plan.journal;
      expect(e.sourceKey, 'shop_return:r1');
      expect(dr(e, const PartyAccount('farmer1')), -r.refund.paise);
      expect(dr(e, sys(SystemAccount.sales)), r.split.taxable.paise);
      expect(dr(e, sys(SystemAccount.gstOutputCgst)), r.split.cgst.paise);
      expect(dr(e, sys(SystemAccount.gstOutputSgst)), r.split.sgst.paise);
      expect(dr(e, sys(SystemAccount.stockInHand)), 40000);
      expect(dr(e, sys(SystemAccount.costOfGoodsSold)), -40000);
      expect(plan.khata!.refType, RefType.shopReturn);
      expect(plan.khata!.side, Side.jama);
      expect(plan.khata!.amount, r.refund);
    });

    test('refunded in cash; the whole invoice returns the round-off', () {
      final r = SalesReturns.compute(sold, const [
        ReturnRequest(0, 5000),
      ], invoiceRoundOff: sale.roundOff);
      expect(r.roundOff, sale.roundOff);
      final plan = ShopPosting.saleReturn(
        returnId: 'r2',
        date: date,
        result: r,
        settlement: ReturnSettlement.split(
          refund: r.refund,
          choice: RefundChoice.cash,
          hasParty: false,
        ),
        refunds: [BookPayment('cash', r.refund)],
      );
      expect(plan.khata, isNull);
      expect(dr(plan.journal, cash), -sale.total.paise);
      expect(
        dr(plan.journal, sys(SystemAccount.roundOff)),
        sale.roundOff.paise,
      );
    });

    test('settlement must match refund, cash lines and party', () {
      final r = SalesReturns.compute(sold, const [ReturnRequest(0, 1000)]);
      ReturnSettlement s(RefundChoice c) =>
          ReturnSettlement.split(refund: r.refund, choice: c, hasParty: true);
      expect(
        () => ShopPosting.saleReturn(
          returnId: 'x',
          date: date,
          result: r,
          settlement: s(RefundChoice.cash),
          refunds: const [],
          partyId: 'p',
        ),
        throwsA(isA<JournalError>()),
      );
      expect(
        () => ShopPosting.saleReturn(
          returnId: 'x',
          date: date,
          result: r,
          settlement: s(RefundChoice.khata),
          refunds: const [],
        ),
        throwsA(isA<JournalError>()),
      );
      expect(
        () => ShopPosting.saleReturn(
          returnId: 'x',
          date: date,
          result: r,
          settlement: const ReturnSettlement(
            khata: Money(1),
            cash: Money(2),
            errors: [],
          ),
          refunds: const [BookPayment('cash', Money(2))],
          partyId: 'p',
        ),
        throwsA(isA<JournalError>()),
      );
    });
  });

  group('purchase (row 19)', () {
    final totals = PurchaseRules.compute(
      lines: const [
        PurchaseLine(
          productId: 'urea',
          batchNo: 'U1',
          qtyMilli: 10000,
          unitCost: Money.rupees(250),
          rateBp: 500,
          hsn: '3102',
        ),
      ],
      freight: const Money.rupees(60),
      roundOff: const Money(-5),
    );

    test('part paid now, rest on the supplier khata', () {
      final plan = ShopPosting.purchase(
        purchaseId: 'p1',
        date: date,
        totals: totals,
        supplierId: 'agency1',
        paid: const [BookPayment('sbi', Money(100000))],
        billNo: 'PB-W1-0001',
      );
      final e = plan.journal;
      // taxable 2500.00 + tax 125.00 + freight 60.00 - 0.05 = 2684.95
      expect(totals.total, const Money(268495));
      expect(e.sourceKey, 'purchase:p1');
      expect(dr(e, sys(SystemAccount.stockInHand)), 256000);
      expect(dr(e, sys(SystemAccount.gstInputCgst)), 6250);
      expect(dr(e, sys(SystemAccount.gstInputSgst)), 6250);
      expect(dr(e, sys(SystemAccount.roundOff)), -5);
      expect(dr(e, bank), -100000);
      expect(dr(e, const PartyAccount('agency1')), -168495);
      expect(plan.khata!.refType, RefType.purchase);
      expect(plan.khata!.side, Side.jama);
      expect(plan.khata!.amount, const Money(168495));
    });

    test('paid in full: no party line, no khata entry; round-off up', () {
      final up = PurchaseRules.compute(
        lines: const [
          PurchaseLine(
            productId: 'p',
            batchNo: 'b',
            qtyMilli: 1000,
            unitCost: Money(10000),
          ),
        ],
        mode: const GstMode(enabled: false),
        roundOff: const Money(3),
      );
      final plan = ShopPosting.purchase(
        purchaseId: 'p2',
        date: date,
        totals: up,
        supplierId: 'agency1',
        paid: [BookPayment('cash', up.total)],
      );
      expect(plan.khata, isNull);
      expect(dr(plan.journal, sys(SystemAccount.roundOff)), 3);
      expect(plan.journal.lines.any((l) => l.account is PartyAccount), isFalse);
    });

    test('inter-state input goes to IGST; overpaying throws', () {
      final t = PurchaseRules.compute(
        lines: const [
          PurchaseLine(
            productId: 'p',
            batchNo: 'b',
            qtyMilli: 1000,
            unitCost: Money(10000),
            rateBp: 1800,
            hsn: '3808',
          ),
        ],
        mode: const GstMode(pricesIncludeGst: false, interState: true),
      );
      final e = ShopPosting.purchase(
        purchaseId: 'p3',
        date: date,
        totals: t,
        supplierId: 's',
        paid: const [],
      ).journal;
      expect(dr(e, sys(SystemAccount.gstInputIgst)), 1800);
      expect(
        () => ShopPosting.purchase(
          purchaseId: 'p4',
          date: date,
          totals: t,
          supplierId: 's',
          paid: const [BookPayment('cash', Money(999999))],
        ),
        throwsA(isA<JournalError>()),
      );
    });
  });

  group('purchase return (row 20)', () {
    final bought = [
      PurchasedLine(
        batchId: 'b1',
        qtyMilli: 10000,
        split: GstSplit.of(
          const Money(250000),
          500,
          inclusive: false,
          interState: false,
        ),
        landed: const Money(256000),
        batchRemainingMilli: 10000,
      ),
    ];

    test('credit note on the supplier khata', () {
      final r = PurchaseRules.computeReturn(bought, const [
        ReturnRequest(0, 4000),
      ]);
      expect(r.stockValue, const Money(102400));
      expect(r.refund, const Money(102400 + 5000));
      final plan = ShopPosting.purchaseReturn(
        returnId: 'pr1',
        date: date,
        result: r,
        settlement: ReturnSettlement.split(
          refund: r.refund,
          choice: RefundChoice.khata,
          hasParty: true,
        ),
        received: const [],
        supplierId: 'agency1',
        returnNo: 'PR-W1-0001',
      );
      final e = plan.journal;
      expect(e.sourceKey, 'purchase_return:pr1');
      expect(dr(e, sys(SystemAccount.stockInHand)), -102400);
      expect(dr(e, sys(SystemAccount.gstInputCgst)), -2500);
      expect(dr(e, sys(SystemAccount.gstInputSgst)), -2500);
      expect(dr(e, const PartyAccount('agency1')), 107400);
      expect(plan.khata!.refType, RefType.purchaseReturn);
      expect(plan.khata!.side, Side.udhaar);
    });

    test('cash refund from the supplier', () {
      final r = PurchaseRules.computeReturn(bought, const [
        ReturnRequest(0, 1000),
      ]);
      final plan = ShopPosting.purchaseReturn(
        returnId: 'pr2',
        date: date,
        result: r,
        settlement: ReturnSettlement.split(
          refund: r.refund,
          choice: RefundChoice.cash,
          hasParty: true,
        ),
        received: [BookPayment('cash', r.refund)],
        supplierId: 'agency1',
      );
      expect(plan.khata, isNull);
      expect(dr(plan.journal, cash), r.refund.paise);
    });
  });

  group('stock adjustment (row 21)', () {
    test('loss, gain and opening stock', () {
      final loss = ShopPosting.stockAdjustment(
        adjustmentId: 'a1',
        date: date,
        value: const Money(-5000),
        narration: 'damaged',
      );
      expect(loss.sourceKey, 'stock_adjustment:a1');
      expect(dr(loss, sys(SystemAccount.stockAdjustment)), 5000);
      expect(dr(loss, sys(SystemAccount.stockInHand)), -5000);

      final gain = ShopPosting.stockAdjustment(
        adjustmentId: 'a2',
        date: date,
        value: const Money(700),
      );
      expect(dr(gain, sys(SystemAccount.stockInHand)), 700);
      expect(dr(gain, sys(SystemAccount.stockAdjustment)), -700);

      final opening = ShopPosting.stockAdjustment(
        adjustmentId: 'a3',
        date: date,
        value: const Money(900),
        reason: StockMovementReason.opening,
      );
      expect(dr(opening, sys(SystemAccount.openingBalanceEquity)), -900);
      expect(
        () => ShopPosting.stockAdjustment(
          adjustmentId: 'a4',
          date: date,
          value: Money.zero,
        ),
        throwsA(isA<JournalError>()),
      );
    });
  });

  group('chart additions', () {
    test('shop system accounts sit in the right groups', () {
      expect(SystemAccount.stockInHand.group, AccountGroup.stockInHand);
      expect(SystemAccount.costOfGoodsSold.group.nature, AccountNature.expense);
      expect(SystemAccount.gstOutputIgst.group, AccountGroup.dutiesAndTaxes);
      expect(SystemAccount.gstInputCgst.group, AccountGroup.dutiesAndTaxes);
      expect(SystemAccount.roundOff.group, AccountGroup.indirectExpenses);
      expect(
        SystemAccount.fromCode('stock_adjustment'),
        SystemAccount.stockAdjustment,
      );
    });

    test('purchase return is a ledger ref type needing purchases.create', () {
      expect(RefType.parse('purchase_return'), RefType.purchaseReturn);
      expect(
        LedgerPosting.requiredPermission(RefType.purchaseReturn),
        Permission.purchasesCreate,
      );
    });
  });
}
