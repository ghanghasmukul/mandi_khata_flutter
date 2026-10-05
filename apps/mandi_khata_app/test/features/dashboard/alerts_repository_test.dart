import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/dashboard/data/alerts_repository.dart';
import 'package:mandi_khata_app/features/dashboard/domain/alerts.dart';
import 'package:mandi_khata_app/features/interest/data/interest_posting_repository.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/loans/data/loans_repository.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/reports/data/reports_repository.dart';
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
const farmer2 = 'f0000000-0000-4000-8000-000000000002';
const farmer3 = 'f0000000-0000-4000-8000-000000000003';
const other = 'f0000000-0000-4000-8000-000000000009';

bool owner(Permission _) => true;

final start = LedgerDate(2027, 1, 1);
final today = LedgerDate(2027, 5, 17);
final startAt = DateTime.utc(2027, 1, 1, 6);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late LoansRepository loans;
  late InterestPostingRepository posting;
  late AlertsRepository alerts;
  late LedgerRepository ledger;
  late SettingsRepository settings;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_alerts_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    loans = LoansRepository(db, PaymentsRepository(db));
    posting = InterestPostingRepository(db);
    alerts = AlertsRepository(db, loans, posting);
    ledger = LedgerRepository(db);
    settings = SettingsRepository(db);
    for (final (id, tenant, name) in [
      (farmer, t1, 'Gurmeet Singh'),
      (farmer2, t1, 'Harbans Lal'),
      (farmer3, t1, 'Balwinder'),
      (other, t2, 'Other Farmer'),
    ]) {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [id, tenant, 'C-$name', name],
      );
    }
    await db.execute(
      'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
      'sort_order) VALUES (?, ?, ?, ?, 1, 0)',
      [BankAccountsRepository.cashIdFor(t1), t1, 'cash', 'Cash'],
    );
    await settings.write(
      ctx,
      scope: SettingScope.tenant,
      key: 'interest.rounding',
      value: 'paise',
      can: owner,
      now: startAt,
    );
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> debit(int rupees, String party) async {
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

  Future<void> credit(int rupees, String party) async {
    await ledger.append(
      ctx,
      LedgerDraft(
        partyId: party,
        side: Side.jama,
        amount: Money.rupees(rupees),
        refType: RefType.journal,
        entryDate: start,
      ),
      can: owner,
      now: startAt,
    );
  }

  Future<void> loan(String party, LedgerDate? due) async {
    final r = await loans.issue(
      ctx,
      LoanDraft(
        partyId: party,
        amount: const Money.rupees(100000),
        issueDate: start,
        dueDate: due,
        config: InterestConfig(
          ratePa: Decimal.parse('18'),
          rounding: InterestRounding.paise,
        ),
      ),
      can: owner,
      now: startAt,
    );
    expect(r, isA<LoanSaved>());
  }

  Future<void> limit(int rupees, {String? party}) => settings.write(
    ctx,
    scope: party == null ? SettingScope.tenant : SettingScope.party,
    scopeId: party,
    key: 'business.credit_limit',
    value: rupees * 100,
    can: owner,
    now: startAt,
  );

  group('loan alerts', () {
    test('counts overdue loans and loans due within 7 days', () async {
      await loan(farmer, LedgerDate(2027, 5, 10)); // overdue
      await loan(farmer2, LedgerDate(2027, 5, 20)); // due soon
      await loan(farmer3, LedgerDate(2027, 5, 24)); // 7 days: due soon
      await loan(farmer, LedgerDate(2027, 5, 25)); // 8 days: on track
      await loan(farmer2, null); // no due date
      final a = await alerts.watchLoans(t1, today).first;
      expect(a, const LoanAlerts(overdue: 1, dueSoon: 2));
    });

    test('another business sees none', () async {
      await loan(farmer, LedgerDate(2027, 5, 10));
      expect(await alerts.watchLoans(t2, today).first, LoanAlerts.none);
    });

    test('a closed loan is not an alert', () async {
      await loan(farmer, LedgerDate(2027, 5, 10));
      await db.execute(
        "UPDATE loans SET status = 'written_off', closed_on = ?, "
        "close_reason = 'x' WHERE tenant_id = ?",
        ['2027-05-01', t1],
      );
      expect(await alerts.watchLoans(t1, today).first, LoanAlerts.none);
    });
  });

  group('credit limit alerts', () {
    test('no limit set: nobody is over it', () async {
      await debit(100000, farmer);
      expect(await alerts.watchCredit(t1).first, CreditAlerts.none);
    });

    test('the business default applies to every party', () async {
      await debit(100000, farmer);
      await debit(40000, farmer2);
      await limit(50000);
      final a = await alerts.watchCredit(t1).first;
      expect(a.count, 1);
      expect(a.excess, const Money.rupees(50000));
    });

    test('a party override beats the default', () async {
      await debit(100000, farmer);
      await debit(40000, farmer2);
      await limit(50000);
      await limit(30000, party: farmer2);
      final a = await alerts.watchCredit(t1).first;
      expect(a.count, 2);
      expect(a.excess, const Money.rupees(60000));
      // A party limit of 0 means no limit for that party.
      await limit(0, party: farmer);
      expect((await alerts.watchCredit(t1).first).count, 1);
    });

    test('a party we owe money to is never over', () async {
      await credit(80000, farmer);
      await limit(1000);
      expect(await alerts.watchCredit(t1).first, CreditAlerts.none);
    });

    test('another business is not counted', () async {
      await debit(100000, farmer);
      await limit(50000);
      expect(await alerts.watchCredit(t2).first, CreditAlerts.none);
    });
  });

  group('interest not posted for the last quarter', () {
    test(
      'counts accounts and the interest up to the quarter boundary',
      () async {
        await debit(100000, farmer);
        await debit(50000, farmer2);
        final u = await alerts.watchUnposted(t1, today).first;
        // 17 May: the last boundary is 1 April (90 days from 1 January).
        expect(u.asOf, LedgerDate(2027, 4, 1));
        expect(u.accounts, 2);
        // 1,00,000 and 50,000 at 18% for 90 days: 4,438.36 + 2,219.18.
        expect(u.amount, const Money(443836 + 221918));
      },
    );

    test('nothing once the quarter is posted', () async {
      await debit(100000, farmer);
      final plans = await posting.candidates(t1, LedgerDate(2027, 4, 1));
      await posting.post(
        ctx,
        [for (final c in plans) c.plan],
        can: owner,
        now: DateTime.utc(2027, 5, 17, 6),
      );
      final u = await alerts.watchUnposted(t1, today).first;
      expect(u.accounts, 0);
      expect(u.amount, Money.zero);
    });
  });

  group('interest earned report', () {
    test('posted and waived in the period, accrued not yet posted', () async {
      await debit(100000, farmer);
      await debit(50000, farmer2);
      // Post farmer's interest up to 1 April, waive part of it.
      final r = await posting.settle(
        ctx,
        farmer,
        LedgerDate(2027, 4, 1),
        can: owner,
        waivers: {SettlementSource.khataKey: 100000},
        reason: 'Good customer',
        now: DateTime.utc(2027, 4, 1, 6),
      );
      expect(r, isA<SettlementDone>());
      final reports = ReportsRepository(db);
      final open = await posting.candidates(t1, today);
      final rows = await reports.interestEarned(
        t1,
        from: start,
        to: today,
        unposted: open,
      );
      final a = rows.firstWhere((x) => x.partyId == farmer);
      expect(a.posted, const Money(443836));
      expect(a.waived, const Money(100000));
      // 1 Apr to 17 May = 46 days on 1,00,000 at 18% = 2,268.49.
      expect(a.unposted, const Money(226849));
      expect(a.earned, const Money(443836 + 226849));
      final b = rows.firstWhere((x) => x.partyId == farmer2);
      expect(b.posted, Money.zero);
      expect(b.unposted.isPositive, isTrue);
      // Biggest earner first.
      expect(rows.first.partyId, farmer);
    });

    test('the period limits what counts as posted', () async {
      await debit(100000, farmer);
      await posting.settle(
        ctx,
        farmer,
        LedgerDate(2027, 4, 1),
        can: owner,
        now: DateTime.utc(2027, 4, 1, 6),
      );
      final reports = ReportsRepository(db);
      final before = await reports.interestEarned(
        t1,
        from: start,
        to: LedgerDate(2027, 3, 1),
        unposted: const [],
      );
      expect(before, isEmpty);
      final tenant2 = await reports.interestEarned(t2, unposted: const []);
      expect(tenant2, isEmpty);
    });

    test('a reversed posting does not count', () async {
      await debit(100000, farmer);
      await posting.settle(
        ctx,
        farmer,
        LedgerDate(2027, 4, 1),
        can: owner,
        now: DateTime.utc(2027, 4, 1, 6),
      );
      final entry = await db.get(
        "SELECT id FROM ledger_entries WHERE ref_type = 'interest'",
      );
      await ledger.reverse(
        ctx,
        entry['id']! as String,
        can: owner,
        now: DateTime.utc(2027, 4, 2, 6),
      );
      final rows = await ReportsRepository(
        db,
      ).interestEarned(t1, unposted: const []);
      expect(rows, isEmpty);
    });
  });
}
