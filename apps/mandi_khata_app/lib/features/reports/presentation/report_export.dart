import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/export/xlsx_writer.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/reports/data/report_pdf.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:printing/printing.dart';

/// What one report needs to be printed or saved.
class ReportExport {
  ReportExport({
    required this.title,
    required this.fileStem,
    required this.table,
    required this.businessName,
    required this.l10n,
    required this.formatDate,
    this.filterLines = const [],
    this.customPdf,
  });

  final String title;

  /// File name without extension, e.g. `outstanding-2026-10-03`.
  final String fileStem;
  final ReportTable table;
  final String businessName;
  final AppLocalizations l10n;
  final String Function(LedgerDate date) formatDate;
  final List<String> filterLines;

  /// Replaces the table PDF (the bulk statements lay out their own pages).
  final Future<Uint8List> Function(StatementFonts fonts)? customPdf;

  Future<Uint8List> pdf() async {
    final fonts = await StatementFonts.load();
    final custom = customPdf;
    if (custom != null) return await custom(fonts);
    return await ReportPdf.build(
      table: table,
      businessName: businessName,
      title: title,
      fonts: fonts,
      formatDate: formatDate,
      pageLabel: l10n.statementPage,
      filterLines: filterLines,
    );
  }

  Future<void> print() async {
    final bytes = await pdf();
    await Printing.layoutPdf(name: title, onLayout: (_) async => bytes);
  }

  Future<void> sharePdf() async {
    final bytes = await pdf();
    await Printing.sharePdf(bytes: bytes, filename: '$fileStem.pdf');
  }

  /// Saves the Excel file; the saved path / name, or null when cancelled.
  Future<String?> saveExcel() => FileSaver.instance.saveAs(
    name: fileStem,
    bytes: XlsxWriter.build(table, sheetName: title),
    fileExtension: 'xlsx',
    mimeType: MimeType.microsoftExcel,
  );

  /// Saves the CSV file (UTF-8 with a byte-order mark, so Excel reads Hindi
  /// and Punjabi names correctly).
  Future<String?> saveCsv() => FileSaver.instance.saveAs(
    name: fileStem,
    bytes: Uint8List.fromList([
      0xEF,
      0xBB,
      0xBF,
      ...utf8.encode(table.toCsv()),
    ]),
    fileExtension: 'csv',
    mimeType: MimeType.csv,
  );
}
