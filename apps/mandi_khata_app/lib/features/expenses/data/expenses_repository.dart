import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/numbering/number_series_service.dart';
import 'package:mandi_khata_app/features/accounts/data/book_line_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/period_lock.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Expenses, their categories and recurring templates in the local database
/// (docs/domain/posting-rules.md, 11.4).
///
/// Recording an expense writes, in ONE local transaction: the expense, its
/// journal entry (Dr the category's account / Cr cash or bank), the book
/// line, the audit rows and, when a bill photo is attached, a local upload
/// job (the photo goes to Storage later, online).
class ExpensesRepository {
  ExpensesRepository(this._db, {this.planDefaults = const {}});

  final PowerSyncDatabase _db;

  /// Values from the subscription plan (settings cascade, step 5.1).
  final Map<String, Object?> planDefaults;

  static const _namespace = '0b5d3e8a-61c2-4f97-a3d4-8e2f7c9b1a56';

  // -- categories -----------------------------------------------------------

  /// Categories of [tenantId] (the seeded ones until they sync too).
  Stream<List<ExpenseCategory>> watchCategories(String tenantId) => _db
      .watch(
        'SELECT * FROM expense_categories WHERE tenant_id = ? '
        'ORDER BY sort_order, name',
        parameters: [tenantId],
        triggerOnTables: const {'expense_categories'},
      )
      .map((rows) {
        final out = [for (final r in rows) ExpenseCategory.fromRow(r)];
        for (final seed in ExpenseCategorySeed.values) {
          final id = JournalWriter.expenseCategoryId(tenantId, seed);
          if (out.any((c) => c.id == id)) continue;
          out.add(
            ExpenseCategory(
              id: id,
              code: seed.code,
              name: seed.name,
              group: seed.group,
              isActive: true,
            ),
          );
        }
        return out;
      });

