import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteReadContext;

/// How many documents still have no journal entry.
class BackfillStatus {
  const BackfillStatus({
    required this.lots,
    required this.payments,
    required this.interest,
    required this.waivers,
    required this.entries,
    required this.reversals,
  });

  final int lots;
  final int payments;
  final int interest;
  final int waivers;

  /// Manual khata entries and opening balances.
  final int entries;

  /// Khata reversals whose journal entry is missing.
  final int reversals;

  int get total => lots + payments + interest + waivers + entries + reversals;
  bool get isDone => total == 0;
}

/// What a back-fill run did.
sealed class BackfillResult {
  const BackfillResult();
}

class BackfillNotPermitted extends BackfillResult {
  const BackfillNotPermitted();
}

class BackfillDone extends BackfillResult {
  const BackfillDone({required this.written, required this.problems});

  /// Journal entries written (documents and reversals).
  final int written;

  /// Documents that could not be journalled, with the reason; nothing is
  /// written for them and nothing is "fixed" silently.
  final List<String> problems;
}

/// Gives documents that were posted before the books existed their journal
/// entries (docs/domain/posting-rules.md, section 7). Idempotent: ids are
/// deterministic and a document that already has its entry is skipped, so it
/// can be interrupted and run again, on any device. Needs `entries.reverse`.
class JournalBackfill {
  JournalBackfill(this._db);

  final PowerSyncDatabase _db;

  static const _lotsSql =
      'FROM lots l WHERE l.tenant_id = ? '
      "AND l.status IN ('posted', 'reversed') AND l.posted_at IS NOT NULL "
      'AND NOT EXISTS (SELECT 1 FROM journal_entries j '
      'WHERE j.tenant_id = l.tenant_id '
      "AND j.source_key = 'lot:' || l.id)";
  static const _paymentsSql =
      'FROM payments p WHERE p.tenant_id = ? '
      'AND NOT EXISTS (SELECT 1 FROM journal_entries j '
      'WHERE j.tenant_id = p.tenant_id '
      "AND j.source_key = 'payment:' || p.id)";
  static const _interestSql =
      'FROM interest_postings i WHERE i.tenant_id = ? AND i.kind = ? '
      'AND NOT EXISTS (SELECT 1 FROM journal_entries j '
      'WHERE j.tenant_id = i.tenant_id '
      "AND j.source_key = i.kind || ':' || i.id)";
  static const _entriesSql =
      'FROM ledger_entries e WHERE e.tenant_id = ? AND e.reverses_id IS NULL '
      "AND (e.ref_type = 'opening_balance' "
      "OR (e.ref_type = 'journal' AND e.ref_id IS NULL)) "
      'AND NOT EXISTS (SELECT 1 FROM journal_entries j '
      'WHERE j.tenant_id = e.tenant_id '
      "AND j.source_key = 'entry:' || e.id)";

  Future<BackfillStatus> status(String tenantId) =>
      _db.readTransaction((tx) async {
        Future<int> count(String sql, List<Object?> args) async =>
            (await tx.get('SELECT COUNT(*) AS n $sql', args))['n']! as int;
        return BackfillStatus(
          lots: await count(_lotsSql, [tenantId]),
          payments: await count(_paymentsSql, [tenantId]),
          interest: await count(_interestSql, [tenantId, 'interest']),
          waivers: await count(_interestSql, [tenantId, 'waiver']),
          entries: await count(_entriesSql, [tenantId]),
          reversals: (await _pendingReversals(tx, tenantId)).length,
        );
      });

  Future<BackfillResult> run(
    WriteContext ctx, {
    required bool Function(Permission) can,
    int batchSize = 25,
    void Function(int done, int total)? onProgress,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse)) return const BackfillNotPermitted();
    final when = now ?? DateTime.now();
    final problems = <String>[];
    var written = 0;

    // Pass 1: the documents. Pass 2: their reversals (a reversal needs the
    // original's journal entry to exist).
    final work = await _db.readTransaction(
      (tx) async => [
        ..._lots(
          await tx.getAll('SELECT l.* $_lotsSql ORDER BY l.entry_date, l.id', [
            ctx.tenantId,
          ]),
        ),
        ..._payments(
          await tx.getAll(
            'SELECT p.* $_paymentsSql ORDER BY p.entry_date, p.id',
            [ctx.tenantId],
          ),
        ),
        ..._interest(
          await tx.getAll(
            'SELECT i.* $_interestSql ORDER BY i.period_to, i.id',
            [ctx.tenantId, 'interest'],
          ),
        ),
        ..._interest(
          await tx.getAll(
            'SELECT i.* $_interestSql ORDER BY i.period_to, i.id',
            [ctx.tenantId, 'waiver'],
          ),
        ),
        ..._entries(
          await tx.getAll(
            'SELECT e.* $_entriesSql ORDER BY e.entry_date, e.created_at, e.id',
            [ctx.tenantId],
          ),
        ),
      ],
    );
    final total = work.length;
    var done = 0;
    for (var i = 0; i < work.length; i += batchSize) {
      final batch = work.skip(i).take(batchSize).toList();
      await _db.writeTransaction((tx) async {
        for (final item in batch) {
          try {
            final draft = item();
            if (await JournalWriter.post(tx, ctx, draft, now: when)) written++;
          } on _Skip catch (skip) {
            problems.add(skip.message);
          }
        }
      });
      done += batch.length;
      onProgress?.call(done, total);
    }

