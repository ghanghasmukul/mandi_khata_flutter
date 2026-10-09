import 'package:flutter/material.dart';
import 'package:mk_admin/src/audit_screen.dart';
import 'package:mk_admin/src/businesses_screen.dart';
import 'package:mk_admin/src/plans_screen.dart';
import 'package:mk_admin/src/requests_screen.dart';
import 'package:mk_admin/src/resources.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Page {
  const _Page(this.label, this.icon, this.build);

  final String label;
  final IconData icon;
  final Widget Function() build;
}

final _pages = <_Page>[
  const _Page('Businesses', Icons.storefront_outlined, BusinessesScreen.new),
  const _Page('Requests', Icons.inbox_outlined, RequestsScreen.new),
  const _Page('Plans', Icons.workspace_premium_outlined, PlansScreen.new),
  _Page(
    'Platform settings',
    Icons.tune,
    () => const ResourceScreen(config: platformSettingsResource),
  ),
  _Page(
    'State presets',
    Icons.map_outlined,
    () => ResourceScreen(config: statePresetsResource),
  ),
  _Page(
    'Crop master',
    Icons.grass_outlined,
    () => CropMasterScreen(config: cropMasterResource),
  ),
  _Page(
    'Referral codes',
    Icons.handshake_outlined,
    () => ResourceScreen(config: referralsResource),
  ),
  _Page(
    'Announcements',
    Icons.campaign_outlined,
    () => ResourceScreen(config: announcementsResource),
  ),
  const _Page('Audit log', Icons.history, AuditScreen.new),
];

class AdminShell extends StatefulWidget {
  const AdminShell({required this.email, super.key});

  final String email;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final body = KeyedSubtree(
      key: ValueKey('page-$_index'),
      child: _pages[_index].build(),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_index].label),
        actions: [
          Center(child: Text(widget.email)),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => Supabase.instance.client.auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(
              child: ListView(
                children: [
                  for (final (i, p) in _pages.indexed)
                    ListTile(
                      leading: Icon(p.icon),
                      title: Text(p.label),
                      selected: i == _index,
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() => _index = i);
                      },
                    ),
                ],
              ),
            ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              extended: true,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final p in _pages)
                  NavigationRailDestination(
                    icon: Icon(p.icon),
                    label: Text(p.label),
                  ),
              ],
            ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
