import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/subscription/subscription_providers.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_editors.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One editable setting in the editor: what it is, its current value and
/// where that came from.
typedef SettingEntry = ({SettingDef def, String? suffix});

extension SettingEntryKey on SettingEntry {
  String get fullKey => suffix == null ? def.key : '${def.key}.$suffix';
}

/// Label, input, "inherited from X" / "set here" and a reset button.
class SettingTile extends ConsumerWidget {
  const SettingTile({
    required this.entry,
    required this.scope,
    required this.scopeId,
    required this.target,
    required this.resolved,
    required this.setHere,
    required this.canEdit,
    this.label,
    super.key,
  });

  final SettingEntry entry;

  /// The level being edited.
  final SettingScope scope;
  final String? scopeId;
  final SettingsTarget target;
  final ResolvedSetting resolved;

  /// A value is stored at exactly this level (so it can be reset).
  final bool setHere;
  final bool canEdit;

  /// Replaces the generated label (the crop screen shows the base name).
  final String? label;

  Future<String?> _save(
    BuildContext context,
    WidgetRef ref,
    Object? value,
  ) async {
    final l10n = AppLocalizations.of(context);
    final failure = await ref
        .read(settingsWriterProvider)
        .write(
          scope: scope,
          scopeId: scopeId,
          key: entry.fullKey,
          value: value,
        );
    return switch (failure) {
      null => null,
      UnknownSetting() || NotSettableHere() => l10n.settingErrorNotHere,
      SettingNotPermitted() => l10n.settingsNoPermission,
      InvalidSettingValue(:final error) => settingErrorText(
        l10n,
        error,
        entry.def,
      ),
    };
  }

  Future<void> _saveAndReport(
    BuildContext context,
    WidgetRef ref,
    Object? value,
  ) async {
    final error = await _save(context, ref, value);
    if (error != null && context.mounted) {
      MkToast.show(context, error, tone: MkToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = MkTokens.of(context);
    final def = entry.def;
    final suffix = entry.suffix;
    final label =
        this.label ??
        (suffix == null
            ? l10n.settingLabel(def.key)
            : def.key == 'app.modules'
            ? l10n.settingSuffix(def.suffixName!, suffix)
            : '${l10n.settingLabel(def.key)} · '
                  '${l10n.settingSuffix(def.suffixName!, suffix)}');
    final source = setHere
        ? l10n.settingSetHere
        : settingSourceText(l10n, resolved.level);
    // A module the plan lacks is off, whatever the switch says, and cannot
    // be switched on from here (docs/domain/saas-rules.md section 2).
    final notInPlan =
        def.key == 'app.modules' &&
        suffix != null &&
        !ref.watch(entitlementsProvider).module(suffix);
    final canEdit = this.canEdit && !notInPlan;
    final perMonth = def.key == 'interest.rate_pa'
        ? SettingsSchema.decimalOf(resolved.value)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MkSpacing.sm),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: MkSpacing.sm,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 220, maxWidth: 360),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyLarge),
                Text(
                  [
                    if (notInPlan) l10n.modNotInPlan else source,
                    if (perMonth != null)
                      l10n.settingRatePerMonth(
                        InterestRate.per100PerMonthFromPa(perMonth).toString(),
                      ),
                    if (!canEdit && !notInPlan) l10n.settingsNoPermission,
                    if (!settingHasEditor(def)) l10n.settingsReadOnly,
                  ].join(' · '),
                  style: TextStyle(
                    fontSize: 12,
                    color: setHere ? tokens.goldText : tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SettingEditor(
                  // New input when the level or the stored value changes.
                  key: ValueKey('${scope.name}|$scopeId|${resolved.value}'),
                  def: def,
                  value: notInPlan ? false : resolved.value,
                  enabled: canEdit && settingHasEditor(def),
                  onSave: (v) async {
                    if (def.type == SettingType.boolean ||
                        def.type == SettingType.choice) {
                      await _saveAndReport(context, ref, v);
                      return null;
                    }
                    return await _save(context, ref, v);
                  },
                ),
              ),
              if (setHere && canEdit)
                IconButton(
                  tooltip: l10n.settingsReset,
                  onPressed: () => _saveAndReport(context, ref, null),
                  icon: const Icon(Icons.undo),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String settingSourceText(AppLocalizations l10n, SettingLevel level) =>
    switch (level) {
      SettingLevel.document => l10n.settingFromDocument,
      SettingLevel.party => l10n.settingFromParty,
      SettingLevel.partyGroup => l10n.settingFromPartyGroup,
      SettingLevel.tenant => l10n.settingFromBusiness,
      SettingLevel.plan => l10n.settingFromPlan,
      SettingLevel.system => l10n.settingFromDefault,
    };

String settingErrorText(
  AppLocalizations l10n,
  SettingError error,
  SettingDef def,
) {
  String bound(int? v) => v == null
      ? ''
      : def.type == SettingType.paise
      ? Money(v).format()
      : '$v';
  return switch (error) {
    SettingError.wrongType => l10n.settingErrorWrongType,
    SettingError.tooSmall => l10n.settingErrorTooSmall(bound(def.min)),
    SettingError.tooLarge => l10n.settingErrorTooLarge(bound(def.max)),
    SettingError.notAllowed => l10n.settingErrorNotAllowed,
    SettingError.invalid => l10n.settingErrorInvalid,
  };
}
