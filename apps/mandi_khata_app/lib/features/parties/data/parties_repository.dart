import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/numbering/number_series_service.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Parties of one business in the local database (offline-first). The
/// reference implementation for every feature repository: live reads,
/// validated writes, one transaction per change with its audit rows.
class PartiesRepository {
  PartiesRepository(this._db);

  final PowerSyncDatabase _db;

  static const _roleIdNamespace = 'd3c1f5a8-2e47-4b9c-8a61-5f0e9b7d2c14';

  /// Same id for the same (party, role) on every device, so the unique
  /// (party_id, role) constraint never rejects an offline double add.
  static String roleRowId(String partyId, PartyRole role) =>
      const Uuid().v5(_roleIdNamespace, '$partyId|${role.name}');

  // Roles are matched on party_id only: the party row is already filtered
  // by tenant, and adding tenant_id here makes SQLite pick the
  // (tenant_id, role) index and scan every role per party (seconds at 10k).
  static const _rolesColumn =
      '(SELECT group_concat(r.role) FROM party_roles r '
      'WHERE r.party_id = p.id AND r.deleted_at IS NULL) AS roles';

  /// Active parties of [tenantId] matching [query] (name, father's name,
  /// village, code or mobile) and [role], by name. Live.
  Stream<List<Party>> watchAll(
    String tenantId, {
    String query = '',
    PartyRole? role,
  }) {
    final text = query.trim().toLowerCase();
    final like = '%${_escape(text)}%';
    // Mobile search only for number-like queries ("98140 22", "+91 98…"),
    // so a code such as "b-2" does not match every mobile with a 2 in it.
    final digits = text.replaceAll(RegExp('[^0-9]'), '');
    final digitsLike =
        RegExp(r'^[+\d\s-]+$').hasMatch(text) && digits.length >= 3
        ? '%$digits%'
        : null;
    return _db
        .watch(
          'SELECT p.*, $_rolesColumn FROM parties p '
          'WHERE p.tenant_id = ? AND p.deleted_at IS NULL '
          "AND (? = '' "
          r"OR lower(p.name) LIKE ? ESCAPE '\' "
          r"OR lower(p.father_or_husband_name) LIKE ? ESCAPE '\' "
          r"OR lower(p.village) LIKE ? ESCAPE '\' "
          r"OR lower(p.code) LIKE ? ESCAPE '\' "
          'OR p.mobile LIKE ?) '
          'AND (? IS NULL OR EXISTS (SELECT 1 FROM party_roles r '
          'WHERE r.party_id = p.id AND r.role = ? '
          'AND r.deleted_at IS NULL)) '
          'ORDER BY p.name COLLATE NOCASE, p.code',
          parameters: [
            tenantId,
            text,
            like,
            like,
            like,
            like,
            digitsLike,
            role?.name,
            role?.name,
          ],
          triggerOnTables: const {'parties', 'party_roles'},
        )
        .map((rows) => [for (final r in rows) Party.fromRow(r)]);
  }

