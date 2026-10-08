import 'dart:typed_data';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/payments/data/receipt_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The words on an invoice, already translated.
class InvoiceLabels {
  const InvoiceLabels({
    required this.title,
    required this.no,
    required this.date,
    required this.billTo,
    required this.gstin,
    required this.placeOfSupply,
    required this.item,
    required this.hsn,
    required this.qty,
    required this.rate,
    required this.taxable,
    required this.gstPct,
    required this.amount,
    required this.discount,
    required this.subtotal,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.roundOff,
    required this.total,
    required this.paidCash,
    required this.paidUpi,
    required this.udhaar,
    required this.thanks,
    required this.signature,
    required this.reversed,
  });

  final String title;
  final String no;
  final String date;
  final String billTo;
  final String gstin;
  final String placeOfSupply;
  final String item;
  final String hsn;
  final String qty;
  final String rate;
  final String taxable;
  final String gstPct;
  final String amount;
  final String discount;
  final String subtotal;
  final String cgst;
  final String sgst;
  final String igst;
  final String roundOff;
  final String total;
  final String paidCash;
  final String paidUpi;
  final String udhaar;
  final String thanks;
  final String signature;
  final String reversed;
}

/// One printed line.
class InvoiceLineData {
  const InvoiceLineData({
    required this.name,
    required this.qty,
    required this.rate,
    required this.taxable,
    required this.amount,
    this.hsn,
    this.gstPct,
    this.discount = Money.zero,
    this.batchCaption,
  });

  final String name;
  final String? hsn;
  final String qty;
  final Money rate;
  final Money discount;
  final Money taxable;
  final String? gstPct;
  final Money amount;
  final String? batchCaption;
}

/// What an invoice shows.
class InvoiceData {
  const InvoiceData({
    required this.businessName,
    required this.saleNo,
    required this.date,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.roundOff,
    required this.total,
    required this.paidCash,
    required this.paidUpi,
    required this.udhaar,
    this.businessGstin,
    this.customerName,
    this.customerDetail,
    this.customerGstin,
    this.placeOfSupply,
    this.isReversed = false,
    this.showGst = true,
  });

  final String businessName;
  final String? businessGstin;
  final String saleNo;

  /// Already formatted for the invoice's language.
  final String date;
  final String? customerName;
  final String? customerDetail;
  final String? customerGstin;
  final String? placeOfSupply;
  final List<InvoiceLineData> lines;
  final Money subtotal;
  final Money discount;
  final Money taxable;
  final Money cgst;
  final Money sgst;
  final Money igst;
  final Money roundOff;
  final Money total;
  final Money paidCash;
  final Money paidUpi;
  final Money udhaar;
  final bool isReversed;

  /// False when GST is switched off: a plain bill without tax columns.
  final bool showGst;
}

/// Builds an A5 GST invoice or an 80 mm thermal bill (same fonts and layout
/// rules as [ReceiptPdf]).
abstract final class InvoicePdf {
  static Future<Uint8List> build({
    required InvoiceData data,
    required InvoiceLabels labels,
    required StatementFonts fonts,
    ReceiptLayout layout = ReceiptLayout.a5,
  }) async {
    final doc = pw.Document(
      title: '${labels.title} ${data.saleNo}',
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        fontFallback: fonts.fallback,
      ),
    );
    final roll = layout.isRoll;
    final base = roll ? (layout == ReceiptLayout.thermal58 ? 8.0 : 9.0) : 9.5;
    pw.TextStyle st({bool bold = false, double? size, PdfColor? color}) =>
        pw.TextStyle(
          fontSize: size ?? base,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        );
    String m(Money v) => v.format(paise: PaiseDisplay.always);
    final rule = pw.Divider(thickness: 0.5, color: PdfColors.grey600);

