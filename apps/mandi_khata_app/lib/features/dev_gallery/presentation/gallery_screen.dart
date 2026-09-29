// Developer-only screen. Its sample text is deliberately not localised: the
// route is not registered in release builds (see docs/decisions.md).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mandi_khata_app/features/dev_gallery/presentation/gallery_input_sections.dart';
import 'package:mandi_khata_app/features/dev_gallery/presentation/gallery_sections.dart';
import 'package:mk_ui/mk_ui.dart';

const _sections = [
  MkNavSection(
    id: 'mandi',
    title: 'Mandi',
    items: [
      MkNavItem(
        id: 'dashboard',
        icon: Icons.space_dashboard,
        label: 'Dashboard',
      ),
      MkNavItem(id: 'khata', icon: Icons.menu_book, label: 'Khata'),
      MkNavItem(id: 'farmers', icon: Icons.groups, label: 'Farmers'),
      MkNavItem(id: 'arrivals', icon: Icons.local_shipping, label: 'Arrivals'),
      MkNavItem(id: 'loans', icon: Icons.payments, label: 'Loans', badge: '3'),
    ],
  ),
  MkNavSection(
    id: 'shop',
    title: 'Shop',
    items: [
      MkNavItem(id: 'pos', icon: Icons.point_of_sale, label: 'POS'),
      MkNavItem(id: 'products', icon: Icons.inventory_2, label: 'Products'),
    ],
  ),
  MkNavSection(
    id: 'accounts',
    title: 'Accounts',
    items: [
      MkNavItem(id: 'vouchers', icon: Icons.receipt_long, label: 'Vouchers'),
      MkNavItem(id: 'reports', icon: Icons.bar_chart, label: 'Reports'),
    ],
  ),
  MkNavSection(
    id: 'admin',
    title: 'Admin',
    items: [
      MkNavItem(id: 'users', icon: Icons.manage_accounts, label: 'Users'),
      MkNavItem(id: 'settings', icon: Icons.settings, label: 'Settings'),
    ],
  ),
];

const _languages = [
  MkLanguage(code: 'en', label: 'EN'),
  MkLanguage(code: 'hi', label: 'हिं'),
  MkLanguage(code: 'pa', label: 'ਪੰ'),
];

/// Shows every `mk_ui` widget inside a real [MkAppShell]. Resize the window to
/// see the sidebar → rail → bottom-nav breakpoints.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  /// The scrolling body, for tests.
  static const listKey = Key('gallery-list');

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selected = 'dashboard';
  String _language = 'en';

  void _openSearch() =>
      MkToast.show(context, 'Search opens here (Ctrl/⌘ K works too)');

  @override
  Widget build(BuildContext context) {
    return MkAppShell(
      appName: 'Mandi Khata',
      businessName: 'Gupta Trading Co.',
      sections: _sections,
      selectedId: _selected,
      onSelect: (item) => setState(() => _selected = item.id),
      bottomItems: [
        _sections[0].items[0],
        _sections[0].items[1],
        _sections[0].items[2],
        _sections[0].items[4],
        _sections[3].items[1],
      ],
      onSearch: _openSearch,
      sidebarFooter: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [MkSyncIndicator(label: 'Offline · 4 queued', ok: false)],
      ),
      topBar: MkTopBar(
        title: 'Design gallery',
        subtitle: 'Every mk_ui widget, on the real theme',
        searchHint: 'Search farmer, lot, receipt…',
        onSearch: _openSearch,
        languages: _languages,
        language: _language,
        onLanguage: (code) => setState(() => _language = code),
        roleLabel: 'Owner',
        roleNote: 'Munshi role: deletes, loans and exports are blocked',
        actions: [
          IconButton(
            tooltip: 'Home',
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: ListView(
        key: GalleryScreen.listKey,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 60),
        children: const [
          GallerySection(title: 'Colours', child: ColourSwatches()),
          GallerySection(title: 'Type', child: TypeSamples()),
          GallerySection(title: 'Stats & money', child: MoneySamples()),
          GallerySection(title: 'Buttons', child: ButtonSamples()),
          GallerySection(title: 'Inputs', child: InputSamples()),
          GallerySection(title: 'Data table', child: TableSample()),
          GallerySection(title: 'Feedback', child: FeedbackSamples()),
        ],
      ),
    );
  }
}
