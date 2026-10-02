import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/permissions.dart';
import 'package:meta/meta.dart';

/// A business date (`entry_date`): a calendar day in the business's own
/// time zone, with no time of day. Stored as `yyyy-mm-dd`.
@immutable
final class LedgerDate implements Comparable<LedgerDate> {
  /// Throws [ArgumentError] for a day that does not exist (30 February).
  LedgerDate(this.year, this.month, this.day) {
    if (!_isCalendarDate(year, month, day)) {
      throw ArgumentError('Not a calendar date: $year-$month-$day');
    }
  }

  /// The calendar day of [dateTime] as it reads locally (no zone shift).
  factory LedgerDate.fromDateTime(DateTime dateTime) =>
      LedgerDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `yyyy-mm-dd`. Throws [FormatException] otherwise.
  factory LedgerDate.parse(String text) {
    final m = _pattern.firstMatch(text);
    if (m == null) throw FormatException('Expected yyyy-mm-dd', text);
    final (year, month, day) = (
      int.parse(m[1]!),
      int.parse(m[2]!),
      int.parse(m[3]!),
    );
    if (!_isCalendarDate(year, month, day)) {
      throw FormatException('Not a calendar date', text);
    }
    return LedgerDate(year, month, day);
  }

  static bool _isCalendarDate(int year, int month, int day) {
    final check = DateTime.utc(year, month, day);
    return check.year == year && check.month == month && check.day == day;
  }

  static final _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  int get _key => year * 10000 + month * 100 + day;

  DateTime get _utc => DateTime.utc(year, month, day);

  /// The day [days] later (earlier when negative).
  LedgerDate addDays(int days) =>
      LedgerDate.fromDateTime(_utc.add(Duration(days: days)));

  /// Whole days from this date to [other] (negative if [other] is earlier).
  int daysUntil(LedgerDate other) => other._utc.difference(_utc).inDays;

  @override
  int compareTo(LedgerDate other) => _key.compareTo(other._key);

  bool operator <(LedgerDate other) => _key < other._key;
  bool operator <=(LedgerDate other) => _key <= other._key;
  bool operator >(LedgerDate other) => _key > other._key;
  bool operator >=(LedgerDate other) => _key >= other._key;

  @override
  bool operator ==(Object other) => other is LedgerDate && other._key == _key;

  @override
  int get hashCode => _key.hashCode;

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

/// Which side of the khata an entry is on.
enum Side {
  /// Debit: the party owes us more (or we owe them less).
  udhaar,

  /// Credit: we owe the party more (or they owe us less).
  jama;

  String get dbName => name;

  Side get opposite => this == udhaar ? jama : udhaar;

  static Side parse(String value) => values.firstWhere(
    (s) => s.dbName == value,
    orElse: () => throw FormatException('Unknown side', value),
  );
}

/// What created a ledger entry (`ledger_entries.ref_type`).
enum RefType {
  arrival('arrival'),
  payment('payment'),
  receipt('receipt'),
  shopSale('shop_sale'),
  shopReturn('shop_return'),
  purchase('purchase'),
  loanDisbursal('loan_disbursal'),
  loanRepayment('loan_repayment'),
  interest('interest'),
  expense('expense'),
  journal('journal'),
  openingBalance('opening_balance'),
  reversal('reversal');

  const RefType(this.dbName);

  final String dbName;

  static RefType parse(String value) => values.firstWhere(
    (r) => r.dbName == value,
    orElse: () => throw FormatException('Unknown ref type', value),
  );
}

/// One posted line in a party's khata. Never changed once posted: a
/// correction is a reversal plus a replacement (see [ReversalBuilder]).
@immutable
final class LedgerEntry {
  /// Throws [ArgumentError] if [amount] is not positive, or if a reversal
  /// does not say what it reverses (or a non-reversal says it does).
  LedgerEntry({
    required this.id,
    required this.partyId,
    required this.entryDate,
    required this.side,
    required this.amount,
    required this.refType,
    required this.createdAt,
    this.refId,
    this.narration,
    this.reversesId,
    this.replacesId,
  }) {
    if (!amount.isPositive) {
      throw ArgumentError.value(amount, 'amount', 'must be positive');
    }
    if ((refType == RefType.reversal) != (reversesId != null)) {
      throw ArgumentError(
        'A reversal (and only a reversal) must name the entry it reverses',
      );
    }
  }

  final String id;
  final String partyId;
  final LedgerDate entryDate;
  final Side side;

  /// Always positive; [side] says which way it counts.
  final Money amount;
  final RefType refType;

