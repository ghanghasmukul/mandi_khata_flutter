// The XML snippets are written as adjacent string literals; they are
// markup, not sentences, so no whitespace belongs between them.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

List<int> _xlsx({
  required String sheetXml,
  String? sharedStrings,
  bool withWorkbook = true,
}) {
  final zip = Archive()
    ..addFile(
      ArchiveFile.bytes('xl/worksheets/sheet1.xml', utf8.encode(sheetXml)),
    );
  if (sharedStrings != null) {
    zip.addFile(
      ArchiveFile.bytes('xl/sharedStrings.xml', utf8.encode(sharedStrings)),
    );
  }
  if (withWorkbook) {
    zip
      ..addFile(
        ArchiveFile.bytes(
          'xl/workbook.xml',
          utf8.encode(
            '<workbook xmlns="http://schemas.openxmlformats.org/'
            'spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.'
            'org/officeDocument/2006/relationships"><sheets>'
            '<sheet name="Parties" sheetId="1" r:id="rId7"/></sheets>'
            '</workbook>',
          ),
        ),
      )
      ..addFile(
        ArchiveFile.bytes(
          'xl/_rels/workbook.xml.rels',
          utf8.encode(
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/'
            '2006/relationships"><Relationship Id="rId7" Type="worksheet" '
            'Target="worksheets/sheet1.xml"/></Relationships>',
          ),
        ),
      );
  }
  return ZipEncoder().encode(zip);
}

void main() {
  group('DelimitedText', () {
    test('comma separated with a header and blank lines', () {
      final sheet = DelimitedText.parse(
        'Name,Village,Amount\n\nRamesh,Rampura,"1,500"\r\nSita,,200\n',
      );
      expect(sheet.rows.length, 3);
      expect(sheet.rows[0].cells, ['Name', 'Village', 'Amount']);
      expect(sheet.rows[1].cells, ['Ramesh', 'Rampura', '1,500']);
      // The blank line still counts for the row number.
      expect(sheet.rows[1].number, 3);
      expect(sheet.rows[2].cells, ['Sita', '', '200']);
      expect(sheet.rows[2].number, 4);
    });

    test('tab separated (pasted from Excel) wins over commas in cells', () {
      final sheet = DelimitedText.parse('Name\tAmount\nRamesh\t1,500\n');
      expect(sheet.rows[1].cells, ['Ramesh', '1,500']);
    });

    test('semicolons, quotes with doubled quotes and line breaks', () {
      final sheet = DelimitedText.parse('Name;Note\n"Ram ""Bhai""";"a;b\nc"\n');
      expect(sheet.rows[1].cells[0], 'Ram "Bhai"');
      expect(sheet.rows[1].cells[1], 'a;b\nc');
    });

    test('byte-order mark is ignored and Hindi survives', () {
      final sheet = DelimitedText.parse('﻿नाम,बाकी\nरमेश,500\n');
      expect(sheet.rows.first.cells, ['नाम', 'बाकी']);
      expect(sheet.rows[1].cells, ['रमेश', '500']);
    });

    test('empty text gives an empty sheet', () {
      expect(DelimitedText.parse('  \n\n').isEmpty, isTrue);
    });
  });

  group('XlsxReader', () {
    test('shared strings, numbers, inline strings, gaps, row numbers', () {
      final bytes = _xlsx(
        sharedStrings:
            '<sst><si><t>Name</t></si><si><t>Balance</t></si>'
            '<si><r><t>Ram</t></r><r><t>esh</t></r></si></sst>',
        sheetXml:
            '<worksheet><sheetData>'
            '<row r="1"><c r="A1" t="s"><v>0</v></c>'
            '<c r="C1" t="s"><v>1</v></c></row>'
            '<row r="3"><c r="A3" t="s"><v>2</v></c>'
            '<c r="B3"><v>9.81402211E9</v></c>'
            '<c r="C3"><v>1555.8000000000002</v></c></row>'
            '<row r="4"><c r="A4" t="inlineStr"><is><t>Sita</t></is></c>'
            '<c r="C4"><v>250</v></c></row>'
            '</sheetData></worksheet>',
      );
      final sheet = XlsxReader.read(bytes);
      expect(sheet.rows.length, 3);
      expect(sheet.rows[0].cells, ['Name', '', 'Balance']);
      expect(sheet.rows[1].number, 3);
      // Rich text runs are joined; a long number is not left in E notation.
      expect(sheet.rows[1].cells, ['Ramesh', '9814022110', '1555.80']);
      expect(sheet.rows[2].cells, ['Sita', '', '250']);
    });

    test('falls back to the first worksheet without a workbook part', () {
      final sheet = XlsxReader.read(
        _xlsx(
          withWorkbook: false,
          sheetXml:
              '<worksheet><sheetData><row r="1">'
              '<c r="A1" t="inlineStr"><is><t>x</t></is></c></row>'
              '</sheetData></worksheet>',
        ),
      );
      expect(sheet.rows.single.cells, ['x']);
    });

    test('a file that is not xlsx is refused', () {
      expect(
        () => XlsxReader.read(utf8.encode('Name,Amount')),
        throwsA(isA<SheetFormatException>()),
      );
    });
  });
}
