import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:meta/meta.dart';

/// One cash / bank book line (`cash_bank_entries`): money in or out.
@immutable
final class BookLine {
  const BookLine({
    required this.id,
    required this.date,
    required this.isIn,
    required this.amount,
    this.reference,
    this.text,
    this.reversesId,
    this.createdAt,
  });

  final String id;
  final LedgerDate date;
  final bool isIn;
  final Money amount;

  /// UTR / UPI id / cheque number of the payment behind it, for matching.
  final String? reference;

  /// What the line is (receipt no., party, voucher no.).
  final String? text;

  /// Set on the mirror line of a reversal.
  final String? reversesId;

  /// Tie-break inside one day (ISO-8601).
  final String? createdAt;

  /// + in, − out.
  Money get signed => isIn ? amount : -amount;
}

/// One day of a cash / bank book.
@immutable
final class CashBookDay {
  const CashBookDay({
    required this.date,
    required this.opening,
    required this.lines,
  });

  final LedgerDate date;
  final Money opening;
  final List<BookLine> lines;

  Money get receipts =>
      lines.where((l) => l.isIn).fold(Money.zero, (s, l) => s + l.amount);

  Money get payments =>
      lines.where((l) => !l.isIn).fold(Money.zero, (s, l) => s + l.amount);

  Money get closing => opening + receipts - payments;
}

/// A cash / bank book for a period: opening, each day, closing.
@immutable
final class CashBook {
  const CashBook({required this.opening, required this.days});

  /// Builds the book of [lines] (any order, any dates) for [from]..[to]
  /// (either open): lines before [from] make the opening, lines after [to]
  /// are left out; days are oldest first and only days with lines appear.
  factory CashBook.build(
    Iterable<BookLine> lines, {
    LedgerDate? from,
    LedgerDate? to,
  }) {
    var opening = Money.zero;
    final inside = <BookLine>[];
    for (final l in lines) {
      if (from != null && l.date < from) {
        opening += l.signed;
      } else if (to == null || l.date <= to) {
        inside.add(l);
      }
    }
    inside.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      if (byDate != 0) return byDate;
      final byTime = (a.createdAt ?? '').compareTo(b.createdAt ?? '');
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    final days = <CashBookDay>[];
    var running = opening;
    var i = 0;
    while (i < inside.length) {
      final date = inside[i].date;
      final dayLines = <BookLine>[];
      while (i < inside.length && inside[i].date == date) {
        dayLines.add(inside[i++]);
      }
      final day = CashBookDay(date: date, opening: running, lines: dayLines);
      days.add(day);
      running = day.closing;
    }
    return CashBook(opening: opening, days: days);
  }

  /// Balance before the first day of the period.
  final Money opening;
  final List<CashBookDay> days;

  Money get receipts => days.fold(Money.zero, (s, d) => s + d.receipts);

  Money get payments => days.fold(Money.zero, (s, d) => s + d.payments);

  Money get closing => opening + receipts - payments;
}
