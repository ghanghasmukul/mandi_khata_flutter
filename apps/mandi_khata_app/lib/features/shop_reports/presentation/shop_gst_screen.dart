import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/nav_destinations.dart' show settingsRoute;
import 'package:mandi_khata_app/core/export/xlsx_writer.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/products/presentation/products_routes.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_table_view.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/gst_models.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/shop_report_tables.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_report_frame.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_report_titles.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_reports_providers.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// GST for one month (step 4.5): B2B / B2C summary, CGST + SGST against
/// IGST, the GSTR-1 tables, the invoices of the month and the products
/// whose HSN or rate is missing. Exports GSTR-1 as Excel and portal JSON.
class ShopGstScreen extends ConsumerStatefulWidget {
  const ShopGstScreen({super.key});

  @override
  ConsumerState<ShopGstScreen> createState() => _ShopGstState();
}

class _ShopGstState extends ConsumerState<ShopGstScreen> {
  late int _year = DateTime.now().year;
  late int _month = DateTime.now().month;

  ReportTable _t(ReportTable t) => ShopReportTables.units(t);

  Future<void> _save(
    String name,
    Uint8List bytes,
    String ext,
    MimeType mime,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final saved = await FileSaver.instance.saveAs(
        name: name,
        bytes: bytes,
        fileExtension: ext,
        mimeType: mime,
      );
      if (saved != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.shrGstSaved(saved))),
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
    final title = shopReportTitles(l10n);
    final data = ref.watch(gstMonthProvider(_year, _month)).value;
    final allowed = ref.watch(canProvider(Permission.financeView));
    final invoices = data == null
        ? null
        : ShopReportTables.invoices([
            for (final i in data.invoices)
              if (i.customerName == 'Walk-in')
                Gstr1Invoice(
                  number: i.number,
                  date: i.date,
                  customerName: title('Walk-in'),
                  placeOfSupply: i.placeOfSupply,
                  lines: i.lines,
                  gstin: i.gstin,
                  roundOff: i.roundOff,
                  isCreditNote: i.isCreditNote,
                )
              else
                i,
          ], title: title);
    final fp = '${_month.toString().padLeft(2, '0')}$_year';
    Widget exportButtons() => Wrap(
      spacing: MkSpacing.sm,
      children: [
        MkButton(
          key: const ValueKey('gst-export-xlsx'),
          label: l10n.shrGstExportXlsx,
          icon: Icons.grid_on_outlined,
          variant: MkButtonVariant.secondary,
          onPressed: data == null || !allowed
              ? null
              : () => _save(
                  'GSTR1-$fp',
                  XlsxWriter.buildWorkbook([
                    ('b2b', _t(data.report.b2bTable(title: title))),
                    ('b2cl', _t(data.report.b2clTable(title: title))),
                    ('b2cs', _t(data.report.b2csTable(title: title))),
                    ('cdn', _t(data.report.cdnTable(title: title))),
                    ('hsn', _t(data.report.hsnTable(title: title))),
                    ('docs', _t(data.report.docsTable(title: title))),
                    ('invoices', invoices!),
                  ]),
                  'xlsx',
                  MimeType.microsoftExcel,
                ),
        ),
        MkButton(
          key: const ValueKey('gst-export-json'),
          label: l10n.shrGstExportJson,
          icon: Icons.data_object,
          variant: MkButtonVariant.secondary,
          onPressed: data == null || !allowed
              ? null
              : () => _save(
                  'GSTR1-$fp',
                  Uint8List.fromList(
                    utf8.encode(
                      const JsonEncoder.withIndent(
                        '  ',
                      ).convert(data.report.toJson()),
                    ),
                  ),
                  'json',
                  MimeType.json,
                ),
        ),
      ],
    );

