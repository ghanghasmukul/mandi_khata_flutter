import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/day_book.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart'
    show SqliteReadContext, SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Every party's khata in the local database (offline-first).
///
/// Append-only: entries are only ever inserted. An edit is a reversal plus a
/// replacement, written in ONE local transaction, which the connector
/// uploads all-or-nothing. All maths comes from khata_core.
class LedgerRepository {
  LedgerRepository(this._db, {this.planDefaults = const {}});

  final PowerSyncDatabase _db;

  /// Values from the subscription plan (settings cascade, step 5.1).
  final Map<String, Object?> planDefaults;

  static const _columns =
      'id, tenant_id, party_id, entry_date, side, amount_paise, ref_type, '
      'ref_id, narration, reverses_id, replaces_id, device_id, created_by, '
      'created_at';

  static LedgerEntry fromRow(Map<String, Object?> row) => LedgerEntry(
    id: row['id']! as String,
    partyId: row['party_id']! as String,
    entryDate: LedgerDate.parse(row['entry_date']! as String),
    side: Side.parse(row['side']! as String),
    amount: Money(row['amount_paise']! as int),
    refType: RefType.parse(row['ref_type']! as String),
    refId: row['ref_id'] as String?,
    narration: row['narration'] as String?,
    reversesId: row['reverses_id'] as String?,
    replacesId: row['replaces_id'] as String?,
    createdAt: DateTime.parse(row['created_at']! as String),
  );

  /// Posts [draft] in its own transaction, with its audit row.
  Future<LedgerPostResult> append(
    WriteContext ctx,
    LedgerDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (draft.refType == RefType.reversal) {
      return const LedgerInvalid(LedgerProblem.useReverse);
    }
    if (!draft.amount.isPositive) {
      return const LedgerInvalid(LedgerProblem.amountNotPositive);
    }
    final needed = LedgerPosting.requiredPermission(draft.refType);
    if (needed != null && !can(needed)) return LedgerNotPermitted(needed);
    final when = now ?? DateTime.now();

    return await _db.writeTransaction((tx) async {
      final refused = await checkDate(
        tx,
        ctx,
        draft.refType,
        draft.entryDate ?? LedgerDate.fromDateTime(when),
        can: can,
        now: when,
        planDefaults: planDefaults,
      );
      if (refused != null) return refused;
      if (!await _partyExists(tx, ctx.tenantId, draft.partyId)) {
        return const LedgerNotFound();
      }
      final entry = await post(tx, ctx, draft, now: when);
      return LedgerPosted([entry]);
    });
  }

  static const _backdateKey = 'business.backdate_days';

  /// The business's back-date window in days (`business.backdate_days`).
  static Future<int> backdateDays(
    SqliteReadContext tx,
    String tenantId, {
    Map<String, Object?> planDefaults = const {},
  }) async {
    final rows = await SettingsRepository.rowsIn(tx, tenantId, businessTarget);
    return SettingsResolver(
          rows,
          planDefaults: planDefaults,
        ).resolve(_backdateKey).value!
        as int;
  }

  /// Null when an entry of [refType] dated [entryDate] may be posted now,
  /// else why not: an entry dated more than `business.backdate_days` before
  /// today, or in the future, needs `entries.reverse` (khata_core
  /// `LedgerPosting.requiredPermissions`; the server checks the same).
  /// Documents call this before posting in their own transaction.
  static Future<LedgerNotPermitted?> checkDate(
    SqliteReadContext tx,
    WriteContext ctx,
    RefType refType,
    LedgerDate entryDate, {
    required bool Function(Permission) can,
    required DateTime now,
    Map<String, Object?> planDefaults = const {},
  }) async {
    if (can(Permission.entriesReverse)) return null;
    final days = await backdateDays(
      tx,
      ctx.tenantId,
      planDefaults: planDefaults,
    );
    final needed = LedgerPosting.requiredPermissions(
      refType,
      entryDate: entryDate,
      recordedOn: LedgerDate.fromDateTime(now),
      backdateDays: days,
    );
    return needed.contains(Permission.entriesReverse)
        ? LedgerNotPermitted(Permission.entriesReverse, backdateDays: days)
        : null;
  }

