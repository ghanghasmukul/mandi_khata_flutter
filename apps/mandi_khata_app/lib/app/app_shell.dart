import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/account_menu.dart';
import 'package:mandi_khata_app/app/command_palette.dart';
import 'package:mandi_khata_app/app/nav_destinations.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/update/update_banner.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_screen.dart';
import 'package:mandi_khata_app/features/products/presentation/products_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The frame around every business screen (design/Mandi_Khata.html): the
/// sidebar on desktop and web, an icon rail on tablets, a bottom bar and a
/// "More" sheet on phones. It also gives every screen's [MkTopBar] the
/// search pill, language switcher, role and account menu, so a screen's
/// header only says its title.
class AppShell extends ConsumerWidget {
  const AppShell({required this.location, required this.child, super.key});

  /// The current route, to mark the active destination.
  final String location;
  final Widget child;

  static const _moreId = 'more';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final member = ref.watch(activeMembershipProvider);
    bool can(Permission p) => ref.watch(canProvider(p));
    final overdue = ref.watch(loanAlertsProvider).value?.overdue ?? 0;
    final sections = navSections(
      l10n,
      can,
      badges: {if (overdue > 0) LoanRoutes.list: '$overdue'},
      moduleOn: (m) => m != 'shop' || ref.watch(shopModuleEnabledProvider),
    );
    final all = [for (final s in sections) ...s.items];
    final selected = selectedNavId(location, [for (final i in all) i.id]);
    final layout = MkShellLayout.forWidth(MediaQuery.sizeOf(context).width);
    final navigatorKey = ref.read(rootNavigatorKeyProvider);

    final bottom = [
      for (final r in bottomRoutes) ...all.where((i) => i.id == r),
      MkNavItem(id: _moreId, icon: Icons.apps, label: l10n.navMore),
    ];

    void select(MkNavItem item) {
      if (item.id == _moreId) {
        _showMore(context, sections, selected);
      } else if (item.id != selected) {
        context.go(item.id);
      }
    }

    final sidebar = layout == MkShellLayout.sidebar;
    return MkAppShell(
      appName: 'Mandi Khata',
      businessName: member?.tenantName,
      sections: sections,
      selectedId: selected,
      onSelect: select,
      bottomItems: bottom,
      onSearch: () => CommandPaletteShortcut.open(ref, navigatorKey),
      sidebarFooter: const _SidebarFooter(),
      body: MkTopBarScope(
        searchHint: l10n.navSearchHint,
        onSearch: () => CommandPaletteShortcut.open(ref, navigatorKey),
        languages: appLanguages,
        language: Localizations.localeOf(context).languageCode,
        onLanguage: (c) => ref.read(appLanguageProvider.notifier).set(c),
        roleLabel: member == null ? null : l10n.roleName(member.role),
        // The sidebar footer already shows sync status and the account.
        trailing: sidebar
            ? const []
            : const [SyncStatusChip(), SizedBox(width: 4), AccountMenu()],
        child: Column(
          children: [
            const UpdateBanner(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  /// Every destination, for phones (the bottom bar only has four).
  void _showMore(
    BuildContext context,
    List<MkNavSection> sections,
    String? selected,
  ) {
    final l10n = AppLocalizations.of(context);
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(
                  l10n.navMenuTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final s in sections) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 4),
                    child: Text(
                      s.title.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  for (final i in s.items)
                    ListTile(
                      key: ValueKey('more-${i.id}'),
                      minTileHeight: 48,
                      leading: Icon(i.icon),
                      title: Text(i.label),
                      selected: i.id == selected,
                      trailing: i.badge == null ? null : Text(i.badge!),
                      onTap: () {
                        Navigator.of(sheet).pop();
                        context.go(i.id);
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sync status and the signed-in user, under the sidebar.
class _SidebarFooter extends ConsumerWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final member = ref.watch(activeMembershipProvider);
    final user = switch (ref.watch(sessionProvider)) {
      SignedIn(:final user) => user.phone ?? user.email ?? '',
      _ => '',
    };
    final role = member == null ? '' : l10n.roleName(member.role);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SyncStatusChip(onDark: true),
        const SizedBox(height: 8),
        AccountMenu(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: MkColors.sidebarAvatar,
                  child: Text(
                    role.isEmpty ? '·' : role.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: MkColors.sidebarItem,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.isEmpty ? role : user,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: tokens.sidebarText,
                        ),
                      ),
                      if (user.isNotEmpty)
                        Text(
                          role,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: tokens.sidebarMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.unfold_more, size: 16, color: tokens.sidebarMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
