import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/numbering/number_series_service.dart';
import 'package:mandi_khata_app/features/accounts/data/book_line_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/period_lock.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Vouchers (contra, payment, receipt, sales, purchase, journal) in the
/// local database (docs/domain/posting-rules.md, 11.2).
///
/// Posting writes, in ONE local transaction: the voucher, its balanced
/// journal entry, a khata entry for every party line, a cash / bank book
/// line for every cash / bank line, and the audit rows. Reversing undoes all
/// of them the same way.
class VoucherRepository {
  VoucherRepository(this._db, {this.planDefaults = const {}});

  final PowerSyncDatabase _db;

  /// Values from the subscription plan (settings cascade, step 5.1).
  final Map<String, Object?> planDefaults;

  /// The number the next voucher of [type] on this device will get.
  Future<String> previewNextNo(WriteContext ctx, VoucherType type) => _db
      .readTransaction((tx) => NumberSeriesService.peek(tx, ctx, type.series));

  /// Posts [draft] (needs `entries.reverse`, and `finance.view` for a bank
  /// line). Nothing is written when a rule refuses it.
  Future<VoucherSaveResult> save(
    WriteContext ctx,
    VoucherDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    return await _db.writeTransaction(
      (tx) => saveIn(tx, ctx, draft, can: can, when: when),
    );
  }

