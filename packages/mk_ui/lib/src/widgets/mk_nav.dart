import 'package:flutter/material.dart';
import 'package:mk_ui/src/theme.dart';
import 'package:mk_ui/src/tokens.dart';

/// A navigation destination.
@immutable
class MkNavItem {
  const MkNavItem({
    required this.id,
    required this.icon,
    required this.label,
    this.badge,
  });

  /// Stable id, usually the route name.
  final String id;
  final IconData icon;
  final String label;

  /// Small gold count or tag, e.g. "4" pending receipts.
  final String? badge;
}

/// A titled group of destinations in the sidebar: Mandi, Shop, Accounts,
/// Admin.
@immutable
class MkNavSection {
  const MkNavSection({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<MkNavItem> items;
}

/// Logo, product name and business name at the top of the sidebar.
class MkSidebarBrand extends StatelessWidget {
  const MkSidebarBrand({
    required this.appName,
    super.key,
    this.businessName,
    this.compact = false,
  });

  final String appName;
  final String? businessName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final mark = Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.gold,
        borderRadius: BorderRadius.circular(MkRadius.md),
      ),
      child: const Text(
        'म',
        style: TextStyle(
          color: MkColors.brandDark,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
    if (compact) return Semantics(label: appName, child: mark);
    return Row(
      children: [
        mark,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appName,
                style: TextStyle(
                  color: tokens.sidebarText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (businessName != null)
                Text(
                  businessName!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: tokens.sidebarMuted, fontSize: 11),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dark green side navigation with collapsible sections.
///
/// With [compact] it becomes an icon-only rail (labels in tooltips), used by
/// `MkAppShell` on medium widths.
class MkSidebar extends StatefulWidget {
  const MkSidebar({
    required this.sections,
    required this.selectedId,
    required this.onSelect,
    super.key,
    this.header,
    this.footer,
    this.compact = false,
  });

  final List<MkNavSection> sections;
  final String? selectedId;
  final ValueChanged<MkNavItem> onSelect;

  /// Usually an [MkSidebarBrand].
  final Widget? header;

  /// Sync status and the signed-in user.
  final Widget? footer;
  final bool compact;

  static const width = 236.0;
  static const compactWidth = 76.0;

  @override
  State<MkSidebar> createState() => _MkSidebarState();
}

class _MkSidebarState extends State<MkSidebar> {
  final _collapsed = <String>{};

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final compact = widget.compact;
    return Material(
      color: tokens.sidebar,
      child: SizedBox(
        width: compact ? MkSidebar.compactWidth : MkSidebar.width,
        child: SafeArea(
          right: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.header != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 21 : 18,
                    18,
                    compact ? 21 : 18,
                    16,
                  ),
                  child: widget.header,
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    for (final section in widget.sections) ..._section(section),
                  ],
                ),
              ),
              if (widget.footer != null)
                Container(
                  margin: const EdgeInsets.only(top: MkSpacing.sm),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: tokens.sidebarDivider),
                    ),
                  ),
                  child: widget.footer,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _section(MkNavSection section) {
    final tokens = MkTokens.of(context);
    final collapsed = _collapsed.contains(section.id) && !widget.compact;
    return [
      if (widget.compact)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Divider(color: tokens.sidebarDivider),
        )
      else
        _SectionHeader(
          title: section.title,
          collapsed: collapsed,
          onToggle: () => setState(() {
            if (!_collapsed.remove(section.id)) _collapsed.add(section.id);
          }),
        ),
      if (!collapsed)
        for (final item in section.items)
          _SidebarTile(
            item: item,
            selected: item.id == widget.selectedId,
            compact: widget.compact,
            onTap: () => widget.onSelect(item),
          ),
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.collapsed,
    required this.onToggle,
  });

  final String title;
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    return Semantics(
      button: true,
      expanded: !collapsed,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(MkRadius.sm),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 6, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: MkText.caps(tokens.sidebarMuted),
                ),
              ),
              Icon(
                collapsed ? Icons.chevron_right : Icons.expand_more,
                size: 16,
                color: tokens.sidebarMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final MkNavItem item;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final fg = selected ? Colors.white : MkColors.sidebarItem;
    final bg = selected ? tokens.sidebarHover : Colors.transparent;
    final badge = item.badge == null ? null : _Badge(item.badge!);
    final touch = mkIsTouch(context);

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(MkRadius.md),
        child: InkWell(
          onTap: onTap,
          hoverColor: selected ? null : tokens.sidebarHover,
          borderRadius: BorderRadius.circular(MkRadius.md),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: touch ? 48 : 38),
            child: compact
                ? Center(
                    child: Badge(
                      isLabelVisible: badge != null,
                      backgroundColor: tokens.gold,
                      smallSize: 8,
                      child: Icon(item.icon, size: 20, color: fg),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(item.icon, size: 18, color: fg),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fg,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ?badge,
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );

    final semantic = Semantics(
      selected: selected,
      button: true,
      label: compact ? item.label : null,
      child: tile,
    );
    return compact
        ? Tooltip(message: item.label, preferBelow: false, child: semantic)
        : semantic;
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: MkTokens.of(context).gold,
        borderRadius: BorderRadius.circular(MkRadius.pill),
      ),
      child: Text(
        text,
        style: MkText.mono(
          size: 10.5,
          weight: FontWeight.w600,
          color: MkColors.brandDark,
        ),
      ),
    );
  }
}

/// Bottom navigation for phones. Keep it to five items or fewer.
class MkBottomNav extends StatelessWidget {
  const MkBottomNav({
    required this.items,
    required this.selectedId,
    required this.onSelect,
    super.key,
  });

  final List<MkNavItem> items;
  final String? selectedId;
  final ValueChanged<MkNavItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    return Material(
      color: tokens.surfaceAlt,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (final item in items)
                  Expanded(
                    child: _BottomNavTile(
                      item: item,
                      selected: item.id == selectedId,
                      onTap: () => onSelect(item),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavTile extends StatelessWidget {
  const _BottomNavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final MkNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final fg = selected ? MkColors.brand : tokens.textMuted;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: selected ? tokens.jamaTint : Colors.transparent,
                borderRadius: BorderRadius.circular(MkRadius.pill),
              ),
              child: Badge(
                isLabelVisible: item.badge != null,
                label: item.badge == null ? null : Text(item.badge!),
                backgroundColor: tokens.gold,
                textColor: MkColors.brandDark,
                child: Icon(item.icon, size: 22, color: fg),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
