import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/accounts/data/books_invariants.dart';
import 'package:mandi_khata_app/features/accounts/data/cash_book_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/cash_count_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_backfill.dart';
import 'package:mandi_khata_app/features/accounts/data/reconciliation_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/voucher_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accounts_providers.g.dart';

@Riverpod(keepAlive: true)
Future<JournalBackfill> journalBackfill(Ref ref) async =>
    JournalBackfill(await ref.watch(powerSyncDatabaseProvider.future));

@Riverpod(keepAlive: true)
Future<BooksInvariants> booksInvariants(Ref ref) async =>
    BooksInvariants(await ref.watch(powerSyncDatabaseProvider.future));

@Riverpod(keepAlive: true)
Future<ChartRepository> chartRepository(Ref ref) async =>
    ChartRepository(await ref.watch(powerSyncDatabaseProvider.future));

@Riverpod(keepAlive: true)
Future<VoucherRepository> voucherRepository(Ref ref) async => VoucherRepository(
  await ref.watch(powerSyncDatabaseProvider.future),
  planDefaults: ref.watch(planDefaultsProvider),
);

@Riverpod(keepAlive: true)
Future<CashBookRepository> cashBookRepository(Ref ref) async =>
    CashBookRepository(await ref.watch(powerSyncDatabaseProvider.future));

@Riverpod(keepAlive: true)
Future<ReconciliationRepository> reconciliationRepository(Ref ref) async =>
    ReconciliationRepository(await ref.watch(powerSyncDatabaseProvider.future));

@Riverpod(keepAlive: true)
Future<CashCountRepository> cashCountRepository(Ref ref) async =>
    CashCountRepository(
      await ref.watch(powerSyncDatabaseProvider.future),
      await ref.watch(voucherRepositoryProvider.future),
    );

/// The cash / bank book of [accountId] for [from]..[to]. Live.
@riverpod
Stream<CashBook> cashBook(
  Ref ref,
  String accountId, {
  LedgerDate? from,
  LedgerDate? to,
}) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return;
  final repo = await ref.watch(cashBookRepositoryProvider.future);
  yield* repo.watch(tenantId, accountId, from: from, to: to);
}

/// What is left to reconcile on bank account [accountId]. Live.
@riverpod
Stream<ReconState> reconState(Ref ref, String accountId) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield ReconState.empty;
    return;
  }
  final repo = await ref.watch(reconciliationRepositoryProvider.future);
  yield* repo.watch(tenantId, accountId);
}

/// Bank book lines older than a week that nobody reconciled. Live.
@riverpod
Stream<int> staleBankLines(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield 0;
    return;
  }
  final repo = await ref.watch(reconciliationRepositoryProvider.future);
  yield* repo.watchStale(
    tenantId,
    today: LedgerDate.fromDateTime(DateTime.now()),
  );
}

/// Cash counts of the active business, newest first. Live.
@riverpod
Stream<List<CashCountRow>> cashCounts(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(cashCountRepositoryProvider.future);
  yield* repo.watch(tenantId);
}

/// Documents of the active business that have no journal entry yet.
@riverpod
Future<BackfillStatus?> booksStatus(Ref ref) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  final backfill = await ref.watch(journalBackfillProvider.future);
  return await backfill.status(tenantId);
}

/// How many entries and accounts the books checks flag (0 everywhere is
/// healthy).
class BooksChecks {
  const BooksChecks({
    required this.unbalanced,
    required this.partyDifferences,
    required this.bookDifferences,
  });

  final int unbalanced;
  final int partyDifferences;
  final int bookDifferences;

  bool get isHealthy =>
      unbalanced == 0 && partyDifferences == 0 && bookDifferences == 0;
}