    final reversals = await _db.readTransaction(
      (tx) => _pendingReversals(tx, ctx.tenantId),
    );
    for (var i = 0; i < reversals.length; i += batchSize) {
      final batch = reversals.skip(i).take(batchSize).toList();
      await _db.writeTransaction((tx) async {
        for (final r in batch) {
          final ok = await JournalWriter.reverse(
            tx,
            ctx,
            r.sourceKey,
            on: r.on,
            now: when,
          );
          if (ok) written++;
        }
      });
    }
    return BackfillDone(written: written, problems: problems);
  }

  // -- documents -----------------------------------------------------------

  Iterable<JournalEntryDraft Function()> _lots(
    Iterable<Map<String, Object?>> rows,
  ) => rows.map(
    (r) => () {
      final lotNo = r['lot_no']! as String;
      final snapshot = r['charges_snapshot'];
      if (snapshot == null) throw _Skip('Lot $lotNo has no charges snapshot');
      final MandiConfig config;
      try {
        config = MandiConfig.fromJson(
          Map<String, Object?>.from(
            jsonDecode(snapshot as String) as Map<String, dynamic>,
          ),
        );
      } on FormatException catch (e) {
        throw _Skip('Lot $lotNo: unreadable charges snapshot (${e.message})');
      }
      final result = LotRules.planPosting(
        farmerId: r['farmer_id']! as String,
        bags: r['bags']! as int,
        qtlMilli: r['qtl_milli'] as int?,
        rate: r['rate_paise_per_qtl'] == null
            ? null
            : Money(r['rate_paise_per_qtl']! as int),
        config: config,
        buyerId: r['buyer_party_id'] as String?,
      );
      final plan = result.plan;
      if (plan == null) {
        throw _Skip('Lot $lotNo: cannot be re-derived (${result.problems})');
      }
      if (plan.farmer.amount.paise != r['net_to_farmer']) {
        throw _Skip(
          'Lot $lotNo: re-derived net ${plan.farmer.amount.paise} differs '
          'from the posted ${r['net_to_farmer']}',
        );
      }
      return PostingRules.lot(
        lotId: r['id']! as String,
        date: LedgerDate.parse(r['entry_date']! as String),
        plan: plan,
        lotNo: lotNo,
      );
    },
  );

  Iterable<JournalEntryDraft Function()> _payments(
    Iterable<Map<String, Object?>> rows,
  ) => rows.map(
    (r) =>
        () => PostingRules.payment(
          paymentId: r['id']! as String,
          date: LedgerDate.parse(r['entry_date']! as String),
          direction: PaymentDirection.parse(r['direction']! as String),
          partyId: r['party_id']! as String,
          bankAccountId: r['bank_account_id']! as String,
          amount: Money(r['amount_paise']! as int),
          narration: r['receipt_no'] as String?,
        ),
  );

  Iterable<JournalEntryDraft Function()> _interest(
    Iterable<Map<String, Object?>> rows,
  ) => rows.map(
    (r) => () {
      final waiver = r['kind'] == 'waiver';
      final to = LedgerDate.parse(r['period_to']! as String);
      return waiver
          ? PostingRules.waiver(
              postingId: r['id']! as String,
              date: to,
              partyId: r['party_id']! as String,
              amount: Money(r['amount_paise']! as int),
              narration: r['reason'] as String?,
            )
          : PostingRules.interest(
              postingId: r['id']! as String,
              date: to.addDays(-1),
              partyId: r['party_id']! as String,
              amount: Money(r['amount_paise']! as int),
            );
    },
  );

  Iterable<JournalEntryDraft Function()> _entries(
    Iterable<Map<String, Object?>> rows,
  ) => rows.map(
    (r) => () {
      final e = LedgerRepository.fromRow(r);
      return e.refType == RefType.openingBalance
          ? PostingRules.openingBalance(
              entryId: e.id,
              date: e.entryDate,
              side: e.side,
              partyId: e.partyId,
              amount: e.amount,
              narration: e.narration,
            )
          : PostingRules.manualEntry(
              entryId: e.id,
              date: e.entryDate,
              side: e.side,
              partyId: e.partyId,
              amount: e.amount,
              narration: e.narration,
            );
    },
  );

  // -- reversals -----------------------------------------------------------

  /// Khata reversals whose original has a journal entry and whose own mirror
  /// is missing, oldest first. A lot's second reversal shares the first's
  /// source key and is dropped.
  Future<List<_PendingReversal>> _pendingReversals(
    SqliteReadContext tx,
    String tenantId,
  ) async {
    final rows = await tx.getAll(
      'SELECT r.id AS rev_id, r.entry_date AS rev_date, o.* '
      'FROM ledger_entries r JOIN ledger_entries o '
      'ON o.tenant_id = r.tenant_id AND o.id = r.reverses_id '
      'WHERE r.tenant_id = ? ORDER BY r.created_at, r.id',
      [tenantId],
    );
    final out = <_PendingReversal>[];
    final seen = <String>{};
    for (final row in rows) {
      final original = LedgerRepository.fromRow(row);
      final key = await JournalWriter.sourceKeyOf(tx, tenantId, original);
      if (key == null || !seen.add(key)) continue;
      final has = await tx.getOptional(
        'SELECT (SELECT 1 FROM journal_entries '
        'WHERE tenant_id = ? AND source_key = ?) AS orig, '
        '(SELECT 1 FROM journal_entries WHERE tenant_id = ? '
        "AND source_key = 'reversal:' || ?) AS rev",
        [tenantId, key, tenantId, key],
      );
      if (has!['orig'] == null || has['rev'] != null) continue;
      out.add(
        _PendingReversal(key, LedgerDate.parse(row['rev_date']! as String)),
      );
    }
    return out;
  }
}

class _PendingReversal {
  const _PendingReversal(this.sourceKey, this.on);

  final String sourceKey;
  final LedgerDate on;
}

class _Skip implements Exception {
  const _Skip(this.message);

  final String message;
}
