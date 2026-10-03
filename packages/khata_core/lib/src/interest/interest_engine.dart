import 'package:decimal/decimal.dart';
import 'package:khata_core/src/interest/interest_config.dart';
import 'package:khata_core/src/interest/interest_math.dart';
import 'package:khata_core/src/interest/interest_result.dart';
import 'package:khata_core/src/interest/ledger_event.dart';
import 'package:khata_core/src/ledger.dart';

/// The byaj (interest) engine. Specification: docs/domain/interest-engine.md
/// (including its "Implementation decisions" section).
///
/// Pure and deterministic. [asOf] is a business date: interest runs up to
/// but not including that day; events dated on or before it are applied.
InterestResult calculate({
  required List<LedgerEvent> events,
  required InterestConfig config,
  required LedgerDate asOf,
  List<RateChange> rateChanges = const [],
}) {
  for (final e in events) {
    if (e.amountPaise <= 0) {
      throw ArgumentError.value(e.amountPaise, 'amountPaise', 'must be > 0');
    }
  }
  final used =
      events.where((e) => !e.isPostedInterest && e.date <= asOf).toList()
        ..sort(_compareEvents);
  if (used.isEmpty) return InterestResult.empty;
  return _Run(used, config, asOf, rateChanges).run();
}

final _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

int _compareEvents(LedgerEvent a, LedgerEvent b) {
  final byDate = a.date.compareTo(b.date);
  if (byDate != 0) return byDate;
  final byCreated = (a.createdAt ?? _epoch).compareTo(b.createdAt ?? _epoch);
  return byCreated != 0 ? byCreated : a.id.compareTo(b.id);
}

/// A debit's still-unpaid amount and the first day it earns interest.
class _Tranche {
  _Tranche(this.amount, this.interestFrom);

  int amount;
  final LedgerDate interestFrom;
}

class _Run {
  _Run(this.events, this.config, this.asOf, List<RateChange> changes)
    : changes = _sortedChanges(changes);

  final List<LedgerEvent> events;
  final InterestConfig config;
  final LedgerDate asOf;
  final List<RateChange> changes;

  final List<InterestRow> rows = [];
  final List<_Tranche> tranches = [];
  Decimal accrued = Decimal.zero;
  Decimal partyInterest = Decimal.zero;
  int credit = 0;
  int interestRecovered = 0;
  int principalRecovered = 0;

  late final Decimal yearDays = Decimal.fromInt(config.dayBasis * 100);

  static List<RateChange> _sortedChanges(List<RateChange> input) {
    // Stable: for changes on one day the one listed last wins.
    final indexed = input.indexed.toList()
      ..sort((a, b) {
        final byDate = a.$2.effectiveDate.compareTo(b.$2.effectiveDate);
        return byDate != 0 ? byDate : a.$1.compareTo(b.$1);
      });
    return [for (final (_, c) in indexed) c];
  }

  int get principal => tranches.fold(0, (sum, t) => sum + t.amount);

  RateChange? _changeAt(LedgerDate day) {
    RateChange? found;
    for (final c in changes) {
      if (c.effectiveDate <= day) found = c;
    }
    return found;
  }

  Decimal rateAt(LedgerDate day) => _changeAt(day)?.ratePa ?? config.ratePa;

  InterestResult run() {
    final start = events.first.date;
    final eventDates = {for (final e in events) e.date};
    final changeDates = {
      for (final c in changes)
        if (c.effectiveDate > start && c.effectiveDate <= asOf) c.effectiveDate,
    };
    final compoundDates = _compoundingDates(start);
    final marks = {
      ...eventDates,
      ...changeDates,
      ...compoundDates,
      asOf,
    }.toList()..sort();

    var cursor = marks.first;
    _applyEvents(cursor);
    for (final mark in marks.skip(1)) {
      _accrue(cursor, mark, eventDates);
      if (compoundDates.contains(mark)) _compound(mark);
      if (changeDates.contains(mark)) _rateChangeRow(mark);
      _applyEvents(mark);
      cursor = mark;
    }

    final unit = config.rounding.unitPaise;
    return InterestResult(
      schedule: List.unmodifiable(rows),
      principalPaise: principal,
      accruedUnpaidPaise: roundHalfUp(_nonNegative(accrued), unit),
      interestRecoveredPaise: interestRecovered,
      principalRecoveredPaise: principalRecovered,
      creditBalancePaise: credit,
      interestPayableToPartyPaise: roundHalfUp(
        _nonNegative(partyInterest),
        unit,
      ),
    );
  }

  Decimal _nonNegative(Decimal v) => v < Decimal.zero ? Decimal.zero : v;

  /// Compounding steps between the first debit and [asOf] (inclusive).
  Set<LedgerDate> _compoundingDates(LedgerDate start) {
    if (!config.applicable || !config.compounds) return {};
    final firstDebit = events
        .where((e) => e.side == Side.udhaar)
        .map((e) => e.date)
        .firstOrNull;
    if (firstDebit == null) return {};
    final dates = <LedgerDate>{};
    if (config.compounding == CompoundingPeriod.onFyClose) {
      var year = firstDebit.month >= 4 ? firstDebit.year + 1 : firstDebit.year;
      for (
        var d = LedgerDate(year, 4, 1);
        d <= asOf;
        d = LedgerDate(++year, 4, 1)
      ) {
        dates.add(d);
      }
    } else {
      final step = config.compounding.months;
      for (var k = 1; ; k++) {
        final d = addMonths(firstDebit, k * step);
        if (d > asOf) break;
        dates.add(d);
      }
    }
    return dates;
  }