/// The books checks again after every completed sync (and on start): the
/// journal that came down must still balance and match the khata and the
/// cash book (phase 3 exit criterion). Finance members only.
@riverpod
Future<BooksChecks?> booksAfterSync(Ref ref) async {
  final canFinance =
      ref.watch(activeMembershipProvider)?.can(Permission.financeView) ?? false;
  if (!canFinance) return null;
  // Re-run when a sync finishes.
  ref.listen(syncStatusProvider, (previous, next) {
    if (previous?.value?.lastSyncedAt != next.value?.lastSyncedAt) {
      ref.invalidate(booksChecksProvider);
    }
  });
  return await ref.watch(booksChecksProvider.future);
}

@riverpod
Future<BooksChecks?> booksChecks(Ref ref) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  final books = await ref.watch(booksInvariantsProvider.future);
  return BooksChecks(
    unbalanced: (await books.unbalancedEntries(tenantId)).length,
    partyDifferences: (await books.partyDifferences(tenantId)).length,
    bookDifferences: (await books.bookDifferences(tenantId)).length,
  );
}

/// The chart of accounts of the active business. Live.
@riverpod
Stream<Chart?> chart(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(chartRepositoryProvider.future);
  yield* repo.watch(tenantId);
}

/// Σ debit / Σ credit of every account up to [asOf] (all dates when null).
@riverpod
Future<Map<String, AccountTotals>> accountTotals(
  Ref ref, {
  LedgerDate? asOf,
}) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const {};
  final db = await ref.watch(powerSyncDatabaseProvider.future);
  // Recompute when the journal changes.
  ref.watch(journalTickProvider);
  return await db.readTransaction(
    (tx) => ChartRepository.totals(tx, tenantId, to: asOf),
  );
}

/// Ticks whenever a journal row is written (local or synced).
@riverpod
Stream<int> journalTick(Ref ref) async* {
  final db = await ref.watch(powerSyncDatabaseProvider.future);
  var n = 0;
  await for (final _ in db.watch(
    'SELECT 1',
    triggerOnTables: const {'journal_lines', 'journal_entries'},
  )) {
    yield n++;
  }
}

/// The accounts day book: journal entries in [from]..[to]. Live.
@riverpod
Stream<List<JournalDayRow>> journalDayBook(
  Ref ref, {
  required LedgerDate from,
  required LedgerDate to,
  VoucherType? voucherType,
  bool vouchersOnly = false,
}) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(voucherRepositoryProvider.future);
  yield* repo.watchDayBook(
    tenantId,
    from: from,
    to: to,
    voucherType: voucherType,
    vouchersOnly: vouchersOnly,
  );
}

/// The lines of one journal entry. Live.
@riverpod
Stream<List<JournalLineView>> journalLines(Ref ref, String entryId) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(voucherRepositoryProvider.future);
  yield* repo.watchLines(tenantId, entryId);
}

/// The number the next voucher of [type] on this device will get.
@riverpod
Future<String?> nextVoucherNo(Ref ref, VoucherType type) async {
  final ctx = ref.watch(writeContextProvider);
  if (ctx == null) return null;
  final repo = await ref.watch(voucherRepositoryProvider.future);
  return await repo.previewNextNo(ctx, type);
}

/// Posts and reverses vouchers and edits own accounts as the signed-in
/// member of the active business.
class AccountsWriter {
  AccountsWriter(this._ref);

  final Ref _ref;

