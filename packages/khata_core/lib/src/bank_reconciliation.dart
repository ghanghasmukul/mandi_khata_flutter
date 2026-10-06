import 'package:khata_core/src/cash_book.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/sheet_reader.dart';
import 'package:meta/meta.dart';

/// One line of a bank statement (`bank_statement_lines`).
@immutable
final class StatementLine {
  const StatementLine({
    required this.id,
    required this.date,
    required this.isIn,
    required this.amount,
    this.reference,
    this.description,
    this.balance,
  });

  final String id;
  final LedgerDate date;

  /// Credit in the bank's statement = money into the account.
  final bool isIn;
  final Money amount;
  final String? reference;
  final String? description;
  final Money? balance;
}

/// How the dates of a statement are written.
enum StatementDateFormat {
  /// 31/03/2027, 31-03-2027, 31.03.2027
  dmy('dd/mm/yyyy'),

  /// 31/03/27
  dmyShort('dd/mm/yy'),

  /// 2027-03-31
  ymd('yyyy-mm-dd'),

  /// 31-Mar-2027, 31 Mar 2027
  dMonY('dd-Mon-yyyy'),

  /// 03/31/2027
  mdy('mm/dd/yyyy');

  const StatementDateFormat(this.label);

  final String label;
}

/// Which column of the statement holds what (0-based; null = not there),
/// saved per bank account so the next import needs no questions.
@immutable
final class StatementMapping {
  const StatementMapping({
    required this.date,
    required this.dateFormat,
    this.description,
    this.reference,
    this.debit,
    this.credit,
    this.amount,
    this.balance,
    this.headerRows = 1,
  });

  /// Reads what [toJson] wrote; null when it is not a mapping.
  static StatementMapping? fromJson(Object? json) {
    if (json is! Map) return null;
    int? col(String k) => json[k] is int ? json[k] as int : null;
    final date = col('date');
    final format = StatementDateFormat.values
        .where((f) => f.name == json['date_format'])
        .firstOrNull;
    if (date == null || format == null) return null;
    final m = StatementMapping(
      date: date,
      dateFormat: format,
      description: col('description'),
      reference: col('reference'),
      debit: col('debit'),
      credit: col('credit'),
      amount: col('amount'),
      balance: col('balance'),
      headerRows: col('header_rows') ?? 1,
    );
    return m.isValid ? m : null;
  }

  final int date;
  final StatementDateFormat dateFormat;
  final int? description;
  final int? reference;

  /// Withdrawal column (money out).
  final int? debit;

  /// Deposit column (money in).
  final int? credit;

  /// One signed amount column instead (negative or "Dr" = money out).
  final int? amount;
  final int? balance;

  /// Rows at the top to skip (titles, column names).
  final int headerRows;

  /// A date and either debit + credit columns or one amount column.
  bool get isValid =>
      date >= 0 &&
      headerRows >= 0 &&
      ((debit != null && credit != null) || amount != null);

  Map<String, Object?> toJson() => {
    'date': date,
    'date_format': dateFormat.name,
    'description': ?description,
    'reference': ?reference,
    'debit': ?debit,
    'credit': ?credit,
    'amount': ?amount,
    'balance': ?balance,
    'header_rows': headerRows,
  };
}

/// Why a statement row could not be read.
enum StatementRowProblem { badDate, badAmount, noAmount }

/// A statement row that could not be read.
@immutable
final class StatementRowError {
  const StatementRowError(this.rowNumber, this.problem);

  final int rowNumber;
  final StatementRowProblem problem;
}

/// A parsed statement row, before it gets an id.
@immutable
final class ParsedStatementRow {
  const ParsedStatementRow({
    required this.rowNumber,
    required this.date,
    required this.isIn,
    required this.amount,
    this.reference,
    this.description,
    this.balance,
  });

  final int rowNumber;
  final LedgerDate date;
  final bool isIn;
  final Money amount;
  final String? reference;
  final String? description;
  final Money? balance;

  /// Identifies the row for de-duplication across imports of the same file.
  String get fingerprint =>
      '$date|${isIn ? 'in' : 'out'}|${amount.paise}|'
      '${_norm(reference ?? '')}|${_norm(description ?? '')}|'
      '${balance?.paise ?? ''}';
}