  static String _escape(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

  /// One active party, or null if missing / deleted. Live.
  Stream<Party?> watchOne(String tenantId, String id) => _db
      .watch(
        'SELECT p.*, $_rolesColumn FROM parties p '
        'WHERE p.tenant_id = ? AND p.id = ? AND p.deleted_at IS NULL',
        parameters: [tenantId, id],
        triggerOnTables: const {'parties', 'party_roles'},
      )
      .map((rows) => rows.isEmpty ? null : Party.fromRow(rows.first));

  /// The code a new party would get if the code is left blank.
  Future<String> previewNextCode(WriteContext ctx) => _db.readTransaction(
    (tx) => NumberSeriesService.peek(tx, ctx, DocumentSeries.party),
  );

  /// Adds a party. A blank code gets the next `P-<device>-NNNN` number.
  ///
  /// [maxParties] is the plan's party limit (null = unlimited): a business
  /// that already has that many parties gets [PartyLimitReached] and nothing
  /// is written (the server checks again).
  Future<PartySaveResult> create(
    WriteContext ctx,
    PartyInput input, {
    required bool Function(Permission) can,
    int? maxParties,
    DateTime? now,
  }) async {
    if (!can(Permission.partiesManage)) return const PartyNotPermitted();
    final autoCode = input.code.trim().isEmpty;
    final errors = input.copyWith(code: autoCode ? 'X' : null).validate();
    if (errors.isNotEmpty) return PartyInvalid(errors);

    final when = now ?? DateTime.now();
    try {
      return await _db.writeTransaction((tx) async {
        if (maxParties != null) {
          final row = await tx.get(
            'SELECT count(*) AS n FROM parties '
            'WHERE tenant_id = ? AND deleted_at IS NULL',
            [ctx.tenantId],
          );
          if ((row['n']! as int) >= maxParties) {
            throw _LimitReached(maxParties);
          }
        }
        final PartyInput n;
        if (autoCode) {
          // Skip numbers someone already typed in by hand as a code.
          var code = await NumberSeriesService.next(
            tx,
            ctx,
            DocumentSeries.party,
            now: when,
          );
          while (await _codeTaken(tx, ctx.tenantId, code)) {
            code = await NumberSeriesService.next(
              tx,
              ctx,
              DocumentSeries.party,
              now: when,
            );
          }
          n = input.copyWith(code: code).normalised();
        } else {
          n = input.normalised();
          if (await _codeTaken(tx, ctx.tenantId, n.code)) {
            // Throw (not return) so the whole transaction is rolled back.
            throw const _CodeTaken();
          }
        }
        final id = const Uuid().v4();
        await insertIn(tx, ctx, n, id: id, when: when);
        return PartySaved(id, n.code);
      });
    } on _CodeTaken {
      return const PartyCodeTaken();
    } on _LimitReached catch (e) {
      return PartyLimitReached(e.limit);
    }
  }

  /// Inserts the (already validated and normalised) party [n] with its
  /// roles and audit rows inside the caller's transaction. [id] lets a
  /// caller (the opening-balance import) use a deterministic id so the same
  /// import on two devices lands on one party.
  static Future<void> insertIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    PartyInput n, {
    required String id,
    required DateTime when,
  }) async {
    final at = when.toUtc().toIso8601String();
    final columns = partyColumns(n);
    await tx.execute(
      'INSERT INTO parties (id, tenant_id, ${columns.keys.join(', ')}, '
      'created_by, created_at, updated_at) '
      'VALUES (${List.filled(columns.length + 5, '?').join(', ')})',
      [id, ctx.tenantId, ...columns.values, ctx.userId, at, at],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'parties',
      rowId: id,
      action: AuditAction.insert,
      after: columns,
      at: when,
    );
    for (final role in n.roles) {
      await _addRole(tx, ctx, id, role, when);
    }
  }

  /// Whether [code] is already used by a party of the business (deleted
  /// ones included: the database unique constraint covers them too).
  static Future<bool> codeTaken(
    SqliteWriteContext tx,
    String tenantId,
    String code,
  ) => _codeTaken(tx, tenantId, code);

