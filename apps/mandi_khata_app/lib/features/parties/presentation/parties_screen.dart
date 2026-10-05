import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_line.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class PartyRoutes {
  static const list = '/parties';
  static const create = '/parties/new';
  static String detail(String id) => '/parties/$id';
  static String edit(String id) => '/parties/$id/edit';
}

/// All parties of the business: instant search and role filter, straight
/// from the local database. Ctrl/⌘+F searches, Ctrl/⌘+N adds a party.
class PartiesScreen extends ConsumerStatefulWidget {
  const PartiesScreen({super.key});

  @override
  ConsumerState<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends ConsumerState<PartiesScreen> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  PartyRole? _role;

  /// Shown while the next query loads, so typing never flashes empty.
  List<Party>? _last;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _add() => context.go(PartyRoutes.create);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = ref.watch(canProvider(Permission.partiesManage));
    final canImport =
        canAdd && ref.watch(canProvider(Permission.entriesReverse));
    final canInterest = ref.watch(canProvider(Permission.loansManage));
    final parties = ref.watch(partyListProvider(_query, _role)).value ?? _last;
    _last = parties;

    return CallbackShortcuts(
      bindings: {
        ...primaryShortcut(LogicalKeyboardKey.keyF, _searchFocus.requestFocus),
        if (canAdd) ...primaryShortcut(LogicalKeyboardKey.keyN, _add),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          floatingActionButton: canAdd
              ? FloatingActionButton.extended(
                  onPressed: _add,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(l10n.partiesAdd),
                )
              : null,
          body: Column(
            children: [
              MkTopBar(
                title: l10n.partiesTitle,
                actions: [
                  const SyncStatusChip(),
                  if (canImport)
                    IconButton(
                      key: const ValueKey('parties-import'),
                      tooltip: l10n.obTitle,
                      onPressed: () => context.go('${PartyRoutes.list}/import'),
                      icon: const Icon(Icons.upload_file_outlined),
                    ),
                  if (canInterest)
                    IconButton(
                      key: const ValueKey('parties-bulk-interest'),
                      tooltip: l10n.byajBulkOpen,
                      onPressed: () =>
                          context.go('${PartyRoutes.list}/interest'),
                      icon: const Icon(Icons.percent),
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
                padding: const EdgeInsets.fromLTRB(
                  MkSpacing.lg,
                  MkSpacing.lg,
                  MkSpacing.lg,
                  0,
                ),
                child: MkTextField(
                  key: const ValueKey('parties-search'),
                  controller: _search,
                  focusNode: _searchFocus,
                  hint: l10n.partiesSearchHint,
                  prefix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.search, size: 20),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              _RoleChips(
                selected: _role,
                onSelected: (r) => setState(() => _role = r),
              ),
              Expanded(child: _body(l10n, parties, canAdd)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n, List<Party>? parties, bool canAdd) {
    if (parties == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (parties.isEmpty) {
      final searching = _query.trim().isNotEmpty || _role != null;
      return MkEmptyState(
        icon: Icons.groups_outlined,
        title: searching ? l10n.partiesNoMatch : l10n.partiesEmptyTitle,
        message: searching ? null : l10n.partiesEmptyBody,
        action: searching || !canAdd
            ? null
            : MkButton(
                label: l10n.partiesAdd,
                icon: Icons.person_add_alt_1,
                onPressed: _add,
              ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MkSpacing.lg),
          child: Text(
            l10n.partiesCount(parties.length),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          // Fixed row height keeps 10k rows smooth: only visible rows build.
          child: ListView.builder(
            itemCount: parties.length,
            itemExtent: 72,
            padding: const EdgeInsets.only(bottom: 88),
            itemBuilder: (context, i) => PartyTile(party: parties[i]),
          ),
        ),
      ],
    );
  }
}

class _RoleChips extends StatelessWidget {
  const _RoleChips({required this.selected, required this.onSelected});

  final PartyRole? selected;
  final ValueChanged<PartyRole?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget chip(PartyRole? role, String label) => Padding(
      padding: const EdgeInsets.only(right: MkSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected == role,
        onSelected: (_) => onSelected(role),
      ),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(MkSpacing.lg),
      child: Row(
        children: [
          chip(null, l10n.partiesAll),
          for (final r in PartyRole.values) chip(r, l10n.partyRole(r)),
        ],
      ),
    );
  }
}

/// One row of the party list.
class PartyTile extends ConsumerWidget {
  const PartyTile({required this.party, super.key});

  final Party party;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only the ledger knows a party's balance (live, this business).
    final balance = ref.watch(
      partyBalancesProvider.select((b) => b.value?[party.id]),
    );
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final details = [
      party.code,
      ?party.village,
      if (party.mobile != null) party.mobile!,
    ].join(' · ');
    return ListTile(
      onTap: () => context.go(PartyRoutes.detail(party.id)),
      leading: CircleAvatar(
        child: Text(party.name.characters.first.toUpperCase()),
      ),
      title: Text(
        l10n.partyFullName(party),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        details,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (balance != null)
            KhataBalanceChip(
              balance: balance,
              isFarmer: party.roles.contains(PartyRole.farmer),
            ),
          if (party.roles.isNotEmpty)
            MkRoleChip(
              label: [
                for (final r in PartyRole.values)
                  if (party.roles.contains(r)) l10n.partyRole(r),
              ].join(' · '),
            ),
        ],
      ),
    );
  }
}