    pw.Widget kv(String k, String v, {bool bold = false}) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(k, style: st(bold: bold)),
        pw.Text(v, style: st(bold: bold)),
      ],
    );

    final header = <pw.Widget>[
      pw.Center(
        child: pw.Text(
          data.businessName,
          textAlign: pw.TextAlign.center,
          style: st(bold: true, size: base + (roll ? 2 : 5)),
        ),
      ),
      if ((data.businessGstin ?? '').isNotEmpty)
        pw.Center(
          child: pw.Text('${labels.gstin}: ${data.businessGstin}', style: st()),
        ),
      pw.SizedBox(height: 3),
      pw.Center(
        child: pw.Text(labels.title, style: st(bold: true, size: base + 1)),
      ),
      if (data.isReversed)
        pw.Center(
          child: pw.Text(
            labels.reversed,
            style: st(bold: true, size: base + 3, color: PdfColors.red800),
          ),
        ),
      rule,
      kv(labels.no, data.saleNo, bold: true),
      kv(labels.date, data.date),
      if ((data.customerName ?? '').isNotEmpty)
        pw.Text(
          '${labels.billTo}: ${data.customerName}',
          style: st(bold: true),
        ),
      if ((data.customerDetail ?? '').isNotEmpty)
        pw.Text(data.customerDetail!, style: st()),
      if ((data.customerGstin ?? '').isNotEmpty)
        pw.Text('${labels.gstin}: ${data.customerGstin}', style: st()),
      if (data.showGst && (data.placeOfSupply ?? '').isNotEmpty)
        pw.Text('${labels.placeOfSupply}: ${data.placeOfSupply}', style: st()),
      rule,
    ];

    final pw.Widget lines;
    if (roll) {
      lines = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final l in data.lines) ...[
            pw.Text(l.name, style: st(bold: true)),
            if (l.batchCaption != null)
              pw.Text(l.batchCaption!, style: st(size: base - 1)),
            kv('${l.qty} x ${m(l.rate)}', m(l.amount)),
            pw.SizedBox(height: 2),
          ],
        ],
      );
    } else {
      final head = [
        labels.item,
        if (data.showGst) labels.hsn,
        labels.qty,
        labels.rate,
        labels.discount,
        if (data.showGst) labels.taxable,
        if (data.showGst) labels.gstPct,
        labels.amount,
      ];
      final widths = <int, pw.TableColumnWidth>{
        0: const pw.FlexColumnWidth(3.2),
        for (var i = 1; i < head.length; i++) i: const pw.FlexColumnWidth(1.3),
      };
      lines = pw.Table(
        columnWidths: widths,
        border: const pw.TableBorder(
          horizontalInside: pw.BorderSide(width: 0.3, color: PdfColors.grey500),
          bottom: pw.BorderSide(width: 0.5),
          top: pw.BorderSide(width: 0.5),
        ),
        children: [
          pw.TableRow(
            children: [
              for (final h in head)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Text(h, style: st(bold: true, size: base - 1)),
                ),
            ],
          ),
          for (final l in data.lines)
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(l.name, style: st()),
                      if (l.batchCaption != null)
                        pw.Text(
                          l.batchCaption!,
                          style: st(size: base - 2, color: PdfColors.grey700),
                        ),
                    ],
                  ),
                ),
                if (data.showGst) pw.Text(l.hsn ?? '', style: st()),
                pw.Text(l.qty, style: st()),
                pw.Text(m(l.rate), style: st()),
                pw.Text(l.discount.isZero ? '' : m(l.discount), style: st()),
                if (data.showGst) pw.Text(m(l.taxable), style: st()),
                if (data.showGst) pw.Text(l.gstPct ?? '', style: st()),
                pw.Text(m(l.amount), style: st(bold: true)),
              ],
            ),
        ],
      );
    }

    final totals = <pw.Widget>[
      pw.SizedBox(height: 4),
      if (!data.discount.isZero) ...[
        kv(labels.subtotal, m(data.subtotal)),
        kv(labels.discount, '- ${m(data.discount)}'),
      ],
      if (data.showGst) ...[
        kv(labels.taxable, m(data.taxable)),
        if (data.cgst.isPositive) kv(labels.cgst, m(data.cgst)),
        if (data.sgst.isPositive) kv(labels.sgst, m(data.sgst)),
        if (data.igst.isPositive) kv(labels.igst, m(data.igst)),
      ],
      if (!data.roundOff.isZero) kv(labels.roundOff, m(data.roundOff)),
      rule,
      kv(labels.total, m(data.total), bold: true),
      pw.SizedBox(height: 3),
      if (data.paidCash.isPositive) kv(labels.paidCash, m(data.paidCash)),
      if (data.paidUpi.isPositive) kv(labels.paidUpi, m(data.paidUpi)),
      if (data.udhaar.isPositive) kv(labels.udhaar, m(data.udhaar)),
      pw.SizedBox(height: roll ? 8 : 24),
      if (roll)
        pw.Center(child: pw.Text(labels.thanks, style: st()))
      else
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(labels.thanks, style: st()),
            pw.Text(labels.signature, style: st(color: PdfColors.grey700)),
          ],
        ),
    ];

    // A long bill flows over pages (MultiPage); a roll is one tall page.
    if (roll) {
      doc.addPage(
        pw.Page(
          pageFormat: ReceiptPdf.format(layout),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            mainAxisSize: pw.MainAxisSize.min,
            children: [...header, lines, ...totals],
          ),
        ),
      );
    } else {
      doc.addPage(
        pw.MultiPage(
          pageFormat: ReceiptPdf.format(layout),
          build: (_) => [...header, lines, ...totals],
        ),
      );
    }
    return await doc.save();
  }
}