    return ShopReportFrame(
      title: l10n.shrGstTitle,
      route: ShopReportRoutes.gst,
      controls: [
        MonthStepper(
          year: _year,
          month: _month,
          onChanged: (y, m) => setState(() {
            _year = y;
            _month = m;
          }),
        ),
        ShopExportBar(
          title: l10n.shrGstTabInvoices,
          fileStem: 'gst-invoices-$_year-$_month',
          table: invoices,
          permission: Permission.financeView,
          extra: [exportButtons()],
        ),
      ],
      body: data == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (data.gstinMissing || data.stateMissing)
                  MaterialBanner(
                    key: const ValueKey('gst-missing-banner'),
                    content: Text(l10n.shrGstMissingBanner),
                    leading: const Icon(Icons.warning_amber_rounded),
                    actions: [
                      TextButton(
                        onPressed: () => context.go(settingsRoute),
                        child: Text(l10n.shrGstOpenSettings),
                      ),
                    ],
                  ),
                Expanded(
                  child: DefaultTabController(
                    length: 8,
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,
                          tabs: [
                            Tab(text: l10n.shrGstTabSummary),
                            Tab(text: l10n.shrGstTabB2b),
                            Tab(text: l10n.shrGstTabB2cl),
                            Tab(text: l10n.shrGstTabB2cs),
                            Tab(text: l10n.shrGstTabNotes),
                            Tab(text: l10n.shrGstTabHsn),
                            Tab(text: l10n.shrGstTabInvoices),
                            Tab(
                              key: const ValueKey('gst-tab-issues'),
                              text:
                                  '${l10n.shrGstTabIssues}'
                                  ' (${data.flags.length})',
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _Summary(data: data),
                              _TableTab(_t(data.report.b2bTable(title: title))),
                              _TableTab(
                                _t(data.report.b2clTable(title: title)),
                              ),
                              _TableTab(
                                _t(data.report.b2csTable(title: title)),
                              ),
                              _TableTab(_t(data.report.cdnTable(title: title))),
                              _TableTab(_t(data.report.hsnTable(title: title))),
                              _TableTab(invoices!),
                              _Flags(flags: data.flags),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TableTab extends StatelessWidget {
  const _TableTab(this.table);

  final ReportTable table;

  @override
  Widget build(BuildContext context) => table.rows.isEmpty
      ? MkEmptyState(title: AppLocalizations.of(context).shrGstNothing)
      : ReportTableView(table: table);
}

class _Summary extends StatelessWidget {
  const _Summary({required this.data});

  final GstMonthData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = data.summary;
    Widget card(String key, String label, GstTotals t) => Card(
      key: ValueKey(key),
      child: Padding(
        padding: const EdgeInsets.all(MkSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            Text(l10n.shrGstCount(t.count)),
            Text(l10n.shrGstTaxable(t.taxable.format())),
            Text(
              'CGST ${t.cgst.format()} · SGST ${t.sgst.format()} · '
              'IGST ${t.igst.format()}',
            ),
          ],
        ),
      ),
    );
    return ListView(
      padding: const EdgeInsets.all(MkSpacing.md),
      children: [
        card('gst-b2b', l10n.shrGstB2b, s.b2b),
        card('gst-b2c', l10n.shrGstB2c, s.b2c),
        card('gst-notes', l10n.shrGstCreditNotes, s.creditNotes),
        card('gst-net', l10n.shrGstNet, s.net),
        Card(
          key: const ValueKey('gst-split'),
          child: Padding(
            padding: const EdgeInsets.all(MkSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.shrGstCgstSgst}: '
                  '${(s.net.cgst + s.net.sgst).format()}',
                ),
                Text('${l10n.shrGstIgst}: ${s.net.igst.format()}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Flags extends StatelessWidget {
  const _Flags({required this.flags});

  final List<GstProductFlag> flags;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (flags.isEmpty) return MkEmptyState(title: l10n.shrGstNoFlags);
    return ListView(
      children: [
        for (final f in flags)
          ListTile(
            key: ValueKey('flag-${f.productId}'),
            title: Text('${f.name} (${f.sku})'),
            subtitle: Text(
              [for (final i in f.issues) l10n.shrGstIssue(i.name)].join(' · '),
            ),
            trailing: TextButton(
              onPressed: () => context.push(ProductRoutes.edit(f.productId)),
              child: Text(l10n.shrGstEditProduct),
            ),
          ),
      ],
    );
  }
}
