import 'dart:typed_data';

import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// One line of the slip: a label and an amount already formatted.
typedef SlipLine = ({String label, String amount, bool bold});

/// What the settlement slip (hisaab) says, already translated and
/// formatted. The figures come from khata_core `Settlement`.
class SettlementSlip {
  const SettlementSlip({
    required this.title,
    required this.businessName,
    required this.partyName,
    required this.asOf,
    required this.lines,
    required this.finalLabel,
    required this.finalAmount,
    required this.partySignature,
    required this.ownerSignature,
    this.partyCode,
    this.partyPlace,
    this.reasonLine,
  });

  final String title;
  final String businessName;
  final String partyName;
  final String? partyCode;
  final String? partyPlace;

  /// "Settled up to 11 Apr 2027".
  final String asOf;
  final List<SlipLine> lines;

  /// "Party pays you" / "You pay the party" / "Settled".
  final String finalLabel;
  final String finalAmount;

  /// "Discount reason: Diwali", when interest is waived.
  final String? reasonLine;
  final String partySignature;
  final String ownerSignature;
}

/// Lays out the A5 settlement slip.
abstract final class SettlementSlipPdf {
  static Future<Uint8List> build({
    required SettlementSlip slip,
    required StatementFonts fonts,
  }) async {
    final doc = pw.Document(
      title: '${slip.title} – ${slip.partyName}',
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        fontFallback: fonts.fallback,
      ),
    );
    pw.Widget row(SlipLine l) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            l.label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: l.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            l.amount,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: l.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              slip.businessName,
              style: const pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(slip.title, style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 8),
            pw.Text(
              [
                slip.partyName,
                if (slip.partyCode != null) slip.partyCode!,
                if (slip.partyPlace != null) slip.partyPlace!,
              ].join(' · '),
              style: const pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              slip.asOf,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.Divider(),
            for (final l in slip.lines) row(l),
            pw.Divider(thickness: 1.2),
            row((label: slip.finalLabel, amount: slip.finalAmount, bold: true)),
            if (slip.reasonLine != null)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 6),
                child: pw.Text(
                  slip.reasonLine!,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            pw.Spacer(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _signature(slip.partySignature),
                _signature(slip.ownerSignature),
              ],
            ),
          ],
        ),
      ),
    );
    return await doc.save();
  }

  static pw.Widget _signature(String label) => pw.Column(
    children: [
      pw.Container(width: 110, height: 0.8, color: PdfColors.grey700),
      pw.SizedBox(height: 3),
      pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
    ],
  );
}
