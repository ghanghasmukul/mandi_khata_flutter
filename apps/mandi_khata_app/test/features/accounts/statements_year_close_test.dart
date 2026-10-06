import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/statements_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/voucher_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/year_close_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/expenses/data/expenses_repository.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'owner',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const farmer = 'f0000000-0000-4000-8000-000000000001';
const buyer = 'b0000000-0000-4000-8000-000000000001';

bool owner(Permission _) => true;

const fy = FinancialYear(2026);
final inYear = LedgerDate(2026, 9, 1);
final today = LedgerDate(2027, 4, 10);
final now = DateTime.utc(2027, 4, 10, 6);
final String cash = BankAccountsRepository.cashIdFor(t1);
final String rentCategory = JournalWriter.expenseCategoryId(
  t1,
  ExpenseCategorySeed.rent,
);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late StatementsRepository statements;
  late YearCloseRepository years;
  late PaymentsRepository payments;
  late LedgerRepository ledger;

  Future<String> sys(SystemAccount a) async =>
      JournalWriter.accountId(t1, SystemJournalAccount(a));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_statements_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    statements = StatementsRepository(db);
    years = YearCloseRepository(db);
    payments = PaymentsRepository(db);
    ledger = LedgerRepository(db);
    for (final (id, name, role) in [
      (farmer, 'Gurmeet Singh', 'farmer'),
      (buyer, 'Bansal Traders', 'buyer'),
    ]) {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [id, t1, 'C-$name', name],
      );
      await db.execute(
        'INSERT INTO party_roles (id, tenant_id, party_id, role) '
        'VALUES (?, ?, ?, ?)',
        ['r-$id', t1, id, role],
      );
    }
    await db.execute(
      'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
      "sort_order) VALUES (?, ?, 'cash', 'Cash', 1, 0)",
      [cash, t1],
    );
    await db.execute(
      'INSERT INTO expense_categories (id, tenant_id, code, name, group_code, '
      "sort_order, is_active) VALUES (?, ?, 'rent', 'Rent', "
      "'indirect_expenses', 70, 1)",
      [rentCategory, t1],
    );

    // FY 2026-27: an opening balance (buyer owes 10,000), a cash sale of
    // 2,500 (sales voucher), a receipt of 4,000 from the buyer, rent 1,200
    // in cash, and a manual khata entry for the farmer.
    await ledger.append(
      ctx,
      LedgerDraft(
        partyId: buyer,
        side: Side.udhaar,
        amount: const Money.rupees(10000),
        refType: RefType.openingBalance,
        entryDate: LedgerDate(2026, 4, 1),
      ),
      can: owner,
      now: now,
    );
    final chart = await db.readTransaction(
      (tx) => ChartRepository.load(tx, t1),
    );
    await VoucherRepository(db).save(
      ctx,
      VoucherDraft(
        type: VoucherType.sales,
        date: inYear,
        lines: [
          VoucherDraftLine(
            account: chart.byId(
              JournalWriter.accountId(t1, BookAccount(cash)),
            )!,
            side: DrCr.dr,
            amount: const Money.rupees(2500),
          ),
          VoucherDraftLine(
            account: chart.byId(await sys(SystemAccount.sales))!,
            side: DrCr.cr,
            amount: const Money.rupees(2500),
          ),
        ],
      ),
      can: owner,
      now: now,
    );
    await payments.save(
      ctx,
      PaymentDraft(
        entryDate: inYear,
        partyId: buyer,
        direction: PaymentDirection.fromParty,
        mode: PaymentMode.cash,
        amount: const Money.rupees(4000),
      ),
      can: owner,
      now: now,
    );
    await ExpensesRepository(db).save(
      ctx,
      ExpenseDraft(
        date: inYear,
        categoryId: rentCategory,
        amount: const Money.rupees(1200),
        isCash: true,
      ),
      can: owner,
      now: now,
    );
    await ledger.append(
      ctx,
      LedgerDraft(
        partyId: farmer,
        side: Side.jama,
        amount: const Money.rupees(300),
        refType: RefType.journal,
        entryDate: inYear,
      ),
      can: owner,
      now: now,
    );
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test('trial balance, profit and loss and balance sheet tally', () async {
    final tb = await statements.trialBalance(t1, asOf: today);
    expect(tb.isBalanced, isTrue);
    // Debit balances: buyer 6,000, cash 5,300, rent 1,200 and Khata
    // Adjustments 300 (the farmer's manual jama).
    expect(tb.debit, const Money.rupees(6000 + 5300 + 1200 + 300));

    final pl = await statements.profitAndLoss(t1, from: fy.start, to: fy.end);
    expect(pl.total(ProfitSection.sales), const Money.rupees(2500));
    expect(pl.total(ProfitSection.indirectExpenses), const Money.rupees(1200));
    expect(pl.netProfit, const Money.rupees(1300));

    final bs = await statements.balanceSheet(t1, asOf: today);
    expect(bs.isBalanced, isTrue);
    expect(bs.currentProfit, const Money.rupees(1300));
    // Khata Adjustments (a liability group) with a debit balance is shown
    // among the assets.
    expect(bs.assets, const Money.rupees(6000 + 5300 + 300));

    // Another business sees an empty trial balance.
    final other = await statements.trialBalance(t2, asOf: today);
    expect(other.lines, isEmpty);
  });

  test('a party ledger equals its khata; group summary', () async {
    final buyerAccount = JournalWriter.accountId(t1, const PartyAccount(buyer));
    final l = await statements.ledger(
      t1,
      buyerAccount,
      from: LedgerDate(2026, 5, 1),
      to: today,
    );
    expect(l.opening, const Money.rupees(10000));
    expect(l.closing, const Money.rupees(6000));
    final balances = await ledger.watchBalances(t1).first;
    expect(-balances[buyer]!.paise, l.closing.paise);
    final debtors = JournalWriter.groupId(t1, AccountGroup.sundryDebtors);
    final summary = await statements.groupSummary(t1, debtors, asOf: today);
    expect(summary.single.$1.partyId, buyer);
    expect(summary.single.$2, const Money.rupees(6000));
  });

  group('year close', () {
    test('preview, refusals, close, and the next year starts clean', () async {
      var p = await years.preview(t1, fy, isOwner: false, today: today);
      expect(p.problems, [YearCloseProblem.notOwner]);
      p = await years.preview(
        t1,
        const FinancialYear(2027),
        isOwner: true,
        today: today,
      );
      expect(p.problems, contains(YearCloseProblem.notEnded));
      p = await years.preview(t1, fy, isOwner: true, today: today);
      expect(p.canClose, isTrue);
      expect(p.profit, const Money.rupees(1300));

      final r = await years.close(
        ctx,
        fy,
        isOwner: true,
        today: today,
        now: now,
      );
      expect(r, isA<YearClosed>());
      expect(
        await years.close(ctx, fy, isOwner: true, today: today),
        isA<YearCloseRefused>(),
        reason: 'a second close refuses: the year row exists',
      );

      // The closing entry zeroes sales and rent into P&L A/c, OBE into
      // capital; P&L of the year (without year-close) is unchanged.
      final totals = await db.readTransaction(
        (tx) => ChartRepository.totals(tx, t1, to: fy.end),
      );
      expect(totals[await sys(SystemAccount.sales)]!.net, Money.zero);
      expect(
        totals[await sys(SystemAccount.profitAndLoss)]!.net,
        const Money.rupees(-1300),
      );
      expect(
        totals[await sys(SystemAccount.openingBalanceEquity)]!.net,
        Money.zero,
      );
      expect(
        totals[await sys(SystemAccount.capital)]!.net,
        const Money.rupees(-10000),
      );
      final pl = await statements.profitAndLoss(t1, from: fy.start, to: fy.end);
      expect(pl.netProfit, const Money.rupees(1300));
      final bs = await statements.balanceSheet(t1, asOf: today);
      expect(bs.isBalanced, isTrue);
      expect(bs.currentProfit, Money.zero);
      final tb = await statements.trialBalance(t1, asOf: today);
      expect(tb.isBalanced, isTrue);

      final rows = await years.watch(t1, today).first;
      expect(rows.map((y) => (y.year.startYear, y.isClosed)), [
        (2027, false),
        (2026, true),
      ]);
      expect(rows.last.profit, const Money.rupees(1300));
      expect(
        (await db.get(
          'SELECT COUNT(*) AS n FROM audit_log WHERE table_name = '
          "'financial_years'",
        ))['n'],
        1,
      );
    });

    test(
      'a closed year is locked; the owner posts there with a reason',
      () async {
        await years.close(ctx, fy, isOwner: true, today: today, now: now);
        PaymentDraft late() => PaymentDraft(
          entryDate: LedgerDate(2027, 3, 1),
          partyId: buyer,
          direction: PaymentDirection.fromParty,
          mode: PaymentMode.cash,
          amount: const Money.rupees(1),
        );
        final refused = await payments.save(ctx, late(), can: owner, now: now);
        expect(
          refused,
          isA<PaymentNotPermitted>().having(
            (r) => r.lockedYear,
            'locked',
            true,
          ),
        );
        final entry = await db.get(
          "SELECT id FROM ledger_entries WHERE ref_type = 'journal'",
        );
        expect(
          await ledger.reverse(ctx, entry['id']! as String, can: owner),
          isA<LedgerNotPermitted>().having((r) => r.lockedYear, 'locked', true),
        );

        const unlocked = WriteContext(
          tenantId: t1,
          userId: 'owner',
          deviceId: 'device-w1',
          deviceCode: 'W1',
          lockReason: 'CA found a missed receipt',
        );
        final ok = await payments.save(unlocked, late(), can: owner, now: now);
        expect(ok, isA<PaymentSaved>());
        final journal = await db.get(
          'SELECT lock_reason FROM journal_entries WHERE source_key = ?',
          ['payment:${(ok as PaymentSaved).id}'],
        );
        expect(journal['lock_reason'], 'CA found a missed receipt');
        // An entry in an open year carries no reason even while unlocked.
        final open = await payments.save(
          unlocked,
          PaymentDraft(
            entryDate: today,
            partyId: buyer,
            direction: PaymentDirection.fromParty,
            mode: PaymentMode.cash,
            amount: const Money.rupees(1),
          ),
          can: owner,
          now: now,
        );
        final openJournal = await db.get(
          'SELECT lock_reason FROM journal_entries WHERE source_key = ?',
          ['payment:${(open as PaymentSaved).id}'],
        );
        expect(openJournal['lock_reason'], isNull);
      },
    );
  });
}
