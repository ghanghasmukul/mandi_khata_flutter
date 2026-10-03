import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:khata_core/khata_core.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Fonts for the statement PDF.
class StatementFonts {
  const StatementFonts({
    required this.regular,
    required this.bold,
    this.fallback = const [],
  });

  final pw.Font regular;
  final pw.Font bold;

  /// Used for glyphs the main font lacks (Devanagari, Gurmukhi names).
  final List<pw.Font> fallback;

  /// The fonts bundled with `mk_ui` (work offline).
  static Future<StatementFonts> load() async {
    Future<pw.Font> font(String file) async =>
        pw.Font.ttf(await rootBundle.load('packages/mk_ui/assets/fonts/$file'));
    return StatementFonts(
      regular: await font('IBMPlexSans-Regular.ttf'),
      bold: await font('IBMPlexSans-SemiBold.ttf'),
      fallback: [
        await font('NotoSansDevanagari-Regular.ttf'),
        await font('NotoSansGurmukhi-Regular.ttf'),
      ],
    );
  }
}

/// The words on the statement, already translated.
class StatementLabels {
  const StatementLabels({
    required this.title,
    required this.period,
    required this.opening,
    required this.closing,
    required this.date,
    required this.details,
    required this.udhaar,
    required this.jama,
    required this.baki,
    required this.totals,
    required this.balanceSide,
    required this.page,
    required this.reversedTag,
    required this.describe,
    required this.formatDate,
  });

  final String title;

  /// "1 Apr 2026 – 30 Sep 2026" or "All dates".
  final String period;
  final String opening;
  final String closing;
  final String date;
  final String details;
  final String udhaar;
  final String jama;
  final String baki;
  final String totals;

  /// "Jama · we owe" / "Udhaar · party owes" / "Settled" for a balance.
  final String Function(Money balance) balanceSide;
  final String Function(int page, int pages) page;
  final String reversedTag;
  final String Function(LedgerEntry entry) describe;
  final String Function(LedgerDate date) formatDate;
}

/// Who and what the statement is for.
class StatementHeader {
  const StatementHeader({
    required this.businessName,
    required this.partyName,
    this.partyCode,
    this.partyPlace,
    this.mobile,
  });

  final String businessName;
  final String partyName;
  final String? partyCode;
  final String? partyPlace;
  final String? mobile;
}

/// Builds the A4 khata statement PDF for a khata_core `Statement` (khata_core
/// already summed it; this only lays it out).
abstract final class StatementPdf {
  static Future<Uint8List> build({
    required Statement statement,
    required StatementHeader header,
    required StatementLabels labels,
    required StatementFonts fonts,
  }) => buildMany(
    statements: [(statement: statement, header: header)],
    labels: labels,
    fonts: fonts,
    title: '${labels.title} – ${header.partyName}',
  );

  /// One document with each party's statement starting on a new page (the
  /// bulk print of a village). Page numbers count the whole document.
  static Future<Uint8List> buildMany({
    required List<({Statement statement, StatementHeader header})> statements,
    required StatementLabels labels,
    required StatementFonts fonts,
    required String title,
  }) async {
    final doc = pw.Document(
      title: title,
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        fontFallback: fonts.fallback,
      ),
    );
    for (final s in statements) {
      _addParty(doc, s.statement, s.header, labels);
    }
    return await doc.save();
  }

  static void _addParty(
    pw.Document doc,
    Statement statement,
    StatementHeader header,
    StatementLabels labels,
  ) {
    const grey = PdfColors.grey700;
    const red = PdfColor.fromInt(0xFFB3261E);
    const green = PdfColor.fromInt(0xFF1B6B3A);

    pw.Widget cell(
      String text, {
      pw.TextAlign align = pw.TextAlign.left,
      bool bold = false,
      PdfColor? color,
      bool strike = false,
    }) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
          decoration: strike ? pw.TextDecoration.lineThrough : null,
        ),
      ),
    );

    String amount(Money m) => m.format();

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          cell(labels.date, bold: true),
          cell(labels.details, bold: true),
          cell(labels.udhaar, bold: true, align: pw.TextAlign.right),
          cell(labels.jama, bold: true, align: pw.TextAlign.right),
          cell(labels.baki, bold: true, align: pw.TextAlign.right),
        ],
      ),
      pw.TableRow(
        children: [
          cell(''),
          cell(labels.opening, bold: true),
          cell(''),
          cell(''),
          cell(
            '${amount(statement.opening.abs())} '
            '${labels.balanceSide(statement.opening)}',
            bold: true,
            align: pw.TextAlign.right,
          ),
        ],
      ),
      for (final r in statement.rows)
        pw.TableRow(
          children: [
            cell(
              labels.formatDate(r.entry.entryDate),
              strike: r.isStruck,
              color: r.isStruck ? grey : null,
            ),
            cell(
              r.isStruck && !r.entry.isReversal
                  ? '${labels.describe(r.entry)} (${labels.reversedTag})'
                  : labels.describe(r.entry),
              strike: r.isStruck,
              color: r.isStruck ? grey : null,
            ),
            cell(
              r.entry.side == Side.udhaar ? amount(r.entry.amount) : '',
              align: pw.TextAlign.right,
              color: r.isStruck ? grey : red,
              strike: r.isStruck,
            ),
            cell(
              r.entry.side == Side.jama ? amount(r.entry.amount) : '',
              align: pw.TextAlign.right,
              color: r.isStruck ? grey : green,
              strike: r.isStruck,
            ),
            cell(
              '${amount(r.balance.abs())} ${labels.balanceSide(r.balance)}',
              align: pw.TextAlign.right,
            ),
          ],
        ),
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          cell(''),
          cell(labels.totals, bold: true),
          cell(
            amount(statement.totalUdhaar),
            bold: true,
            align: pw.TextAlign.right,
          ),
          cell(
            amount(statement.totalJama),
            bold: true,
            align: pw.TextAlign.right,
          ),
          cell(''),
        ],
      ),
    ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              header.businessName,
              style: const pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(labels.title, style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 8),
            pw.Text(
              [
                header.partyName,
                ?header.partyCode,
                ?header.partyPlace,
                ?header.mobile,
              ].join(' · '),
              style: const pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              labels.period,
              style: const pw.TextStyle(fontSize: 9, color: grey),
            ),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            labels.page(ctx.pageNumber, ctx.pagesCount),
            style: const pw.TextStyle(fontSize: 8, color: grey),
          ),
        ),
        build: (_) => [
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(62),
              1: const pw.FlexColumnWidth(),
              2: const pw.FixedColumnWidth(70),
              3: const pw.FixedColumnWidth(70),
              4: const pw.FixedColumnWidth(96),
            },
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: PdfColors.grey300,
                width: 0.5,
              ),
              bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.5),
            ),
            children: rows,
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '${labels.closing}: ${amount(statement.closing.abs())} '
              '${labels.balanceSide(statement.closing)}',
              style: const pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
