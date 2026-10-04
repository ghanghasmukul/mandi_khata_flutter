import 'dart:async';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;

/// In-memory payments for screen tests. Writes are recorded and, like the
/// real repository, change what the streams show.
class FakePaymentsRepository implements PaymentsRepository {
  final payments = <Payment>[];
  final saved = <PaymentDraft>[];
  final reversed = <String>[];
  final chequeMoves = <({String id, ChequeStatus to, LedgerDate? date})>[];

  /// Returned instead of saving, when set.
  PaymentSaveResult? nextResult;
  final _changed = StreamController<void>.broadcast();

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

  @override
  Map<String, Object?> get planDefaults => const {};

  @override
  Stream<List<Payment>> watchAll(String tenantId, PaymentFilter f) => _live(
    () => [
      for (final p in payments)
        if ((f.from == null || p.entryDate >= f.from!) &&
            (f.to == null || p.entryDate <= f.to!) &&
            (f.direction == null || p.direction == f.direction) &&
            (f.mode == null || p.mode == f.mode) &&
            (!f.pendingChequesOnly || p.isPendingCheque) &&
            (f.query.isEmpty ||
                p.partyName.toLowerCase().contains(f.query.toLowerCase())))
          p,
    ],
  );

  @override
  Stream<Payment?> watchOne(String tenantId, String id) => _live(() {
    for (final p in payments) {
      if (p.id == id) return p;
    }
    return null;
  });

  @override
  Future<String> previewNextNo(WriteContext ctx, PaymentDirection d) async =>
      d == PaymentDirection.toParty ? 'V-W1-0007' : 'R-W1-0007';

  @override
  Future<PaymentSaveResult> saveIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    PaymentDraft draft, {
    required bool Function(Permission) can,
    required DateTime when,
    LoanPaymentLink? loan,
  }) => throw UnimplementedError('only loans use a transaction');

  @override
  Future<PaymentSaveResult> save(
    WriteContext ctx,
    PaymentDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    saved.add(draft);
    final forced = nextResult;
    if (forced != null) return forced;
    final no = draft.direction == PaymentDirection.toParty
        ? 'V-W1-0007'
        : 'R-W1-0007';
    payments.add(
      Payment(
        id: 'pay-${payments.length + 1}',
        receiptNo: no,
        entryDate: draft.entryDate,
        partyId: draft.partyId,
        partyName: 'Gurmeet Singh',
        direction: draft.direction,
        mode: draft.mode,
        amount: draft.amount,
        bankAccountId: draft.bankAccountId ?? 'cash',
        chequeNo: draft.chequeNo,
        chequeDate: draft.chequeDate,
        chequeStatus: draft.mode == PaymentMode.cheque
            ? ChequeStatus.pending
            : null,
        status: PaymentStatus.posted,
        createdAt: DateTime.utc(2026, 4, 10),
      ),
    );
    _changed.add(null);
    return PaymentSaved('pay-${payments.length}', no);
  }

  @override
  Future<PaymentSaveResult> reverse(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    reversed.add(id);
    return PaymentSaved(id, 'V-W1-0001');
  }

  @override
  Future<PaymentSaveResult> setChequeStatus(
    WriteContext ctx,
    String id,
    ChequeStatus to, {
    required bool Function(Permission) can,
    LedgerDate? bounceDate,
    DateTime? now,
  }) async {
    chequeMoves.add((id: id, to: to, date: bounceDate));
    return PaymentSaved(id, 'V-W1-0001');
  }
}

class FakeBankAccountsRepository implements BankAccountsRepository {
  final accounts = <BankAccount>[
    const BankAccount(
      id: 'cash',
      kind: AccountKind.cash,
      name: 'Cash',
      isActive: true,
    ),
  ];
  final balances = <String, Money>{};
  final created = <BankAccountInput>[];
  final toggled = <({String id, bool active})>[];
  final _changed = StreamController<void>.broadcast();

  @override
  Stream<List<BankAccount>> watchAll(
    String tenantId, {
    bool includeInactive = false,
  }) async* {
    List<BankAccount> read() => [
      for (final a in accounts)
        if (includeInactive || a.isActive) a,
    ];
    yield read();
    await for (final _ in _changed.stream) {
      yield read();
    }
  }

  @override
  Stream<Map<String, Money>> watchBalances(String tenantId) =>
      Stream.value(balances);

  @override
  Future<BankAccountResult> create(
    WriteContext ctx,
    BankAccountInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    created.add(input);
    accounts.add(
      BankAccount(
        id: 'bank-${accounts.length}',
        kind: AccountKind.bank,
        name: input.name.trim(),
        bankName: input.bankName,
        last4: input.last4,
        isActive: true,
      ),
    );
    _changed.add(null);
    return BankAccountSaved('bank-${accounts.length - 1}');
  }

  @override
  Future<BankAccountResult> update(
    WriteContext ctx,
    String id,
    BankAccountInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async => BankAccountSaved(id);

  @override
  Future<BankAccountResult> setActive(
    WriteContext ctx,
    String id, {
    required bool active,
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    toggled.add((id: id, active: active));
    return BankAccountSaved(id);
  }
}
