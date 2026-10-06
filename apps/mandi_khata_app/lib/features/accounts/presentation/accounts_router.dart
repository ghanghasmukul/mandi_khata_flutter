import 'package:flutter/widgets.dart' show ValueKey;
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_day_book_screen.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_hub_screen.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/accounts/presentation/books_screen.dart';
import 'package:mandi_khata_app/features/accounts/presentation/cash_book_screen.dart';
import 'package:mandi_khata_app/features/accounts/presentation/chart_screen.dart';
import 'package:mandi_khata_app/features/accounts/presentation/reconciliation_screen.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statement_screens.dart';
import 'package:mandi_khata_app/features/accounts/presentation/tally_export_screen.dart';
import 'package:mandi_khata_app/features/accounts/presentation/voucher_entry_screen.dart';
import 'package:mandi_khata_app/features/accounts/presentation/year_close_screen.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_screen.dart';

/// Every screen under `/accounts` (phase 3).
List<RouteBase> accountsRoutes() => [
  GoRoute(
    path: AccountRoutes.hub,
    builder: (context, state) => const AccountsHubScreen(),
  ),
  GoRoute(
    path: AccountRoutes.books,
    builder: (context, state) => const BooksScreen(),
  ),
  GoRoute(
    path: AccountRoutes.voucherNew,
    builder: (context, state) {
      final type = VoucherType.values
          .where((t) => t.dbName == state.uri.queryParameters['type'])
          .firstOrNull;
      return VoucherEntryScreen(
        key: ValueKey(type),
        initialType: type ?? VoucherType.payment,
      );
    },
  ),
  GoRoute(
    path: AccountRoutes.dayBook,
    builder: (context, state) => const AccountsDayBookScreen(),
  ),
  GoRoute(
    path: AccountRoutes.chart,
    builder: (context, state) => const ChartScreen(),
  ),
  GoRoute(
    path: AccountRoutes.cashBook,
    builder: (context, state) =>
        CashBookScreen(accountId: state.uri.queryParameters['account']),
  ),
  GoRoute(
    path: AccountRoutes.reconcile,
    builder: (context, state) => const ReconciliationScreen(),
  ),
  GoRoute(
    path: AccountRoutes.expenses,
    builder: (context, state) => const ExpensesScreen(),
  ),
  GoRoute(
    path: AccountRoutes.trialBalance,
    builder: (context, state) => const TrialBalanceScreen(),
  ),
  GoRoute(
    path: AccountRoutes.profitLoss,
    builder: (context, state) => const ProfitLossScreen(),
  ),
  GoRoute(
    path: AccountRoutes.balanceSheet,
    builder: (context, state) => const BalanceSheetScreen(),
  ),
  GoRoute(
    path: AccountRoutes.ledger,
    builder: (context, state) => AccountLedgerScreen(
      key: ValueKey(state.uri.queryParameters['account']),
      accountId: state.uri.queryParameters['account'],
    ),
  ),
  GoRoute(
    path: AccountRoutes.groupSummary,
    builder: (context, state) => const GroupSummaryScreen(),
  ),
  GoRoute(
    path: AccountRoutes.yearClose,
    builder: (context, state) => const YearCloseScreen(),
  ),
  GoRoute(
    path: AccountRoutes.tally,
    builder: (context, state) => const TallyExportScreen(),
  ),
];
