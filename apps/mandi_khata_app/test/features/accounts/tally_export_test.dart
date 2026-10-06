import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/tally_export_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/voucher_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';
import 'package:xml/xml.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'owner',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);
const farmer = 'f0000000-0000-4000-8000-000000000001';
const farmer2 = 'f0000000-0000-4000-8000-000000000002';

bool owner(Permission _) => true;

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  final day = LedgerDate(2027, 4, 9);
  final now = DateTime.utc(2027, 4, 9, 6);
  final cash = BankAccountsRepository.cashIdFor(t1);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_tally_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    for (final (id, code) in [(farmer, 'P-1'), (farmer2, 'P-2')]) {
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name) VALUES (?, ?, ?, ?)',
        [id, t1, code, 'Gurmeet Singh'],
      );
    }
    await db.execute(
      'INSERT INTO bank_accounts (id, tenant_id, kind, name, is_active, '
      "sort_order) VALUES (?, ?, 'cash', 'Cash', 1, 0)",
      [cash, t1],
    );
    await PaymentsRepository(db).save(
      ctx,
      PaymentDraft(
        entryDate: day,
        partyId: farmer,
        direction: PaymentDirection.toParty,
        mode: PaymentMode.cash,
        amount: const Money.rupees(5000),
      ),
      can: owner,
      now: now,
    );
    final chart = await db.readTransaction(
      (tx) => ChartRepository.load(tx, t1),
    );
    await VoucherRepository(db).save(
      ctx,
      VoucherDraft(
        type: VoucherType.journal,
        date: day,
        lines: [
          VoucherDraftLine(
            account: chart.byId(
              JournalWriter.accountId(t1, const PartyAccount(farmer2)),
            )!,
            side: DrCr.dr,
            amount: const Money.rupees(100),
          ),
          VoucherDraftLine(
            account: chart.byId(
              JournalWriter.accountId(t1, const PartyAccount(farmer)),
            )!,
            side: DrCr.cr,
            amount: const Money.rupees(100),
          ),
        ],
      ),
      can: owner,
      now: now,
    );
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test('a period exports its ledgers and vouchers, ready for Tally', () async {
    final plan = await TallyExportRepository(db).plan(
      t1,
      company: 'Bansal & Sons',
      from: day,
      to: day,
      groupMap: TallyExportRepository.groupMap(null),
    );
    final r = plan.result;
    expect(r.voucherCount, 2);
    expect(r.ledgerCount, 3);
    expect(r.isClean, isTrue, reason: '${r.issues.map((i) => i.kind)}');
    final masters = XmlDocument.parse(r.mastersXml);
    expect(
      {
        for (final l in masters.findAllElements('LEDGER'))
          l.getAttribute('NAME'),
      },
      {'Gurmeet Singh (P-1)', 'Gurmeet Singh (P-2)', 'Cash'},
    );
    final vouchers = XmlDocument.parse(
      r.vouchersXml,
    ).findAllElements('VOUCHER').toList();
    expect(
      {for (final v in vouchers) v.getAttribute('VCHTYPE')},
      {'Payment', 'Journal'},
    );
    expect(
      vouchers
          .firstWhere((v) => v.getAttribute('VCHTYPE') == 'Payment')
          .findElements('VOUCHERNUMBER')
          .single
          .innerText,
      'V-W1-0001',
    );
    expect(
      {for (final g in plan.groups) (g.code, g.tallyGroup)},
      {
        ('sundry_creditors', 'Sundry Creditors'),
        ('cash_in_hand', 'Cash-in-Hand'),
      },
    );

    final zip = ZipDecoder().decodeBytes(
      TallyExportRepository.zip(r, const ['ok']),
    );
    expect(
      [for (final f in zip.files) f.name],
      ['01-masters.xml', '02-vouchers.xml', 'validation.txt'],
    );
  });

  test('a missing mapping is reported; other periods and businesses are '
      'empty', () async {
    final plan = await TallyExportRepository(db).plan(
      t1,
      company: 'X',
      from: day,
      to: day,
      groupMap: const {'cash_in_hand': 'Cash-in-Hand'},
    );
    expect(
      plan.result.issues.map((i) => i.kind),
      contains(TallyIssueKind.unmappedGroup),
    );
    expect(plan.result.isClean, isFalse);
    final empty = await TallyExportRepository(db).plan(
      t1,
      company: 'X',
      from: day.addDays(1),
      to: day.addDays(5),
      groupMap: TallyExportRepository.groupMap(null),
    );
    expect(empty.result.voucherCount, 0);
    final other = await TallyExportRepository(db).plan(
      t2,
      company: 'X',
      from: day,
      to: day,
      groupMap: TallyExportRepository.groupMap(null),
    );
    expect(other.result.voucherCount, 0);
    expect(
      TallyExportRepository.groupMap({'cash_in_hand': 'Bank Accounts', 1: 2}),
      containsPair('cash_in_hand', 'Bank Accounts'),
    );
  });
}
