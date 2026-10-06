import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/books_invariants.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/statements_repository.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteReadContext;
import 'package:uuid/uuid.dart';

/// A financial year as the year-close screen lists it.
@immutable
class YearRow {
  const YearRow({
    required this.year,
    required this.isClosed,
    this.profit,
    this.closedAt,
  });

  final FinancialYear year;
  final bool isClosed;

  /// The profit booked at close.
  final Money? profit;
  final DateTime? closedAt;
}

/// Why a year cannot be closed now.
enum YearCloseProblem {
  notOwner,
  notEnded,
  earlierOpen,
  booksDoNotTally,
  alreadyClosed,
}

/// What closing a year would do.
@immutable
class YearClosePreview {
  const YearClosePreview({
    required this.year,
    required this.profit,
    required this.problems,
    this.entry,
  });

  final FinancialYear year;

  /// Net profit of the year (negative = loss), without year-close entries.
  final Money profit;

  /// The closing journal entry; null when nothing needs moving.
  final JournalEntryDraft? entry;
  final List<YearCloseProblem> problems;

  bool get canClose => problems.isEmpty;
}

sealed class YearCloseResult {
  const YearCloseResult();
}

final class YearClosed extends YearCloseResult {
  const YearClosed(this.year);

  final FinancialYear year;
}

final class YearCloseRefused extends YearCloseResult {
  const YearCloseRefused(this.problems);

  final List<YearCloseProblem> problems;
}

/// Financial years and their close (posting-rules 11.5, decision): no
/// khata entries move; one closing journal entry dated 31 March zeroes the
/// income and expense accounts into Profit & Loss A/c and Opening Balance
/// Equity into Capital, and the year is locked. Owner only.
class YearCloseRepository {
  YearCloseRepository(this._db);

  final PowerSyncDatabase _db;

  static const _namespace = '9c4e2a71-5b38-4d06-8f1e-3a7d6b2c9e14';

  static String yearId(String tenantId, FinancialYear fy) =>
      const Uuid().v5(_namespace, '$tenantId|fy|${fy.startYear}');

  /// From the first year with a journal or khata entry to the current one,
  /// newest first. Live.
  Stream<List<YearRow>> watch(String tenantId, LedgerDate today) => _db
      .watch(
        'SELECT 1',
        triggerOnTables: const {
          'financial_years',
          'journal_entries',
          'ledger_entries',
        },
      )
      .asyncMap((_) => _db.readTransaction((tx) => years(tx, tenantId, today)));

  static Future<List<YearRow>> years(
    SqliteReadContext tx,
    String tenantId,
    LedgerDate today,
  ) async {
    final first = await tx.get(
      'SELECT MIN(d) AS d FROM (SELECT MIN(entry_date) AS d FROM '
      'journal_entries WHERE tenant_id = ? UNION ALL SELECT MIN(entry_date) '
      'FROM ledger_entries WHERE tenant_id = ?)',
      [tenantId, tenantId],
    );
    final closed = {
      for (final r in await tx.getAll(
        'SELECT * FROM financial_years WHERE tenant_id = ? '
        "AND status = 'closed'",
        [tenantId],
      ))
        LedgerDate.parse(r['start_date']! as String).year: r,
    };
    final current = FinancialYear.containing(today);
    final from = first['d'] == null
        ? current
        : FinancialYear.containing(LedgerDate.parse(first['d']! as String));
    return [
      for (var y = current.startYear; y >= from.startYear; y--)
        YearRow(
          year: FinancialYear(y),
          isClosed: closed.containsKey(y),
          profit: closed[y] == null
              ? null
              : Money(closed[y]!['profit_paise']! as int),
          closedAt: closed[y]?['closed_at'] == null
              ? null
              : DateTime.parse(closed[y]!['closed_at']! as String),
        ),
    ];
  }

  /// What closing [fy] would do, and what stops it.
  Future<YearClosePreview> preview(
    String tenantId,
    FinancialYear fy, {
    required bool isOwner,
    required LedgerDate today,
  }) => _db.readTransaction(
    (tx) => _preview(tx, tenantId, fy, isOwner: isOwner, today: today),
  );