  /// Saves an edit. Only changed columns are written, so two devices that
  /// edit different fields offline both keep their change (last write wins
  /// per field); each device's change gets its own audit row.
  Future<PartySaveResult> update(
    WriteContext ctx,
    String id,
    PartyInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.partiesManage)) return const PartyNotPermitted();
    final errors = input.validate();
    if (errors.isNotEmpty) return PartyInvalid(errors);
    final n = input.normalised();
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();

    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT p.*, $_rolesColumn FROM parties p '
        'WHERE p.tenant_id = ? AND p.id = ? AND p.deleted_at IS NULL',
        [ctx.tenantId, id],
      );
      if (row == null) return const PartyNotFound();
      final current = Party.fromRow(row);
      if (n.code != current.code &&
          await _codeTaken(tx, ctx.tenantId, n.code, excludeId: id)) {
        return const PartyCodeTaken();
      }

      final wanted = partyColumns(n);
      final changed = {
        for (final MapEntry(:key, :value) in wanted.entries)
          if (row[key] != value) key: value,
      };
      if (changed.isNotEmpty) {
        await tx.execute(
          'UPDATE parties SET '
          '${changed.keys.map((k) => '$k = ?').join(', ')}, updated_at = ? '
          'WHERE id = ?',
          [...changed.values, at, id],
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'parties',
          rowId: id,
          action: AuditAction.update,
          before: {for (final k in changed.keys) k: row[k]},
          after: changed,
          at: when,
        );
      }
      for (final role in n.roles.difference(current.roles)) {
        await _addRole(tx, ctx, id, role, when);
      }
      for (final role in current.roles.difference(n.roles)) {
        await _removeRole(tx, ctx, id, role, when);
      }
      return PartySaved(id, n.code);
    });
  }

  /// Hides a party everywhere (owner only: `master.delete`). The row stays
  /// for history and audit; ledger entries will still point to it.
  Future<PartySaveResult> softDelete(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.masterDelete)) return const PartyNotPermitted();
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT code, name FROM parties '
        'WHERE tenant_id = ? AND id = ? AND deleted_at IS NULL',
        [ctx.tenantId, id],
      );
      if (row == null) return const PartyNotFound();
      await tx.execute(
        'UPDATE parties SET deleted_at = ?, updated_at = ? WHERE id = ?',
        [at, at, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'parties',
        rowId: id,
        action: AuditAction.softDelete,
        before: {'code': row['code'], 'name': row['name'], 'deleted_at': null},
        after: {'deleted_at': at},
        at: when,
      );
      return PartySaved(id, row['code']! as String);
    });
  }

  static Future<bool> _codeTaken(
    SqliteWriteContext tx,
    String tenantId,
    String code, {
    String? excludeId,
  }) async =>
      // Deleted parties keep their code (the database unique constraint
      // covers them too).
      await tx.getOptional(
        'SELECT 1 FROM parties WHERE tenant_id = ? AND upper(code) = ? '
        'AND id IS NOT ?',
        [tenantId, code.toUpperCase(), excludeId],
      ) !=
      null;

  static Future<void> _addRole(
    SqliteWriteContext tx,
    WriteContext ctx,
    String partyId,
    PartyRole role,
    DateTime when,
  ) async {
    final at = when.toUtc().toIso8601String();
    final id = roleRowId(partyId, role);
    final existing = await tx.getOptional(
      'SELECT deleted_at FROM party_roles WHERE id = ?',
      [id],
    );
    if (existing == null) {
      await tx.execute(
        'INSERT INTO party_roles (id, tenant_id, party_id, role, created_by, '
        'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [id, ctx.tenantId, partyId, role.name, ctx.userId, at, at],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'party_roles',
        rowId: id,
        action: AuditAction.insert,
        after: {'party_id': partyId, 'role': role.name},
        at: when,
      );
    } else {
      await tx.execute(
        'UPDATE party_roles SET deleted_at = NULL, updated_at = ? WHERE id = ?',
        [at, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'party_roles',
        rowId: id,
        action: AuditAction.restore,
        before: {'deleted_at': existing['deleted_at']},
        after: {'deleted_at': null},
        at: when,
      );
    }
  }

  static Future<void> _removeRole(
    SqliteWriteContext tx,
    WriteContext ctx,
    String partyId,
    PartyRole role,
    DateTime when,
  ) async {
    final at = when.toUtc().toIso8601String();
    final id = roleRowId(partyId, role);
    await tx.execute(
      'UPDATE party_roles SET deleted_at = ?, updated_at = ? WHERE id = ?',
      [at, at, id],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'party_roles',
      rowId: id,
      action: AuditAction.softDelete,
      before: {'role': role.name, 'deleted_at': null},
      after: {'deleted_at': at},
      at: when,
    );
  }
}

class _LimitReached implements Exception {
  const _LimitReached(this.limit);

  final int limit;
}

class _CodeTaken implements Exception {
  const _CodeTaken();
}