  ({WriteContext ctx, bool Function(Permission) can})? _who() {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) return null;
    return (ctx: ctx, can: member.can);
  }

  Future<VoucherSaveResult> save(VoucherDraft draft) async {
    final who = _who();
    if (who == null) {
      return const VoucherNotPermitted(Permission.entriesReverse);
    }
    final repo = await _ref.read(voucherRepositoryProvider.future);
    return await repo.save(who.ctx, draft, can: who.can);
  }

  Future<VoucherSaveResult> reverse(String voucherId) async {
    final who = _who();
    if (who == null) {
      return const VoucherNotPermitted(Permission.entriesReverse);
    }
    final repo = await _ref.read(voucherRepositoryProvider.future);
    return await repo.reverse(who.ctx, voucherId, can: who.can);
  }

  Future<AccountProblem?> addAccount(String name, String groupId) async {
    final who = _who();
    if (who == null || !who.can(Permission.entriesReverse)) {
      return AccountProblem.notOwn;
    }
    final repo = await _ref.read(chartRepositoryProvider.future);
    return (await repo.addAccount(
      who.ctx,
      name: name,
      groupId: groupId,
    )).problem;
  }

  Future<AccountProblem?> updateAccount(
    String id, {
    String? name,
    String? groupId,
    bool? isActive,
  }) async {
    final who = _who();
    if (who == null || !who.can(Permission.entriesReverse)) {
      return AccountProblem.notOwn;
    }
    final repo = await _ref.read(chartRepositoryProvider.future);
    return await repo.updateAccount(
      who.ctx,
      id,
      name: name,
      groupId: groupId,
      isActive: isActive,
    );
  }
}

@Riverpod(keepAlive: true)
AccountsWriter accountsWriter(Ref ref) => AccountsWriter(ref);

/// Bank reconciliation and cash counts as the signed-in member.
class BankWriter {
  BankWriter(this._ref);

  final Ref _ref;

  ({WriteContext ctx, bool Function(Permission) can})? _who() {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) return null;
    return (ctx: ctx, can: member.can);
  }

  Future<ReconciliationRepository?> _recon() async {
    final who = _who();
    if (who == null || !who.can(Permission.financeView)) return null;
    return await _ref.read(reconciliationRepositoryProvider.future);
  }

  Future<StatementImportResult?> import(
    String accountId,
    Sheet sheet,
    StatementMapping mapping,
  ) async {
    final repo = await _recon();
    if (repo == null) return null;
    return await repo.import(_who()!.ctx, accountId, sheet, mapping);
  }

  Future<StatementMapping?> mapping(String accountId) async {
    final repo = await _recon();
    if (repo == null) return null;
    return await repo.mapping(_who()!.ctx.tenantId, accountId);
  }

  Future<int> autoMatch(String accountId) async {
    final repo = await _recon();
    if (repo == null) return 0;
    return await repo.autoMatch(_who()!.ctx, accountId);
  }

  Future<bool> match(
    String accountId,
    String bookId,
    String statementId,
  ) async {
    final repo = await _recon();
    if (repo == null) return false;
    return await repo.match(_who()!.ctx, accountId, bookId, statementId);
  }

  Future<bool> reconcileWithoutStatement(
    String accountId,
    List<String> bookIds,
    LedgerDate on,
  ) async {
    final repo = await _recon();
    if (repo == null) return false;
    return await repo.reconcileWithoutStatement(
      _who()!.ctx,
      accountId,
      bookIds,
      on,
    );
  }

  Future<void> undo(String reconciliationId) async {
    final repo = await _recon();
    if (repo == null) return;
    await repo.undo(_who()!.ctx, reconciliationId);
  }

  Future<CashCountResult> saveCount(
    LedgerDate on,
    CashCount count, {
    required bool postDifference,
    String? note,
  }) async {
    final who = _who();
    if (who == null) {
      return const CashCountNotPermitted(Permission.paymentsCreate);
    }
    final repo = await _ref.read(cashCountRepositoryProvider.future);
    return await repo.save(
      who.ctx,
      on,
      count,
      can: who.can,
      postDifference: postDifference,
      note: note,
    );
  }

  Future<Money?> cashBalance(LedgerDate on) async {
    final who = _who();
    if (who == null) return null;
    final repo = await _ref.read(cashCountRepositoryProvider.future);
    return await repo.bookBalance(who.ctx.tenantId, on);
  }
}

@Riverpod(keepAlive: true)
BankWriter bankWriter(Ref ref) => BankWriter(ref);
