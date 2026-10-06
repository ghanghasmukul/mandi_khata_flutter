import 'package:flutter/services.dart';
import 'package:khata_core/khata_core.dart';

abstract final class AccountRoutes {
  static const hub = '/accounts';
  static const books = '/accounts/books';
  static const voucherNew = '/accounts/vouchers/new';
  static const dayBook = '/accounts/day-book';
  static const chart = '/accounts/chart';
  static const cashBook = '/accounts/cash-book';
  static const reconcile = '/accounts/reconcile';
  static const expenses = '/accounts/expenses';
  static const trialBalance = '/accounts/trial-balance';
  static const profitLoss = '/accounts/profit-loss';
  static const balanceSheet = '/accounts/balance-sheet';
  static const ledger = '/accounts/ledger';
  static const groupSummary = '/accounts/group-summary';
  static const yearClose = '/accounts/year-close';
  static const tally = '/accounts/tally';

  /// The ledger of one account.
  static String ledgerOf(String accountId) => '$ledger?account=$accountId';

  /// The voucher entry screen for [type].
  static String newVoucher(VoucherType type) =>
      '$voucherNew?type=${type.dbName}';
}

/// Tally's voucher keys (desktop): F4 Contra … F9 Journal.
const voucherTypeKeys = <(LogicalKeyboardKey, VoucherType)>[
  (LogicalKeyboardKey.f4, VoucherType.contra),
  (LogicalKeyboardKey.f5, VoucherType.payment),
  (LogicalKeyboardKey.f6, VoucherType.receipt),
  (LogicalKeyboardKey.f7, VoucherType.sales),
  (LogicalKeyboardKey.f8, VoucherType.purchase),
  (LogicalKeyboardKey.f9, VoucherType.journal),
];
