import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/numbering/number_series_service.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart'
    show SqliteReadContext, SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Payments and receipts of one business in the local database
/// (offline-first).
///
/// Recording a payment writes the payment, the party's khata entry, the cash
/// / bank book line and every audit row in ONE local transaction, which the
/// connector uploads all-or-nothing. Reversing one (by mistake, or because a
/// cheque bounced) reverses the khata entry and the book line together. All
/// maths comes from khata_core.
class PaymentsRepository {
  PaymentsRepository(this._db, {this.planDefaults = const {}});

  final PowerSyncDatabase _db;

  /// Values from the subscription plan (settings cascade, step 5.1).
  final Map<String, Object?> planDefaults;

  // Joins match on id and tenant: the payment row is already tenant-filtered.
  static const _select =
      'SELECT p.*, pa.name AS party_name, pa.code AS party_code, '
      'a.name AS account_name '
      'FROM payments p '
      'LEFT JOIN parties pa ON pa.id = p.party_id '
      'AND pa.tenant_id = p.tenant_id '
      'LEFT JOIN bank_accounts a ON a.id = p.bank_account_id '
      'AND a.tenant_id = p.tenant_id ';

  static const _tables = {'payments', 'parties', 'bank_accounts'};

  /// Payments of [tenantId] matching [filter], newest first. Live.
  Stream<List<Payment>> watchAll(String tenantId, PaymentFilter filter) {
    final text = filter.query.trim().toLowerCase();
    final like = '%${_escape(text)}%';
    return _db
        .watch(
          '$_select WHERE p.tenant_id = ? '
          'AND (? IS NULL OR p.entry_date >= ?) '
          'AND (? IS NULL OR p.entry_date <= ?) '
          'AND (? IS NULL OR p.party_id = ?) '
          'AND (? IS NULL OR p.direction = ?) '
          'AND (? IS NULL OR p.mode = ?) '
          "AND (? = 0 OR (p.cheque_status = 'pending' "
          "AND p.status = 'posted')) "
          "AND (? = '' "
          r"OR lower(pa.name) LIKE ? ESCAPE '\' "
          r"OR lower(pa.code) LIKE ? ESCAPE '\' "
          r"OR lower(p.receipt_no) LIKE ? ESCAPE '\' "
          r"OR lower(p.cheque_no) LIKE ? ESCAPE '\') "
          'ORDER BY p.entry_date DESC, p.created_at DESC, p.id DESC',
          parameters: [
            tenantId,
            filter.from?.toString(),
            filter.from?.toString(),
            filter.to?.toString(),
            filter.to?.toString(),
            filter.partyId,
            filter.partyId,
            filter.direction?.dbName,
            filter.direction?.dbName,
            filter.mode?.name,
            filter.mode?.name,
            if (filter.pendingChequesOnly) 1 else 0,
            text,
            like,
            like,
            like,
            like,
          ],
          triggerOnTables: _tables,
        )
        .map((rows) => [for (final r in rows) Payment.fromRow(r)]);
  }

  /// One payment, or null. Live.
  Stream<Payment?> watchOne(String tenantId, String id) => _db
      .watch(
        '$_select WHERE p.tenant_id = ? AND p.id = ?',
        parameters: [tenantId, id],
        triggerOnTables: _tables,
      )
      .map((rows) => rows.isEmpty ? null : Payment.fromRow(rows.first));

  /// The number the next payment of [direction] on this device will get.
  Future<String> previewNextNo(WriteContext ctx, PaymentDirection direction) =>
      _db.readTransaction(
        (tx) => NumberSeriesService.peek(tx, ctx, _series(direction)),
      );

  /// A payment to a party is a voucher (`V-`), money received a receipt
  /// (`R-`).
  static DocumentSeries _series(PaymentDirection d) =>
      d == PaymentDirection.toParty
      ? DocumentSeries.voucher
      : DocumentSeries.receipt;

  static const _limitKey = 'business.munshi_payment_limit';

  /// The business's limit on one payment to a party (`business.munshi_
  /// payment_limit`); zero = none.
  static Future<Money> paymentLimit(
    SqliteReadContext tx,
    String tenantId, {
    Map<String, Object?> planDefaults = const {},
  }) async {
    final rows = await SettingsRepository.rowsIn(tx, tenantId, businessTarget);
    return Money(
      SettingsResolver(
            rows,
            planDefaults: planDefaults,
          ).resolve(_limitKey).value!
          as int,
    );
  }

