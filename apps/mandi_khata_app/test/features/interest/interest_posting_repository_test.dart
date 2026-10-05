import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/interest/data/interest_posting_repository.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/loans/data/loans_repository.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
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
const farmer2 = 'f0000000-0000-4000-8000-000000000002';
const farmerT2 = 'f0000000-0000-4000-8000-000000000003';

bool owner(Permission _) => true;
bool munshi(Permission p) => MemberRole.munshi.allows(p);

/// 1 Jan 2027 + 100 days: 1,00,000 at 18% = 4,931.51.
final start = LedgerDate(2027, 1, 1);
final day100 = LedgerDate(2027, 4, 11);
final day130 = LedgerDate(2027, 5, 11);
final startAt = DateTime.utc(2027, 1, 1, 6);
final at100 = DateTime.utc(2027, 4, 11, 6);
final at130 = DateTime.utc(2027, 5, 11, 6);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late InterestPostingRepository repo;
  late LedgerRepository ledger;
  late SettingsRepository settings;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_posting_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = InterestPostingRepository(db);
    ledger = LedgerRepository(db);
    settings = SettingsRepository(db);
    for (final (id, tenant, name) in [
      (farmer, t1, 'Gurmeet Singh'),
      (farmer2, t1, 'Harbans Lal'),
      (farmerT2, t2, 'Other Farmer'),
    ]) {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [id, tenant, 'C-$name', name],
      );
      await db.execute(
        'INSERT INTO party_roles (id, tenant_id, party_id, role) '
        "VALUES (?, ?, ?, 'farmer')",
        ['role-$id', tenant, id],
      );
    }
    // Whole paise, so figures match the hand-worked examples.
    await settings.write(
      ctx,
      scope: SettingScope.tenant,
      key: 'interest.rounding',
      value: 'paise',
      can: owner,
      now: startAt,
    );
    await db.execute('DELETE FROM ps_crud');
    await db.execute('DELETE FROM audit_log');
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

  Future<void> debit(int rupees, {String party = farmer}) async {
    final r = await ledger.append(
      ctx,
      LedgerDraft(
        partyId: party,
        side: Side.udhaar,
        amount: Money.rupees(rupees),
        refType: RefType.journal,
        entryDate: start,
      ),
      can: owner,
      now: startAt,
    );
    expect(r, isA<LedgerPosted>());
  }

  Future<List<PostingCandidate>> candidates(
    LedgerDate asOf, {
    String tenant = t1,
  }) => repo.candidates(tenant, asOf);

  Future<InterestPostingPlan> onlyPlan(LedgerDate asOf) async {
    final found = await candidates(asOf);
    expect(found, hasLength(1));
    return found.single.plan;
  }

  Future<String> issueLoan() async {
    final loans = LoansRepository(db, PaymentsRepository(db));
    await db.execute(
      'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
      'sort_order) VALUES (?, ?, ?, ?, 1, 0)',
      [BankAccountsRepository.cashIdFor(t1), t1, 'cash', 'Cash'],
    );
    final r = await loans.issue(
      ctx,
      LoanDraft(
        partyId: farmer,
        amount: const Money.rupees(100000),
        issueDate: start,
        config: InterestConfig(
          ratePa: Decimal.parse('18'),
          rounding: InterestRounding.paise,
        ),
      ),
      can: owner,
      now: startAt,
    );
    expect(r, isA<LoanSaved>());
    await db.execute('DELETE FROM ps_crud');
    await db.execute('DELETE FROM audit_log');
    return (r as LoanSaved).id;
  }

  group('khata interest (net_udhaar)', () {
    test('the preview is what the engine charged up to the day', () async {
      await debit(100000);
      final plan = await onlyPlan(day100);
      expect(plan.scope, PostingScope.khata);
      expect(plan.amountPaise, 493151);
      expect(plan.from, start);
      expect(plan.to, day100);
      expect(plan.periodKey, 'interest:khata:$farmer:2027-04-11');
      // Nothing is written by a preview.
      expect(await rows('interest_postings'), isEmpty);
    });

    test('posting writes the posting, the udhaar entry and the audit in ONE '
        'upload', () async {
      await debit(100000);
      await db.execute('DELETE FROM audit_log');
      await db.execute('DELETE FROM ps_crud');
      final plan = await onlyPlan(day100);
      final r = await repo.post(ctx, [plan], can: owner, now: at100);
      expect(r, isA<InterestPosted>());
      expect((r as InterestPosted).total, const Money(493151));

      final posting = (await rows('interest_postings')).single;
      expect(posting['kind'], 'interest');
      expect(posting['party_id'], farmer);
      expect(posting['loan_id'], isNull);
      expect(posting['period_from'], '2027-01-01');
      expect(posting['period_to'], '2027-04-11');
      expect(posting['amount_paise'], 493151);
      expect(posting['rate_pa'], '18');
      expect(posting['method'], 'simple');
      expect(posting['period_key'], plan.periodKey);

      final entry = (await rows(
        'ledger_entries',
      )).firstWhere((e) => e['ref_type'] == 'interest');
      expect(entry['side'], 'udhaar');
      expect(entry['amount_paise'], 493151);
      expect(entry['ref_id'], posting['id']);
      expect(entry['entry_date'], '2027-04-10'); // the last day charged
      expect(await balance(farmer), const Money(-10493151));

      expect(await transactions(), 1);
      final tables = (await rows(
        'audit_log',
      )).map((a) => a['table_name']).toList()..sort();
      expect(tables, ['interest_postings', 'ledger_entries']);
    });

    test('posted interest is not charged again and the next period starts '
        'where the last one ended', () async {
      await debit(100000);
      await repo.post(ctx, [await onlyPlan(day100)], can: owner, now: at100);
      expect(await candidates(day100), isEmpty);

      final next = await onlyPlan(day130);
      expect(next.from, day100);
      expect(next.amountPaise, 147945); // 641,096 - 493,151
    });

    test(
      'posting the same plan twice, or on two devices, posts once',
      () async {
        await debit(100000);
        final plan = await onlyPlan(day100);
        await repo.post(ctx, [plan], can: owner, now: at100);
        final again = await repo.post(ctx, [plan], can: owner, now: at100);
        expect((again as InterestPosted).posted, isEmpty);
        expect(again.skipped.single.reason, PostingSkip.alreadyPosted);
        expect(await rows('interest_postings'), hasLength(1));

        // Another device builds the SAME ids from the period key.
        expect(
          InterestPostingRepository.postingIdFor(t1, plan.periodKey),
          (await rows('interest_postings')).single['id'],
        );
        expect(
          InterestPostingRepository.entryIdFor(t1, plan.periodKey),
          isNot(InterestPostingRepository.postingIdFor(t1, plan.periodKey)),
        );
      },
    );

    test('a reversed posting counts as not posted', () async {
      await debit(100000);
      await repo.post(ctx, [await onlyPlan(day100)], can: owner, now: at100);
      final entry = (await rows(
        'ledger_entries',
      )).firstWhere((e) => e['ref_type'] == 'interest');
      await ledger.reverse(ctx, entry['id']! as String, can: owner, now: at100);
      final plan = await onlyPlan(day100);
      expect(plan.amountPaise, 493151);
      expect(plan.from, start);
    });

    test('a run posts many parties in batches', () async {
      await debit(100000);
      await debit(50000, party: farmer2);
      final found = await candidates(day100);
      expect(found.map((c) => c.partyName), ['Gurmeet Singh', 'Harbans Lal']);
      expect(found.map((c) => c.amount.paise), [493151, 246575]);
      await db.execute('DELETE FROM ps_crud');
      final r = await repo.post(
        ctx,
        [for (final c in found) c.plan],
        can: owner,
        batchSize: 1,
        now: at100,
      );
      expect((r as InterestPosted).posted, hasLength(2));
      expect(await transactions(), 2);
      final batches = {
        for (final p in await rows('interest_postings')) p['batch_id'],
      };
      expect(batches, hasLength(1));
      expect(batches.single, isNotNull);
    });

    test('the next day nothing is posted before today, and future days are '
        'refused', () async {
      await debit(100000);
      final plan = await onlyPlan(day130);
      final r = await repo.post(ctx, [plan], can: owner, now: at100);
      expect(r, isA<PostingInFuture>());
      expect(await rows('interest_postings'), isEmpty);
    });

    test('a munshi cannot post; a date past the back-date window needs '
        'entries.reverse', () async {
      await debit(100000);
      final plan = await onlyPlan(day100);
      final denied = await repo.post(ctx, [plan], can: munshi, now: at100);
      expect(denied, isA<PostingNotPermitted>());
      expect(await rows('interest_postings'), isEmpty);

      bool loansOnly(Permission p) => p == Permission.loansManage;
      final late = await repo.post(
        ctx,
        [plan],
        can: loansOnly,
        now: DateTime.utc(2027, 4, 20, 6),
      );
      expect(
        (late as InterestPosted).skipped.single.reason,
        PostingSkip.backdated,
      );
      expect(await rows('interest_postings'), isEmpty);
    });

    test(
      'another business sees nothing and cannot post into this one',
      () async {
        await debit(100000);
        expect(await candidates(day100, tenant: t2), isEmpty);
        final plan = await onlyPlan(day100);
        final r = await repo.post(otherCtx, [plan], can: owner, now: at100);
        expect(
          (r as InterestPosted).skipped.single.reason,
          PostingSkip.notFound,
        );
        expect(await rows('interest_postings'), isEmpty);
      },
    );

    test('party with interest switched off or a credit balance has no '
        'candidate', () async {
      await debit(100000);
      await settings.write(
        ctx,
        scope: SettingScope.party,
        scopeId: farmer,
        key: 'interest.enabled',
        value: false,
        can: owner,
        now: startAt,
      );
      expect(await candidates(day100), isEmpty);
    });
  });

  group('settlement (hisaab)', () {
    test('posts the interest and the waiver in ONE upload', () async {
      await debit(100000);
      await db.execute('DELETE FROM ps_crud');
      final r = await repo.settle(
        ctx,
        farmer,
        day100,
        can: owner,
        waivers: {SettlementSource.khataKey: 93151},
        reason: 'Diwali',
        now: at100,
      );
      expect(r, isA<SettlementDone>());
      expect((r as SettlementDone).interest, const Money(493151));
      expect(r.waived, const Money(93151));

      final postings = await rows('interest_postings');
      expect(postings.map((p) => p['kind']).toSet(), {'interest', 'waiver'});
      final waiver = postings.firstWhere((p) => p['kind'] == 'waiver');
      expect(waiver['reason'], 'Diwali');
      expect(waiver['amount_paise'], 93151);
      expect(waiver['period_key'], 'waiver:${waiver['id']}');
      final entry = (await rows(
        'ledger_entries',
      )).firstWhere((e) => e['ref_id'] == waiver['id']);
      expect(entry['ref_type'], 'journal');
      expect(entry['side'], 'jama');
      expect(entry['narration'], 'Interest waived · Diwali');

      // 1,00,000 + 4,931.51 - 931.51 = 1,04,000.
      expect(await balance(farmer), const Money.rupees(-104000));
      expect(await transactions(), 1);
      expect(await candidates(day100), isEmpty);
    });

    test(
      'a waiver without a reason, or above the interest, writes nothing',
      () async {
        await debit(100000);
        await db.execute('DELETE FROM ps_crud');
        final noReason = await repo.settle(
          ctx,
          farmer,
          day100,
          can: owner,
          waivers: {SettlementSource.khataKey: 100},
          now: at100,
        );
        expect((noReason as SettlementInvalid).problems, [
          SettlementProblem.reasonRequired,
        ]);
        final tooMuch = await repo.settle(
          ctx,
          farmer,
          day100,
          can: owner,
          waivers: {SettlementSource.khataKey: 493152},
          reason: 'x',
          now: at100,
        );
        expect((tooMuch as SettlementInvalid).problems, [
          SettlementProblem.waiverExceedsInterest,
        ]);
        expect(await rows('interest_postings'), isEmpty);
        expect(await transactions(), 0);
      },
    );

    test('a waiver needs entries.reverse as well as loans.manage', () async {
      await debit(100000);
      bool loansOnly(Permission p) => p == Permission.loansManage;
      final r = await repo.settle(
        ctx,
        farmer,
        day100,
        can: loansOnly,
        waivers: {SettlementSource.khataKey: 100},
        reason: 'x',
        now: at100,
      );
      expect((r as PostingNotPermitted).permission, Permission.entriesReverse);
      expect(await rows('interest_postings'), isEmpty);
    });

    test('waived interest is not charged again by the engine', () async {
      await debit(100000);
      await repo.settle(
        ctx,
        farmer,
        day100,
        can: owner,
        waivers: {SettlementSource.khataKey: 493151},
        reason: 'Full waiver',
        now: at100,
      );
      expect(await candidates(day100), isEmpty);
      // 30 more days: only the new interest is due (1,00,000 x 18% x 30/365).
      final next = await onlyPlan(day130);
      expect(next.amountPaise, 147945);
    });
  });

  group('loans', () {
    test('a party whose interest runs on the khata is posted on the khata '
        'only, never also per loan', () async {
      await issueLoan();
      final found = await candidates(day100);
      expect(found, hasLength(1));
      expect(found.single.plan.scope, PostingScope.khata);
    });

    test('with loans_only each loan is posted on its own', () async {
      final loanId = await issueLoan();
      await settings.write(
        ctx,
        scope: SettingScope.tenant,
        key: 'interest.apply_on',
        value: 'loans_only',
        can: owner,
        now: startAt,
      );
      final plan = await onlyPlan(day100);
      expect(plan.scope, PostingScope.loan);
      expect(plan.loanId, loanId);
      expect(plan.amountPaise, 493151);
      expect(plan.periodKey, 'interest:loan:$loanId:2027-04-11');

      final r = await repo.post(ctx, [plan], can: owner, now: at100);
      expect(r, isA<InterestPosted>());
      final posting = (await rows('interest_postings')).single;
      expect(posting['loan_id'], loanId);
      expect(await candidates(day100), isEmpty);
      expect(await balance(farmer), const Money(-10493151));
    });

    test("a loan waiver lowers the loan's own accrued interest", () async {
      final loanId = await issueLoan();
      await settings.write(
        ctx,
        scope: SettingScope.tenant,
        key: 'interest.apply_on',
        value: 'loans_only',
        can: owner,
        now: startAt,
      );
      final r = await repo.settle(
        ctx,
        farmer,
        day100,
        can: owner,
        waivers: {'loan:$loanId': 93151},
        reason: 'Good customer',
        now: at100,
      );
      expect(r, isA<SettlementDone>());
      final detail = (await LoansRepository(
        db,
        PaymentsRepository(db),
      ).watchOne(t1, loanId).first)!;
      final position = detail.position(day100);
      expect(position.result.interestWaivedPaise, 93151);
      expect(position.accrued, const Money(400000));
      expect(position.principal, const Money.rupees(100000));
    });
  });
}
