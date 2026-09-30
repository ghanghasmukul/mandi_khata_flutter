import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

/// The crops master of one business in the local database (offline-first).
/// Adding or changing crops is business-wide configuration
/// (`settings.manage`); crops are switched off, never deleted.
class CropsRepository {
  CropsRepository(this._db);

  final PowerSyncDatabase _db;

  /// Same namespace as `private.seed_default_crops` in the crops migration.
  static const _idNamespace = '3d8f2a6e-4c1b-4f0a-9b7e-5a2c8d1e6f30';

  /// Crop ids are UUID v5 of (tenant, code): the server seed and every
  /// device agree, so two devices adding the same code offline write one
  /// row instead of colliding on the unique code.
  static String idFor(String tenantId, String code) =>
      const Uuid().v5(_idNamespace, '$tenantId|$code');

  /// Crops of [tenantId] in display order; inactive ones only when
  /// [includeInactive]. Live.
  Stream<List<Crop>> watchAll(
    String tenantId, {
    bool includeInactive = false,
  }) => _db
      .watch(
        'SELECT * FROM crops WHERE tenant_id = ? AND (? OR is_active = 1) '
        'ORDER BY sort_order, name_en COLLATE NOCASE',
        parameters: [tenantId, if (includeInactive) 1 else 0],
        triggerOnTables: const {'crops'},
      )
      .map((rows) => [for (final r in rows) Crop.fromRow(r)]);

  /// One crop, or null. Live.
  Stream<Crop?> watchOne(String tenantId, String id) => _db
      .watch(
        'SELECT * FROM crops WHERE tenant_id = ? AND id = ?',
        parameters: [tenantId, id],
        triggerOnTables: const {'crops'},
      )
      .map((rows) => rows.isEmpty ? null : Crop.fromRow(rows.first));

  Future<CropSaveResult> create(
    WriteContext ctx,
    CropInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.settingsManage)) return const CropNotPermitted();
    final errors = input.validate();
    if (errors.isNotEmpty) return CropInvalid(errors);
    final columns = input.columns();
    final code = columns['code']! as String;
    final id = idFor(ctx.tenantId, code);
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();

    return await _db.writeTransaction((tx) async {
      final taken = await tx.getOptional(
        'SELECT 1 FROM crops WHERE tenant_id = ? AND (code = ? OR id = ?)',
        [ctx.tenantId, code, id],
      );
      if (taken != null) return const CropCodeTaken();
      final last = await tx.get(
        'SELECT coalesce(max(sort_order), 0) AS m FROM crops '
        'WHERE tenant_id = ?',
        [ctx.tenantId],
      );
      final sortOrder = (last['m']! as int) + 10;
      await tx.execute(
        'INSERT INTO crops (id, tenant_id, ${columns.keys.join(', ')}, unit, '
        'sort_order, created_by, created_at, updated_at) '
        'VALUES (${List.filled(columns.length + 7, '?').join(', ')})',
        [
          id,
          ctx.tenantId,
          ...columns.values,
          'qtl',
          sortOrder,
          ctx.userId,
          at,
          at,
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'crops',
        rowId: id,
        action: AuditAction.insert,
        after: {...columns, 'sort_order': sortOrder},
        at: when,
      );
      return CropSaved(id);
    });
  }

  /// Saves an edit; only changed columns are written. The code cannot
  /// change (per-crop settings are keyed by it).
  Future<CropSaveResult> update(
    WriteContext ctx,
    String id,
    CropInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.settingsManage)) return const CropNotPermitted();
    final errors = input.validate();
    if (errors.isNotEmpty) return CropInvalid(errors);
    final wanted = input.columns();
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();

    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM crops WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (row == null) return const CropNotFound();
      if (row['code'] != wanted['code']) {
        return const CropInvalid({CropFieldError.code});
      }
      final changed = {
        for (final MapEntry(:key, :value) in wanted.entries)
          if (row[key] != value) key: value,
      };
      if (changed.isEmpty) return CropSaved(id);
      await tx.execute(
        'UPDATE crops SET '
        '${changed.keys.map((k) => '$k = ?').join(', ')}, updated_at = ? '
        'WHERE id = ?',
        [...changed.values, at, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'crops',
        rowId: id,
        action: AuditAction.update,
        before: {for (final k in changed.keys) k: row[k]},
        after: changed,
        at: when,
      );
      return CropSaved(id);
    });
  }
}
