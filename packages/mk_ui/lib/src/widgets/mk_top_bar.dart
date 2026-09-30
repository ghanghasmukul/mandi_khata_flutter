import 'package:flutter/material.dart';
import 'package:mk_ui/src/theme.dart';
import 'package:mk_ui/src/tokens.dart';

/// A language offered in the top bar switcher.
@immutable
class MkLanguage {
  const MkLanguage({required this.code, required this.label});

  /// Locale code: `en`, `hi`, `pa`.
  final String code;

  /// Short native label: `EN`, `हिं`, `ਪੰ`.
  final String label;
}

/// Screen header: title, subtitle, search (Ctrl/⌘ K), language switcher and
/// the current role.
///
/// The Ctrl/⌘ K shortcut itself is registered by `MkAppShell` so it works
/// wherever focus is; this bar only shows the hint and handles taps.
class MkTopBar extends StatelessWidget {
  const MkTopBar({
    required this.title,
    super.key,
    this.subtitle,
    this.searchHint,
    this.onSearch,
    this.languages = const [],
    this.language,
    this.onLanguage,
    this.roleLabel,
    this.roleNote,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;

  /// Placeholder in the search pill, e.g. "Search farmer, lot, receipt…".
  final String? searchHint;

  /// Opens search. The pill is hidden when null.
  final VoidCallback? onSearch;
  final List<MkLanguage> languages;
  final String? language;
  final ValueChanged<String>? onLanguage;

  /// Signed-in role, e.g. "Owner".
  final String? roleLabel;

  /// Gold warning next to the role, e.g. "Munshi role: deletes are blocked".
  final String? roleNote;
  final List<Widget> actions;

  /// Key hint for the platform: ⌘K on Apple, Ctrl K elsewhere.
  static String shortcutHint(TargetPlatform platform) =>
      platform == TargetPlatform.macOS || platform == TargetPlatform.iOS
      ? '⌘K'
      : 'Ctrl K';

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < MkBreakpoints.rail;
        return Material(
          color: tokens.surfaceAlt,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: tokens.border)),
            ),
            child: SafeArea(
              bottom: false,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 58),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: narrow ? 12 : 20,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      // On phones the title takes the free space and
                      // ellipsizes, so a long business name never overflows.
                      if (narrow)
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            style: theme.textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        Flexible(
                          flex: 0,
                          child: Text(
                            title,
                            style: theme.textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(width: 14),
                      if (!narrow)
                        Expanded(
                          child: subtitle == null
                              ? const SizedBox.shrink()
                              : Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: tokens.textMuted,
                                  ),
                                ),
                        ),
                      if (onSearch != null && narrow)
                        IconButton(
                          onPressed: onSearch,
                          tooltip: searchHint,
                          icon: const Icon(Icons.search),
                        )
                      else if (onSearch != null)
                        Flexible(
                          flex: 2,
                          child: _SearchPill(
                            hint: searchHint ?? '',
                            onTap: onSearch!,
                          ),
                        ),
                      if (languages.isNotEmpty && !narrow) ...[
                        const SizedBox(width: 12),
                        MkLanguageSwitcher(
                          languages: languages,
                          selected: language,
                          onSelect: onLanguage,
                        ),
                      ],
                      if (roleNote != null && !narrow) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          flex: 2,
                          child: MkRoleChip(label: roleNote!, warning: true),
                        ),
                      ],
                      if (roleLabel != null && !narrow) ...[
                        const SizedBox(width: 12),
                        MkRoleChip(label: roleLabel!),
                      ],
                      ...actions,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    return Semantics(
      button: true,
      label: hint,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Material(
          color: tokens.field,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MkRadius.md),
            side: BorderSide(color: tokens.border),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(MkRadius.md),
            child: LayoutBuilder(
              // Too narrow for the hint text: show just the icon.
              builder: (context, c) => c.maxWidth < 150
                  ? Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(
                        Icons.search,
                        size: 18,
                        color: tokens.textFaint,
                      ),
                    )
                  : _full(context, tokens),
            ),
          ),
        ),
      ),
    );
  }

  Widget _full(BuildContext context, MkTokens tokens) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: tokens.textFaint),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: tokens.textFaint),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: tokens.surfaceAlt,
              border: Border.all(color: tokens.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              MkTopBar.shortcutHint(Theme.of(context).platform),
              style: MkText.mono(size: 10.5, color: tokens.textFaint),
            ),
          ),
        ],
      ),
    );
  }
}

/// Segmented EN / हिं / ਪੰ switch.
class MkLanguageSwitcher extends StatelessWidget {
  const MkLanguageSwitcher({
    required this.languages,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<MkLanguage> languages;
  final String? selected;
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final touch = mkIsTouch(context);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: tokens.field,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(MkRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final lang in languages)
            Semantics(
              button: true,
              selected: lang.code == selected,
              child: Material(
                color: lang.code == selected
                    ? MkColors.brandDark
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(MkRadius.sm),
                child: InkWell(
                  onTap: onSelect == null ? null : () => onSelect!(lang.code),
                  borderRadius: BorderRadius.circular(MkRadius.sm),
                  child: Container(
                    constraints: touch
                        ? const BoxConstraints(minWidth: 48, minHeight: 48)
                        : null,
                    alignment: touch ? Alignment.center : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    child: Text(
                      lang.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: lang.code == selected
                            ? MkColors.surfaceAlt
                            : tokens.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small pill naming the current role, or (with [warning]) a gold role note.
class MkRoleChip extends StatelessWidget {
  const MkRoleChip({required this.label, super.key, this.warning = false});

  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: warning ? tokens.goldTint : tokens.surfaceAlt,
        border: warning ? null : Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(MkRadius.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: warning
              ? tokens.goldText
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
