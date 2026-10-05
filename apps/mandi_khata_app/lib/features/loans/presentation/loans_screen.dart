import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart' show Permission;
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/loans/presentation/issue_loan_dialog.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_card.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class LoanRoutes {
  static const list = '/loans';
  static String detail(String id) => '/loans/$id';
  static const post = '/loans/post';
}

/// Loans (karza) of the business as cards. Ctrl/⌘+N issues one (owner),
/// Ctrl/⌘+F searches, Esc goes home.
class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  final _searchFocus = FocusNode();
  LoanFilter _filter = const LoanFilter();

  /// Shown while the next query loads, so filtering never flashes empty.
  List<LoanSummary>? _last;

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _issue() async {
    final id = await showIssueLoanDialog(context);
    if (id != null && mounted) context.go(LoanRoutes.detail(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canIssue = ref.watch(canProvider(Permission.loansManage));
    final loans = ref.watch(loanListProvider(_filter)).value ?? _last;
    _last = loans;
    return CallbackShortcuts(
      bindings: {
        ...primaryShortcut(LogicalKeyboardKey.keyF, _searchFocus.requestFocus),
        if (canIssue) ...primaryShortcut(LogicalKeyboardKey.keyN, _issue),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(GateRoutes.home),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          floatingActionButton: canIssue
              ? FloatingActionButton.extended(
                  key: const ValueKey('loans-issue'),
                  onPressed: _issue,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.loansIssue),
                )
              : null,
          body: Column(
            children: [
              MkTopBar(
                title: l10n.loansTitle,
                actions: [
                  const SyncStatusChip(),
                  if (canIssue)
                    IconButton(
                      key: const ValueKey('loans-post-interest'),
                      tooltip: l10n.postInterestTitle,
                      onPressed: () => context.go(LoanRoutes.post),
                      icon: const Icon(Icons.playlist_add_check),
                    ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => context.go(GateRoutes.home),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(MkSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MkTextField(
                      key: const ValueKey('loans-search'),
                      focusNode: _searchFocus,
                      hint: l10n.loansSearchHint,
                      prefix: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.search, size: 20),
                      ),
                      onChanged: (v) =>
                          setState(() => _filter = _filter.copyWith(query: v)),
                    ),
                    const SizedBox(height: MkSpacing.md),
                    Wrap(
                      spacing: MkSpacing.sm,
                      children: [
                        for (final (s, label) in [
                          (LoanStatusFilter.open, l10n.loansFilterOpen),
                          (LoanStatusFilter.closed, l10n.loansFilterClosed),
                          (LoanStatusFilter.all, l10n.loansFilterAll),
                        ])
                          ChoiceChip(
                            key: ValueKey('loans-filter-${s.name}'),
                            label: Text(label),
                            selected: _filter.status == s,
                            onSelected: (_) => setState(
                              () => _filter = _filter.copyWith(status: s),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: _body(l10n, loans, canIssue)),
              if (loans != null && loans.isNotEmpty)
                _TotalsBar(totals: LoanTotals.of(loans)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n, List<LoanSummary>? loans, bool canIssue) {
    if (loans == null) return const Center(child: CircularProgressIndicator());
    if (loans.isEmpty) {
      return MkEmptyState(
        icon: Icons.request_quote_outlined,
        title: l10n.loansEmpty,
        action: canIssue
            ? MkButton(
                label: l10n.loansIssue,
                icon: Icons.add,
                onPressed: _issue,
              )
            : null,
      );
    }
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 1100
            ? 3
            : c.maxWidth >= 700
            ? 2
            : 1;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(MkSpacing.lg, 0, MkSpacing.lg, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: MkSpacing.md,
            mainAxisSpacing: MkSpacing.md,
            mainAxisExtent: 190,
          ),
          itemCount: loans.length,
          itemBuilder: (context, i) => LoanCard(
            summary: loans[i],
            onTap: () => context.go(LoanRoutes.detail(loans[i].loan.id)),
          ),
        );
      },
    );
  }
}

class _TotalsBar extends StatelessWidget {
  const _TotalsBar({required this.totals});

  final LoanTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    Widget item(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: MkSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ', style: TextStyle(color: tokens.textMuted)),
          value,
        ],
      ),
    );
    return DecoratedBox(
      key: const ValueKey('loans-totals'),
      decoration: BoxDecoration(
        color: tokens.background2,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MkSpacing.md),
        child: Wrap(
          alignment: WrapAlignment.end,
          runSpacing: MkSpacing.xs,
          children: [
            item(l10n.loansTotalCount, Text('${totals.count}')),
            item(l10n.loansTotalPrincipal, MkMoneyText(totals.principal)),
            item(
              l10n.loansTotalInterest,
              MkMoneyText(totals.interest, tone: MkMoneyTone.udhaar),
            ),
            item(l10n.loansTotalOverdue, Text('${totals.overdue}')),
          ],
        ),
      ),
    );
  }
}
