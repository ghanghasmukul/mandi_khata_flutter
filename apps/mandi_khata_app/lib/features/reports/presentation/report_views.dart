import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/khata/presentation/statement_labels.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_tables.dart';
import 'package:mandi_khata_app/features/reports/presentation/reports_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// A loaded report: its table, the cards above it, the filter lines for the
/// PDF header, and (statements only) its own PDF.
class ReportView {
  const ReportView({
    required this.table,
    this.summary,
    this.filterLines = const [],
    this.customPdf,
  });

  final ReportTable table;
  final Widget? summary;
  final List<String> filterLines;
  final Future<Uint8List> Function(StatementFonts fonts)? customPdf;
}

/// Reads the report [kind] for [filter] and shapes it for the screen and for
/// export. [businessName] heads the bulk statements.
AsyncValue<ReportView> watchReportView(
  WidgetRef ref,
  BuildContext context, {
  required ReportKind kind,
  required ReportFilter filter,
  required LedgerDate today,
  required String businessName,
}) {
  final l10n = AppLocalizations.of(context);
  final language = Localizations.localeOf(context).languageCode;
  String date(LedgerDate d) => AppFormat.ledgerDate(context, d);
  String period() => filter.from == null && filter.to == null
      ? l10n.rangeAll
      : '${filter.from == null ? '…' : date(filter.from!)} – '
            '${filter.to == null ? '…' : date(filter.to!)}';
  final periodLine = l10n.reportPeriod(period());

  switch (kind) {
    case ReportKind.outstanding:
      final asOf = filter.asOf ?? today;
      return ref
          .watch(outstandingReportProvider(filter, today))
          .whenData(
            (rows) => ReportView(
              table: ReportTables.outstanding(l10n, rows, asOf),
              summary: _AgeingCards(rows: rows, asOf: asOf),
              filterLines: [l10n.reportAsOf(date(asOf))],
            ),
          );
    case ReportKind.arrivals:
      return ref
          .watch(arrivalsReportProvider(filter))
          .whenData(
            (rows) => ReportView(
              table: ReportTables.arrivals(l10n, rows, language),
              filterLines: [periodLine],
            ),
          );
    case ReportKind.commission:
      return ref
          .watch(commissionReportProvider(filter))
          .whenData(
            (rows) => ReportView(
              table: ReportTables.commission(l10n, rows, language),
              filterLines: [periodLine],
            ),
          );
    case ReportKind.payments:
      return ref
          .watch(paymentsReportProvider(filter))
          .whenData(
            (rows) => ReportView(
              table: ReportTables.payments(l10n, rows),
              summary: _ModeCards(totals: ReportTables.modeTotals(rows)),
              filterLines: [periodLine],
            ),
          );
    case ReportKind.karza:
      final asOf = filter.asOf ?? today;
      return ref
          .watch(karzaReportProvider(filter, today))
          .whenData(
            (rows) => ReportView(
              table: ReportTables.karza(l10n, rows),
              summary: _Note(
                l10n.reportKarzaOverdueCount(
                  rows.where((r) => r.daysOverdue != null).length,
                ),
              ),
              filterLines: [l10n.reportAsOf(date(asOf))],
            ),
          );
    case ReportKind.interestEarned:
      return ref
          .watch(interestEarnedReportProvider(filter, today))
          .whenData(
            (rows) => ReportView(
              table: ReportTables.interestEarned(l10n, rows),
              summary: _Note(l10n.reportInterestHelp),
              filterLines: [periodLine],
            ),
          );
    case ReportKind.statements:
      return ref
          .watch(statementsReportProvider(filter))
          .whenData(
            (rows) => ReportView(
              table: ReportTables.statements(l10n, rows),
              summary: _StatementsNote(count: rows.length),
              filterLines: [periodLine, ?filter.village],
              customPdf: (fonts) => StatementPdf.buildMany(
                title: '$businessName – ${l10n.statementTitle}',
                labels: statementLabels(
                  l10n,
                  period: period(),
                  formatDate: date,
                ),
                fonts: fonts,
                statements: [
                  for (final r in rows)
                    (
                      statement: r.statement,
                      header: StatementHeader(
                        businessName: businessName,
                        partyName: r.name,
                        partyCode: r.code,
                        partyPlace: r.village,
                        mobile: r.mobile,
                      ),
                    ),
                ],
              ),
            ),
          );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      MkSpacing.lg,
      MkSpacing.sm,
      MkSpacing.lg,
      MkSpacing.md,
    ),
    child: Wrap(
      spacing: MkSpacing.md,
      runSpacing: MkSpacing.md,
      children: children,
    ),
  );
}

class _AgeingCards extends StatelessWidget {
  const _AgeingCards({required this.rows, required this.asOf});

  final List<OutstandingRow> rows;
  final LedgerDate asOf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totals = ReportTables.ageingTotals(rows, asOf);
    return _CardRow(
      children: [
        for (final b in AgeingBucket.values)
          SizedBox(
            width: 220,
            child: MkCard(
              title: ReportTables.ageingName(l10n, b),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.reportColWeOwe}: ${totals[b]!.weOwe.format()}'),
                  Text(
                    '${l10n.reportColTheyOwe}: ${totals[b]!.theyOwe.format()}',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ModeCards extends StatelessWidget {
  const _ModeCards({required this.totals});

  final Map<PaymentMode, ({Money received, Money paid})> totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _CardRow(
      children: [
        for (final e in totals.entries)
          SizedBox(
            width: 220,
            child: MkCard(
              title: l10n.paymentModeName(e.key),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.reportColReceived}: ${e.value.received.format()}',
                  ),
                  Text('${l10n.reportColPaid}: ${e.value.paid.format()}'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: MkSpacing.lg,
      vertical: MkSpacing.sm,
    ),
    child: Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class _StatementsNote extends StatelessWidget {
  const _StatementsNote({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MkSpacing.lg,
        vertical: MkSpacing.sm,
      ),
      child: Text(
        '${l10n.reportStatementsCount(count)} · '
        '${l10n.reportStatementsHelp}',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
