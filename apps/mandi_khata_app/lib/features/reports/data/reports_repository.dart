import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:powersync/powersync.dart';

/// Report data read from the local database (works offline).
///
/// Every query filters by tenant and aggregates in SQL; a season has about
/// 20k lots and 100k ledger entries, so nothing is loaded just to be summed
/// in Dart. Amounts are whole paise.
class ReportsRepository {
  ReportsRepository(this._db);

  final PowerSyncDatabase _db;

  /// Parties with a non-zero balance on [asOf], biggest first.
  ///
  /// The ageing date is the party's last entry (either side) up to [asOf].
  Future<List<OutstandingRow>> outstanding(
    String tenantId, {
    required LedgerDate asOf,
    OutstandingSide side = OutstandingSide.all,
  }) async {
    final rows = await _db.getAll(
      'SELECT p.id, p.code, p.name, p.village, b.bal, b.last_date FROM (SELECT '
      'party_id, '
      "SUM(CASE side WHEN 'jama' THEN amount_paise ELSE -amount_paise END) "
      'AS bal, MAX(entry_date) AS last_date FROM ledger_entries '
      'WHERE tenant_id = ?1 AND entry_date <= ?2 GROUP BY party_id) b '
      'JOIN parties p ON p.id = b.party_id AND p.tenant_id = ?1 '
      'WHERE b.bal <> 0 AND (?3 = 0 OR (?3 = 1 AND b.bal > 0) '
      'OR (?3 = 2 AND b.bal < 0)) '
      'ORDER BY ABS(b.bal) DESC, p.name',
      [tenantId, asOf.toString(), side.index],
    );
    return [
      for (final r in rows)
        OutstandingRow(
          partyId: r['id']! as String,
          code: r['code']! as String,
          name: r['name']! as String,
          village: r['village'] as String?,
          balance: Money(r['bal']! as int),
          lastEntry: LedgerDate.parse(r['last_date']! as String),
        ),
    ];
  }

  /// Lots dated [from]..[to] (either open), oldest first. Cancelled and
  /// reversed lots are left out; [cropId] limits to one crop.
  Future<List<ArrivalRow>> arrivals(
    String tenantId, {
    LedgerDate? from,
    LedgerDate? to,
    String? cropId,
  }) async {
    final rows = await _db.getAll(
      'SELECT l.lot_no, l.entry_date, l.bags, l.qtl_milli, '
      'l.rate_paise_per_qtl, l.gross, l.commission, l.net_to_farmer, '
      'l.status, f.name AS farmer_name, f.code AS farmer_code, '
      'b.name AS buyer_name, c.name_en, c.name_hi, c.name_pa '
      'FROM lots l '
      'JOIN crops c ON c.id = l.crop_id AND c.tenant_id = l.tenant_id '
      'LEFT JOIN parties f ON f.id = l.farmer_id AND f.tenant_id = l.tenant_id '
      'LEFT JOIN parties b ON b.id = l.buyer_party_id '
      'AND b.tenant_id = l.tenant_id '
      "WHERE l.tenant_id = ?1 AND l.status <> 'reversed' "
      'AND (?2 IS NULL OR l.entry_date >= ?2) '
      'AND (?3 IS NULL OR l.entry_date <= ?3) '
      'AND (?4 IS NULL OR l.crop_id = ?4) '
      'ORDER BY l.entry_date, l.lot_no',
      [tenantId, from?.toString(), to?.toString(), cropId],
    );
    Money? money(Object? v) => v is int ? Money(v) : null;
    return [
      for (final r in rows)
        ArrivalRow(
          lotNo: r['lot_no']! as String,
          date: LedgerDate.parse(r['entry_date']! as String),
          farmerName: (r['farmer_name'] as String?) ?? '',
          farmerCode: r['farmer_code'] as String?,
          crop: LocalName(
            r['name_en']! as String,
            hi: r['name_hi'] as String?,
            pa: r['name_pa'] as String?,
          ),
          bags: r['bags']! as int,
          qtlMilli: r['qtl_milli'] as int?,
          ratePerQtl: money(r['rate_paise_per_qtl']),
          gross: money(r['gross']),
          commission: money(r['commission']),
          netToFarmer: money(r['net_to_farmer']),
          buyerName: r['buyer_name'] as String?,
          status: LotStatus.parse(r['status']! as String),
        ),
    ];
  }

  /// Posted lots per crop in [from]..[to]: volume, sale value and arhat,
  /// biggest sale first.
  Future<List<CommissionRow>> commission(
    String tenantId, {
    LedgerDate? from,
    LedgerDate? to,
  }) async {
    final rows = await _db.getAll(
      'SELECT c.code, c.name_en, c.name_hi, c.name_pa, COUNT(*) AS lots, '
      'SUM(l.qtl_milli) AS qtl, SUM(l.gross) AS gross, '
      'SUM(l.commission) AS commission '
      'FROM lots l JOIN crops c ON c.id = l.crop_id '
      'AND c.tenant_id = l.tenant_id '
      "WHERE l.tenant_id = ?1 AND l.status = 'posted' "
      'AND (?2 IS NULL OR l.entry_date >= ?2) '
      'AND (?3 IS NULL OR l.entry_date <= ?3) '
      'GROUP BY c.id ORDER BY gross DESC, c.code',
      [tenantId, from?.toString(), to?.toString()],
    );
    return [
      for (final r in rows)
        CommissionRow(
          cropCode: r['code']! as String,
          crop: LocalName(
            r['name_en']! as String,
            hi: r['name_hi'] as String?,
            pa: r['name_pa'] as String?,
          ),
          lots: r['lots']! as int,
          qtlMilli: r['qtl']! as int,
          gross: Money(r['gross']! as int),
          commission: Money(r['commission']! as int),
        ),
    ];
  }

