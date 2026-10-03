import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/crops/data/crops_repository.dart';
import 'package:mandi_khata_app/features/dashboard/data/dashboard_repository.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/day_book.dart';
import 'package:mandi_khata_app/features/parties/data/parties_repository.dart';
import 'package:mandi_khata_app/features/reports/data/reports_repository.dart';
import 'package:powersync/powersync.dart';

/// Pilot-size business: a busy season of an arhtiya with 5,000 parties and
/// 50,000 khata entries (20k lots, 20k payments, 10k journal entries), the
/// matching 50k audit rows, as one first sync would leave on the device.
const benchParties = 5000;
const benchLots = 20000;
const benchPayments = 20000;
const benchJournal = 10000;
const int benchEntries = benchLots + benchPayments + benchJournal;

const Duration listBudget = Duration(milliseconds: 100);
const reportBudget = Duration(seconds: 2);

String _pad(int n, int w) => n.toString().padLeft(w, '0');

/// Loads the dataset into [db] (one transaction per table, like a sync).
Future<void> seedBench(PowerSyncDatabase db, String tenant) async {
  final crop = CropsRepository.idFor(tenant, 'wheat');
  final start = DateTime.utc(2025, 4);
  DateTime at(int i, int total) =>
      start.add(Duration(minutes: (i * 525600) ~/ total));

  await db.writeTransaction((tx) async {
    await tx.execute(
      'INSERT INTO crops (id, tenant_id, code, name_en, unit, sort_order, '
      'is_active) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [crop, tenant, 'wheat', 'Wheat', 'qtl', 10, 1],
    );
    const villages = [
      'Bhikhi',
      'Budhlada',
      'Sardulgarh',
      'Joga',
      'Bareta',
      'Jhunir',
    ];
    const names = [
      'Gurpreet Singh',
      'Balwinder Kaur',
      'Amrik Singh',
      'Harjit Kaur',
      'Sukhdev Singh',
      'Ramesh Kumar',
      'Jaswinder Singh',
      'Manjit Singh',
    ];
    await tx.executeBatch(
      'INSERT INTO parties (id, tenant_id, code, name, father_or_husband_name, '
      'village, mobile) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        for (var i = 0; i < benchParties; i++)
          [
            'p${_pad(i, 5)}',
            tenant,
            'F-${_pad(i, 5)}',
            '${names[i % names.length]} ${i ~/ names.length}',
            'Kartar Singh',
            villages[i % villages.length],
            '98${_pad(i * 7919 % 100000000, 8)}',
          ],
      ],
    );
    // 90% farmers, 10% buyers.
    await tx.executeBatch(
      'INSERT INTO party_roles (id, tenant_id, party_id, role) '
      'VALUES (?, ?, ?, ?)',
      [
        for (var i = 0; i < benchParties; i++)
          [
            'r${_pad(i, 5)}',
            tenant,
            'p${_pad(i, 5)}',
            if (i % 10 == 9) 'buyer' else 'farmer',
          ],
      ],
    );
    await tx.executeBatch(
      'INSERT INTO lots (id, tenant_id, lot_no, entry_date, farmer_id, '
      'crop_id, bags, qtl_milli, rate_paise_per_qtl, status, gross, '
      'commission, net_to_farmer, created_at) '
      "VALUES (?, ?, ?, ?, ?, ?, 18, 8640, 242500, 'posted', 2095200, "
      '52380, 1983276, ?)',
      [
        for (var i = 0; i < benchLots; i++)
          [
            'l${_pad(i, 6)}',
            tenant,
            'L-W1-${_pad(i, 5)}',
            LedgerDate.fromDateTime(at(i, benchLots)).toString(),
            'p${_pad(i % benchParties, 5)}',
            crop,
            at(i, benchLots).toIso8601String(),
          ],
      ],
    );
    await tx.executeBatch(
      'INSERT INTO payments (id, tenant_id, receipt_no, entry_date, party_id, '
      'direction, mode, amount_paise, status, created_at) '
      "VALUES (?, ?, ?, ?, ?, 'to_party', ?, ?, 'posted', ?)",
      [
        for (var i = 0; i < benchPayments; i++)
          [
            'y${_pad(i, 6)}',
            tenant,
            'V-W1-${_pad(i, 5)}',
            LedgerDate.fromDateTime(at(i, benchPayments)).toString(),
            'p${_pad(i * 3 % benchParties, 5)}',
            const ['cash', 'bank', 'upi', 'cheque'][i % 4],
            500000 + i,
            at(i, benchPayments).toIso8601String(),
          ],
      ],
    );
    // Ledger: arrival credits, payment debits, journal either way.
    final rows = <List<Object?>>[];
    for (var i = 0; i < benchLots; i++) {
      final t = at(i, benchLots);
      rows.add([
        'ea${_pad(i, 6)}',
        tenant,
        'p${_pad(i % benchParties, 5)}',
        LedgerDate.fromDateTime(t).toString(),
        'jama',
        1983276,
        'arrival',
        'l${_pad(i, 6)}',
        t.toIso8601String(),
      ]);
    }
    for (var i = 0; i < benchPayments; i++) {
      final t = at(i, benchPayments);
      rows.add([
        'ep${_pad(i, 6)}',
        tenant,
        'p${_pad(i * 3 % benchParties, 5)}',
        LedgerDate.fromDateTime(t).toString(),
        'udhaar',
        500000 + i,
        'payment',
        'y${_pad(i, 6)}',
        t.toIso8601String(),
      ]);
    }
    for (var i = 0; i < benchJournal; i++) {
      final t = at(i, benchJournal);
      rows.add([
        'ej${_pad(i, 6)}',
        tenant,
        'p${_pad(i * 7 % benchParties, 5)}',
        LedgerDate.fromDateTime(t).toString(),
        if (i.isEven) 'udhaar' else 'jama',
        100000 + i,
        'journal',
        null,
        t.toIso8601String(),
      ]);
    }
    await tx.executeBatch(
      'INSERT INTO ledger_entries (id, tenant_id, party_id, entry_date, side, '
      'amount_paise, ref_type, ref_id, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      rows,
    );
    await tx.executeBatch(
      'INSERT INTO audit_log (id, tenant_id, table_name, row_id, action, '
      'created_at) VALUES (?, ?, ?, ?, ?, ?)',
      [
        for (var i = 0; i < benchEntries; i++)
          [
            'a${_pad(i, 6)}',
            tenant,
            'ledger_entries',
            'e$i',
            'insert',
            at(i, benchEntries).toIso8601String(),
          ],
      ],
    );
  });
}

