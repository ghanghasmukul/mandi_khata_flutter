import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

/// The statements as [ReportTable]s: the same table on screen, in the PDF,
/// Excel and CSV.
abstract final class StatementTables {
  static String _indent(int depth, String name) => '${'    ' * depth}$name';

  static ReportTable trialBalance(AppLocalizations l10n, TrialBalance tb) =>
      ReportTable(
        columns: [
          ReportColumn(l10n.stmtParticulars, ReportColumnKind.text),
          ReportColumn(l10n.stmtDebit, ReportColumnKind.money),
          ReportColumn(l10n.stmtCredit, ReportColumnKind.money),
        ],
        rows: [
          for (final l in tb.lines)
            [
              _indent(l.depth, l.isGroup ? l.name.toUpperCase() : l.name),
              if (l.debit.isZero) null else l.debit,
              if (l.credit.isZero) null else l.credit,
            ],
        ],
        totals: [l10n.stmtTotal, tb.debit, tb.credit],
      );

  static String sectionName(AppLocalizations l10n, ProfitSection s) =>
      switch (s) {
        ProfitSection.sales => l10n.plSales,
        ProfitSection.directIncome => l10n.plDirectIncome,
        ProfitSection.purchases => l10n.plPurchases,
        ProfitSection.directExpenses => l10n.plDirectExpenses,
        ProfitSection.indirectIncome => l10n.plIndirectIncome,
        ProfitSection.indirectExpenses => l10n.plIndirectExpenses,
      };

  static ReportTable profitAndLoss(AppLocalizations l10n, ProfitAndLoss pl) {
    final rows = <List<Object?>>[];
    void section(ProfitSection s) {
      final lines = pl.sections[s]!;
      if (lines.isEmpty) return;
      rows.add([sectionName(l10n, s).toUpperCase(), pl.total(s)]);
      for (final l in lines) {
        rows.add([_indent(1, l.name), l.amount]);
      }
    }

    section(ProfitSection.sales);
    section(ProfitSection.directIncome);
    section(ProfitSection.purchases);
    section(ProfitSection.directExpenses);
    rows.add([l10n.plGrossProfit.toUpperCase(), pl.grossProfit]);
    section(ProfitSection.indirectIncome);
    section(ProfitSection.indirectExpenses);
    final net = pl.netProfit;
    return ReportTable(
      columns: [
        ReportColumn(l10n.stmtParticulars, ReportColumnKind.text),
        ReportColumn(l10n.stmtAmount, ReportColumnKind.money),
      ],
      rows: rows,
      totals: [
        if (net.isNegative) l10n.plNetLoss else l10n.plNetProfit,
        net.abs(),
      ],
    );
  }

  static ReportTable balanceSheet(
    AppLocalizations l10n,
    BalanceSheet bs,
    Chart? chart,
  ) {
    final rows = <List<Object?>>[];
    void side(BalanceSide s, String title, {Money extra = Money.zero}) {
      rows.add([title.toUpperCase(), bs.total(s) + extra]);
      String? lastGroup;
      for (final l in bs.sides[s]!) {
        final group = chart?.groups[l.groupId]?.name;
        if (group != null && group != lastGroup) {
          rows.add([_indent(1, group), null]);
          lastGroup = group;
        }
        rows.add([
          _indent(2, l.otherSide ? l10n.bsOtherSide(l.name) : l.name),
          l.amount,
        ]);
      }
    }

    side(BalanceSide.liabilities, l10n.bsLiabilities);
    side(BalanceSide.capital, l10n.bsCapital, extra: bs.currentProfit);
    rows
      ..add([_indent(2, l10n.bsCurrentProfit), bs.currentProfit])
      ..add([
        l10n.bsLiabilitiesAndCapital.toUpperCase(),
        bs.liabilitiesAndCapital,
      ]);
    side(BalanceSide.assets, l10n.bsAssets);
    return ReportTable(
      columns: [
        ReportColumn(l10n.stmtParticulars, ReportColumnKind.text),
        ReportColumn(l10n.stmtAmount, ReportColumnKind.money),
      ],
      rows: rows,
      totals: [l10n.bsAssets, bs.assets],
    );
  }

  static ReportTable ledger(
    AppLocalizations l10n,
    AccountLedger ledger, {
    LedgerDate? from,
  }) => ReportTable(
    columns: [
      ReportColumn(l10n.cashBookColDate, ReportColumnKind.date),
      ReportColumn(l10n.stmtParticulars, ReportColumnKind.text),
      ReportColumn(l10n.stmtDebit, ReportColumnKind.money),
      ReportColumn(l10n.stmtCredit, ReportColumnKind.money),
      ReportColumn(l10n.stmtBalance, ReportColumnKind.text),
    ],
    rows: [
      [from, l10n.ledgerOpening, null, null, _drCr(l10n, ledger.opening)],
      for (final l in ledger.lines)
        [
          l.posting.date,
          l.posting.text ?? '',
          if (l.posting.debit.isZero) null else l.posting.debit,
          if (l.posting.credit.isZero) null else l.posting.credit,
          _drCr(l10n, l.balance),
        ],
    ],
    totals: [
      l10n.ledgerClosing,
      null,
      ledger.debit,
      ledger.credit,
      _drCr(l10n, ledger.closing),
    ],
  );

  static ReportTable groupSummary(
    AppLocalizations l10n,
    List<(ChartEntry, Money)> rows,
  ) {
    var debit = Money.zero;
    var credit = Money.zero;
    for (final (_, net) in rows) {
      if (net.isPositive) {
        debit += net;
      } else {
        credit -= net;
      }
    }
    return ReportTable(
      columns: [
        ReportColumn(l10n.stmtParticulars, ReportColumnKind.text),
        ReportColumn(l10n.stmtDebit, ReportColumnKind.money),
        ReportColumn(l10n.stmtCredit, ReportColumnKind.money),
      ],
      rows: [
        for (final (a, net) in rows)
          [
            a.label,
            if (net.isPositive) net else null,
            if (net.isNegative) -net else null,
          ],
      ],
      totals: [l10n.stmtTotal, debit, credit],
    );
  }

  static String _drCr(AppLocalizations l10n, Money net) {
    if (net.isZero) return Money.zero.format();
    final text = net.abs().format();
    return net.isPositive
        ? l10n.chartDrBalance(text)
        : l10n.chartCrBalance(text);
  }
}
