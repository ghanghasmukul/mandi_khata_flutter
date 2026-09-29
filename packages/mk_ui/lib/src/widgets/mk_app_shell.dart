import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mk_ui/src/theme.dart';
import 'package:mk_ui/src/tokens.dart';
import 'package:mk_ui/src/widgets/mk_nav.dart';

/// Which navigation layout [MkAppShell] uses at a given width.
enum MkShellLayout {
  /// ≥ 1000 px: full sidebar with section titles.
  sidebar,

  /// 600–999 px: icon-only rail.
  rail,

  /// < 600 px: bottom navigation bar.
  bottom;

  static MkShellLayout forWidth(double width) {
    if (width >= MkBreakpoints.sidebar) return MkShellLayout.sidebar;
    if (width >= MkBreakpoints.rail) return MkShellLayout.rail;
    return MkShellLayout.bottom;
  }
}

/// Responsive app frame: navigation + top bar + screen body.
///
/// Also owns app-wide desktop shortcuts: Ctrl/⌘ K calls [onSearch].
class MkAppShell extends StatelessWidget {
  const MkAppShell({
    required this.sections,
    required this.selectedId,
    required this.onSelect,
    required this.body,
    required this.appName,
    super.key,
    this.businessName,
    this.topBar,
    this.sidebarFooter,
    this.bottomItems,
    this.onSearch,
  });

  final List<MkNavSection> sections;
  final String? selectedId;
  final ValueChanged<MkNavItem> onSelect;
  final Widget body;
  final String appName;
  final String? businessName;

  /// Usually an `MkTopBar`.
  final Widget? topBar;

  /// Sync status and user, shown under the full sidebar.
  final Widget? sidebarFooter;

  /// Destinations for the phone bottom bar (five at most). Defaults to the
  /// first five items across all sections.
  final List<MkNavItem>? bottomItems;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final layout = MkShellLayout.forWidth(MediaQuery.sizeOf(context).width);

    final main = Column(
      children: [
        ?topBar,
        Expanded(child: body),
      ],
    );

    final Widget scaffold;
    switch (layout) {
      case MkShellLayout.sidebar:
      case MkShellLayout.rail:
        final compact = layout == MkShellLayout.rail;
        scaffold = Scaffold(
          body: Row(
            children: [
              MkSidebar(
                sections: sections,
                selectedId: selectedId,
                onSelect: onSelect,
                compact: compact,
                header: MkSidebarBrand(
                  appName: appName,
                  businessName: businessName,
                  compact: compact,
                ),
                footer: compact ? null : sidebarFooter,
              ),
              Expanded(child: main),
            ],
          ),
        );
      case MkShellLayout.bottom:
        final items =
            bottomItems ??
            [for (final s in sections) ...s.items].take(5).toList();
        scaffold = Scaffold(
          body: main,
          bottomNavigationBar: MkBottomNav(
            items: items,
            selectedId: selectedId,
            onSelect: onSelect,
          ),
        );
    }

    if (onSearch == null) return scaffold;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            onSearch!,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): onSearch!,
      },
      child: Focus(autofocus: true, child: scaffold),
    );
  }
}

/// Sync state dot + label for the sidebar footer, e.g. "Synced · 2 min ago".
class MkSyncIndicator extends StatelessWidget {
  const MkSyncIndicator({required this.label, required this.ok, super.key});

  final String label;

  /// Green when synced, gold when offline or queued.
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: ok ? MkColors.synced : MkColors.pending,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: tokens.sidebarMuted),
          ),
        ),
      ],
    );
  }
}
