// Phase 1 exit criterion: a munshi cannot reverse entries or add / use bank
// accounts, and the owner sees every munshi edit in the audit log.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/arrivals/data/lots_repository.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/audit/data/audit_repository.dart';
import 'package:mandi_khata_app/features/audit/domain/audit_entry.dart';
import 'package:mandi_khata_app/features/crops/data/crops_repository.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/parties/data/parties_repository.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';

import '../../integration_test/support/khata_flow.dart';

const tenant = '11111111-1111-4111-8111-111111111111';
const ownerCtx = WriteContext(
  tenantId: tenant,
  userId: 'u-owner',
  deviceId: 'd-w1',
  deviceCode: 'W1',
);
const munshiCtx = WriteContext(
  tenantId: tenant,
  userId: 'u-munshi',
  deviceId: 'd-a1',
  deviceCode: 'A1',
);
const bank = 'a0000000-0000-4000-8000-0000000000b1';

bool munshi(Permission p) => MemberRole.munshi.allows(p);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  var clock = DateTime.now().toUtc().subtract(const Duration(hours: 2));
  DateTime tick() => clock = clock.add(const Duration(minutes: 3));
  LedgerDate today() => LedgerDate.fromDateTime(DateTime.now());

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_munshi_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    await seedBusiness(db, tenant);
    await db.execute(
      'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
      "sort_order) VALUES (?, ?, 'bank', 'SBI Current', 1, 10)",
      [bank, tenant],
    );
    for (final (id, name) in [
      ('u-owner', 'Naresh Gupta'),
      ('u-munshi', 'Rajinder'),
    ]) {
      await db.execute('INSERT INTO app_users (id, full_name) VALUES (?, ?)', [
        id,
        name,
      ]);
    }
    await db.execute(
      'INSERT INTO tenant_members (id, tenant_id, user_id, role) '
      "VALUES ('m-1', ?, 'u-owner', 'owner'), ('m-2', ?, 'u-munshi', 'munshi')",
      [tenant, tenant],
    );
    for (final (id, user, code, platform) in [
      ('d-w1', 'u-owner', 'W1', 'windows'),
      ('d-a1', 'u-munshi', 'A1', 'android'),
    ]) {
      await db.execute(
        'INSERT INTO devices (id, tenant_id, user_id, device_code, platform) '
        'VALUES (?, ?, ?, ?, ?)',
        [id, tenant, user, code, platform],
      );
    }
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<String> farmerWithBalance() async {
    final r = await runKhataFlow(db, ownerCtx, now: tick());
    return r.farmerId;
  }

  Future<int> rows(String table) async =>
      (await db.get('SELECT COUNT(*) AS n FROM $table'))['n']! as int;

  test(
    'a munshi cannot reverse or correct anything, nothing is written',
    () async {
      final farmer = await farmerWithBalance();
      final ledger = LedgerRepository(db);
      final payments = PaymentsRepository(db);
      final lots = LotsRepository(db);
      final entry =
          (await db.get(
                "SELECT id FROM ledger_entries WHERE ref_type = 'payment'",
              ))['id']!
              as String;
      final payment =
          (await db.get('SELECT id FROM payments'))['id']! as String;
      final lot = (await db.get('SELECT id FROM lots'))['id']! as String;
      final before = [
        await rows('ledger_entries'),
        await rows('payments'),
        await rows('lots'),
        await rows('audit_log'),
      ];

      expect(
        await ledger.reverse(munshiCtx, entry, can: munshi),
        isA<LedgerNotPermitted>(),
      );
      expect(
        await ledger.correct(
          munshiCtx,
          entry,
          can: munshi,
          amount: const Money.rupees(1),
        ),
        isA<LedgerNotPermitted>(),
      );
      expect(
        await payments.reverse(munshiCtx, payment, can: munshi),
        isA<PaymentNotPermitted>(),
      );
      expect(
        await lots.reverse(munshiCtx, lot, can: munshi),
        isA<LotNotPermitted>(),
      );
      // A journal entry is an accountant / owner tool too.
      expect(
        await ledger.append(
          munshiCtx,
          LedgerDraft(
            partyId: farmer,
            side: Side.udhaar,
            amount: const Money.rupees(10),
            refType: RefType.journal,
          ),
          can: munshi,
        ),
        isA<LedgerNotPermitted>(),
      );

      expect([
        await rows('ledger_entries'),
        await rows('payments'),
        await rows('lots'),
        await rows('audit_log'),
      ], before);
      expect(
        await db.getAll(
          'SELECT id FROM ledger_entries WHERE reverses_id IS NOT NULL',
        ),
        isEmpty,
      );
    },
  );

  test('a munshi cannot bounce a cheque, add or use a bank account', () async {
    final farmer = await farmerWithBalance();
    final payments = PaymentsRepository(db);

    // Owner records a cheque; the munshi may not bounce it.
    final cheque = await payments.save(
      ownerCtx,
      PaymentDraft(
        entryDate: today(),
        partyId: farmer,
        direction: PaymentDirection.toParty,
        mode: PaymentMode.cheque,
        amount: const Money.rupees(3000),
        bankAccountId: bank,
        chequeNo: '000123',
        chequeDate: today(),
      ),
      can: ownerCan,
      now: tick(),
    );
    expect(
      await payments.setChequeStatus(
        munshiCtx,
        (cheque as PaymentSaved).id,
        ChequeStatus.bounced,
        can: munshi,
      ),
      isA<PaymentNotPermitted>(),
    );

    // No bank accounts for the munshi: create, edit, switch off.
    final accounts = BankAccountsRepository(db);
    expect(
      await accounts.create(
        munshiCtx,
        const BankAccountInput(name: 'My own bank'),
        can: munshi,
      ),
      isA<BankAccountNotPermitted>(),
    );
    expect(
      await accounts.update(
        munshiCtx,
        bank,
        const BankAccountInput(name: 'Renamed'),
        can: munshi,
      ),
      isA<BankAccountNotPermitted>(),
    );
    expect(
      await accounts.setActive(munshiCtx, bank, active: false, can: munshi),
      isA<BankAccountNotPermitted>(),
    );

    // And cannot pay or receive through one (bank, UPI, cheque), only cash.
    for (final mode in [
      PaymentMode.bank,
      PaymentMode.upi,
      PaymentMode.cheque,
    ]) {
      final r = await payments.save(
        munshiCtx,
        PaymentDraft(
          entryDate: today(),
          partyId: farmer,
          direction: PaymentDirection.fromParty,
          mode: mode,
          amount: const Money.rupees(100),
          bankAccountId: bank,
          chequeNo: mode == PaymentMode.cheque ? '000124' : null,
          chequeDate: mode == PaymentMode.cheque ? today() : null,
        ),
        can: munshi,
      );
      expect(r, isA<PaymentNotPermitted>(), reason: mode.name);
      expect((r as PaymentNotPermitted).permission, Permission.financeView);
    }
    expect(
      (await db.get('SELECT name FROM bank_accounts WHERE id = ?', [
        bank,
      ]))['name'],
      'SBI Current',
    );
    expect(
      await payments.save(
        munshiCtx,
        PaymentDraft(
          entryDate: today(),
          partyId: farmer,
          direction: PaymentDirection.fromParty,
          mode: PaymentMode.cash,
          amount: const Money.rupees(100),
        ),
        can: munshi,
      ),
      isA<PaymentSaved>(),
      reason: 'cash is the munshis job',
    );
  });

  test('the owner sees every munshi edit in the audit log', () async {
    await farmerWithBalance();
    final parties = PartiesRepository(db);
    final farmer =
        (await db.get(
              'SELECT id FROM parties ORDER BY created_at LIMIT 1',
            ))['id']!
            as String;

    // The munshi's day: a new farmer, an edit, a lot, a payment.
    final created = await parties.create(
      munshiCtx,
      const PartyInput(
        code: '',
        name: 'Harpreet Kaur',
        roles: {PartyRole.farmer},
      ),
      can: munshi,
      now: tick(),
    );
    expect(created, isA<PartySaved>());
    expect(
      await parties.update(
        munshiCtx,
        (created as PartySaved).id,
        const PartyInput(
          code: 'P-A1-0001',
          name: 'Harpreet Kaur',
          roles: {PartyRole.farmer},
          village: 'Bhikhi',
        ),
        can: munshi,
        now: tick(),
      ),
      isA<PartySaved>(),
    );
    expect(
      await LotsRepository(db).save(
        munshiCtx,
        LotDraft(
          entryDate: today(),
          farmerId: farmer,
          cropId: CropsRepository.idFor(tenant, 'wheat'),
          bags: 10,
          qtlMilli: 4800,
          rate: const Money.rupees(2425),
        ),
        can: munshi,
        now: tick(),
      ),
      isA<LotSaved>(),
    );
    expect(
      await PaymentsRepository(db).save(
        munshiCtx,
        PaymentDraft(
          entryDate: today(),
          partyId: farmer,
          direction: PaymentDirection.toParty,
          mode: PaymentMode.cash,
          amount: const Money.rupees(1000),
        ),
        can: munshi,
        now: tick(),
      ),
      isA<PaymentSaved>(),
    );

    // The server fills the role on upload; the owner's synced copy has it.
    await db.execute(
      "UPDATE audit_log SET role = 'munshi' WHERE user_id = 'u-munshi'",
    );
    await db.execute(
      "UPDATE audit_log SET role = 'owner' WHERE user_id = 'u-owner'",
    );

    // Every row a munshi wrote has an audit row, in the owner's log, with
    // the munshi's name, device and role.
    final log = await AuditRepository(
      db,
    ).watch(tenant, const AuditFilter(userId: 'u-munshi'), limit: 500).first;
    expect(log, isNotEmpty);
    expect(log.every((e) => e.userName == 'Rajinder'), isTrue);
    expect(log.every((e) => e.deviceCode == 'A1'), isTrue);
    expect(log.every((e) => e.role == 'munshi'), isTrue);
    final audited = {for (final e in log) '${e.table}/${e.rowId}'};
    // The munshi's own lot, payment and party edit are all there.
    final munshiLot = await db.getAll(
      "SELECT id FROM lots WHERE device_id = 'd-a1'",
    );
    final munshiPayment = await db.getAll(
      "SELECT id FROM payments WHERE device_id = 'd-a1'",
    );
    expect(munshiLot, hasLength(1));
    expect(munshiPayment, hasLength(1));
    expect(audited, contains('lots/${munshiLot.single['id']}'));
    expect(audited, contains('payments/${munshiPayment.single['id']}'));
    expect(
      log.where((e) => e.table == 'parties' && e.action == 'update'),
      hasLength(1),
      reason: 'the party edit',
    );
    for (final e in await db.getAll(
      "SELECT id FROM ledger_entries WHERE device_id = 'd-a1'",
    )) {
      expect(audited, contains('ledger_entries/${e['id']}'));
    }
  });
}
