import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/accounts/data/statements_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/year_close_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statements_providers.g.dart';

@Riverpod(keepAlive: true)
Future<StatementsRepository> statementsRepository(Ref ref) async =>
    StatementsRepository(await ref.watch(powerSyncDatabaseProvider.future));

@Riverpod(keepAlive: true)
Future<YearCloseRepository> yearCloseRepository(Ref ref) async =>
    YearCloseRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Recomputed whenever the journal changes (journalTickProvider).
@riverpod
Future<TrialBalance?> trialBalance(
  Ref ref, {
  required LedgerDate asOf,
  bool withAccounts = true,
}) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  ref.watch(journalTickProvider);
  final repo = await ref.watch(statementsRepositoryProvider.future);
  return await repo.trialBalance(
    tenantId,
    asOf: asOf,
    withAccounts: withAccounts,
  );
}

@riverpod
Future<ProfitAndLoss?> profitAndLoss(
  Ref ref, {
  required LedgerDate from,
  required LedgerDate to,
}) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  ref.watch(journalTickProvider);
  final repo = await ref.watch(statementsRepositoryProvider.future);
  return await repo.profitAndLoss(tenantId, from: from, to: to);
}

@riverpod
Future<BalanceSheet?> balanceSheet(Ref ref, {required LedgerDate asOf}) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  ref.watch(journalTickProvider);
  final repo = await ref.watch(statementsRepositoryProvider.future);
  return await repo.balanceSheet(tenantId, asOf: asOf);
}

@riverpod
Future<AccountLedger?> accountLedger(
  Ref ref,
  String accountId, {
  LedgerDate? from,
  LedgerDate? to,
}) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  ref.watch(journalTickProvider);
  final repo = await ref.watch(statementsRepositoryProvider.future);
  return await repo.ledger(tenantId, accountId, from: from, to: to);
}

@riverpod
Future<List<(ChartEntry, Money)>> groupSummary(
  Ref ref,
  String groupId, {
  required LedgerDate asOf,
}) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return const [];
  ref.watch(journalTickProvider);
  final repo = await ref.watch(statementsRepositoryProvider.future);
  return await repo.groupSummary(tenantId, groupId, asOf: asOf);
}

/// Financial years from the first entry to today, newest first. Live.
@riverpod
Stream<List<YearRow>> financialYears(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(yearCloseRepositoryProvider.future);
  yield* repo.watch(tenantId, LedgerDate.fromDateTime(DateTime.now()));
}

@riverpod
Future<YearClosePreview?> yearClosePreview(Ref ref, int startYear) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return null;
  ref.watch(journalTickProvider);
  final isOwner = ref.watch(activeMembershipProvider)?.role == MemberRole.owner;
  final repo = await ref.watch(yearCloseRepositoryProvider.future);
  return await repo.preview(
    tenantId,
    FinancialYear(startYear),
    isOwner: isOwner,
    today: LedgerDate.fromDateTime(DateTime.now()),
  );
}

/// Closes a financial year as the signed-in owner.
class YearCloseWriter {
  YearCloseWriter(this._ref);

  final Ref _ref;

  Future<YearCloseResult> close(FinancialYear fy) async {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const YearCloseRefused([YearCloseProblem.notOwner]);
    }
    final repo = await _ref.read(yearCloseRepositoryProvider.future);
    return await repo.close(
      ctx,
      fy,
      isOwner: member.role == MemberRole.owner,
      today: LedgerDate.fromDateTime(DateTime.now()),
    );
  }
}

@Riverpod(keepAlive: true)
YearCloseWriter yearCloseWriter(Ref ref) => YearCloseWriter(ref);
