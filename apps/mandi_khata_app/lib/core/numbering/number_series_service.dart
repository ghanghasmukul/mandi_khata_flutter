import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:sqlite_async/sqlite_async.dart'
    show SqliteReadContext, SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Hands out human-readable document numbers (`R-W1-0042`) offline.
///
/// Each device has its own counter per series in `number_series` (tenant,
/// series, device_code), which only this device ever advances — so numbers
/// made offline on different devices can never collide (CLAUDE.md rule 10).
/// The counter row syncs like any other, so a reinstall picks up where the
/// server left off once synced.
///
/// Always call [next] inside the same write transaction as the document
/// insert, so a number is never used twice and never skipped by a failed
/// write.
abstract final class NumberSeriesService {
  static const _idNamespace = 'b2f6e8c4-5a0d-4c61-9e3b-7f1d2a8c4e90';

  static String rowIdFor(String tenantId, String series, String deviceCode) =>
      const Uuid().v5(_idNamespace, '$tenantId|$series|$deviceCode');

  static Future<String> next(
    SqliteWriteContext tx,
    WriteContext ctx,
    DocumentSeries series, {
    DateTime? now,
  }) async {
    final config = await _config(tx, ctx.tenantId, series);
    final at = (now ?? DateTime.now()).toUtc().toIso8601String();
    final row = await tx.getOptional(
      'SELECT id, next_value FROM number_series '
      'WHERE tenant_id = ? AND series = ? AND device_code = ?',
      [ctx.tenantId, series.code, ctx.deviceCode],
    );

    final int counter;
    if (row == null) {
      counter = config.start;
      await tx.execute(
        'INSERT INTO number_series (id, tenant_id, series, device_code, '
        'next_value, created_by, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          rowIdFor(ctx.tenantId, series.code, ctx.deviceCode),
          ctx.tenantId,
          series.code,
          ctx.deviceCode,
          counter + 1,
          ctx.userId,
          at,
          at,
        ],
      );
    } else {
      counter = row['next_value']! as int;
      await tx.execute(
        'UPDATE number_series SET next_value = ?, updated_at = ? WHERE id = ?',
        [counter + 1, at, row['id']],
      );
    }
    return formatDocumentNumber(config.prefix, ctx.deviceCode, counter);
  }

  /// The number [next] would hand out, without using it (for a form hint).
  static Future<String> peek(
    SqliteReadContext tx,
    WriteContext ctx,
    DocumentSeries series,
  ) async {
    final config = await _config(tx, ctx.tenantId, series);
    final row = await tx.getOptional(
      'SELECT next_value FROM number_series '
      'WHERE tenant_id = ? AND series = ? AND device_code = ?',
      [ctx.tenantId, series.code, ctx.deviceCode],
    );
    final counter = row?['next_value'] as int? ?? config.start;
    return formatDocumentNumber(config.prefix, ctx.deviceCode, counter);
  }

  /// Prefix and a new device's first counter, from the business setting
  /// `business.number_series.<doc>` (only settable at business level).
  static Future<({String prefix, int start})> _config(
    SqliteReadContext tx,
    String tenantId,
    DocumentSeries series,
  ) async {
    final stored = await tx.getOptional(
      "SELECT value FROM settings WHERE tenant_id = ? AND scope = 'tenant' "
      'AND scope_id IS NULL AND key = ?',
      [tenantId, series.settingKey],
    );
    final raw = stored?['value'] as String?;
    final resolved = SettingsResolver([
      if (raw != null)
        SettingRow(
          scope: SettingScope.tenant,
          key: series.settingKey,
          value: jsonDecode(raw),
        ),
    ]).resolve(series.settingKey);
    final value = resolved.value! as Map<String, Object?>;
    return (prefix: value['prefix']! as String, start: value['next']! as int);
  }
}
