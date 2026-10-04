import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_change_dialogs.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_detail_cards.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_statement_table.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_screen.dart';
import 'package:mandi_khata_app/features/loans/presentation/repayment_dialog.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One loan: who, how much, the terms, the live interest statement from the
/// engine, "payable on a date" with an as-of date to answer "how much if he
/// pays on 15 Oct?", and the owner's actions. F2 records a repayment, F3
/// changes the rate, Esc goes back.
class LoanDetailScreen extends ConsumerStatefulWidget {
  const LoanDetailScreen({required this.loanId, super.key});

  final String loanId;

  @override
  ConsumerState<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends ConsumerState<LoanDetailScreen> {
  LedgerDate _asOf = LedgerDate.fromDateTime(DateTime.now());

  void _back() => context.go(LoanRoutes.list);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(loanDetailProvider(widget.loanId));
    final detail = async.value;
    final canManage = ref.watch(canProvider(Permission.loansManage));
    final canRepay = ref.watch(canProvider(Permission.paymentsCreate));
    final open = detail?.loan.isOpen ?? false;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _back,
        if (detail != null && open && canRepay)
          const SingleActivator(LogicalKeyboardKey.f2): () =>
              showRepaymentDialog(context, widget.loanId, date: _asOf),
        if (detail != null && open && canManage)
          const SingleActivator(LogicalKeyboardKey.f3): () =>
              showChangeRateDialog(context, detail),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(
                title: detail?.loan.loanNo ?? l10n.loansTitle,
                subtitle: detail?.loan.partyName,
                actions: [
                  const SyncStatusChip(),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: _back,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: switch (async) {
                  AsyncValue(value: null, isLoading: true) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  AsyncValue(value: null) => MkEmptyState(
                    icon: Icons.search_off,
                    title: l10n.loanNotFound,
                  ),
                  AsyncValue(value: final d?) => _Body(
                    detail: d,
                    asOf: _asOf,
                    onAsOf: (v) => setState(() => _asOf = v),
                    canManage: canManage,
                    canRepay: canRepay,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.detail,
    required this.asOf,
    required this.onAsOf,
    required this.canManage,
    required this.canRepay,
  });

  final LoanDetail detail;
  final LedgerDate asOf;
  final ValueChanged<LedgerDate> onAsOf;
  final bool canManage;
  final bool canRepay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loan = detail.loan;
    final position = detail.position(asOf);

    return ListView(
      padding: const EdgeInsets.all(MkSpacing.lg),
      children: [
        LoanSummaryCard(detail: detail, position: position),
        const SizedBox(height: MkSpacing.md),
        LoanFiguresCard(
          detail: detail,
          position: position,
          asOf: asOf,
          onAsOf: onAsOf,
        ),
        if (loan.isOpen) ...[
          const SizedBox(height: MkSpacing.md),
          LoanActions(
            detail: detail,
            asOf: asOf,
            canManage: canManage,
            canRepay: canRepay,
          ),
        ],
        const SizedBox(height: MkSpacing.lg),
        Text(
          l10n.loanStmtTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: MkSpacing.sm),
        LoanStatementTable(rows: position.result.schedule),
        if (detail.rateChanges.isNotEmpty) ...[
          const SizedBox(height: MkSpacing.lg),
          Text(
            l10n.loanRateChangesTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: MkSpacing.sm),
          LoanRateChangesCard(detail: detail),
        ],
      ],
    );
  }
}
