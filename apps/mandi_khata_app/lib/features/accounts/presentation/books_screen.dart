import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart' show Permission;
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_backfill.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The books (double-entry journal) of the business: whether every document
/// has its journal entry, the button that writes the missing ones for
/// documents older than the books, and the checks that the books tally with
/// the khata and the cash / bank book. Owner / accountant (`entries.reverse`).
class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  bool _running = false;
  int _done = 0;
  int _total = 0;
  BackfillDone? _result;

  Future<void> _run() async {
    final ctx = ref.read(writeContextProvider);
    bool can(Permission p) => ref.read(canProvider(p));
    if (ctx == null) return;
    final backfill = await ref.read(journalBackfillProvider.future);
    setState(() {
      _running = true;
      _done = 0;
      _total = 0;
      _result = null;
    });
    final result = await backfill.run(
      ctx,
      can: can,
      onProgress: (done, total) {
        if (mounted) {
          setState(() {
            _done = done;
            _total = total;
          });
        }
      },
    );
    if (!mounted) return;
    setState(() {
      _running = false;
      _result = result is BackfillDone ? result : null;
    });
    ref
      ..invalidate(booksStatusProvider)
      ..invalidate(booksChecksProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canRun = ref.watch(canProvider(Permission.entriesReverse));
    final status = ref.watch(booksStatusProvider).value;
    final checks = ref.watch(booksChecksProvider).value;
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
              MkTopBar(title: l10n.booksTitle),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(MkSpacing.lg),
                  children: [
                    Text(
                      l10n.booksIntro,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: MkSpacing.lg),
                    if (!canRun)
                      Text(
                        l10n.booksNotPermitted,
                        key: const ValueKey('books-not-permitted'),
                      )
                    else ...[
                      _StatusCard(
                        status: status,
                        running: _running,
                        done: _done,
                        total: _total,
                        onRun: _run,
                      ),
                      if (_result != null) ...[
                        const SizedBox(height: MkSpacing.md),
                        _ResultCard(result: _result!),
                      ],
                      const SizedBox(height: MkSpacing.lg),
                      _ChecksCard(
                        checks: checks,
                        onRecheck: () => ref.invalidate(booksChecksProvider),
                      ),
                    ],
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.running,
    required this.done,
    required this.total,
    required this.onRun,
  });

  final BackfillStatus? status;
  final bool running;
  final int done;
  final int total;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = status;
    return MkCard(
      key: const ValueKey('books-status'),
      title: l10n.booksStatusTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s == null)
            const LinearProgressIndicator()
          else if (s.isDone)
            Text(l10n.booksAllDone, key: const ValueKey('books-all-done'))
          else ...[
            Text(
              l10n.booksMissing(s.total),
              key: const ValueKey('books-missing'),
            ),
            const SizedBox(height: MkSpacing.xs),
            Text(
              l10n.booksMissingDetail(
                s.lots,
                s.payments,
                s.interest,
                s.waivers,
                s.entries,
                s.reversals,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: MkSpacing.md),
            if (running) ...[
              LinearProgressIndicator(
                value: total == 0 ? null : done / total,
                key: const ValueKey('books-progress'),
              ),
              const SizedBox(height: MkSpacing.xs),
              Text(l10n.booksRunning(done, total)),
            ] else
              MkButton(
                key: const ValueKey('books-run'),
                label: l10n.booksRun,
                icon: Icons.auto_fix_high,
                onPressed: onRun,
              ),
          ],
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final BackfillDone result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkCard(
      key: const ValueKey('books-result'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.booksRunDone(result.written)),
          if (result.problems.isNotEmpty) ...[
            const SizedBox(height: MkSpacing.sm),
            Text(
              l10n.booksRunProblems,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final p in result.problems) Text('• $p'),
          ],
        ],
      ),
    );
  }
}

class _ChecksCard extends StatelessWidget {
  const _ChecksCard({required this.checks, required this.onRecheck});

  final BooksChecks? checks;
  final VoidCallback onRecheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = checks;
    Widget row(String key, String good, String bad, {required bool ok}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            key: ValueKey(key),
            children: [
              Icon(
                ok ? Icons.check_circle_outline : Icons.error_outline,
                size: 18,
                color: ok
                    ? MkTokens.of(context).jama
                    : MkTokens.of(context).udhaar,
              ),
              const SizedBox(width: MkSpacing.sm),
              Expanded(child: Text(ok ? good : bad)),
            ],
          ),
        );
    return MkCard(
      key: const ValueKey('books-checks'),
      title: l10n.booksChecksTitle,
      trailing: TextButton(
        key: const ValueKey('books-recheck'),
        onPressed: onRecheck,
        child: Text(l10n.booksRecheck),
      ),
      child: c == null
          ? const LinearProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                row(
                  'check-balanced',
                  l10n.booksCheckBalanced,
                  l10n.booksCheckBalancedBad(c.unbalanced),
                  ok: c.unbalanced == 0,
                ),
                row(
                  'check-parties',
                  l10n.booksCheckParties,
                  l10n.booksCheckPartiesBad(c.partyDifferences),
                  ok: c.partyDifferences == 0,
                ),
                row(
                  'check-books',
                  l10n.booksCheckBooks,
                  l10n.booksCheckBooksBad(c.bookDifferences),
                  ok: c.bookDifferences == 0,
                ),
              ],
            ),
    );
  }
}
