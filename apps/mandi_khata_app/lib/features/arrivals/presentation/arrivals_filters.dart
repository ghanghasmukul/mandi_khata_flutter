import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_providers.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

enum _DateRange { today, yesterday, week, all, custom }

/// Search (farmer / lot no), date range, crop and status for the arrivals
/// list.
class ArrivalsFilterBar extends ConsumerWidget {
  const ArrivalsFilterBar({
    required this.filter,
    required this.onChanged,
    super.key,
    this.searchFocus,
  });

  final LotFilter filter;
  final ValueChanged<LotFilter> onChanged;
  final FocusNode? searchFocus;

  static LedgerDate _day(int daysAgo) =>
      LedgerDate.fromDateTime(DateTime.now().subtract(Duration(days: daysAgo)));

  _DateRange get _range {
    final (from, to) = (filter.from, filter.to);
    if (from == null && to == null) return _DateRange.all;
    if (from == _day(0) && to == _day(0)) return _DateRange.today;
    if (from == _day(1) && to == _day(1)) return _DateRange.yesterday;
    if (from == _day(6) && to == _day(0)) return _DateRange.week;
    return _DateRange.custom;
  }

  void _setRange(LedgerDate? from, LedgerDate? to) =>
      onChanged(filter.copyWith(from: () => from, to: () => to));

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    DateTime asDate(LedgerDate d) => DateTime(d.year, d.month, d.day);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: filter.from == null || filter.to == null
          ? null
          : DateTimeRange(start: asDate(filter.from!), end: asDate(filter.to!)),
    );
    if (picked != null) {
      _setRange(
        LedgerDate.fromDateTime(picked.start),
        LedgerDate.fromDateTime(picked.end),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final crops = ref.watch(cropListProvider(includeInactive: true)).value;
    final range = _range;

    Widget chip(_DateRange r, String label, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(right: MkSpacing.sm),
      child: ChoiceChip(
        key: ValueKey('lots-range-${r.name}'),
        label: Text(label),
        selected: range == r,
        onSelected: (_) => onTap(),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(MkSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MkTextField(
            key: const ValueKey('lots-search'),
            focusNode: searchFocus,
            hint: l10n.arrivalsSearchHint,
            prefix: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.search, size: 20),
            ),
            onChanged: (v) => onChanged(filter.copyWith(query: v)),
          ),
          const SizedBox(height: MkSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                chip(
                  _DateRange.today,
                  l10n.rangeToday,
                  () => _setRange(_day(0), _day(0)),
                ),
                chip(
                  _DateRange.yesterday,
                  l10n.rangeYesterday,
                  () => _setRange(_day(1), _day(1)),
                ),
                chip(
                  _DateRange.week,
                  l10n.rangeWeek,
                  () => _setRange(_day(6), _day(0)),
                ),
                chip(
                  _DateRange.all,
                  l10n.rangeAll,
                  () => _setRange(null, null),
                ),
                chip(
                  _DateRange.custom,
                  range == _DateRange.custom
                      ? '${AppFormat.ledgerDate(context, filter.from!)} – '
                            '${AppFormat.ledgerDate(context, filter.to!)}'
                      : l10n.rangeCustom,
                  () => _pickRange(context),
                ),
                const SizedBox(width: MkSpacing.md),
                DropdownButton<String?>(
                  key: const ValueKey('lots-crop'),
                  value: filter.cropId,
                  hint: Text(l10n.arrivalsAllCrops),
                  items: [
                    DropdownMenuItem(child: Text(l10n.arrivalsAllCrops)),
                    for (final c in crops ?? const <Crop>[])
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nameIn(lang)),
                      ),
                  ],
                  onChanged: (id) =>
                      onChanged(filter.copyWith(cropId: () => id)),
                ),
                const SizedBox(width: MkSpacing.md),
                DropdownButton<LotStatus?>(
                  key: const ValueKey('lots-status'),
                  value: filter.status,
                  hint: Text(l10n.arrivalsAllStatuses),
                  items: [
                    DropdownMenuItem(child: Text(l10n.arrivalsAllStatuses)),
                    for (final s in LotStatus.values)
                      DropdownMenuItem(
                        value: s,
                        child: Text(l10n.lotStatusName(s)),
                      ),
                  ],
                  onChanged: (s) => onChanged(filter.copyWith(status: () => s)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
