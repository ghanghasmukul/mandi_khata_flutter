import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/loans/data/loans_repository.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loans_providers.g.dart';

@Riverpod(keepAlive: true)
Future<LoansRepository> loansRepository(Ref ref) async => LoansRepository(
  await ref.watch(powerSyncDatabaseProvider.future),
  await ref.watch(paymentsRepositoryProvider.future),
  planDefaults: ref.watch(planDefaultsProvider),
);

/// Loans of the active business matching [filter], with their figures as of
/// today. Live.
@riverpod
Stream<List<LoanSummary>> loanList(Ref ref, LoanFilter filter) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(loansRepositoryProvider.future);
  yield* repo.watchAll(tenantId, filter);
}

/// One loan of the active business with its entries and rate changes; null
/// if missing. Live.
@riverpod
Stream<LoanDetail?> loanDetail(Ref ref, String id) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(loansRepositoryProvider.future);
  yield* repo.watchOne(tenantId, id);
}

/// The number the next loan on this device will get.
@riverpod
Future<String?> nextLoanNo(Ref ref) async {
  final ctx = ref.watch(writeContextProvider);
  if (ctx == null) return null;
  final repo = await ref.watch(loansRepositoryProvider.future);
  return await repo.previewNextNo(ctx);
}

/// Issues loans, records repayments and changes loans as the signed-in
/// member of the active business.
class LoanWriter {
  LoanWriter(this._ref);

  final Ref _ref;

  Future<LoanResult> _run(
    Future<LoanResult> Function(
      LoansRepository repo,
      WriteContext ctx,
      bool Function(Permission) can,
    )
    action,
  ) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const LoanNotPermitted(Permission.loansManage);
    }
    final repo = await _ref.read(loansRepositoryProvider.future);
    return await action(repo, ctx, member.can);
  }

  Future<LoanResult> issue(LoanDraft draft) =>
      _run((repo, ctx, can) => repo.issue(ctx, draft, can: can));

  Future<LoanResult> repay(LoanRepaymentDraft draft) =>
      _run((repo, ctx, can) => repo.repay(ctx, draft, can: can));

  Future<LoanResult> changeRate(
    String loanId, {
    required String ratePa,
    required LedgerDate effectiveDate,
    String? reason,
  }) => _run(
    (repo, ctx, can) => repo.changeRate(
      ctx,
      loanId,
      ratePa: ratePa,
      effectiveDate: effectiveDate,
      reason: reason,
      can: can,
    ),
  );

  Future<LoanResult> close(
    String loanId, {
    required LedgerDate closedOn,
    String? reason,
  }) => _run(
    (repo, ctx, can) =>
        repo.close(ctx, loanId, closedOn: closedOn, reason: reason, can: can),
  );

  Future<LoanResult> writeOff(
    String loanId, {
    required LedgerDate closedOn,
    required String reason,
  }) => _run(
    (repo, ctx, can) => repo.writeOff(
      ctx,
      loanId,
      closedOn: closedOn,
      reason: reason,
      can: can,
    ),
  );
}

@Riverpod(keepAlive: true)
LoanWriter loanWriter(Ref ref) => LoanWriter(ref);

extension LoanLabels on AppLocalizations {
  String loanHealthName(LoanHealth h) => switch (h) {
    LoanHealth.onTrack => loanHealthOnTrack,
    LoanHealth.dueSoon => loanHealthDueSoon,
    LoanHealth.overdue => loanHealthOverdue,
    LoanHealth.settled => loanHealthSettled,
    LoanHealth.closed => loanStatusClosed,
    LoanHealth.writtenOff => loanStatusWrittenOff,
  };

  String loanStatusName(LoanStatus s) => switch (s) {
    LoanStatus.active => loansFilterOpen,
    LoanStatus.closed => loanStatusClosed,
    LoanStatus.writtenOff => loanStatusWrittenOff,
  };

  /// "12 days left", "Due today", "3 days overdue" or "No due date".
  String loanDueText(LoanPosition p) {
    final left = p.daysLeft;
    if (left == null) return loanCardNoDue;
    if (left < 0) return loanCardOverdue('${-left}');
    if (left == 0) return loanCardDueToday;
    return loanCardDaysLeft('$left');
  }

  String loanProblem(LoanProblem p) => switch (p) {
    LoanProblem.amountNotPositive => loanErrorAmount,
    LoanProblem.dueBeforeIssue => loanErrorDue,
    LoanProblem.guarantorIsBorrower => loanErrorGuarantor,
    LoanProblem.rateInvalid => loanErrorRate,
    LoanProblem.effectiveBeforeIssue => loanErrorEffective,
    LoanProblem.notActive => loanErrorNotActive,
    LoanProblem.amountStillDue => loanErrorStillDue,
    LoanProblem.nothingToWriteOff => loanErrorNothingToWriteOff,
    LoanProblem.reasonMissing => loanErrorReason,
    LoanProblem.closedBeforeLastEntry => loanErrorClosedBefore,
  };

  /// A message for a failed action, or null when it worked.
  String? loanSaveError(LoanResult r) => switch (r) {
    LoanSaved() => null,
    LoanNotPermitted(:final backdateDays?) => khataErrorBackdated(backdateDays),
    LoanNotPermitted(:final limit?) => paymentErrorLimit(limit.format()),
    LoanNotPermitted(permission: Permission.financeView) => paymentErrorFinance,
    LoanNotPermitted(permission: Permission.loansManage) =>
      loanErrorNotPermitted,
    LoanNotPermitted() => loanErrorNotPermittedRepay,
    LoanInvalid(:final problems, :final paymentProblems) => [
      for (final p in problems) loanProblem(p),
      for (final p in paymentProblems) paymentProblem(p),
    ].join('\n'),
    LoanNotFound() => loanErrorNotFound,
    LoanNotActive() => loanErrorNotActive,
    LoanExceedsPayable(:final payable) => loanErrorExceeds(payable.format()),
    LoanExceedsCrop(:final available) => loanErrorExceedsCrop(
      available.format(),
    ),
  };
}