  /// Posts [draft] inside [tx], the caller's transaction: documents
  /// (arrivals, payments…) post to the khata in the same local transaction
  /// as the document itself. The caller checks permission and the party.
  static Future<LedgerEntry> post(
    SqliteWriteContext tx,
    WriteContext ctx,
    LedgerDraft draft, {
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    final entry = LedgerEntry(
      id: const Uuid().v4(),
      partyId: draft.partyId,
      entryDate: draft.entryDate ?? LedgerDate.fromDateTime(when),
      side: draft.side,
      amount: draft.amount,
      refType: draft.refType,
      refId: draft.refId,
      narration: _clean(draft.narration),
      createdAt: when.toUtc(),
    );
    await _insert(tx, ctx, entry);
    await AuditWriter.record(
      tx,
      ctx,
      table: 'ledger_entries',
      rowId: entry.id,
      action: AuditAction.insert,
      after: _auditValues(entry),
      at: when,
    );
    return entry;
  }

  /// Cancels entry [id] with a reversal (needs `entries.reverse`). Dated
  /// like the original unless [entryDate] is given (e.g. a bounced cheque).
  Future<LedgerPostResult> reverse(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    LedgerDate? entryDate,
    String? narration,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse)) {
      return const LedgerNotPermitted(Permission.entriesReverse);
    }
    return await _db.writeTransaction(
      (tx) => reverseIn(
        tx,
        ctx,
        id,
        entryDate: entryDate,
        narration: narration,
        now: now,
      ),
    );
  }

  /// Reverses entry [id] inside [tx], the caller's transaction (a document
  /// being reversed reverses its entries with it). The caller checks
  /// permission.
  static Future<LedgerPostResult> reverseIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    String id, {
    LedgerDate? entryDate,
    String? narration,
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    final (:original, :problem) = await _reversible(tx, ctx.tenantId, id);
    if (original == null) return problem!;
    final reversal = ReversalBuilder.reverse(
      original,
      id: const Uuid().v4(),
      createdAt: when.toUtc(),
      entryDate: entryDate,
      narration: _clean(narration),
    );
    await _insert(tx, ctx, reversal);
    await AuditWriter.record(
      tx,
      ctx,
      table: 'ledger_entries',
      rowId: reversal.id,
      action: AuditAction.reverse,
      before: _auditValues(original),
      after: _auditValues(reversal),
      at: when,
    );
    return LedgerPosted([reversal]);
  }

  /// Edits entry [id]: reverses it and posts a replacement with the given
  /// changes, in one transaction (needs `entries.reverse`). The audit log
  /// shows the original as "before" and the replacement as "after".
  Future<LedgerPostResult> correct(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    Money? amount,
    Side? side,
    LedgerDate? entryDate,
    String? narration,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse)) {
      return const LedgerNotPermitted(Permission.entriesReverse);
    }
    if (amount != null && !amount.isPositive) {
      return const LedgerInvalid(LedgerProblem.amountNotPositive);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final (:original, :problem) = await _reversible(tx, ctx.tenantId, id);
      if (original == null) return problem!;
      final newNarration = narration == null ? null : _clean(narration);
      if ((amount ?? original.amount) == original.amount &&
          (side ?? original.side) == original.side &&
          (entryDate ?? original.entryDate) == original.entryDate &&
          (narration == null || newNarration == original.narration)) {
        return const LedgerInvalid(LedgerProblem.nothingChanged);
      }
      final c = ReversalBuilder.correct(
        original,
        reversalId: const Uuid().v4(),
        replacementId: const Uuid().v4(),
        createdAt: when.toUtc(),
        amount: amount,
        side: side,
        entryDate: entryDate,
        narration: newNarration,
      );
      await _insert(tx, ctx, c.reversal);
      await _insert(tx, ctx, c.replacement);
      await AuditWriter.record(
        tx,
        ctx,
        table: 'ledger_entries',
        rowId: c.reversal.id,
        action: AuditAction.reverse,
        before: _auditValues(original),
        after: _auditValues(c.reversal),
        at: when,
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'ledger_entries',
        rowId: c.replacement.id,
        action: AuditAction.insert,
        before: _auditValues(original),
        after: _auditValues(c.replacement),
        at: when,
      );
      return LedgerPosted([c.reversal, c.replacement]);
    });
  }

  /// A party's statement for [from]..[to] (either open), with the balance
  /// brought forward and running baki. Live.
  Stream<Statement> watchStatement(
    String tenantId,
    String partyId, {
    LedgerDate? from,
    LedgerDate? to,
  }) => _db
      .watch(
        // The whole khata: the balance brought forward and reversal pairs
        // across the period's edges need entries outside it.
        'SELECT $_columns FROM ledger_entries '
        'WHERE tenant_id = ? AND party_id = ?',
        parameters: [tenantId, partyId],
        triggerOnTables: const {'ledger_entries'},
      )
      .map(
        (rows) =>
            LedgerCalculator.statement(rows.map(fromRow), from: from, to: to),
      );

  static const _dayBookWhere =
      'WHERE e.tenant_id = ? '
      'AND (? IS NULL OR e.entry_date >= ?) '
      'AND (? IS NULL OR e.entry_date <= ?) '
      'AND (? IS NULL OR e.party_id = ?) '
      'AND (? IS NULL OR e.ref_type = ?) ';

  static List<Object?> _dayBookParams(String tenantId, LedgerFilter f) => [
    tenantId,
    f.from?.toString(),
    f.from?.toString(),
    f.to?.toString(),
    f.to?.toString(),
    f.partyId,
    f.partyId,
    f.refType?.dbName,
    f.refType?.dbName,
  ];

  /// How many entries match [filter] and their udhaar / jama totals. Live.
  Stream<DayBookSummary> watchDayBookSummary(
    String tenantId,
    LedgerFilter filter,
  ) => _db
      .watch(
        'SELECT COUNT(*) AS n, '
        "COALESCE(SUM(CASE e.side WHEN 'udhaar' THEN e.amount_paise END), 0) "
        'AS udhaar, '
        "COALESCE(SUM(CASE e.side WHEN 'jama' THEN e.amount_paise END), 0) "
        'AS jama FROM ledger_entries e $_dayBookWhere',
        parameters: _dayBookParams(tenantId, filter),
        triggerOnTables: const {'ledger_entries'},
      )
      .map((rows) {
        final r = rows.first;
        return (
          count: r['n']! as int,
          udhaar: Money(r['udhaar']! as int),
          jama: Money(r['jama']! as int),
        );
      });

  /// Entries [offset]..[offset] + [limit] of the day book for [filter],
  /// newest first, each with its party's running baki. Live.
  ///
  /// Paged so 100k entries never load at once: the page is picked first
  /// (index on tenant + date), then the baki is summed only for the page's
  /// rows over their party's entries up to them — the same order and rule as
  /// `LedgerCalculator.statement` (checked by test).
  Stream<List<DayBookRow>> watchDayBookPage(
    String tenantId,
    LedgerFilter filter, {
    required int offset,
    required int limit,
  }) => _db
      .watch(
        'SELECT p.*, pa.name AS party_name, pa.code AS party_code, '
        "(SELECT SUM(CASE x.side WHEN 'jama' THEN x.amount_paise "
        'ELSE -x.amount_paise END) FROM ledger_entries x '
        'WHERE x.tenant_id = p.tenant_id AND x.party_id = p.party_id '
        'AND (x.entry_date < p.entry_date OR (x.entry_date = p.entry_date '
        'AND (x.created_at < p.created_at OR (x.created_at = p.created_at '
        'AND x.id <= p.id))))) AS balance, '
        '(SELECT r.id FROM ledger_entries r WHERE r.tenant_id = p.tenant_id '
        'AND r.reverses_id = p.id LIMIT 1) AS reversed_by_id '
        'FROM (SELECT e.* FROM ledger_entries e $_dayBookWhere'
        'ORDER BY e.entry_date DESC, e.created_at DESC, e.id DESC '
        'LIMIT ? OFFSET ?) p '
        'LEFT JOIN parties pa ON pa.id = p.party_id '
        'AND pa.tenant_id = p.tenant_id '
        'ORDER BY p.entry_date DESC, p.created_at DESC, p.id DESC',
        parameters: [..._dayBookParams(tenantId, filter), limit, offset],
        triggerOnTables: const {'ledger_entries', 'parties'},
      )
      .map(
        (rows) => [
          for (final r in rows)
            DayBookRow(
              entry: fromRow(r),
              partyName: r['party_name'] as String? ?? '',
              partyCode: r['party_code'] as String? ?? '',
              balance: Money(r['balance']! as int),
              reversedById: r['reversed_by_id'] as String?,
            ),
        ],
      );

  /// Σ jama − Σ udhaar). Live.
  ///
  /// Summed in SQL per side (a list of thousands of parties must not load
  /// every entry); the same rule as `LedgerCalculator.balance`, checked by
  /// test.
  Stream<Map<String, Money>> watchBalances(String tenantId) => _db
      .watch(
        'SELECT party_id, '
        "SUM(CASE side WHEN 'jama' THEN amount_paise ELSE 0 END) AS jama, "
        "SUM(CASE side WHEN 'udhaar' THEN amount_paise ELSE 0 END) AS udhaar "
        'FROM ledger_entries WHERE tenant_id = ? GROUP BY party_id',
        parameters: [tenantId],
        triggerOnTables: const {'ledger_entries'},
      )
      .map(
        (rows) => {
          for (final r in rows)
            r['party_id']! as String:
                Money(r['jama']! as int) - Money(r['udhaar']! as int),
        },
      );

  static Future<bool> _partyExists(
    SqliteWriteContext tx,
    String tenantId,
    String partyId,
  ) async =>
      await tx.getOptional(
        'SELECT 1 FROM parties '
        'WHERE tenant_id = ? AND id = ? AND deleted_at IS NULL',
        [tenantId, partyId],
      ) !=
      null;

  /// The entry, or why it cannot be reversed.
  static Future<({LedgerEntry? original, LedgerPostResult? problem})>
  _reversible(SqliteWriteContext tx, String tenantId, String id) async {
    final row = await tx.getOptional(
      'SELECT $_columns FROM ledger_entries WHERE tenant_id = ? AND id = ?',
      [tenantId, id],
    );
    if (row == null) return (original: null, problem: const LedgerNotFound());
    final entry = fromRow(row);
    if (entry.isReversal) {
      return (
        original: null,
        problem: const LedgerInvalid(LedgerProblem.isReversal),
      );
    }
    final reversed = await tx.getOptional(
      'SELECT 1 FROM ledger_entries WHERE tenant_id = ? AND reverses_id = ?',
      [tenantId, id],
    );
    if (reversed != null) {
      return (
        original: null,
        problem: const LedgerInvalid(LedgerProblem.alreadyReversed),
      );
    }
    return (original: entry, problem: null);
  }

  static Future<void> _insert(
    SqliteWriteContext tx,
    WriteContext ctx,
    LedgerEntry e,
  ) => tx.execute(
    'INSERT INTO ledger_entries ($_columns) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      e.id,
      ctx.tenantId,
      e.partyId,
      e.entryDate.toString(),
      e.side.dbName,
      e.amount.paise,
      e.refType.dbName,
      e.refId,
      e.narration,
      e.reversesId,
      e.replacesId,
      ctx.deviceId,
      ctx.userId,
      e.createdAt.toUtc().toIso8601String(),
    ],
  );

  static Map<String, Object?> _auditValues(LedgerEntry e) => {
    'party_id': e.partyId,
    'entry_date': e.entryDate.toString(),
    'side': e.side.dbName,
    'amount_paise': e.amount.paise,
    'ref_type': e.refType.dbName,
    'ref_id': ?e.refId,
    'narration': ?e.narration,
    'reverses_id': ?e.reversesId,
    'replaces_id': ?e.replacesId,
  };

  static String? _clean(String? text) {
    final t = text?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}