  /// The document that posted this entry (arrival, payment …), if any.
  final String? refId;
  final String? narration;

  /// For a reversal: the entry it cancels.
  final String? reversesId;

  /// For the new entry of a correction: the entry it replaces.
  final String? replacesId;

  /// When it was recorded on the device (UTC). Orders entries of one day.
  final DateTime createdAt;

  bool get isReversal => refType == RefType.reversal;

  /// Effect on the balance: jama positive, udhaar negative.
  Money get signed => side == Side.jama ? amount : -amount;
}

/// A correction: the reversal of the wrong entry and the entry that
/// replaces it. Both are posted in one transaction.
typedef Correction = ({LedgerEntry reversal, LedgerEntry replacement});

/// Builds reversals and corrections. The ledger is append-only, so these
/// are the only ways to undo or change a posted entry.
abstract final class ReversalBuilder {
  /// The entry that cancels [original]: opposite side, same amount and
  /// party. Dated like the original unless [entryDate] is given (e.g. the
  /// day a cheque bounced). A reversal cannot be reversed — post a new
  /// entry instead.
  static LedgerEntry reverse(
    LedgerEntry original, {
    required String id,
    required DateTime createdAt,
    LedgerDate? entryDate,
    String? narration,
  }) {
    if (original.isReversal) {
      throw ArgumentError('A reversal cannot be reversed');
    }
    return LedgerEntry(
      id: id,
      partyId: original.partyId,
      entryDate: entryDate ?? original.entryDate,
      side: original.side.opposite,
      amount: original.amount,
      refType: RefType.reversal,
      narration: narration,
      reversesId: original.id,
      createdAt: createdAt,
    );
  }

  /// Reverses [original] and posts a replacement with the given changes;
  /// everything else is copied. The reversal is dated like the original,
  /// so balances on past dates are corrected too.
  static Correction correct(
    LedgerEntry original, {
    required String reversalId,
    required String replacementId,
    required DateTime createdAt,
    Money? amount,
    Side? side,
    LedgerDate? entryDate,
    String? narration,
  }) {
    final reversal = reverse(original, id: reversalId, createdAt: createdAt);
    final replacement = LedgerEntry(
      id: replacementId,
      partyId: original.partyId,
      entryDate: entryDate ?? original.entryDate,
      side: side ?? original.side,
      amount: amount ?? original.amount,
      refType: original.refType,
      refId: original.refId,
      narration: narration ?? original.narration,
      replacesId: original.id,
      createdAt: createdAt,
    );
    return (reversal: reversal, replacement: replacement);
  }
}

/// One line of a khata statement with the balance after it.
@immutable
final class StatementRow {
  const StatementRow({
    required this.entry,
    required this.balance,
    this.reversedById,
  });

  final LedgerEntry entry;

  /// Running balance (baki) after this entry.
  final Money balance;

  /// The reversal that cancelled this entry, if any.
  final String? reversedById;

  /// Shown struck through: a reversed entry or the reversal itself.
  bool get isStruck => reversedById != null || entry.isReversal;
}

/// A khata statement for a period.
@immutable
final class Statement {
  const Statement({
    required this.opening,
    required this.rows,
    required this.totalUdhaar,
    required this.totalJama,
  });

  /// Balance brought forward from before the period.
  final Money opening;
  final List<StatementRow> rows;
  final Money totalUdhaar;
  final Money totalJama;

  Money get closing => rows.isEmpty ? opening : rows.last.balance;
}

/// Udhaar and jama totals of a group of entries.
typedef SideTotals = ({Money udhaar, Money jama});

/// Ledger maths over a party's entries. Balance = Σ jama − Σ udhaar:
/// positive means we owe the party (jama), negative means they owe us.
abstract final class LedgerCalculator {
  /// Statement order: entry date, then when recorded, then id, so every
  /// device shows the same order.
  static int compare(LedgerEntry a, LedgerEntry b) {
    final byDate = a.entryDate.compareTo(b.entryDate);
    if (byDate != 0) return byDate;
    final byTime = a.createdAt.compareTo(b.createdAt);
    if (byTime != 0) return byTime;
    return a.id.compareTo(b.id);
  }

  static List<LedgerEntry> sorted(Iterable<LedgerEntry> entries) =>
      entries.toList()..sort(compare);

  static Money balance(Iterable<LedgerEntry> entries) =>
      entries.fold(Money.zero, (sum, e) => sum + e.signed);

  /// Balance at the end of [date].
  static Money balanceAsOf(Iterable<LedgerEntry> entries, LedgerDate date) =>
      balance(entries.where((e) => e.entryDate <= date));

