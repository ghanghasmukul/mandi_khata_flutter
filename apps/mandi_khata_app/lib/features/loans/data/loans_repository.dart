import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/numbering/number_series_service.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/payments/data/payments_repository.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart'
    show SqliteReadContext, SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Loans (karza) of one business in the local database (offline-first).
///
/// Issuing a loan writes the loan, its disbursal payment (cash or bank), the
/// party's udhaar entry (`loan_disbursal`), the book line and every audit
/// row in ONE local transaction, uploaded all-or-nothing. A repayment is a
/// payment from the party tied to the loan, or an adjustment against crop
/// proceeds already in the khata. The interest is never stored: the engine
/// (khata_core `calculate`) runs over the loan's khata entries and rate
/// changes whenever it is shown.
class LoansRepository {
  LoansRepository(this._db, this._payments, {this.planDefaults = const {}});

  final PowerSyncDatabase _db;
  final PaymentsRepository _payments;

  /// Values from the subscription plan (settings cascade, step 5.1).
  final Map<String, Object?> planDefaults;

  // Joins match on id and tenant: the loan row is already tenant-filtered.
  static const _select =
      'SELECT l.*, pa.name AS party_name, pa.code AS party_code, '
      'g.name AS guarantor_name '
      'FROM loans l '
      'LEFT JOIN parties pa ON pa.id = l.party_id '
      'AND pa.tenant_id = l.tenant_id '
      'LEFT JOIN parties g ON g.id = l.guarantor_party_id '
      'AND g.tenant_id = l.tenant_id ';

  static const _tables = {
    'loans',
    'parties',
    'ledger_entries',
    'payments',
    'loan_rate_changes',
    'interest_postings',
  };

  static String _escape(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

  /// Loans of [tenantId] matching [filter] with their figures as of [asOf]
  /// (today when null), open loans first, soonest due first. Live.
  Stream<List<LoanSummary>> watchAll(
    String tenantId,
    LoanFilter filter, {
    LedgerDate? asOf,
  }) {
    final text = filter.query.trim().toLowerCase();
    final like = '%${_escape(text)}%';
    final statuses = filter.status.statuses;
    return _db
        .watch(
          '$_select WHERE l.tenant_id = ? '
          '${statuses == null ? '' : 'AND l.status IN '
                    '(${List.filled(statuses.length, '?').join(', ')}) '}'
          "AND (? = '' "
          r"OR lower(pa.name) LIKE ? ESCAPE '\' "
          r"OR lower(pa.code) LIKE ? ESCAPE '\' "
          r"OR lower(l.loan_no) LIKE ? ESCAPE '\') "
          "ORDER BY CASE l.status WHEN 'active' THEN 0 ELSE 1 END, "
          'l.due_date IS NULL, l.due_date, l.issue_date DESC, l.id',
          parameters: [
            tenantId,
            ...?statuses?.map((s) => s.dbName),
            text,
            like,
            like,
            like,
          ],
          triggerOnTables: _tables,
        )
        .asyncMap((rows) async {
          final loans = [for (final r in rows) Loan.fromRow(r)];
          if (loans.isEmpty) return const <LoanSummary>[];
          final day = asOf ?? LedgerDate.fromDateTime(DateTime.now());
          final (entries, changes) = await _db.readTransaction(
            (tx) async => (
              await _entriesByLoan(tx, tenantId),
              await _rateChangesByLoan(tx, tenantId),
            ),
          );
          return [
            for (final loan in loans)
              LoanSummary(
                loan: loan,
                position: LoanDetail(
                  loan: loan,
                  entries: entries[loan.id] ?? const [],
                  rateChanges: changes[loan.id] ?? const [],
                ).position(day),
              ),
          ];
        });
  }

  /// One loan with its entries and rate changes, or null. Live.
  Stream<LoanDetail?> watchOne(String tenantId, String id) => _db
      .watch(
        '$_select WHERE l.tenant_id = ? AND l.id = ?',
        parameters: [tenantId, id],
        triggerOnTables: _tables,
      )
      .asyncMap((rows) async {
        if (rows.isEmpty) return null;
        return await _db.readTransaction(
          (tx) => _detail(tx, tenantId, Loan.fromRow(rows.first)),
        );
      });

  static Future<LoanDetail> _detail(
    SqliteReadContext tx,
    String tenantId,
    Loan loan,
  ) async => LoanDetail(
    loan: loan,
    entries:
        (await _entriesByLoan(tx, tenantId, loanId: loan.id))[loan.id] ??
        const [],
    rateChanges:
        (await _rateChangesByLoan(tx, tenantId, loanId: loan.id))[loan.id] ??
        const [],
  );

