import 'dart:async';
import 'dart:typed_data';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/expenses/data/bill_storage.dart';
import 'package:mandi_khata_app/features/expenses/data/bill_uploader.dart';
import 'package:mandi_khata_app/features/expenses/data/expenses_repository.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses_providers.g.dart';

@Riverpod(keepAlive: true)
Future<ExpensesRepository> expensesRepository(Ref ref) async =>
    ExpensesRepository(
      await ref.watch(powerSyncDatabaseProvider.future),
      planDefaults: ref.watch(planDefaultsProvider),
    );

/// Sends a bill to Supabase Storage. A provider so tests replace it.
@Riverpod(keepAlive: true)
BillUploadFn billUploadFn(Ref ref) => BillStorage.upload;

@Riverpod(keepAlive: true)
Future<BillUploader> billUploader(Ref ref) async => BillUploader(
  await ref.watch(powerSyncDatabaseProvider.future),
  ref.watch(billUploadFnProvider),
);

/// Runs the bill uploads whenever sync is connected and a photo waits.
/// Watched for the app's lifetime (main.dart).
@Riverpod(keepAlive: true)
Future<void> billUploadRunner(Ref ref) async {
  if (!syncConfigured) return;
  final uploader = await ref.watch(billUploaderProvider.future);
  var pending = 0;
  var connected = false;
  Future<void> tryNow() async {
    if (connected && pending > 0) await uploader.uploadPending();
  }

  ref.listen(syncStatusProvider, (_, next) {
    connected = next.value?.connected ?? false;
    unawaited(tryNow());
  });
  final sub = uploader.watchPending().listen((n) {
    pending = n;
    unawaited(tryNow());
  });
  ref.onDispose(sub.cancel);
}

/// Bill photos of the active business waiting for upload on this device.
/// Live.
@riverpod
Stream<int> pendingBills(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  final uploader = await ref.watch(billUploaderProvider.future);
  yield* uploader.watchPending(tenantId: tenantId);
}

@riverpod
Stream<List<ExpenseCategory>> expenseCategories(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(expensesRepositoryProvider.future);
  yield* repo.watchCategories(tenantId);
}

@riverpod
Stream<List<Expense>> expenseList(
  Ref ref, {
  LedgerDate? from,
  LedgerDate? to,
}) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(expensesRepositoryProvider.future);
  yield* repo.watchExpenses(tenantId, from: from, to: to);
}

@riverpod
Stream<List<RecurringExpense>> recurringExpenses(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(expensesRepositoryProvider.future);
  yield* repo.watchRecurring(tenantId);
}

@riverpod
Stream<List<DueRecurring>> dueRecurring(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(expensesRepositoryProvider.future);
  yield* repo.watchDue(tenantId, LedgerDate.fromDateTime(DateTime.now()));
}

/// Expenses by category and month for [from]..[to].
@riverpod
Future<ExpensePivot> expensePivot(
  Ref ref, {
  LedgerDate? from,
  LedgerDate? to,
}) async {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) return ExpensePivot.of(const []);
  // Recompute when expenses change.
  ref.watch(expenseListProvider(from: from, to: to));
  final repo = await ref.watch(expensesRepositoryProvider.future);
  return ExpensePivot.of(await repo.facts(tenantId, from: from, to: to));
}

/// The photo at [path]: from this device if it still has it, else a short
/// signed link from Storage (online only); null when neither.
@riverpod
Future<({Uint8List? bytes, String? url})?> billImage(
  Ref ref,
  String path,
) async {
  final uploader = await ref.watch(billUploaderProvider.future);
  final local = await uploader.localBytes(path);
  if (local != null) return (bytes: local, url: null);
  if (!syncConfigured) return null;
  try {
    return (bytes: null, url: await BillStorage.signedUrl(path));
  } on Object {
    return null;
  }
}

/// Records, reverses and plans expenses as the signed-in member.
class ExpensesWriter {
  ExpensesWriter(this._ref);

  final Ref _ref;

  ({WriteContext ctx, bool Function(Permission) can})? _who() {
    final ctx = _ref.read(writeContextProvider);
    final member = _ref.read(activeMembershipProvider);
    if (ctx == null || member == null) return null;
    return (ctx: ctx, can: member.can);
  }

  Future<ExpenseResult> save(ExpenseDraft draft) async {
    final who = _who();
    if (who == null) {
      return const ExpenseNotPermitted(Permission.paymentsCreate);
    }
    final repo = await _ref.read(expensesRepositoryProvider.future);
    return await repo.save(who.ctx, draft, can: who.can);
  }

  Future<ExpenseResult> reverse(String id) async {
    final who = _who();
    if (who == null) {
      return const ExpenseNotPermitted(Permission.entriesReverse);
    }
    final repo = await _ref.read(expensesRepositoryProvider.future);
    return await repo.reverse(who.ctx, id, can: who.can);
  }

  Future<bool> attachBill(String id, BillPhoto bill) async {
    final who = _who();
    if (who == null) return false;
    final repo = await _ref.read(expensesRepositoryProvider.future);
    return await repo.attachBill(who.ctx, id, bill, can: who.can);
  }

  Future<ExpenseResult> postDue(DueRecurring due) async {
    final who = _who();
    if (who == null) {
      return const ExpenseNotPermitted(Permission.paymentsCreate);
    }
    final repo = await _ref.read(expensesRepositoryProvider.future);
    return await repo.postDue(who.ctx, due, can: who.can);
  }

  Future<String?> addCategory(String name, AccountGroup group) async {
    final who = _who();
    if (who == null) return null;
    final repo = await _ref.read(expensesRepositoryProvider.future);
    return await repo.addCategory(who.ctx, name, group, can: who.can);
  }

  Future<bool> updateCategory(
    String id, {
    String? name,
    AccountGroup? group,
    bool? isActive,
  }) async {
    final who = _who();
    if (who == null) return false;
    final repo = await _ref.read(expensesRepositoryProvider.future);
    return await repo.updateCategory(
      who.ctx,
      id,
      can: who.can,
      name: name,
      group: group,
      isActive: isActive,
    );
  }

  Future<String?> addRecurring({
    required String categoryId,
    required Money amount,
    required bool isCash,
    required int dayOfMonth,
    required LedgerDate start,
    String? bankAccountId,
    String? paidTo,
  }) async {
    final who = _who();
    if (who == null) return null;
    final repo = await _ref.read(expensesRepositoryProvider.future);
    return await repo.addRecurring(
      who.ctx,
      categoryId: categoryId,
      amount: amount,
      isCash: isCash,
      dayOfMonth: dayOfMonth,
      start: start,
      bankAccountId: bankAccountId,
      paidTo: paidTo,
      can: who.can,
    );
  }

  Future<void> setRecurringActive(String id, {required bool isActive}) async {
    final who = _who();
    if (who == null || !who.can(Permission.entriesReverse)) return;
    final repo = await _ref.read(expensesRepositoryProvider.future);
    await repo.setRecurringActive(who.ctx, id, isActive: isActive);
  }
}

@Riverpod(keepAlive: true)
ExpensesWriter expensesWriter(Ref ref) => ExpensesWriter(ref);
