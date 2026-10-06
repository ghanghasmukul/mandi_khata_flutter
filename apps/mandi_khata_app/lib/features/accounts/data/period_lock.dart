import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteReadContext;

/// The lock of closed financial years (docs/domain/posting-rules.md, 11.5):
/// a write dated inside one needs the owner's session override with a
/// reason (`WriteContext.lockReason`). The server enforces the same.
abstract final class PeriodLock {
  /// The closed financial years of [tenantId].
  static Future<List<FinancialYear>> closedYears(
    SqliteReadContext tx,
    String tenantId,
  ) async {
    final rows = await tx.getAll(
      'SELECT start_date FROM financial_years WHERE tenant_id = ? '
      "AND status = 'closed'",
      [tenantId],
    );
    return [
      for (final r in rows)
        FinancialYear(LedgerDate.parse(r['start_date']! as String).year),
    ];
  }

  static Future<bool> isLocked(
    SqliteReadContext tx,
    String tenantId,
    LedgerDate date,
  ) async => YearClose.isLocked(date, await closedYears(tx, tenantId));

  /// True when [ctx] may not write on [date]: it is in a closed year and
  /// the owner has not unlocked it with a reason.
  static Future<bool> refuses(
    SqliteReadContext tx,
    WriteContext ctx,
    LedgerDate date,
  ) async => ctx.lockReason == null && await isLocked(tx, ctx.tenantId, date);
}
