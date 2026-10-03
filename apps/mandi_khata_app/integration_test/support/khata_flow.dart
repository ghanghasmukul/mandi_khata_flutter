import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/arrivals/data/lots_repository.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/crops/data/crops_repository.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/parties/data/parties_repository.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';

/// The Phase 1 day in one function, shared by the headless test
/// (`test/hardening`) and the device test (`integration_test`): add a farmer,
/// receive a lot, post it, pay the farmer, and check the khata statement.
///
/// Works on any [PowerSyncDatabase] (desktop file, Android file, browser).
/// Everything is written offline: nothing here needs a connection.
bool ownerCan(Permission _) => true;

/// Wheat, 18 bags, 8.64 qtl @ ₹2,425 with the default charges:
/// net to the farmer ₹19,832.76 (worked example in docs/domain).
const netToFarmer = Money(1983276);

class KhataFlowResult {
  const KhataFlowResult({
    required this.farmerId,
    required this.lotId,
    required this.lotNo,
    required this.receiptNo,
    required this.closing,
  });

  final String farmerId;
  final String lotId;
  final String lotNo;
  final String receiptNo;

  /// The farmer's baki after the payment (positive = we owe him).
  final Money closing;
}

/// Puts the master data every business starts with (wheat, the Cash
/// account) into [db], the way onboarding does.
Future<void> seedBusiness(PowerSyncDatabase db, String tenantId) async {
  await db.execute(
    'INSERT INTO crops (id, tenant_id, code, name_en, unit, sort_order, '
    'is_active) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [
      CropsRepository.idFor(tenantId, 'wheat'),
      tenantId,
      'wheat',
      'Wheat',
      'qtl',
      10,
      1,
    ],
  );
  await db.execute(
    'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
    'sort_order) VALUES (?, ?, ?, ?, ?, ?)',
    [
      BankAccountsRepository.cashIdFor(tenantId),
      tenantId,
      'cash',
      'Cash',
      1,
      0,
    ],
  );
}

Future<KhataFlowResult> runKhataFlow(
  PowerSyncDatabase db,
  WriteContext ctx, {
  required DateTime now,
  String farmerName = 'Gurmeet Singh',
}) async {
  final day = LedgerDate.fromDateTime(now);

  final created = await PartiesRepository(db).create(
    ctx,
    PartyInput(
      code: '',
      name: farmerName,
      roles: const {PartyRole.farmer},
      village: 'Bhikhi',
    ),
    can: ownerCan,
    now: now,
  );
  expect(created, isA<PartySaved>());
  final farmerId = (created as PartySaved).id;

  final lots = LotsRepository(db);
  final arrival = await lots.save(
    ctx,
    LotDraft(
      entryDate: day,
      farmerId: farmerId,
      cropId: CropsRepository.idFor(ctx.tenantId, 'wheat'),
      bags: 18,
      qtlMilli: 8640,
      rate: const Money.rupees(2425),
    ),
    can: ownerCan,
    now: now,
  );
  expect(arrival, isA<LotSaved>());
  final lot = arrival as LotSaved;
  expect(lot.status, LotStatus.posted);
  expect(lot.lotNo, startsWith('L-${ctx.deviceCode}-'));

  final ledger = LedgerRepository(db);
  Future<Money> baki() async =>
      (await ledger.watchStatement(ctx.tenantId, farmerId).first).closing;
  expect(await baki(), netToFarmer, reason: 'posting credits the farmer');

  final paid = await PaymentsRepository(db).save(
    ctx,
    PaymentDraft(
      entryDate: day,
      partyId: farmerId,
      direction: PaymentDirection.toParty,
      mode: PaymentMode.cash,
      amount: const Money.rupees(5000),
      narration: 'advance',
    ),
    can: ownerCan,
    now: now,
  );
  expect(paid, isA<PaymentSaved>());

  final statement = await ledger.watchStatement(ctx.tenantId, farmerId).first;
  expect(statement.rows, hasLength(2));
  expect(statement.totalJama, netToFarmer);
  expect(statement.totalUdhaar, const Money.rupees(5000));
  final closing = netToFarmer - const Money.rupees(5000);
  expect(statement.closing, closing);
  expect(statement.closing, const Money(1483276));

  return KhataFlowResult(
    farmerId: farmerId,
    lotId: lot.id,
    lotNo: lot.lotNo,
    receiptNo: (paid as PaymentSaved).receiptNo,
    closing: closing,
  );
}
