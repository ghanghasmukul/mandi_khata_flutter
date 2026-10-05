import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/interest/data/interest_posting_repository.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/loans/data/loans_repository.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const otherCtx = WriteContext(
  tenantId: t2,
  userId: 'user-b',
  deviceId: 'device-b',
  deviceCode: 'W1',
);

const farmer = 'f0000000-0000-4000-8000-000000000001';
const guarantor = 'f0000000-0000-4000-8000-000000000002';
const farmerT2 = 'f0000000-0000-4000-8000-000000000003';
const sbi = 'a0000000-0000-4000-8000-000000000001';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);
bool accountant(Permission p) => MemberRole.accountant.allows(p);

final day = LedgerDate(2026, 4, 10);
final now = DateTime.utc(2026, 4, 10, 6);

/// A month later: repayments, rate changes and closings happen then.
final later = DateTime.utc(2026, 5, 10, 6);
final String cash = BankAccountsRepository.cashIdFor(t1);

InterestConfig terms({
  String rate = '18',
  Appropriation appropriation = Appropriation.interestFirst,
}) => InterestConfig(
  ratePa: Decimal.parse(rate),
  rounding: InterestRounding.paise,
  appropriation: appropriation,
);

LoanDraft draft({
  Money amount = const Money.rupees(100000),
  String party = farmer,
  InterestConfig? config,
  LedgerDate? due,
  String? guarantorId,
  PaymentMode mode = PaymentMode.cash,
  String? bank,
}) => LoanDraft(
  partyId: party,
  amount: amount,
  issueDate: day,
  config: config ?? terms(),
  purpose: ' Diesel and seed ',
  dueDate: due,
  guarantorPartyId: guarantorId,
  mode: mode,
  bankAccountId: bank,
);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late PaymentsRepository payments;
  late LoansRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_loans_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    payments = PaymentsRepository(db);
    repo = LoansRepository(db, payments);
    for (final (id, tenant, name) in [
      (farmer, t1, 'Gurmeet Singh'),
      (guarantor, t1, 'Harbans Lal'),
      (farmerT2, t2, 'Other Farmer'),
    ]) {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [id, tenant, 'C-$name', name],
      );
    }
    for (final (id, kind, name) in [
      (cash, 'cash', 'Cash'),
      (sbi, 'bank', 'SBI'),
    ]) {
      await db.execute(
        'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
        'sort_order) VALUES (?, ?, ?, ?, 1, 0)',
        [id, t1, kind, name],
      );
    }
    await db.execute('DELETE FROM ps_crud');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<List<Map<String, Object?>>> rows(String table) =>
      db.getAll('SELECT * FROM $table ORDER BY created_at, id');

  Future<int> transactions() async =>
      (await db.getAll('SELECT DISTINCT tx_id FROM ps_crud')).length;

  Future<Money> balance(String partyId) async {
    final r = await db.get(
      "SELECT COALESCE(SUM(CASE side WHEN 'jama' THEN amount_paise "
      'ELSE -amount_paise END), 0) AS b FROM ledger_entries '
      'WHERE tenant_id = ? AND party_id = ?',
      [t1, partyId],
    );
    return Money(r['b']! as int);
  }

  Future<LoanDetail> detail(String id, [String tenant = t1]) async =>
      (await repo.watchOne(tenant, id).first)!;

  Future<String> issue({
    LoanDraft? d,
    bool Function(Permission) can = owner,
  }) async {
    final r = await repo.issue(ctx, d ?? draft(), can: can, now: now);
    expect(r, isA<LoanSaved>());
    return (r as LoanSaved).id;
  }

  Future<LoanResult> repay(
    String loanId,
    int rupees, {
    LedgerDate? date,
    RepaymentSource source = RepaymentSource.payment,
    PaymentMode mode = PaymentMode.cash,
    String? bank,
    bool Function(Permission) can = owner,
  }) => repo.repay(
    ctx,
    LoanRepaymentDraft(
      loanId: loanId,
      date: date ?? LedgerDate(2026, 5, 10),
      amount: Money.rupees(rupees),
      source: source,
      mode: mode,
      bankAccountId: bank,
    ),
    can: can,
    now: later,
  );

  Future<void> nothingWritten() async {
    for (final t in [
      'loans',
      'payments',
      'ledger_entries',
      'cash_bank_entries',
      'audit_log',
      'loan_rate_changes',
      'number_series',
    ]) {
      expect(await rows(t), isEmpty, reason: t);
    }
    expect(await transactions(), 0);
  }

  group('issuing', () {
    test('writes the loan, payment, khata entry, book line and audit in '
        'ONE upload', () async {
      final id = await issue(d: draft(due: LedgerDate(2026, 10, 10)));
      final loan = (await detail(id)).loan;
      expect(loan.loanNo, 'KZ-W1-0001');
      expect(loan.partyName, 'Gurmeet Singh');
      expect(loan.principal, const Money.rupees(100000));
      expect(loan.purpose, 'Diesel and seed');
      expect(loan.dueDate, LedgerDate(2026, 10, 10));
      expect(loan.status, LoanStatus.active);
      expect(loan.issueDate, day);

      final payment = (await rows('payments')).single;
      expect(payment['direction'], 'to_party');
      expect(payment['loan_id'], id);
      expect(payment['receipt_no'], 'V-W1-0001');
      expect(payment['bank_account_id'], cash);
      expect(payment['amount_paise'], 10000000);

      final entry = (await rows('ledger_entries')).single;
      expect(entry['ref_type'], 'loan_disbursal');
      expect(entry['ref_id'], id);
      expect(entry['side'], 'udhaar');
      expect(entry['amount_paise'], 10000000);
      expect(entry['entry_date'], '2026-04-10');
      expect(entry['narration'], 'KZ-W1-0001 · V-W1-0001');

      final line = (await rows('cash_bank_entries')).single;
      expect(line['direction'], 'out');
      expect(line['account_kind'], 'cash');

      expect(await balance(farmer), const Money.rupees(-100000));
      expect(await transactions(), 1);
      final tables = (await rows(
        'audit_log',
      )).map((a) => a['table_name']).toList()..sort();
      expect(tables, [
        'cash_bank_entries',
        'ledger_entries',
        'loans',
        'payments',
      ]);
    });

    test('the interest terms are snapshotted and the loan is its own '
        'account (loans_only)', () async {
      final id = await issue(
        d: draft(
          config: terms(
            rate: '24.5',
            appropriation: Appropriation.principalFirst,
          ),
        ),
      );
      final raw = (await rows('loans')).single['interest_config_snapshot']!;
      final json = jsonDecode(raw as String) as Map<String, Object?>;
      expect(json['rate_pa'], '24.5');
      expect(json['apply_on'], 'loans_only');
      expect(json['appropriation'], 'principal_first');
      final loan = (await detail(id)).loan;
      expect(loan.config.ratePa, Decimal.parse('24.5'));
      expect(loan.config.applyOn, ApplyOn.loansOnly);
      final audit = (await rows(
        'audit_log',
      )).firstWhere((a) => a['table_name'] == 'loans');
      final after =
          jsonDecode(audit['after']! as String) as Map<String, Object?>;
      expect((after['interest_config_snapshot']! as Map)['rate_pa'], '24.5');
    });

    test('a guarantor is stored and shown', () async {
      final id = await issue(d: draft(guarantorId: guarantor));
      final loan = (await detail(id)).loan;
      expect(loan.guarantorId, guarantor);
      expect(loan.guarantorName, 'Harbans Lal');
    });

    test('a bank disbursal goes through the bank account', () async {
      await issue(
        d: draft(mode: PaymentMode.bank, bank: sbi),
      );
      expect((await rows('payments')).single['bank_account_id'], sbi);
      expect((await rows('cash_bank_entries')).single['account_kind'], 'bank');
    });

    test('numbers follow on', () async {
      await issue();
      await issue();
      expect(await repo.previewNextNo(ctx), 'KZ-W1-0003');
      final nos = (await repo.watchAll(t1, const LoanFilter()).first)
          .map((s) => s.loan.loanNo)
          .toSet();
      expect(nos, {'KZ-W1-0001', 'KZ-W1-0002'});
    });

    test('only loans.manage issues: accountant and munshi are refused, '
        'nothing written', () async {
      for (final can in [accountant, munshi]) {
        final r = await repo.issue(ctx, draft(), can: can, now: now);
        expect(r, isA<LoanNotPermitted>());
        expect((r as LoanNotPermitted).permission, Permission.loansManage);
      }
      await nothingWritten();
    });

    test('rule problems are returned and nothing is written', () async {
      for (final (d, problem) in [
        (draft(amount: Money.zero), LoanProblem.amountNotPositive),
        (draft(guarantorId: farmer), LoanProblem.guarantorIsBorrower),
        (draft(due: LedgerDate(2026, 4, 9)), LoanProblem.dueBeforeIssue),
        (draft(config: terms(rate: '101')), LoanProblem.rateInvalid),
      ]) {
        final r = await repo.issue(ctx, d, can: owner, now: now);
        expect(r, isA<LoanInvalid>());
        expect((r as LoanInvalid).problems, contains(problem));
      }
      final bank = await repo.issue(
        ctx,
        draft(mode: PaymentMode.bank),
        can: owner,
        now: now,
      );
      expect((bank as LoanInvalid).paymentProblems, [
        PaymentProblem.bankAccountMissing,
      ]);
      await nothingWritten();
    });

    test('an unknown party or guarantor writes nothing', () async {
      final a = await repo.issue(
        ctx,
        draft(party: farmerT2),
        can: owner,
        now: now,
      );
      expect(a, isA<LoanNotFound>());
      final b = await repo.issue(
        ctx,
        draft(guarantorId: farmerT2),
        can: owner,
        now: now,
      );
      expect(b, isA<LoanNotFound>());
      await nothingWritten();
    });

    test('a payment that fails after the loan row rolls the whole save back, '
        'number included', () async {
      final r = await repo.issue(
        ctx,
        draft(mode: PaymentMode.bank, bank: 'no-such-account'),
        can: owner,
        now: now,
      );
      expect(r, isA<LoanNotFound>());
      await nothingWritten();
      expect(await repo.previewNextNo(ctx), 'KZ-W1-0001');
    });

    test(
      'a back-dated issue needs entries.reverse (the payment rule)',
      () async {
        final old = LoanDraft(
          partyId: farmer,
          amount: const Money.rupees(5000),
          issueDate: LedgerDate(2026, 3, 1),
          config: terms(),
        );
        bool onlyLoans(Permission p) =>
            p == Permission.loansManage || p == Permission.paymentsCreate;
        final r = await repo.issue(ctx, old, can: onlyLoans, now: now);
        expect(r, isA<LoanNotPermitted>());
        expect((r as LoanNotPermitted).permission, Permission.entriesReverse);
        await nothingWritten();
      },
    );
  });

  group('the statement and figures', () {
    test(
      '30 days at 18% on ₹1,00,000 is ₹1,479.45; payable ₹1,01,479.45',
      () async {
        final id = await issue();
        final p = (await detail(id)).position(LedgerDate(2026, 5, 10));
        expect(p.accrued, const Money(147945));
        expect(p.payable, const Money(10147945));
        expect(p.recoveryPercent, 0);
      },
    );

    test('the list carries each loan with its figures', () async {
      await issue(d: draft(due: LedgerDate(2026, 4, 30)));
      final list = await repo
          .watchAll(t1, const LoanFilter(), asOf: LedgerDate(2026, 5, 10))
          .first;
      expect(list.single.position.payable, const Money(10147945));
      expect(list.single.position.health, LoanHealth.overdue);
      expect(LoanTotals.of(list).overdue, 1);
      expect(LoanTotals.of(list).principal, const Money.rupees(100000));
    });

    test('filters: status and text', () async {
      final a = await issue();
      await issue(d: draft(party: guarantor));
      await repo.writeOff(
        ctx,
        a,
        closedOn: day,
        reason: 'Gone',
        can: owner,
        now: later,
      );
      Future<List<String>> names(LoanFilter f) async => [
        for (final s in await repo.watchAll(t1, f).first) s.loan.partyName,
      ];
      expect(await names(const LoanFilter()), ['Harbans Lal']);
      expect(await names(const LoanFilter(status: LoanStatusFilter.closed)), [
        'Gurmeet Singh',
      ]);
      expect(
        await names(const LoanFilter(status: LoanStatusFilter.all)),
        hasLength(2),
      );
      expect(
        await names(
          const LoanFilter(status: LoanStatusFilter.all, query: 'harb'),
        ),
        ['Harbans Lal'],
      );
      expect(
        await names(
          const LoanFilter(status: LoanStatusFilter.all, query: 'kz-w1-0001'),
        ),
        ['Gurmeet Singh'],
      );
    });

    test('another business sees none of it', () async {
      final id = await issue();
      expect(await repo.watchAll(t2, const LoanFilter()).first, isEmpty);
      expect(await repo.watchOne(t2, id).first, isNull);
      final r = await repo.repay(
        otherCtx,
        LoanRepaymentDraft(
          loanId: id,
          date: day,
          amount: const Money.rupees(1),
        ),
        can: owner,
        now: later,
      );
      expect(r, isA<LoanNotFound>());
    });
  });

  group('repayments', () {
    test('cash: payment, jama entry, book line, one upload; split as '
        'previewed', () async {
      final id = await issue();
      await db.execute('DELETE FROM ps_crud');
      final before = await detail(id);
      final preview = before.previewRepayment(
        LedgerDate(2026, 5, 10),
        const Money.rupees(20000),
      );
      expect(preview.interest, const Money(147945));
      expect(preview.principal, const Money(1852055));

      final r = await repay(id, 20000);
      expect(r, isA<LoanSaved>());
      final pay = (await rows('payments')).last;
      expect(pay['direction'], 'from_party');
      expect(pay['loan_id'], id);
      expect(pay['receipt_no'], 'R-W1-0001');
      final entry = (await rows('ledger_entries')).last;
      expect(entry['ref_type'], 'loan_repayment');
      expect(entry['side'], 'jama');
      expect(entry['ref_id'], pay['id']);
      expect(entry['narration'], 'KZ-W1-0001 · R-W1-0001');
      expect(await transactions(), 1);

      final after = await detail(id);
      expect(after.entries, hasLength(2));
      expect(after.entries.last.paymentId, pay['id']);
      final p = after.position(LedgerDate(2026, 5, 10));
      expect(p.interestRecovered, preview.interest);
      expect(p.principalRecovered, preview.principal);
      expect(p.payable, preview.payableAfter);
      expect(p.recoveryPercent, 18);
      expect(await balance(farmer), const Money.rupees(-80000));
    });

    test('a munshi may take cash repayments but not bank ones', () async {
      final id = await issue();
      expect(await repay(id, 1000, can: munshi), isA<LoanSaved>());
      final r = await repay(
        id,
        1000,
        mode: PaymentMode.bank,
        bank: sbi,
        can: munshi,
      );
      expect(r, isA<LoanNotPermitted>());
      expect((r as LoanNotPermitted).permission, Permission.financeView);
    });

    test('more than is due is refused (it would only be credit)', () async {
      final id = await issue();
      final r = await repay(id, 150000);
      expect(r, isA<LoanExceedsPayable>());
      expect((r as LoanExceedsPayable).payable, const Money(10147945));
      expect(await rows('payments'), hasLength(1)); // the disbursal only
    });

    test('exactly what is due clears the loan so it can be closed', () async {
      final id = await issue();
      final r = await repo.repay(
        ctx,
        LoanRepaymentDraft(
          loanId: id,
          date: LedgerDate(2026, 5, 10),
          amount: const Money(10147945),
        ),
        can: owner,
        now: later,
      );
      expect(r, isA<LoanSaved>());
      final p = (await detail(id)).position(LedgerDate(2026, 5, 10));
      expect(p.payable, Money.zero);
      expect(p.health, LoanHealth.settled);
    });

    test('a zero amount, an unknown loan and a closed loan', () async {
      final id = await issue();
      final zero = await repay(id, 0);
      expect((zero as LoanInvalid).problems, [LoanProblem.amountNotPositive]);
      expect(await repay('nope', 10), isA<LoanNotFound>());
      await repo.writeOff(
        ctx,
        id,
        closedOn: day,
        reason: 'x',
        can: owner,
        now: later,
      );
      expect(await repay(id, 10), isA<LoanNotActive>());
    });

    group('adjusted from crop proceeds', () {
      Future<void> crop(int rupees) => db.execute(
        'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, '
        'side, amount_paise, ref_type, created_at) VALUES (uuid(), ?, ?, '
        "'2026-05-01', 'jama', ?, 'arrival', '2026-05-01T06:00:00Z')",
        [t1, farmer, rupees * 100],
      );

      test('a jama repayment plus a balancing journal: the net balance '
          'does not move, the loan does', () async {
        final id = await issue();
        await crop(300000); // khata now +2,00,000 (we owe him)
        final before = await balance(farmer);
        await db.execute('DELETE FROM ps_crud');

        final r = await repay(id, 50000, source: RepaymentSource.cropProceeds);
        expect(r, isA<LoanSaved>());
        expect(await balance(farmer), before);
        final e = (await rows('ledger_entries')).skip(2).toList();
        expect(e.map((x) => '${x['ref_type']}:${x['side']}').toSet(), {
          'loan_repayment:jama',
          'journal:udhaar',
        });
        expect(e.every((x) => x['ref_id'] == id), isTrue);
        expect(await rows('payments'), hasLength(1)); // no money moved
        expect(await rows('cash_bank_entries'), hasLength(1));
        expect(await transactions(), 1);

        final p = (await detail(id)).position(LedgerDate(2026, 5, 10));
        expect(p.principalRecovered.paise + p.interestRecovered.paise, 5000000);
      });

      test('limited to the credit the party has in the khata', () async {
        final id = await issue();
        await crop(60000); // khata +… -1,00,000 + 60,000 = -40,000 (no credit)
        final r = await repay(id, 10, source: RepaymentSource.cropProceeds);
        expect(r, isA<LoanExceedsCrop>());
        expect((r as LoanExceedsCrop).available, Money.zero);
        await crop(100000); // now +60,000 credit
        final tooMuch = await repay(
          id,
          70000,
          source: RepaymentSource.cropProceeds,
        );
        expect(
          (tooMuch as LoanExceedsCrop).available,
          const Money.rupees(60000),
        );
        expect(
          await repay(id, 60000, source: RepaymentSource.cropProceeds),
          isA<LoanSaved>(),
        );
      });

      test('needs payments.create and entries.reverse: accountant yes, '
          'munshi no', () async {
        final id = await issue();
        await crop(300000);
        final no = await repay(
          id,
          1000,
          source: RepaymentSource.cropProceeds,
          can: munshi,
        );
        expect((no as LoanNotPermitted).permission, Permission.entriesReverse);
        expect(
          await repay(
            id,
            1000,
            source: RepaymentSource.cropProceeds,
            can: accountant,
          ),
          isA<LoanSaved>(),
        );
      });
    });

    test('reversing a repayment payment undoes it; the disbursal payment '
        'cannot be reversed from the payments screen', () async {
      final id = await issue();
      await repay(id, 20000);
      final disbursal = (await rows('payments')).first['id']! as String;
      final repayment = (await rows('payments')).last['id']! as String;
      expect(
        await payments.reverse(ctx, disbursal, can: owner, now: later),
        isA<PaymentLocked>(),
      );
      expect(
        await payments.reverse(ctx, repayment, can: owner, now: later),
        isA<PaymentSaved>(),
      );
      final p = (await detail(id)).position(LedgerDate(2026, 5, 10));
      expect(p.principalRecovered, Money.zero);
      expect(p.payable, const Money(10147945));
      expect(await balance(farmer), const Money.rupees(-100000));
    });

    test('a repayment of a closed loan cannot be reversed', () async {
      final id = await issue();
      await repay(id, 1000);
      final repayment = (await rows('payments')).last['id']! as String;
      await repo.writeOff(
        ctx,
        id,
        closedOn: LedgerDate(2026, 5, 10),
        reason: 'x',
        can: owner,
        now: later,
      );
      expect(
        await payments.reverse(ctx, repayment, can: owner, now: later),
        isA<PaymentLocked>(),
      );
    });
  });

  group('rate changes', () {
    test('an effective-dated change splits the slab; audited', () async {
      final id = await issue();
      final r = await repo.changeRate(
        ctx,
        id,
        ratePa: ' 24 ',
        effectiveDate: LedgerDate(2026, 4, 25),
        reason: 'Season ended',
        can: owner,
        now: later,
      );
      expect(r, isA<LoanSaved>());
      final d = await detail(id);
      expect(d.rateChanges.single.ratePa, Decimal.parse('24'));
      expect(d.rateChanges.single.reason, 'Season ended');
      // 15 d at 18% = 739.726; 15 d at 24% = 986.301 -> 1,726.03
      expect(d.position(LedgerDate(2026, 5, 10)).accrued, const Money(172603));
      final audit = (await rows(
        'audit_log',
      )).where((a) => a['table_name'] == 'loan_rate_changes');
      expect(audit, hasLength(1));
    });

    test('owner only; refused before the issue date, with a bad rate and '
        'on a closed loan', () async {
      final id = await issue();
      Future<LoanResult> change(
        String rate,
        LedgerDate on, {
        bool Function(Permission) can = owner,
      }) => repo.changeRate(
        ctx,
        id,
        ratePa: rate,
        effectiveDate: on,
        can: can,
        now: later,
      );
      expect(await change('24', day, can: accountant), isA<LoanNotPermitted>());
      expect(
        ((await change('24', LedgerDate(2026, 4, 9))) as LoanInvalid).problems,
        [LoanProblem.effectiveBeforeIssue],
      );
      expect(((await change('abc', day)) as LoanInvalid).problems, [
        LoanProblem.rateInvalid,
      ]);
      await repo.writeOff(
        ctx,
        id,
        closedOn: day,
        reason: 'x',
        can: owner,
        now: later,
      );
      expect(((await change('24', day)) as LoanInvalid).problems, [
        LoanProblem.notActive,
      ]);
      expect(await rows('loan_rate_changes'), isEmpty);
    });
  });

  group('closing and writing off', () {
    test('close needs nothing left to pay', () async {
      final id = await issue();
      final early = await repo.close(
        ctx,
        id,
        closedOn: LedgerDate(2026, 5, 10),
        can: owner,
        now: later,
      );
      expect((early as LoanInvalid).problems, [LoanProblem.amountStillDue]);

      await repo.repay(
        ctx,
        LoanRepaymentDraft(
          loanId: id,
          date: LedgerDate(2026, 5, 10),
          amount: const Money(10147945),
        ),
        can: owner,
        now: later,
      );
      // Nothing is payable, but the interest is not on the khata yet: a
      // closed loan is no longer offered for posting, so closing is refused.
      final unposted = await repo.close(
        ctx,
        id,
        closedOn: LedgerDate(2026, 5, 10),
        can: owner,
        now: later,
      );
      expect((unposted as LoanInvalid).problems, [
        LoanProblem.interestNotPosted,
      ]);
      final posting = InterestPostingRepository(db);
      final plans = [
        for (final c in await posting.candidates(t1, LedgerDate(2026, 5, 10)))
          c.plan,
      ];
      expect(plans, hasLength(1));
      expect(
        await posting.post(ctx, plans, can: owner, now: later),
        isA<InterestPosted>(),
      );
      final ok = await repo.close(
        ctx,
        id,
        closedOn: LedgerDate(2026, 5, 10),
        reason: 'Paid in full',
        can: owner,
        now: later,
      );
      expect(ok, isA<LoanSaved>());
      final loan = (await detail(id)).loan;
      expect(loan.status, LoanStatus.closed);
      expect(loan.closedOn, LedgerDate(2026, 5, 10));
      expect(loan.closeReason, 'Paid in full');
    });

    test('write-off needs a reason, stops the interest, changes nothing in '
        'the khata', () async {
      final id = await issue();
      final noReason = await repo.writeOff(
        ctx,
        id,
        closedOn: LedgerDate(2026, 5, 10),
        reason: '  ',
        can: owner,
        now: later,
      );
      expect((noReason as LoanInvalid).problems, [LoanProblem.reasonMissing]);
      final entriesBefore = (await rows('ledger_entries')).length;

      final r = await repo.writeOff(
        ctx,
        id,
        closedOn: LedgerDate(2026, 5, 10),
        reason: 'Crop failed, no means to repay',
        can: owner,
        now: later,
      );
      expect(r, isA<LoanSaved>());
      expect((await rows('ledger_entries')).length, entriesBefore);
      final d = await detail(id);
      expect(d.loan.status, LoanStatus.writtenOff);
      expect(d.loan.closeReason, 'Crop failed, no means to repay');
      // Stops on the closing day even when asked about a later day.
      expect(d.position(LedgerDate(2026, 12, 31)).accrued, const Money(147945));
      expect(
        d.position(LedgerDate(2026, 12, 31)).health,
        LoanHealth.writtenOff,
      );
      final audit = (await rows('audit_log')).last;
      expect(audit['table_name'], 'loans');
      expect(audit['action'], 'update');
    });

    test('owner only; a closed loan cannot be closed again; the date cannot '
        'precede the last entry', () async {
      final id = await issue();
      await repay(id, 1000, date: LedgerDate(2026, 4, 20));
      expect(
        await repo.writeOff(
          ctx,
          id,
          closedOn: day,
          reason: 'x',
          can: accountant,
          now: later,
        ),
        isA<LoanNotPermitted>(),
      );
      expect(
        await repo.close(ctx, id, closedOn: day, can: munshi, now: later),
        isA<LoanNotPermitted>(),
      );
      final early = await repo.writeOff(
        ctx,
        id,
        closedOn: LedgerDate(2026, 4, 15),
        reason: 'x',
        can: owner,
        now: later,
      );
      expect((early as LoanInvalid).problems, [
        LoanProblem.closedBeforeLastEntry,
      ]);
      await repo.writeOff(
        ctx,
        id,
        closedOn: LedgerDate(2026, 4, 20),
        reason: 'x',
        can: owner,
        now: later,
      );
      expect(
        await repo.writeOff(
          ctx,
          id,
          closedOn: LedgerDate(2026, 4, 20),
          reason: 'again',
          can: owner,
          now: later,
        ),
        isA<LoanNotActive>(),
      );
    });
  });
}