  /// Posted payments and receipts in [from]..[to], grouped by mode (cash,
  /// bank, upi, cheque) then by date. Reversed payments (mistakes, bounced
  /// cheques) are not listed; they net to nothing in the khata.
  Future<List<PaymentRow>> payments(
    String tenantId, {
    LedgerDate? from,
    LedgerDate? to,
    PaymentMode? mode,
  }) async {
    final rows = await _db.getAll(
      'SELECT y.receipt_no, y.entry_date, y.direction, y.mode, '
      'y.amount_paise, y.reference, p.name, p.code FROM payments y '
      'JOIN parties p ON p.id = y.party_id AND p.tenant_id = y.tenant_id '
      "WHERE y.tenant_id = ?1 AND y.status = 'posted' "
      'AND (?2 IS NULL OR y.entry_date >= ?2) '
      'AND (?3 IS NULL OR y.entry_date <= ?3) '
      'AND (?4 IS NULL OR y.mode = ?4) '
      "ORDER BY CASE y.mode WHEN 'cash' THEN 0 WHEN 'bank' THEN 1 "
      "WHEN 'upi' THEN 2 ELSE 3 END, y.entry_date, y.receipt_no",
      [tenantId, from?.toString(), to?.toString(), mode?.name],
    );
    return [
      for (final r in rows)
        PaymentRow(
          receiptNo: r['receipt_no']! as String,
          date: LedgerDate.parse(r['entry_date']! as String),
          partyName: r['name']! as String,
          partyCode: r['code'] as String?,
          direction: PaymentDirection.parse(r['direction']! as String),
          mode: PaymentMode.parse(r['mode']! as String),
          amount: Money(r['amount_paise']! as int),
          reference: r['reference'] as String?,
        ),
    ];
  }

  /// Villages of the business's farmers, A to Z.
  Future<List<String>> farmerVillages(String tenantId) async {
    final rows = await _db.getAll(
      'SELECT DISTINCT p.village FROM parties p '
      'JOIN party_roles r ON r.party_id = p.id AND r.tenant_id = p.tenant_id '
      "WHERE p.tenant_id = ? AND r.role = 'farmer' AND r.deleted_at IS NULL "
      "AND p.deleted_at IS NULL AND p.village IS NOT NULL AND p.village <> '' "
      'ORDER BY p.village COLLATE NOCASE',
      [tenantId],
    );
    return [for (final r in rows) r['village']! as String];
  }

  /// Statements of every farmer of [village] (all farmers when null) for
  /// [from]..[to], by name. Farmers with nothing before or in the period are
  /// left out.
  Future<List<PartyStatement>> farmerStatements(
    String tenantId, {
    String? village,
    LedgerDate? from,
    LedgerDate? to,
  }) async {
    final parties = await _db.getAll(
      'SELECT p.id, p.code, p.name, p.village, p.mobile FROM parties p '
      'WHERE p.tenant_id = ?1 AND p.deleted_at IS NULL AND (?2 IS NULL '
      'OR p.village = ?2) AND p.id IN (SELECT r.party_id FROM party_roles r '
      "WHERE r.tenant_id = ?1 AND r.role = 'farmer' "
      'AND r.deleted_at IS NULL) '
      'ORDER BY p.name COLLATE NOCASE, p.code',
      [tenantId, village],
    );
    if (parties.isEmpty) return const [];
    final entries = await _db.getAll(
      'SELECT e.id, e.tenant_id, e.party_id, e.entry_date, e.side, '
      'e.amount_paise, e.ref_type, e.ref_id, e.narration, e.reverses_id, '
      'e.replaces_id, e.device_id, e.created_by, e.created_at '
      'FROM ledger_entries e JOIN parties p ON p.id = e.party_id '
      'AND p.tenant_id = e.tenant_id WHERE e.tenant_id = ?1 '
      'AND p.deleted_at IS NULL AND (?2 IS NULL OR p.village = ?2) '
      'AND (?3 IS NULL OR e.entry_date <= ?3)',
      [tenantId, village, to?.toString()],
    );
    final byParty = <String, List<LedgerEntry>>{};
    for (final r in entries) {
      byParty
          .putIfAbsent(r['party_id']! as String, () => [])
          .add(LedgerRepository.fromRow(r));
    }
    return [
      for (final p in parties)
        if (byParty[p['id']] case final list?)
          PartyStatement(
            partyId: p['id']! as String,
            code: p['code']! as String,
            name: p['name']! as String,
            village: p['village'] as String?,
            mobile: p['mobile'] as String?,
            statement: LedgerCalculator.statement(list, from: from, to: to),
          ),
    ];
  }
}