  /// Interest for the days [from, to), which lie inside one period between
  /// two events.
  void _accrue(LedgerDate from, LedgerDate to, Set<LedgerDate> eventDates) {
    if (!config.applicable) return;
    final days = from.daysUntil(to);
    final rate = rateAt(from);
    final blocked = _belowMinDays(from, eventDates);
    final total = principal;
    if (total > 0) {
      var interest = Decimal.zero;
      if (!blocked) {
        var weighted = BigInt.zero;
        for (final t in tranches) {
          final billableFrom = from > t.interestFrom ? from : t.interestFrom;
          if (billableFrom < to) {
            weighted +=
                BigInt.from(t.amount) * BigInt.from(billableFrom.daysUntil(to));
          }
        }
        interest = divide(Decimal.fromBigInt(weighted) * rate, yearDays);
      }
      accrued += interest;
      rows.add(
        InterestRow(
          kind: InterestRowKind.accrue,
          from: from,
          to: to,
          days: days,
          principalPaise: total,
          ratePa: rate,
          interest: interest,
        ),
      );
    } else if (credit > 0 && config.payOnJama) {
      final interest = blocked
          ? Decimal.zero
          : divide(
              Decimal.fromBigInt(BigInt.from(credit) * BigInt.from(days)) *
                  config.payRatePa,
              yearDays,
            );
      partyInterest += interest;
      rows.add(
        InterestRow(
          kind: InterestRowKind.accrue,
          from: from,
          to: to,
          days: days,
          principalPaise: 0,
          ratePa: config.payRatePa,
          interest: interest,
          inPartyFavour: true,
        ),
      );
    }
  }

  /// Spec rule 11. A period runs between two balance-changing events (the
  /// last one to [asOf]); rate changes and compounding dates do not shorten it.
  bool _belowMinDays(LedgerDate slabStart, Set<LedgerDate> eventDates) {
    if (config.minDays == 0) return false;
    var periodStart = slabStart;
    LedgerDate? periodEnd;
    for (final d in eventDates) {
      if (d <= slabStart && d > periodStart) periodStart = d;
      if (d > slabStart && (periodEnd == null || d < periodEnd)) periodEnd = d;
    }
    return periodStart.daysUntil(periodEnd ?? asOf) < config.minDays;
  }

  void _compound(LedgerDate on) {
    final capital = roundHalfUpPaise(_nonNegative(accrued));
    if (capital == 0 || principal == 0) return;
    tranches.add(_Tranche(capital, on));
    accrued -= Decimal.fromInt(capital);
    rows.add(
      InterestRow(
        kind: InterestRowKind.compound,
        from: on,
        to: on,
        principalPaise: principal,
        ratePa: rateAt(on),
        interest: Decimal.fromInt(capital),
        amountPaise: capital,
      ),
    );
  }

  void _rateChangeRow(LedgerDate on) {
    final change = _changeAt(on)!;
    rows.add(
      InterestRow(
        kind: InterestRowKind.rateChange,
        from: on,
        to: on,
        principalPaise: principal,
        ratePa: change.ratePa,
        note: change.reason,
      ),
    );
  }

  void _applyEvents(LedgerDate on) {
    for (final e in events.where((e) => e.date == on)) {
      if (e.side == Side.udhaar) {
        _debit(e);
      } else {
        _credit(e);
      }
    }
  }

  void _debit(LedgerEvent e) {
    final setOff = e.amountPaise < credit ? e.amountPaise : credit;
    credit -= setOff;
    final rest = e.amountPaise - setOff;
    if (rest > 0) {
      tranches.add(_Tranche(rest, e.date.addDays(config.graceDays)));
    }
    rows.add(
      InterestRow(
        kind: InterestRowKind.debit,
        from: e.date,
        to: e.date,
        principalPaise: principal,
        ratePa: rateAt(e.date),
        amountPaise: e.amountPaise,
        fromCreditBalancePaise: setOff,
        eventId: e.id,
        note: e.note,
      ),
    );
  }

  int _payInterest(int available) {
    final owed = roundHalfUpPaise(_nonNegative(accrued));
    final paid = available < owed ? available : owed;
    accrued -= Decimal.fromInt(paid);
    interestRecovered += paid;
    return paid;
  }

  int _payPrincipal(int available) {
    var left = available;
    for (final t in tranches) {
      if (left == 0) break;
      final take = left < t.amount ? left : t.amount;
      t.amount -= take;
      left -= take;
    }
    tranches.removeWhere((t) => t.amount == 0);
    final paid = available - left;
    principalRecovered += paid;
    return paid;
  }

  void _credit(LedgerEvent e) {
    var left = e.amountPaise;
    int payInterest;
    int payPrincipal;
    if (config.appropriation == Appropriation.interestFirst) {
      payInterest = _payInterest(left);
      payPrincipal = _payPrincipal(left - payInterest);
    } else {
      payPrincipal = _payPrincipal(left);
      payInterest = _payInterest(left - payPrincipal);
    }
    left -= payInterest + payPrincipal;
    credit += left;
    rows.add(
      InterestRow(
        kind: InterestRowKind.credit,
        from: e.date,
        to: e.date,
        principalPaise: principal,
        ratePa: rateAt(e.date),
        amountPaise: e.amountPaise,
        payInterestPaise: payInterest,
        payPrincipalPaise: payPrincipal,
        toCreditBalancePaise: left,
        eventId: e.id,
        note: e.note,
      ),
    );
  }
}
