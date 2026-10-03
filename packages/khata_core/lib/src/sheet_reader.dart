import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

/// One non-empty row of an imported table.
@immutable
final class SheetRow {
  const SheetRow(this.number, this.cells);

  /// Row number as the person sees it in the file (1 = first line / row).
  final int number;
  final List<String> cells;

  String cell(int? index) => index == null || index < 0 || index >= cells.length
      ? ''
      : cells[index].trim();
}

/// A table read from pasted text, a CSV or an Excel file. Pure text: what
/// the cells mean is decided later (`OpeningBalanceImport`).
@immutable
final class Sheet {
  const Sheet(this.rows);

  /// Blank rows are dropped; [SheetRow.number] still counts them.
  final List<SheetRow> rows;

  bool get isEmpty => rows.isEmpty;
}

/// The file could not be read as a table.
final class SheetFormatException implements Exception {
  const SheetFormatException(this.message);

  final String message;

  @override
  String toString() => 'SheetFormatException: $message';
}

/// Reads CSV and tab-separated text (what Excel copies to the clipboard).
abstract final class DelimitedText {
  static const _delimiters = ['\t', ',', ';', '|'];

  /// Parses [text]. The delimiter is picked from the first non-blank line
  /// (tab, comma, semicolon or pipe — whichever appears most, tab first).
  /// Quoted cells may hold the delimiter, quotes (`""`) and line breaks. A
  /// leading byte-order mark is ignored.
  static Sheet parse(String text) {
    var input = text;
    if (input.startsWith('﻿')) input = input.substring(1);
    final delimiter = _detect(input);

    final rows = <SheetRow>[];
    var cells = <String>[];
    final cell = StringBuffer();
    var inQuotes = false;
    var line = 1;
    var rowStartLine = 1;
    var cellWasQuoted = false;

    void endCell() {
      cells.add(cell.toString());
      cell.clear();
      cellWasQuoted = false;
    }

    void endRow() {
      endCell();
      if (cells.any((c) => c.trim().isNotEmpty)) {
        rows.add(SheetRow(rowStartLine, cells));
      }
      cells = <String>[];
      rowStartLine = line;
    }

    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < input.length && input[i + 1] == '"') {
            cell.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          if (ch == '\n') line++;
          cell.write(ch);
        }
      } else if (ch == '"' && cell.isEmpty && !cellWasQuoted) {
        inQuotes = true;
        cellWasQuoted = true;
      } else if (ch == delimiter) {
        endCell();
      } else if (ch == '\n' || ch == '\r') {
        if (ch == '\r' && i + 1 < input.length && input[i + 1] == '\n') i++;
        line++;
        endRow();
      } else {
        cell.write(ch);
      }
    }
    if (cell.isNotEmpty || cells.isNotEmpty) endRow();
    return Sheet(rows);
  }

  static String _detect(String input) {
    // Count each candidate on the first line that has any text, ignoring
    // what sits inside quotes.
    var inQuotes = false;
    final counts = {for (final d in _delimiters) d: 0};
    var seenText = false;
    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
        seenText = true;
      } else if (!inQuotes && (ch == '\n' || ch == '\r')) {
        if (seenText) break;
      } else if (!inQuotes && counts.containsKey(ch)) {
        counts[ch] = counts[ch]! + 1;
        seenText = true;
      } else if (ch.trim().isNotEmpty) {
        seenText = true;
      }
    }
    var best = ',';
    var bestCount = 0;
    for (final d in _delimiters) {
      if (counts[d]! > bestCount) {
        best = d;
        bestCount = counts[d]!;
      }
    }
    return best;
  }
}

/// Reads the first worksheet of an Excel `.xlsx` file. Only values are read
/// (no formulas are evaluated beyond the value Excel saved).
///
/// Numbers come back as plain text: whole numbers without a decimal point
/// (mobile numbers), others rounded to 2 decimals (Excel keeps `1555.8` as a
/// binary fraction, so exact paise cannot be told from noise below 0.005).
abstract final class XlsxReader {
  static Sheet read(List<int> bytes) {
    final Archive zip;
    try {
      zip = ZipDecoder().decodeBytes(bytes);
    } on Object {
      throw const SheetFormatException('Not a valid .xlsx file');
    }
    final sheetFile = _firstSheet(zip);
    if (sheetFile == null) {
      throw const SheetFormatException('The workbook has no worksheet');
    }
    final strings = _sharedStrings(zip);
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(utf8.decode(sheetFile.content));
    } on Object {
      throw const SheetFormatException('The worksheet could not be read');
    }

