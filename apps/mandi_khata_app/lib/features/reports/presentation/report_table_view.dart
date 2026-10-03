import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mk_ui/mk_ui.dart';

/// A [ReportTable] on screen: sortable lazy rows, then a totals strip.
class ReportTableView extends StatelessWidget {
  const ReportTableView({required this.table, super.key});

  final ReportTable table;

  /// Text of one cell, shown in the user's number and date style.
  static String cellText(
    BuildContext context,
    ReportColumn column,
    Object? v,
  ) => switch (v) {
    null => '',
    final Money m => m.format(),
    final LedgerDate d => AppFormat.ledgerDate(context, d),
    final int milli when column.kind == ReportColumnKind.quantity =>
      Quintals.format(milli),
    final Object o => o.toString(),
  };

  /// Sort order of a cell as text, so one key type fits every column:
  /// numbers are shifted and zero-padded, empty cells sort first.
  static String _sortKey(Object? v) => switch (v) {
    null => '',
    final Money m => (m.paise + 1000000000000000).toString().padLeft(20, '0'),
    final int n => (n + 1000000000000000).toString().padLeft(20, '0'),
    final LedgerDate d => d.toString(),
    final Object o => o.toString().toLowerCase(),
  };

  @override
  Widget build(BuildContext context) {
    final totals = table.totals;
    return Column(
      children: [
        Expanded(
          child: MkDataTable<List<Object?>>(
            minWidth: table.columns.length * 120.0,
            rows: table.rows,
            columns: [
              for (var i = 0; i < table.columns.length; i++)
                MkColumn(
                  label: table.columns[i].title,
                  flex: table.columns[i].kind == ReportColumnKind.text ? 3 : 2,
                  numeric:
                      table.columns[i].kind != ReportColumnKind.text &&
                      table.columns[i].kind != ReportColumnKind.date,
                  cell: (row) => Text(
                    cellText(context, table.columns[i], row[i]),
                    overflow: TextOverflow.ellipsis,
                  ),
                  sortKey: (row) => _sortKey(row[i]),
                ),
            ],
          ),
        ),
        if (totals != null) _TotalsStrip(table: table, totals: totals),
      ],
    );
  }
}

class _TotalsStrip extends StatelessWidget {
  const _TotalsStrip({required this.table, required this.totals});

  final ReportTable table;
  final List<Object?> totals;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
        horizontal: MkSpacing.lg,
        vertical: MkSpacing.md,
      ),
      child: Wrap(
        spacing: MkSpacing.xl,
        runSpacing: MkSpacing.xs,
        children: [
          Text(
            '${totals.first}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          for (var i = 1; i < totals.length && i < table.columns.length; i++)
            if (totals[i] != null)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${table.columns[i].title}: ',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    TextSpan(
                      text: ReportTableView.cellText(
                        context,
                        table.columns[i],
                        totals[i],
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
