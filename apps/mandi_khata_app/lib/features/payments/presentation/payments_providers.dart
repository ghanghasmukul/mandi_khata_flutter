import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payments_providers.g.dart';

@Riverpod(keepAlive: true)
Future<PaymentsRepository> paymentsRepository(Ref ref) async =>
    PaymentsRepository(
      await ref.watch(powerSyncDatabaseProvider.future),
      planDefaults: ref.watch(planDefaultsProvider),
    );

@Riverpod(keepAlive: true)
Future<BankAccountsRepository> bankAccountsRepository(Ref ref) async =>
    BankAccountsRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Payments of the active business matching [filter], newest first. Live.
@riverpod
Stream<List<Payment>> paymentList(Ref ref, PaymentFilter filter) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(paymentsRepositoryProvider.future);
  yield* repo.watchAll(tenantId, filter);
}

/// One payment of the active business; null if missing.
@riverpod
Stream<Payment?> payment(Ref ref, String id) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield null;
    return;
  }
  final repo = await ref.watch(paymentsRepositoryProvider.future);
  yield* repo.watchOne(tenantId, id);
}

/// The number the next payment of [direction] on this device will get.
@riverpod
Future<String?> nextPaymentNo(Ref ref, PaymentDirection direction) async {
  final ctx = ref.watch(writeContextProvider);
  if (ctx == null) return null;
  final repo = await ref.watch(paymentsRepositoryProvider.future);
  return await repo.previewNextNo(ctx, direction);
}

/// Cash and bank accounts of the active business (a device without finance
/// access only has Cash). Live.
@riverpod
Stream<List<BankAccount>> bankAccountList(
  Ref ref, {
  bool includeInactive = false,
}) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(bankAccountsRepositoryProvider.future);
  yield* repo.watchAll(tenantId, includeInactive: includeInactive);
}

/// Book balance (money in − out) of every account. Live.
@riverpod
Stream<Map<String, Money>> accountBalances(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const {};
    return;
  }
  final repo = await ref.watch(bankAccountsRepositoryProvider.future);
  yield* repo.watchBalances(tenantId);
}

/// Records and reverses payments, and edits bank accounts, as the signed-in
/// member of the active business.
class PaymentWriter {
  PaymentWriter(this._ref);

  final Ref _ref;

  Future<PaymentSaveResult> _run(
    Future<PaymentSaveResult> Function(
      PaymentsRepository repo,
      WriteContext ctx,
      bool Function(Permission) can,
    )
    action,
  ) async {
    // Read everything before the first await.
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) {
      return const PaymentNotPermitted(Permission.paymentsCreate);
    }
    final repo = await _ref.read(paymentsRepositoryProvider.future);
    return await action(repo, ctx, member.can);
  }

  Future<PaymentSaveResult> save(PaymentDraft draft) =>
      _run((repo, ctx, can) => repo.save(ctx, draft, can: can));

  Future<PaymentSaveResult> reverse(String id) =>
      _run((repo, ctx, can) => repo.reverse(ctx, id, can: can));

  Future<PaymentSaveResult> setChequeStatus(
    String id,
    ChequeStatus to, {
    LedgerDate? bounceDate,
  }) => _run(
    (repo, ctx, can) =>
        repo.setChequeStatus(ctx, id, to, can: can, bounceDate: bounceDate),
  );

  Future<BankAccountResult> _account(
    Future<BankAccountResult> Function(
      BankAccountsRepository repo,
      WriteContext ctx,
      bool Function(Permission) can,
    )
    action,
  ) async {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) return const BankAccountNotPermitted();
    final repo = await _ref.read(bankAccountsRepositoryProvider.future);
    return await action(repo, ctx, member.can);
  }

  Future<BankAccountResult> createAccount(BankAccountInput input) =>
      _account((repo, ctx, can) => repo.create(ctx, input, can: can));

  Future<BankAccountResult> updateAccount(String id, BankAccountInput input) =>
      _account((repo, ctx, can) => repo.update(ctx, id, input, can: can));

  Future<BankAccountResult> setAccountActive(
    String id, {
    required bool active,
  }) => _account(
    (repo, ctx, can) => repo.setActive(ctx, id, active: active, can: can),
  );
}

@Riverpod(keepAlive: true)
PaymentWriter paymentWriter(Ref ref) => PaymentWriter(ref);

extension PaymentLabels on AppLocalizations {
  String paymentModeName(PaymentMode m) => switch (m) {
    PaymentMode.cash => paymentModeCash,
    PaymentMode.bank => paymentModeBank,
    PaymentMode.upi => paymentModeUpi,
    PaymentMode.cheque => paymentModeCheque,
  };

  String paymentDirectionName(PaymentDirection d) => switch (d) {
    PaymentDirection.toParty => paymentDirectionTo,
    PaymentDirection.fromParty => paymentDirectionFrom,
  };

  String chequeStatusName(ChequeStatus s) => switch (s) {
    ChequeStatus.pending => paymentChequePending,
    ChequeStatus.cleared => paymentChequeCleared,
    ChequeStatus.bounced => paymentChequeBounced,
  };

  /// The title of a payment's document: a voucher when we paid, a receipt
  /// when we received.
  String paymentDocumentTitle(PaymentDirection d) =>
      d == PaymentDirection.toParty ? paymentVoucherTitle : paymentReceiptTitle;

  String paymentProblem(PaymentProblem p) => switch (p) {
    PaymentProblem.amountNotPositive => paymentErrorAmount,
    PaymentProblem.bankAccountMissing => paymentErrorBank,
    PaymentProblem.chequeNoMissing => paymentErrorChequeNo,
    PaymentProblem.chequeDateMissing => paymentErrorChequeDate,
    PaymentProblem.chequeDetailsNotAllowed => paymentErrorChequeDetails,
  };

  /// A message for a failed save, or null when it saved.
  String? paymentSaveError(PaymentSaveResult r) => switch (r) {
    PaymentSaved() => null,
    PaymentNotPermitted(lockedYear: true) => yearLockedError,
    PaymentNotPermitted(:final backdateDays?) => khataErrorBackdated(
      backdateDays,
    ),
    PaymentNotPermitted(:final limit?) => paymentErrorLimit(limit.format()),
    PaymentNotPermitted(permission: Permission.financeView) =>
      paymentErrorFinance,
    PaymentNotPermitted() => paymentErrorNotPermitted,
    PaymentNotFound() => paymentErrorNotFound,
    PaymentInvalid(:final problems) => [
      for (final p in problems) paymentProblem(p),
    ].join('\n'),
    PaymentLocked() => paymentErrorLocked,
  };

  /// A message for a failed bank account save, or null when it saved.
  String? bankAccountError(BankAccountResult r) => switch (r) {
    BankAccountSaved() => null,
    BankAccountNotPermitted() => accountErrorNotPermitted,
    BankAccountNotFound() => paymentErrorNotFound,
    BankAccountInvalid(:final problems) => [
      for (final p in problems)
        switch (p) {
          BankAccountProblem.nameMissing => accountErrorName,
          BankAccountProblem.last4Invalid => accountErrorLast4,
          BankAccountProblem.ifscInvalid => accountErrorIfsc,
        },
    ].join('\n'),
  };
}
