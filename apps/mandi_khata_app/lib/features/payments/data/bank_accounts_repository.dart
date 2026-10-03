import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

/// The business's own cash and bank accounts in the local database. Bank
/// accounts are finance details: adding or changing one needs
/// `finance.view`. The Cash account exists from the start and never changes.
class BankAccountsRepository {
  BankAccountsRepository(this._db);

  final PowerSyncDatabase _db;

  /// Same namespace as `private.seed_cash_account` in the payments migration.
  static const _idNamespace = '3d8f2a6e-4c1b-4f0a-9b7e-5a2c8d1e6f30';

  /// The Cash account's id: UUID v5 of `<tenant>|account|cash`, the same on
  /// the server and every device.
  static String cashIdFor(String tenantId) =>
      const Uuid().v5(_idNamespace, '$tenantId|account|cash');

  /// Accounts of [tenantId], Cash first; inactive ones only when
  /// [includeInactive]. A device without finance access only has Cash. Live.
  Stream<List<BankAccount>> watchAll(
    String tenantId, {
    bool includeInactive = false,
  }) => _db
      .watch(
        'SELECT * FROM bank_accounts WHERE tenant_id = ? '
        'AND (? OR is_active = 1) '
        "ORDER BY (kind = 'cash') DESC, sort_order, name COLLATE NOCASE",
        parameters: [tenantId, if (includeInactive) 1 else 0],
        triggerOnTables: const {'bank_accounts'},
      )
      .map((rows) => [for (final r in rows) BankAccount.fromRow(r)]);

  /// Money in − money out of every account's book, by account id. Live.
  Stream<Map<String, Money>> watchBalances(String tenantId) => _db
      .watch(
        'SELECT account_id, '
        "SUM(CASE direction WHEN 'in' THEN amount_paise "
        'ELSE -amount_paise END) AS balance '
        'FROM cash_bank_entries WHERE tenant_id = ? GROUP BY account_id',
        parameters: [tenantId],
        triggerOnTables: const {'cash_bank_entries'},
      )
      .map(
        (rows) => {
          for (final r in rows)
            r['account_id']! as String: Money(r['balance']! as int),
        },
      );

  Future<BankAccountResult> create(
    WriteContext ctx,
    BankAccountInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.financeView)) return const BankAccountNotPermitted();
    final problems = input.validate();
    if (problems.isNotEmpty) return BankAccountInvalid(problems);
    final columns = input.columns();
    final id = const Uuid().v4();
    final at = (now ?? DateTime.now()).toUtc().toIso8601String();
    return await _db.writeTransaction((tx) async {
      final last = await tx.get(
        'SELECT coalesce(max(sort_order), 0) AS m FROM bank_accounts '
        'WHERE tenant_id = ?',
        [ctx.tenantId],
      );
      await tx.execute(
        'INSERT INTO bank_accounts (id, tenant_id, ${columns.keys.join(', ')}, '
        'kind, sort_order, is_active, created_by, created_at, updated_at) '
        "VALUES (${List.filled(columns.length + 2, '?').join(', ')}, "
        "'bank', ?, 1, ?, ?, ?)",
        [
          id,
          ctx.tenantId,
          ...columns.values,
          (last['m']! as int) + 10,
          ctx.userId,
          at,
          at,
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'bank_accounts',
        rowId: id,
        action: AuditAction.insert,
        after: {...columns, 'kind': 'bank'},
        at: now,
      );
      return BankAccountSaved(id);
    });
  }

  Future<BankAccountResult> update(
    WriteContext ctx,
    String id,
    BankAccountInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.financeView)) return const BankAccountNotPermitted();
    final problems = input.validate();
    if (problems.isNotEmpty) return BankAccountInvalid(problems);
    final columns = input.columns();
    final at = (now ?? DateTime.now()).toUtc().toIso8601String();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM bank_accounts WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (row == null) return const BankAccountNotFound();
      // The Cash account has nothing to edit.
      if (row['kind'] == 'cash') return const BankAccountNotPermitted();
      final changed = {
        for (final MapEntry(:key, :value) in columns.entries)
          if (row[key] != value) key: value,
      };
      if (changed.isNotEmpty) {
        await tx.execute(
          'UPDATE bank_accounts SET '
          '${changed.keys.map((k) => '$k = ?').join(', ')}, updated_at = ? '
          'WHERE tenant_id = ? AND id = ?',
          [...changed.values, at, ctx.tenantId, id],
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'bank_accounts',
          rowId: id,
          action: AuditAction.update,
          before: {for (final k in changed.keys) k: row[k]},
          after: changed,
          at: now,
        );
      }
      return BankAccountSaved(id);
    });
  }

  /// Switches a bank account on or off (never deleted).
  Future<BankAccountResult> setActive(
    WriteContext ctx,
    String id, {
    required bool active,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.financeView)) return const BankAccountNotPermitted();
    final at = (now ?? DateTime.now()).toUtc().toIso8601String();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT kind, is_active FROM bank_accounts '
        'WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (row == null) return const BankAccountNotFound();
      if (row['kind'] == 'cash') return const BankAccountNotPermitted();
      if ((row['is_active'] == 1) == active) return BankAccountSaved(id);
      await tx.execute(
        'UPDATE bank_accounts SET is_active = ?, updated_at = ? '
        'WHERE tenant_id = ? AND id = ?',
        [if (active) 1 else 0, at, ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'bank_accounts',
        rowId: id,
        action: AuditAction.update,
        before: {'is_active': !active},
        after: {'is_active': active},
        at: now,
      );
      return BankAccountSaved(id);
    });
  }
}
