import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/dashboard/domain/alerts.dart';
import 'package:mandi_khata_app/features/dashboard/domain/dashboard.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_providers.dart';
import 'package:mandi_khata_app/features/expenses/presentation/expenses_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_screen.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:mandi_khata_app/features/reports/presentation/reports_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// "Needs you today": rejected sync changes, cheques due and what munshis
/// changed lately. Each row only for members who can act on it.
class NeedsYouCard extends ConsumerWidget {
  const NeedsYouCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final counts =
        ref.watch(attentionCountsProvider).value ?? AttentionCounts.none;
    final rejected = ref.watch(syncErrorsProvider).value?.length ?? 0;
    final canCheques = ref.watch(canProvider(Permission.paymentsCreate));
    final canStaff = ref.watch(canProvider(Permission.entriesReverse));
    final canLoans = ref.watch(canProvider(Permission.loansManage));
    final canFinance = ref.watch(canProvider(Permission.financeView));
    final loans = ref.watch(loanAlertsProvider).value ?? LoanAlerts.none;
    final credit = ref.watch(creditAlertsProvider).value ?? CreditAlerts.none;
    final unposted = ref.watch(unpostedInterestProvider).value;
    final recurringDue = canCheques
        ? ref.watch(dueRecurringProvider).value?.length ?? 0
        : 0;
    final books = ref.watch(booksAfterSyncProvider).value;
    final booksProblems = books == null
        ? 0
        : books.unbalanced + books.partyDifferences + books.bookDifferences;
    final staleBank = canFinance
        ? ref.watch(staleBankLinesProvider).value ?? 0
        : 0;
    final isOwner =
        ref.watch(activeMembershipProvider)?.role == MemberRole.owner;

    final rows = [
      if (rejected > 0)
        _NeedRow(
          icon: Icons.sync_problem_outlined,
          text: l10n.dashNeedsSyncErrors(rejected),
          onTap: isOwner ? () => context.go(AppRoutes.diagnostics) : null,
        ),
      if (canLoans && loans.overdue > 0)
        _NeedRow(
          key: const ValueKey('need-loans-overdue'),
          icon: Icons.request_quote_outlined,
          text: l10n.dashNeedsLoansOverdue(loans.overdue),
          onTap: () => context.go(LoanRoutes.list),
        ),
      if (canLoans && loans.dueSoon > 0)
        _NeedRow(
          key: const ValueKey('need-loans-soon'),
          icon: Icons.event_outlined,
          text: l10n.dashNeedsLoansDueSoon(loans.dueSoon),
          onTap: () => context.go(LoanRoutes.list),
        ),
      if (canFinance && credit.count > 0)
        _NeedRow(
          key: const ValueKey('need-over-limit'),
          icon: Icons.warning_amber_outlined,
          text: l10n.dashNeedsOverLimit(credit.count),
          onTap: () => context.go(ReportRoutes.of(ReportKind.outstanding)),
        ),
      if (unposted != null && unposted.accounts > 0)
        _NeedRow(
          key: const ValueKey('need-interest-unposted'),
          icon: Icons.playlist_add_check,
          text: l10n.dashNeedsInterestUnposted(
            unposted.accounts,
            unposted.amount.short(),
          ),
          onTap: () => context.go(LoanRoutes.postAsOf(unposted.asOf)),
        ),
      if (booksProblems > 0)
        _NeedRow(
          key: const ValueKey('need-books'),
          icon: Icons.error_outline,
          text: l10n.dashNeedsBooks(booksProblems),
          onTap: () => context.go(AccountRoutes.books),
        ),
      if (staleBank > 0)
        _NeedRow(
          key: const ValueKey('need-unreconciled'),
          icon: Icons.compare_arrows,
          text: l10n.dashNeedsUnreconciled(staleBank),
          onTap: () => context.go(AccountRoutes.reconcile),
        ),
      if (recurringDue > 0)
        _NeedRow(
          key: const ValueKey('need-recurring-due'),
          icon: Icons.event_repeat,
          text: l10n.dashNeedsRecurringDue(recurringDue),
          onTap: () => context.go(AccountRoutes.expenses),
        ),
      if (canCheques && counts.chequesDue > 0)
        _NeedRow(
          icon: Icons.receipt_long_outlined,
          text: l10n.dashNeedsCheques(
            counts.chequesDue,
            counts.chequesDueAmount.short(),
          ),
          onTap: () => context.go(PaymentRoutes.list),
        ),
      if (canStaff && counts.staffChanges > 0)
        _NeedRow(
          icon: Icons.manage_history_outlined,
          text: l10n.dashNeedsStaff(counts.staffChanges),
        ),
    ];
    return MkCard(
      title: l10n.dashNeedsTitle,
      child: rows.isEmpty
          ? Text(
              l10n.dashNeedsNothing,
              style: TextStyle(color: tokens.textMuted),
            )
          : Column(children: rows),
    );
  }
}

class _NeedRow extends StatelessWidget {
  const _NeedRow({
    required this.icon,
    required this.text,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 48,
      leading: Icon(icon, color: MkColors.goldText),
      title: Text(text),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
