import 'dart:math';

import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

/// The built-in chart, ids = codes.
final chart = StatementChart([
  for (final g in AccountGroup.values)
    StatementGroup(
      id: g.code,
      code: g.code,
      name: g.name,
      nature: g.nature,
      parentId: g.parent?.code,
    ),
  const StatementGroup(
    id: 'custom_income',
    name: 'Other receipts',
    nature: AccountNature.income,
  ),
]);

StatementAccount acct(String id, String group, {int dr = 0, int cr = 0}) =>
    StatementAccount(
      id: id,
      name: id,
      groupId: group,
      debit: Money.rupees(dr),
      credit: Money.rupees(cr),
    );

/// Lot 1 of posting-rules section 5, a cash receipt from the buyer, a
/// payment to the farmer, rent paid, interest posted, an opening balance.
final List<StatementAccount> books = [
  acct('buyer', 'sundry_debtors', dr: 20952, cr: 15000), // 5,952 Dr
  acct('farmer', 'sundry_creditors', dr: 5000 + 1000, cr: 19832), // 13,832 Cr
  acct('cash', 'cash_in_hand', dr: 15000 + 10000, cr: 5000 + 2000),
  acct('commission', 'direct_income', cr: 524),
  acct('palledari', 'direct_income', cr: 216),
  acct('mandi_fee', 'duties_and_taxes', cr: 210),
  acct('rent', 'indirect_expenses', dr: 2000),
  acct('interest', 'indirect_income', cr: 1000),
  acct('obe', 'capital', cr: 10000),
  // Rounding of the lot example to whole rupees (keeps the books balanced).
  acct('round', 'indirect_income', cr: 170),
];