  /// Records a payment or receipt: the payment, the party's khata entry and
  /// the book line, in one transaction. Nothing is written when a rule
  /// refuses it.
  Future<PaymentSaveResult> save(
    WriteContext ctx,
    PaymentDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    final problems = draft.validate();
    if (problems.isNotEmpty) return PaymentInvalid(problems);
    final when = now ?? DateTime.now();
    return await _db.writeTransaction(
      (tx) => saveIn(tx, ctx, draft, can: can, when: when),
    );
  }

  /// [save] inside [tx], the caller's transaction: a loan is issued, or
  /// repaid, together with its payment. [loan] ties the payment to a loan
  /// (see [LoanPaymentLink]); the loan row must already be written. The
  /// caller validates [draft] and checks any loan permission.
  Future<PaymentSaveResult> saveIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    PaymentDraft draft, {
    required bool Function(Permission) can,
    required DateTime when,
    LoanPaymentLink? loan,
  }) async {
    final problems = draft.validate();
    if (problems.isNotEmpty) return PaymentInvalid(problems);
    final at = when.toUtc().toIso8601String();
    final limit = await paymentLimit(
      tx,
      ctx.tenantId,
      planDefaults: planDefaults,
    );
    for (final needed in PaymentRules.requiredPermissions(
      direction: draft.direction,
      mode: draft.mode,
      amount: draft.amount,
      limit: limit,
    )) {
      if (!can(needed)) {
        return PaymentNotPermitted(
          needed,
          limit:
              needed == Permission.entriesReverse &&
                  PaymentRules.exceedsLimit(
                    draft.direction,
                    draft.amount,
                    limit,
                  )
              ? limit
              : null,
        );
      }
    }
    final entryRefType = loan?.refType ?? draft.direction.refType;
    final refused = await LedgerRepository.checkDate(
      tx,
      ctx,
      entryRefType,
      draft.entryDate,
      can: can,
      now: when,
      planDefaults: planDefaults,
    );
    if (refused != null) {
      return PaymentNotPermitted(
        refused.permission,
        backdateDays: refused.backdateDays,
      );
    }

    final party = await tx.getOptional(
      'SELECT 1 FROM parties '
      'WHERE tenant_id = ? AND id = ? AND deleted_at IS NULL',
      [ctx.tenantId, draft.partyId],
    );
    if (party == null) return const PaymentNotFound();

    final String accountId;
    if (draft.mode.usesCashAccount) {
      // Seeded by the server for every business and the same id everywhere.
      accountId = BankAccountsRepository.cashIdFor(ctx.tenantId);
    } else {
      final account = await tx.getOptional(
        'SELECT id FROM bank_accounts WHERE tenant_id = ? AND id = ? '
        "AND kind = 'bank' AND is_active = 1",
        [ctx.tenantId, draft.bankAccountId],
      );
      if (account == null) return const PaymentNotFound();
      accountId = account['id']! as String;
    }

    final id = const Uuid().v4();
    final receiptNo = await NumberSeriesService.next(
      tx,
      ctx,
      _series(draft.direction),
      now: when,
    );
    final isCheque = draft.mode == PaymentMode.cheque;
    final columns = <String, Object?>{
      'receipt_no': receiptNo,
      'entry_date': draft.entryDate.toString(),
      'party_id': draft.partyId,
      'direction': draft.direction.dbName,
      'mode': draft.mode.name,
      'amount_paise': draft.amount.paise,
      'bank_account_id': accountId,
      'reference': _clean(draft.reference),
      'cheque_no': isCheque ? _clean(draft.chequeNo) : null,
      'cheque_date': isCheque ? draft.chequeDate?.toString() : null,
      'cheque_status': isCheque ? ChequeStatus.pending.name : null,
      'narration': _clean(draft.narration),
      'status': PaymentStatus.posted.name,
      'loan_id': loan?.loanId,
    };
    await tx.execute(
      'INSERT INTO payments (id, tenant_id, ${columns.keys.join(', ')}, '
      'device_id, created_by, created_at, updated_at) '
      'VALUES (${List.filled(columns.length + 6, '?').join(', ')})',
      [id, ctx.tenantId, ...columns.values, ctx.deviceId, ctx.userId, at, at],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'payments',
      rowId: id,
      action: AuditAction.insert,
      after: {
        for (final MapEntry(:key, :value) in columns.entries) key: ?value,
      },
      at: when,
    );

    final narration = loan == null
        ? receiptNo
        : '${loan.loanNo} \u00b7 $receiptNo';
    await LedgerRepository.post(
      tx,
      ctx,
      LedgerDraft(
        partyId: draft.partyId,
        side: draft.direction.side,
        amount: draft.amount,
        refType: entryRefType,
        // A loan's disbursal points at the loan; everything else at the
        // payment (so reversing the payment finds its entry).
        refId: loan != null && loan.isDisbursal ? loan.loanId : id,
        entryDate: draft.entryDate,
        narration: narration,
      ),
      now: when,
    );
    await _insertBookLine(
      tx,
      ctx,
      accountId: accountId,
      accountKind: draft.mode.usesCashAccount ? 'cash' : 'bank',
      entryDate: draft.entryDate,
      direction: draft.direction.book,
      amount: draft.amount,
      paymentId: id,
      narration: narration,
      when: when,
    );
    await JournalWriter.post(
      tx,
      ctx,
      PostingRules.payment(
        paymentId: id,
        date: draft.entryDate,
        direction: draft.direction,
        partyId: draft.partyId,
        bankAccountId: accountId,
        amount: draft.amount,
        narration: narration,
      ),
      now: when,
    );
    return PaymentSaved(id, receiptNo);
  }

  /// Reverses a payment (needs `entries.reverse`): the khata entry and the
  /// book line are reversed and the payment is marked reversed, in one
  /// transaction. The reversals are dated like the payment.
  Future<PaymentSaveResult> reverse(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse)) {
      return const PaymentNotPermitted(Permission.entriesReverse);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction(
      (tx) => _reverseIn(tx, ctx, id, when: when, bounced: false),
    );
  }

  /// Moves a pending cheque to [to]. Clearing needs `payments.create`. A
  /// bounce needs `entries.reverse` and reverses the khata entry and the book
  /// line, dated [bounceDate] (today when null).
  Future<PaymentSaveResult> setChequeStatus(
    WriteContext ctx,
    String id,
    ChequeStatus to, {
    required bool Function(Permission) can,
    LedgerDate? bounceDate,
    DateTime? now,
  }) async {
    if (to == ChequeStatus.pending) return const PaymentLocked();
    final needed = PaymentRules.cheque(to);
    if (!can(needed)) return PaymentNotPermitted(needed);
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      if (to == ChequeStatus.bounced) {
        return await _reverseIn(
          tx,
          ctx,
          id,
          when: when,
          bounced: true,
          bounceDate: bounceDate,
        );
      }
      final row = await _payment(tx, ctx.tenantId, id);
      if (row == null) return const PaymentNotFound();
      if (row['status'] != 'posted' || row['cheque_status'] != 'pending') {
        return const PaymentLocked();
      }
      await tx.execute(
        'UPDATE payments SET cheque_status = ?, updated_at = ? '
        'WHERE tenant_id = ? AND id = ?',
        [to.name, when.toUtc().toIso8601String(), ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'payments',
        rowId: id,
        action: AuditAction.update,
        before: {'cheque_status': 'pending'},
        after: {'cheque_status': to.name},
        at: when,
      );
      return PaymentSaved(id, row['receipt_no']! as String);
    });
  }

  Future<PaymentSaveResult> _reverseIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    String id, {
    required DateTime when,
    required bool bounced,
    LedgerDate? bounceDate,
  }) async {
    final row = await _payment(tx, ctx.tenantId, id);
    if (row == null) return const PaymentNotFound();
    if (row['status'] != 'posted') return const PaymentLocked();
    if (bounced && row['cheque_status'] != 'pending') {
      return const PaymentLocked();
    }
    // A loan's own payment is undone from the loan: a disbursal never, a
    // repayment only while the loan is still active.
    final loanId = row['loan_id'] as String?;
    if (loanId != null) {
      if (row['direction'] == PaymentDirection.toParty.dbName) {
        return const PaymentLocked();
      }
      final loan = await tx.getOptional(
        'SELECT status FROM loans WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, loanId],
      );
      if (loan == null || loan['status'] != 'active') {
        return const PaymentLocked();
      }
    }
    final receiptNo = row['receipt_no']! as String;
    final reversalDate = bounced
        ? bounceDate ?? LedgerDate.fromDateTime(when)
        : null;

    final entries = await tx.getAll(
      'SELECT e.id FROM ledger_entries e WHERE e.tenant_id = ? '
      'AND e.ref_id = ? AND e.ref_type IN (?, ?, ?) AND NOT EXISTS ( '
      'SELECT 1 FROM ledger_entries r WHERE r.tenant_id = e.tenant_id '
      'AND r.reverses_id = e.id) ORDER BY e.created_at, e.id',
      [
        ctx.tenantId,
        id,
        RefType.payment.dbName,
        RefType.receipt.dbName,
        RefType.loanRepayment.dbName,
      ],
    );
    for (final e in entries) {
      await LedgerRepository.reverseIn(
        tx,
        ctx,
        e['id']! as String,
        entryDate: reversalDate,
        narration: receiptNo,
        now: when,
      );
    }

    final lines = await tx.getAll(
      'SELECT l.* FROM cash_bank_entries l WHERE l.tenant_id = ? '
      'AND l.payment_id = ? AND l.reverses_id IS NULL AND NOT EXISTS ( '
      'SELECT 1 FROM cash_bank_entries r WHERE r.tenant_id = l.tenant_id '
      'AND r.reverses_id = l.id) ORDER BY l.created_at, l.id',
      [ctx.tenantId, id],
    );
    for (final l in lines) {
      await _insertBookLine(
        tx,
        ctx,
        accountId: l['account_id']! as String,
        accountKind: l['account_kind']! as String,
        entryDate: reversalDate ?? LedgerDate.parse(l['entry_date']! as String),
        direction: BookDirection.parse(l['direction']! as String).opposite,
        amount: Money(l['amount_paise']! as int),
        paymentId: id,
        narration: receiptNo,
        reversesId: l['id']! as String,
        when: when,
      );
    }

    final at = when.toUtc().toIso8601String();
    await tx.execute(
      'UPDATE payments SET status = ?, reversed_at = ?, '
      '${bounced ? 'cheque_status = ?, ' : ''}updated_at = ? '
      'WHERE tenant_id = ? AND id = ?',
      [
        PaymentStatus.reversed.name,
        at,
        if (bounced) ChequeStatus.bounced.name,
        at,
        ctx.tenantId,
        id,
      ],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'payments',
      rowId: id,
      action: AuditAction.reverse,
      before: {'status': 'posted', if (bounced) 'cheque_status': 'pending'},
      after: {'status': 'reversed', if (bounced) 'cheque_status': 'bounced'},
      at: when,
    );
    return PaymentSaved(id, receiptNo);
  }

  static Future<void> _insertBookLine(
    SqliteWriteContext tx,
    WriteContext ctx, {
    required String accountId,
    required String accountKind,
    required LedgerDate entryDate,
    required BookDirection direction,
    required Money amount,
    required String paymentId,
    required String? narration,
    required DateTime when,
    String? reversesId,
  }) async {
    final lineId = const Uuid().v4();
    await tx.execute(
      'INSERT INTO cash_bank_entries (id, tenant_id, account_id, '
      'account_kind, entry_date, direction, amount_paise, payment_id, '
      'narration, reverses_id, device_id, created_by, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        lineId,
        ctx.tenantId,
        accountId,
        accountKind,
        entryDate.toString(),
        direction.dbName,
        amount.paise,
        paymentId,
        narration,
        reversesId,
        ctx.deviceId,
        ctx.userId,
        when.toUtc().toIso8601String(),
      ],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'cash_bank_entries',
      rowId: lineId,
      action: reversesId == null ? AuditAction.insert : AuditAction.reverse,
      after: {
        'account_id': accountId,
        'entry_date': entryDate.toString(),
        'direction': direction.dbName,
        'amount_paise': amount.paise,
        'payment_id': paymentId,
        'reverses_id': ?reversesId,
      },
      at: when,
    );
  }

  static Future<Map<String, Object?>?> _payment(
    SqliteWriteContext tx,
    String tenantId,
    String id,
  ) => tx.getOptional('SELECT * FROM payments WHERE tenant_id = ? AND id = ?', [
    tenantId,
    id,
  ]);

  static String? _clean(String? text) {
    final t = text?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  static String _escape(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
