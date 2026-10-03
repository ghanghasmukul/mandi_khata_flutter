import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/audit/domain/audit_entry.dart';
import 'package:powersync/powersync.dart';

/// The audit log of one business, from the local database. Owners get the
/// log synced to the device (`audit.view`); everyone else has none locally.
class AuditRepository {
  AuditRepository(this._db);

  final PowerSyncDatabase _db;

  /// Newest first, at most [limit] rows, filtered by [filter]. Live.
  Stream<List<AuditEntry>> watch(
    String tenantId,
    AuditFilter filter, {
    int limit = 100,
  }) {
    final where = <String>['a.tenant_id = ?'];
    final args = <Object?>[tenantId];
    if (filter.userId != null) {
      where.add('a.user_id = ?');
      args.add(filter.userId);
    }
    if (filter.table != null) {
      where.add('a.table_name = ?');
      args.add(filter.table);
    }
    final from = filter.from;
    if (from != null) {
      where.add('a.created_at >= ?');
      args.add(_startOfDayUtc(from));
    }
    final to = filter.to;
    if (to != null) {
      where.add('a.created_at < ?');
      args.add(_startOfDayUtc(to.addDays(1)));
    }
    if (filter.onlyHighlighted) {
      final tables = AuditRules.moneyTables.map((_) => '?').join(', ');
      where.add(
        "a.action IN ('reverse', 'update') AND a.table_name IN ($tables)",
      );
      args.addAll(AuditRules.moneyTables);
    }
    args.add(limit);
    return _db
        .watch(
          'SELECT a.*, u.full_name AS user_name, d.device_code AS device_code, '
          '$_subjectSql AS subject '
          'FROM audit_log a '
          'LEFT JOIN app_users u ON u.id = a.user_id '
          'LEFT JOIN devices d ON d.id = a.device_id '
          'WHERE ${where.join(' AND ')} '
          'ORDER BY a.created_at DESC, a.id LIMIT ?',
          parameters: args,
          triggerOnTables: const {'audit_log', 'app_users', 'devices'},
        )
        .map((rows) {
          final entries = [for (final r in rows) AuditEntry.fromRow(r)];
          return filter.onlyHighlighted
              ? [
                  for (final e in entries)
                    if (e.highlighted) e,
                ]
              : entries;
        });
  }

  /// People who appear in the log (for the user filter): everyone on the
  /// team plus anyone who wrote entries.
  Stream<List<({String id, String name})>> watchWriters(String tenantId) => _db
      .watch(
        'SELECT DISTINCT a.user_id AS id, u.full_name AS name '
        'FROM audit_log a LEFT JOIN app_users u ON u.id = a.user_id '
        'WHERE a.tenant_id = ? ORDER BY u.full_name COLLATE NOCASE',
        parameters: [tenantId],
        triggerOnTables: const {'audit_log', 'app_users'},
      )
      .map(
        (rows) => [
          for (final r in rows)
            (
              id: r['id']! as String,
              name: (r['name'] as String?)?.trim().isNotEmpty ?? false
                  ? r['name']! as String
                  : (r['id']! as String).substring(0, 8),
            ),
        ],
      );

  static String _startOfDayUtc(LedgerDate d) =>
      DateTime(d.year, d.month, d.day).toUtc().toIso8601String();

  /// A readable name for the row an entry is about. Each lookup is by id
  /// and filtered by the entry's own tenant.
  static final String _subjectSql = [
    'CASE a.table_name',
    _when('parties', 'SELECT x.name FROM parties x'),
    _when(
      'tenant_members',
      'SELECT mu.full_name FROM tenant_members x '
          'JOIN app_users mu ON mu.id = x.user_id',
    ),
    _when('devices', 'SELECT x.device_code FROM devices x'),
    _when('crops', 'SELECT x.name_en FROM crops x'),
    _when('payments', 'SELECT x.receipt_no FROM payments x'),
    _when('lots', 'SELECT x.lot_no FROM lots x'),
    _when(
      'ledger_entries',
      'SELECT lp.name FROM ledger_entries x '
          'JOIN parties lp ON lp.id = x.party_id '
          'AND lp.tenant_id = x.tenant_id',
    ),
    _when('member_invites', 'SELECT x.phone FROM member_invites x'),
    'END',
  ].join(' ');

  static String _when(String table, String select) =>
      "WHEN '$table' THEN ($select "
      'WHERE x.id = a.row_id AND x.tenant_id = a.tenant_id)';
}
