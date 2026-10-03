import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/features/audit/domain/audit_entry.dart';
import 'package:mandi_khata_app/features/audit/presentation/audit_entry_card.dart';
import 'package:mandi_khata_app/features/audit/presentation/audit_labels.dart';
import 'package:mandi_khata_app/features/audit/presentation/audit_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class AuditRoutes {
  static const list = '/audit';
}

/// The audit log (owner): a timeline of who did what, with money edits and
/// reversals highlighted; filter by person, record type and date.
class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  static const _page = 50;

  AuditFilter _filter = const AuditFilter();
  int _limit = _page;

  void _setFilter(AuditFilter f) => setState(() {
    _filter = f;
    _limit = _page;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allowed = ref.watch(canProvider(Permission.auditView));
    final entries = allowed
        ? ref.watch(auditEntriesProvider(_filter, _limit)).value
        : null;

    Widget body() {
      if (!allowed) {
        return MkEmptyState(
          icon: Icons.lock_outline,
          title: l10n.auditNoAccess,
        );
      }
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              _Filters(filter: _filter, onChanged: _setFilter),
              Expanded(child: _list(l10n, entries)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.auditTitle,
            actions: [
              const SyncStatusChip(),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => context.go(GateRoutes.home),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Expanded(child: body()),
        ],
      ),
    );
  }

  Widget _list(AppLocalizations l10n, List<AuditEntry>? entries) {
    if (entries == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (entries.isEmpty) {
      return MkEmptyState(
        icon: Icons.history_toggle_off,
        title: l10n.auditEmpty,
      );
    }
    // A full page means there may be more.
    final more = entries.length >= _limit;
    return ListView.builder(
      key: const ValueKey('audit-list'),
      padding: const EdgeInsets.fromLTRB(
        MkSpacing.lg,
        MkSpacing.sm,
        MkSpacing.lg,
        MkSpacing.xxl,
      ),
      itemCount: entries.length + (more ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == entries.length) {
          return Center(
            child: MkButton(
              key: const ValueKey('audit-more'),
              label: l10n.auditShowMore,
              variant: MkButtonVariant.secondary,
              onPressed: () => setState(() => _limit += _page),
            ),
          );
        }
        return AuditEntryCard(entry: entries[i]);
      },
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.filter, required this.onChanged});

  final AuditFilter filter;
  final ValueChanged<AuditFilter> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final writers = ref.watch(auditWritersProvider).value ?? const [];
    final userValue = writers.any((w) => w.id == filter.userId)
        ? filter.userId
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MkSpacing.lg,
        MkSpacing.md,
        MkSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MkSpacing.md,
            runSpacing: MkSpacing.sm,
            children: [
              _Dropdown<String?>(
                fieldKey: const ValueKey('audit-filter-user'),
                label: l10n.auditFilterUser,
                value: userValue,
                items: [
                  DropdownMenuItem(child: Text(l10n.auditAllUsers)),
                  for (final w in writers)
                    DropdownMenuItem(value: w.id, child: Text(w.name)),
                ],
                onChanged: (v) => onChanged(filter.copyWith(userId: () => v)),
              ),
              _Dropdown<String?>(
                fieldKey: const ValueKey('audit-filter-table'),
                label: l10n.auditFilterTable,
                value: filter.table,
                items: [
                  DropdownMenuItem(child: Text(l10n.auditAllTables)),
                  for (final t in AuditRules.knownTables)
                    DropdownMenuItem(value: t, child: Text(l10n.auditTable(t))),
                ],
                onChanged: (v) => onChanged(filter.copyWith(table: () => v)),
              ),
            ],
          ),
          const SizedBox(height: MkSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DateRangeChips(
              keyPrefix: 'audit',
              from: filter.from,
              to: filter.to,
              onChanged: (from, to) =>
                  onChanged(filter.copyWith(range: (from: from, to: to))),
            ),
          ),
          SwitchListTile(
            key: const ValueKey('audit-only-money'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.auditOnlyMoney),
            value: filter.onlyHighlighted,
            onChanged: (v) => onChanged(filter.copyWith(onlyHighlighted: v)),
          ),
        ],
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final Key fieldKey;
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: DropdownButtonFormField<T>(
      key: fieldKey,
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
    ),
  );
}