    final rows = <SheetRow>[];
    var rowNumber = 0;
    for (final row in doc.findAllElements('row')) {
      rowNumber = int.tryParse(row.getAttribute('r') ?? '') ?? rowNumber + 1;
      final cells = <int, String>{};
      var column = -1;
      for (final c in row.findElements('c')) {
        final ref = c.getAttribute('r');
        column = ref == null ? column + 1 : _columnIndex(ref);
        cells[column] = _cellText(c, strings);
      }
      if (cells.isEmpty) continue;
      final width = cells.keys.reduce((a, b) => a > b ? a : b) + 1;
      final values = [for (var i = 0; i < width; i++) cells[i] ?? ''];
      if (values.any((v) => v.trim().isNotEmpty)) {
        rows.add(SheetRow(rowNumber, values));
      }
    }
    return Sheet(rows);
  }

  static ArchiveFile? _file(Archive zip, String name) {
    for (final f in zip.files) {
      if (f.isFile && f.name == name) return f;
    }
    return null;
  }

  static ArchiveFile? _firstSheet(Archive zip) {
    try {
      final workbook = _file(zip, 'xl/workbook.xml');
      final rels = _file(zip, 'xl/_rels/workbook.xml.rels');
      if (workbook != null && rels != null) {
        final sheet = XmlDocument.parse(
          utf8.decode(workbook.content),
        ).findAllElements('sheet').firstOrNull;
        final id = sheet?.attributes
            .where((a) => a.name.local == 'id')
            .firstOrNull
            ?.value;
        if (id != null && id.isNotEmpty) {
          for (final rel in XmlDocument.parse(
            utf8.decode(rels.content),
          ).findAllElements('Relationship')) {
            if (rel.getAttribute('Id') == id) {
              var target = rel.getAttribute('Target') ?? '';
              target = target.startsWith('/')
                  ? target.substring(1)
                  : 'xl/$target';
              final found = _file(zip, target);
              if (found != null) return found;
            }
          }
        }
      }
    } on Object {
      // Fall through to the first worksheet by name.
    }
    final sheets =
        zip.files
            .where(
              (f) =>
                  f.isFile &&
                  f.name.startsWith('xl/worksheets/') &&
                  f.name.endsWith('.xml'),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return sheets.firstOrNull;
  }

  static List<String> _sharedStrings(Archive zip) {
    final file = _file(zip, 'xl/sharedStrings.xml');
    if (file == null) return const [];
    try {
      return [
        for (final si in XmlDocument.parse(
          utf8.decode(file.content),
        ).findAllElements('si'))
          // Plain <t> or rich text <r><t>…; phonetic runs (<rPh>) excluded.
          si.childElements
              .where((e) => e.name.local == 't' || e.name.local == 'r')
              .expand(
                (e) => e.name.local == 't'
                    ? [e]
                    : e.childElements.where((x) => x.name.local == 't'),
              )
              .map((t) => t.innerText)
              .join(),
      ];
    } on Object {
      return const [];
    }
  }

  /// `B7` -> 1, `AA1` -> 26.
  static int _columnIndex(String ref) {
    var n = 0;
    for (final unit in ref.toUpperCase().codeUnits) {
      if (unit < 65 || unit > 90) break;
      n = n * 26 + (unit - 64);
    }
    return n - 1;
  }

  static String _cellText(XmlElement c, List<String> strings) {
    final type = c.getAttribute('t');
    if (type == 'inlineStr') {
      return c.findAllElements('t').map((t) => t.innerText).join();
    }
    final v = c.findElements('v').firstOrNull?.innerText ?? '';
    switch (type) {
      case 's':
        final i = int.tryParse(v.trim());
        return i != null && i >= 0 && i < strings.length ? strings[i] : '';
      case 'str':
      case 'e':
        return v;
      case 'b':
        return v.trim() == '1' ? 'TRUE' : 'FALSE';
      default:
        return _number(v);
    }
  }

  static String _number(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '';
    final d = Decimal.tryParse(text) ?? _scientific(text);
    if (d == null) return text;
    if (d.isInteger) return d.toBigInt().toString();
    return d.round(scale: 2).toStringAsFixed(2);
  }

  /// `9.81402211E9` — Excel writes long numbers this way.
  static Decimal? _scientific(String text) {
    final m = RegExp(r'^(-?\d+(?:\.\d+)?)[eE]([+-]?\d+)$').firstMatch(text);
    if (m == null) return null;
    final base = Decimal.tryParse(m[1]!);
    final exp = int.tryParse(m[2]!);
    if (base == null || exp == null || exp.abs() > 30) return null;
    final shift = Decimal.fromBigInt(BigInt.from(10).pow(exp.abs()));
    return exp >= 0
        ? base * shift
        : (base / shift).toDecimal(scaleOnInfinitePrecision: 30);
  }
}