  /// The disbursal and repayment entries (not reversed) of every loan, or of
  /// [loanId] only. An entry belongs to a loan through `ref_id`: the loan
  /// itself (disbursal, crop-proceeds repayment) or a payment tied to it.
  static Future<Map<String, List<LoanEntry>>> _entriesByLoan(
    SqliteReadContext tx,
    String tenantId, {
    String? loanId,
  }) async {
    final payments = await tx.getAll(
      'SELECT id, loan_id FROM payments WHERE tenant_id = ? '
      'AND loan_id IS NOT NULL ${loanId == null ? '' : 'AND loan_id = ?'}',
      [tenantId, ?loanId],
    );
    final loanOfPayment = {
      for (final p in payments) p['id']! as String: p['loan_id']! as String,
    };
    // Interest waivers of loans: journal entries pointing at a waiver
    // posting (`ref_id`) that belongs to the loan.
    final waivers = await tx.getAll(
      'SELECT id, loan_id FROM interest_postings WHERE tenant_id = ? '
      "AND kind = 'waiver' AND loan_id IS NOT NULL "
      '${loanId == null ? '' : 'AND loan_id = ?'}',
      [tenantId, ?loanId],
    );
    final loanOfWaiver = {
      for (final w in waivers) w['id']! as String: w['loan_id']! as String,
    };
    final rows = await tx.getAll(
      'SELECT e.* FROM ledger_entries e WHERE e.tenant_id = ? '
      'AND (e.ref_type IN (?, ?) OR (e.ref_type = ? '
      'AND e.ref_id IN (SELECT id FROM interest_postings WHERE tenant_id = ? '
      "AND kind = 'waiver'))) AND NOT EXISTS ( "
      'SELECT 1 FROM ledger_entries r WHERE r.tenant_id = e.tenant_id '
      'AND r.reverses_id = e.id) '
      'ORDER BY e.entry_date, e.created_at, e.id',
      [
        tenantId,
        RefType.loanDisbursal.dbName,
        RefType.loanRepayment.dbName,
        RefType.journal.dbName,
        tenantId,
      ],
    );
    final byLoan = <String, List<LoanEntry>>{};
    for (final r in rows) {
      final ref = r['ref_id'] as String?;
      if (ref == null) continue;
      final waiverLoan = loanOfWaiver[ref];
      if (r['ref_type'] == RefType.journal.dbName && waiverLoan == null) {
        continue;
      }
      final owner = waiverLoan ?? loanOfPayment[ref] ?? ref;
      if (loanId != null && owner != loanId) continue;
      byLoan
          .putIfAbsent(owner, () => [])
          .add(
            LoanEntry(
              entry: LedgerRepository.fromRow(r),
              paymentId: loanOfPayment.containsKey(ref) ? ref : null,
              isWaiver: waiverLoan != null,
            ),
          );
    }
    return byLoan;
  }

  static Future<Map<String, List<LoanRateChange>>> _rateChangesByLoan(
    SqliteReadContext tx,
    String tenantId, {
    String? loanId,
  }) async {
    final rows = await tx.getAll(
      'SELECT * FROM loan_rate_changes WHERE tenant_id = ? '
      '${loanId == null ? '' : 'AND loan_id = ? '}'
      'ORDER BY effective_date, created_at, id',
      [tenantId, ?loanId],
    );
    final byLoan = <String, List<LoanRateChange>>{};
    for (final r in rows) {
      byLoan
          .putIfAbsent(r['loan_id']! as String, () => [])
          .add(LoanRateChange.fromRow(r));
    }
    return byLoan;
  }

  /// Every active loan of [tenantId] (of [partyId] only when given) with its
  /// entries and rate changes, read inside [tx]. Interest posting works on
  /// these.
  static Future<List<LoanDetail>> openDetailsIn(
    SqliteReadContext tx,
    String tenantId, {
    String? partyId,
  }) async {
    final rows = await tx.getAll(
      '$_select WHERE l.tenant_id = ? AND l.status = ? '
      '${partyId == null ? '' : 'AND l.party_id = ? '}'
      'ORDER BY l.issue_date, l.id',
      [tenantId, LoanStatus.active.dbName, ?partyId],
    );
    if (rows.isEmpty) return const [];
    final entries = await _entriesByLoan(tx, tenantId);
    final changes = await _rateChangesByLoan(tx, tenantId);
    return [
      for (final r in rows)
        LoanDetail(
          loan: Loan.fromRow(r),
          entries: entries[r['id']! as String] ?? const [],
          rateChanges: changes[r['id']! as String] ?? const [],
        ),
    ];
  }

