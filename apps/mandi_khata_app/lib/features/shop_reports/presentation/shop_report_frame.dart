import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/products/presentation/products_providers.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_export.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

LedgerDate shopToday() => LedgerDate.fromDateTime(DateTime.now());

/// The frame of every shop report: title, a chip row to jump between the
/// reports, the screen's controls and the body. When the shop module is
/// switched off it says so instead.
class ShopReportFrame extends ConsumerWidget {
  const ShopReportFrame({
    required this.title,
    required this.route,
    required this.body,
    this.controls = const [],
    super.key,
  });

  final String title;

  /// The route of this report, to mark its chip.
  final String route;
  final List<Widget> controls;
  final Widget body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final on = ref.watch(shopModuleEnabledProvider);
    final chips = <(String, String)>[
      (ShopReportRoutes.dues, l10n.shrNavDues),
      (ShopReportRoutes.profit, l10n.shrNavProfit),
      (ShopReportRoutes.gst, l10n.shrNavGst),
      (ShopReportRoutes.expiry, l10n.shrNavExpiry),
      (ShopReportRoutes.reorder, l10n.shrNavReorder),
    ];
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(title: title),
          if (!on)
            Expanded(
              child: MkEmptyState(
                title: title,
                message: l10n.shrModuleOff,
                key: const ValueKey('shop-module-off'),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MkSpacing.md,
                MkSpacing.md,
                MkSpacing.md,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: MkSpacing.sm,
                  runSpacing: MkSpacing.sm,
                  children: [
                    for (final (r, label) in chips)
                      ChoiceChip(
                        key: ValueKey('shop-nav-$r'),
                        label: Text(label),
                        selected: r == route,
                        onSelected: (_) {
                          if (r != route) context.go(r);
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (controls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(MkSpacing.md),
                child: Wrap(
                  spacing: MkSpacing.md,
                  runSpacing: MkSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: controls,
                ),
              ),
            Expanded(child: body),
          ],
        ],
      ),
    );
  }
}

/// Print / PDF / Excel / CSV of a shop report table. [permission] decides
/// who may export (`shop.view_profit` for profit, `finance.view` else).
class ShopExportBar extends ConsumerWidget {
  const ShopExportBar({
    required this.title,
    required this.fileStem,
    required this.table,
    required this.permission,
    this.filterLines = const [],
    this.extra = const [],
    super.key,
  });

  final String title;
  final String fileStem;
  final ReportTable? table;
  final Permission permission;
  final List<String> filterLines;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allowed = ref.watch(canProvider(permission));
    final t = table;
    Future<void> run(Future<String?> Function(ReportExport) action) async {
      if (t == null) return;
      final messenger = ScaffoldMessenger.of(context);
      final job = ReportExport(
        title: title,
        fileStem: fileStem,
        table: t,
        businessName: ref.read(activeMembershipProvider)?.tenantName ?? '',
        l10n: l10n,
        formatDate: (d) => AppFormat.ledgerDate(context, d),
        filterLines: filterLines,
      );
      try {
        final saved = await action(job);
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

    final ready = allowed && t != null && t.rows.isNotEmpty;
    Widget button(String key, String label, IconData icon, VoidCallback tap) =>
        MkButton(
          key: ValueKey(key),
          label: label,
          icon: icon,
          variant: MkButtonVariant.secondary,
          onPressed: ready ? tap : null,
        );
    return Tooltip(
      message: allowed ? '' : l10n.reportExportLocked,
      child: Wrap(
        spacing: MkSpacing.sm,
        runSpacing: MkSpacing.sm,
        children: [
          button('export-print', l10n.reportPrint, Icons.print_outlined, () {
            unawaited(
              run((j) async {
                await j.print();
                return null;
              }),
            );
          }),
          button(
            'export-pdf',
            l10n.reportExportPdf,
            Icons.picture_as_pdf_outlined,
            () => run((j) async {
              await j.sharePdf();
              return null;
            }),
          ),
          button(
            'export-excel',
            l10n.reportExportExcel,
            Icons.grid_on_outlined,
            () => run((j) => j.saveExcel()),
          ),
          button(
            'export-csv',
            l10n.reportExportCsv,
            Icons.description_outlined,
            () => run((j) => j.saveCsv()),
          ),
          ...extra,
        ],
      ),
    );
  }
}

/// A month with previous / next buttons (GSTR-1 is filed per month).
class MonthStepper extends StatelessWidget {
  const MonthStepper({
    required this.year,
    required this.month,
    required this.onChanged,
    super.key,
  });

  final int year;
  final int month;
  final void Function(int year, int month) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = MaterialLocalizations.of(
      context,
    ).formatMonthYear(DateTime(year, month));
    void step(int d) {
      final t = DateTime(year, month + d);
      onChanged(t.year, t.month);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const ValueKey('gst-prev'),
          tooltip: l10n.shrGstPrevMonth,
          icon: const Icon(Icons.chevron_left),
          onPressed: () => step(-1),
        ),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          key: const ValueKey('gst-next'),
          tooltip: l10n.shrGstNextMonth,
          icon: const Icon(Icons.chevron_right),
          onPressed: () => step(1),
        ),
      ],
    );
  }
}
