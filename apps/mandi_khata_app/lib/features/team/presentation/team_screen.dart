import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/features/team/presentation/invite_dialog.dart';
import 'package:mandi_khata_app/features/team/presentation/team_devices_tab.dart';
import 'package:mandi_khata_app/features/team/presentation/team_people_tab.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class TeamRoutes {
  static const list = '/team';
}

/// Users & permissions (owner): people, invitations and devices.
/// Ctrl/⌘+N invites someone.
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allowed = ref.watch(canProvider(Permission.adminManage));

    Widget body() {
      if (!allowed) {
        return MkEmptyState(icon: Icons.lock_outline, title: l10n.teamNoAccess);
      }
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: l10n.teamTabPeople),
                  Tab(text: l10n.teamTabDevices),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [TeamPeopleTab(), TeamDevicesTab()],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: CallbackShortcuts(
        bindings: {
          if (allowed)
            ...primaryShortcut(
              LogicalKeyboardKey.keyN,
              () => InviteDialog.show(context),
            ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            floatingActionButton: allowed
                ? FloatingActionButton.extended(
                    key: const ValueKey('team-invite'),
                    onPressed: () => InviteDialog.show(context),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: Text(l10n.teamInvite),
                  )
                : null,
            body: Column(
              children: [
                MkTopBar(
                  title: l10n.teamTitle,
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
                Expanded(child: body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
