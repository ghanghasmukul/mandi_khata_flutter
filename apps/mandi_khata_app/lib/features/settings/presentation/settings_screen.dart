import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/backup/presentation/backup_screen.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_screen.dart';
import 'package:mandi_khata_app/features/imports/presentation/imports_hub_screen.dart';
import 'package:mandi_khata_app/features/settings/data/party_options.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_tile.dart';
import 'package:mandi_khata_app/features/settings/presentation/whats_new_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The settings a level can hold, grouped for display. Keys with a fixed
/// suffix list (modules, per-role tiers, number series) get one row each;
/// per-crop overrides are edited on the crop screen.
Map<String, List<SettingEntry>> settingEntriesFor(SettingScope scope) {
  final groups = <String, List<SettingEntry>>{};
  for (final def in SettingsSchema.visible) {
    if (!def.allowedAt(scope)) continue;
    final group = def.key == 'app.modules'
        ? 'modules'
        : def.key.split('.').first;
    final list = groups.putIfAbsent(group, () => []);
    final suffixes = def.suffixValues;
    if (suffixes == null) {
      list.add((def: def, suffix: null));
    } else {
      list.addAll([for (final s in suffixes) (def: def, suffix: s)]);
    }
  }
  return groups;
}

/// Generic editor for every key in the settings schema, for the whole
/// business or for one party. Shows where each value comes from and lets a
/// value set here be reset to the inherited one.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Null = whole business.
  String? _partyId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final member = ref.watch(activeMembershipProvider);
    final scope = _partyId == null ? SettingScope.tenant : SettingScope.party;
    final SettingsTarget target = (
      partyId: _partyId,
      partyGroupId: null,
      documentId: null,
    );
    final rows = ref.watch(settingRowsProvider(target)).value;
    final resolver = ref.watch(settingsResolverProvider(target));

    final Widget body;
    if (member == null || rows == null || resolver == null) {
      body = Center(
        child: member == null
            ? Text(l10n.settingsNoTenant)
            : const CircularProgressIndicator(),
      );
    } else {
      bool storedHere(String key) => rows.any(
        (r) =>
            r.scope == scope &&
            r.scopeId == _partyId &&
            r.key == key &&
            r.value != null,
      );
      final groups = settingEntriesFor(scope);
      body = ListView(
        padding: const EdgeInsets.all(MkSpacing.lg),
        children: [
          _ScopePicker(
            partyId: _partyId,
            onChanged: (id) => setState(() => _partyId = id),
          ),
          if (_partyId == null && member.can(Permission.adminManage))
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.lg),
              child: MkCard(
                padding: EdgeInsets.zero,
                onTap: () => context.go('/onboarding'),
                child: ListTile(
                  key: const ValueKey('settings-wizard'),
                  leading: const Icon(Icons.checklist_outlined),
                  title: Text(l10n.onboardingTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/onboarding'),
                ),
              ),
            ),
          if (_partyId == null)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.lg),
              child: MkCard(
                padding: EdgeInsets.zero,
                onTap: () => context.go(WhatsNewScreen.route),
                child: ListTile(
                  key: const ValueKey('settings-whats-new'),
                  leading: const Icon(Icons.new_releases_outlined),
                  title: Text(l10n.whatsNewTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(WhatsNewScreen.route),
                ),
              ),
            ),
          if (_partyId == null && member.can(Permission.partiesManage))
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.lg),
              child: MkCard(
                padding: EdgeInsets.zero,
                onTap: () => context.go(ImportRoutes.hub),
                child: ListTile(
                  key: const ValueKey('settings-imports'),
                  leading: const Icon(Icons.upload_file_outlined),
                  title: Text(l10n.importHubTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(ImportRoutes.hub),
                ),
              ),
            ),
          if (_partyId == null && member.role == MemberRole.owner)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.lg),
              child: MkCard(
                padding: EdgeInsets.zero,
                onTap: () => context.go(BackupScreen.route),
                child: ListTile(
                  key: const ValueKey('settings-backup'),
                  leading: const Icon(Icons.backup_outlined),
                  title: Text(l10n.backupTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(BackupScreen.route),
                ),
              ),
            ),
          if (_partyId == null)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.lg),
              child: MkCard(
                padding: EdgeInsets.zero,
                onTap: () => context.go(CropRoutes.list),
                child: ListTile(
                  key: const ValueKey('settings-crops'),
                  leading: const Icon(Icons.grass_outlined),
                  title: Text(l10n.settingsCropsLink),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(CropRoutes.list),
                ),
              ),
            ),
          for (final MapEntry(key: group, value: entries) in groups.entries)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.lg),
              child: MkCard(
                title: l10n.settingGroup(group),
                child: Column(
                  children: [
                    for (final e in entries)
                      SettingTile(
                        key: ValueKey('${scope.name}|$_partyId|${e.fullKey}'),
                        entry: e,
                        scope: scope,
                        scopeId: _partyId,
                        target: target,
                        resolved: resolver.resolve(
                          e.fullKey,
                          partyId: _partyId,
                        ),
                        setHere: storedHere(e.fullKey),
                        canEdit: canWriteSetting(e.fullKey, scope, member.can),
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.settingsTitle,
            subtitle: member?.tenantName,
            languages: appLanguages,
            language: Localizations.localeOf(context).languageCode,
            onLanguage: (c) => ref.read(appLanguageProvider.notifier).set(c),
            actions: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go(GateRoutes.home),
                icon: const Icon(Icons.close),
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

/// "Settings for": the whole business or one party.
class _ScopePicker extends ConsumerWidget {
  const _ScopePicker({required this.partyId, required this.onChanged});

  final String? partyId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final parties = ref.watch(partyOptionsProvider).value ?? const [];
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownMenu<String?>(
            key: const ValueKey('settings-scope'),
            label: Text(l10n.settingsScopeLabel),
            initialSelection: partyId,
            enableFilter: true,
            requestFocusOnTap: true,
            expandedInsets: EdgeInsets.zero,
            onSelected: onChanged,
            dropdownMenuEntries: [
              DropdownMenuEntry(value: null, label: l10n.settingsScopeBusiness),
              for (final p in parties)
                DropdownMenuEntry(
                  value: p.id,
                  label: p.village == null
                      ? p.name
                      : '${p.name} · ${p.village}',
                ),
            ],
          ),
          const SizedBox(height: MkSpacing.sm),
          Text(
            l10n.settingsScopeHint,
            style: TextStyle(
              fontSize: 12,
              color: MkTokens.of(context).textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