void main() {
  group('worked example: the books balance', () {
    test('Σ debit = Σ credit of the inputs', () {
      final d = books.fold(Money.zero, (s, a) => s + a.debit);
      final c = books.fold(Money.zero, (s, a) => s + a.credit);
      expect(d, c);
    });

    test('trial balance', () {
      final tb = TrialBalance.build(chart, books);
      expect(tb.isBalanced, isTrue);
      expect(tb.debit, const Money.rupees(5952 + 18000 + 2000));
      expect(tb.credit, tb.debit);
      final cash = tb.lines.firstWhere((l) => l.id == 'cash');
      expect(cash.debit, const Money.rupees(18000));
      final farmer = tb.lines.firstWhere((l) => l.id == 'farmer');
      expect(farmer.credit, const Money.rupees(13832));
      final assets = tb.lines.firstWhere((l) => l.id == 'current_assets');
      expect(assets.isGroup, isTrue);
      expect(assets.depth, 0);
      expect(assets.debit, const Money.rupees(5952 + 18000));
      final debtors = tb.lines.firstWhere((l) => l.id == 'sundry_debtors');
      expect(debtors.depth, 1);
      expect(tb.lines.indexOf(debtors), greaterThan(tb.lines.indexOf(assets)));
      // Group level only.
      final groups = TrialBalance.build(chart, books, withAccounts: false);
      expect(groups.lines.every((l) => l.isGroup), isTrue);
      expect(groups.debit, tb.debit);
      // Empty groups are left out.
      expect(tb.lines.where((l) => l.id == 'stock_in_hand'), isEmpty);
    });

    test('profit and loss', () {
      final pl = ProfitAndLoss.build(chart, books);
      expect(pl.total(ProfitSection.directIncome), const Money.rupees(740));
      expect(pl.total(ProfitSection.indirectIncome), const Money.rupees(1170));
      expect(
        pl.total(ProfitSection.indirectExpenses),
        const Money.rupees(2000),
      );
      expect(pl.grossProfit, const Money.rupees(740));
      expect(pl.netProfit, const Money.rupees(740 + 1170 - 2000));
      expect(pl.sections[ProfitSection.directIncome]!.map((l) => l.accountId), [
        'commission',
        'palledari',
      ]);
    });

    test('balance sheet balances with the open profit in capital', () {
      final bs = BalanceSheet.build(chart, books);
      expect(bs.currentProfit, const Money.rupees(-90));
      expect(bs.assets, const Money.rupees(5952 + 18000));
      expect(
        bs.total(BalanceSide.liabilities),
        const Money.rupees(13832 + 210),
      );
      expect(bs.total(BalanceSide.capital), const Money.rupees(10000));
      expect(bs.isBalanced, isTrue);
    });
  });

  group('trial balance: an account whose group has not synced', () {
    test('is listed at the top level and still counts', () {
      final tb = TrialBalance.build(chart, [
        acct('cash', 'cash_in_hand', dr: 100),
        acct('new-party', 'not-synced-group', cr: 60),
        acct('other', 'not-synced-group', cr: 40),
      ]);
      expect(tb.isBalanced, isTrue);
      final unknown = tb.lines.where((l) => l.depth == 0 && !l.isGroup);
      expect(unknown.map((l) => (l.id, l.credit.paise)), [
        ('new-party', 6000),
        ('other', 4000),
      ]);
    });
  });

  group('balance sheet: other-side balances', () {
    test('a creditor with a debit balance is an asset, flagged', () {
      final bs = BalanceSheet.build(chart, [
        acct('farmer', 'sundry_creditors', dr: 300),
        acct('buyer', 'sundry_debtors', cr: 100),
        acct('cash', 'cash_in_hand', cr: 200),
      ]);
      final farmer = bs.sides[BalanceSide.assets]!.single;
      expect(farmer.accountId, 'farmer');
      expect(farmer.otherSide, isTrue);
      final liab = bs.sides[BalanceSide.liabilities]!;
      expect(liab.map((l) => (l.accountId, l.otherSide)), [
        ('buyer', true),
        ('cash', true),
      ]);
      expect(bs.isBalanced, isTrue);
    });
  });

  group('profit sections', () {
    test('built-in groups and a custom income group', () {
      ProfitSection? s(String g) => ProfitAndLoss.sectionOf(chart, g);
      expect(s('sales_accounts'), ProfitSection.sales);
      expect(s('purchase_accounts'), ProfitSection.purchases);
      expect(s('direct_expenses'), ProfitSection.directExpenses);
      expect(s('custom_income'), ProfitSection.indirectIncome);
      expect(s('sundry_debtors'), isNull);
      expect(ProfitSection.sales.isIncome, isTrue);
      expect(ProfitSection.purchases.isIncome, isFalse);
      final pl = ProfitAndLoss.build(chart, [
        acct('sales', 'sales_accounts', cr: 900),
        acct('purchase', 'purchase_accounts', dr: 600),
        acct('freight', 'direct_expenses', dr: 50),
        acct('zero', 'direct_expenses', dr: 5, cr: 5),
      ]);
      expect(pl.grossProfit, const Money.rupees(250));
      expect(pl.sections[ProfitSection.directExpenses], hasLength(1));
    });
  });

  group('account ledger', () {
    test('opening, running balance, closing', () {
      final l = AccountLedger.build(
        [
          AccountPosting(
            date: LedgerDate(2027, 4, 3),
            debit: Money.zero,
            credit: const Money.rupees(300),
            order: 'b',
          ),
          AccountPosting(
            date: LedgerDate(2027, 3, 31),
            debit: const Money.rupees(1000),
            credit: Money.zero,
          ),
          AccountPosting(
            date: LedgerDate(2027, 4, 3),
            debit: const Money.rupees(50),
            credit: Money.zero,
            order: 'a',
          ),
          AccountPosting(
            date: LedgerDate(2027, 5, 1),
            debit: const Money.rupees(7),
            credit: Money.zero,
          ),
        ],
        from: LedgerDate(2027, 4, 1),
        to: LedgerDate(2027, 4, 30),
      );
      expect(l.opening, const Money.rupees(1000));
      expect([for (final x in l.lines) x.balance.paise], [105000, 75000]);
      expect(l.debit, const Money.rupees(50));
      expect(l.credit, const Money.rupees(300));
      expect(l.closing, const Money.rupees(750));
    });
  });

  group('year close', () {
    const commission = SystemJournalAccount(SystemAccount.commissionIncome);
    const rent = ChartAccount('rent');
    const fy = FinancialYear(2026);

    test('profit: incomes and expenses zeroed into P&L, OBE into capital', () {
      final e = YearClose.closingEntry(
        fy,
        incomeExpense: {
          commission: const Money.rupees(-5000),
          rent: const Money.rupees(2000),
        },
        openingEquity: const Money.rupees(-10000),
      )!;
      expect(e.sourceKey, 'year_close:2026');
      expect(e.date, LedgerDate(2027, 3, 31));
      expect(
        [for (final l in e.lines) l.toString()],
        [
          'Cr account:rent 200000',
          'Dr system:commission_income 500000',
          'Cr system:profit_and_loss 300000',
          'Dr system:opening_balance_equity 1000000',
          'Cr system:capital 1000000',
        ],
      );
    });

    test('loss goes to the debit of P&L; nothing to close = null', () {
      final e = YearClose.closingEntry(
        fy,
        incomeExpense: {rent: const Money.rupees(900)},
        openingEquity: const Money.rupees(250),
      )!;
      expect(
        e.lines.map((l) => l.toString()),
        containsAll([
          'Dr system:profit_and_loss 90000',
          'Cr system:opening_balance_equity 25000',
          'Dr system:capital 25000',
        ]),
      );
      expect(
        YearClose.closingEntry(
          fy,
          incomeExpense: {rent: Money.zero},
          openingEquity: Money.zero,
        ),
        isNull,
      );
    });

    test('locked dates', () {
      expect(YearClose.isLocked(LedgerDate(2027, 3, 31), [fy]), isTrue);
      expect(YearClose.isLocked(LedgerDate(2027, 4, 1), [fy]), isFalse);
      expect(YearClose.isLocked(LedgerDate(2026, 4, 1), const []), isFalse);
    });
  });

  group('fuzz: random balanced postings always tally', () {
    test('trial balance and balance sheet, 200 random books', () {
      final rnd = Random(42);
      final ids = [
        ('buyer', 'sundry_debtors'),
        ('farmer', 'sundry_creditors'),
        ('cash', 'cash_in_hand'),
        ('sbi', 'bank_accounts'),
        ('commission', 'direct_income'),
        ('interest', 'indirect_income'),
        ('rent', 'indirect_expenses'),
        ('fee', 'duties_and_taxes'),
        ('obe', 'capital'),
        ('sales', 'sales_accounts'),
        ('purchase', 'purchase_accounts'),
        ('other', 'custom_income'),
      ];
      for (var run = 0; run < 200; run++) {
        final dr = <String, int>{};
        final cr = <String, int>{};
        for (var i = 0; i < 30; i++) {
          final a = ids[rnd.nextInt(ids.length)].$1;
          final b = ids[rnd.nextInt(ids.length)].$1;
          final amount = rnd.nextInt(10000000) + 1;
          dr[a] = (dr[a] ?? 0) + amount;
          cr[b] = (cr[b] ?? 0) + amount;
        }
        final accounts = [
          for (final (id, group) in ids)
            StatementAccount(
              id: id,
              name: id,
              groupId: group,
              debit: Money(dr[id] ?? 0),
              credit: Money(cr[id] ?? 0),
            ),
        ];
        final tb = TrialBalance.build(chart, accounts);
        expect(tb.isBalanced, isTrue, reason: 'run $run');
        final bs = BalanceSheet.build(chart, accounts);
        expect(bs.isBalanced, isTrue, reason: 'run $run');
        final pl = ProfitAndLoss.build(chart, accounts);
        expect(pl.netProfit, bs.currentProfit, reason: 'run $run');
      }
    });
  });
}
