import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/dashboard/domain/dashboard.dart';
import 'package:powersync/powersync.dart';

/// Numbers for the dashboard, computed from the local database (offline).
///
/// Every query is filtered by tenant and summed in SQL (a business may have
/// 100k ledger entries); amounts are whole paise, never doubles. Lots and
/// payments that were reversed or cancelled never count.
class DashboardRepository {
  DashboardRepository(this._db);

  final PowerSyncDatabase _db;

  /// Lots that arrived, commission earned, money paid out and received on
  /// [day]. Live.
  Stream<DaySummary> watchDay(String tenantId, LedgerDate day) => _db
      .watch(
        'SELECT '
        '(SELECT COUNT(*) FROM lots WHERE tenant_id = ?1 AND entry_date = ?2 '
        "AND status <> 'reversed') AS lots, "
        '(SELECT COALESCE(SUM(qtl_milli), 0) FROM lots '
        "WHERE tenant_id = ?1 AND entry_date = ?2 AND status <> 'reversed') "
        'AS qtl, '
        '(SELECT COALESCE(SUM(commission), 0) FROM lots '
        "WHERE tenant_id = ?1 AND entry_date = ?2 AND status = 'posted') "
        'AS earned, '
        '(SELECT COALESCE(SUM(amount_paise), 0) FROM payments '
        "WHERE tenant_id = ?1 AND entry_date = ?2 AND status = 'posted' "
        "AND direction = 'to_party') AS paid, "
        '(SELECT COALESCE(SUM(amount_paise), 0) FROM payments '
        "WHERE tenant_id = ?1 AND entry_date = ?2 AND status = 'posted' "
        "AND direction = 'from_party') AS received",
        parameters: [tenantId, day.toString()],
        triggerOnTables: const {'lots', 'payments'},
      )
      .map((rows) {
        final r = rows.first;
        return DaySummary(
          lots: r['lots']! as int,
          qtlMilli: r['qtl']! as int,
          arhatEarned: Money(r['earned']! as int),
          paidOut: Money(r['paid']! as int),
          receipts: Money(r['received']! as int),
        );
      });

  /// Commission earned on each of the last [DashboardDays.chartDays] days
  /// ending [today], oldest first (days without lots are zero). Live.
  Stream<List<DayAmount>> watchEarnedDays(String tenantId, LedgerDate today) {
    final first = today.addDays(1 - DashboardDays.chartDays);
    return _db
        .watch(
          'SELECT entry_date, COALESCE(SUM(commission), 0) AS earned '
          'FROM lots WHERE tenant_id = ? AND entry_date >= ? '
          "AND entry_date <= ? AND status = 'posted' GROUP BY entry_date",
          parameters: [tenantId, first.toString(), today.toString()],
          triggerOnTables: const {'lots'},
        )
        .map(
          (rows) => DashboardDays.chart(today, {
            for (final r in rows)
              LedgerDate.parse(r['entry_date']! as String): Money(
                r['earned']! as int,
              ),
          }),
        );
  }

  /// Posted sales per crop in the financial year containing [today], biggest
  /// first. Live.
  Stream<List<CropSale>> watchCropMix(String tenantId, LedgerDate today) {
    final year = FinancialYear.containing(today);
    return _db
        .watch(
          'SELECT c.id AS crop_id, c.code, c.name_en, c.name_hi, c.name_pa, '
          'SUM(l.gross) AS gross, COUNT(*) AS lots '
          'FROM lots l JOIN crops c ON c.id = l.crop_id '
          'AND c.tenant_id = l.tenant_id '
          "WHERE l.tenant_id = ? AND l.status = 'posted' "
          'AND l.entry_date >= ? AND l.entry_date <= ? '
          'GROUP BY c.id ORDER BY gross DESC, c.code',
          parameters: [tenantId, year.start.toString(), year.end.toString()],
          triggerOnTables: const {'lots', 'crops'},
        )
        .map(
          (rows) => [
            for (final r in rows)
              CropSale(
                cropId: r['crop_id']! as String,
                code: r['code']! as String,
                nameEn: r['name_en']! as String,
                nameHi: r['name_hi'] as String?,
                namePa: r['name_pa'] as String?,
                gross: Money(r['gross']! as int),
                lots: r['lots']! as int,
              ),
          ],
        );
  }

  /// What the khata says we owe and are owed, split farmers / others.
  /// Same rule as `LedgerCalculator.balance` (Σ jama − Σ udhaar), checked by
  /// test. Live.
  Stream<MoneyPosition> watchPosition(String tenantId) => _db
      .watch(
        'WITH bal AS (SELECT party_id, '
        "SUM(CASE side WHEN 'jama' THEN amount_paise ELSE -amount_paise END) "
        'AS b FROM ledger_entries '
        'WHERE tenant_id = ?1 GROUP BY party_id), '
        'tagged AS (SELECT b, EXISTS (SELECT 1 FROM party_roles r '
        'WHERE r.tenant_id = ?1 AND r.party_id = bal.party_id '
        "AND r.role = 'farmer' AND r.deleted_at IS NULL) AS farmer "
        'FROM bal) '
        'SELECT '
        'COALESCE(SUM(CASE WHEN farmer AND b > 0 THEN b END), 0) AS payable, '
        'COALESCE(SUM(CASE WHEN farmer AND b < 0 THEN -b END), 0) AS f_recv, '
        'COALESCE(SUM(CASE WHEN NOT farmer AND b < 0 THEN -b END), 0) '
        'AS o_recv FROM tagged',
        parameters: [tenantId],
        triggerOnTables: const {'ledger_entries', 'party_roles'},
      )
      .map((rows) {
        final r = rows.first;
        return MoneyPosition(
          farmersPayable: Money(r['payable']! as int),
          farmersReceivable: Money(r['f_recv']! as int),
          othersReceivable: Money(r['o_recv']! as int),
        );
      });

  /// Cheques due on or before [today] and munshi changes in the last
  /// [DashboardDays.staffWindow] days (from the audit log). Live.
  Stream<AttentionCounts> watchAttention(String tenantId, LedgerDate today) {
    final since = DateTime.now()
        .toUtc()
        .subtract(const Duration(days: DashboardDays.staffWindow))
        .toIso8601String();
    return _db
        .watch(
          'SELECT '
          '(SELECT COUNT(*) FROM payments WHERE tenant_id = ?1 '
          "AND status = 'posted' AND cheque_status = 'pending' "
          'AND cheque_date <= ?2) AS cheques, '
          '(SELECT COALESCE(SUM(amount_paise), 0) FROM payments '
          "WHERE tenant_id = ?1 AND status = 'posted' "
          "AND cheque_status = 'pending' AND cheque_date <= ?2) AS cheque_sum, "
          '(SELECT COUNT(*) FROM audit_log a WHERE a.tenant_id = ?1 '
          "AND a.action IN ('update', 'reverse') AND a.created_at >= ?3 "
          "AND a.table_name IN ('lots', 'payments', 'ledger_entries') "
          'AND EXISTS (SELECT 1 FROM tenant_members m '
          'WHERE m.tenant_id = a.tenant_id AND m.user_id = a.user_id '
          "AND m.role = 'munshi')) AS staff",
          parameters: [tenantId, today.toString(), since],
          triggerOnTables: const {'payments', 'audit_log', 'tenant_members'},
        )
        .map((rows) {
          final r = rows.first;
          return AttentionCounts(
            chequesDue: r['cheques']! as int,
            chequesDueAmount: Money(r['cheque_sum']! as int),
            staffChanges: r['staff']! as int,
          );
        });
  }
}
