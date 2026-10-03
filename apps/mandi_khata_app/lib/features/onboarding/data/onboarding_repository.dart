import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:powersync/powersync.dart';

/// Why a wizard step could not be saved.
enum OnboardingSaveFailure { notPermitted, invalid, notFound }

/// What the first-run wizard writes besides settings: the business's own
/// details and which crops it deals in. Local database only (offline-first);
/// every change is audited in the same transaction.
class OnboardingRepository {
  OnboardingRepository(this._db);

  final PowerSyncDatabase _db;

  /// Whether the business already has any party or khata entry (an existing
  /// business is never pulled into the wizard by itself). Live.
  Stream<bool> watchHasData(String tenantId) => _db
      .watch(
        'SELECT (EXISTS (SELECT 1 FROM parties WHERE tenant_id = ?) '
        'OR EXISTS (SELECT 1 FROM ledger_entries WHERE tenant_id = ?)) '
        'AS has_data',
        parameters: [tenantId, tenantId],
        triggerOnTables: const {'parties', 'ledger_entries'},
      )
      .map((rows) => rows.first['has_data'] == 1);

  /// The business row as stored, or null. Live.
  Stream<Map<String, Object?>?> watchTenant(String tenantId) => _db
      .watch(
        'SELECT name, legal_name, gstin, address, state_code, mandi_name, '
        'phone FROM tenants WHERE id = ?',
        parameters: [tenantId],
        triggerOnTables: const {'tenants'},
      )
      .map((rows) => rows.isEmpty ? null : rows.first);

  /// Changes the given `tenants` columns (only those that differ are
  /// written). Needs `admin.manage`; billing columns are not accepted.
  Future<OnboardingSaveFailure?> updateTenant(
    WriteContext ctx,
    Map<String, Object?> wanted, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.adminManage)) return OnboardingSaveFailure.notPermitted;
    const allowed = {
      'name',
      'legal_name',
      'gstin',
      'address',
      'state_code',
      'mandi_name',
      'phone',
    };
    if (wanted.isEmpty || !allowed.containsAll(wanted.keys)) {
      return OnboardingSaveFailure.invalid;
    }
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional('SELECT * FROM tenants WHERE id = ?', [
        ctx.tenantId,
      ]);
      if (row == null) return OnboardingSaveFailure.notFound;
      final changed = {
        for (final MapEntry(:key, :value) in wanted.entries)
          if (row[key] != value) key: value,
      };
      if (changed.isEmpty) return null;
      await tx.execute(
        'UPDATE tenants SET '
        '${changed.keys.map((k) => '$k = ?').join(', ')}, updated_at = ? '
        'WHERE id = ?',
        [...changed.values, at, ctx.tenantId],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'tenants',
        rowId: ctx.tenantId,
        action: AuditAction.update,
        before: {for (final k in changed.keys) k: row[k]},
        after: changed,
        at: when,
      );
      return null;
    });
  }

  /// Switches crops on / off so exactly [activeIds] are active. Crops are
  /// never deleted. One transaction, one audit row per crop changed.
  Future<({OnboardingSaveFailure? failure, int changed})> setActiveCrops(
    WriteContext ctx,
    Set<String> activeIds, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.settingsManage)) {
      return (failure: OnboardingSaveFailure.notPermitted, changed: 0);
    }
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();
    final changed = await _db.writeTransaction((tx) async {
      var n = 0;
      final rows = await tx.getAll(
        'SELECT id, is_active FROM crops WHERE tenant_id = ?',
        [ctx.tenantId],
      );
      for (final r in rows) {
        final id = r['id']! as String;
        final was = r['is_active'] != 0;
        final want = activeIds.contains(id);
        if (was == want) continue;
        await tx.execute(
          'UPDATE crops SET is_active = ?, updated_at = ? WHERE id = ?',
          [if (want) 1 else 0, at, id],
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'crops',
          rowId: id,
          action: AuditAction.update,
          before: {'is_active': was},
          after: {'is_active': want},
          at: when,
        );
        n++;
      }
      return n;
    });
    return (failure: null, changed: changed);
  }
}