/// Reading a bank statement with a [StatementMapping].
abstract final class StatementParser {
  static const _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  /// Parses [text] as a date in [format]; an Excel serial day number (as an
  /// .xlsx stores dates) is read too. Null when it is not a date.
  static LedgerDate? parseDate(String text, StatementDateFormat format) {
    final t = text.trim();
    if (t.isEmpty) return null;
    final serial = RegExp(r'^\d{5}(\.\d+)?$').firstMatch(t);
    if (serial != null) {
      final days = int.parse(t.split('.').first);
      return LedgerDate(1899, 12, 30).addDays(days);
    }
    final parts = t.split(RegExp(r'[\s/.\-]+'));
    if (parts.length < 3) return null;
    int? n(String s) => int.tryParse(s);
    int? year(String s) {
      final y = n(s);
      if (y == null) return null;
      return s.length == 2 ? 2000 + y : y;
    }

    final (int? y, int? m, int? d) = switch (format) {
      StatementDateFormat.dmy || StatementDateFormat.dmyShort => (
        year(parts[2]),
        n(parts[1]),
        n(parts[0]),
      ),
      StatementDateFormat.ymd => (year(parts[0]), n(parts[1]), n(parts[2])),
      StatementDateFormat.mdy => (year(parts[2]), n(parts[0]), n(parts[1])),
      StatementDateFormat.dMonY => (
        year(parts[2]),
        _months[parts[1].toLowerCase().substring(
          0,
          parts[1].length < 3 ? parts[1].length : 3,
        )],
        n(parts[0]),
      ),
    };
    if (y == null || m == null || d == null || y < 1900) return null;
    final check = DateTime.utc(y, m, d);
    if (check.year != y || check.month != m || check.day != d) return null;
    return LedgerDate(y, m, d);
  }

  /// A money cell: `1,23,456.78`, `₹ 500`, `500.00 Cr`, `(200)`, `-200`.
  /// Returns the amount and whether the cell says it is negative / Dr.
  static ({Money amount, bool negative})? parseAmount(String text) {
    var t = text.trim();
    if (t.isEmpty) return null;
    var negative = false;
    final lower = t.toLowerCase();
    if (lower.endsWith('dr')) {
      negative = true;
      t = t.substring(0, t.length - 2);
    } else if (lower.endsWith('cr')) {
      t = t.substring(0, t.length - 2);
    }
    t = t.replaceAll(RegExp(r'[₹,\s]|rs\.?|inr', caseSensitive: false), '');
    if (t.startsWith('(') && t.endsWith(')')) {
      negative = true;
      t = t.substring(1, t.length - 1);
    }
    if (t.startsWith('-')) {
      negative = !negative;
      t = t.substring(1);
    } else if (t.startsWith('+')) {
      t = t.substring(1);
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(t)) return null;
    final money = Money.tryParse(t);
    return money == null ? null : (amount: money, negative: negative);
  }

  /// Every row of [sheet] after the header rows: read, or why not. Rows with
  /// no amount at all (opening balance lines, totals) are reported as
  /// [StatementRowProblem.noAmount] so the person can see them skipped.
  static ({List<ParsedStatementRow> rows, List<StatementRowError> errors})
  parse(Sheet sheet, StatementMapping mapping) {
    final rows = <ParsedStatementRow>[];
    final errors = <StatementRowError>[];
    for (final r in sheet.rows.skip(mapping.headerRows)) {
      final date = parseDate(r.cell(mapping.date), mapping.dateFormat);
      if (date == null) {
        errors.add(StatementRowError(r.number, StatementRowProblem.badDate));
        continue;
      }
      Money? amount;
      bool? isIn;
      var bad = false;
      if (mapping.amount != null) {
        final a = parseAmount(r.cell(mapping.amount));
        if (a == null) {
          bad = r.cell(mapping.amount).isNotEmpty;
        } else if (a.amount.isPositive) {
          amount = a.amount;
          isIn = !a.negative;
        }
      } else {
        final out = parseAmount(r.cell(mapping.debit));
        final inn = parseAmount(r.cell(mapping.credit));
        bad =
            (out == null && r.cell(mapping.debit).isNotEmpty) ||
            (inn == null && r.cell(mapping.credit).isNotEmpty);
        if (!bad) {
          final outPositive = out != null && out.amount.isPositive;
          final inPositive = inn != null && inn.amount.isPositive;
          if (outPositive && inPositive) {
            bad = true;
          } else if (outPositive) {
            amount = out.amount;
            isIn = false;
          } else if (inPositive) {
            amount = inn.amount;
            isIn = true;
          }
        }
      }
      if (bad) {
        errors.add(StatementRowError(r.number, StatementRowProblem.badAmount));
        continue;
      }
      if (amount == null || isIn == null) {
        errors.add(StatementRowError(r.number, StatementRowProblem.noAmount));
        continue;
      }
      final balance = mapping.balance == null
          ? null
          : parseAmount(r.cell(mapping.balance));
      String? text(int? col) {
        final v = r.cell(col);
        return v.isEmpty ? null : v;
      }

      rows.add(
        ParsedStatementRow(
          rowNumber: r.number,
          date: date,
          isIn: isIn,
          amount: amount,
          reference: text(mapping.reference),
          description: text(mapping.description),
          balance: balance == null
              ? null
              : (balance.negative ? -balance.amount : balance.amount),
        ),
      );
    }
    return (rows: rows, errors: errors);
  }
}