  /// Original entry id → id of the reversal that cancels it.
  static Map<String, String> reversalPairs(Iterable<LedgerEntry> entries) => {
    for (final e in entries) ?e.reversesId: e.id,
  };

  /// Entries dated [from]..[to] (inclusive, either open) with the running
  /// balance, starting from everything before [from].
  static Statement statement(
    Iterable<LedgerEntry> entries, {
    LedgerDate? from,
    LedgerDate? to,
  }) {
    final all = sorted(entries);
    final pairs = reversalPairs(all);
    var running = Money.zero;
    var udhaar = Money.zero;
    var jama = Money.zero;
    Money? opening;
    final rows = <StatementRow>[];
    for (final e in all) {
      if (from != null && e.entryDate < from) {
        running += e.signed;
        continue;
      }
      if (to != null && e.entryDate > to) break;
      opening ??= running;
      running += e.signed;
      if (e.side == Side.jama) {
        jama += e.amount;
      } else {
        udhaar += e.amount;
      }
      rows.add(
        StatementRow(entry: e, balance: running, reversedById: pairs[e.id]),
      );
    }
    return Statement(
      opening: opening ?? running,
      rows: rows,
      totalUdhaar: udhaar,
      totalJama: jama,
    );
  }

  /// Udhaar / jama per ref type. A reversal counts under the type of the
  /// entry it reverses (so an edited arrival nets out under "arrival");
  /// only a reversal whose original is not in [entries] stays "reversal".
  static Map<RefType, SideTotals> totalsByRefType(
    Iterable<LedgerEntry> entries,
  ) {
    final byId = {for (final e in entries) e.id: e};
    final totals = <RefType, SideTotals>{};
    for (final e in entries) {
      final type = e.isReversal
          ? byId[e.reversesId]?.refType ?? RefType.reversal
          : e.refType;
      final t = totals[type] ?? (udhaar: Money.zero, jama: Money.zero);
      totals[type] = e.side == Side.jama
          ? (udhaar: t.udhaar, jama: t.jama + e.amount)
          : (udhaar: t.udhaar + e.amount, jama: t.jama);
    }
    return totals;
  }
}

/// Who may post which kind of entry. Mirrors the SQL function
/// `private.ledger_post_permission` (ledger_entries insert policy).
abstract final class LedgerPosting {
  /// The permission needed to post an entry of [refType]; null means any
  /// active member. A reversal, a correction's replacement ([isCorrection]),
  /// a journal entry and an opening balance all change what is already on
  /// the books, so they need `entries.reverse`.
  static Permission? requiredPermission(
    RefType refType, {
    bool isCorrection = false,
  }) {
    if (isCorrection) return Permission.entriesReverse;
    return switch (refType) {
      RefType.reversal ||
      RefType.journal ||
      RefType.openingBalance => Permission.entriesReverse,
      RefType.arrival => Permission.arrivalsManage,
      RefType.payment ||
      RefType.receipt ||
      RefType.loanRepayment => Permission.paymentsCreate,
      RefType.loanDisbursal || RefType.interest => Permission.loansManage,
      RefType.shopSale ||
      RefType.shopReturn ||
      RefType.purchase ||
      RefType.expense => null,
    };
  }

  /// True when an entry dated [entryDate], recorded on [recordedOn] (the
  /// device's calendar day), is back-dated more than [backdateDays] days or
  /// dated in the future. Such an entry needs `entries.reverse`, whatever
  /// its type (setting `business.backdate_days`).
  static bool dateNeedsOverride({
    required LedgerDate entryDate,
    required LedgerDate recordedOn,
    required int backdateDays,
  }) => entryDate > recordedOn || entryDate < recordedOn.addDays(-backdateDays);

  /// Every permission needed to post an entry of [refType] dated
  /// [entryDate]: the type's own ([requiredPermission]) and, when the date
  /// is outside the back-date window, `entries.reverse`. Empty = any
  /// active member.
  static List<Permission> requiredPermissions(
    RefType refType, {
    required LedgerDate entryDate,
    required LedgerDate recordedOn,
    required int backdateDays,
    bool isCorrection = false,
  }) {
    final own = requiredPermission(refType, isCorrection: isCorrection);
    final dated = dateNeedsOverride(
      entryDate: entryDate,
      recordedOn: recordedOn,
      backdateDays: backdateDays,
    );
    return [
      ?own,
      if (dated && own != Permission.entriesReverse) Permission.entriesReverse,
    ];
  }
}
