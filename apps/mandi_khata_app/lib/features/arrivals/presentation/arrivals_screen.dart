import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_filters.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class ArrivalRoutes {
  static const list = '/arrivals';
  static const create = '/arrivals/new';
  static String detail(String id) => '/arrivals/$id';
  static String edit(String id) => '/arrivals/$id/edit';

  /// A new lot pre-filled from [id] (after reversing a wrong one).
  static String copy(String id) => '/arrivals/new?from=$id';
}

/// Arrivals (lots): today's by default, filtered by date, crop, status and
/// farmer / lot number, with a totals row. Ctrl/⌘+N adds a lot,
/// Ctrl/⌘+F searches.
class ArrivalsScreen extends ConsumerStatefulWidget {
  const ArrivalsScreen({super.key});

  @override
  ConsumerState<ArrivalsScreen> createState() => _ArrivalsScreenState();
}

class _ArrivalsScreenState extends ConsumerState<ArrivalsScreen> {
  final _searchFocus = FocusNode();
  LotFilter _filter = LotFilter(
    from: LedgerDate.fromDateTime(DateTime.now()),
    to: LedgerDate.fromDateTime(DateTime.now()),
  );

  /// Shown while the next query loads, so filtering never flashes empty.
  List<Lot>? _last;

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  void _add() => context.go(ArrivalRoutes.create);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = ref.watch(canProvider(Permission.arrivalsManage));
    final lots = ref.watch(lotListProvider(_filter)).value ?? _last;
    _last = lots;
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
                  icon: const Icon(Icons.add),
                  label: Text(l10n.lotNewTitle),
                )
              : null,
          body: Column(
            children: [
              MkTopBar(
                title: l10n.arrivalsTitle,
                actions: [
                  const SyncStatusChip(),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => context.go(GateRoutes.home),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              ArrivalsFilterBar(
                filter: _filter,
                searchFocus: _searchFocus,
                onChanged: (f) => setState(() => _filter = f),
              ),
              Expanded(child: _body(l10n, lots, canAdd)),
              if (lots != null && lots.isNotEmpty)
                _TotalsBar(totals: LotTotals.of(lots)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n, List<Lot>? lots, bool canAdd) {
    if (lots == null) return const Center(child: CircularProgressIndicator());
    if (lots.isEmpty) {
      return MkEmptyState(
        icon: Icons.agriculture_outlined,
        title: l10n.arrivalsEmpty,
        action: canAdd
            ? MkButton(
                label: l10n.lotNewTitle,
                icon: Icons.add,
                onPressed: _add,
              )
            : null,
      );
    }
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth < MkBreakpoints.rail
          ? ListView.builder(
              itemCount: lots.length,
              padding: const EdgeInsets.only(bottom: 88),
              itemBuilder: (context, i) => _LotTile(lot: lots[i]),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(
                MkSpacing.lg,
                0,
                MkSpacing.lg,
                MkSpacing.lg,
              ),
              child: _LotTable(lots: lots),
            ),
    );
  }
}

class _LotTable extends StatelessWidget {
  const _LotTable({required this.lots});

  final List<Lot> lots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    Widget money(Money? m) => m == null ? const Text('—') : MkMoneyText(m);
    return MkDataTable<Lot>(
      minWidth: 900,
      rows: lots,
      onRowTap: (l) => context.go(ArrivalRoutes.detail(l.id)),
      columns: [
        MkColumn(
          label: l10n.lotNo,
          flex: 3,
          cell: (l) => Text(l.lotNo, style: MkText.mono()),
          sortKey: (l) => l.lotNo,
        ),
        MkColumn(
          label: l10n.lotDate,
          flex: 3,
          cell: (l) => Text(AppFormat.ledgerDate(context, l.entryDate)),
          sortKey: (l) => l.entryDate,
        ),
        MkColumn(
          label: l10n.lotFarmer,
          flex: 5,
          cell: (l) => Text(l.farmerName, overflow: TextOverflow.ellipsis),
          sortKey: (l) => l.farmerName.toLowerCase(),
        ),
        MkColumn(
          label: l10n.lotCrop,
          flex: 3,
          cell: (l) =>
              Text(l.cropNameIn(lang), overflow: TextOverflow.ellipsis),
        ),
        MkColumn(
          label: l10n.lotBags,
          flex: 2,
          numeric: true,
          cell: (l) => Text('${l.bags}'),
          sortKey: (l) => l.bags,
        ),
        MkColumn(
          label: l10n.lotQtl,
          flex: 2,
          numeric: true,
          cell: (l) => Text(
            l.qtlMilli == null ? '—' : Quintals.format(l.qtlMilli!),
            style: MkText.mono(),
          ),
          sortKey: (l) => l.qtlMilli ?? 0,
        ),
        MkColumn(
          label: l10n.lotRate,
          flex: 3,
          numeric: true,
          cell: (l) => money(l.rate),
          sortKey: (l) => l.rate?.paise ?? 0,
        ),
        MkColumn(
          label: l10n.mandiNetToFarmer,
          flex: 3,
          numeric: true,
          cell: (l) => money(l.netToFarmer),
          sortKey: (l) => l.netToFarmer?.paise ?? 0,
        ),
        MkColumn(
          label: l10n.lotStatusLabel,
          flex: 3,
          cell: (l) => LotStatusChip(lot: l),
        ),
      ],
    );
  }
}

class _LotTile extends StatelessWidget {
  const _LotTile({required this.lot});

  final Lot lot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final weight = lot.qtlMilli == null
        ? l10n.lotBagsCount(lot.bags)
        : '${l10n.lotBagsCount(lot.bags)} · ${Quintals.format(lot.qtlMilli!)} '
              '${l10n.lotQtlUnit}';
    return ListTile(
      onTap: () => context.go(ArrivalRoutes.detail(lot.id)),
      title: Text(
        '${lot.farmerName} · ${lot.cropNameIn(lang)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${lot.lotNo} · $weight'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (lot.netToFarmer != null) MkMoneyText(lot.netToFarmer!),
          LotStatusChip(lot: lot),
        ],
      ),
    );
  }
}

/// Lot status as a small chip; cancelled and reversed lots are flagged.
class LotStatusChip extends StatelessWidget {
  const LotStatusChip({required this.lot, super.key});

  final Lot lot;

  @override
  Widget build(BuildContext context) => MkRoleChip(
    label: AppLocalizations.of(context).lotStatus(lot),
    warning: lot.status == LotStatus.reversed,
  );
}

class _TotalsBar extends StatelessWidget {
  const _TotalsBar({required this.totals});

  final LotTotals totals;

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
      key: const ValueKey('lots-totals'),
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
            item(l10n.lotsTotalCount, Text('${totals.count}')),
            item(l10n.lotBags, Text('${totals.bags}')),
            item(
              l10n.lotQtl,
              Text(Quintals.format(totals.qtlMilli), style: MkText.mono()),
            ),
            item(l10n.mandiGross, MkMoneyText(totals.gross)),
            item(l10n.mandiNetToFarmer, MkMoneyText(totals.netToFarmer)),
          ],
        ),
      ),
    );
  }
}
