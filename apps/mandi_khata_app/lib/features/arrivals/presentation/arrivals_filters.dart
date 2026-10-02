import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_providers.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mk_ui/mk_ui.dart';

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

  void _setRange(LedgerDate? from, LedgerDate? to) =>
      onChanged(filter.copyWith(from: () => from, to: () => to));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final crops = ref.watch(cropListProvider(includeInactive: true)).value;

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
                DateRangeChips(
                  from: filter.from,
                  to: filter.to,
                  keyPrefix: 'lots',
                  onChanged: _setRange,
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
