import 'dart:typed_data';

import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A party's byaj statement as the engine worked it out, already translated
/// and formatted (see `interestStatementData`). The PDF only lays it out, in
/// the language of [headers] and [rows]; the bundled fonts cover Hindi and
/// Punjabi.
class InterestStatementData {
  const InterestStatementData({
    required this.title,
    required this.businessName,
    required this.partyName,
    required this.asOf,
    required this.terms,
    required this.figures,
    required this.headers,
    required this.rows,
    this.partyCode,
    this.partyPlace,
  });

  final String title;
  final String businessName;
  final String partyName;
  final String? partyCode;
  final String? partyPlace;

  /// "Byaj up to 11 Apr 2027".
  final String asOf;

  /// "18% p.a., simple".
  final String terms;

  /// Label and amount lines (principal, accrued, posted, payable …).
  final List<({String label, String amount, bool bold})> figures;
  final List<String> headers;
  final List<List<String>> rows;
}

abstract final class InterestStatementPdf {
  /// Columns from the right: numbers; the event column takes the width.
  static Future<Uint8List> build({
    required InterestStatementData data,
    required StatementFonts fonts,
  }) async {
    final doc = pw.Document(
      title: '${data.title} – ${data.partyName}',
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        fontFallback: fonts.fallback,
      ),
    );
    const grey = PdfColors.grey700;
    pw.Widget cell(String t, {bool bold = false, bool right = false}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: pw.Text(
            t,
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        );
    // Event text (column 2) is left aligned, dates (0, 1) too.
    bool isRight(int c) => c > 2;
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              data.businessName,
              style: const pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(data.title, style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 6),
            pw.Text(
              [
                data.partyName,
                if (data.partyCode != null) data.partyCode!,
                if (data.partyPlace != null) data.partyPlace!,
              ].join(' · '),
              style: const pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              '${data.asOf} · ${data.terms}',
              style: const pw.TextStyle(fontSize: 9, color: grey),
            ),
            pw.SizedBox(height: 6),
          ],
        ),
        build: (_) => [
          for (final f in data.figures)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.SizedBox(
                  width: 260,
                  child: pw.Text(
                    f.label,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: f.bold
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
                    ),
                  ),
                ),
                pw.Text(
                  f.amount,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: f.bold
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal,
                  ),
                ),
              ],
            ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(color: PdfColors.grey300),
              bottom: pw.BorderSide(color: PdfColors.grey500),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.2),
              1: const pw.FlexColumnWidth(2.2),
              2: const pw.FlexColumnWidth(5),
              for (var c = 3; c < data.headers.length; c++)
                c: const pw.FlexColumnWidth(2.4),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  for (var c = 0; c < data.headers.length; c++)
                    cell(data.headers[c], bold: true, right: isRight(c)),
                ],
              ),
              for (final r in data.rows)
                pw.TableRow(
                  children: [
                    for (var c = 0; c < r.length; c++)
                      cell(r[c], right: isRight(c)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
    return await doc.save();
  }
}
