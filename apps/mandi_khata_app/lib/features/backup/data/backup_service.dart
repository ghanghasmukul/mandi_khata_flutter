import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/export/xlsx_writer.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

/// Why a restore was refused.
enum RestoreRefusal {
  /// The backup belongs to another business.
  otherBusiness,

  /// This business already has data on this device; a restore only goes into
  /// an empty one (it would otherwise mix two histories).
  notEmpty,

  /// The file is a backup of a newer app.
  newerFormat,
}

class RestoreRefused implements Exception {
  const RestoreRefused(this.reason);
  final RestoreRefusal reason;
}

/// Reads a business's data out of the local database as a snapshot (for the
/// encrypted backup) and puts a snapshot back (restore), and builds the
/// "download all my data" zip (step 6.4, docs/domain/backup-export.md).
class BackupService {
  BackupService(this._db);

  final PowerSyncDatabase _db;

  static const formatVersion = 1;

  /// Business data worth saving: every synced table with a `tenant_id`,
  /// except platform-wide tables and the ones that identify people / billing
  /// (those come back by signing in).
  static List<SyncedTable> get dataTables => [
    for (final t in syncedTables)
      if (t.columns.containsKey('tenant_id') && !_notBackedUp.contains(t.name))
        t,
  ];

  /// Not saved: the server owns them and a fresh sign-in brings them back.
  static const _notBackedUp = {
    'tenant_members',
    'devices',
    'member_invites',
    'tenant_subscriptions',
    'plan_requests',
    'support_sessions',
  };

  /// All rows of [tenantId], by table. Tables without rows are left out.
  Future<Map<String, Object?>> snapshot(
    String tenantId, {
    String tenantName = '',
    String appVersion = '',
    DateTime? now,
  }) async {
    final tables = <String, Object?>{};
    for (final t in dataTables) {
      final cols = ['id', ...t.columns.keys];
      final rows = await _db.getAll(
        'SELECT ${cols.join(', ')} FROM ${t.name} WHERE tenant_id = ?',
        [tenantId],
      );
      if (rows.isEmpty) continue;
      tables[t.name] = {
        'columns': cols,
        'rows': [
          for (final r in rows) [for (final c in cols) r[c]],
        ],
      };
    }
    return {
      'format': formatVersion,
      'app_version': appVersion,
      'created_at': (now ?? DateTime.now()).toUtc().toIso8601String(),
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'tables': tables,
    };
  }

  /// Rows per table in [snapshot] (for the confirmation text).
  static Map<String, int> rowCounts(Map<String, Object?> snapshot) {
    final tables = (snapshot['tables'] as Map? ?? const {})
        .cast<String, Object?>();
    return {
      for (final e in tables.entries)
        e.key: ((e.value! as Map)['rows'] as List).length,
    };
  }

  /// Whether the business has business data on this device.
  Future<bool> hasData(String tenantId) async {
    for (final table in const ['parties', 'ledger_entries', 'lots']) {
      final r = await _db.get(
        'SELECT COUNT(*) AS n FROM $table WHERE tenant_id = ?',
        [tenantId],
      );
      if ((r['n']! as int) > 0) return true;
    }
    return false;
  }

  /// Puts [snapshot] into the (empty) local database of [ctx]'s business, in
  /// one transaction, with one audit row. The rows then upload like any other
  /// change. Throws [RestoreRefused]; returns the number of rows restored.
  Future<int> restore(
    WriteContext ctx,
    Map<String, Object?> snapshot, {
    DateTime? now,
  }) async {
    if (((snapshot['format'] as int?) ?? 0) > formatVersion) {
      throw const RestoreRefused(RestoreRefusal.newerFormat);
    }
    if (snapshot['tenant_id'] != ctx.tenantId) {
      throw const RestoreRefused(RestoreRefusal.otherBusiness);
    }
    if (await hasData(ctx.tenantId)) {
      throw const RestoreRefused(RestoreRefusal.notEmpty);
    }
    final known = {for (final t in dataTables) t.name: t};
    final tables = (snapshot['tables'] as Map? ?? const {})
        .cast<String, Object?>();
    var total = 0;
    await _db.writeTransaction((tx) async {
      for (final MapEntry(key: name, value: body) in tables.entries) {
        final table = known[name];
        if (table == null) continue; // a table this app does not know
        final map = body! as Map;
        final cols = (map['columns']! as List).cast<String>();
        // Columns this app no longer has are skipped; unknown ones never run
        // as SQL because only names from our own schema are used.
        final use = [
          for (var i = 0; i < cols.length; i++)
            if (cols[i] == 'id' || table.columns.containsKey(cols[i])) i,
        ];
        final sql =
            'INSERT INTO $name (${[for (final i in use) cols[i]].join(', ')}) '
            'VALUES (${List.filled(use.length, '?').join(', ')})';
        final rows = (map['rows']! as List).cast<List<Object?>>();
        await tx.executeBatch(sql, [
          for (final r in rows) [for (final i in use) r[i]],
        ]);
        total += rows.length;
      }
      await AuditWriter.record(
        tx,
        ctx,
        table: 'backup_restore',
        rowId: const Uuid().v4(),
        action: AuditAction.insert,
        after: {
          'rows': total,
          'backup_created_at': snapshot['created_at'],
          'backup_app_version': snapshot['app_version'],
        },
        at: now,
      );
    });
    return total;
  }

  // -- download all my data ---------------------------------------------

  /// A zip with one `.xlsx` per table that has rows (`xlsx/<table>.xlsx`),
  /// a `README.txt`, and, when given, `statements.pdf` (every party's khata).
  Future<Uint8List> exportZip(
    String tenantId, {
    String tenantName = '',
    Uint8List? statementsPdf,
    DateTime? now,
  }) async {
    final archive = Archive();
    var files = 0;
    for (final t in dataTables) {
      final cols = ['id', ...t.columns.keys];
      final rows = await _db.getAll(
        'SELECT ${cols.join(', ')} FROM ${t.name} WHERE tenant_id = ?',
        [tenantId],
      );
      if (rows.isEmpty) continue;
      final table = ReportTable(
        columns: [
          for (final c in cols)
            ReportColumn(
              c,
              t.columns[c] == ColumnKind.integer ||
                      t.columns[c] == ColumnKind.boolean
                  ? ReportColumnKind.number
                  : ReportColumnKind.text,
            ),
        ],
        rows: [
          for (final r in rows) [for (final c in cols) r[c]],
        ],
      );
      archive.addFile(
        ArchiveFile.bytes(
          'xlsx/${t.name}.xlsx',
          XlsxWriter.build(table, sheetName: t.name),
        ),
      );
      files++;
    }
    if (statementsPdf != null) {
      archive.addFile(ArchiveFile.bytes('statements.pdf', statementsPdf));
    }
    final stamp = (now ?? DateTime.now()).toUtc().toIso8601String();
    archive.addFile(
      ArchiveFile.bytes(
        'README.txt',
        utf8.encode(
          'Mandi Khata data export\n'
          'Business: $tenantName\n'
          'Exported: $stamp (UTC)\n'
          'Tables: $files (xlsx/<table>.xlsx), one file per table.\n'
          'Money columns ending in _paise are in paise (100 paise = 1 rupee).\n'
          'Dates are ISO-8601 text. Ids are UUIDs.\n'
          '${statementsPdf == null ? '' : 'statements.pdf holds every '
                    "party's khata statement.\n"}',
        ),
      ),
    );
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }
}
