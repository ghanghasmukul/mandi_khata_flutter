import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteReadContext;

/// The financial statements of one business, from the local journal
/// (docs/domain/posting-rules.md, 11.5). The maths is khata_core's; this
/// reads the chart and the totals.
class StatementsRepository {
  StatementsRepository(this._db);

  final PowerSyncDatabase _db;

  /// The chart in the shape the statements need.
  static StatementChart statementChart(Chart chart) => StatementChart([
    for (final g in chart.groups.values)
      StatementGroup(
        id: g.id,
        name: g.name,
        nature: g.nature,
        code: g.system?.code,
        parentId: g.parentId,
      ),
  ]);

  /// Every account with a line in the dates, with its totals. An account
  /// whose row has not synced yet keeps its id as name and no group.
  static Future<(StatementChart, List<StatementAccount>)> accounts(
    SqliteReadContext tx,
    String tenantId, {
    LedgerDate? from,
    LedgerDate? to,
    Set<String> excludeSourceTypes = const {},
  }) async {
    final chart = await ChartRepository.load(tx, tenantId);
    final totals = await ChartRepository.totals(
      tx,
      tenantId,
      from: from,
      to: to,
      excludeSourceTypes: excludeSourceTypes,
    );
    return (
      statementChart(chart),
      [
        for (final MapEntry(key: id, value: t) in totals.entries)
          StatementAccount(
            id: id,
            name: chart.byId(id)?.label ?? id,
            groupId: chart.byId(id)?.groupId ?? '',
            debit: t.debit,
            credit: t.credit,
          ),
      ],
    );
  }

  Future<TrialBalance> trialBalance(
    String tenantId, {
    required LedgerDate asOf,
    bool withAccounts = true,
  }) => _db.readTransaction((tx) async {
    final (chart, list) = await accounts(tx, tenantId, to: asOf);
    return TrialBalance.build(chart, list, withAccounts: withAccounts);
  });

  /// Profit and loss for [from]..[to], without year-close entries.
  Future<ProfitAndLoss> profitAndLoss(
    String tenantId, {
    required LedgerDate from,
    required LedgerDate to,
  }) => _db.readTransaction((tx) async {
    final (chart, list) = await accounts(
      tx,
      tenantId,
      from: from,
      to: to,
      excludeSourceTypes: const {'year_close'},
    );
    return ProfitAndLoss.build(chart, list);
  });

  Future<BalanceSheet> balanceSheet(
    String tenantId, {
    required LedgerDate asOf,
  }) => _db.readTransaction((tx) async {
    final (chart, list) = await accounts(tx, tenantId, to: asOf);
    return BalanceSheet.build(chart, list);
  });

  /// The accounts of group [groupId] and its sub-groups with their closing
  /// balances on [asOf] (debit − credit), largest first.
  Future<List<(ChartEntry, Money)>> groupSummary(
    String tenantId,
    String groupId, {
    required LedgerDate asOf,
  }) => _db.readTransaction((tx) async {
    final chart = await ChartRepository.load(tx, tenantId);
    final totals = await ChartRepository.totals(tx, tenantId, to: asOf);
    final groups = chart.groupAndChildren(groupId);
    final out = [
      for (final a in chart.accounts)
        if (groups.contains(a.groupId) && totals[a.id] != null)
          (a, totals[a.id]!.net),
    ]..sort((x, y) => y.$2.abs().compareTo(x.$2.abs()));
    return [
      for (final r in out)
        if (!r.$2.isZero) r,
    ];
  });

  /// The ledger of account [accountId] for [from]..[to].
  Future<AccountLedger> ledger(
    String tenantId,
    String accountId, {
    LedgerDate? from,
    LedgerDate? to,
  }) => _db.readTransaction((tx) async {
    final rows = await tx.getAll(
      'SELECT e.entry_date, e.narration, e.source_key, e.created_at, '
      'l.debit_paise, l.credit_paise, l.memo FROM journal_lines l '
      'JOIN journal_entries e ON e.id = l.journal_entry_id '
      'AND e.tenant_id = l.tenant_id '
      'WHERE l.tenant_id = ? AND l.account_id = ? '
      'AND (? IS NULL OR e.entry_date <= ?)',
      [tenantId, accountId, to?.toString(), to?.toString()],
    );
    return AccountLedger.build(
      [
        for (final r in rows)
          AccountPosting(
            date: LedgerDate.parse(r['entry_date']! as String),
            debit: Money(r['debit_paise']! as int),
            credit: Money(r['credit_paise']! as int),
            text: [r['narration'], r['memo']].whereType<String>().join(' · '),
            sourceKey: r['source_key'] as String?,
            order: r['created_at'] as String? ?? '',
          ),
      ],
      from: from,
      to: to,
    );
  });
}
