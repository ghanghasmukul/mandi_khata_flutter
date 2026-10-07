import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/khata/domain/day_book.dart';
import 'package:mandi_khata_app/features/khata/presentation/entry_actions.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_entry_dialog.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_line.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_picker.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class KhataRoutes {
  static const dayBook = '/khata';
}

/// "All entries": every khata line of the business, newest first, with the
/// party's running baki. Filters: date range, party, type. The list is
/// paged from the local database, so 100k entries scroll smoothly.
class DayBookScreen extends ConsumerStatefulWidget {
  const DayBookScreen({super.key});

  @override
  ConsumerState<DayBookScreen> createState() => _DayBookScreenState();
}

class _DayBookScreenState extends ConsumerState<DayBookScreen> {
  LedgerFilter _filter = const LedgerFilter();
  Party? _party;

  Future<void> _addEntry() => showKhataEntryDialog(context);

  void _set(LedgerFilter f) => setState(() => _filter = f);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = ref.watch(canProvider(Permission.entriesReverse));
    final summary = ref.watch(dayBookSummaryProvider(_filter)).value;

    return CallbackShortcuts(
      bindings: {
        if (canAdd) ...primaryShortcut(LogicalKeyboardKey.keyN, _addEntry),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(GateRoutes.home),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          floatingActionButton: canAdd
              ? FloatingActionButton.extended(
                  onPressed: _addEntry,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.khataEntryTitle),
                )
              : null,
          body: Column(
            children: [
              MkTopBar(title: l10n.khataDayBookTitle),
              _Filters(
                filter: _filter,
                party: _party,
                onChanged: _set,
                onParty: (p) {
                  _party = p;
                  _set(_filter.copyWith(partyId: () => p?.id));
                },
              ),
              if (summary != null) _SummaryBar(summary: summary),
              const KhataHeader(showParty: true),
              const Divider(height: 1),
              Expanded(
                child: summary == null
                    ? const Center(child: CircularProgressIndicator())
                    : summary.count == 0
                    ? MkEmptyState(
                        icon: Icons.menu_book_outlined,
                        title: l10n.khataDayBookEmpty,
                      )
                    : _EntryList(filter: _filter, count: summary.count),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.filter,
    required this.party,
    required this.onChanged,
    required this.onParty,
  });

  final LedgerFilter filter;
  final Party? party;
  final ValueChanged<LedgerFilter> onChanged;
  final ValueChanged<Party?> onParty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(MkSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DateRangeChips(
              from: filter.from,
              to: filter.to,
              keyPrefix: 'khata',
              onChanged: (f, t) =>
                  onChanged(filter.copyWith(from: () => f, to: () => t)),
            ),
          ),
          const SizedBox(height: MkSpacing.md),
          Wrap(
            spacing: MkSpacing.md,
            runSpacing: MkSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 320,
                child: PartyPicker(
                  role: null,
                  selected: party,
                  onSelected: onParty,
                  hint: l10n.khataFilterParty,
                ),
              ),
              DropdownButton<RefType?>(
                key: const ValueKey('khata-type'),
                value: filter.refType,
                hint: Text(l10n.khataFilterAllTypes),
                items: [
                  DropdownMenuItem(child: Text(l10n.khataFilterAllTypes)),
                  for (final t in RefType.values)
                    DropdownMenuItem(
                      value: t,
                      child: Text(l10n.refTypeName(t)),
                    ),
                ],
                onChanged: (t) => onChanged(filter.copyWith(refType: () => t)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.summary});

  final DayBookSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MkSpacing.lg),
      child: Wrap(
        spacing: MkSpacing.lg,
        runSpacing: MkSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            l10n.khataEntriesCount(summary.count),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${l10n.khataColUdhaar}: '),
                WidgetSpan(
                  child: MkMoneyText(summary.udhaar, tone: MkMoneyTone.udhaar),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${l10n.khataColJama}: '),
                WidgetSpan(
                  child: MkMoneyText(summary.jama, tone: MkMoneyTone.jama),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Builds only the rows on screen; each page of [dayBookPageSize] rows is
/// loaded (and watched) on demand.
class _EntryList extends ConsumerWidget {
  const _EntryList({required this.filter, required this.count});

  final LedgerFilter filter;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: count,
      itemExtent: khataLineHeight,
      padding: const EdgeInsets.only(bottom: 88),
      itemBuilder: (context, i) {
        final page = i ~/ dayBookPageSize;
        final rows = ref.watch(dayBookPageProvider(filter, page)).value;
        final index = i % dayBookPageSize;
        if (rows == null || index >= rows.length) {
          return const SizedBox.shrink();
        }
        return _Row(row: rows[index]);
      },
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.row});

  final DayBookRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KhataLine(
      entry: row.entry,
      balance: row.balance,
      struck: row.isStruck,
      partyName: row.partyName,
      onPartyTap: () => context.go(PartyRoutes.detail(row.entry.partyId)),
      trailing: EntryActionsMenu(
        entry: row.entry,
        reversed: row.reversedById != null,
        partyName: row.partyName,
      ),
    );
  }
}