/// One measured operation: median and worst of several runs.
class Timing {
  const Timing(this.name, this.median, this.worst, {required this.budget});

  final String name;
  final Duration median;
  final Duration worst;
  final Duration budget;

  bool get ok => worst < budget;

  @override
  String toString() =>
      '${name.padRight(34)} '
      'median ${median.inMilliseconds.toString().padLeft(5)} ms'
      '  worst ${worst.inMilliseconds.toString().padLeft(5)} ms'
      '  budget ${budget.inMilliseconds} ms  ${ok ? 'ok' : 'OVER'}';
}

Future<Timing> _time(
  String name,
  Duration budget,
  Future<void> Function() run, {
  int runs = 5,
}) async {
  final times = <Duration>[];
  for (var i = 0; i < runs; i++) {
    final sw = Stopwatch()..start();
    await run();
    times.add(sw.elapsed);
  }
  times.sort();
  return Timing(name, times[times.length ~/ 2], times.last, budget: budget);
}

/// Times every list, search, dashboard and report on the seeded [db].
Future<List<Timing>> runBench(PowerSyncDatabase db, String tenant) async {
  final parties = PartiesRepository(db);
  final ledger = LedgerRepository(db);
  final reports = ReportsRepository(db);
  final dashboard = DashboardRepository(db);
  final today = LedgerDate(2026, 3, 15);
  final fyStart = LedgerDate(2025, 4, 1);
  const none = LedgerFilter();
  const busy = 'p00007';

  return [
    await _time(
      'Parties list (all 5,000)',
      listBudget,
      () => parties.watchAll(tenant).first,
    ),
    await _time(
      'Parties search by name',
      listBudget,
      () => parties.watchAll(tenant, query: 'gurpreet').first,
    ),
    await _time(
      'Parties search by village',
      listBudget,
      () => parties.watchAll(tenant, query: 'budhlada').first,
    ),
    await _time(
      'Parties search by code',
      listBudget,
      () => parties.watchAll(tenant, query: 'F-0420').first,
    ),
    await _time(
      'Parties search by mobile',
      listBudget,
      () => parties.watchAll(tenant, query: '98 0000').first,
    ),
    await _time(
      'Parties filter: farmers only',
      listBudget,
      () => parties.watchAll(tenant, role: PartyRole.farmer).first,
    ),
    await _time(
      'All balances (party list baki)',
      listBudget,
      () => ledger.watchBalances(tenant).first,
    ),
    await _time(
      'Party statement (one khata)',
      listBudget,
      () => ledger.watchStatement(tenant, busy).first,
    ),
    await _time(
      'Day book first page',
      listBudget,
      () => ledger.watchDayBookPage(tenant, none, offset: 0, limit: 100).first,
    ),
    await _time(
      'Day book deep page',
      listBudget,
      () => ledger
          .watchDayBookPage(tenant, none, offset: 40000, limit: 100)
          .first,
    ),
    await _time(
      'Day book totals',
      listBudget,
      () => ledger.watchDayBookSummary(tenant, none).first,
    ),
    await _time(
      'Day book one party',
      listBudget,
      () => ledger
          .watchDayBookPage(
            tenant,
            const LedgerFilter(partyId: busy),
            offset: 0,
            limit: 100,
          )
          .first,
    ),
    // Each tile is its own provider and query; time them one by one.
    await _time(
      'Dashboard: day tile',
      listBudget,
      () => dashboard.watchDay(tenant, today).first,
    ),
    await _time(
      'Dashboard: earned chart',
      listBudget,
      () => dashboard.watchEarnedDays(tenant, today).first,
    ),
    await _time(
      'Dashboard: crop mix',
      listBudget,
      () => dashboard.watchCropMix(tenant, today).first,
    ),
    await _time(
      'Dashboard: money position',
      listBudget,
      () => dashboard.watchPosition(tenant).first,
    ),
    await _time(
      'Dashboard: needs you today',
      listBudget,
      () => dashboard.watchAttention(tenant, today).first,
    ),
    await _time(
      'Report: outstanding + ageing',
      reportBudget,
      () => reports.outstanding(tenant, asOf: today),
    ),
    await _time(
      'Report: arrival register (FY)',
      reportBudget,
      () => reports.arrivals(tenant, from: fyStart, to: today),
    ),
    await _time(
      'Report: commission by crop',
      reportBudget,
      () => reports.commission(tenant, from: fyStart, to: today),
    ),
    await _time(
      'Report: payment register (FY)',
      reportBudget,
      () => reports.payments(tenant, from: fyStart, to: today),
    ),
    await _time(
      'Report: all farmer statements',
      reportBudget,
      () => reports.farmerStatements(tenant, from: fyStart, to: today),
      runs: 3,
    ),
  ];
}
