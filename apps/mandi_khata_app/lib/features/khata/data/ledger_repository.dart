import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Every party's khata in the local database (offline-first).
///
/// Append-only: entries are only ever inserted. An edit is a reversal plus a
/// replacement, written in ONE local transaction, which the connector
/// uploads all-or-nothing. All maths comes from khata_core.
class LedgerRepository {
  LedgerRepository(this._db);

  final PowerSyncDatabase _db;

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

    return await _db.writeTransaction((tx) async {
      if (!await _partyExists(tx, ctx.tenantId, draft.partyId)) {
        return const LedgerNotFound();
      }
      final entry = await post(tx, ctx, draft, now: now);
      return LedgerPosted([entry]);
    });
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
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
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
    });
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

  /// Balance of every party with entries in [tenantId] (party id →
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
