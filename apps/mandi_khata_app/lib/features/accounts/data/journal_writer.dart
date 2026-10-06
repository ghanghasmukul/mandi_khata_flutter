import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/period_lock.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:uuid/uuid.dart';

/// Writes the double-entry journal (docs/domain/posting-rules.md) inside the
/// caller's local transaction, next to the document and its khata entries.
///
/// Ids are deterministic (UUID v5), so the same posting on two devices, or a
/// re-run of the back-fill, writes the same rows and the server keeps the
/// first. The account ids match the server seed and triggers
/// (`private.chart_id` in the chart migration); account ROWS are created by
/// the server, never here, so this only needs their ids.
abstract final class JournalWriter {
  static const _accountNamespace = '5c0f9d3a-8e21-4b6c-a7d4-1e9b3f2a6c80';
  static const _journalNamespace = 'a41d7e92-3b58-4c06-8f1a-6d2e9c5b7a13';

  /// The id of [account] in [tenantId]: the same value the server computes.
  static String accountId(String tenantId, JournalAccount account) =>
      switch (account) {
        PartyAccount(:final partyId) => const Uuid().v5(
          _accountNamespace,
          '$tenantId|party|$partyId',
        ),
        BookAccount(:final bankAccountId) => const Uuid().v5(
          _accountNamespace,
          '$tenantId|book|$bankAccountId',
        ),
        SystemJournalAccount(account: final a) => const Uuid().v5(
          _accountNamespace,
          '$tenantId|account|${a.code}',
        ),
        ChartAccount(:final accountId) => accountId,
      };

  /// The account of expense category [categoryId] (made by the server).
  static String expenseAccountId(String tenantId, String categoryId) =>
      const Uuid().v5(_accountNamespace, '$tenantId|expense|$categoryId');

  /// The id of a seeded expense category.
  static String expenseCategoryId(String tenantId, ExpenseCategorySeed seed) =>
      const Uuid().v5(
        _accountNamespace,
        '$tenantId|expense_category|${seed.code}',
      );

  /// The id of a system group, e.g. `sundry_debtors`.
  static String groupId(String tenantId, AccountGroup group) =>
      const Uuid().v5(_accountNamespace, '$tenantId|group|${group.code}');

  static String entryId(String tenantId, String sourceKey) =>
      const Uuid().v5(_journalNamespace, '$tenantId|journal|$sourceKey');

  static String _lineId(String entryId, int index) =>
      const Uuid().v5(_journalNamespace, '$entryId|line|$index');

  static String sourceType(String sourceKey) =>
      sourceKey.substring(0, sourceKey.indexOf(':'));

