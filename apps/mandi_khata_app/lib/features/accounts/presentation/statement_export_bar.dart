import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_export.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Print / PDF / Excel / CSV of an accounts statement ([table]); needs
/// `finance.view` like every report export.
class StatementExportBar extends ConsumerWidget {
  const StatementExportBar({
    required this.title,
    required this.fileStem,
    required this.table,
    this.filterLines = const [],
    super.key,
  });

  final String title;
  final String fileStem;
  final ReportTable? table;
  final List<String> filterLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allowed = ref.watch(canProvider(Permission.financeView));
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

    Widget button(String key, String label, IconData icon, VoidCallback tap) =>
        Tooltip(
          message: allowed ? '' : l10n.reportExportLocked,
          child: MkButton(
            key: ValueKey(key),
            label: label,
            icon: icon,
            variant: MkButtonVariant.secondary,
            onPressed: allowed && t != null && t.rows.isNotEmpty ? tap : null,
          ),
        );
    return Wrap(
      spacing: MkSpacing.sm,
      runSpacing: MkSpacing.sm,
      children: [
        button(
          'export-print',
          l10n.reportPrint,
          Icons.print_outlined,
          () => run((j) async {
            await j.print();
            return null;
          }),
        ),
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
      ],
    );
  }
}
