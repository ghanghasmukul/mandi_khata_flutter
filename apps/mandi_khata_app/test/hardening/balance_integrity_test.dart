import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/arrivals/data/lots_repository.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/crops/data/crops_repository.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/parties/data/parties_repository.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';

import '../../integration_test/support/balance_check.dart';
import '../../integration_test/support/khata_flow.dart';
import '../../integration_test/support/perf_bench.dart';

const tenant = '11111111-1111-4111-8111-111111111111';
const ctx = WriteContext(
  tenantId: tenant,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const bank = 'a0000000-0000-4000-8000-0000000000b1';

void main() {
  late Directory dir;
  late PowerSyncDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_balance_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test(
    'every displayed balance equals the ledger sum after a messy day',
    () async {
      await seedBusiness(db, tenant);
      await db.execute(
        'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
        "sort_order) VALUES (?, ?, 'bank', 'SBI Current', 1, 10)",
        [bank, tenant],
      );
      final parties = PartiesRepository(db);
      final lots = LotsRepository(db);
      final payments = PaymentsRepository(db);
      final ledger = LedgerRepository(db);
      final wheat = CropsRepository.idFor(tenant, 'wheat');
      var clock = DateTime.utc(2026, 4, 10, 6);
      DateTime tick() => clock = clock.add(const Duration(minutes: 7));
      LedgerDate today() => LedgerDate.fromDateTime(clock);

      Future<String> party(String name, PartyRole role) async {
        final r = await parties.create(
          ctx,
          PartyInput(code: '', name: name, roles: {role}),
          can: ownerCan,
          now: tick(),
        );
        return (r as PartySaved).id;
      }

      final f1 = await party('Gurmeet Singh', PartyRole.farmer);
      final f2 = await party('Balwinder Kaur', PartyRole.farmer);
      final f3 = await party('Amrik Singh', PartyRole.farmer);
      final b1 = await party('Bansal Traders', PartyRole.buyer);
      await party('Idle Buyer', PartyRole.buyer); // no entries at all

      Future<String> lot(String farmer, {String? buyer, int qtl = 8640}) async {
        final r = await lots.save(
          ctx,
          LotDraft(
            entryDate: today(),
            farmerId: farmer,
            cropId: wheat,
            bags: 18,
            qtlMilli: qtl,
            rate: const Money.rupees(2425),
            buyerId: buyer,
          ),
          can: ownerCan,
          now: tick(),
        );
        return (r as LotSaved).id;
      }

      Future<String> pay(
        String partyId,
        PaymentDirection direction,
        int rupees, {
        PaymentMode mode = PaymentMode.cash,
      }) async {
        final r = await payments.save(
          ctx,
          PaymentDraft(
            entryDate: today(),
            partyId: partyId,
            direction: direction,
            mode: mode,
            amount: Money.rupees(rupees),
            bankAccountId: mode == PaymentMode.cash ? null : bank,
            chequeNo: mode == PaymentMode.cheque ? '004512' : null,
            chequeDate: mode == PaymentMode.cheque ? today() : null,
          ),
          can: ownerCan,
          now: tick(),
        );
        return (r as PaymentSaved).id;
      }

      // Lots: with a buyer (buyer owes), without, and one that is reversed.
      await lot(f1, buyer: b1);
      await lot(f2);
      final reversedLot = await lot(f3, buyer: b1, qtl: 5000);
      expect(
        await lots.reverse(ctx, reversedLot, can: ownerCan, now: tick()),
        isA<LotSaved>(),
      );

      // Payments: out, in, over-payment (farmer now owes us), a bounced
      // cheque and a reversed payment.
      await pay(f1, PaymentDirection.toParty, 5000);
      await pay(b1, PaymentDirection.fromParty, 10000);
      await pay(f3, PaymentDirection.toParty, 2500); // f3 has nothing to get
      final cheque = await pay(
        f2,
        PaymentDirection.toParty,
        7000,
        mode: PaymentMode.cheque,
      );
      expect(
        await payments.setChequeStatus(
          ctx,
          cheque,
          ChequeStatus.bounced,
          can: ownerCan,
          now: tick(),
        ),
        isA<PaymentSaved>(),
      );
      final mistake = await pay(f1, PaymentDirection.toParty, 999);
      expect(
        await payments.reverse(ctx, mistake, can: ownerCan, now: tick()),
        isA<PaymentSaved>(),
      );

      // A journal entry, then corrected (reversal + new entry).
      final posted = await ledger.append(
        ctx,
        LedgerDraft(
          partyId: f2,
          side: Side.udhaar,
          amount: const Money.rupees(1200),
          refType: RefType.journal,
          entryDate: today(),
        ),
        can: ownerCan,
        now: tick(),
      );
      final journalId = (posted as LedgerPosted).entries.single.id;
      expect(
        await ledger.correct(
          ctx,
          journalId,
          can: ownerCan,
          amount: const Money.rupees(1500),
          now: tick(),
        ),
        isA<LedgerPosted>(),
      );

      await expectBalancesMatchLedger(db, tenant);

      // Spot-check one number by hand: f1 gets 19,832.76, was paid 5,000.
      expect(
        (await ledger.watchStatement(tenant, f1).first).closing,
        const Money(1483276),
      );
    },
  );

  test('also on a 5,000-party / 50,000-entry business', () async {
    await seedBench(db, tenant);
    await expectBalancesMatchLedger(db, tenant);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
