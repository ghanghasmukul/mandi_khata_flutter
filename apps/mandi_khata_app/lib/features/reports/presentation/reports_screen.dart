import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_export.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_filters.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_table_view.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_views.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class ReportRoutes {
  static const list = '/reports';

  /// `?r=<kind>` opens a given report.
  static String of(ReportKind kind) => '$list?r=${kind.name}';
}

/// Reports: pick one, filter it, read it on screen, print / save it as PDF,
/// Excel or CSV. Everything is read from the local database, so it works
/// offline. Export needs `finance.view`; so does the commission report.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key, this.initial = ReportKind.outstanding});

  final ReportKind initial;

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late ReportKind _kind = widget.initial;
  late ReportFilter _filter = _defaults(widget.initial);

  static LedgerDate get _today => LedgerDate.fromDateTime(DateTime.now());

  /// This season for the registers, the last week for payments.
  static ReportFilter _defaults(ReportKind kind) {
    final season = FinancialYear.containing(_today);
    return switch (kind) {
      ReportKind.outstanding => const ReportFilter(),
      ReportKind.payments => ReportFilter(from: _today.addDays(-6), to: _today),
      _ => ReportFilter(from: season.start, to: _today),
    };
  }

  void _pick(ReportKind kind) => setState(() {
    _kind = kind;
    _filter = _defaults(kind);
  });

  String _name(AppLocalizations l10n, ReportKind kind) => switch (kind) {
    ReportKind.outstanding => l10n.reportOutstanding,
    ReportKind.arrivals => l10n.reportArrivals,
    ReportKind.commission => l10n.reportCommission,
    ReportKind.payments => l10n.reportPayments,
    ReportKind.statements => l10n.reportStatements,
  };

  Future<void> _export(
    ReportView view,
    Future<String?> Function(ReportExport) run,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final job = ReportExport(
      title: _name(l10n, _kind),
      fileStem: '${_kind.name}-$_today',
      table: view.table,
      businessName: ref.read(activeMembershipProvider)?.tenantName ?? '',
      l10n: l10n,
      formatDate: (d) => AppFormat.ledgerDate(context, d),
      filterLines: view.filterLines,
      customPdf: view.customPdf,
    );
    try {
      final saved = await run(job);
      if (saved != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.reportExportSaved(saved))),
        );
      }
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reportExportFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canFinance = ref.watch(canProvider(Permission.financeView));
    final restricted = _kind == ReportKind.commission && !canFinance;
    final view = restricted
        ? null
        : watchReportView(
            ref,
            context,
            kind: _kind,
            filter: _filter,
            today: _today,
            businessName: ref.watch(activeMembershipProvider)?.tenantName ?? '',
          );
    final loaded = view?.value;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(GateRoutes.home),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(
                title: l10n.reportsTitle,
                actions: [
                  const SyncStatusChip(),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => context.go(GateRoutes.home),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              _KindChips(
                kind: _kind,
                name: (k) => _name(l10n, k),
                onPick: _pick,
              ),
              if (!restricted)
                ReportFilters(
                  kind: _kind,
                  filter: _filter,
                  today: _today,
                  onChanged: (f) => setState(() => _filter = f),
                ),
              if (loaded != null)
                _ExportBar(
                  rows: loaded.table.rows.length,
                  allowed: canFinance,
                  onPrint: () => _export(loaded, (j) async {
                    await j.print();
                    return null;
                  }),
                  onPdf: () => _export(loaded, (j) async {
                    await j.sharePdf();
                    return null;
                  }),
                  onExcel: () => _export(loaded, (j) => j.saveExcel()),
                  onCsv: () => _export(loaded, (j) => j.saveCsv()),
                ),
              ?loaded?.summary,
              Expanded(
                child: _body(l10n, restricted: restricted, view: view),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(
    AppLocalizations l10n, {
    required bool restricted,
    required AsyncValue<ReportView>? view,
  }) {
    if (restricted) {
      return MkEmptyState(
        icon: Icons.lock_outline,
        title: l10n.reportRestricted,
      );
    }
    return view!.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => MkEmptyState(
        icon: Icons.error_outline,
        title: l10n.reportExportFailed('$e'),
      ),
      data: (v) => v.table.rows.isEmpty
          ? MkEmptyState(
              icon: Icons.table_chart_outlined,
              title: l10n.reportEmpty,
            )
          : ReportTableView(table: v.table),
    );
  }
}

class _KindChips extends StatelessWidget {
  const _KindChips({
    required this.kind,
    required this.name,
    required this.onPick,
  });

  final ReportKind kind;
  final String Function(ReportKind) name;
  final ValueChanged<ReportKind> onPick;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(
      horizontal: MkSpacing.lg,
      vertical: MkSpacing.sm,
    ),
    child: Row(
      children: [
        for (final k in ReportKind.values)
          Padding(
            padding: const EdgeInsets.only(right: MkSpacing.sm),
            child: ChoiceChip(
              key: ValueKey('report-kind-${k.name}'),
              label: Text(name(k)),
              selected: kind == k,
              onSelected: (_) => onPick(k),
            ),
          ),
      ],
    ),
  );
}

class _ExportBar extends StatelessWidget {
  const _ExportBar({
    required this.rows,
    required this.allowed,
    required this.onPrint,
    required this.onPdf,
    required this.onExcel,
    required this.onCsv,
  });

  final int rows;
  final bool allowed;
  final VoidCallback onPrint;
  final VoidCallback onPdf;
  final VoidCallback onExcel;
  final VoidCallback onCsv;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget button(String key, String label, IconData icon, VoidCallback tap) =>
        Tooltip(
          message: allowed ? '' : l10n.reportExportLocked,
          child: MkButton(
            key: ValueKey(key),
            label: label,
            icon: icon,
            variant: MkButtonVariant.secondary,
            onPressed: allowed && rows > 0 ? tap : null,
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MkSpacing.lg,
        vertical: MkSpacing.xs,
      ),
      child: Wrap(
        spacing: MkSpacing.sm,
        runSpacing: MkSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(l10n.reportRows(rows)),
          button(
            'report-print',
            l10n.reportPrint,
            Icons.print_outlined,
            onPrint,
          ),
          button(
            'report-pdf',
            l10n.reportExportPdf,
            Icons.picture_as_pdf_outlined,
            onPdf,
          ),
          button(
            'report-excel',
            l10n.reportExportExcel,
            Icons.grid_on_outlined,
            onExcel,
          ),
          button(
            'report-csv',
            l10n.reportExportCsv,
            Icons.description_outlined,
            onCsv,
          ),
        ],
      ),
    );
  }
}