  /// Adds a category (needs `entries.reverse`); null when refused.
  Future<String?> addCategory(
    WriteContext ctx,
    String name,
    AccountGroup group, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse) || name.trim().isEmpty) return null;
    if (!ExpenseRules.groups.contains(group)) return null;
    final when = (now ?? DateTime.now()).toUtc();
    final id = const Uuid().v4();
    await _db.writeTransaction((tx) async {
      final at = when.toIso8601String();
      await tx.execute(
        'INSERT INTO expense_categories (id, tenant_id, name, group_code, '
        'sort_order, is_active, created_by, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, 100, 1, ?, ?, ?)',
        [id, ctx.tenantId, name.trim(), group.code, ctx.userId, at, at],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'expense_categories',
        rowId: id,
        action: AuditAction.insert,
        after: {'name': name.trim(), 'group_code': group.code},
        at: when,
      );
    });
    return id;
  }

  /// Renames, regroups or switches off a category (`entries.reverse`).
  /// False when refused or not synced yet.
  Future<bool> updateCategory(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    String? name,
    AccountGroup? group,
    bool? isActive,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse)) return false;
    if (name != null && name.trim().isEmpty) return false;
    if (group != null && !ExpenseRules.groups.contains(group)) return false;
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM expense_categories WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (row == null) return false;
      final after = {
        'name': name?.trim() ?? row['name'],
        'group_code': group?.code ?? row['group_code'],
        'is_active': isActive ?? row['is_active'] == 1,
      };
      await tx.execute(
        'UPDATE expense_categories SET name = ?, group_code = ?, '
        'is_active = ?, updated_at = ? WHERE tenant_id = ? AND id = ?',
        [
          after['name'],
          after['group_code'],
          if (after['is_active']! as bool) 1 else 0,
          when.toIso8601String(),
          ctx.tenantId,
          id,
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'expense_categories',
        rowId: id,
        action: AuditAction.update,
        before: {
          'name': row['name'],
          'group_code': row['group_code'],
          'is_active': row['is_active'] == 1,
        },
        after: after,
        at: when,
      );
      return true;
    });
  }

  // -- expenses -------------------------------------------------------------

  /// The number the next expense on this device will get.
  Future<String> previewNextNo(WriteContext ctx) => _db.readTransaction(
    (tx) => NumberSeriesService.peek(tx, ctx, DocumentSeries.expense),
  );

  /// Records an expense (needs `payments.create`, `finance.view` for bank).
  Future<ExpenseResult> save(
    WriteContext ctx,
    ExpenseDraft draft, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    return await _db.writeTransaction(
      (tx) => _saveIn(tx, ctx, draft, can: can, when: when),
    );
  }

  Future<ExpenseResult> _saveIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    ExpenseDraft draft, {
    required bool Function(Permission) can,
    required DateTime when,
    String? id,
    String? recurringId,
    String? period,
  }) async {
    final problems = ExpenseRules.validate(
      amount: draft.amount,
      categoryId: draft.categoryId,
      isCash: draft.isCash,
      bankAccountId: draft.bankAccountId,
    );
    if (problems.isNotEmpty) return ExpenseInvalid(problems);
    if (!can(Permission.paymentsCreate)) {
      return const ExpenseNotPermitted(Permission.paymentsCreate);
    }
    if (!draft.isCash && !can(Permission.financeView)) {
      return const ExpenseNotPermitted(Permission.financeView);
    }
    final refused = await LedgerRepository.checkDate(
      tx,
      ctx,
      RefType.expense,
      draft.date,
      can: can,
      now: when,
      planDefaults: planDefaults,
    );
    if (refused != null) {
      return ExpenseNotPermitted(
        refused.permission,
        backdateDays: refused.backdateDays,
        lockedYear: refused.lockedYear,
      );
    }
    final category = await tx.getOptional(
      'SELECT name FROM expense_categories WHERE tenant_id = ? AND id = ? '
      'AND is_active = 1',
      [ctx.tenantId, draft.categoryId],
    );
    final seeded = ExpenseCategorySeed.values.any(
      (s) =>
          JournalWriter.expenseCategoryId(ctx.tenantId, s) == draft.categoryId,
    );
    if (category == null && !seeded) return const ExpenseNotFound();

    final String accountId;
    if (draft.isCash) {
      accountId = BankAccountsRepository.cashIdFor(ctx.tenantId);
    } else {
      final account = await tx.getOptional(
        'SELECT id FROM bank_accounts WHERE tenant_id = ? AND id = ? '
        "AND kind = 'bank' AND is_active = 1",
        [ctx.tenantId, draft.bankAccountId],
      );
      if (account == null) return const ExpenseNotFound();
      accountId = account['id']! as String;
    }

    final expenseId = id ?? const Uuid().v4();
    if (await tx.getOptional(
          'SELECT 1 FROM expenses WHERE tenant_id = ? AND id = ?',
          [ctx.tenantId, expenseId],
        ) !=
        null) {
      return const ExpenseLocked();
    }
    final no = await NumberSeriesService.next(
      tx,
      ctx,
      DocumentSeries.expense,
      now: when,
    );
    final bill = draft.bill;
    final billPath = bill == null
        ? null
        : '${ctx.tenantId}/$expenseId/${_safeName(bill.fileName)}';
    final at = when.toUtc().toIso8601String();
    final columns = <String, Object?>{
      'expense_no': no,
      'entry_date': draft.date.toString(),
      'category_id': draft.categoryId,
      'amount_paise': draft.amount.paise,
      'mode': draft.isCash ? 'cash' : 'bank',
      'bank_account_id': accountId,
      'paid_to': _clean(draft.paidTo),
      'narration': _clean(draft.narration),
      'bill_path': billPath,
      'recurring_id': recurringId,
      'period': period,
      'status': 'posted',
    };
    await tx.execute(
      'INSERT INTO expenses (id, tenant_id, ${columns.keys.join(', ')}, '
      'device_id, created_by, created_at, updated_at) '
      'VALUES (${List.filled(columns.length + 6, '?').join(', ')})',
      [
        expenseId,
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
      table: 'expenses',
      rowId: expenseId,
      action: AuditAction.insert,
      after: {
        for (final MapEntry(:key, :value) in columns.entries) key: ?value,
      },
      at: when,
    );
    final narration = [no, ?_clean(draft.paidTo)].join(' · ');
    await JournalWriter.post(
      tx,
      ctx,
      ExpenseRules.journal(
        expenseId: expenseId,
        date: draft.date,
        expenseAccount: ChartAccount(
          JournalWriter.expenseAccountId(ctx.tenantId, draft.categoryId),
        ),
        bankAccountId: accountId,
        amount: draft.amount,
        narration: narration,
      ),
      now: when,
    );
    await BookLineWriter.insert(
      tx,
      ctx,
      source: BookSource.expense,
      sourceId: expenseId,
      accountId: accountId,
      accountKind: draft.isCash ? 'cash' : 'bank',
      entryDate: draft.date,
      direction: BookDirection.moneyOut,
      amount: draft.amount,
      narration: narration,
      when: when,
    );
    if (bill != null && billPath != null) {
      await BillQueue.enqueue(tx, ctx, expenseId, billPath, bill, when);
    }
    return ExpenseSaved(expenseId, no);
  }

  /// Attaches a bill photo to an expense that has none yet.
  Future<bool> attachBill(
    WriteContext ctx,
    String expenseId,
    BillPhoto bill, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.paymentsCreate)) return false;
    final when = (now ?? DateTime.now()).toUtc();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT bill_path, status FROM expenses WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, expenseId],
      );
      if (row == null ||
          row['bill_path'] != null ||
          row['status'] != 'posted') {
        return false;
      }
      final path = '${ctx.tenantId}/$expenseId/${_safeName(bill.fileName)}';
      await tx.execute(
        'UPDATE expenses SET bill_path = ?, updated_at = ? '
        'WHERE tenant_id = ? AND id = ?',
        [path, when.toIso8601String(), ctx.tenantId, expenseId],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'expenses',
        rowId: expenseId,
        action: AuditAction.update,
        after: {'bill_path': path},
        at: when,
      );
      await BillQueue.enqueue(tx, ctx, expenseId, path, bill, when);
      return true;
    });
  }

  /// Reverses an expense (needs `entries.reverse`, and `finance.view` for a
  /// bank one): journal and book line mirrored, dated like the expense.
  Future<ExpenseResult> reverse(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse)) {
      return const ExpenseNotPermitted(Permission.entriesReverse);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final row = await tx.getOptional(
        'SELECT * FROM expenses WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (row == null) return const ExpenseNotFound();
      if (row['status'] != 'posted') return const ExpenseLocked();
      if (await PeriodLock.refuses(
        tx,
        ctx,
        LedgerDate.parse(row['entry_date']! as String),
      )) {
        return const ExpenseNotPermitted(
          Permission.adminManage,
          lockedYear: true,
        );
      }
      if (row['mode'] == 'bank' && !can(Permission.financeView)) {
        return const ExpenseNotPermitted(Permission.financeView);
      }
      final no = row['expense_no']! as String;
      await JournalWriter.reverse(
        tx,
        ctx,
        'expense:$id',
        narration: no,
        now: when,
      );
      await BookLineWriter.reverseAll(
        tx,
        ctx,
        source: BookSource.expense,
        sourceId: id,
        narration: no,
        when: when,
      );
      final at = when.toUtc().toIso8601String();
      await tx.execute(
        "UPDATE expenses SET status = 'reversed', reversed_at = ?, "
        'updated_at = ? WHERE tenant_id = ? AND id = ?',
        [at, at, ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'expenses',
        rowId: id,
        action: AuditAction.reverse,
        before: {'status': 'posted'},
        after: {'status': 'reversed'},
        at: when,
      );
      return ExpenseSaved(id, no);
    });
  }

  static const _listSelect =
      'SELECT x.*, c.name AS category_name, a.name AS account_name '
      'FROM expenses x '
      'LEFT JOIN expense_categories c ON c.id = x.category_id '
      'AND c.tenant_id = x.tenant_id '
      'LEFT JOIN bank_accounts a ON a.id = x.bank_account_id '
      'AND a.tenant_id = x.tenant_id ';

  /// Expenses dated [from]..[to] (either open), newest first. Live.
  Stream<List<Expense>> watchExpenses(
    String tenantId, {
    LedgerDate? from,
    LedgerDate? to,
  }) => _db
      .watch(
        '$_listSelect WHERE x.tenant_id = ? '
        'AND (? IS NULL OR x.entry_date >= ?) '
        'AND (? IS NULL OR x.entry_date <= ?) '
        'ORDER BY x.entry_date DESC, x.created_at DESC LIMIT 1000',
        parameters: [
          tenantId,
          from?.toString(),
          from?.toString(),
          to?.toString(),
          to?.toString(),
        ],
        triggerOnTables: const {
          'expenses',
          'expense_categories',
          'bank_accounts',
        },
      )
      .map((rows) => [for (final r in rows) Expense.fromRow(r)]);

  /// Posted (not reversed) expenses dated [from]..[to], for the report.
  Future<List<ExpenseFact>> facts(
    String tenantId, {
    LedgerDate? from,
    LedgerDate? to,
  }) async {
    final rows = await _db.getAll(
      'SELECT category_id, entry_date, amount_paise FROM expenses '
      "WHERE tenant_id = ? AND status = 'posted' "
      'AND (? IS NULL OR entry_date >= ?) AND (? IS NULL OR entry_date <= ?)',
      [
        tenantId,
        from?.toString(),
        from?.toString(),
        to?.toString(),
        to?.toString(),
      ],
    );
    return [
      for (final r in rows)
        ExpenseFact(
          categoryId: r['category_id']! as String,
          date: LedgerDate.parse(r['entry_date']! as String),
          amount: Money(r['amount_paise']! as int),
        ),
    ];
  }

  // -- recurring ------------------------------------------------------------

  /// Adds a recurring template (needs `entries.reverse`); null if refused.
  Future<String?> addRecurring(
    WriteContext ctx, {
    required String categoryId,
    required Money amount,
    required bool isCash,
    required int dayOfMonth,
    required LedgerDate start,
    required bool Function(Permission) can,
    String? bankAccountId,
    LedgerDate? end,
    String? paidTo,
    String? narration,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse)) return null;
    if (!amount.isPositive || dayOfMonth < 1 || dayOfMonth > 31) return null;
    if (end != null && end < start) return null;
    final accountId = isCash
        ? BankAccountsRepository.cashIdFor(ctx.tenantId)
        : bankAccountId;
    if (accountId == null) return null;
    final when = (now ?? DateTime.now()).toUtc();
    final id = const Uuid().v4();
    await _db.writeTransaction((tx) async {
      final at = when.toIso8601String();
      final columns = <String, Object?>{
        'category_id': categoryId,
        'amount_paise': amount.paise,
        'mode': isCash ? 'cash' : 'bank',
        'bank_account_id': accountId,
        'paid_to': _clean(paidTo),
        'narration': _clean(narration),
        'day_of_month': dayOfMonth,
        'start_date': start.toString(),
        'end_date': end?.toString(),
        'is_active': 1,
      };
      await tx.execute(
        'INSERT INTO recurring_expenses (id, tenant_id, '
        '${columns.keys.join(', ')}, created_by, created_at, updated_at) '
        'VALUES (${List.filled(columns.length + 5, '?').join(', ')})',
        [id, ctx.tenantId, ...columns.values, ctx.userId, at, at],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'recurring_expenses',
        rowId: id,
        action: AuditAction.insert,
        after: {
          for (final MapEntry(:key, :value) in columns.entries) key: ?value,
        },
        at: when,
      );
    });
    return id;
  }

  /// Switches a template off (or on again).
  Future<void> setRecurringActive(
    WriteContext ctx,
    String id, {
    required bool isActive,
    DateTime? now,
  }) async {
    final when = (now ?? DateTime.now()).toUtc();
    await _db.writeTransaction((tx) async {
      await tx.execute(
        'UPDATE recurring_expenses SET is_active = ?, updated_at = ? '
        'WHERE tenant_id = ? AND id = ?',
        [if (isActive) 1 else 0, when.toIso8601String(), ctx.tenantId, id],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'recurring_expenses',
        rowId: id,
        action: AuditAction.update,
        after: {'is_active': isActive},
        at: when,
      );
    });
  }

  /// Templates of [tenantId]. Live.
  Stream<List<RecurringExpense>> watchRecurring(String tenantId) => _db
      .watch(
        'SELECT r.*, c.name AS category_name FROM recurring_expenses r '
        'LEFT JOIN expense_categories c ON c.id = r.category_id '
        'AND c.tenant_id = r.tenant_id WHERE r.tenant_id = ? '
        'ORDER BY r.day_of_month, c.name',
        parameters: [tenantId],
        triggerOnTables: const {'recurring_expenses', 'expense_categories'},
      )
      .map((rows) => [for (final r in rows) RecurringExpense.fromRow(r)]);

  /// Months of active templates due by [today] and not posted yet. Live.
  Stream<List<DueRecurring>> watchDue(String tenantId, LedgerDate today) => _db
      .watch(
        'SELECT 1',
        triggerOnTables: const {'recurring_expenses', 'expenses'},
      )
      .asyncMap((_) => due(tenantId, today));

  Future<List<DueRecurring>> due(String tenantId, LedgerDate today) async {
    final templates = await watchRecurring(tenantId).first;
    final posted = await _db.getAll(
      'SELECT recurring_id, period FROM expenses WHERE tenant_id = ? '
      'AND recurring_id IS NOT NULL',
      [tenantId],
    );
    final byTemplate = <String, Set<String>>{};
    for (final r in posted) {
      byTemplate
          .putIfAbsent(r['recurring_id']! as String, () => {})
          .add(r['period']! as String);
    }
    return [
      for (final t in templates)
        if (t.isActive)
          for (final d in t.schedule.due(
            today,
            posted: byTemplate[t.id] ?? const {},
          ))
            DueRecurring(t, d.period, d.date),
    ];
  }

  /// Posts one due month. The expense id is UUID v5 of template + month, so
  /// two devices posting the same month write the same row once.
  Future<ExpenseResult> postDue(
    WriteContext ctx,
    DueRecurring due, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    final t = due.template;
    final id = const Uuid().v5(
      _namespace,
      '${ctx.tenantId}|recurring|${t.id}|${due.period}',
    );
    return await _db.writeTransaction(
      (tx) => _saveIn(
        tx,
        ctx,
        ExpenseDraft(
          date: due.date,
          categoryId: t.categoryId,
          amount: t.amount,
          isCash: t.isCash,
          bankAccountId: t.isCash ? null : t.bankAccountId,
          paidTo: t.paidTo,
          narration: t.narration,
        ),
        can: can,
        when: when,
        id: id,
        recurringId: t.id,
        period: due.period,
      ),
    );
  }

  static String _safeName(String name) {
    final cleaned = name.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
    return cleaned.isEmpty ? 'bill' : cleaned;
  }

  static String? _clean(String? text) {
    final t = text?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}

/// The local queue of bill photos waiting for Storage (`bill_uploads`,
/// local-only).
abstract final class BillQueue {
  static Future<void> enqueue(
    SqliteWriteContext tx,
    WriteContext ctx,
    String expenseId,
    String path,
    BillPhoto bill,
    DateTime when,
  ) => tx.execute(
    'INSERT INTO bill_uploads (id, tenant_id, expense_id, path, '
    'content_type, data, created_at, attempts) VALUES (?, ?, ?, ?, ?, ?, ?, 0)',
    [
      const Uuid().v4(),
      ctx.tenantId,
      expenseId,
      path,
      bill.contentType,
      base64Encode(bill.bytes),
      when.toUtc().toIso8601String(),
    ],
  );
}
