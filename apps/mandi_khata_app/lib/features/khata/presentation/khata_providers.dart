import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/day_book.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'khata_providers.g.dart';

@Riverpod(keepAlive: true)
Future<LedgerRepository> ledgerRepository(Ref ref) async => LedgerRepository(
  await ref.watch(powerSyncDatabaseProvider.future),
  planDefaults: ref.watch(planDefaultsProvider),
);

/// A party's khata statement in the active business for [from]..[to]
/// (either open).
@riverpod
Stream<Statement> partyStatement(
  Ref ref,
  String partyId, {
  LedgerDate? from,
  LedgerDate? to,
}) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const Statement(
      opening: Money.zero,
      rows: [],
      totalUdhaar: Money.zero,
      totalJama: Money.zero,
    );
    return;
  }
  final repo = await ref.watch(ledgerRepositoryProvider.future);
  yield* repo.watchStatement(tenantId, partyId, from: from, to: to);
}

/// Every entry of one party's khata in the active business, oldest first.
/// Live. Feeds the interest engine.
@riverpod
Stream<List<LedgerEntry>> partyEntries(Ref ref, String partyId) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(ledgerRepositoryProvider.future);
  yield* repo.watchEntries(tenantId, partyId);
}

/// Balance of every party with entries in the active business.
@riverpod
Stream<Map<String, Money>> partyBalances(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const {};
    return;
  }
  final repo = await ref.watch(ledgerRepositoryProvider.future);
  yield* repo.watchBalances(tenantId);
}

/// Rows per day-book page; the list loads only the pages on screen.
const dayBookPageSize = 100;

/// Count and totals of the day book for [filter]. Live.
@riverpod
Stream<DayBookSummary> dayBookSummary(Ref ref, LedgerFilter filter) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield (count: 0, udhaar: Money.zero, jama: Money.zero);
    return;
  }
  final repo = await ref.watch(ledgerRepositoryProvider.future);
  yield* repo.watchDayBookSummary(tenantId, filter);
}

/// Page [page] (of [dayBookPageSize] rows) of the day book. Live; disposed
/// when scrolled away.
@riverpod
Stream<List<DayBookRow>> dayBookPage(
  Ref ref,
  LedgerFilter filter,
  int page,
) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(ledgerRepositoryProvider.future);
  yield* repo.watchDayBookPage(
    tenantId,
    filter,
    offset: page * dayBookPageSize,
    limit: dayBookPageSize,
  );
}

/// Posts, edits and reverses khata entries as the signed-in member of the
/// active business.
class KhataWriter {
  KhataWriter(this._ref);

  final Ref _ref;

  Future<LedgerPostResult> _run(
    Future<LedgerPostResult> Function(
      LedgerRepository repo,
      WriteContext ctx,
      bool Function(Permission) can,
    )
    action,
  ) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const LedgerNotPermitted(Permission.entriesReverse);
    }
    final repo = await _ref.read(ledgerRepositoryProvider.future);
    return await action(repo, ctx, member.can);
  }

  /// A manual khata entry (`journal`, needs `entries.reverse`).
  Future<LedgerPostResult> addManual({
    required String partyId,
    required Side side,
    required Money amount,
    required LedgerDate entryDate,
    String? narration,
  }) => _run(
    (repo, ctx, can) => repo.append(
      ctx,
      LedgerDraft(
        partyId: partyId,
        side: side,
        amount: amount,
        refType: RefType.journal,
        entryDate: entryDate,
        narration: narration,
      ),
      can: can,
    ),
  );

  /// Edit = reversal + replacement in one transaction.
  Future<LedgerPostResult> correct(
    String id, {
    required Side side,
    required Money amount,
    required LedgerDate entryDate,
    required String narration,
  }) => _run(
    (repo, ctx, can) => repo.correct(
      ctx,
      id,
      can: can,
      side: side,
      amount: amount,
      entryDate: entryDate,
      narration: narration,
    ),
  );

  Future<LedgerPostResult> reverse(String id) =>
      _run((repo, ctx, can) => repo.reverse(ctx, id, can: can));
}

@Riverpod(keepAlive: true)
KhataWriter khataWriter(Ref ref) => KhataWriter(ref);

extension KhataLabels on AppLocalizations {
  String refTypeName(RefType t) => switch (t) {
    RefType.arrival => khataRefArrival,
    RefType.payment => khataRefPayment,
    RefType.receipt => khataRefReceipt,
    RefType.shopSale => khataRefShopSale,
    RefType.shopReturn => khataRefShopReturn,
    RefType.purchase => khataRefPurchase,
    RefType.loanDisbursal => khataRefLoanDisbursal,
    RefType.loanRepayment => khataRefLoanRepayment,
    RefType.interest => khataRefInterest,
    RefType.expense => khataRefExpense,
    RefType.journal => khataRefJournal,
    RefType.openingBalance => khataRefOpeningBalance,
    RefType.reversal => khataRefReversal,
  };

  /// What a khata line says: its narration, else its type.
  String entryDescription(LedgerEntry e) {
    final type = refTypeName(e.refType);
    final n = e.narration;
    return n == null ? type : '$type · $n';
  }

  /// A message for a failed post, or null when it posted.
  String? ledgerPostError(LedgerPostResult r) => switch (r) {
    LedgerPosted() => null,
    LedgerNotPermitted(:final backdateDays?) => khataErrorBackdated(
      backdateDays,
    ),
    LedgerNotPermitted() => khataErrorNotPermitted,
    LedgerNotFound() => khataErrorNotFound,
    LedgerInvalid(:final problem) => switch (problem) {
      LedgerProblem.amountNotPositive => khataErrorAmount,
      LedgerProblem.nothingChanged => khataErrorNothingChanged,
      LedgerProblem.alreadyReversed => khataErrorAlreadyReversed,
      LedgerProblem.isReversal ||
      LedgerProblem.useReverse => khataErrorIsReversal,
    },
  };
}
