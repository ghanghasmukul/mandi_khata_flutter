import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statement_export_bar.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_table_view.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The frame every accounts statement shares: title, its controls, export,
/// an optional summary line, then the table. Esc goes back to the hub.
class StatementPage extends StatelessWidget {
  const StatementPage({
    required this.title,
    required this.fileStem,
    required this.controls,
    required this.table,
    this.summary,
    this.filterLines = const [],
    super.key,
  });

  final String title;
  final String fileStem;
  final List<Widget> controls;

  /// Null while loading.
  final ReportTable? table;
  final Widget? summary;
  final List<String> filterLines;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = table;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(AccountRoutes.hub),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(
                title: title,
                actions: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => context.go(AccountRoutes.hub),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(MkSpacing.md),
                child: Wrap(
                  spacing: MkSpacing.md,
                  runSpacing: MkSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...controls,
                    StatementExportBar(
                      title: title,
                      fileStem: fileStem,
                      table: t,
                      filterLines: filterLines,
                    ),
                  ],
                ),
              ),
              ?summary,
              Expanded(
                child: t == null
                    ? const Center(child: CircularProgressIndicator())
                    : t.rows.isEmpty
                    ? MkEmptyState(title: l10n.stmtEmpty)
                    : ReportTableView(table: t),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A button showing a date that opens a date picker.
class StatementDateButton extends StatelessWidget {
  const StatementDateButton({
    required this.date,
    required this.onChanged,
    this.label,
    super.key,
  });

  final LedgerDate date;
  final ValueChanged<LedgerDate> onChanged;
  final String Function(String date)? label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppFormat.ledgerDate(context, date);
    return TextButton.icon(
      key: const ValueKey('statement-date'),
      icon: const Icon(Icons.event, size: 18),
      label: Text(label?.call(text) ?? l10n.stmtAsOf(text)),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 366)),
          initialDate: DateTime(date.year, date.month, date.day),
        );
        if (picked != null) onChanged(LedgerDate.fromDateTime(picked));
      },
    );
  }
}

/// This year / last year / custom period chips for a profit and loss or a
/// ledger.
class PeriodChips extends StatelessWidget {
  const PeriodChips({
    required this.from,
    required this.to,
    required this.onChanged,
    super.key,
  });

  final LedgerDate from;
  final LedgerDate to;
  final void Function(LedgerDate from, LedgerDate to) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = LedgerDate.fromDateTime(DateTime.now());
    final thisYear = FinancialYear.containing(today);
    final lastYear = FinancialYear(thisYear.startYear - 1);
    bool isYear(FinancialYear fy) =>
        from == fy.start && (to == fy.end || (fy == thisYear && to == today));
    return Wrap(
      spacing: MkSpacing.sm,
      children: [
        ChoiceChip(
          key: const ValueKey('period-this-year'),
          label: Text(l10n.stmtThisYear(thisYear.label)),
          selected: isYear(thisYear),
          onSelected: (_) => onChanged(thisYear.start, today),
        ),
        ChoiceChip(
          key: const ValueKey('period-last-year'),
          label: Text(l10n.stmtLastYear(lastYear.label)),
          selected: isYear(lastYear),
          onSelected: (_) => onChanged(lastYear.start, lastYear.end),
        ),
        ActionChip(
          avatar: const Icon(Icons.date_range, size: 18),
          label: Text(
            '${AppFormat.ledgerDate(context, from)} – '
            '${AppFormat.ledgerDate(context, to)}',
          ),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 366)),
              initialDateRange: DateTimeRange(
                start: DateTime(from.year, from.month, from.day),
                end: DateTime(to.year, to.month, to.day),
              ),
            );
            if (picked != null) {
              onChanged(
                LedgerDate.fromDateTime(picked.start),
                LedgerDate.fromDateTime(picked.end),
              );
            }
          },
        ),
      ],
    );
  }
}
