import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/team/domain/team_models.dart';
import 'package:mandi_khata_app/features/team/presentation/permission_grid.dart';
import 'package:mandi_khata_app/features/team/presentation/team_labels.dart';
import 'package:mandi_khata_app/features/team/presentation/team_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Edit one person: role, permission overrides, device limit; deactivate or
/// reactivate. Everything is saved locally (and audited) and syncs later.
class MemberDialog extends ConsumerStatefulWidget {
  const MemberDialog({required this.member, super.key});

  final TeamMember member;

  static Future<void> show(BuildContext context, TeamMember member) =>
      showDialog<void>(
        context: context,
        barrierColor: MkColors.scrim,
        builder: (_) => MemberDialog(member: member),
      );

  @override
  ConsumerState<MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends ConsumerState<MemberDialog> {
  late MemberRole _role = widget.member.role;
  late Set<Permission> _granted = widget.member.effective;
  late int _deviceLimit = widget.member.deviceLimit;
  bool _saving = false;
  String? _error;

  TeamMember get _m => widget.member;

  void _pickRole(MemberRole role) => setState(() {
    _role = role;
    // A new role starts from its own defaults.
    _granted = TeamRules.effective(role, const {});
  });

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref
        .read(teamWriterProvider)
        .updateMember(
          _m.id,
          role: _role,
          overrides: TeamRules.overridesFor(_role, _granted),
          deviceLimit: _deviceLimit,
        );
    if (!mounted) return;
    final error = l10n.teamError(result);
    if (error == null) {
      Navigator.of(context).pop();
      MkToast.show(context, l10n.teamSaved, tone: MkToastTone.success);
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  Future<void> _toggleActive() async {
    final l10n = AppLocalizations.of(context);
    final activate = !_m.isActive;
    if (!activate) {
      final ok = await MkDialog.show<bool>(
        context,
        title: l10n.teamDeactivateTitle(_m.displayName),
        content: Text(l10n.teamDeactivateBody),
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
              key: const ValueKey('confirm-deactivate'),
              label: l10n.teamDeactivate,
              variant: MkButtonVariant.danger,
              onPressed: () => Navigator.of(c).pop(true),
            ),
          ),
        ],
      );
      if (ok != true || !mounted) return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref
        .read(teamWriterProvider)
        .setActive(_m.id, active: activate);
    if (!mounted) return;
    final error = l10n.teamError(result);
    if (error == null) {
      Navigator.of(context).pop();
      MkToast.show(
        context,
        activate ? l10n.teamReactivated : l10n.teamDeactivated,
        tone: MkToastTone.success,
      );
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(sessionProvider);
    final actorRole =
        ref.watch(activeMembershipProvider)?.role ?? MemberRole.munshi;
    final actorIsOwner = actorRole == MemberRole.owner;
    final isSelf = me is SignedIn && me.user.id == _m.userId;
    // Same rules as the server: only owners touch owners; nobody but an
    // owner changes their own access.
    final locked = !actorIsOwner && (_m.isOwner || isSelf);
    final roles = [
      if (actorIsOwner) MemberRole.owner,
      MemberRole.accountant,
      MemberRole.munshi,
      MemberRole.custom,
    ];
    final tokens = MkTokens.of(context);

    return MkDialog(
      title: _m.displayName,
      maxWidth: 560,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_m.phone != null && _m.phone!.isNotEmpty)
            Text(
              TeamRules.displayPhone(_m.phone!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: MkSpacing.md),
          Text(l10n.teamRole, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: MkSpacing.sm),
          RoleChoice(
            roles: roles,
            selected: _role,
            enabled: !locked && !_saving,
            onSelected: _pickRole,
          ),
          const SizedBox(height: MkSpacing.lg),
          Text(
            l10n.teamPermissions,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: MkSpacing.xs),
          PermissionGrid(
            role: _role,
            granted: _granted,
            enabled: !locked && !_saving,
            onChanged: (p, {required on}) => setState(() {
              _granted = {..._granted};
              if (on) {
                _granted.add(p);
              } else {
                _granted.remove(p);
              }
            }),
          ),
          const SizedBox(height: MkSpacing.md),
          Row(
            children: [
              Expanded(child: Text(l10n.teamDeviceLimit)),
              IconButton(
                key: const ValueKey('limit-minus'),
                tooltip: '-',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: locked || _saving || _deviceLimit <= 1
                    ? null
                    : () => setState(() => _deviceLimit--),
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '$_deviceLimit',
                  key: const ValueKey('limit-value'),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                key: const ValueKey('limit-plus'),
                tooltip: '+',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: locked || _saving || _deviceLimit >= 50
                    ? null
                    : () => setState(() => _deviceLimit++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (locked)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.sm),
              child: Text(
                l10n.teamErrProtected,
                style: TextStyle(color: tokens.goldText),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.sm),
              child: Text(
                _error!,
                key: const ValueKey('member-error'),
                style: TextStyle(color: tokens.udhaar),
              ),
            ),
        ],
      ),
      actions: [
        if (!isSelf && !locked)
          MkButton(
            key: const ValueKey('member-toggle-active'),
            label: _m.isActive ? l10n.teamDeactivate : l10n.teamReactivate,
            variant: _m.isActive
                ? MkButtonVariant.ghost
                : MkButtonVariant.secondary,
            onPressed: _saving ? null : _toggleActive,
          ),
        MkButton(
          label: l10n.commonClose,
          variant: MkButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MkButton(
          key: const ValueKey('member-save'),
          label: l10n.teamSave,
          busy: _saving,
          onPressed: locked ? null : _save,
        ),
      ],
    );
  }
}