/// A statement line paired with a book line.
@immutable
final class ReconMatch {
  const ReconMatch(
    this.statementLineId,
    this.bookLineId, {
    required this.byReference,
  });

  final String statementLineId;
  final String bookLineId;

  /// The reference (UTR / cheque no.) agreed, not just amount and date.
  final bool byReference;
}

/// Bank reconciliation rules (docs/domain/posting-rules.md, 11.3).
abstract final class BankReconciliation {
  /// Days a statement line may be from its book line.
  static const windowDays = 3;

  /// How a book line's references compare with a statement line: agree (a
  /// reference of the book line appears in the statement's reference or
  /// description), disagree (both have a reference and it does not), or
  /// unknown.
  static bool? referencesAgree(BookLine book, StatementLine statement) {
    final refs = _refs(book.reference);
    if (refs.isEmpty) return null;
    final ref = _norm(statement.reference ?? '');
    final haystack = '$ref ${_norm(statement.description ?? '')}';
    if (refs.any(haystack.contains)) return true;
    return ref.isEmpty ? null : false;
  }

  /// Whether [book] and [statement] may be matched by hand: same direction
  /// and amount.
  static bool canMatch(BookLine book, StatementLine statement) =>
      book.isIn == statement.isIn && book.amount == statement.amount;

  /// Pairs unmatched [statement] lines with unreconciled [book] lines:
  /// same direction and amount, dated within [windowDays], references not
  /// disagreeing; a reference match wins, then the closest date, then the
  /// oldest line. Each line is used once.
  static List<ReconMatch> autoMatch(
    List<StatementLine> statement,
    List<BookLine> book,
  ) {
    final candidates =
        <({StatementLine s, BookLine b, bool byRef, int days})>[];
    for (final s in statement) {
      for (final b in book) {
        if (!canMatch(b, s)) continue;
        final days = b.date.daysUntil(s.date).abs();
        if (days > windowDays) continue;
        final agree = referencesAgree(b, s);
        if (agree == false) continue;
        candidates.add((s: s, b: b, byRef: agree ?? false, days: days));
      }
    }
    candidates.sort((x, y) {
      if (x.byRef != y.byRef) return x.byRef ? -1 : 1;
      if (x.days != y.days) return x.days.compareTo(y.days);
      final byDate = x.b.date.compareTo(y.b.date);
      if (byDate != 0) return byDate;
      final byStatement = x.s.date.compareTo(y.s.date);
      if (byStatement != 0) return byStatement;
      final byBook = x.b.id.compareTo(y.b.id);
      return byBook != 0 ? byBook : x.s.id.compareTo(y.s.id);
    });
    final usedS = <String>{};
    final usedB = <String>{};
    final out = <ReconMatch>[];
    for (final c in candidates) {
      if (usedS.contains(c.s.id) || usedB.contains(c.b.id)) continue;
      usedS.add(c.s.id);
      usedB.add(c.b.id);
      out.add(ReconMatch(c.s.id, c.b.id, byReference: c.byRef));
    }
    return out;
  }

  static Set<String> _refs(String? text) => {
    for (final part in (text ?? '').split(RegExp(r'[\s,;/]+')))
      if (_norm(part).length >= 4) _norm(part),
  };
}

String _norm(String s) => s.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
