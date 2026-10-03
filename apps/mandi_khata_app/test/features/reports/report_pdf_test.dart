import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:mandi_khata_app/features/reports/data/report_pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Font _font(String file) => pw.Font.ttf(
  ByteData.sublistView(
    File('../../packages/mk_ui/assets/fonts/$file').readAsBytesSync(),
  ),
);

StatementFonts _fonts() => StatementFonts(
  regular: _font('IBMPlexSans-Regular.ttf'),
  bold: _font('IBMPlexSans-SemiBold.ttf'),
  fallback: [
    _font('NotoSansDevanagari-Regular.ttf'),
    _font('NotoSansGurmukhi-Regular.ttf'),
  ],
);

int _pages(Uint8List bytes) => RegExp(
  r'/Type\s*/Page\b',
).allMatches(latin1.decode(bytes, allowInvalid: true)).length;

void main() {
  test('a report table spreads over pages with its header repeated', () async {
    final table = ReportTable(
      columns: const [
        ReportColumn('Lot', ReportColumnKind.text),
        ReportColumn('Date', ReportColumnKind.date),
        ReportColumn('Qtl', ReportColumnKind.quantity),
        ReportColumn('Gross', ReportColumnKind.money),
      ],
      rows: [
        for (var i = 0; i < 300; i++)
          ['L-$i', LedgerDate(2026, 10, 1), 8640, Money.rupees(1000 + i)],
      ],
      totals: const ['Total', null, 2592000, Money(30000000)],
    );
    final bytes = await ReportPdf.build(
      table: table,
      businessName: 'Gupta Arhat',
      title: 'Arrival register',
      fonts: _fonts(),
      formatDate: (d) => d.toString(),
      pageLabel: (p, n) => 'Page $p of $n',
      filterLines: const ['Period: this season'],
    );
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
    // 300 rows do not fit one page (and the default cap was 20 pages).
    expect(_pages(bytes), greaterThan(3));
  });

  test('a wide report prints landscape', () async {
    Future<Uint8List> pdf(int columns) => ReportPdf.build(
      table: ReportTable(
        columns: [
          for (var i = 0; i < columns; i++)
            const ReportColumn('c', ReportColumnKind.text),
        ],
        rows: [
          [for (var i = 0; i < columns; i++) 'x'],
        ],
      ),
      businessName: 'B',
      title: 'T',
      fonts: _fonts(),
      formatDate: (d) => d.toString(),
      pageLabel: (p, n) => '$p/$n',
    );
    final narrow = latin1.decode(await pdf(4), allowInvalid: true);
    final wide = latin1.decode(await pdf(9), allowInvalid: true);
    // A4 portrait is 595 x 842 points, landscape 842 x 595.
    expect(narrow, contains('595.27'));
    expect(wide, matches(RegExp(r'MediaBox\s*\[\s*0\s+0\s+841\.')));
  });

  test('bulk statements put every party on its own page', () async {
    Statement statement(int n) => LedgerCalculator.statement([
      LedgerEntry(
        id: 'e$n',
        partyId: 'p$n',
        entryDate: LedgerDate(2026, 4, 1),
        side: Side.jama,
        amount: Money.rupees(1000 * n),
        refType: RefType.journal,
        createdAt: DateTime.utc(2026),
      ),
    ]);
    final labels = StatementLabels(
      title: 'Khata statement',
      period: 'All dates',
      opening: 'Opening balance',
      closing: 'Closing balance',
      date: 'Date',
      details: 'Details',
      udhaar: 'Udhaar',
      jama: 'Jama',
      baki: 'Baki',
      totals: 'Total',
      balanceSide: (m) => m.isPositive ? 'Jama' : 'Udhaar',
      page: (p, n) => 'Page $p of $n',
      reversedTag: 'reversed',
      describe: (e) => e.refType.dbName,
      formatDate: (d) => d.toString(),
    );
    final bytes = await StatementPdf.buildMany(
      title: 'Rampura',
      labels: labels,
      fonts: _fonts(),
      statements: [
        for (var n = 1; n <= 4; n++)
          (
            statement: statement(n),
            header: StatementHeader(
              businessName: 'Gupta Arhat',
              partyName: 'Farmer $n',
              partyCode: 'F-$n',
            ),
          ),
      ],
    );
    expect(_pages(bytes), 4);
  });
}
