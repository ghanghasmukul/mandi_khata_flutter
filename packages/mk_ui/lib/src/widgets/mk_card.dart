import 'package:flutter/material.dart';
import 'package:mk_ui/src/theme.dart';
import 'package:mk_ui/src/tokens.dart';

/// White rounded card with the soft brand shadow.
class MkCard extends StatelessWidget {
  const MkCard({
    required this.child,
    super.key,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  final Widget child;

  /// Optional heading row, e.g. "Crop mix by sale value".
  final String? title;

  /// Shown at the end of the heading row.
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(MkRadius.lg);

    var content = child;
    if (title != null || trailing != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (title != null)
                Expanded(
                  child: Text(title!, style: theme.textTheme.titleMedium),
                )
              else
                const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: MkSpacing.lg),
          child,
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: radius,
        border: Border.all(color: tokens.border2),
        boxShadow: MkShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: content),
        ),
      ),
    );
  }
}

/// A headline number on a card: label, big mono value, optional note.
class MkStatTile extends StatelessWidget {
  const MkStatTile({
    required this.label,
    required this.value,
    super.key,
    this.sub,
    this.valueColor,
    this.onTap,
  });

  final String label;

  /// Pre-formatted value, e.g. `Money.short()` output or a count.
  final String value;
  final String? sub;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    return MkCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label.toUpperCase(), style: MkText.caps(tokens.textFaint)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                maxLines: 1,
                style: MkText.mono(
                  size: 25,
                  weight: FontWeight.w600,
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (sub != null) ...[
              const SizedBox(height: 6),
              Text(
                sub!,
                style: TextStyle(fontSize: 11.5, color: tokens.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
