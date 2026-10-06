import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/accounts/data/books_invariants.dart';
import 'package:mandi_khata_app/features/accounts/data/cash_book_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/cash_count_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/reconciliation_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/voucher_repository.dart';
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
const farmer = 'f0000000-0000-4000-8000-000000000001';
const sbi = 'a0000000-0000-4000-8000-000000000001';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

final d1 = LedgerDate(2027, 4, 1);
final d2 = LedgerDate(2027, 4, 2);
final d3 = LedgerDate(2027, 4, 3);
final now = DateTime.utc(2027, 4, 3, 6);
final String cash = BankAccountsRepository.cashIdFor(t1);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late PaymentsRepository payments;
  late CashBookRepository books;
  late ReconciliationRepository recon;
  late CashCountRepository counts;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_bank_books_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    payments = PaymentsRepository(db);
    books = CashBookRepository(db);
    recon = ReconciliationRepository(db);
    counts = CashCountRepository(db, VoucherRepository(db));
    await db.execute(
      'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
      [farmer, t1, 'P-1', 'Gurmeet Singh'],
    );
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
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<String> pay(
    LedgerDate date,
    PaymentDirection direction,
    PaymentMode mode,
    int rupees, {
    String? reference,
  }) async {
    final r = await payments.save(
      ctx,
      PaymentDraft(
        partyId: farmer,
        direction: direction,
        mode: mode,
        amount: Money.rupees(rupees),
        entryDate: date,
        bankAccountId: mode == PaymentMode.cash ? null : sbi,
        reference: reference,
      ),
      can: owner,
      now: now,
    );
    return (r as PaymentSaved).id;
  }

  group('cash / bank book', () {
    test(
      'opening, receipts, payments, closing; lines say what they are',
      () async {
        await pay(d1, PaymentDirection.fromParty, PaymentMode.cash, 10000);
        await pay(d2, PaymentDirection.toParty, PaymentMode.cash, 2500);
        await pay(d3, PaymentDirection.fromParty, PaymentMode.cash, 700);
        final book = await books.watch(t1, cash, from: d2, to: d3).first;
        expect(book.opening, const Money.rupees(10000));
        expect(book.receipts, const Money.rupees(700));
        expect(book.payments, const Money.rupees(2500));
        expect(book.closing, const Money.rupees(8200));
        expect(book.days.first.lines.single.text, 'V-W1-0001 · Gurmeet Singh');
        // Another business sees an empty book.
        final other = await books.watch(t2, cash).first;
        expect(other.days, isEmpty);
      },
    );
  });

  group('reconciliation', () {
    const mapping = StatementMapping(
      date: 0,
      dateFormat: StatementDateFormat.dmy,
      description: 1,
      reference: 2,
      debit: 3,
      credit: 4,
    );
    final sheet = DelimitedText.parse(
      'Date,Narration,Ref,Withdrawal,Deposit\n'
      '02/04/2027,NEFT GURMEET,UTR123456,,25000.00\n'
      '04/04/2027,CHQ PAID,,"1,000.00",\n'
      '05/04/2027,BANK CHARGES,,59.00,\n',
    );

    test('import saves the mapping and never adds a line twice', () async {
      final first = await recon.import(ctx, sbi, sheet, mapping, now: now);
      expect(first.added, 3);
      expect(first.duplicates, 0);
      final again = await recon.import(ctx, sbi, sheet, mapping, now: now);
      expect(again.added, 0);
      expect(again.duplicates, 3);
      expect((await recon.mapping(t1, sbi))!.toJson(), mapping.toJson());
      final row = await db.get(
        'SELECT statement_mapping FROM bank_accounts WHERE id = ?',
        [sbi],
      );
      expect(
        jsonDecode(row['statement_mapping']! as String),
        isA<Map<String, Object?>>(),
      );
      // A cash account has no statement.
      expect((await recon.import(ctx, cash, sheet, mapping)).added, 0);
    });

    test('auto-match, manual match, without statement, undo', () async {
      await pay(
        d1,
        PaymentDirection.fromParty,
        PaymentMode.bank,
        25000,
        reference: 'UTR123456',
      );
      await pay(d3, PaymentDirection.toParty, PaymentMode.bank, 1000);
      final odd = await pay(d3, PaymentDirection.toParty, PaymentMode.bank, 5);
      await recon.import(ctx, sbi, sheet, mapping, now: now);

      expect(await recon.autoMatch(ctx, sbi, now: now), 2);
      var s = await recon.watch(t1, sbi).first;
      expect(s.reconciled, hasLength(2));
      expect(s.reconciled.map((r) => r.on).toSet(), {
        d2,
        LedgerDate(2027, 4, 4),
      });
      expect(s.statement.single.description, 'BANK CHARGES');
      expect(s.book.single.amount, const Money.rupees(5));

      // Different amounts never match by hand.
      expect(
        await recon.match(ctx, sbi, s.book.single.id, s.statement.single.id),
        isFalse,
      );
      expect(
        await recon.reconcileWithoutStatement(ctx, sbi, [s.book.single.id], d3),
        isTrue,
      );
      s = await recon.watch(t1, sbi).first;
      expect(s.book, isEmpty);
      final undo = s.reconciled.firstWhere((r) => r.statement == null);
      await recon.undo(ctx, undo.id, now: now);
      s = await recon.watch(t1, sbi).first;
      expect(s.book.single.amount, const Money.rupees(5));
      expect(odd, isNotEmpty);

      // Every write is audited; another business sees nothing.
      expect(
        (await db.get(
          'SELECT COUNT(*) AS n FROM audit_log '
          "WHERE table_name = 'bank_reconciliations'",
        ))['n'],
        4,
      );
      final other = await ReconciliationRepository(db).watch(t2, sbi).first;
      expect(other.book, isEmpty);
      expect(other.statement, isEmpty);
    });

    test(
      'a reversed payment and its reversal are left out of the alert',
      () async {
        final id = await pay(d1, PaymentDirection.toParty, PaymentMode.bank, 9);
        await payments.reverse(ctx, id, can: owner, now: now);
        await pay(d1, PaymentDirection.toParty, PaymentMode.bank, 8);
        final today = LedgerDate(2027, 4, 20);
        expect(await recon.watchStale(t1, today: today).first, 1);
        expect(await recon.watchStale(t1, today: d3).first, 0);
      },
    );
  });

  group('cash count', () {
    test('excess posts a journal voucher and the books still tally', () async {
      await pay(d1, PaymentDirection.fromParty, PaymentMode.cash, 1000);
      final r = await counts.save(
        ctx,
        d3,
        CashCount(const {500: 2}, loose: const Money(5000)),
        can: owner,
        postDifference: true,
        note: 'evening',
        now: now,
      );
      expect(r, isA<CashCountSaved>());
      expect((r as CashCountSaved).voucherNo, 'JV-W1-0001');
      final row = (await counts.watch(t1).first).single;
      expect(row.book, const Money.rupees(1000));
      expect(row.counted, const Money.rupees(1050));
      expect(row.difference, const Money.rupees(50));
      expect(row.voucherId, isNotNull);
      expect(await counts.bookBalance(t1, d3), const Money.rupees(1050));
      final invariants = BooksInvariants(db);
      expect(await invariants.bookDifferences(t1), isEmpty);
      expect(await invariants.unbalancedEntries(t1), isEmpty);
    });

    test('a munshi counts but cannot post the difference', () async {
      expect(
        await counts.save(
          ctx,
          d3,
          CashCount(const {100: 1}),
          can: munshi,
          postDifference: true,
        ),
        isA<CashCountNotPermitted>(),
      );
      final r = await counts.save(
        ctx,
        d3,
        CashCount(const {100: 1}),
        can: munshi,
        postDifference: false,
      );
      expect(r, isA<CashCountSaved>());
      expect((r as CashCountSaved).voucherNo, isNull);
      expect((await db.get('SELECT COUNT(*) AS n FROM vouchers'))['n'], 0);
    });

    test('nothing is posted when the count matches', () async {
      await pay(d1, PaymentDirection.fromParty, PaymentMode.cash, 100);
      final r = await counts.save(
        ctx,
        d3,
        CashCount(const {100: 1}),
        can: owner,
        postDifference: true,
      );
      expect((r as CashCountSaved).voucherNo, isNull);
    });
  });
}
