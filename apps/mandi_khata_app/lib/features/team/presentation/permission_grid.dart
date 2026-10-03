import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/team/presentation/team_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One switch per permission for a [role]. A dot marks a permission whose
/// state differs from the role default; the caller stores only those
/// differences (`TeamRules.overridesFor`).
class PermissionGrid extends StatelessWidget {
  const PermissionGrid({
    required this.role,
    required this.granted,
    required this.onChanged,
    super.key,
    this.enabled = true,
  });

  final MemberRole role;
  final Set<Permission> granted;
  final void Function(Permission permission, {required bool on}) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    if (role == MemberRole.owner) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: MkSpacing.sm),
        child: Text(l10n.teamOwnerAll),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.teamPermissionsHelp,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: MkSpacing.sm),
        for (final p in Permission.values)
          SwitchListTile(
            key: ValueKey('perm-${p.key}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: granted.contains(p),
            onChanged: enabled ? (v) => onChanged(p, on: v) : null,
            title: Row(
              children: [
                Flexible(child: Text(l10n.permissionName(p))),
                if (granted.contains(p) != role.allows(p))
                  Padding(
                    padding: const EdgeInsets.only(left: MkSpacing.sm),
                    child: Tooltip(
                      message: l10n.teamPermissionChanged,
                      child: Icon(Icons.circle, size: 8, color: tokens.gold),
                    ),
                  ),
                if (TeamRules.sensitive.contains(p))
                  Padding(
                    padding: const EdgeInsets.only(left: MkSpacing.sm),
                    child: Tooltip(
                      message: l10n.teamPermissionSensitive,
                      child: Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: tokens.goldText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Role chips; [roles] are the choices on offer.
class RoleChoice extends StatelessWidget {
  const RoleChoice({
    required this.roles,
    required this.selected,
    required this.onSelected,
    super.key,
    this.enabled = true,
  });

  final List<MemberRole> roles;
  final MemberRole selected;
  final ValueChanged<MemberRole> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: MkSpacing.sm,
      runSpacing: MkSpacing.sm,
      children: [
        for (final r in roles)
          ChoiceChip(
            key: ValueKey('role-${r.name}'),
            label: Text(l10n.roleName(r)),
            selected: r == selected,
            onSelected: enabled ? (_) => onSelected(r) : null,
          ),
      ],
    );
  }
}