  /// The number the next loan on this device will get.
  Future<String> previewNextNo(WriteContext ctx) => _db.readTransaction(
    (tx) => NumberSeriesService.peek(tx, ctx, DocumentSeries.karza),
  );

  /// Issues a loan (needs `loans.manage`): the loan, its disbursal payment,
  /// the party's udhaar entry, the book line and the audit rows in one
  /// transaction. The interest terms in [draft] are snapshotted on the loan;
  /// the loan is its own interest account (`apply_on = loans_only`). Nothing
  /// is written when a rule refuses it.
  Future<LoanResult> issue(
    WriteContext ctx,
    LoanDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    for (final needed in LoanRules.requiredPermissions(LoanAction.issue)) {
      if (!can(needed)) return LoanNotPermitted(needed);
    }
    final config = draft.config.copyWith(applyOn: ApplyOn.loansOnly);
    final problems = LoanRules.validateIssue(
      amount: draft.amount,
      issueDate: draft.issueDate,
      partyId: draft.partyId,
      ratePa: config.ratePa.toString(),
      dueDate: draft.dueDate,
      guarantorId: draft.guarantorPartyId,
    );
    final payment = draft.toPayment();
    final paymentProblems = payment.validate();
    if (problems.isNotEmpty || paymentProblems.isNotEmpty) {
      return LoanInvalid(problems: problems, paymentProblems: paymentProblems);
    }
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();

    try {
      return await _db.writeTransaction((tx) async {
        if (!await _partyExists(tx, ctx.tenantId, draft.partyId)) {
          return const LoanNotFound();
        }
        final guarantor = draft.guarantorPartyId;
        if (guarantor != null &&
            !await _partyExists(tx, ctx.tenantId, guarantor)) {
          return const LoanNotFound();
        }
        final id = const Uuid().v4();
        final loanNo = await NumberSeriesService.next(
          tx,
          ctx,
          DocumentSeries.karza,
          now: when,
        );
        final columns = <String, Object?>{
          'loan_no': loanNo,
          'party_id': draft.partyId,
          'issue_date': draft.issueDate.toString(),
          'principal_paise': draft.amount.paise,
          'purpose': _clean(draft.purpose),
          'due_date': draft.dueDate?.toString(),
          'guarantor_party_id': guarantor,
          'interest_config_snapshot': jsonEncode(config.toJson()),
          'status': LoanStatus.active.dbName,
          'notes': _clean(draft.notes),
        };
        await tx.execute(
          'INSERT INTO loans (id, tenant_id, ${columns.keys.join(', ')}, '
          'device_id, created_by, created_at, updated_at) '
          'VALUES (${List.filled(columns.length + 6, '?').join(', ')})',
          [
            id,
            ctx.tenantId,
            ...columns.values,
            ctx.deviceId,
            ctx.userId,
            at,
            at,
          ],
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'loans',
          rowId: id,
          action: AuditAction.insert,
          after: {
            for (final MapEntry(:key, :value) in columns.entries)
              key: key == 'interest_config_snapshot' ? config.toJson() : value,
          }..removeWhere((_, v) => v == null),
          at: when,
        );
        final paid = await _payments.saveIn(
          tx,
          ctx,
          payment,
          can: can,
          when: when,
          loan: LoanPaymentLink.disbursal(loanId: id, loanNo: loanNo),
        );
        if (paid is! PaymentSaved) throw _Abort(_fromPayment(paid));
        return LoanSaved(id, loanNo);
      });
    } on _Abort catch (stop) {
      return stop.result;
    }
  }

