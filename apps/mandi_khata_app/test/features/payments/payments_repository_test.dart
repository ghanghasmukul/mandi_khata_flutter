import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
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
const otherTenant = WriteContext(
  tenantId: t2,
  userId: 'user-b',
  deviceId: 'device-b',
  deviceCode: 'W1',
);

const farmer = 'f0000000-0000-4000-8000-000000000001';
const buyer = 'b0000000-0000-4000-8000-000000000001';
const farmerT2 = 'f0000000-0000-4000-8000-000000000002';
const sbi = 'a0000000-0000-4000-8000-000000000001';
const sbiT2 = 'a0000000-0000-4000-8000-000000000002';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);
bool accountant(Permission p) => MemberRole.accountant.allows(p);
bool nobody(Permission _) => false;

final day = LedgerDate(2026, 4, 10);
final now = DateTime.utc(2026, 4, 10, 6);
final String cash = BankAccountsRepository.cashIdFor(t1);

PaymentDraft pay({
  Money amount = const Money.rupees(5000),
  PaymentDirection direction = PaymentDirection.toParty,
  PaymentMode mode = PaymentMode.cash,
  String? partyId,
  String? bank,
  String? chequeNo,
  LedgerDate? chequeDate,
  LedgerDate? date,
}) => PaymentDraft(
  entryDate: date ?? day,
  partyId: partyId ?? farmer,
  direction: direction,
  mode: mode,
  amount: amount,
  bankAccountId: bank,
  chequeNo: chequeNo,
  chequeDate: chequeDate,
  narration: ' advance ',
);

