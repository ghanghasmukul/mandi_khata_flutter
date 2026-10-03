import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/dashboard/data/dashboard_repository.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/day_book.dart';
import 'package:mandi_khata_app/features/reports/data/reports_repository.dart';
import 'package:powersync/powersync.dart';

/// Phase 1 exit criterion: every balance any screen shows equals the ledger
/// sum (baki = Σ jama - Σ udhaar, positive = we owe the party).
///
/// The oracle here is plain SQL over `ledger_entries` plus a Dart running
/// total, written independently of the repositories under test. Each place
/// that shows a balance is then compared with it:
///
///  * party list / khata balances ([LedgerRepository.watchBalances]),
///  * the party khata statement (closing and every running baki),
///  * the day book's running baki on each row,
///  * the dashboard "We owe farmers / Others owe us" tiles,
///  * the outstanding report and the bulk village statements.
///
/// [sampleStatements] caps the per-party statement checks on big data sets.
Future<void> expectBalancesMatchLedger(
  PowerSyncDatabase db,
  String tenantId, {
  int sampleStatements = 400,
  int dayBookRows = 2000,
}) async {
  final far = LedgerDate(2100, 1, 1);
  final raw = await db.getAll(
    'SELECT id, party_id, side, amount_paise FROM ledger_entries '
    'WHERE tenant_id = ? ORDER BY entry_date, created_at, id',
    [tenantId],
  );
  final truth = <String, int>{};
  final runningAfter = <String, int>{};
  for (final r in raw) {
    final party = r['party_id']! as String;
    final signed = (r['side'] == 'jama' ? 1 : -1) * (r['amount_paise']! as int);
    runningAfter[r['id']! as String] = truth[party] =
        (truth[party] ?? 0) + signed;
  }
  final farmers = {
    for (final r in await db.getAll(
      'SELECT DISTINCT party_id FROM party_roles WHERE tenant_id = ? '
      "AND role = 'farmer' AND deleted_at IS NULL",
      [tenantId],
    ))
      r['party_id']! as String,
  };
  expect(truth, isNotEmpty, reason: 'nothing to check');

  final ledger = LedgerRepository(db);

  // 1. Party balances.
  final balances = await ledger.watchBalances(tenantId).first;
  expect(balances.length, truth.length);
  truth.forEach((party, total) {
    expect(balances[party], Money(total), reason: 'balance of $party');
  });

  // 2. Khata statements: closing, and each running baki step by step.
  for (final party in truth.keys.take(sampleStatements)) {
    final statement = await ledger.watchStatement(tenantId, party).first;
    expect(statement.closing, Money(truth[party]!), reason: 'statement $party');
    var run = statement.opening;
    for (final row in statement.rows) {
      run += row.entry.side == Side.jama ? row.entry.amount : -row.entry.amount;
      expect(row.balance, run, reason: 'running baki $party');
    }
    expect(
      statement.totalJama - statement.totalUdhaar + statement.opening,
      Money(truth[party]!),
      reason: 'totals of $party',
    );
  }

  // 3. Day book: the baki printed on each row.
  var seen = 0;
  while (seen < dayBookRows && seen < raw.length) {
    final page = await ledger
        .watchDayBookPage(
          tenantId,
          const LedgerFilter(),
          offset: seen,
          limit: 100,
        )
        .first;
    if (page.isEmpty) break;
    for (final row in page) {
      expect(
        row.balance,
        Money(runningAfter[row.entry.id]!),
        reason: 'day book baki on ${row.entry.id}',
      );
    }
    seen += page.length;
  }

  // 4. Dashboard position.
  final position = await DashboardRepository(db).watchPosition(tenantId).first;
  var payable = 0;
  var farmerRecv = 0;
  var otherRecv = 0;
  truth.forEach((party, total) {
    final isFarmer = farmers.contains(party);
    if (isFarmer && total > 0) payable += total;
    if (isFarmer && total < 0) farmerRecv -= total;
    if (!isFarmer && total < 0) otherRecv -= total;
  });
  expect(position.farmersPayable, Money(payable));
  expect(position.farmersReceivable, Money(farmerRecv));
  expect(position.othersReceivable, Money(otherRecv));

  // 5. Reports.
  final reports = ReportsRepository(db);
  final outstanding = await reports.outstanding(tenantId, asOf: far);
  expect(
    {for (final o in outstanding) o.partyId: o.balance.paise},
    {
      for (final e in truth.entries)
        if (e.value != 0) e.key: e.value,
    },
    reason: 'outstanding report',
  );
  final statements = await reports.farmerStatements(tenantId, to: far);
  for (final s in statements) {
    expect(s.statement.closing, Money(truth[s.partyId]!), reason: s.name);
  }
}
