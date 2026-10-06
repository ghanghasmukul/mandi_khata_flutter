import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/accounts/data/books_invariants.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/voucher_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
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
const buyer = 'b0000000-0000-4000-8000-000000000001';
const sbi = 'a0000000-0000-4000-8000-000000000001';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);
bool noFinance(Permission p) => p != Permission.financeView;

final day = LedgerDate(2027, 4, 11);
final now = DateTime.utc(2027, 4, 11, 6);
final String cash = BankAccountsRepository.cashIdFor(t1);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late VoucherRepository vouchers;
  late ChartRepository charts;
  late BooksInvariants books;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_voucher_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    vouchers = VoucherRepository(db);
    charts = ChartRepository(db);
    books = BooksInvariants(db);
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

  Future<Chart> chart([String tenant = t1]) =>
      db.readTransaction((tx) => ChartRepository.load(tx, tenant));

  Future<ChartEntry> acct(JournalAccount a) async =>
      (await chart()).byId(JournalWriter.accountId(t1, a))!;

  Future<VoucherDraftLine> dr(JournalAccount a, int rupees) async =>
      VoucherDraftLine(
        account: await acct(a),
        side: DrCr.dr,
        amount: Money.rupees(rupees),
      );

  Future<VoucherDraftLine> cr(JournalAccount a, int rupees) async =>
      VoucherDraftLine(
        account: await acct(a),
        side: DrCr.cr,
        amount: Money.rupees(rupees),
      );

  Future<VoucherSaveResult> post(
    VoucherType type,
    List<VoucherDraftLine> lines, {
    bool Function(Permission) can = owner,
    String? narration,
  }) => vouchers.save(
    ctx,
    VoucherDraft(type: type, date: day, lines: lines, narration: narration),
    can: can,
    now: now,
  );

  Future<int> count(String sql, [List<Object?> args = const []]) async =>
      (await db.get('SELECT COUNT(*) AS n FROM $sql', args))['n']! as int;

  Future<int> partyBalance(String party) async =>
      (await db.get(
            "SELECT COALESCE(SUM(CASE side WHEN 'jama' THEN amount_paise "
            'ELSE -amount_paise END), 0) AS b FROM ledger_entries '
            'WHERE tenant_id = ? AND party_id = ?',
            [t1, party],
          ))['b']!
          as int;

  Future<int> bookBalance(String account) async =>
      (await db.get(
            "SELECT COALESCE(SUM(CASE direction WHEN 'in' THEN amount_paise "
            'ELSE -amount_paise END), 0) AS b FROM cash_bank_entries '
            'WHERE tenant_id = ? AND account_id = ?',
            [t1, account],
          ))['b']!
          as int;

  Future<void> expectBooksTally() async {
    expect(await books.unbalancedEntries(t1), isEmpty);
    expect(await books.partyDifferences(t1), isEmpty);
    expect(await books.bookDifferences(t1), isEmpty);
  }

  group('chart', () {
    test(
      'built from parties, books and the built-in list before sync',
      () async {
        final c = await chart();
        final f = c.byId(
          JournalWriter.accountId(t1, const PartyAccount(farmer)),
        )!;
        expect(f.kind, VoucherAccountKind.party);
        expect(f.synced, isFalse);
        expect(c.groupOf(f)!.code, 'sundry_creditors');
        final b = c.byId(
          JournalWriter.accountId(t1, const PartyAccount(buyer)),
        )!;
        expect(c.groupOf(b)!.code, 'sundry_debtors');
        expect(
          c.byId(JournalWriter.accountId(t1, const BookAccount(sbi)))!.kind,
          VoucherAccountKind.bank,
        );
        final sales = c.byId(
          JournalWriter.accountId(
            t1,
            const SystemJournalAccount(SystemAccount.sales),
          ),
        )!;
        expect(sales.kind, VoucherAccountKind.sales);
        expect(c.groups, hasLength(AccountGroup.values.length));
      },
    );

    test('another business sees none of these parties or books', () async {
      final c = await chart(t2);
      expect(
        c.accounts.where((a) => a.kind == VoucherAccountKind.party),
        isEmpty,
      );
      expect(c.accounts.where((a) => a.kind.isBook), isEmpty);
    });

    test(
      'own accounts: add, refuse duplicates and locked groups, switch off',
      () async {
        final indirect = JournalWriter.groupId(
          t1,
          AccountGroup.indirectExpenses,
        );
        final r = await charts.addAccount(
          ctx,
          name: 'Shop rent',
          groupId: indirect,
          now: now,
        );
        expect(r.problem, isNull);
        expect(
          (await charts.addAccount(
            ctx,
            name: 'shop rent ',
            groupId: indirect,
          )).problem,
          AccountProblem.nameTaken,
        );
        expect(
          (await charts.addAccount(
            ctx,
            name: 'Petty',
            groupId: JournalWriter.groupId(t1, AccountGroup.cashInHand),
          )).problem,
          AccountProblem.groupNotAllowed,
        );
        expect(
          (await charts.addAccount(ctx, name: ' ', groupId: indirect)).problem,
          AccountProblem.nameEmpty,
        );
        final rent = (await chart()).byId(r.id!)!;
        expect(rent.isOwn, isTrue);
        expect(rent.kind, VoucherAccountKind.other);
        expect(await charts.updateAccount(ctx, r.id!, isActive: false), isNull);
        expect((await chart()).byId(r.id!)!.isActive, isFalse);
        expect(
          await charts.updateAccount(
            ctx,
            JournalWriter.accountId(t1, const PartyAccount(farmer)),
            name: 'x',
          ),
          AccountProblem.notOwn,
        );
        expect(await count("audit_log WHERE table_name = 'accounts'"), 2);
      },
    );
  });

  group('posting', () {
    test(
      'payment: Dr farmer / Cr cash writes voucher, journal, khata, cash book',
      () async {
        final r = await post(VoucherType.payment, [
          await dr(const PartyAccount(farmer), 5000),
          await cr(BookAccount(cash), 5000),
        ], narration: 'advance');
        expect(r, isA<VoucherSaved>());
        final saved = r as VoucherSaved;
        expect(saved.voucherNo, 'PY-W1-0001');

        final v = await db.get('SELECT * FROM vouchers WHERE id = ?', [
          saved.id,
        ]);
        expect(v['voucher_type'], 'payment');
        expect(v['total_paise'], 500000);
        expect(v['status'], 'posted');
        final e = await db.get(
          'SELECT * FROM journal_entries WHERE voucher_id = ?',
          [saved.id],
        );
        expect(e['source_key'], 'voucher:${saved.id}');
        expect(e['source_type'], 'voucher');
        expect(e['narration'], 'PY-W1-0001 · advance');
        expect(await partyBalance(farmer), -500000);
        expect(await bookBalance(cash), -500000);
        final khata = await db.get(
          'SELECT * FROM ledger_entries WHERE ref_id = ?',
          [saved.id],
        );
        expect(khata['ref_type'], 'voucher');
        expect(khata['side'], 'udhaar');
        expect(
          await count(
            "audit_log WHERE table_name IN ('vouchers', 'journal_entries', "
            "'ledger_entries', 'cash_bank_entries')",
          ),
          4,
        );
        await expectBooksTally();
      },
    );

    test('every type posts and the books tally', () async {
      final rent = (await charts.addAccount(
        ctx,
        name: 'Rent',
        groupId: JournalWriter.groupId(t1, AccountGroup.indirectExpenses),
      )).id!;
      const sales = SystemJournalAccount(SystemAccount.sales);
      const purchase = SystemJournalAccount(SystemAccount.purchase);
      final results = [
        await post(VoucherType.contra, [
          await dr(const BookAccount(sbi), 10000),
          await cr(BookAccount(cash), 10000),
        ]),
        await post(VoucherType.receipt, [
          await dr(BookAccount(cash), 900),
          await cr(const PartyAccount(buyer), 900),
        ]),
        await post(VoucherType.sales, [
          await dr(const PartyAccount(buyer), 2500),
          await cr(sales, 2500),
        ]),
        await post(VoucherType.purchase, [
          await dr(purchase, 700),
          await cr(const PartyAccount(farmer), 700),
        ]),
        await post(VoucherType.journal, [
          await dr(ChartAccount(rent), 300),
          await cr(const PartyAccount(farmer), 300),
        ]),
        await post(VoucherType.payment, [
          await dr(ChartAccount(rent), 1000),
          await dr(const PartyAccount(farmer), 2000),
          await cr(BookAccount(cash), 1000),
          await cr(const BookAccount(sbi), 2000),
        ]),
      ];
      expect(
        [for (final r in results) (r as VoucherSaved).voucherNo],
        [
          'CV-W1-0001',
          'RC-W1-0001',
          'SV-W1-0001',
          'PU-W1-0001',
          'JV-W1-0001',
          'PY-W1-0001',
        ],
      );
      expect(await bookBalance(sbi), 1000000 - 200000);
      expect(await bookBalance(cash), -1000000 + 90000 - 100000);
      // farmer: jama 700 + 300, udhaar 2000; buyer: jama 900, udhaar 2500.
      expect(await partyBalance(farmer), 100000 - 200000);
      expect(await partyBalance(buyer), 90000 - 250000);
      final totals = await db.readTransaction(
        (tx) => ChartRepository.totals(tx, t1),
      );
      expect(totals[rent]!.net, const Money.rupees(1300));
      final allNet = totals.values.fold(Money.zero, (s, t) => s + t.net);
      expect(allNet, Money.zero, reason: 'trial balance tallies');
      await expectBooksTally();
    });

    test(
      'refused: unbalanced, wrong type, munshi, bank without finance',
      () async {
        expect(
          await post(VoucherType.payment, [
            await dr(const PartyAccount(farmer), 5000),
            await cr(BookAccount(cash), 4999),
          ]),
          isA<VoucherInvalid>().having((r) => r.problems, 'problems', [
            VoucherProblem.unbalanced,
          ]),
        );
        expect(
          await post(VoucherType.journal, [
            await dr(const PartyAccount(farmer), 1),
            await cr(BookAccount(cash), 1),
          ]),
          isA<VoucherInvalid>(),
        );
        expect(
          await post(VoucherType.payment, [
            await dr(const PartyAccount(farmer), 1),
            await cr(BookAccount(cash), 1),
          ], can: munshi),
          isA<VoucherNotPermitted>().having(
            (r) => r.permission,
            'permission',
            Permission.entriesReverse,
          ),
        );
        expect(
          await post(VoucherType.payment, [
            await dr(const PartyAccount(farmer), 1),
            await cr(const BookAccount(sbi), 1),
          ], can: noFinance),
          isA<VoucherNotPermitted>().having(
            (r) => r.permission,
            'permission',
            Permission.financeView,
          ),
        );
        expect(await count('vouchers'), 0);
        expect(await count('journal_entries'), 0);
        expect(await count('ledger_entries'), 0);
        expect(await count('cash_bank_entries'), 0);
        expect(await count('number_series'), 0);
      },
    );

    test('a switched-off account cannot take a line', () async {
      final id = (await charts.addAccount(
        ctx,
        name: 'Old',
        groupId: JournalWriter.groupId(t1, AccountGroup.indirectExpenses),
      )).id!;
      final line = await dr(ChartAccount(id), 1);
      await charts.updateAccount(ctx, id, isActive: false);
      expect(
        await post(VoucherType.journal, [
          line,
          await cr(const PartyAccount(farmer), 1),
        ]),
        isA<VoucherNotFound>(),
      );
    });
  });

  group('reversal', () {
    test('mirrors khata, book and journal; once', () async {
      final saved =
          await post(VoucherType.payment, [
                await dr(const PartyAccount(farmer), 3000),
                await dr(const PartyAccount(buyer), 2000),
                await cr(BookAccount(cash), 5000),
              ])
              as VoucherSaved;
      expect(
        await vouchers.reverse(ctx, saved.id, can: munshi),
        isA<VoucherNotPermitted>(),
      );
      final r = await vouchers.reverse(ctx, saved.id, can: owner, now: now);
      expect(r, isA<VoucherSaved>());
      expect(await partyBalance(farmer), 0);
      expect(await partyBalance(buyer), 0);
      expect(await bookBalance(cash), 0);
      expect(
        (await db.get('SELECT status FROM vouchers WHERE id = ?', [
          saved.id,
        ]))['status'],
        'reversed',
      );
      final reversal = await db.get(
        'SELECT * FROM journal_entries WHERE source_key = ?',
        ['reversal:voucher:${saved.id}'],
      );
      expect(reversal['entry_date'], day.toString());
      expect(await count('journal_entries'), 2);
      expect(
        await vouchers.reverse(ctx, saved.id, can: owner),
        isA<VoucherLocked>(),
      );
      await expectBooksTally();
    });

    test('a voucher with no party line is reversed too', () async {
      final saved =
          await post(VoucherType.contra, [
                await dr(const BookAccount(sbi), 100),
                await cr(BookAccount(cash), 100),
              ])
              as VoucherSaved;
      await vouchers.reverse(ctx, saved.id, can: owner, now: now);
      expect(await bookBalance(sbi), 0);
      expect(await bookBalance(cash), 0);
      expect(await count('journal_entries'), 2);
      await expectBooksTally();
    });

    test(
      'the khata line of a voucher is not editable from the khata',
      () async {
        final saved =
            await post(VoucherType.journal, [
                  await dr(const PartyAccount(buyer), 100),
                  await cr(const PartyAccount(farmer), 100),
                ])
                as VoucherSaved;
        // Reversing one khata line from the khata would mirror the WHOLE
        // journal entry; the voucher's reversal must stay the only way.
        final line = await db.get(
          "SELECT id FROM ledger_entries WHERE ref_id = ? AND side = 'udhaar'",
          [saved.id],
        );
        final row = LedgerRepository.fromRow(
          await db.get('SELECT * FROM ledger_entries WHERE id = ?', [
            line['id'],
          ]),
        );
        expect(row.refType, RefType.voucher);
      },
    );
  });

  group('day book', () {
    test('lists vouchers with numbers, filter by type, tenant only', () async {
      await post(VoucherType.payment, [
        await dr(const PartyAccount(farmer), 10),
        await cr(BookAccount(cash), 10),
      ]);
      await post(VoucherType.receipt, [
        await dr(BookAccount(cash), 20),
        await cr(const PartyAccount(buyer), 20),
      ]);
      final all = await vouchers.watchDayBook(t1, from: day, to: day).first;
      expect(all, hasLength(2));
      expect(all.map((r) => r.voucher!.voucherNo).toSet(), {
        'PY-W1-0001',
        'RC-W1-0001',
      });
      expect(all.map((r) => r.total.paise).toSet(), {1000, 2000});
      final receipts = await vouchers
          .watchDayBook(
            t1,
            from: day,
            to: day,
            voucherType: VoucherType.receipt,
          )
          .first;
      expect(receipts.single.voucher!.type, VoucherType.receipt);
      expect(
        await vouchers.watchDayBook(t2, from: day, to: day).first,
        isEmpty,
      );
      final lines = await vouchers.watchLines(t1, receipts.single.id).first;
      expect(lines.map((l) => l.account!.name).toSet(), {
        'Cash',
        'Bansal Traders',
      });
    });
  });
}
