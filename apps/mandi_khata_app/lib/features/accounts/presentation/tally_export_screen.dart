import 'dart:async';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/accounts/data/tally_export_repository.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statement_page.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Export a period to Tally Prime: pick the period, check the group
/// mapping (saved for the business when the member may change settings),
/// read the checks, save the zip. Needs `finance.view`.
class TallyExportScreen extends ConsumerStatefulWidget {
  const TallyExportScreen({super.key});

  @override
  ConsumerState<TallyExportScreen> createState() => _TallyState();
}

class _TallyState extends ConsumerState<TallyExportScreen> {
  late LedgerDate _from;
  late LedgerDate _to;
  final _overrides = <String, String>{};
  TallyExportPlan? _plan;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final today = LedgerDate.fromDateTime(DateTime.now());
    _from = LedgerDate(today.year, today.month, 1);
    _to = today;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Map<String, String> get _map => {
    ...TallyExportRepository.groupMap(
      ref.read(settingProvider('tally.group_map', businessTarget))?.value,
    ),
    ..._overrides,
  };

  Future<void> _load() async {
    final tenantId = ref.read(activeTenantProvider);
    if (tenantId == null) return;
    setState(() => _loading = true);
    final db = await ref.read(powerSyncDatabaseProvider.future);
    final plan = await TallyExportRepository(db).plan(
      tenantId,
      company: ref.read(activeMembershipProvider)?.tenantName ?? '',
      from: _from,
      to: _to,
      groupMap: _map,
    );
    if (mounted) {
      setState(() {
        _plan = plan;
        _loading = false;
      });
    }
  }

  Future<void> _setGroup(String code, String tallyGroup) async {
    _overrides[code] = tallyGroup;
    if (ref.read(canProvider(Permission.settingsManage))) {
      final saved = ref
          .read(settingProvider('tally.group_map', businessTarget))
          ?.value;
      await ref
          .read(settingsWriterProvider)
          .write(
            scope: SettingScope.tenant,
            key: 'tally.group_map',
            value: {
              if (saved is Map) ...saved.cast<String, Object?>(),
              code: tallyGroup,
            },
          );
    }
    await _load();
  }

  String _issue(AppLocalizations l10n, TallyIssue i) => switch (i.kind) {
    TallyIssueKind.unmappedGroup => l10n.tallyIssueUnmapped(
      i.subject,
      i.detail ?? '',
    ),
    TallyIssueKind.badName => l10n.tallyIssueBadName(i.subject),
    TallyIssueKind.renamed => l10n.tallyIssueRenamed(i.subject, i.detail ?? ''),
    TallyIssueKind.unbalanced => l10n.tallyIssueUnbalanced(i.subject),
    TallyIssueKind.unknownLedger => l10n.tallyIssueUnknown(i.subject),
  };

  Future<void> _export(AppLocalizations l10n, TallyExportPlan plan) async {
    final messenger = ScaffoldMessenger.of(context);
    final report = [for (final i in plan.result.issues) _issue(l10n, i)];
    final saved = await FileSaver.instance.saveAs(
      name: 'tally-$_from-$_to',
      bytes: TallyExportRepository.zip(plan.result, report),
      fileExtension: 'zip',
      mimeType: MimeType.zip,
    );
    if (saved != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reportExportSaved(saved))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allowed = ref.watch(canProvider(Permission.financeView));
    // Refresh when the journal changes.
    ref.listen(journalTickProvider, (_, _) => unawaited(_load()));
    final plan = _plan;
    final today = LedgerDate.fromDateTime(DateTime.now());
    final lastMonthEnd = LedgerDate(today.year, today.month, 1).addDays(-1);
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
              MkTopBar(title: l10n.tallyTitle),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(MkSpacing.lg),
                  children: [
                    Text(l10n.tallyIntro),
                    const SizedBox(height: MkSpacing.md),
                    Wrap(
                      spacing: MkSpacing.sm,
                      runSpacing: MkSpacing.sm,
                      children: [
                        ActionChip(
                          key: const ValueKey('tally-this-month'),
                          label: Text(l10n.tallyThisMonth),
                          onPressed: () {
                            _from = LedgerDate(today.year, today.month, 1);
                            _to = today;
                            unawaited(_load());
                          },
                        ),
                        ActionChip(
                          key: const ValueKey('tally-last-month'),
                          label: Text(l10n.tallyLastMonth),
                          onPressed: () {
                            _from = LedgerDate(
                              lastMonthEnd.year,
                              lastMonthEnd.month,
                              1,
                            );
                            _to = lastMonthEnd;
                            unawaited(_load());
                          },
                        ),
                        PeriodChips(
                          from: _from,
                          to: _to,
                          onChanged: (f, t) {
                            _from = f;
                            _to = t;
                            unawaited(_load());
                          },
                        ),
                      ],
                    ),
                    if (_loading) const LinearProgressIndicator(),
                    if (plan != null) ..._body(l10n, plan, allowed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _body(
    AppLocalizations l10n,
    TallyExportPlan plan,
    bool allowed,
  ) {
    final r = plan.result;
    return [
      const SizedBox(height: MkSpacing.md),
      Text(
        l10n.tallyCounts(r.ledgerCount, r.voucherCount),
        key: const ValueKey('tally-counts'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: MkSpacing.md),
      MkCard(
        title: l10n.tallyMapping,
        child: Column(
          children: [
            for (final g in plan.groups)
              Row(
                key: ValueKey('tally-group-${g.code}'),
                children: [
                  Expanded(
                    child: Text(
                      '${g.name} · ${l10n.tallyGroupLedgers(g.ledgers)}',
                    ),
                  ),
                  DropdownButton<String>(
                    value: tallyGroups.contains(g.tallyGroup)
                        ? g.tallyGroup
                        : null,
                    hint: Text(l10n.tallyGroupUnmapped),
                    items: [
                      for (final t in tallyGroups)
                        DropdownMenuItem(value: t, child: Text(t)),
                    ],
                    onChanged: (v) {
                      if (v != null) unawaited(_setGroup(g.code, v));
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
      const SizedBox(height: MkSpacing.md),
      MkCard(
        key: const ValueKey('tally-issues'),
        title: l10n.tallyIssuesTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r.issues.isEmpty) Text(l10n.tallyNoIssues),
            for (final i in r.issues)
              Text(
                '• ${_issue(l10n, i)}',
                style: TextStyle(
                  color: i.isWarning
                      ? null
                      : Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: MkSpacing.md),
      Row(
        children: [
          MkButton(
            key: const ValueKey('tally-export'),
            label: l10n.tallyExport,
            icon: Icons.download,
            onPressed: allowed && r.isClean && r.voucherCount > 0
                ? () => _export(l10n, plan)
                : null,
          ),
          const SizedBox(width: MkSpacing.md),
          if (!r.isClean) Text(l10n.tallyExportBlocked),
          if (!allowed) Text(l10n.reportExportLocked),
        ],
      ),
    ];
  }
}
