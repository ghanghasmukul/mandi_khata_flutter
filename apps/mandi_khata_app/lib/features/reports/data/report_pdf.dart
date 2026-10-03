import 'dart:typed_data';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Lays a [ReportTable] out as a PDF: business name, report title, filter
/// lines, then the table with a totals row. A4 landscape when the table has
/// more than six columns, portrait otherwise.
abstract final class ReportPdf {
  static const PdfColor _grey = PdfColors.grey700;

  static Future<Uint8List> build({
    required ReportTable table,
    required String businessName,
    required String title,
    required StatementFonts fonts,
    required String Function(LedgerDate date) formatDate,
    required String Function(int page, int pages) pageLabel,
    List<String> filterLines = const [],
  }) async {
    final doc = pw.Document(
      title: '$businessName – $title',
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        fontFallback: fonts.fallback,
      ),
    );

    String text(int column, Object? cell) => switch (cell) {
      null => '',
      final Money m => m.format(),
      final LedgerDate d => formatDate(d),
      final int milli
          when table.columns[column].kind == ReportColumnKind.quantity =>
        Quintals.format(milli),
      final Object o => o.toString(),
    };

    pw.Alignment alignOf(ReportColumnKind kind) => kind == ReportColumnKind.text
        ? pw.Alignment.centerLeft
        : pw.Alignment.centerRight;

    pw.Widget cell(
      int column,
      Object? value, {
      bool bold = false,
      bool header = false,
    }) => pw.Container(
      alignment: alignOf(table.columns[column].kind),
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: pw.Text(
        header ? table.columns[column].title : text(column, value),
        textAlign: table.columns[column].kind == ReportColumnKind.text
            ? pw.TextAlign.left
            : pw.TextAlign.right,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: bold || header
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
        ),
      ),
    );

    pw.TableRow dataRow(List<Object?> values, {bool bold = false}) =>
        pw.TableRow(
          decoration: bold
              ? const pw.BoxDecoration(color: PdfColors.grey200)
              : null,
          children: [
            for (var i = 0; i < table.columns.length; i++)
              cell(i, i < values.length ? values[i] : null, bold: bold),
          ],
        );

    final widths = <int, pw.TableColumnWidth>{
      for (var i = 0; i < table.columns.length; i++)
        i: table.columns[i].kind == ReportColumnKind.text
            ? const pw.FlexColumnWidth(2)
            : const pw.FlexColumnWidth(1.3),
    };

    final landscape = table.columns.length > 6;
    final totals = table.totals;
    doc.addPage(
      pw.MultiPage(
        pageFormat: landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        // A season is thousands of rows; the default cap is 20 pages.
        maxPages: 5000,
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              businessName,
              style: const pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(title, style: const pw.TextStyle(fontSize: 11)),
            for (final line in filterLines)
              pw.Text(
                line,
                style: const pw.TextStyle(fontSize: 9, color: _grey),
              ),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            pageLabel(ctx.pageNumber, ctx.pagesCount),
            style: const pw.TextStyle(fontSize: 8, color: _grey),
          ),
        ),
        build: (_) => [
          pw.Table(
            columnWidths: widths,
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: PdfColors.grey300,
                width: 0.5,
              ),
              bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.5),
            ),
            children: [
              pw.TableRow(
                repeat: true,
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  for (var i = 0; i < table.columns.length; i++)
                    cell(i, null, header: true),
                ],
              ),
              for (final row in table.rows) dataRow(row),
              if (totals != null) dataRow(totals, bold: true),
            ],
          ),
        ],
      ),
    );
    return await doc.save();
  }
}