PaymentDraft cheque({Money amount = const Money.rupees(20000)}) => pay(
  amount: amount,
  mode: PaymentMode.cheque,
  bank: sbi,
  chequeNo: '004512',
  chequeDate: day,
);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late PaymentsRepository repo;
  late BankAccountsRepository accounts;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_payments_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = PaymentsRepository(db);
    accounts = BankAccountsRepository(db);
    for (final (id, tenant, name) in [
      (farmer, t1, 'Gurmeet Singh'),
      (buyer, t1, 'Bansal Traders'),
      (farmerT2, t2, 'Other Farmer'),
    ]) {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [id, tenant, 'C-$name', name],
      );
    }
    for (final (id, tenant, kind, name, active) in [
      (cash, t1, 'cash', 'Cash', 1),
      (sbi, t1, 'bank', 'SBI Current', 1),
      (sbiT2, t2, 'bank', 'SBI Two', 1),
      ('a0000000-0000-4000-8000-000000000003', t1, 'bank', 'Old bank', 0),
    ]) {
      await db.execute(
        'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
        'sort_order) VALUES (?, ?, ?, ?, ?, 10)',
        [id, tenant, kind, name, active],
      );
    }
    // Only what the repository writes counts below.
    await db.execute('DELETE FROM ps_crud');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> setting(String key, Object v) => db.execute(
    'INSERT INTO settings (id, tenant_id, scope, scope_id, key, value) '
    "VALUES (uuid(), ?, 'tenant', NULL, ?, ?)",
    [t1, key, jsonEncode(v)],
  );

  Future<Payment> payment(String id, [String tenant = t1]) async =>
      (await repo.watchOne(tenant, id).first)!;

  Future<List<Map<String, Object?>>> entries() => db.getAll(
    'SELECT * FROM ledger_entries ORDER BY created_at, ref_type, side',
  );

  Future<List<Map<String, Object?>>> book() => db.getAll(
    'SELECT * FROM cash_bank_entries ORDER BY created_at, direction',
  );

  Future<List<Map<String, Object?>>> audit() =>
      db.getAll('SELECT * FROM audit_log');

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

  Future<String> save(
    PaymentDraft d, {
    bool Function(Permission) can = owner,
  }) async {
    final r = await repo.save(ctx, d, can: can, now: now);
    expect(r, isA<PaymentSaved>());
    return (r as PaymentSaved).id;
  }

  group('recording', () {
    test('a cash payment: payment, khata entry, book line, 1 upload', () async {
      final id = await save(pay());
      final p = await payment(id);
      expect(p.receiptNo, 'V-W1-0001');
      expect(p.partyName, 'Gurmeet Singh');
      expect(p.amount, const Money.rupees(5000));
      expect(p.mode, PaymentMode.cash);
      expect(p.bankAccountId, cash);
      expect(p.narration, 'advance');
      expect(p.status, PaymentStatus.posted);
      expect(p.chequeStatus, isNull);

      final e = await entries();
      expect(e, hasLength(1));
      expect(e.single['ref_type'], 'payment');
      expect(e.single['ref_id'], id);
      expect(e.single['side'], 'udhaar');
      expect(e.single['amount_paise'], 500000);
      expect(e.single['narration'], 'V-W1-0001');
      expect(e.single['entry_date'], '2026-04-10');

      final b = await book();
      expect(b, hasLength(1));
      expect(b.single['account_id'], cash);
      expect(b.single['account_kind'], 'cash');
      expect(b.single['direction'], 'out');
      expect(b.single['payment_id'], id);

      expect(await balance(farmer), const Money.rupees(-5000));
      expect(await transactions(), 1);
      final tables = (await audit()).map((a) => a['table_name']).toList()
        ..sort();
      expect(tables, [
        'cash_bank_entries',
        'journal_entries',
        'ledger_entries',
        'payments',
      ]);
    });

    test('paying a farmer we owe ₹10,000 ₹4,000 leaves ₹6,000 jama', () async {
      await db.execute(
        'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, '
        "side, amount_paise, ref_type, created_at) VALUES ('seed', ?, ?, "
        "'2026-04-09', 'jama', 1000000, 'arrival', '2026-04-09T06:00:00Z')",
        [t1, farmer],
      );
      await save(pay(amount: const Money.rupees(4000)));
      expect(await balance(farmer), const Money.rupees(6000));
    });

    test('a receipt from a party is jama, money in, and an R number', () async {
      final id = await save(pay(direction: PaymentDirection.fromParty));
      expect((await payment(id)).receiptNo, 'R-W1-0001');
      final e = (await entries()).single;
      expect(e['ref_type'], 'receipt');
      expect(e['side'], 'jama');
      expect((await book()).single['direction'], 'in');
      expect(await balance(farmer), const Money.rupees(5000));
    });

    test('numbers follow on per series', () async {
      await save(pay());
      await save(pay());
      await save(pay(direction: PaymentDirection.fromParty));
      final nos = (await repo.watchAll(t1, const PaymentFilter()).first)
          .map((p) => p.receiptNo)
          .toSet();
      expect(nos, {'V-W1-0001', 'V-W1-0002', 'R-W1-0001'});
      expect(
        await repo.previewNextNo(ctx, PaymentDirection.toParty),
        'V-W1-0003',
      );
    });

    test('a bank payment uses the bank account and its own book', () async {
      final id = await save(
        pay(mode: PaymentMode.bank, bank: sbi),
        can: accountant,
      );
      final p = await payment(id);
      expect(p.bankAccountId, sbi);
      expect(p.accountName, 'SBI Current');
      final line = (await book()).single;
      expect(line['account_id'], sbi);
      expect(line['account_kind'], 'bank');
    });

    test('a pending cheque posts at once', () async {
      final id = await save(cheque(), can: accountant);
      final p = await payment(id);
      expect(p.chequeNo, '004512');
      expect(p.chequeStatus, ChequeStatus.pending);
      expect(p.isPendingCheque, isTrue);
      expect(await balance(farmer), const Money.rupees(-20000));
    });

    test('problems are returned and nothing is written', () async {
      for (final (d, problem) in [
        (pay(amount: Money.zero), PaymentProblem.amountNotPositive),
        (pay(mode: PaymentMode.upi), PaymentProblem.bankAccountMissing),
        (
          pay(mode: PaymentMode.cheque, bank: sbi, chequeDate: day),
          PaymentProblem.chequeNoMissing,
        ),
      ]) {
        final r = await repo.save(ctx, d, can: owner, now: now);
        expect(r, isA<PaymentInvalid>());
        expect((r as PaymentInvalid).problems, contains(problem));
      }
      expect(await entries(), isEmpty);
      expect(await book(), isEmpty);
      expect(await audit(), isEmpty);
      expect(await transactions(), 0);
    });

    test('party and bank account must be in this business', () async {
      for (final d in [
        pay(partyId: farmerT2),
        pay(partyId: 'missing'),
        pay(mode: PaymentMode.bank, bank: sbiT2),
        pay(
          mode: PaymentMode.bank,
          bank: 'a0000000-0000-4000-8000-000000000003',
        ),
        pay(mode: PaymentMode.bank, bank: cash),
      ]) {
        expect(
          await repo.save(ctx, d, can: owner, now: now),
          isA<PaymentNotFound>(),
        );
      }
      expect(await entries(), isEmpty);
    });

    test('a deleted party takes no payments', () async {
      await db.execute(
        "UPDATE parties SET deleted_at = '2026-04-01T00:00:00Z' WHERE id = ?",
        [farmer],
      );
      expect(
        await repo.save(ctx, pay(), can: owner, now: now),
        isA<PaymentNotFound>(),
      );
    });
  });

  group('permissions', () {
    test('payments need payments.create', () async {
      final r = await repo.save(ctx, pay(), can: nobody, now: now);
      expect(r, isA<PaymentNotPermitted>());
      expect((r as PaymentNotPermitted).permission, Permission.paymentsCreate);
      expect(await entries(), isEmpty);
    });

    test(
      'a munshi pays in cash only: bank, UPI and cheque need finance.view',
      () async {
        for (final d in [
          pay(mode: PaymentMode.bank, bank: sbi),
          pay(mode: PaymentMode.upi, bank: sbi),
          cheque(),
        ]) {
          final r = await repo.save(ctx, d, can: munshi, now: now);
          expect((r as PaymentNotPermitted).permission, Permission.financeView);
        }
        await save(pay(), can: munshi);
      },
    );

    test('the limit: at it is fine, above needs entries.reverse', () async {
      await setting('business.munshi_payment_limit', 500000);
      await save(pay(), can: munshi);
      final r = await repo.save(
        ctx,
        pay(amount: const Money(500001)),
        can: munshi,
        now: now,
      );
      expect(r, isA<PaymentNotPermitted>());
      final denied = r as PaymentNotPermitted;
      expect(denied.permission, Permission.entriesReverse);
      expect(denied.limit, const Money.rupees(5000));
      expect(await entries(), hasLength(1));

      await save(pay(amount: const Money(500001)), can: accountant);
    });

    test('receipts are never limited', () async {
      await setting('business.munshi_payment_limit', 500000);
      await save(
        pay(
          direction: PaymentDirection.fromParty,
          amount: const Money.rupees(900000),
        ),
        can: munshi,
      );
    });

    test('limit 0 (the default) means no limit', () async {
      await save(pay(amount: const Money.rupees(9000000)), can: munshi);
    });

    test('a munshi cannot back-date past the window', () async {
      final r = await repo.save(
        ctx,
        pay(date: day.addDays(-4)),
        can: munshi,
        now: now,
      );
      final denied = r as PaymentNotPermitted;
      expect(denied.permission, Permission.entriesReverse);
      expect(denied.backdateDays, 3);
      await save(pay(date: day.addDays(-3)), can: munshi);
      await save(pay(date: day.addDays(-30)), can: accountant);
    });
  });

  group('reversing', () {
    test('mirrors the khata entry and the book line', () async {
      final id = await save(pay());
      final r = await repo.reverse(ctx, id, can: owner, now: now);
      expect(r, isA<PaymentSaved>());

      final p = await payment(id);
      expect(p.isReversed, isTrue);
      expect(p.reversedAt, isNotNull);
      expect(p.chequeStatus, isNull);

      final e = await entries();
      expect(e, hasLength(2));
      final reversal = e.firstWhere((r) => r['ref_type'] == 'reversal');
      expect(reversal['side'], 'jama');
      expect(reversal['reverses_id'], e.first['id']);
      expect(reversal['entry_date'], '2026-04-10');
      expect(await balance(farmer), Money.zero);

      final b = await book();
      expect(b, hasLength(2));
      final line = b.firstWhere((r) => r['reverses_id'] != null);
      expect(line['direction'], 'in');
      expect(line['amount_paise'], 500000);
      expect(line['account_id'], cash);
      expect(await transactions(), 2);
    });

    test('only once, and only with entries.reverse', () async {
      final id = await save(pay());
      expect(
        (await repo.reverse(ctx, id, can: munshi, now: now))
            as PaymentNotPermitted,
        isA<PaymentNotPermitted>(),
      );
      await repo.reverse(ctx, id, can: owner, now: now);
      expect(
        await repo.reverse(ctx, id, can: owner, now: now),
        isA<PaymentLocked>(),
      );
      expect(await entries(), hasLength(2));
      expect(
        await repo.reverse(ctx, 'missing', can: owner, now: now),
        isA<PaymentNotFound>(),
      );
    });
  });

  group('cheques', () {
    test('a pending cheque clears; then it is final', () async {
      final id = await save(cheque(), can: accountant);
      final r = await repo.setChequeStatus(
        ctx,
        id,
        ChequeStatus.cleared,
        can: munshi,
        now: now,
      );
      expect(r, isA<PaymentSaved>());
      expect((await payment(id)).chequeStatus, ChequeStatus.cleared);
      // Clearing changes no money.
      expect(await entries(), hasLength(1));
      expect(await book(), hasLength(1));
      for (final to in ChequeStatus.values) {
        expect(
          await repo.setChequeStatus(ctx, id, to, can: owner, now: now),
          isA<PaymentLocked>(),
        );
      }
    });

    test('a bounce reverses the khata entry and the book line, dated the '
        'bounce', () async {
      final id = await save(cheque(), can: accountant);
      final bounce = day.addDays(3);
      final r = await repo.setChequeStatus(
        ctx,
        id,
        ChequeStatus.bounced,
        can: accountant,
        bounceDate: bounce,
        now: now,
      );
      expect(r, isA<PaymentSaved>());

      final p = await payment(id);
      expect(p.chequeStatus, ChequeStatus.bounced);
      expect(p.isReversed, isTrue);
      final reversal = (await entries()).firstWhere(
        (e) => e['ref_type'] == 'reversal',
      );
      expect(reversal['entry_date'], bounce.toString());
      expect(reversal['side'], 'jama');
      expect(await balance(farmer), Money.zero);
      final line = (await book()).firstWhere((l) => l['reverses_id'] != null);
      expect(line['entry_date'], bounce.toString());
      expect(line['direction'], 'in');
      expect(line['account_kind'], 'bank');

      final a = (await audit()).where((r) => r['action'] == 'reverse');
      expect(a.map((r) => r['table_name']).toSet(), {
        'payments',
        'ledger_entries',
        'cash_bank_entries',
        'journal_entries',
      });
    });

    test(
      'a bounce needs entries.reverse; a cleared cheque cannot bounce',
      () async {
        final id = await save(cheque(), can: accountant);
        final r = await repo.setChequeStatus(
          ctx,
          id,
          ChequeStatus.bounced,
          can: munshi,
          now: now,
        );
        expect(
          (r as PaymentNotPermitted).permission,
          Permission.entriesReverse,
        );
        expect((await payment(id)).chequeStatus, ChequeStatus.pending);

        await repo.setChequeStatus(
          ctx,
          id,
          ChequeStatus.cleared,
          can: owner,
          now: now,
        );
        expect(
          await repo.setChequeStatus(
            ctx,
            id,
            ChequeStatus.bounced,
            can: owner,
            now: now,
          ),
          isA<PaymentLocked>(),
        );
        expect(await entries(), hasLength(1));
      },
    );

    test('a pending cheque cannot be put back to pending', () async {
      final id = await save(cheque(), can: accountant);
      expect(
        await repo.setChequeStatus(
          ctx,
          id,
          ChequeStatus.pending,
          can: owner,
          now: now,
        ),
        isA<PaymentLocked>(),
      );
    });
  });

  group('list and tenants', () {
    test('filters, search, totals and pending cheques', () async {
      await save(pay(amount: const Money.rupees(1000)));
      await save(
        pay(
          partyId: buyer,
          direction: PaymentDirection.fromParty,
          amount: const Money.rupees(2500),
          date: day.addDays(1),
        ),
      );
      final chequeId = await save(cheque(), can: accountant);
      Future<List<Payment>> list(PaymentFilter f) => repo.watchAll(t1, f).first;

      expect(await list(const PaymentFilter()), hasLength(3));
      expect(await list(PaymentFilter(from: day.addDays(1))), hasLength(1));
      expect(
        await list(const PaymentFilter(direction: PaymentDirection.fromParty)),
        hasLength(1),
      );
      expect(
        await list(const PaymentFilter(mode: PaymentMode.cheque)),
        hasLength(1),
      );
      expect(await list(const PaymentFilter(partyId: buyer)), hasLength(1));
      expect(await list(const PaymentFilter(query: 'bansal')), hasLength(1));
      expect(await list(const PaymentFilter(query: '004512')), hasLength(1));
      expect(await list(const PaymentFilter(query: 'R-W1')), hasLength(1));
      expect(
        await list(const PaymentFilter(pendingChequesOnly: true)),
        hasLength(1),
      );
      final totals = PaymentTotals.of(await list(const PaymentFilter()));
      expect(totals.count, 3);
      expect(totals.paid, const Money.rupees(21000));
      expect(totals.received, const Money.rupees(2500));

      await repo.reverse(ctx, chequeId, can: owner, now: now);
      expect(
        await list(const PaymentFilter(pendingChequesOnly: true)),
        isEmpty,
      );
      expect(
        PaymentTotals.of(await list(const PaymentFilter())).paid,
        const Money.rupees(1000),
      );
    });

    test('another business sees none of these payments', () async {
      final id = await save(pay());
      expect(await repo.watchAll(t2, const PaymentFilter()).first, isEmpty);
      expect(await repo.watchOne(t2, id).first, isNull);
      expect(
        await repo.reverse(otherTenant, id, can: owner, now: now),
        isA<PaymentNotFound>(),
      );
      expect(
        await repo.setChequeStatus(
          otherTenant,
          id,
          ChequeStatus.cleared,
          can: owner,
          now: now,
        ),
        isA<PaymentNotFound>(),
      );
    });
  });

  group('bank accounts', () {
    test('create, edit, switch off; Cash is fixed', () async {
      final r = await accounts.create(
        ctx,
        const BankAccountInput(
          name: ' HDFC Savings ',
          bankName: 'HDFC Bank',
          last4: '1234',
          ifsc: 'hdfc0001234',
        ),
        can: accountant,
        now: now,
      );
      final id = (r as BankAccountSaved).id;
      var list = await accounts.watchAll(t1).first;
      expect(list.first.isCash, isTrue);
      final hdfc = list.firstWhere((a) => a.id == id);
      expect(hdfc.name, 'HDFC Savings');
      expect(hdfc.ifsc, 'HDFC0001234');
      expect(hdfc.label, 'HDFC Savings · ••1234');
      // The inactive account is hidden.
      expect(list.map((a) => a.name), isNot(contains('Old bank')));
      expect(
        (await accounts.watchAll(t1, includeInactive: true).first).map(
          (a) => a.name,
        ),
        contains('Old bank'),
      );

      await accounts.update(
        ctx,
        id,
        const BankAccountInput(name: 'HDFC Current', last4: '1234'),
        can: owner,
        now: now,
      );
      list = await accounts.watchAll(t1).first;
      expect(list.firstWhere((a) => a.id == id).name, 'HDFC Current');
      expect(list.firstWhere((a) => a.id == id).bankName, isNull);

      await accounts.setActive(ctx, id, active: false, can: owner, now: now);
      expect(
        (await accounts.watchAll(t1).first).map((a) => a.id),
        isNot(contains(id)),
      );

      expect(
        await accounts.update(
          ctx,
          cash,
          const BankAccountInput(name: 'Till'),
          can: owner,
        ),
        isA<BankAccountNotPermitted>(),
      );
      expect(
        await accounts.setActive(ctx, cash, active: false, can: owner),
        isA<BankAccountNotPermitted>(),
      );
      final a = (await audit()).map((r) => r['table_name']).toSet();
      expect(a, {'bank_accounts'});
    });

    test('a munshi cannot add accounts; bad input is refused', () async {
      expect(
        await accounts.create(
          ctx,
          const BankAccountInput(name: 'X'),
          can: munshi,
        ),
        isA<BankAccountNotPermitted>(),
      );
      final r = await accounts.create(
        ctx,
        const BankAccountInput(name: ' ', last4: '12', ifsc: 'bad'),
        can: owner,
      );
      expect((r as BankAccountInvalid).problems, {
        BankAccountProblem.nameMissing,
        BankAccountProblem.last4Invalid,
        BankAccountProblem.ifscInvalid,
      });
      expect(
        await accounts.update(
          ctx,
          'missing',
          const BankAccountInput(name: 'X'),
          can: owner,
        ),
        isA<BankAccountNotFound>(),
      );
    });

    test('book balances: money in − out, per account', () async {
      await save(pay(direction: PaymentDirection.fromParty));
      await save(pay(amount: const Money.rupees(1200)));
      await save(
        pay(mode: PaymentMode.bank, bank: sbi, amount: const Money.rupees(300)),
        can: accountant,
      );
      final balances = await accounts.watchBalances(t1).first;
      expect(balances[cash], const Money.rupees(3800));
      expect(balances[sbi], const Money.rupees(-300));
      expect(await accounts.watchBalances(t2).first, isEmpty);
    });
  });
}
