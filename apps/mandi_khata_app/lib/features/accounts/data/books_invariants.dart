import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteReadContext;

/// One account whose books differ from what it should mirror.
class BooksDifference {
  const BooksDifference({
    required this.id,
    required this.name,
    required this.expectedPaise,
    required this.actualPaise,
  });

  /// The party or the cash / bank account.
  final String id;
  final String name;

  /// What the khata / cash book says, debit-positive.
  final int expectedPaise;

  /// What the journal lines add up to (debit minus credit).
  final int actualPaise;

  int get differencePaise => actualPaise - expectedPaise;
}

/// The checks of docs/domain/posting-rules.md, section 1: the books always
/// tally with the khata and the cash / bank book. Read-only; used by tests,
/// the back-fill report and the phase reviews. Never "fixes" anything.
///
/// Accounts are matched by their deterministic ids (computed here), not by
/// joining the `accounts` table, which the server fills and which a device
/// may not have yet.
class BooksInvariants {
  BooksInvariants(this._db);

  final PowerSyncDatabase _db;

  /// Journal entries whose lines do not balance (there should be none).
  Future<List<String>> unbalancedEntries(String tenantId) =>
      _db.readTransaction((tx) => unbalancedEntriesIn(tx, tenantId));

  static Future<List<String>> unbalancedEntriesIn(
    SqliteReadContext tx,
    String tenantId,
  ) async => [
    for (final r in await tx.getAll(
      'SELECT journal_entry_id FROM journal_lines WHERE tenant_id = ? '
      'GROUP BY journal_entry_id '
      'HAVING SUM(debit_paise) <> SUM(credit_paise)',
      [tenantId],
    ))
      r['journal_entry_id']! as String,
  ];

  /// Party accounts whose debit balance is not minus the khata balance
  /// (`Σ jama − Σ udhaar`), up to [asOn] (`yyyy-mm-dd`) when given.
  Future<List<BooksDifference>> partyDifferences(
    String tenantId, {
    String? asOn,
  }) =>
      _db.readTransaction((tx) => partyDifferencesIn(tx, tenantId, asOn: asOn));

  static Future<List<BooksDifference>> partyDifferencesIn(
    SqliteReadContext tx,
    String tenantId, {
    String? asOn,
  }) async {
    final khata = {
      for (final r in await tx.getAll(
        "SELECT party_id, SUM(CASE side WHEN 'udhaar' THEN amount_paise "
        'ELSE -amount_paise END) AS bal FROM ledger_entries '
        'WHERE tenant_id = ? ${asOn == null ? '' : 'AND entry_date <= ? '}'
        'GROUP BY party_id',
        [tenantId, ?asOn],
      ))
        r['party_id']! as String: r['bal']! as int,
    };
    final journal = await _journalBalances(tx, tenantId, asOn: asOn);
    final parties = await tx.getAll(
      'SELECT id, name FROM parties WHERE tenant_id = ?',
      [tenantId],
    );
    return [
      for (final p in parties)
        if ((khata[p['id']] ?? 0) !=
            (journal[JournalWriter.accountId(
                  tenantId,
                  PartyAccount(p['id']! as String),
                )] ??
                0))
          BooksDifference(
            id: p['id']! as String,
            name: p['name']! as String,
            expectedPaise: khata[p['id']] ?? 0,
            actualPaise:
                journal[JournalWriter.accountId(
                  tenantId,
                  PartyAccount(p['id']! as String),
                )] ??
                0,
          ),
    ];
  }

  /// Cash and bank accounts whose journal balance is not `Σ in − Σ out` of
  /// the cash / bank book.
  Future<List<BooksDifference>> bookDifferences(
    String tenantId, {
    String? asOn,
  }) =>
      _db.readTransaction((tx) => bookDifferencesIn(tx, tenantId, asOn: asOn));

  static Future<List<BooksDifference>> bookDifferencesIn(
    SqliteReadContext tx,
    String tenantId, {
    String? asOn,
  }) async {
    final book = {
      for (final r in await tx.getAll(
        "SELECT account_id, SUM(CASE direction WHEN 'in' THEN amount_paise "
        'ELSE -amount_paise END) AS bal FROM cash_bank_entries '
        'WHERE tenant_id = ? ${asOn == null ? '' : 'AND entry_date <= ? '}'
        'GROUP BY account_id',
        [tenantId, ?asOn],
      ))
        r['account_id']! as String: r['bal']! as int,
    };
    final journal = await _journalBalances(tx, tenantId, asOn: asOn);
    final banks = await tx.getAll(
      'SELECT id, name FROM bank_accounts WHERE tenant_id = ?',
      [tenantId],
    );
    int actual(String id) =>
        journal[JournalWriter.accountId(tenantId, BookAccount(id))] ?? 0;
    return [
      for (final b in banks)
        if ((book[b['id']] ?? 0) != actual(b['id']! as String))
          BooksDifference(
            id: b['id']! as String,
            name: b['name']! as String,
            expectedPaise: book[b['id']] ?? 0,
            actualPaise: actual(b['id']! as String),
          ),
    ];
  }

  /// Debit minus credit per account id over all journal lines.
  static Future<Map<String, int>> _journalBalances(
    SqliteReadContext tx,
    String tenantId, {
    String? asOn,
  }) async => {
    for (final r in await tx.getAll(
      'SELECT l.account_id, SUM(l.debit_paise - l.credit_paise) AS bal '
      'FROM journal_lines l '
      'JOIN journal_entries j ON j.id = l.journal_entry_id '
      'WHERE l.tenant_id = ? ${asOn == null ? '' : 'AND j.entry_date <= ? '}'
      'GROUP BY l.account_id',
      [tenantId, ?asOn],
    ))
      r['account_id']! as String: r['bal']! as int,
  };
}
