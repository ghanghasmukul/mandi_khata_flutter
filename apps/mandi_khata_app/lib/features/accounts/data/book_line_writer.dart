import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// The document a cash / bank book line belongs to: exactly one of a
/// payment, a voucher or an expense (`cash_bank_entries`).
enum BookSource {
  payment('payment_id'),
  voucher('voucher_id'),
  expense('expense_id'),
  purchase('purchase_id'),
  purchaseReturn('purchase_return_id'),
  shopSale('shop_sale_id'),
  shopReturn('shop_return_id');

  const BookSource(this.column);

  final String column;
}

/// Writes cash / bank book lines (`cash_bank_entries`, append-only) inside
/// the caller's transaction, each with its audit row.
abstract final class BookLineWriter {
  /// One line of [source] [sourceId]; returns its id.
  static Future<String> insert(
    SqliteWriteContext tx,
    WriteContext ctx, {
    required BookSource source,
    required String sourceId,
    required String accountId,
    required String accountKind,
    required LedgerDate entryDate,
    required BookDirection direction,
    required Money amount,
    required String? narration,
    required DateTime when,
    String? reversesId,
  }) async {
    final lineId = const Uuid().v4();
    await tx.execute(
      'INSERT INTO cash_bank_entries (id, tenant_id, account_id, '
      'account_kind, entry_date, direction, amount_paise, ${source.column}, '
      'narration, reverses_id, device_id, created_by, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        lineId,
        ctx.tenantId,
        accountId,
        accountKind,
        entryDate.toString(),
        direction.dbName,
        amount.paise,
        sourceId,
        narration,
        reversesId,
        ctx.deviceId,
        ctx.userId,
        when.toUtc().toIso8601String(),
      ],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'cash_bank_entries',
      rowId: lineId,
      action: reversesId == null ? AuditAction.insert : AuditAction.reverse,
      after: {
        'account_id': accountId,
        'entry_date': entryDate.toString(),
        'direction': direction.dbName,
        'amount_paise': amount.paise,
        source.column: sourceId,
        'reverses_id': ?reversesId,
      },
      at: when,
    );
    return lineId;
  }

  /// Mirrors every line of [source] [sourceId] not reversed yet, dated
  /// [entryDate] (each line's own date when null). Returns how many.
  static Future<int> reverseAll(
    SqliteWriteContext tx,
    WriteContext ctx, {
    required BookSource source,
    required String sourceId,
    required String? narration,
    required DateTime when,
    LedgerDate? entryDate,
  }) async {
    final lines = await tx.getAll(
      'SELECT l.* FROM cash_bank_entries l WHERE l.tenant_id = ? '
      'AND l.${source.column} = ? AND l.reverses_id IS NULL AND NOT EXISTS ( '
      'SELECT 1 FROM cash_bank_entries r WHERE r.tenant_id = l.tenant_id '
      'AND r.reverses_id = l.id) ORDER BY l.created_at, l.id',
      [ctx.tenantId, sourceId],
    );
    for (final l in lines) {
      await insert(
        tx,
        ctx,
        source: source,
        sourceId: sourceId,
        accountId: l['account_id']! as String,
        accountKind: l['account_kind']! as String,
        entryDate: entryDate ?? LedgerDate.parse(l['entry_date']! as String),
        direction: BookDirection.parse(l['direction']! as String).opposite,
        amount: Money(l['amount_paise']! as int),
        narration: narration,
        reversesId: l['id']! as String,
        when: when,
      );
    }
    return lines.length;
  }
}
