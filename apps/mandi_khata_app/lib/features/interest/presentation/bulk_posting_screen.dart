import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_posting_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_mode_fields.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The owner's posting run (`loans.manage`): every party and loan with
/// interest charged up to a day, as a table. Untick what should not be
/// posted, post. Re-running never posts the same period twice (period key),
/// and the same money is never posted on the khata AND on a loan.
///
/// v1 posts only when the owner runs this; the day proposed follows
/// `interest.post_frequency` (nothing posts by itself).
class BulkPostingScreen extends ConsumerStatefulWidget {
  const BulkPostingScreen({super.key});

  @override
  ConsumerState<BulkPostingScreen> createState() => _BulkPostingState();
}

class _BulkPostingState extends ConsumerState<BulkPostingScreen> {
  final LedgerDate _today = LedgerDate.fromDateTime(DateTime.now());
  LedgerDate? _asOf;

  /// Rows the user unticked, by period key. Everything else is selected.
  final Set<String> _excluded = {};
  bool _posting = false;
  String? _message;

  Future<void> _post(List<PostingCandidate> chosen) async {
    setState(() {
      _posting = true;
      _message = null;
    });
    final result = await ref.read(interestPostingWriterProvider).post([
      for (final c in chosen) c.plan,
    ]);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _posting = false;
      _message = switch (result) {
        InterestPosted(:final posted, :final skipped, :final total) => [
          l10n.postBulkDone(posted.length, total.format()),
          if (skipped.isNotEmpty) l10n.postBulkSkipped(skipped.length),
        ].join(' '),
        _ => l10n.postingError(result),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canManage = ref.watch(canProvider(Permission.loansManage));
    final suggested = ref.watch(suggestedPostingDayProvider(_today));
    final asOf = _asOf ?? suggested;
    final async = ref.watch(postingCandidatesProvider(asOf));
    final all = async.value ?? const <PostingCandidate>[];
    final chosen = [
      for (final c in all)
        if (!c.alreadyPosted && !_excluded.contains(c.plan.periodKey)) c,
    ];
    final total = Money(chosen.fold(0, (sum, c) => sum + c.amount.paise));

    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.postInterestTitle,
            actions: [
              const SyncStatusChip(),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => context.go(LoanRoutes.list),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Expanded(
            child: !canManage
                ? Center(child: Text(l10n.byajNoPermission))
                : ListView(
                    padding: const EdgeInsets.all(MkSpacing.lg),
                    children: [
                      Text(l10n.postBulkIntro),
                      const SizedBox(height: MkSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 220,
                            child: PaymentDateField(
                              key: const ValueKey('bulk-post-asof'),
                              label: l10n.postBulkAsOf,
                              date: asOf,
                              onChanged: (d) => setState(() {
                                _asOf = d > _today ? _today : d;
                                _excluded.clear();
                              }),
                            ),
                          ),
                          const SizedBox(width: MkSpacing.sm),
                          if (asOf != suggested)
                            TextButton(
                              key: const ValueKey('bulk-post-suggested'),
                              onPressed: () => setState(() {
                                _asOf = null;
                                _excluded.clear();
                              }),
                              child: Text(
                                l10n.postBulkSuggested(
                                  AppFormat.ledgerDate(context, suggested),
                                ),
                              ),
                            ),
                          if (asOf != _today)
                            TextButton(
                              key: const ValueKey('bulk-post-today'),
                              onPressed: () => setState(() {
                                _asOf = _today;
                                _excluded.clear();
                              }),
                              child: Text(l10n.loanDetailToday),
                            ),
                        ],
                      ),
                      const SizedBox(height: MkSpacing.md),
                      if (async.isLoading && !async.hasValue)
                        const Center(child: CircularProgressIndicator())
                      else if (all.isEmpty)
                        Text(
                          l10n.postBulkNone,
                          key: const ValueKey('bulk-post-none'),
                        )
                      else ...[
                        for (final c in all)
                          _Row(
                            candidate: c,
                            selected:
                                !c.alreadyPosted &&
                                !_excluded.contains(c.plan.periodKey),
                            onChanged: (v) => setState(() {
                              v
                                  ? _excluded.remove(c.plan.periodKey)
                                  : _excluded.add(c.plan.periodKey);
                            }),
                          ),
                        const Divider(),
                        Text(
                          l10n.postBulkTotal(chosen.length, total.format()),
                          key: const ValueKey('bulk-post-total'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                      if (_message != null) ...[
                        const SizedBox(height: MkSpacing.md),
                        Text(_message!, key: const ValueKey('bulk-post-msg')),
                      ],
                      const SizedBox(height: MkSpacing.md),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: MkButton(
                          key: const ValueKey('bulk-post-run'),
                          label: l10n.postBulkPost(chosen.length),
                          icon: Icons.check,
                          onPressed: _posting || chosen.isEmpty
                              ? null
                              : () => _post(chosen),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.candidate,
    required this.selected,
    required this.onChanged,
  });

  final PostingCandidate candidate;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plan = candidate.plan;
    final period = l10n.postPeriod(
      AppFormat.ledgerDate(context, plan.from),
      AppFormat.ledgerDate(context, plan.to),
    );
    return CheckboxListTile(
      key: ValueKey('bulk-post-${plan.periodKey}'),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: selected,
      onChanged: candidate.alreadyPosted ? null : (v) => onChanged(v ?? false),
      title: Text(
        [
          candidate.partyName,
          if (candidate.loanNo != null) candidate.loanNo!,
        ].join(' · '),
      ),
      subtitle: Text(
        candidate.alreadyPosted
            ? l10n.postSkipAlready
            : '$period · ${l10n.loanPrincipalOutstanding}: '
                  '${candidate.principal.format()}',
      ),
      secondary: MkMoneyText(candidate.amount),
    );
  }
}
