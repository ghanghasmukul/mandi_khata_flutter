import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/cash_book_repository.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart'
    show SqliteReadContext, SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// A reconciled book line, with the statement line it matched (if any).
@immutable
class ReconciledRow {
  const ReconciledRow({
    required this.id,
    required this.book,
    required this.on,
    this.statement,
  });

  final String id;
  final BookLine book;
  final StatementLine? statement;
  final LedgerDate on;
}

/// What is left to reconcile on one bank account.
@immutable
class ReconState {
  const ReconState({
    required this.book,
    required this.statement,
    required this.reconciled,
  });

  static const empty = ReconState(book: [], statement: [], reconciled: []);

  /// Book lines not reconciled yet, oldest first.
  final List<BookLine> book;

  /// Statement lines not matched yet, oldest first.
  final List<StatementLine> statement;

  /// Reconciled lines, newest first.
  final List<ReconciledRow> reconciled;
}

/// What an import did.
@immutable
class StatementImportResult {
  const StatementImportResult({
    required this.added,
    required this.duplicates,
    required this.errors,
  });

  final int added;

  /// Lines already imported before (same date, amount, text…).
  final int duplicates;
  final List<StatementRowError> errors;
}

/// Bank statements and reconciliation in the local database
/// (docs/domain/posting-rules.md, 11.3). Needs `finance.view`; every write
/// is audited.
class ReconciliationRepository {
  ReconciliationRepository(this._db);

  final PowerSyncDatabase _db;

  static const _namespace = '6e2b9c41-7d3a-4f85-b0c2-9a1e5d7f3b64';

  static const tables = {
    'cash_bank_entries',
    'bank_statement_lines',
    'bank_reconciliations',
    'payments',
    'vouchers',
    'parties',
  };

  /// The statement mapping saved for [accountId], or null.
  Future<StatementMapping?> mapping(String tenantId, String accountId) async {
    final r = await _db.getOptional(
      'SELECT statement_mapping FROM bank_accounts '
      'WHERE tenant_id = ? AND id = ?',
      [tenantId, accountId],
    );
    final raw = r?['statement_mapping'] as String?;
    return raw == null ? null : StatementMapping.fromJson(jsonDecode(raw));
  }

