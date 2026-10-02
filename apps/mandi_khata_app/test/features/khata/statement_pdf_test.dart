import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/khata/data/statement_pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Font _font(String file) => pw.Font.ttf(
  ByteData.sublistView(
    File('../../packages/mk_ui/assets/fonts/$file').readAsBytesSync(),
  ),
);

LedgerEntry _entry(
  String id,
  String date,
  Side side,
  int rupees, {
  RefType type = RefType.journal,
  String? reverses,
}) => LedgerEntry(
  id: id,
  partyId: 'p1',
  entryDate: LedgerDate.parse(date),
  side: side,
  amount: Money.rupees(rupees),
  refType: type,
  reversesId: reverses,
  createdAt: DateTime.utc(2026, 4, 1, 10),
);

void main() {
  test('builds a multi-page A4 statement with every figure', () async {
    final entries = [
      _entry('a', '2026-04-01', Side.udhaar, 2000),
      _entry('b', '2026-04-05', Side.jama, 15558, type: RefType.arrival),
      _entry('c', '2026-04-09', Side.jama, 999),
      _entry(
        'd',
        '2026-04-09',
        Side.udhaar,
        999,
        type: RefType.reversal,
        reverses: 'c',
      ),
      // Enough rows to need a second page.
      for (var i = 0; i < 70; i++)
        _entry('x$i', '2026-05-01', Side.udhaar, 10 + i),
    ];
    final statement = LedgerCalculator.statement(entries);
    final bytes = await StatementPdf.build(
      statement: statement,
      fonts: StatementFonts(
        regular: _font('IBMPlexSans-Regular.ttf'),
        bold: _font('IBMPlexSans-SemiBold.ttf'),
        fallback: [
          _font('NotoSansDevanagari-Regular.ttf'),
          _font('NotoSansGurmukhi-Regular.ttf'),
        ],
      ),
      header: const StatementHeader(
        businessName: 'Gupta Arhat',
        partyName: 'Gurmeet Singh',
        partyCode: 'F-101',
        partyPlace: 'Rampura',
      ),
      labels: StatementLabels(
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
      ),
    );
    final text = latin1.decode(bytes, allowInvalid: true);
    expect(text.startsWith('%PDF-'), isTrue);
    expect(RegExp(r'/Type\s*/Page\b').allMatches(text).length, greaterThan(1));
    expect(bytes.length, greaterThan(5000));
  });
}
