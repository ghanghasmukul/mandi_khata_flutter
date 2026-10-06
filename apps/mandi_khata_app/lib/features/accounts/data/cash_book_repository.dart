import 'package:khata_core/khata_core.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteReadContext;

/// The cash / bank book of one account (`cash_bank_entries`), from the
/// local database. Each line says what it is: the payment (number, party,
/// UTR / cheque), the voucher or the expense behind it.
class CashBookRepository {
  CashBookRepository(this._db);

  final PowerSyncDatabase _db;

  static const tables = {
    'cash_bank_entries',
    'payments',
    'vouchers',
    'expenses',
    'parties',
  };

  /// Every line of [accountId], oldest first, with its text and reference.
  static Future<List<BookLine>> lines(
    SqliteReadContext tx,
    String tenantId,
    String accountId, {
    LedgerDate? to,
  }) async {
    final rows = await tx.getAll(
      'SELECT l.id, l.entry_date, l.direction, l.amount_paise, l.reverses_id, '
      'l.created_at, l.narration, p.receipt_no, p.reference, p.cheque_no, '
      'pa.name AS party_name, v.voucher_no, x.expense_no, x.paid_to '
      'FROM cash_bank_entries l '
      'LEFT JOIN payments p ON p.id = l.payment_id '
      'AND p.tenant_id = l.tenant_id '
      'LEFT JOIN parties pa ON pa.id = p.party_id '
      'AND pa.tenant_id = p.tenant_id '
      'LEFT JOIN vouchers v ON v.id = l.voucher_id '
      'AND v.tenant_id = l.tenant_id '
      'LEFT JOIN expenses x ON x.id = l.expense_id '
      'AND x.tenant_id = l.tenant_id '
      'WHERE l.tenant_id = ? AND l.account_id = ? '
      'AND (? IS NULL OR l.entry_date <= ?) '
      'ORDER BY l.entry_date, l.created_at, l.id',
      [tenantId, accountId, to?.toString(), to?.toString()],
    );
    return [
      for (final r in rows)
        BookLine(
          id: r['id']! as String,
          date: LedgerDate.parse(r['entry_date']! as String),
          isIn: r['direction'] == 'in',
          amount: Money(r['amount_paise']! as int),
          reversesId: r['reverses_id'] as String?,
          createdAt: r['created_at'] as String?,
          reference: [
            r['reference'],
            r['cheque_no'],
          ].whereType<String>().join(' '),
          text: [
            r['receipt_no'] ?? r['voucher_no'] ?? r['expense_no'],
            r['party_name'] ?? r['paid_to'],
            if (r['receipt_no'] == null &&
                r['voucher_no'] == null &&
                r['expense_no'] == null)
              r['narration'],
          ].whereType<String>().join(' · '),
        ),
    ];
  }

  /// The book of [accountId] for [from]..[to]. Live.
  Stream<CashBook> watch(
    String tenantId,
    String accountId, {
    LedgerDate? from,
    LedgerDate? to,
  }) => _db
      .watch('SELECT 1', triggerOnTables: tables)
      .asyncMap(
        (_) => _db.readTransaction(
          (tx) async => CashBook.build(
            await lines(tx, tenantId, accountId, to: to),
            from: from,
            to: to,
          ),
        ),
      );

  /// The balance of [accountId] at the end of [on] (Σ in − Σ out).
  static Future<Money> balance(
    SqliteReadContext tx,
    String tenantId,
    String accountId,
    LedgerDate on,
  ) async {
    final r = await tx.get(
      "SELECT COALESCE(SUM(CASE direction WHEN 'in' THEN amount_paise "
      'ELSE -amount_paise END), 0) AS b FROM cash_bank_entries '
      'WHERE tenant_id = ? AND account_id = ? AND entry_date <= ?',
      [tenantId, accountId, on.toString()],
    );
    return Money(r['b']! as int);
  }
}
