import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/accounts/data/year_close_repository.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statements_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Financial years: close one (owner), see what closing does, and unlock
/// closed years for this session with a reason (owner).
class YearCloseScreen extends ConsumerWidget {
  const YearCloseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final years = ref.watch(financialYearsProvider).value ?? const [];
    final isOwner =
        ref.watch(activeMembershipProvider)?.role == MemberRole.owner;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(AccountRoutes.hub),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(title: l10n.yearCloseTitle),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(MkSpacing.lg),
                  children: [
                    Text(l10n.yearCloseIntro),
                    const SizedBox(height: MkSpacing.md),
                    for (final y in years) _YearCard(row: y),
                    if (isOwner && years.any((y) => y.isClosed))
                      const _UnlockCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YearCard extends ConsumerWidget {
  const _YearCard({required this.row});

  final YearRow row;

  String _problem(AppLocalizations l10n, YearCloseProblem p) => switch (p) {
    YearCloseProblem.notOwner => l10n.yearProblemOwner,
    YearCloseProblem.notEnded => l10n.yearProblemNotEnded,
    YearCloseProblem.earlierOpen => l10n.yearProblemEarlier,
    YearCloseProblem.booksDoNotTally => l10n.yearProblemBooks,
    YearCloseProblem.alreadyClosed => l10n.yearClosedDone(row.year.label),
  };

  Future<void> _close(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final label = row.year.label;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.yearCloseButton(label)),
        content: Text(l10n.yearCloseConfirm(label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('year-close-confirm'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(l10n.yearCloseButton(label)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final r = await ref.read(yearCloseWriterProvider).close(row.year);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(switch (r) {
          YearClosed() => l10n.yearClosedDone(label),
          YearCloseRefused(:final problems) =>
            problems.map((p) => _problem(l10n, p)).join('\n'),
        }),
      ),
    );
  }

  String _profit(AppLocalizations l10n, Money m) => m.isNegative
      ? l10n.yearLoss(m.abs().format())
      : l10n.yearProfit(m.format());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preview = row.isClosed
        ? null
        : ref.watch(yearClosePreviewProvider(row.year.startYear)).value;
    return MkCard(
      key: ValueKey('year-${row.year.startYear}'),
      title: row.year.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (row.isClosed) ...[
            Text(
              l10n.yearClosedOn(
                row.closedAt == null
                    ? ''
                    : AppFormat.date(context, row.closedAt!.toLocal()),
              ),
            ),
            if (row.profit != null) Text(_profit(l10n, row.profit!)),
          ] else ...[
            Text(l10n.yearOpen),
            if (preview != null) ...[
              Text(_profit(l10n, preview.profit)),
              for (final p in preview.problems)
                Text(
                  _problem(l10n, p),
                  style: TextStyle(color: MkTokens.of(context).udhaar),
                ),
              const SizedBox(height: MkSpacing.sm),
              Wrap(
                spacing: MkSpacing.sm,
                children: [
                  TextButton(
                    key: ValueKey('year-interest-${row.year.startYear}'),
                    onPressed: () => context.go(
                      LoanRoutes.postAsOf(row.year.end.addDays(1)),
                    ),
                    child: Text(l10n.yearRunInterest),
                  ),
                  MkButton(
                    key: ValueKey('year-close-${row.year.startYear}'),
                    label: l10n.yearCloseButton(row.year.label),
                    icon: Icons.lock_outline,
                    onPressed: preview.canClose
                        ? () => _close(context, ref)
                        : null,
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _UnlockCard extends ConsumerStatefulWidget {
  const _UnlockCard();

  @override
  ConsumerState<_UnlockCard> createState() => _UnlockCardState();
}

class _UnlockCardState extends ConsumerState<_UnlockCard> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reason = ref.watch(lockOverrideProvider);
    return MkCard(
      key: const ValueKey('year-unlock'),
      title: l10n.yearUnlockTitle,
      child: reason != null
          ? Row(
              children: [
                Expanded(child: Text(l10n.yearUnlockOn(reason))),
                TextButton(
                  key: const ValueKey('year-relock'),
                  onPressed: () =>
                      ref.read(lockOverrideProvider.notifier).set(null),
                  child: Text(l10n.yearUnlockOff),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: MkTextField(
                    key: const ValueKey('year-unlock-reason'),
                    label: l10n.yearUnlockReason,
                    controller: _reason,
                  ),
                ),
                const SizedBox(width: MkSpacing.sm),
                MkButton(
                  key: const ValueKey('year-unlock-button'),
                  label: l10n.yearUnlockButton,
                  icon: Icons.lock_open,
                  variant: MkButtonVariant.secondary,
                  onPressed: () =>
                      ref.read(lockOverrideProvider.notifier).set(_reason.text),
                ),
              ],
            ),
    );
  }
}
