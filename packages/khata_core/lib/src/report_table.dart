import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/lot_rules.dart';
import 'package:khata_core/src/money.dart';
import 'package:meta/meta.dart';

/// Age band of an outstanding balance, by days since the party's last entry.
enum AgeingBucket {
  upTo30,
  upTo90,
  upTo180,
  over180;

  /// 0–30, 31–90, 91–180, 180+ days. A date in the future counts as today.
  static AgeingBucket forDays(int days) {
    if (days <= 30) return upTo30;
    if (days <= 90) return upTo90;
    if (days <= 180) return upTo180;
    return over180;
  }
}

abstract final class Ageing {
  /// Whole days from [lastEntry] to [asOf] (negative when it is later).
  static int daysSince(LedgerDate lastEntry, LedgerDate asOf) =>
      lastEntry.daysUntil(asOf);

  static AgeingBucket bucketOf(LedgerDate lastEntry, LedgerDate asOf) =>
      AgeingBucket.forDays(daysSince(lastEntry, asOf));
}

/// How a report cell is shown and exported.
/// [quantity] is a weight in thousandths of a quintal (`qtl_milli`).
enum ReportColumnKind { text, date, money, number, quantity }

@immutable
final class ReportColumn {
  const ReportColumn(this.title, this.kind);

  final String title;
  final ReportColumnKind kind;
}

/// A finished report: translated column titles, rows of cells and an
/// optional totals row, the same for the screen, PDF, CSV and Excel.
///
/// Cells are `String` (text), `LedgerDate` (date), `Money` (money), `int`
/// (number, or thousandths of a quintal for quantity) or `null` (empty).
@immutable
final class ReportTable {
  const ReportTable({required this.columns, required this.rows, this.totals});

  final List<ReportColumn> columns;
  final List<List<Object?>> rows;
  final List<Object?>? totals;

  /// Plain text of one cell for CSV: money as rupees with paise, a date as
  /// `yyyy-mm-dd`, a weight as quintals, no symbols or digit grouping.
  static String plain(ReportColumnKind kind, Object? cell) => switch (cell) {
    null => '',
    final Money m => m.plainRupees,
    final LedgerDate d => d.toString(),
    final int milli when kind == ReportColumnKind.quantity => Quintals.format(
      milli,
    ),
    final Object o => o.toString(),
  };

  /// [plain] for column [index].
  String cellText(int index, Object? cell) => plain(columns[index].kind, cell);

  /// RFC 4180 CSV (CRLF line ends), with a header row and the totals row.
  String toCsv() {
    String quote(String s) =>
        s.contains(RegExp('[",\r\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
    final out = StringBuffer();
    void line(Iterable<String> cells) => out
      ..writeAll(cells.map(quote), ',')
      ..write('\r\n');
    line(columns.map((c) => c.title));
    Iterable<String> texts(List<Object?> row) => [
      for (var i = 0; i < row.length; i++) cellText(i, row[i]),
    ];
    for (final row in rows) {
      line(texts(row));
    }
    final t = totals;
    if (t != null) line(texts(t));
    return out.toString();
  }
}

extension MoneyPlain on Money {
  /// `1555.80` / `-0.05`: for files read by other programs.
  String get plainRupees {
    final abs = paise.abs();
    final text = '${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
    return paise < 0 ? '-$text' : text;
  }
}
