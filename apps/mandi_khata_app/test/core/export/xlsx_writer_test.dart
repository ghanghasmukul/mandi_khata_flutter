import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/export/xlsx_writer.dart';
import 'package:xml/xml.dart';

String _part(List<int> zip, String path) {
  final archive = ZipDecoder().decodeBytes(zip);
  return utf8.decode(archive.findFile(path)!.content);
}

void main() {
  final table = ReportTable(
    columns: const [
      ReportColumn('Party & <Co>', ReportColumnKind.text),
      ReportColumn('Date', ReportColumnKind.date),
      ReportColumn('Amount', ReportColumnKind.money),
      ReportColumn('Qtl', ReportColumnKind.quantity),
      ReportColumn('Bags', ReportColumnKind.number),
    ],
    rows: [
      ['Ram "Lal"', LedgerDate(2026, 4, 1), const Money(155580), 8640, 12],
      const ['ਗੁਰਮੀਤ', null, Money(-5), 15375, 0],
    ],
    totals: const ['Total', null, Money(155575), null, 12],
  );

  test('writes every part of a valid workbook', () {
    final bytes = XlsxWriter.build(table, sheetName: 'Out/standing?');
    final names = ZipDecoder().decodeBytes(bytes).files.map((f) => f.name);
    expect(
      names,
      containsAll([
        '[Content_Types].xml',
        '_rels/.rels',
        'xl/workbook.xml',
        'xl/_rels/workbook.xml.rels',
        'xl/styles.xml',
        'xl/worksheets/sheet1.xml',
      ]),
    );
    for (final n in names) {
      // Every part is well-formed XML.
      XmlDocument.parse(_part(bytes, n));
    }
    expect(_part(bytes, 'xl/workbook.xml'), contains('name="Out standing"'));
  });

  test('keeps money exact, dates real, text escaped', () {
    final xml = _part(XlsxWriter.build(table), 'xl/worksheets/sheet1.xml');
    final doc = XmlDocument.parse(xml);
    String? value(String ref) => doc
        .findAllElements('c')
        .firstWhere((c) => c.getAttribute('r') == ref)
        .getElement('v')
        ?.innerText;
    String inline(String ref) => doc
        .findAllElements('c')
        .firstWhere((c) => c.getAttribute('r') == ref)
        .findAllElements('t')
        .single
        .innerText;

    expect(inline('A1'), 'Party & <Co>');
    expect(inline('A2'), 'Ram "Lal"');
    expect(inline('A3'), 'ਗੁਰਮੀਤ');
    // 2026-04-01 is Excel day 46113.
    expect(value('B2'), '46113');
    expect(value('C2'), '1555.80');
    expect(value('C3'), '-0.05');
    expect(value('D2'), '8.64');
    expect(value('D3'), '15.375');
    expect(value('E2'), '12');
    // Totals row.
    expect(inline('A4'), 'Total');
    expect(value('C4'), '1555.75');
  });

  test('column letters go past Z', () {
    final wide = ReportTable(
      columns: [
        for (var i = 0; i < 28; i++)
          const ReportColumn('c', ReportColumnKind.text),
      ],
      rows: [
        [for (var i = 0; i < 28; i++) 'x'],
      ],
    );
    final xml = _part(XlsxWriter.build(wide), 'xl/worksheets/sheet1.xml');
    expect(xml, contains('r="Z1"'));
    expect(xml, contains('r="AA1"'));
    expect(xml, contains('r="AB2"'));
  });
}