  /// Records a repayment (needs `payments.create`; adjusting crop proceeds
  /// also `entries.reverse`). It must not be more than the loan's payable on
  /// that day. Cash / bank: a payment from the party tied to the loan, its
  /// `loan_repayment` jama and the book line. Crop proceeds: a
  /// `loan_repayment` jama and a balancing `journal` udhaar, so the party's
  /// net balance does not change; the amount is limited to the credit the
  /// party has in the khata.
  Future<LoanResult> repay(
    WriteContext ctx,
    LoanRepaymentDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    final action = draft.source == RepaymentSource.cropProceeds
        ? LoanAction.adjustFromCrop
        : LoanAction.repay;
    for (final needed in LoanRules.requiredPermissions(action)) {
      if (!can(needed)) return LoanNotPermitted(needed);
    }
    if (!draft.amount.isPositive) {
      return const LoanInvalid(problems: [LoanProblem.amountNotPositive]);
    }
    final when = now ?? DateTime.now();

    try {
      return await _db.writeTransaction((tx) async {
        final loan = await _loan(tx, ctx.tenantId, draft.loanId);
        if (loan == null) return const LoanNotFound();
        if (!loan.isOpen) return const LoanNotActive();
        final detail = await _detail(tx, ctx.tenantId, loan);
        final preview = detail.previewRepayment(draft.date, draft.amount);
        if (preview.exceedsPayable) {
          return LoanExceedsPayable(preview.payableBefore);
        }

        if (draft.source == RepaymentSource.payment) {
          final payment = draft.toPayment(loan.partyId);
          final problems = payment.validate();
          if (problems.isNotEmpty) {
            return LoanInvalid(paymentProblems: problems);
          }
          final paid = await _payments.saveIn(
            tx,
            ctx,
            payment,
            can: can,
            when: when,
            loan: LoanPaymentLink.repayment(
              loanId: loan.id,
              loanNo: loan.loanNo,
            ),
          );
          if (paid is! PaymentSaved) throw _Abort(_fromPayment(paid));
          return LoanSaved(loan.id, loan.loanNo);
        }

        final available = LoanRules.cropProceedsAvailable(
          await _partyBalance(tx, ctx.tenantId, loan.partyId),
        );
        if (draft.amount > available) return LoanExceedsCrop(available);
        for (final refType in [RefType.loanRepayment, RefType.journal]) {
          final refused = await LedgerRepository.checkDate(
            tx,
            ctx,
            refType,
            draft.date,
            can: can,
            now: when,
            planDefaults: planDefaults,
          );
          if (refused != null) {
            return LoanNotPermitted(
              refused.permission,
              backdateDays: refused.backdateDays,
            );
          }
        }
        final note = _clean(draft.narration);
        await LedgerRepository.post(
          tx,
          ctx,
          LedgerDraft(
            partyId: loan.partyId,
            side: Side.jama,
            amount: draft.amount,
            refType: RefType.loanRepayment,
            refId: loan.id,
            entryDate: draft.date,
            narration: '${loan.loanNo} · ${note ?? 'crop proceeds'}',
          ),
          now: when,
        );
        await LedgerRepository.post(
          tx,
          ctx,
          LedgerDraft(
            partyId: loan.partyId,
            side: Side.udhaar,
            amount: draft.amount,
            refType: RefType.journal,
            refId: loan.id,
            entryDate: draft.date,
            narration: '${loan.loanNo} · adjusted against crop proceeds',
          ),
          now: when,
        );
        return LoanSaved(loan.id, loan.loanNo);
      });
    } on _Abort catch (stop) {
      return stop.result;
    }
  }