  /// Reads [sheet] with [mapping], saves the mapping on the account and
  /// adds every new line. A line already imported (same account, date,
  /// direction, amount, reference, text, balance) is not added twice, on
  /// any device: its id is UUID v5 of those.
  Future<StatementImportResult> import(
    WriteContext ctx,
    String accountId,
    Sheet sheet,
    StatementMapping mapping, {
    DateTime? now,
  }) async {
    final when = (now ?? DateTime.now()).toUtc();
    final at = when.toIso8601String();
    final parsed = StatementParser.parse(sheet, mapping);
    return await _db.writeTransaction((tx) async {
      final account = await tx.getOptional(
        'SELECT statement_mapping FROM bank_accounts WHERE tenant_id = ? '
        "AND id = ? AND kind = 'bank'",
        [ctx.tenantId, accountId],
      );
      if (account == null) {
        return StatementImportResult(
          added: 0,
          duplicates: 0,
          errors: parsed.errors,
        );
      }
      final json = jsonEncode(mapping.toJson());
      if (account['statement_mapping'] != json) {
        await tx.execute(
          'UPDATE bank_accounts SET statement_mapping = ?, updated_at = ? '
          'WHERE tenant_id = ? AND id = ?',
          [json, at, ctx.tenantId, accountId],
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'bank_accounts',
          rowId: accountId,
          action: AuditAction.update,
          after: {'statement_mapping': mapping.toJson()},
          at: when,
        );
      }
      final batch = const Uuid().v4();
      var added = 0;
      var duplicates = 0;
      // The same row twice in one file is two real lines: count repeats.
      final seen = <String, int>{};
      for (final r in parsed.rows) {
        final n = seen[r.fingerprint] = (seen[r.fingerprint] ?? 0) + 1;
        final id = const Uuid().v5(
          _namespace,
          '${ctx.tenantId}|$accountId|${r.fingerprint}|$n',
        );
        final taken = await tx.getOptional(
          'SELECT 1 FROM bank_statement_lines WHERE tenant_id = ? AND id = ?',
          [ctx.tenantId, id],
        );
        if (taken != null) {
          duplicates++;
          continue;
        }
        await tx.execute(
          'INSERT INTO bank_statement_lines (id, tenant_id, bank_account_id, '
          'txn_date, direction, amount_paise, reference, description, '
          'balance_paise, import_batch, device_id, created_by, created_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            id,
            ctx.tenantId,
            accountId,
            r.date.toString(),
            if (r.isIn) 'in' else 'out',
            r.amount.paise,
            r.reference,
            r.description,
            r.balance?.paise,
            batch,
            ctx.deviceId,
            ctx.userId,
            at,
          ],
        );
        added++;
      }
      await AuditWriter.record(
        tx,
        ctx,
        table: 'bank_statement_lines',
        rowId: batch,
        action: AuditAction.insert,
        after: {
          'bank_account_id': accountId,
          'added': added,
          'duplicates': duplicates,
          'errors': parsed.errors.length,
        },
        at: when,
      );
      return StatementImportResult(
        added: added,
        duplicates: duplicates,
        errors: parsed.errors,
      );
    });
  }

  /// What is left to reconcile on [accountId]. Live.
  Stream<ReconState> watch(String tenantId, String accountId) => _db
      .watch('SELECT 1', triggerOnTables: tables)
      .asyncMap(
        (_) => _db.readTransaction((tx) => state(tx, tenantId, accountId)),
      );

  static Future<ReconState> state(
    SqliteReadContext tx,
    String tenantId,
    String accountId,
  ) async {
    final book = await CashBookRepository.lines(tx, tenantId, accountId);
    final statement = await _statement(tx, tenantId, accountId);
    final recon = await tx.getAll(
      'SELECT id, book_line_id, statement_line_id, reconciled_on '
      'FROM bank_reconciliations WHERE tenant_id = ? AND bank_account_id = ? '
      'AND deleted_at IS NULL ORDER BY reconciled_on DESC, created_at DESC',
      [tenantId, accountId],
    );
    final bookById = {for (final b in book) b.id: b};
    final statementById = {for (final s in statement) s.id: s};
    final doneBook = <String>{};
    final doneStatement = <String>{};
    final reconciled = <ReconciledRow>[];
    for (final r in recon) {
      final b = bookById[r['book_line_id']];
      if (b == null) continue;
      final sid = r['statement_line_id'] as String?;
      doneBook.add(b.id);
      if (sid != null) doneStatement.add(sid);
      reconciled.add(
        ReconciledRow(
          id: r['id']! as String,
          book: b,
          statement: sid == null ? null : statementById[sid],
          on: LedgerDate.parse(r['reconciled_on']! as String),
        ),
      );
    }
    return ReconState(
      book: [
        for (final b in book)
          if (!doneBook.contains(b.id)) b,
      ],
      statement: [
        for (final s in statement)
          if (!doneStatement.contains(s.id)) s,
      ],
      reconciled: reconciled,
    );
  }

  static Future<List<StatementLine>> _statement(
    SqliteReadContext tx,
    String tenantId,
    String accountId,
  ) async {
    final rows = await tx.getAll(
      'SELECT * FROM bank_statement_lines WHERE tenant_id = ? '
      'AND bank_account_id = ? ORDER BY txn_date, created_at, id',
      [tenantId, accountId],
    );
    return [
      for (final r in rows)
        StatementLine(
          id: r['id']! as String,
          date: LedgerDate.parse(r['txn_date']! as String),
          isIn: r['direction'] == 'in',
          amount: Money(r['amount_paise']! as int),
          reference: r['reference'] as String?,
          description: r['description'] as String?,
          balance: r['balance_paise'] == null
              ? null
              : Money(r['balance_paise']! as int),
        ),
    ];
  }

  /// Matches what [BankReconciliation.autoMatch] pairs, reconciled on the
  /// statement line's date. Returns how many.
  Future<int> autoMatch(
    WriteContext ctx,
    String accountId, {
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final s = await state(tx, ctx.tenantId, accountId);
      final matches = BankReconciliation.autoMatch(s.statement, s.book);
      final statementById = {for (final x in s.statement) x.id: x};
      for (final m in matches) {
        await _insert(
          tx,
          ctx,
          accountId,
          bookLineId: m.bookLineId,
          statementLineId: m.statementLineId,
          on: statementById[m.statementLineId]!.date,
          when: when,
        );
      }
      return matches.length;
    });
  }

  /// Pairs one book line with one statement line by hand (same direction
  /// and amount). False when they do not fit or one is taken.
  Future<bool> match(
    WriteContext ctx,
    String accountId,
    String bookLineId,
    String statementLineId, {
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final s = await state(tx, ctx.tenantId, accountId);
      final b = s.book.where((x) => x.id == bookLineId).firstOrNull;
      final st = s.statement.where((x) => x.id == statementLineId).firstOrNull;
      if (b == null || st == null || !BankReconciliation.canMatch(b, st)) {
        return false;
      }
      await _insert(
        tx,
        ctx,
        accountId,
        bookLineId: b.id,
        statementLineId: st.id,
        on: st.date,
        when: when,
      );
      return true;
    });
  }

  /// Marks book lines reconciled on [on] without a statement line (e.g. a
  /// payment and its reversal that never reached the bank). False when one
  /// is already reconciled or not a line of this account.
  Future<bool> reconcileWithoutStatement(
    WriteContext ctx,
    String accountId,
    List<String> bookLineIds,
    LedgerDate on, {
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final s = await state(tx, ctx.tenantId, accountId);
      final open = {for (final b in s.book) b.id};
      if (bookLineIds.isEmpty || !bookLineIds.every(open.contains)) {
        return false;
      }
      for (final id in bookLineIds) {
        await _insert(tx, ctx, accountId, bookLineId: id, on: on, when: when);
      }
      return true;
    });
  }

  /// Undoes reconciliation [id] (soft delete).
  Future<void> undo(WriteContext ctx, String id, {DateTime? now}) async {
    final when = (now ?? DateTime.now()).toUtc();
    await _db.writeTransaction((tx) async {
      final at = when.toIso8601String();
      await tx.execute(
        'UPDATE bank_reconciliations SET deleted_at = ?, updated_at = ? '
        'WHERE tenant_id = ? AND id = ? AND deleted_at IS NULL',
        [at, at, ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'bank_reconciliations',
        rowId: id,
        action: AuditAction.softDelete,
        after: {'deleted_at': at},
        at: when,
      );
    });
  }

  /// Bank book lines older than [days] days that nobody reconciled, over
  /// every bank account; a line reversed by another (both unreconciled) is
  /// not counted. Live (dashboard).
  Stream<int> watchStale(
    String tenantId, {
    required LedgerDate today,
    int days = 7,
  }) => _db
      .watch(
        'SELECT COUNT(*) AS n FROM cash_bank_entries l '
        "WHERE l.tenant_id = ? AND l.account_kind = 'bank' "
        'AND l.entry_date < ? '
        'AND NOT EXISTS (SELECT 1 FROM bank_reconciliations r '
        'WHERE r.tenant_id = l.tenant_id AND r.book_line_id = l.id '
        'AND r.deleted_at IS NULL) '
        'AND l.reverses_id IS NULL AND NOT EXISTS (SELECT 1 FROM '
        'cash_bank_entries x WHERE x.tenant_id = l.tenant_id '
        'AND x.reverses_id = l.id)',
        parameters: [tenantId, today.addDays(-days).toString()],
        triggerOnTables: const {'cash_bank_entries', 'bank_reconciliations'},
      )
      .map((rows) => rows.first['n']! as int);

  static Future<void> _insert(
    SqliteWriteContext tx,
    WriteContext ctx,
    String accountId, {
    required String bookLineId,
    required LedgerDate on,
    required DateTime when,
    String? statementLineId,
  }) async {
    final id = const Uuid().v4();
    final at = when.toUtc().toIso8601String();
    await tx.execute(
      'INSERT INTO bank_reconciliations (id, tenant_id, bank_account_id, '
      'book_line_id, statement_line_id, reconciled_on, device_id, created_by, '
      'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        ctx.tenantId,
        accountId,
        bookLineId,
        statementLineId,
        on.toString(),
        ctx.deviceId,
        ctx.userId,
        at,
        at,
      ],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'bank_reconciliations',
      rowId: id,
      action: AuditAction.insert,
      after: {
        'book_line_id': bookLineId,
        'statement_line_id': ?statementLineId,
        'reconciled_on': on.toString(),
      },
      at: when,
    );
  }
}
