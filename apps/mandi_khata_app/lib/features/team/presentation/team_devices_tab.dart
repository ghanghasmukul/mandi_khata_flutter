import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/team/domain/team_models.dart';
import 'package:mandi_khata_app/features/team/presentation/team_labels.dart';
import 'package:mandi_khata_app/features/team/presentation/team_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Every install of the app in the business, with "revoke".
class TeamDevicesTab extends ConsumerWidget {
  const TeamDevicesTab({super.key});

  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    TeamDevice device,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await MkDialog.show<bool>(
      context,
      title: l10n.teamRevokeTitle(device.code),
      content: Text(l10n.teamRevokeBody),
      actions: [
        Builder(
          builder: (c) => MkButton(
            label: l10n.commonCancel,
            variant: MkButtonVariant.secondary,
            onPressed: () => Navigator.of(c).pop(false),
          ),
        ),
        Builder(
          builder: (c) => MkButton(
            key: const ValueKey('confirm-revoke'),
            label: l10n.teamDeviceRevoke,
            variant: MkButtonVariant.danger,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ),
      ],
    );
    if (ok != true || !context.mounted) return;
    final result = await ref.read(teamWriterProvider).revokeDevice(device.id);
    if (!context.mounted) return;
    final error = result is TeamProtected
        ? l10n.teamErrThisDevice
        : l10n.teamError(result);
    MkToast.show(
      context,
      error ?? l10n.teamRevokeDone,
      tone: error == null ? MkToastTone.success : MkToastTone.error,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final devices = ref.watch(teamDevicesProvider).value;
    final mine = ref.watch(activeDeviceProvider)?.id;
    if (devices == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (devices.isEmpty) {
      return MkEmptyState(
        icon: Icons.devices_outlined,
        title: l10n.teamEmptyDevices,
      );
    }
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        MkSpacing.lg,
        MkSpacing.md,
        MkSpacing.lg,
        96,
      ),
      children: [
        for (final d in devices)
          Opacity(
            opacity: d.isRevoked ? 0.6 : 1,
            child: ListTile(
              key: ValueKey('device-${d.id}'),
              minVerticalPadding: MkSpacing.md,
              leading: CircleAvatar(child: Icon(_icon(d.platform))),
              title: Text('${d.code} · ${platformName(d.platform)}'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: MkSpacing.xs),
                child: Wrap(
                  spacing: MkSpacing.sm,
                  runSpacing: MkSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (d.userName != null) Text(d.userName!),
                    Text(
                      d.lastSeenAt == null
                          ? l10n.teamDeviceNeverSeen
                          : l10n.teamDeviceLastSeen(
                              AppFormat.dateTime(context, d.lastSeenAt!),
                            ),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (d.id == mine) MkRoleChip(label: l10n.teamDeviceThis),
                    if (d.isRevoked)
                      MkRoleChip(label: l10n.teamDeviceRevoked, warning: true),
                  ],
                ),
              ),
              trailing: d.isRevoked || d.id == mine
                  ? null
                  : TextButton(
                      key: ValueKey('revoke-${d.id}'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        foregroundColor: MkTokens.of(context).udhaar,
                      ),
                      onPressed: () => _revoke(context, ref, d),
                      child: Text(l10n.teamDeviceRevoke),
                    ),
            ),
          ),
      ],
    );
  }

  static IconData _icon(String platform) => switch (platform) {
    'android' => Icons.phone_android,
    'web' => Icons.language,
    _ => Icons.desktop_windows_outlined,
  };
}
