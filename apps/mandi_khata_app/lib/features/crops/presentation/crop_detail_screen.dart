import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crop_form_dialog.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_screen.dart';
import 'package:mandi_khata_app/features/crops/presentation/mandi_breakdown_view.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_tile.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Bags used for the example calculation on the crop screen.
const exampleBags = 20;

/// Rate for the example when the crop has no MSP / usual rate. Display
/// only: a lot's rate is always entered per lot.
const exampleFallbackRate = Money.rupees(2000);

/// One crop: its names and reference rate, a per-crop value for every
/// `mandi.*` setting (business level, showing what it inherits), and a live
/// example of the calculation with those values.
class CropDetailScreen extends ConsumerWidget {
  const CropDetailScreen({required this.cropId, super.key});

  final String cropId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final crop = ref.watch(cropProvider(cropId));
    final lang = Localizations.localeOf(context).languageCode;

    final body = switch (crop) {
      AsyncData(value: null) => MkEmptyState(
        icon: Icons.grass_outlined,
        title: l10n.cropNotFound,
      ),
      AsyncData(value: final c?) => ListView(
        padding: const EdgeInsets.all(MkSpacing.lg),
        children: [
          _CropCard(crop: c),
          const SizedBox(height: MkSpacing.lg),
          _CropCharges(crop: c),
          const SizedBox(height: MkSpacing.lg),
          _CropExample(crop: c),
        ],
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };

    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: crop.value?.nameIn(lang) ?? l10n.cropsTitle,
            actions: [
              const SyncStatusChip(),
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go(CropRoutes.list),
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropCard extends ConsumerWidget {
  const _CropCard({required this.crop});

  final Crop crop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canEdit = ref.watch(canProvider(Permission.settingsManage));
    final rate = crop.stdRate;
    final muted = TextStyle(
      fontSize: 12,
      color: MkTokens.of(context).textMuted,
    );
    return MkCard(
      title: crop.nameEn,
      trailing: canEdit
          ? IconButton(
              key: const ValueKey('crop-edit'),
              tooltip: l10n.cropEditTitle,
              onPressed: () => CropFormDialog.show(context, crop: crop),
              icon: const Icon(Icons.edit_outlined),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [?crop.nameHi, ?crop.namePa].join(' · '),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: MkSpacing.sm),
          Text(
            [
              '${l10n.cropFieldCode}: ${crop.code}',
              if (rate == null)
                l10n.cropNoRate
              else
                '${l10n.cropFieldStdRate}: ${rate.format()}',
              if (!crop.isActive) l10n.cropInactive,
            ].join(' · '),
            style: muted,
          ),
        ],
      ),
    );
  }
}

/// Every `mandi.*` key for this crop at business level.
class _CropCharges extends ConsumerWidget {
  const _CropCharges({required this.crop});

  final Crop crop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final member = ref.watch(activeMembershipProvider);
    final rows = ref.watch(settingRowsProvider(businessTarget)).value;
    final resolver = ref.watch(settingsResolverProvider(businessTarget));
    if (member == null || rows == null || resolver == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final defs = [
      for (final d in SettingsSchema.all)
        if (d.key.startsWith('mandi.')) d,
    ];
    return MkCard(
      title: l10n.cropChargesTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cropChargesHint,
            style: TextStyle(
              fontSize: 12,
              color: MkTokens.of(context).textMuted,
            ),
          ),
          for (final def in defs)
            Builder(
              builder: (context) {
                final key = '${def.key}.${crop.code}';
                return SettingTile(
                  key: ValueKey('crop-setting-$key'),
                  entry: (def: def, suffix: crop.code),
                  label: l10n.settingLabel(def.key),
                  scope: SettingScope.tenant,
                  scopeId: null,
                  target: businessTarget,
                  resolved: resolver.resolve(key),
                  setHere: rows.any(
                    (r) =>
                        r.scope == SettingScope.tenant &&
                        r.key == key &&
                        r.value != null,
                  ),
                  canEdit: canWriteSetting(
                    key,
                    SettingScope.tenant,
                    member.can,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// A sample lot with the crop's current values, so the owner can check the
/// numbers before the season.
class _CropExample extends ConsumerWidget {
  const _CropExample({required this.crop});

  final Crop crop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final resolver = ref.watch(settingsResolverProvider(businessTarget));
    if (resolver == null) return const SizedBox.shrink();
    final config = MandiConfig.resolve(resolver, cropCode: crop.code);
    final qtlMilli = MandiCharges.qtlMilliFromBags(
      exampleBags,
      config.bagWeightKg,
    );
    final rate = crop.stdRate ?? exampleFallbackRate;
    final breakdown = MandiCharges.calculate(
      LotInput(bags: exampleBags, qtlMilli: qtlMilli, rate: rate),
      config,
    );
    final qtl = (Decimal.fromInt(qtlMilli) / Decimal.fromInt(1000))
        .toDecimal()
        .toString();
    return MkCard(
      title: l10n.cropExampleTitle(exampleBags, qtl, rate.format()),
      child: MandiBreakdownView(breakdown: breakdown),
    );
  }
}
