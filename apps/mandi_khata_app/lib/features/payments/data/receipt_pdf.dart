import 'dart:typed_data';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Paper for a receipt (setting `print.receipt_size`).
enum ReceiptLayout {
  /// A5 portrait: the receipt book size.
  a5('a5'),

  /// 80 mm thermal roll.
  thermal80('thermal_80'),

  /// 58 mm thermal roll.
  thermal58('thermal_58');

  const ReceiptLayout(this.settingValue);

  final String settingValue;

  static ReceiptLayout fromSetting(Object? value) =>
      values.firstWhere((l) => l.settingValue == value, orElse: () => a5);

  bool get isRoll => this != a5;
}

/// The words on a receipt, already translated.
class ReceiptLabels {
  const ReceiptLabels({
    required this.title,
    required this.partyLabel,
    required this.no,
    required this.date,
    required this.amount,
    required this.mode,
    required this.reference,
    required this.chequeNo,
    required this.chequeDate,
    required this.balanceAfter,
    required this.signature,
    required this.reversed,
    required this.balanceSide,
  });

  /// "Receipt" or "Payment voucher".
  final String title;

  /// "Received from" or "Paid to".
  final String partyLabel;
  final String no;
  final String date;
  final String amount;
  final String mode;
  final String reference;
  final String chequeNo;
  final String chequeDate;
  final String balanceAfter;
  final String signature;
  final String reversed;

  /// "Jama · we owe" / "Udhaar · party owes" / "Settled" for a balance.
  final String Function(Money balance) balanceSide;
}

/// What a receipt shows.
class ReceiptData {
  const ReceiptData({
    required this.businessName,
    required this.receiptNo,
    required this.date,
    required this.partyName,
    required this.amount,
    required this.modeName,
    this.partyDetail,
    this.reference,
    this.chequeNo,
    this.chequeDate,
    this.narration,
    this.balanceAfter,
    this.isReversed = false,
  });

  final String businessName;
  final String receiptNo;

  /// Already formatted for the receipt's language.
  final String date;
  final String partyName;

  /// Code, village: "P-W1-0007 · Rampura".
  final String? partyDetail;
  final Money amount;
  final String modeName;
  final String? reference;
  final String? chequeNo;
  final String? chequeDate;
  final String? narration;

  /// The party's khata balance once this payment is in; only known right
  /// after recording (a later reprint leaves it out).
  final Money? balanceAfter;
  final bool isReversed;
}

/// Builds a receipt / payment voucher PDF for an A5 sheet or a thermal roll.
/// Fonts come bundled (offline); Hindi and Punjabi glyphs use the fallback
/// fonts (see docs/decisions.md on conjunct shaping).
abstract final class ReceiptPdf {
  static PdfPageFormat format(ReceiptLayout layout) => switch (layout) {
    ReceiptLayout.a5 => PdfPageFormat.a5.copyWith(
      marginTop: 28,
      marginBottom: 28,
      marginLeft: 28,
      marginRight: 28,
    ),
    ReceiptLayout.thermal80 => PdfPageFormat.roll80.copyWith(
      marginTop: 8,
      marginBottom: 8,
      marginLeft: 8,
      marginRight: 8,
    ),
    ReceiptLayout.thermal58 => PdfPageFormat.roll57.copyWith(
      marginTop: 6,
      marginBottom: 6,
      marginLeft: 5,
      marginRight: 5,
    ),
  };

  static Future<Uint8List> build({
    required ReceiptData data,
    required ReceiptLabels labels,
    required StatementFonts fonts,
    ReceiptLayout layout = ReceiptLayout.a5,
  }) async {
    final doc = pw.Document(
      title: '${labels.title} ${data.receiptNo}',
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        fontFallback: fonts.fallback,
      ),
    );
    final roll = layout.isRoll;
    final small = layout == ReceiptLayout.thermal58;
    final base = roll ? (small ? 8.0 : 9.0) : 11.0;

    pw.Widget row(String label, String value, {bool bold = false}) =>
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: roll ? 1.5 : 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: roll ? (small ? 52 : 64) : 96,
                child: pw.Text(
                  label,
                  style: pw.TextStyle(fontSize: base, color: PdfColors.grey700),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  value,
                  style: pw.TextStyle(
                    fontSize: base,
                    fontWeight: bold
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );

    final rule = pw.Divider(thickness: 0.5, color: PdfColors.grey600);
    final balance = data.balanceAfter;
    final content = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Center(
          child: pw.Text(
            data.businessName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: base + (roll ? 2 : 5),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: roll ? 2 : 4),
        pw.Center(
          child: pw.Text(
            labels.title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: base + 1,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        if (data.isReversed)
          pw.Center(
            child: pw.Text(
              labels.reversed,
              style: pw.TextStyle(
                fontSize: base + 2,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red800,
              ),
            ),
          ),
        rule,
        row(labels.no, data.receiptNo, bold: true),
        row(labels.date, data.date),
        row(labels.partyLabel, data.partyName, bold: true),
        if (data.partyDetail != null) row('', data.partyDetail!),
        rule,
        row(
          labels.amount,
          data.amount.format(paise: PaiseDisplay.always),
          bold: true,
        ),
        row(labels.mode, data.modeName),
        if (data.reference != null) row(labels.reference, data.reference!),
        if (data.chequeNo != null) row(labels.chequeNo, data.chequeNo!),
        if (data.chequeDate != null) row(labels.chequeDate, data.chequeDate!),
        if (data.narration != null) row('', data.narration!),
        if (balance != null) ...[
          rule,
          row(
            labels.balanceAfter,
            '${balance.abs().format()} ${labels.balanceSide(balance)}',
          ),
        ],
        pw.SizedBox(height: roll ? 14 : 40),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            children: [
              pw.Container(
                width: roll ? 80 : 130,
                height: 0.5,
                color: PdfColors.grey700,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                labels.signature,
                style: pw.TextStyle(
                  fontSize: base - 1,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    doc.addPage(pw.Page(pageFormat: format(layout), build: (_) => content));
    return await doc.save();
  }
}
