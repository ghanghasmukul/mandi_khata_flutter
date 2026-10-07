import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_labels.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The chart of accounts: every group with its accounts and balances; the
/// business adds, renames and switches off its own accounts
/// (`entries.reverse`). Needs `finance.view`.
class ChartScreen extends ConsumerStatefulWidget {
  const ChartScreen({super.key});

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  String _query = '';

  Future<void> _edit(Chart chart, {ChartEntry? account}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AccountDialog(chart: chart, account: account),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chart = ref.watch(chartProvider).value;
    final totals = ref.watch(accountTotalsProvider()).value ?? const {};
    final canEdit = ref.watch(canProvider(Permission.entriesReverse));
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(AccountRoutes.hub),
      },
      child: Scaffold(
        floatingActionButton: canEdit && chart != null
            ? FloatingActionButton.extended(
                key: const ValueKey('chart-add'),
                onPressed: () => _edit(chart),
                icon: const Icon(Icons.add),
                label: Text(l10n.chartAddAccount),
              )
            : null,
        body: Column(
          children: [
            MkTopBar(title: l10n.chartTitle),
            Padding(
              padding: const EdgeInsets.all(MkSpacing.md),
              child: MkTextField(
                key: const ValueKey('chart-search'),
                hint: l10n.chartSearch,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: chart == null
                  ? const Center(child: CircularProgressIndicator())
                  : _list(context, chart, totals, canEdit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    Chart chart,
    Map<String, AccountTotals> totals,
    bool canEdit,
  ) {
    final l10n = AppLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final children = <Widget>[];
    for (final g in chart.orderedGroups) {
      final accounts = [
        for (final a in chart.accounts)
          if (a.groupId == g.id &&
              (q.isEmpty ||
                  a.label.toLowerCase().contains(q) ||
                  g.name.toLowerCase().contains(q)))
            a,
      ];
      if (accounts.isEmpty && q.isNotEmpty) continue;
      final groupNet = accounts.fold(
        Money.zero,
        (s, a) => s + (totals[a.id] ?? AccountTotals.zero).net,
      );
      children.add(
        ListTile(
          key: ValueKey('chart-group-${g.code}'),
          dense: true,
          contentPadding: EdgeInsets.only(
            left: g.parentId == null ? MkSpacing.md : MkSpacing.xl,
            right: MkSpacing.md,
          ),
          title: Text(
            g.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          trailing: Text(l10n.drCr(groupNet), style: MkText.mono()),
        ),
      );
      for (final a in accounts) {
        final net = (totals[a.id] ?? AccountTotals.zero).net;
        children.add(
          ListTile(
            key: ValueKey('chart-account-${a.id}'),
            dense: true,
            contentPadding: const EdgeInsets.only(
              left: MkSpacing.xl * 2,
              right: MkSpacing.md,
            ),
            title: Text(a.label),
            subtitle: !a.isActive
                ? Text(l10n.chartOff)
                : !a.synced
                ? Text(l10n.chartNotSynced)
                : null,
            trailing: Text(l10n.drCr(net), style: MkText.mono()),
            onTap: canEdit && a.synced && (a.isOwn || a.isSystem)
                ? () => _edit(chart, account: a)
                : null,
          ),
        );
      }
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: children,
    );
  }
}

class _AccountDialog extends ConsumerStatefulWidget {
  const _AccountDialog({required this.chart, this.account});

  final Chart chart;
  final ChartEntry? account;

  @override
  ConsumerState<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends ConsumerState<_AccountDialog> {
  late final _name = TextEditingController(text: widget.account?.name ?? '');
  late String? _groupId = widget.account?.groupId;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  List<ChartGroup> get _allowedGroups => [
    for (final g in widget.chart.orderedGroups)
      if (!ChartRepository.lockedGroups.any(
        (locked) => widget.chart.groupWithin(g.id, locked),
      ))
        g,
  ];

  Future<void> _save({bool? isActive}) async {
    final l10n = AppLocalizations.of(context);
    final writer = ref.read(accountsWriterProvider);
    final a = widget.account;
    final groupId = _groupId;
    if (groupId == null) {
      setState(() => _error = l10n.chartProblemGroup);
      return;
    }
    final problem = a == null
        ? await writer.addAccount(_name.text, groupId)
        : await writer.updateAccount(
            a.id,
            name: _name.text,
            groupId: a.isOwn ? groupId : null,
            isActive: isActive,
          );
    if (!mounted) return;
    if (problem == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = l10n.accountProblem(problem));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final a = widget.account;
    final canMove = a == null || a.isOwn;
    return AlertDialog(
      title: Text(a == null ? l10n.chartAddAccount : l10n.chartEditAccount),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MkTextField(
              key: const ValueKey('account-name'),
              label: l10n.chartAccountName,
              controller: _name,
              autofocus: true,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: MkSpacing.md),
            DropdownButtonFormField<String>(
              key: const ValueKey('account-group'),
              initialValue: _groupId,
              decoration: InputDecoration(labelText: l10n.chartGroup),
              items: [
                for (final g
                    in canMove
                        ? _allowedGroups
                        : [widget.chart.groups[a.groupId]!])
                  DropdownMenuItem(value: g.id, child: Text(g.name)),
              ],
              onChanged: canMove ? (v) => setState(() => _groupId = v) : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: MkSpacing.sm),
              Text(
                _error!,
                key: const ValueKey('account-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (a != null && a.isOwn)
          TextButton(
            key: const ValueKey('account-toggle'),
            onPressed: () => _save(isActive: !a.isActive),
            child: Text(a.isActive ? l10n.chartSwitchOff : l10n.chartSwitchOn),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('account-save'),
          onPressed: _save,
          child: Text(l10n.voucherSave),
        ),
      ],
    );
  }
}