  Future<YearClosePreview> _preview(
    SqliteReadContext tx,
    String tenantId,
    FinancialYear fy, {
    required bool isOwner,
    required LedgerDate today,
  }) async {
    final problems = <YearCloseProblem>[
      if (!isOwner) YearCloseProblem.notOwner,
      if (fy.end >= today) YearCloseProblem.notEnded,
    ];
    final rows = await years(tx, tenantId, today);
    if (rows.any((r) => r.year == fy && r.isClosed)) {
      problems.add(YearCloseProblem.alreadyClosed);
    }
    if (rows.any((r) => r.year.startYear < fy.startYear && !r.isClosed)) {
      problems.add(YearCloseProblem.earlierOpen);
    }
    if ((await BooksInvariants.unbalancedEntriesIn(tx, tenantId)).isNotEmpty ||
        (await BooksInvariants.partyDifferencesIn(tx, tenantId)).isNotEmpty ||
        (await BooksInvariants.bookDifferencesIn(tx, tenantId)).isNotEmpty) {
      problems.add(YearCloseProblem.booksDoNotTally);
    }

    final (chart, list) = await StatementsRepository.accounts(
      tx,
      tenantId,
      from: fy.start,
      to: fy.end,
      excludeSourceTypes: const {'year_close'},
    );
    final pl = ProfitAndLoss.build(chart, list);
    final fullChart = await ChartRepository.load(tx, tenantId);
    final incomeExpense = <JournalAccount, Money>{
      for (final a in list)
        if (ProfitAndLoss.sectionOf(chart, a.groupId) != null)
          fullChart.byId(a.id)?.account ?? ChartAccount(a.id): a.net,
    };
    final obeId = JournalWriter.accountId(
      tenantId,
      const SystemJournalAccount(SystemAccount.openingBalanceEquity),
    );
    final obe = (await ChartRepository.totals(tx, tenantId, to: fy.end))[obeId];
    return YearClosePreview(
      year: fy,
      profit: pl.netProfit,
      problems: problems,
      entry: YearClose.closingEntry(
        fy,
        incomeExpense: incomeExpense,
        openingEquity: obe?.net ?? Money.zero,
      ),
    );
  }

  /// Closes [fy]: the closing entry and the locked year in one transaction.
  Future<YearCloseResult> close(
    WriteContext ctx,
    FinancialYear fy, {
    required bool isOwner,
    required LedgerDate today,
    DateTime? now,
  }) async {
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final p = await _preview(
        tx,
        ctx.tenantId,
        fy,
        isOwner: isOwner,
        today: today,
      );
      if (!p.canClose) return YearCloseRefused(p.problems);
      final entry = p.entry;
      String? entryId;
      if (entry != null) {
        // Dated inside the year it closes; the year is still open here, so
        // no lock reason is needed (the year row is written after it).
        await JournalWriter.post(tx, ctx, entry, now: when);
        entryId = JournalWriter.entryId(ctx.tenantId, entry.sourceKey);
      }
      final id = yearId(ctx.tenantId, fy);
      final at = when.toIso8601String();
      await tx.execute(
        'INSERT INTO financial_years (id, tenant_id, start_date, end_date, '
        'status, closed_at, closed_by, closing_entry_id, profit_paise, '
        'device_id, created_by, created_at, updated_at) VALUES (?, ?, ?, ?, '
        "'closed', ?, ?, ?, ?, ?, ?, ?, ?)",
        [
          id,
          ctx.tenantId,
          fy.start.toString(),
          fy.end.toString(),
          at,
          ctx.userId,
          entryId,
          p.profit.paise,
          ctx.deviceId,
          ctx.userId,
          at,
          at,
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'financial_years',
        rowId: id,
        action: AuditAction.insert,
        after: {
          'start_date': fy.start.toString(),
          'status': 'closed',
          'profit_paise': p.profit.paise,
          'closing_entry_id': ?entryId,
        },
        at: when,
      );
      return YearClosed(fy);
    });
  }
}
