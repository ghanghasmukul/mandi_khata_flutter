import 'package:flutter/material.dart';
import 'package:mk_admin/src/audit_screen.dart';
import 'package:mk_admin/src/businesses_screen.dart';
import 'package:mk_admin/src/plans_screen.dart';
import 'package:mk_admin/src/requests_screen.dart';
import 'package:mk_admin/src/resources.dart';
import 'package:mk_admin/src/sync_health_screen.dart';
import 'package:mk_admin/src/users_screen.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Page {
  const _Page(this.id, this.label, this.icon, this.build);

  final String id;
  final String label;
  final IconData icon;
  final Widget Function() build;

  MkNavItem get item => MkNavItem(id: id, icon: icon, label: label);
}

final _customers = <_Page>[
  const _Page(
    'businesses',
    'Businesses',
    Icons.storefront_outlined,
    BusinessesScreen.new,
  ),
  const _Page(
    'users',
    'Users & access',
    Icons.manage_accounts_outlined,
    UsersScreen.new,
  ),
  const _Page('requests', 'Requests', Icons.inbox_outlined, RequestsScreen.new),
];

final _commercial = <_Page>[
  const _Page(
    'plans',
    'Plans & add-ons',
    Icons.workspace_premium_outlined,
    PlansScreen.new,
  ),
  _Page(
    'settings',
    'Platform settings',
    Icons.tune,
    () => const ResourceScreen(config: platformSettingsResource),
  ),
  _Page(
    'presets',
    'State presets',
    Icons.map_outlined,
    () => ResourceScreen(config: statePresetsResource),
  ),
];

final _content = <_Page>[
  _Page(
    'crops',
    'Crop master',
    Icons.grass_outlined,
    () => CropMasterScreen(config: cropMasterResource),
  ),
  _Page(
    'referrals',
    'Referral codes',
    Icons.handshake_outlined,
    () => ResourceScreen(config: referralsResource),
  ),
  _Page(
    'announcements',
    'Announcements',
    Icons.campaign_outlined,
    () => ResourceScreen(config: announcementsResource),
  ),
];

final _operations = <_Page>[
  const _Page('health', 'Sync health', Icons.sync_alt, SyncHealthScreen.new),
  const _Page('audit', 'Audit log', Icons.history, AuditScreen.new),
];

final _sections = <(String, String, List<_Page>)>[
  ('customers', 'Customers', _customers),
  ('commercial', 'Plans & defaults', _commercial),
  ('content', 'Content', _content),
  ('ops', 'Operations', _operations),
];

final List<_Page> _all = [for (final s in _sections) ...s.$3];

/// The console frame: dark sidebar in sections, a quiet top bar, the page.
class AdminShell extends StatefulWidget {
  const AdminShell({required this.email, super.key});

  final String email;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  String _id = _all.first.id;

  @override
  Widget build(BuildContext context) {
    final page = _all.firstWhere((p) => p.id == _id);
    return MkAppShell(
      appName: 'Mandi Khata',
      businessName: 'Super admin',
      selectedId: _id,
      onSelect: (item) => setState(() => _id = item.id),
      sections: [
        for (final s in _sections)
          MkNavSection(
            id: s.$1,
            title: s.$2,
            items: [for (final p in s.$3) p.item],
          ),
      ],
      bottomItems: [for (final p in _customers) p.item, _operations.first.item],
      sidebarFooter: Padding(
        padding: const EdgeInsets.all(MkSpacing.md),
        child: Row(
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 18,
              color: MkColors.sidebarMuted,
            ),
            const SizedBox(width: MkSpacing.sm),
            Expanded(
              child: Text(
                widget.email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: MkColors.sidebarText,
                  fontSize: 12,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => Supabase.instance.client.auth.signOut(),
              icon: const Icon(
                Icons.logout,
                size: 18,
                color: MkColors.sidebarMuted,
              ),
            ),
          ],
        ),
      ),
      topBar: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: MkSpacing.xl),
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(
          color: MkColors.surface,
          border: Border(bottom: BorderSide(color: MkColors.border)),
        ),
        child: Row(
          children: [
            Text(page.label, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            if (MediaQuery.sizeOf(context).width < 1000)
              IconButton(
                tooltip: 'Sign out',
                onPressed: () => Supabase.instance.client.auth.signOut(),
                icon: const Icon(Icons.logout),
              ),
          ],
        ),
      ),
      body: KeyedSubtree(key: ValueKey('page-$_id'), child: page.build()),
    );
  }
}
