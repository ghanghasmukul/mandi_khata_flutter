import 'dart:typed_data';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// An expense category (`expense_categories`).
@immutable
class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.group,
    required this.isActive,
    this.code,
  });

  factory ExpenseCategory.fromRow(Map<String, Object?> r) => ExpenseCategory(
    id: r['id']! as String,
    name: r['name']! as String,
    code: r['code'] as String?,
    group:
        AccountGroup.fromCode(r['group_code']! as String) ??
        AccountGroup.indirectExpenses,
    isActive: r['is_active'] == 1,
  );

  final String id;
  final String name;
  final String? code;
  final AccountGroup group;
  final bool isActive;
}

/// A bill photo to attach: file name, bytes, MIME type.
@immutable
class BillPhoto {
  const BillPhoto(this.fileName, this.bytes, this.contentType);

  final String fileName;
  final Uint8List bytes;
  final String contentType;
}

/// An expense to record.
@immutable
class ExpenseDraft {
  const ExpenseDraft({
    required this.date,
    required this.categoryId,
    required this.amount,
    required this.isCash,
    this.bankAccountId,
    this.paidTo,
    this.narration,
    this.bill,
  });

  final LedgerDate date;
  final String categoryId;
  final Money amount;
  final bool isCash;

  /// A bank account (when not cash).
  final String? bankAccountId;
  final String? paidTo;
  final String? narration;
  final BillPhoto? bill;
}

/// A recorded expense.
@immutable
class Expense {
  const Expense({
    required this.id,
    required this.expenseNo,
    required this.date,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.isCash,
    required this.accountName,
    required this.isReversed,
    this.paidTo,
    this.narration,
    this.billPath,
    this.period,
  });

  factory Expense.fromRow(Map<String, Object?> r) => Expense(
    id: r['id']! as String,
    expenseNo: r['expense_no']! as String,
    date: LedgerDate.parse(r['entry_date']! as String),
    categoryId: r['category_id']! as String,
    categoryName: r['category_name'] as String? ?? '',
    amount: Money(r['amount_paise']! as int),
    isCash: r['mode'] == 'cash',
    accountName: r['account_name'] as String? ?? '',
    isReversed: r['status'] == 'reversed',
    paidTo: r['paid_to'] as String?,
    narration: r['narration'] as String?,
    billPath: r['bill_path'] as String?,
    period: r['period'] as String?,
  );

  final String id;
  final String expenseNo;
  final LedgerDate date;
  final String categoryId;
  final String categoryName;
  final Money amount;
  final bool isCash;
  final String accountName;
  final bool isReversed;
  final String? paidTo;
  final String? narration;
  final String? billPath;

  /// `yyyy-mm` when it posted a recurring month.
  final String? period;
}

/// A recurring expense template.
@immutable
class RecurringExpense {
  const RecurringExpense({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.isCash,
    required this.bankAccountId,
    required this.schedule,
    required this.isActive,
    this.paidTo,
    this.narration,
  });

  factory RecurringExpense.fromRow(Map<String, Object?> r) => RecurringExpense(
    id: r['id']! as String,
    categoryId: r['category_id']! as String,
    categoryName: r['category_name'] as String? ?? '',
    amount: Money(r['amount_paise']! as int),
    isCash: r['mode'] == 'cash',
    bankAccountId: r['bank_account_id']! as String,
    schedule: RecurringSchedule(
      dayOfMonth: r['day_of_month']! as int,
      start: LedgerDate.parse(r['start_date']! as String),
      end: r['end_date'] == null
          ? null
          : LedgerDate.parse(r['end_date']! as String),
    ),
    isActive: r['is_active'] == 1,
    paidTo: r['paid_to'] as String?,
    narration: r['narration'] as String?,
  );

  final String id;
  final String categoryId;
  final String categoryName;
  final Money amount;
  final bool isCash;
  final String bankAccountId;
  final RecurringSchedule schedule;
  final bool isActive;
  final String? paidTo;
  final String? narration;
}

/// A month of a recurring expense that is due and not posted.
@immutable
class DueRecurring {
  const DueRecurring(this.template, this.period, this.date);

  final RecurringExpense template;
  final String period;
  final LedgerDate date;
}

sealed class ExpenseResult {
  const ExpenseResult();
}

final class ExpenseSaved extends ExpenseResult {
  const ExpenseSaved(this.id, this.expenseNo);

  final String id;
  final String expenseNo;
}

final class ExpenseInvalid extends ExpenseResult {
  const ExpenseInvalid(this.problems);

  final List<ExpenseProblem> problems;
}

final class ExpenseNotPermitted extends ExpenseResult {
  const ExpenseNotPermitted(
    this.permission, {
    this.backdateDays,
    this.lockedYear = false,
  });

  final Permission permission;
  final int? backdateDays;

  /// The date is in a closed financial year.
  final bool lockedYear;
}

/// The category, account or expense is not here (or is switched off).
final class ExpenseNotFound extends ExpenseResult {
  const ExpenseNotFound();
}

/// Already reversed, or this recurring month is already posted.
final class ExpenseLocked extends ExpenseResult {
  const ExpenseLocked();
}