  /// [save] inside the caller's transaction. [allowBooksInJournal] is for a
  /// journal voucher the app makes itself (the cash count difference).
  Future<VoucherSaveResult> saveIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    VoucherDraft draft, {
    required bool Function(Permission) can,
    required DateTime when,
    bool allowBooksInJournal = false,
  }) async {
    if (!can(Permission.entriesReverse)) {
      return const VoucherNotPermitted(Permission.entriesReverse);
    }
    if (draft.lines.any((l) => l.account.kind == VoucherAccountKind.bank) &&
        !can(Permission.financeView)) {
      return const VoucherNotPermitted(Permission.financeView);
    }
    final problems = VoucherRules.validate(
      draft.type,
      draft.inputs,
      allowBooksInJournal: allowBooksInJournal,
    );
    if (problems.isNotEmpty) return VoucherInvalid(problems);
    final refused = await LedgerRepository.checkDate(
      tx,
      ctx,
      RefType.voucher,
      draft.date,
      can: can,
      now: when,
      planDefaults: planDefaults,
    );
    if (refused != null) {
      return VoucherNotPermitted(
        refused.permission,
        backdateDays: refused.backdateDays,
        lockedYear: refused.lockedYear,
      );
    }

    // Every account must still be in this business's chart.
    final chart = await ChartRepository.load(tx, ctx.tenantId);
    for (final l in draft.lines) {
      final current = chart.byId(l.account.id);
      if (current == null || !current.isActive) {
        return const VoucherNotFound();
      }
    }

    final id = const Uuid().v4();
    final no = await NumberSeriesService.next(
      tx,
      ctx,
      draft.type.series,
      now: when,
    );
    final narration = _clean(draft.narration);
    final journal = VoucherRules.journal(
      voucherId: id,
      date: draft.date,
      lines: draft.inputs,
      narration: narration == null ? no : '$no · $narration',
    );
    final at = when.toUtc().toIso8601String();
    final columns = <String, Object?>{
      'voucher_type': draft.type.dbName,
      'voucher_no': no,
      'entry_date': draft.date.toString(),
      'narration': narration,
      'total_paise': journal.total.paise,
      'status': 'posted',
    };
    await tx.execute(
      'INSERT INTO vouchers (id, tenant_id, ${columns.keys.join(', ')}, '
      'device_id, created_by, created_at, updated_at) '
      'VALUES (${List.filled(columns.length + 6, '?').join(', ')})',
      [id, ctx.tenantId, ...columns.values, ctx.deviceId, ctx.userId, at, at],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'vouchers',
      rowId: id,
      action: AuditAction.insert,
      after: {
        for (final MapEntry(:key, :value) in columns.entries) key: ?value,
        'lines': [
          for (final l in draft.lines)
            {
              'account_id': l.account.id,
              'side': l.side.name,
              'amount_paise': l.amount.paise,
            },
        ],
      },
      at: when,
    );
    await JournalWriter.post(tx, ctx, journal, now: when, voucherId: id);

    for (final l in draft.lines) {
      final partyId = l.account.partyId;
      if (partyId != null) {
        await LedgerRepository.post(
          tx,
          ctx,
          LedgerDraft(
            partyId: partyId,
            side: l.input.khataSide,
            amount: l.amount,
            refType: RefType.voucher,
            refId: id,
            entryDate: draft.date,
            narration: journal.narration,
          ),
          now: when,
        );
      }
      final bankId = l.account.bankAccountId;
      if (bankId != null) {
        await BookLineWriter.insert(
          tx,
          ctx,
          source: BookSource.voucher,
          sourceId: id,
          accountId: bankId,
          accountKind: l.account.kind == VoucherAccountKind.bank
              ? 'bank'
              : 'cash',
          entryDate: draft.date,
          direction: l.input.isMoneyIn
              ? BookDirection.moneyIn
              : BookDirection.moneyOut,
          amount: l.amount,
          narration: journal.narration,
          when: when,
        );
      }
    }
    return VoucherSaved(id, no);
  }

  /// Reverses voucher [id] (needs `entries.reverse`, and `finance.view`
  /// when it touched a bank account): its khata entries, book lines and
  /// journal entry are mirrored, dated like the voucher, and it is marked
  /// reversed.
  Future<VoucherSaveResult> reverse(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse)) {
      return const VoucherNotPermitted(Permission.entriesReverse);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM vouchers WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (row == null) return const VoucherNotFound();
      if (row['status'] != 'posted') return const VoucherLocked();
      if (await PeriodLock.refuses(
        tx,
        ctx,
        LedgerDate.parse(row['entry_date']! as String),
      )) {
        return const VoucherNotPermitted(
          Permission.adminManage,
          lockedYear: true,
        );
      }
      final bank = await tx.getOptional(
        'SELECT 1 FROM cash_bank_entries WHERE tenant_id = ? '
        "AND voucher_id = ? AND account_kind = 'bank' LIMIT 1",
        [ctx.tenantId, id],
      );
      if (bank != null && !can(Permission.financeView)) {
        return const VoucherNotPermitted(Permission.financeView);
      }
      final no = row['voucher_no']! as String;

      final entries = await tx.getAll(
        'SELECT e.id FROM ledger_entries e WHERE e.tenant_id = ? '
        'AND e.ref_id = ? AND e.ref_type = ? AND NOT EXISTS ( '
        'SELECT 1 FROM ledger_entries r WHERE r.tenant_id = e.tenant_id '
        'AND r.reverses_id = e.id) ORDER BY e.created_at, e.id',
        [ctx.tenantId, id, RefType.voucher.dbName],
      );
      for (final e in entries) {
        await LedgerRepository.reverseIn(
          tx,
          ctx,
          e['id']! as String,
          narration: no,
          now: when,
        );
      }
      await BookLineWriter.reverseAll(
        tx,
        ctx,
        source: BookSource.voucher,
        sourceId: id,
        narration: no,
        when: when,
      );
      // Done already when a party line was reversed above.
      await JournalWriter.reverse(
        tx,
        ctx,
        'voucher:$id',
        narration: no,
        now: when,
      );

      final at = when.toUtc().toIso8601String();
      await tx.execute(
        "UPDATE vouchers SET status = 'reversed', reversed_at = ?, "
        'updated_at = ? WHERE tenant_id = ? AND id = ?',
        [at, at, ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'vouchers',
        rowId: id,
        action: AuditAction.reverse,
        before: {'status': 'posted'},
        after: {'status': 'reversed'},
        at: when,
      );
      return VoucherSaved(id, no);
    });
  }

  static const _dayTables = {'journal_entries', 'journal_lines', 'vouchers'};

  /// Journal entries dated [from]..[to] (the accounts day book), newest
  /// first, with their voucher. [voucherType] keeps only that type of
  /// voucher; [vouchersOnly] only vouchers. Live.
  Stream<List<JournalDayRow>> watchDayBook(
    String tenantId, {
    required LedgerDate from,
    required LedgerDate to,
    VoucherType? voucherType,
    bool vouchersOnly = false,
  }) => _db
      .watch(
        'SELECT e.id, e.source_key, e.source_type, e.entry_date, e.narration, '
        'e.reverses_id, '
        '(SELECT SUM(l.debit_paise) FROM journal_lines l '
        'WHERE l.tenant_id = e.tenant_id AND l.journal_entry_id = e.id) '
        'AS total, '
        'EXISTS (SELECT 1 FROM journal_entries r WHERE r.tenant_id = '
        'e.tenant_id AND r.reverses_id = e.id) AS reversed, '
        'v.id AS v_id, v.voucher_type, v.voucher_no, v.entry_date AS v_date, '
        'v.total_paise, v.status, v.narration AS v_narration '
        'FROM journal_entries e LEFT JOIN vouchers v '
        'ON v.id = e.voucher_id AND v.tenant_id = e.tenant_id '
        'WHERE e.tenant_id = ? AND e.entry_date >= ? AND e.entry_date <= ? '
        'AND (? = 0 OR e.voucher_id IS NOT NULL) '
        'AND (? IS NULL OR v.voucher_type = ?) '
        'ORDER BY e.entry_date DESC, e.created_at DESC, e.id DESC LIMIT 2000',
        parameters: [
          tenantId,
          from.toString(),
          to.toString(),
          if (vouchersOnly || voucherType != null) 1 else 0,
          voucherType?.dbName,
          voucherType?.dbName,
        ],
        triggerOnTables: _dayTables,
      )
      .map(
        (rows) => [
          for (final r in rows)
            JournalDayRow(
              id: r['id']! as String,
              sourceKey: r['source_key']! as String,
              sourceType: r['source_type']! as String,
              date: LedgerDate.parse(r['entry_date']! as String),
              total: Money(r['total'] as int? ?? 0),
              narration: r['narration'] as String?,
              reversesId: r['reverses_id'] as String?,
              isReversed: r['reversed'] == 1,
              voucher: r['v_id'] == null
                  ? null
                  : Voucher.fromRow({
                      'id': r['v_id'],
                      'voucher_type': r['voucher_type'],
                      'voucher_no': r['voucher_no'],
                      'entry_date': r['v_date'],
                      'total_paise': r['total_paise'],
                      'status': r['status'],
                      'narration': r['v_narration'],
                    }),
            ),
        ],
      );

  /// The lines of journal entry [entryId], with their accounts. Live.
  Stream<List<JournalLineView>> watchLines(String tenantId, String entryId) =>
      _db
          .watch(
            'SELECT account_id, debit_paise, credit_paise, memo '
            'FROM journal_lines WHERE tenant_id = ? AND journal_entry_id = ? '
            'ORDER BY line_no',
            parameters: [tenantId, entryId],
            triggerOnTables: {'journal_lines', ...ChartRepository.tables},
          )
          .asyncMap((rows) async {
            final chart = await _db.readTransaction(
              (tx) => ChartRepository.load(tx, tenantId),
            );
            return [
              for (final r in rows)
                JournalLineView(
                  accountId: r['account_id']! as String,
                  account: chart.byId(r['account_id']! as String),
                  debit: Money(r['debit_paise']! as int),
                  credit: Money(r['credit_paise']! as int),
                  memo: r['memo'] as String?,
                ),
            ];
          });

  static String? _clean(String? text) {
    final t = text?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}

/// Accounts of [chart] a voucher line can use, the [suggested] kinds first.
List<ChartEntry> voucherAccounts(
  Chart chart, {
  Set<VoucherAccountKind> suggested = const {},
}) {
  final active = chart.accounts.where((a) => a.isActive).toList();
  if (suggested.isEmpty) return active;
  return [
    ...active.where((a) => suggested.contains(a.kind)),
    ...active.where((a) => !suggested.contains(a.kind)),
  ];
}
