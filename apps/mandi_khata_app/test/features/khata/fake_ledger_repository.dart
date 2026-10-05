import 'dart:async';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/day_book.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';

/// In-memory khata for screen tests. Statements and balances use khata_core;
/// writes are recorded in [appended] / [corrected] / [reversed] and, like the
/// real repository, change the entries the streams show.
class FakeLedgerRepository implements LedgerRepository {
  final entries = <LedgerEntry>[];
  final partyNames = <String, String>{};
  final appended = <LedgerDraft>[];
  final corrected = <({String id, Money? amount, Side? side})>[];
  final reversed = <String>[];

  /// Returned instead of posting, when set.
  LedgerPostResult? nextResult;

  final _changed = StreamController<void>.broadcast();
  int _seq = 0;

  @override
  Map<String, Object?> get planDefaults => const {};

  Stream<T> _live<T>(T Function() read) {
    StreamSubscription<void>? changes;
    late final StreamController<T> out;
    out = StreamController<T>(
      onListen: () {
        changes = _changed.stream.listen((_) => out.add(read()));
        out.add(read());
      },
      onCancel: () => changes?.cancel(),
    );
    return out.stream;
  }

  LedgerEntry add(
    String partyId,
    String date,
    Side side,
    int rupees, {
    RefType refType = RefType.journal,
    String? narration,
    String? id,
  }) {
    final e = LedgerEntry(
      id: id ?? 'e${++_seq}',
      partyId: partyId,
      entryDate: LedgerDate.parse(date),
      side: side,
      amount: Money.rupees(rupees),
      refType: refType,
      narration: narration,
      createdAt: DateTime.utc(2026, 4).add(Duration(minutes: _seq)),
    );
    entries.add(e);
    _changed.add(null);
    return e;
  }

  @override
  Stream<List<LedgerEntry>> watchEntries(String tenantId, String partyId) =>
      _live(
        () =>
            LedgerCalculator.sorted(entries.where((e) => e.partyId == partyId)),
      );

  @override
  Stream<Statement> watchStatement(
    String tenantId,
    String partyId, {
    LedgerDate? from,
    LedgerDate? to,
  }) => _live(
    () => LedgerCalculator.statement(
      entries.where((e) => e.partyId == partyId),
      from: from,
      to: to,
    ),
  );

  @override
  Stream<Map<String, Money>> watchBalances(String tenantId) => _live(() {
    final byParty = <String, List<LedgerEntry>>{};
    for (final e in entries) {
      (byParty[e.partyId] ??= []).add(e);
    }
    return {
      for (final MapEntry(:key, :value) in byParty.entries)
        key: LedgerCalculator.balance(value),
    };
  });

  List<LedgerEntry> _filtered(LedgerFilter f) => [
    for (final e in LedgerCalculator.sorted(entries).reversed)
      if ((f.from == null || e.entryDate >= f.from!) &&
          (f.to == null || e.entryDate <= f.to!) &&
          (f.partyId == null || e.partyId == f.partyId) &&
          (f.refType == null || e.refType == f.refType))
        e,
  ];

  @override
  Stream<DayBookSummary> watchDayBookSummary(
    String tenantId,
    LedgerFilter filter,
  ) => _live(() {
    final list = _filtered(filter);
    return (
      count: list.length,
      udhaar: list
          .where((e) => e.side == Side.udhaar)
          .fold(Money.zero, (s, e) => s + e.amount),
      jama: list
          .where((e) => e.side == Side.jama)
          .fold(Money.zero, (s, e) => s + e.amount),
    );
  });

  @override
  Stream<List<DayBookRow>> watchDayBookPage(
    String tenantId,
    LedgerFilter filter, {
    required int offset,
    required int limit,
  }) => _live(() {
    final pairs = LedgerCalculator.reversalPairs(entries);
    final page = _filtered(filter).skip(offset).take(limit);
    return [
      for (final e in page)
        DayBookRow(
          entry: e,
          partyName: partyNames[e.partyId] ?? e.partyId,
          partyCode: e.partyId,
          balance: LedgerCalculator.balance(
            LedgerCalculator.sorted(
              entries.where((x) => x.partyId == e.partyId),
            ).takeWhile((x) => x != e).followedBy([e]),
          ),
          reversedById: pairs[e.id],
        ),
    ];
  });

  @override
  Future<LedgerPostResult> append(
    WriteContext ctx,
    LedgerDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    appended.add(draft);
    if (nextResult != null) return nextResult!;
    final e = add(
      draft.partyId,
      (draft.entryDate ?? LedgerDate.fromDateTime(now ?? DateTime.now()))
          .toString(),
      draft.side,
      draft.amount.rupees,
      refType: draft.refType,
      narration: draft.narration,
    );
    return LedgerPosted([e]);
  }

  @override
  Future<LedgerPostResult> reverse(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    LedgerDate? entryDate,
    String? narration,
    DateTime? now,
  }) async {
    reversed.add(id);
    if (nextResult != null) return nextResult!;
    final original = entries.firstWhere((e) => e.id == id);
    final r = ReversalBuilder.reverse(
      original,
      id: 'r${++_seq}',
      createdAt: DateTime.utc(2026, 5).add(Duration(minutes: _seq)),
    );
    entries.add(r);
    _changed.add(null);
    return LedgerPosted([r]);
  }

  @override
  Future<LedgerPostResult> correct(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    Money? amount,
    Side? side,
    LedgerDate? entryDate,
    String? narration,
    DateTime? now,
  }) async {
    corrected.add((id: id, amount: amount, side: side));
    if (nextResult != null) return nextResult!;
    final original = entries.firstWhere((e) => e.id == id);
    final c = ReversalBuilder.correct(
      original,
      reversalId: 'r${++_seq}',
      replacementId: 'n${++_seq}',
      createdAt: DateTime.utc(2026, 5).add(Duration(minutes: _seq)),
      amount: amount,
      side: side,
      entryDate: entryDate,
      narration: narration,
    );
    entries
      ..add(c.reversal)
      ..add(c.replacement);
    _changed.add(null);
    return LedgerPosted([c.reversal, c.replacement]);
  }
}
