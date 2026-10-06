import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/books_invariants.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_backfill.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/arrivals/data/lots_repository.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/crops/data/crops_repository.dart';
import 'package:mandi_khata_app/features/interest/data/interest_posting_repository.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/loans/data/loans_repository.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const farmer = 'f0000000-0000-4000-8000-000000000001';
const buyer = 'b0000000-0000-4000-8000-000000000001';
const sbi = 'a0000000-0000-4000-8000-000000000001';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

final day = LedgerDate(2027, 4, 11);
final now = DateTime.utc(2027, 4, 11, 6);
final String cash = BankAccountsRepository.cashIdFor(t1);
final String wheat = CropsRepository.idFor(t1, 'wheat');

/// The journal as plain data: source key, date, and the lines as
/// `account key: debit/credit`, order-independent.
typedef Shape = ({String key, String date, List<String> lines});

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late LotsRepository lots;
  late PaymentsRepository payments;
  late LoansRepository loans;
  late LedgerRepository ledger;
  late InterestPostingRepository interest;
  late BooksInvariants books;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_journal_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    lots = LotsRepository(db);
    payments = PaymentsRepository(db);
    loans = LoansRepository(db, payments);
    ledger = LedgerRepository(db);
    interest = InterestPostingRepository(db);
    books = BooksInvariants(db);
    for (final (id, name) in [(farmer, 'Gurmeet Singh'), (buyer, 'Bansal')]) {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [id, t1, 'C-$name', name],
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
    await db.execute(
      'INSERT INTO crops (id, tenant_id, code, name_en, unit, sort_order, '
      "is_active) VALUES (?, ?, 'wheat', 'wheat', 'qtl', 10, 1)",
      [wheat, t1],
    );
    await SettingsRepository(db).write(
      ctx,
      scope: SettingScope.tenant,
      key: 'interest.rounding',
      value: 'paise',
      can: owner,
      now: DateTime.utc(2027),
    );
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  // -- helpers ---------------------------------------------------------------

  Future<List<Shape>> journal() async {
    final entries = await db.getAll(
      'SELECT * FROM journal_entries ORDER BY source_key',
    );
    final out = <Shape>[];
    for (final e in entries) {
      final lines = await db.getAll(
        'SELECT * FROM journal_lines WHERE journal_entry_id = ?',
        [e['id']],
      );
      out.add((
        key: e['source_key']! as String,
        date: e['entry_date']! as String,
        lines: [
          for (final l in lines)
            '${l['account_id']}:${l['debit_paise']}/${l['credit_paise']}',
        ]..sort(),
      ));
    }
    return out;
  }

  String acct(JournalAccount a) => JournalWriter.accountId(t1, a);
  String sys(SystemAccount a) => acct(SystemJournalAccount(a));

  /// Σ debit − Σ credit on [a], over every journal line.
  Future<int> net(JournalAccount a) async =>
      (await db.get(
            'SELECT COALESCE(SUM(debit_paise - credit_paise), 0) AS n '
            'FROM journal_lines WHERE account_id = ?',
            [acct(a)],
          ))['n']!
          as int;

  Future<void> expectBooksTally() async {
    expect(await books.unbalancedEntries(t1), isEmpty);
    expect(
      [for (final d in await books.partyDifferences(t1)) d.name],
      isEmpty,
      reason: 'party accounts mirror the khata',
    );
    expect(
      [for (final d in await books.bookDifferences(t1)) d.name],
      isEmpty,
      reason: 'cash / bank accounts mirror the cash / bank book',
    );
    // Double entry: everything nets to zero.
    final all = await db.get(
      'SELECT COALESCE(SUM(debit_paise - credit_paise), 0) AS n '
      'FROM journal_lines',
    );
    expect(all['n'], 0);
  }

  Future<String> postLot({String? buyerId, int? bags}) async {
    final r = await lots.save(
      ctx,
      LotDraft(
        entryDate: day,
        farmerId: farmer,
        cropId: wheat,
        bags: bags ?? 18,
        qtlMilli: 8640,
        rate: const Money.rupees(2425),
        buyerId: buyerId,
      ),
      can: owner,
      now: now,
    );
    expect(r, isA<LotSaved>());
    return (r as LotSaved).id;
  }

  Future<String> pay({
    PaymentDirection direction = PaymentDirection.toParty,
    PaymentMode mode = PaymentMode.cash,
    String? bank,
    int rupees = 5000,
    String? party,
  }) async {
    final r = await payments.save(
      ctx,
      PaymentDraft(
        entryDate: day,
        partyId: party ?? farmer,
        direction: direction,
        mode: mode,
        amount: Money.rupees(rupees),
        bankAccountId: bank,
        chequeNo: mode == PaymentMode.cheque ? '0045' : null,
        chequeDate: mode == PaymentMode.cheque ? day : null,
      ),
      can: owner,
      now: now,
    );
    expect(r, isA<PaymentSaved>());
    return (r as PaymentSaved).id;
  }

  // -- lots ------------------------------------------------------------------

  group('lot', () {
    test(
      'posting writes the worked-example entry and the books tally',
      () async {
        final id = await postLot(buyerId: buyer);
        final j = (await journal()).single;
        expect(j.key, 'lot:$id');
        expect(j.date, '2027-04-11');
        expect(
          j.lines,
          unorderedEquals([
            '${acct(const PartyAccount(buyer))}:2095200/0',
            '${acct(const PartyAccount(farmer))}:0/1983276',
            '${sys(SystemAccount.commissionIncome)}:0/52380',
            '${sys(SystemAccount.palledariReceipts)}:0/21600',
            '${sys(SystemAccount.bardanaReceipts)}:0/14400',
            '${sys(SystemAccount.tulaiReceipts)}:0/2592',
            '${sys(SystemAccount.mandiFeePayable)}:0/20952',
          ]),
        );
        await expectBooksTally();
      },
    );

    test('a lot with no buyer is debited to Lot Sale Clearing', () async {
      await postLot();
      expect(await net(const PartyAccount(farmer)), -1983276);
      expect(
        await net(const SystemJournalAccount(SystemAccount.lotSaleClearing)),
        2095200,
      );
      await expectBooksTally();
    });

    test(
      'reversing the lot mirrors its journal entry, dated like the lot',
      () async {
        final id = await postLot(buyerId: buyer);
        await lots.reverse(ctx, id, can: owner, now: now);
        final entries = await journal();
        expect(entries.map((e) => e.key), ['lot:$id', 'reversal:lot:$id']);
        expect(entries.last.date, '2027-04-11');
        // Every account nets to nothing again.
        for (final a in [
          const PartyAccount(farmer),
          const PartyAccount(buyer),
          const SystemJournalAccount(SystemAccount.commissionIncome),
        ]) {
          expect(await net(a), 0);
        }
        await expectBooksTally();
      },
    );
  });

  // -- payments and loans ---------------------------------------------------

  group('payments', () {
    test('cash out, bank in: party against the right book account', () async {
      await pay();
      await pay(
        direction: PaymentDirection.fromParty,
        mode: PaymentMode.bank,
        bank: sbi,
        rupees: 1200,
      );
      expect(await net(const PartyAccount(farmer)), 500000 - 120000);
      expect(await net(const BookAccount(sbi)), 120000);
      expect(await net(BookAccount(cash)), -500000);
      await expectBooksTally();
    });

    test('reversing a payment mirrors it', () async {
      final id = await pay();
      await payments.reverse(ctx, id, can: owner, now: now);
      expect((await journal()).map((e) => e.key), [
        'payment:$id',
        'reversal:payment:$id',
      ]);
      expect(await net(const PartyAccount(farmer)), 0);
      await expectBooksTally();
    });

    test('a bounced cheque reverses the journal on the bounce date', () async {
      final id = await pay(mode: PaymentMode.cheque, bank: sbi);
      final bounce = LedgerDate(2027, 4, 13);
      await payments.setChequeStatus(
        ctx,
        id,
        ChequeStatus.bounced,
        can: owner,
        bounceDate: bounce,
        now: DateTime.utc(2027, 4, 13, 6),
      );
      final reversal = (await journal()).last;
      expect(reversal.key, 'reversal:payment:$id');
      expect(reversal.date, '2027-04-13');
      await expectBooksTally();
    });

    test('a cleared cheque writes nothing new', () async {
      final id = await pay(mode: PaymentMode.cheque, bank: sbi);
      await payments.setChequeStatus(
        ctx,
        id,
        ChequeStatus.cleared,
        can: owner,
        now: now,
      );
      expect(await journal(), hasLength(1));
    });
  });

  group('loans', () {
    LoanDraft draft() => LoanDraft(
      partyId: farmer,
      amount: const Money.rupees(50000),
      issueDate: day,
      config: InterestConfig(
        ratePa: Decimal.parse('18'),
        rounding: InterestRounding.paise,
      ),
      mode: PaymentMode.bank,
      bankAccountId: sbi,
    );

    test('disbursal and a cash repayment are payments; crop proceeds write '
        'no journal entry', () async {
      final r = await loans.issue(ctx, draft(), can: owner, now: now);
      final loanId = (r as LoanSaved).id;
      // Crop credit to adjust against.
      await ledger.append(
        ctx,
        LedgerDraft(
          partyId: farmer,
          side: Side.jama,
          amount: const Money.rupees(20000),
          refType: RefType.journal,
          entryDate: day,
        ),
        can: owner,
        now: now,
      );
      final before = (await journal()).length;
      await loans.repay(
        ctx,
        LoanRepaymentDraft(
          loanId: loanId,
          date: day,
          amount: const Money.rupees(10000),
          source: RepaymentSource.cropProceeds,
        ),
        can: owner,
        now: now,
      );
      expect(await journal(), hasLength(before));
      await loans.repay(
        ctx,
        LoanRepaymentDraft(
          loanId: loanId,
          date: day,
          amount: const Money.rupees(5000),
        ),
        can: owner,
        now: now,
      );
      expect(await journal(), hasLength(before + 1));
      expect(await net(const PartyAccount(farmer)), 5000000 - 2000000 - 500000);
      await expectBooksTally();
    });
  });

  // -- interest, waiver, manual entries, opening balances -------------------

  group('interest and manual entries', () {
    test('interest posting and its waiver; reversing the interest entry '
        'mirrors the journal', () async {
      await ledger.append(
        ctx,
        LedgerDraft(
          partyId: farmer,
          side: Side.udhaar,
          amount: const Money.rupees(100000),
          refType: RefType.journal,
          entryDate: LedgerDate(2027, 1, 1),
        ),
        can: owner,
        now: DateTime.utc(2027, 1, 1, 6),
      );
      final asOf = LedgerDate(2027, 4, 11);
      final r = await interest.settle(
        ctx,
        farmer,
        asOf,
        can: owner,
        waivers: {SettlementSource.khataKey: 93151},
        reason: 'Diwali',
        now: now,
      );
      expect(r, isA<SettlementDone>());
      expect(await net(const PartyAccount(farmer)), 10000000 + 493151 - 93151);
      expect(
        await net(const SystemJournalAccount(SystemAccount.interestIncome)),
        -493151,
      );
      expect(
        await net(const SystemJournalAccount(SystemAccount.interestWaived)),
        93151,
      );
      await expectBooksTally();

      final entry = await db.get(
        "SELECT id FROM ledger_entries WHERE ref_type = 'interest'",
      );
      await ledger.reverse(ctx, entry['id']! as String, can: owner, now: now);
      expect(
        await net(const SystemJournalAccount(SystemAccount.interestIncome)),
        0,
      );
      await expectBooksTally();
    });

    test('a manual entry is journalled against Khata Adjustments and an edit '
        'reverses it and posts the replacement', () async {
      final r = await ledger.append(
        ctx,
        LedgerDraft(
          partyId: farmer,
          side: Side.udhaar,
          amount: const Money.rupees(700),
          refType: RefType.journal,
          entryDate: day,
        ),
        can: owner,
        now: now,
      );
      final id = (r as LedgerPosted).entries.single.id;
      expect(
        await net(const SystemJournalAccount(SystemAccount.khataAdjustments)),
        -70000,
      );
      await ledger.correct(
        ctx,
        id,
        can: owner,
        amount: const Money.rupees(900),
        now: now,
      );
      expect(await net(const PartyAccount(farmer)), 90000);
      expect(
        await net(const SystemJournalAccount(SystemAccount.khataAdjustments)),
        -90000,
      );
      await expectBooksTally();
    });

    test(
      'an opening balance is journalled against Opening Balance Equity',
      () async {
        await db.writeTransaction((tx) async {
          await LedgerRepository.post(
            tx,
            ctx,
            LedgerDraft(
              partyId: farmer,
              side: Side.jama,
              amount: const Money.rupees(2500),
              refType: RefType.openingBalance,
              entryDate: day,
            ),
            now: now,
          );
        });
        expect(await net(const PartyAccount(farmer)), -250000);
        expect(
          await net(
            const SystemJournalAccount(SystemAccount.openingBalanceEquity),
          ),
          250000,
        );
        await expectBooksTally();
      },
    );

    test('every journal write has an audit row', () async {
      await postLot(buyerId: buyer);
      await pay();
      final audited = await db.getAll(
        "SELECT row_id FROM audit_log WHERE table_name = 'journal_entries'",
      );
      final entries = await db.getAll('SELECT id FROM journal_entries');
      expect(
        audited.map((a) => a['row_id']).toSet(),
        entries.map((e) => e['id']).toSet(),
      );
    });
  });

  // -- back-fill -------------------------------------------------------------

  group('back-fill', () {
    test(
      'rebuilds the same journal from documents that have none, once',
      () async {
        // A busy day: lots (one reversed), payments (one reversed, one bounced
        // cheque), a loan, interest with a waiver, a manual entry (edited), an
        // opening balance.
        final lot1 = await postLot(buyerId: buyer);
        await postLot();
        await lots.reverse(ctx, lot1, can: owner, now: now);
        final p1 = await pay();
        await pay(
          direction: PaymentDirection.fromParty,
          mode: PaymentMode.bank,
          bank: sbi,
          rupees: 1200,
        );
        await payments.reverse(ctx, p1, can: owner, now: now);
        final cheque = await pay(mode: PaymentMode.cheque, bank: sbi);
        await payments.setChequeStatus(
          ctx,
          cheque,
          ChequeStatus.bounced,
          can: owner,
          bounceDate: LedgerDate(2027, 4, 12),
          now: DateTime.utc(2027, 4, 12, 6),
        );
        await loans.issue(
          ctx,
          LoanDraft(
            partyId: buyer,
            amount: const Money.rupees(30000),
            issueDate: day,
            config: InterestConfig(
              ratePa: Decimal.parse('18'),
              rounding: InterestRounding.paise,
            ),
          ),
          can: owner,
          now: now,
        );
        final manual = await ledger.append(
          ctx,
          LedgerDraft(
            partyId: buyer,
            side: Side.udhaar,
            amount: const Money.rupees(100000),
            refType: RefType.journal,
            entryDate: LedgerDate(2027, 1, 1),
          ),
          can: owner,
          now: DateTime.utc(2027, 1, 1, 6),
        );
        await ledger.correct(
          ctx,
          (manual as LedgerPosted).entries.single.id,
          can: owner,
          amount: const Money.rupees(120000),
          now: DateTime.utc(2027, 1, 1, 7),
        );
        await interest.settle(
          ctx,
          buyer,
          day,
          can: owner,
          waivers: {SettlementSource.khataKey: 10000},
          reason: 'Round off',
          now: now,
        );
        await db.writeTransaction((tx) async {
          await LedgerRepository.post(
            tx,
            ctx,
            LedgerDraft(
              partyId: farmer,
              side: Side.jama,
              amount: const Money.rupees(2500),
              refType: RefType.openingBalance,
              entryDate: day,
            ),
            now: now,
          );
        });

        final expected = await journal();
        expect(expected.length, greaterThan(10));
        await expectBooksTally();

        // The same data as it was before the books existed.
        await db.execute('DELETE FROM journal_lines');
        await db.execute('DELETE FROM journal_entries');
        final backfill = JournalBackfill(db);
        final status = await backfill.status(t1);
        expect(status.isDone, isFalse);
        expect(status.lots, 2);
        expect(status.payments, greaterThanOrEqualTo(4));
        // Reversals wait for their originals' journal entries.
        expect(status.reversals, 0);

        final progress = <int>[];
        final r = await backfill.run(
          ctx,
          can: owner,
          batchSize: 3,
          onProgress: (done, _) => progress.add(done),
          now: now,
        );
        expect(r, isA<BackfillDone>());
        expect((r as BackfillDone).problems, isEmpty);
        expect(r.written, expected.length);
        expect(progress, isNotEmpty);

        // Identical entries: same keys, dates and lines.
        final rebuilt = await journal();
        String flat(Shape e) => '${e.key}|${e.date}|${e.lines.join(',')}';
        expect(
          [for (final e in rebuilt) flat(e)],
          [for (final e in expected) flat(e)],
        );
        await expectBooksTally();
        expect((await backfill.status(t1)).isDone, isTrue);

        // Running it again changes nothing.
        final again = await backfill.run(ctx, can: owner, now: now);
        expect((again as BackfillDone).written, 0);
        expect(await journal(), hasLength(expected.length));
      },
    );

    test('needs entries.reverse', () async {
      final r = await JournalBackfill(db).run(ctx, can: munshi, now: now);
      expect(r, isA<BackfillNotPermitted>());
    });
  });
}