  /// Changes the rate of an active loan from [effectiveDate] on (needs
  /// `loans.manage`). Append-only: the old rate stays in the statement for
  /// the days before.
  Future<LoanResult> changeRate(
    WriteContext ctx,
    String loanId, {
    required String ratePa,
    required LedgerDate effectiveDate,
    required bool Function(Permission) can,
    String? reason,
    DateTime? now,
  }) async {
    for (final needed in LoanRules.requiredPermissions(LoanAction.changeRate)) {
      if (!can(needed)) return LoanNotPermitted(needed);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final loan = await _loan(tx, ctx.tenantId, loanId);
      if (loan == null) return const LoanNotFound();
      final problems = LoanRules.validateRateChange(
        ratePa: ratePa,
        effectiveDate: effectiveDate,
        issueDate: loan.issueDate,
        status: loan.status,
      );
      if (problems.isNotEmpty) return LoanInvalid(problems: problems);
      final rate = LoanRules.parseRate(ratePa)!.toString();
      final id = const Uuid().v4();
      await tx.execute(
        'INSERT INTO loan_rate_changes (id, tenant_id, loan_id, '
        'effective_date, rate_pa, reason, device_id, created_by, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          id,
          ctx.tenantId,
          loanId,
          effectiveDate.toString(),
          rate,
          _clean(reason),
          ctx.deviceId,
          ctx.userId,
          when.toUtc().toIso8601String(),
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'loan_rate_changes',
        rowId: id,
        action: AuditAction.insert,
        after: {
          'loan_id': loanId,
          'effective_date': effectiveDate.toString(),
          'rate_pa': rate,
          'reason': ?_clean(reason),
        },
        at: when,
      );
      return LoanSaved(loanId, loan.loanNo);
    });
  }

  /// Closes a loan with nothing left to pay (needs `loans.manage`).
  Future<LoanResult> close(
    WriteContext ctx,
    String loanId, {
    required LedgerDate closedOn,
    required bool Function(Permission) can,
    String? reason,
    DateTime? now,
  }) => _finish(
    ctx,
    loanId,
    LoanStatus.closed,
    closedOn: closedOn,
    reason: reason,
    can: can,
    now: now,
  );

  /// Writes off what is still owed (needs `loans.manage`; a reason is
  /// required). Only the loan's status changes: the khata keeps showing the
  /// udhaar until it is waived (step 2.4).
  Future<LoanResult> writeOff(
    WriteContext ctx,
    String loanId, {
    required LedgerDate closedOn,
    required String reason,
    required bool Function(Permission) can,
    DateTime? now,
  }) => _finish(
    ctx,
    loanId,
    LoanStatus.writtenOff,
    closedOn: closedOn,
    reason: reason,
    can: can,
    now: now,
  );

  Future<LoanResult> _finish(
    WriteContext ctx,
    String loanId,
    LoanStatus to, {
    required LedgerDate closedOn,
    required bool Function(Permission) can,
    String? reason,
    DateTime? now,
  }) async {
    final action = to == LoanStatus.closed
        ? LoanAction.close
        : LoanAction.writeOff;
    for (final needed in LoanRules.requiredPermissions(action)) {
      if (!can(needed)) return LoanNotPermitted(needed);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final loan = await _loan(tx, ctx.tenantId, loanId);
      if (loan == null) return const LoanNotFound();
      if (!loan.isOpen) return const LoanNotActive();
      final detail = await _detail(tx, ctx.tenantId, loan);
      final position = detail.position(closedOn);
      final problems = to == LoanStatus.closed
          ? LoanRules.validateClose(
              position: position,
              closedOn: closedOn,
              issueDate: loan.issueDate,
              lastEventDate: detail.lastEntryDate,
            )
          : LoanRules.validateWriteOff(
              position: position,
              closedOn: closedOn,
              issueDate: loan.issueDate,
              lastEventDate: detail.lastEntryDate,
              reason: reason ?? '',
            );
      if (problems.isNotEmpty) return LoanInvalid(problems: problems);
      await tx.execute(
        'UPDATE loans SET status = ?, closed_on = ?, close_reason = ?, '
        'updated_at = ? WHERE tenant_id = ? AND id = ?',
        [
          to.dbName,
          closedOn.toString(),
          _clean(reason),
          when.toUtc().toIso8601String(),
          ctx.tenantId,
          loanId,
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'loans',
        rowId: loanId,
        action: AuditAction.update,
        before: {'status': LoanStatus.active.dbName},
        after: {
          'status': to.dbName,
          'closed_on': closedOn.toString(),
          'close_reason': ?_clean(reason),
          'payable_paise': position.payable.paise,
        },
        at: when,
      );
      return LoanSaved(loanId, loan.loanNo);
    });
  }

  static LoanResult _fromPayment(PaymentSaveResult r) => switch (r) {
    PaymentSaved() => throw StateError('a saved payment is not a failure'),
    PaymentNotPermitted(:final permission, :final backdateDays, :final limit) =>
      LoanNotPermitted(permission, backdateDays: backdateDays, limit: limit),
    PaymentNotFound() => const LoanNotFound(),
    PaymentInvalid(:final problems) => LoanInvalid(paymentProblems: problems),
    PaymentLocked() => const LoanNotActive(),
  };

  static Future<Loan?> _loan(
    SqliteReadContext tx,
    String tenantId,
    String id,
  ) async {
    final row = await tx.getOptional(
      '$_select WHERE l.tenant_id = ? AND l.id = ?',
      [tenantId, id],
    );
    return row == null ? null : Loan.fromRow(row);
  }

  static Future<bool> _partyExists(
    SqliteWriteContext tx,
    String tenantId,
    String partyId,
  ) async =>
      await tx.getOptional(
        'SELECT 1 FROM parties '
        'WHERE tenant_id = ? AND id = ? AND deleted_at IS NULL',
        [tenantId, partyId],
      ) !=
      null;

  /// Σ jama − Σ udhaar of the party's whole khata.
  static Future<Money> _partyBalance(
    SqliteReadContext tx,
    String tenantId,
    String partyId,
  ) async {
    final r = await tx.get(
      "SELECT COALESCE(SUM(CASE side WHEN 'jama' THEN amount_paise "
      'ELSE -amount_paise END), 0) AS balance FROM ledger_entries '
      'WHERE tenant_id = ? AND party_id = ?',
      [tenantId, partyId],
    );
    return Money(r['balance']! as int);
  }

  static String? _clean(String? text) {
    final t = text?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}

/// Rolls the whole transaction back with [result] (a rule failed after the
/// first row was written).
class _Abort implements Exception {
  const _Abort(this.result);

  final LoanResult result;
}