  /// Writes [draft] with its lines and one audit row. Does nothing when the
  /// entry already exists (idempotent). Returns whether it wrote. A
  /// voucher's entry names it in [voucherId].
  static Future<bool> post(
    SqliteWriteContext tx,
    WriteContext ctx,
    JournalEntryDraft draft, {
    DateTime? now,
    String? voucherId,
  }) async {
    if (draft.isReversal) {
      throw ArgumentError('Use JournalWriter.reverse for a reversal');
    }
    final when = (now ?? DateTime.now()).toUtc();
    final id = entryId(ctx.tenantId, draft.sourceKey);
    final taken = await tx.getOptional(
      'SELECT 1 FROM journal_entries WHERE tenant_id = ? AND source_key = ?',
      [ctx.tenantId, draft.sourceKey],
    );
    if (taken != null) return false;
    final lockReason = await _lockReason(tx, ctx, draft.date);

    await tx.execute(
      'INSERT INTO journal_entries (id, tenant_id, source_key, source_type, '
      'voucher_id, entry_date, narration, reverses_id, device_id, '
      'created_by, created_at, lock_reason) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        ctx.tenantId,
        draft.sourceKey,
        sourceType(draft.sourceKey),
        voucherId,
        draft.date.toString(),
        draft.narration,
        null,
        ctx.deviceId,
        ctx.userId,
        when.toIso8601String(),
        lockReason,
      ],
    );
    for (var i = 0; i < draft.lines.length; i++) {
      final line = draft.lines[i];
      await tx.execute(
        'INSERT INTO journal_lines (id, tenant_id, journal_entry_id, line_no, '
        'account_id, debit_paise, credit_paise, memo, created_by, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          _lineId(id, i),
          ctx.tenantId,
          id,
          i,
          accountId(ctx.tenantId, line.account),
          line.debit.paise,
          line.credit.paise,
          line.memo,
          ctx.userId,
          when.toIso8601String(),
        ],
      );
    }
    await AuditWriter.record(
      tx,
      ctx,
      table: 'journal_entries',
      rowId: id,
      action: AuditAction.insert,
      after: {
        'source_key': draft.sourceKey,
        'entry_date': draft.date.toString(),
        'total_paise': draft.total.paise,
        'lines': draft.lines.length,
        'voucher_id': ?voucherId,
        'lock_reason': ?lockReason,
      },
      at: when,
    );
    return true;
  }

  /// Reverses the journal entry of [sourceKey] on [on] (the original's date
  /// when null): the same lines with debit and credit swapped. Does nothing
  /// when the document has no journal entry (older than the books; the
  /// back-fill writes both sides) or was already reversed.
  static Future<bool> reverse(
    SqliteWriteContext tx,
    WriteContext ctx,
    String sourceKey, {
    LedgerDate? on,
    String? narration,
    DateTime? now,
  }) async {
    final original = await tx.getOptional(
      'SELECT id, entry_date, narration FROM journal_entries '
      'WHERE tenant_id = ? AND source_key = ?',
      [ctx.tenantId, sourceKey],
    );
    if (original == null) return false;
    final lines = await tx.getAll(
      'SELECT account_id, debit_paise, credit_paise, memo FROM journal_lines '
      'WHERE tenant_id = ? AND journal_entry_id = ? ORDER BY line_no',
      [ctx.tenantId, original['id']],
    );
    final date = on ?? LedgerDate.parse(original['entry_date']! as String);
    final when = (now ?? DateTime.now()).toUtc();
    final id = entryId(ctx.tenantId, 'reversal:$sourceKey');
    final taken = await tx.getOptional(
      'SELECT 1 FROM journal_entries WHERE tenant_id = ? AND id = ?',
      [ctx.tenantId, id],
    );
    if (taken != null) return false;
    final lockReason = await _lockReason(tx, ctx, date);

    await tx.execute(
      'INSERT INTO journal_entries (id, tenant_id, source_key, source_type, '
      'entry_date, narration, reverses_id, device_id, created_by, created_at, '
      'lock_reason) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        ctx.tenantId,
        'reversal:$sourceKey',
        'reversal',
        date.toString(),
        narration ?? original['narration'],
        original['id'],
        ctx.deviceId,
        ctx.userId,
        when.toIso8601String(),
        lockReason,
      ],
    );
    var total = 0;
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      total += l['credit_paise']! as int;
      await tx.execute(
        'INSERT INTO journal_lines (id, tenant_id, journal_entry_id, line_no, '
        'account_id, debit_paise, credit_paise, memo, created_by, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          _lineId(id, i),
          ctx.tenantId,
          id,
          i,
          l['account_id'],
          l['credit_paise'],
          l['debit_paise'],
          l['memo'],
          ctx.userId,
          when.toIso8601String(),
        ],
      );
    }
    await AuditWriter.record(
      tx,
      ctx,
      table: 'journal_entries',
      rowId: id,
      action: AuditAction.reverse,
      before: {'source_key': sourceKey},
      after: {
        'source_key': 'reversal:$sourceKey',
        'entry_date': date.toString(),
        'total_paise': total,
        'lines': lines.length,
        'reverses_id': original['id'],
        'lock_reason': ?lockReason,
      },
      at: when,
    );
    return true;
  }

  /// The owner's reason when [date] is in a closed financial year (the
  /// server refuses such an entry without one); null otherwise.
  static Future<String?> _lockReason(
    SqliteWriteContext tx,
    WriteContext ctx,
    LedgerDate date,
  ) async =>
      ctx.lockReason != null &&
          await PeriodLock.isLocked(tx, ctx.tenantId, date)
      ? ctx.lockReason
      : null;

  /// The source key of the journal entry behind khata entry [e] (posting-rules
  /// section 4), or null when it has none (crop-proceeds loan lines, which net
  /// to nothing, and reversals). Looks up a loan disbursal's payment.
  static Future<String?> sourceKeyOf(
    SqliteReadContext tx,
    String tenantId,
    LedgerEntry e,
  ) async {
    final ref = e.refId;
    switch (e.refType) {
      case RefType.arrival:
        return ref == null ? null : 'lot:$ref';
      case RefType.payment || RefType.receipt:
        return ref == null ? null : 'payment:$ref';
      case RefType.loanRepayment:
        // A cash / bank repayment points at its payment; crop proceeds at the
        // loan, and write no journal.
        if (ref == null) return null;
        final payment = await tx.getOptional(
          'SELECT 1 FROM payments WHERE tenant_id = ? AND id = ?',
          [tenantId, ref],
        );
        return payment == null ? null : 'payment:$ref';
      case RefType.loanDisbursal:
        if (ref == null) return null;
        final payment = await tx.getOptional(
          'SELECT id FROM payments WHERE tenant_id = ? AND loan_id = ? '
          "AND direction = 'to_party' ORDER BY created_at LIMIT 1",
          [tenantId, ref],
        );
        return payment == null ? null : 'payment:${payment['id']}';
      case RefType.interest:
        return ref == null ? null : 'interest:$ref';
      case RefType.journal:
        if (ref == null) return 'entry:${e.id}';
        final waiver = await tx.getOptional(
          'SELECT 1 FROM interest_postings WHERE tenant_id = ? AND id = ? '
          "AND kind = 'waiver'",
          [tenantId, ref],
        );
        return waiver == null ? null : 'waiver:$ref';
      case RefType.openingBalance:
        return 'entry:${e.id}';
      case RefType.voucher:
        return ref == null ? null : 'voucher:$ref';
      case RefType.reversal ||
          RefType.shopSale ||
          RefType.shopReturn ||
          RefType.purchase ||
          RefType.expense:
        return null;
    }
  }
}
