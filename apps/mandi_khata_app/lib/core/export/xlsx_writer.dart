// XML is built from adjacent fragments; a space between them would be
// written into the file.
// ignore_for_file: missing_whitespace_between_adjacent_strings
// ignore_for_file: no_adjacent_strings_in_list

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:khata_core/khata_core.dart';

/// Writes a [ReportTable] as an Excel (.xlsx) workbook with one sheet.
///
/// An .xlsx file is a zip of small XML parts, so this needs no spreadsheet
/// package (`excel` cannot resolve next to `pdf`, see docs/decisions.md).
/// Money goes in as a number with two decimals taken straight from whole
/// paise (never through a `double`), a weight as quintals, a date as a real
/// Excel date; text is stored inline.
abstract final class XlsxWriter {
  static const _headerStyle = 1;
  static const _moneyStyle = 2;
  static const _dateStyle = 3;
  static const _qtyStyle = 4;
  static const _boldMoneyStyle = 5;
  static const _boldStyle = 6;
  static const _boldQtyStyle = 7;

  static Uint8List build(ReportTable table, {String sheetName = 'Report'}) {
    final archive = Archive();
    void add(String path, String xml) =>
        archive.addFile(ArchiveFile.bytes(path, utf8.encode(xml)));

    add('[Content_Types].xml', _contentTypes);
    add('_rels/.rels', _rootRels);
    add('xl/workbook.xml', _workbook(sheetName));
    add('xl/_rels/workbook.xml.rels', _workbookRels);
    add('xl/styles.xml', _styles);
    add('xl/worksheets/sheet1.xml', _sheet(table));
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  static const _xmlHead =
      '<?xml version="1.0" encoding="UTF-8" '
      'standalone="yes"?>\n';

  static const _contentTypes =
      '$_xmlHead'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/'
      'content-types">'
      '<Default Extension="rels" ContentType="application/vnd.'
      'openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.'
      'openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
      '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="'
      'application/vnd.openxmlformats-officedocument.spreadsheetml.'
      'worksheet+xml"/>'
      '<Override PartName="/xl/styles.xml" ContentType="application/vnd.'
      'openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
      '</Types>';

  static const _rootRels =
      '$_xmlHead'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/'
      'relationships"><Relationship Id="rId1" Type="http://schemas.'
      'openxmlformats.org/officeDocument/2006/relationships/officeDocument" '
      'Target="xl/workbook.xml"/></Relationships>';

  static String _workbook(String name) =>
      '$_xmlHead'
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/'
      'main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/'
      'relationships"><sheets><sheet name="${_escape(_sheetName(name))}" '
      'sheetId="1" r:id="rId1"/></sheets></workbook>';

  static const _workbookRels =
      '$_xmlHead'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/'
      'relationships"><Relationship Id="rId1" Type="http://schemas.'
      'openxmlformats.org/officeDocument/2006/relationships/worksheet" '
      'Target="worksheets/sheet1.xml"/><Relationship Id="rId2" Type="http://'
      'schemas.openxmlformats.org/officeDocument/2006/relationships/styles" '
      'Target="styles.xml"/></Relationships>';

  // Style ids: 0 plain, 1 header, 2 money, 3 date, 4 quantity, 5 bold money,
  // 6 bold, 7 bold quantity.
  static const _styles =
      '$_xmlHead'
      '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/'
      '2006/main">'
      '<numFmts count="2"><numFmt numFmtId="164" formatCode="#,##0.00"/>'
      r'<numFmt numFmtId="165" formatCode="dd\-mmm\-yyyy"/></numFmts>'
      '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
      '<font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
      '<fills count="3"><fill><patternFill patternType="none"/></fill>'
      '<fill><patternFill patternType="gray125"/></fill>'
      '<fill><patternFill patternType="solid"><fgColor rgb="FFE5E7EB"/>'
      '</patternFill></fill></fills>'
      '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/>'
      '</border></borders>'
      '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" '
      'borderId="0"/></cellStyleXfs>'
      '<cellXfs count="8">'
      '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
      '<xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" '
      'applyFont="1" applyFill="1"/>'
      '<xf numFmtId="164" fontId="0" fillId="0" borderId="0" xfId="0" '
      'applyNumberFormat="1"/>'
      '<xf numFmtId="165" fontId="0" fillId="0" borderId="0" xfId="0" '
      'applyNumberFormat="1"/>'
      '<xf numFmtId="2" fontId="0" fillId="0" borderId="0" xfId="0" '
      'applyNumberFormat="1"/>'
      '<xf numFmtId="164" fontId="1" fillId="0" borderId="0" xfId="0" '
      'applyNumberFormat="1" applyFont="1"/>'
      '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" '
      'applyFont="1"/>'
      '<xf numFmtId="2" fontId="1" fillId="0" borderId="0" xfId="0" '
      'applyNumberFormat="1" applyFont="1"/>'
      '</cellXfs></styleSheet>';

  /// Excel sheet names: at most 31 characters, none of `\ / ? * [ ] :`.
  static String _sheetName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/?*\[\]:]'), ' ').trim();
    final short = cleaned.length > 31 ? cleaned.substring(0, 31) : cleaned;
    return short.isEmpty ? 'Report' : short;
  }

  static String _sheet(ReportTable table) {
    final widths = [for (final c in table.columns) c.title.length.toDouble()];
    final out = StringBuffer(_xmlHead)
      ..write(
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/'
        '2006/main"><sheetViews><sheetView workbookViewId="0">'
        '<pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" '
        'state="frozen"/></sheetView></sheetViews>',
      );
    final body = StringBuffer('<sheetData>');

    void row(
      int number,
      List<Object?> cells, {
      bool header = false,
      bool bold = false,
    }) {
      body.write('<row r="$number">');
      for (var i = 0; i < cells.length && i < table.columns.length; i++) {
        final kind = table.columns[i].kind;
        final ref = '${_column(i)}$number';
        final cell = cells[i];
        final text = ReportTable.plain(kind, cell);
        if (text.length + 2 > widths[i]) widths[i] = text.length + 2.0;
        body.write(_cell(ref, kind, cell, text, header: header, bold: bold));
      }
      body.write('</row>');
    }

    row(1, [for (final c in table.columns) c.title], header: true);
    var r = 2;
    for (final cells in table.rows) {
      row(r++, cells);
    }
    final totals = table.totals;
    if (totals != null) row(r, totals, bold: true);
    body.write('</sheetData>');

    out
      ..write('<cols>')
      ..writeAll([
        for (var i = 0; i < widths.length; i++)
          '<col min="${i + 1}" max="${i + 1}" '
              'width="${widths[i].clamp(8, 48)}" customWidth="1"/>',
      ])
      ..write('</cols>')
      ..write(body)
      ..write('</worksheet>');
    return out.toString();
  }

  static String _cell(
    String ref,
    ReportColumnKind kind,
    Object? value,
    String text, {
    required bool header,
    required bool bold,
  }) {
    if (header) return _inline(ref, text, _headerStyle);
    if (value == null) {
      return bold ? '<c r="$ref" s="$_boldStyle"/>' : '';
    }
    switch (value) {
      case Money():
        return '<c r="$ref" s="${bold ? _boldMoneyStyle : _moneyStyle}">'
            '<v>$text</v></c>';
      case LedgerDate():
        return '<c r="$ref" s="$_dateStyle"><v>${_excelDate(value)}</v></c>';
      case int() when kind == ReportColumnKind.quantity:
        return '<c r="$ref" s="${bold ? _boldQtyStyle : _qtyStyle}">'
            '<v>$text</v></c>';
      case int():
        return '<c r="$ref"${bold ? ' s="$_boldStyle"' : ''}><v>$value</v></c>';
      default:
        return _inline(ref, text, bold ? _boldStyle : 0);
    }
  }

  static String _inline(String ref, String text, int style) =>
      '<c r="$ref" t="inlineStr"${style == 0 ? '' : ' s="$style"'}>'
      '<is><t xml:space="preserve">${_escape(text)}</t></is></c>';

  /// Days since 1899-12-30, Excel's day 0 for dates after February 1900.
  static int _excelDate(LedgerDate d) => DateTime.utc(
    d.year,
    d.month,
    d.day,
  ).difference(DateTime.utc(1899, 12, 30)).inDays;

  /// 0 → A, 25 → Z, 26 → AA.
  static String _column(int index) {
    var n = index + 1;
    var s = '';
    while (n > 0) {
      final rem = (n - 1) % 26;
      s = String.fromCharCode(65 + rem) + s;
      n = (n - 1) ~/ 26;
    }
    return s;
  }

  static String _escape(String s) => s
      .replaceAll(RegExp('[\u0000-\u0008\u000B\u000C\u000E-\u001F]'), '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
