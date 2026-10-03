import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/team/domain/team_models.dart';
import 'package:mandi_khata_app/features/team/presentation/member_dialog.dart';
import 'package:mandi_khata_app/features/team/presentation/team_labels.dart';
import 'package:mandi_khata_app/features/team/presentation/team_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Members of the business and invitations still waiting to be accepted.
class TeamPeopleTab extends ConsumerWidget {
  const TeamPeopleTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final members = ref.watch(teamMembersProvider).value;
    final invites = ref.watch(pendingInvitesProvider).value ?? const [];
    final devices = ref.watch(teamDevicesProvider).value ?? const [];
    final me = ref.watch(sessionProvider);
    if (members == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (members.isEmpty && invites.isEmpty) {
      return MkEmptyState(
        icon: Icons.groups_outlined,
        title: l10n.teamEmptyPeople,
      );
    }
    final myId = me is SignedIn ? me.user.id : null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        MkSpacing.lg,
        MkSpacing.md,
        MkSpacing.lg,
        96,
      ),
      children: [
        for (final m in members)
          _MemberTile(
            member: m,
            isMe: m.userId == myId,
            devices: devices
                .where((d) => d.userId == m.userId && !d.isRevoked)
                .length,
          ),
        if (invites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: MkSpacing.xl,
              bottom: MkSpacing.sm,
            ),
            child: Text(
              l10n.teamPendingInvites,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          for (final i in invites) _InviteTile(invite: i),
        ],
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isMe,
    required this.devices,
  });

  final TeamMember member;
  final bool isMe;
  final int devices;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final initial = member.displayName.characters.first.toUpperCase();
    final phone = member.phone;
    return Opacity(
      opacity: member.isActive ? 1 : 0.6,
      child: ListTile(
        key: ValueKey('member-${member.id}'),
        minVerticalPadding: MkSpacing.md,
        onTap: () => MemberDialog.show(context, member),
        leading: CircleAvatar(child: Text(initial)),
        title: Text(
          isMe ? '${member.displayName} (${l10n.teamYou})' : member.displayName,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: MkSpacing.xs),
          child: Wrap(
            spacing: MkSpacing.sm,
            runSpacing: MkSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MkRoleChip(label: l10n.roleName(member.role)),
              if (!member.isActive)
                MkRoleChip(label: l10n.teamInactive, warning: true),
              if (phone != null && phone.isNotEmpty)
                Text(
                  TeamRules.displayPhone(phone),
                  style: theme.textTheme.bodySmall,
                ),
              Text(
                l10n.teamDevicesCount(devices),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _InviteTile extends ConsumerWidget {
  const _InviteTile({required this.invite});

  final TeamInvite invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final expired = invite.isExpired(DateTime.now());
    final expires = invite.expiresAt;
    final name = invite.fullName;
    return ListTile(
      key: ValueKey('invite-${invite.id}'),
      leading: const CircleAvatar(child: Icon(Icons.hourglass_top)),
      title: Text(
        [
          if (name != null && name.isNotEmpty) name,
          TeamRules.displayPhone(invite.phone),
        ].join(' · '),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: MkSpacing.xs),
        child: Wrap(
          spacing: MkSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            MkRoleChip(label: l10n.roleName(invite.role)),
            if (expired)
              MkRoleChip(label: l10n.teamInviteExpired, warning: true)
            else if (expires != null)
              Text(
                l10n.teamInviteExpires(AppFormat.date(context, expires)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
      trailing: TextButton(
        key: ValueKey('cancel-invite-${invite.id}'),
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
        onPressed: () async {
          final result = await ref
              .read(teamWriterProvider)
              .cancelInvite(invite.id);
          if (!context.mounted) return;
          final error = l10n.teamError(result);
          MkToast.show(
            context,
            error ?? l10n.teamInviteCancelled,
            tone: error == null ? MkToastTone.success : MkToastTone.error,
          );
        },
        child: Text(l10n.teamInviteCancel),
      ),
    );
  }
}
