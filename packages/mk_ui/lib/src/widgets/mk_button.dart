import 'package:flutter/material.dart';
import 'package:mk_ui/src/theme.dart';
import 'package:mk_ui/src/tokens.dart';

enum MkButtonVariant { primary, secondary, ghost, danger }

/// The one button used across the app. Built on [TextButton], so focus,
/// Enter/Space activation and semantics come for free.
class MkButton extends StatelessWidget {
  const MkButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = MkButtonVariant.primary,
    this.icon,
    this.busy = false,
    this.expand = false,
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final MkButtonVariant variant;
  final IconData? icon;

  /// Shows a spinner and ignores taps (e.g. while saving).
  final bool busy;

  /// Fill the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final (bg, fg, border, hover) = switch (variant) {
      MkButtonVariant.primary => (
        MkColors.brand,
        Colors.white,
        null,
        MkColors.brandHover,
      ),
      MkButtonVariant.secondary => (
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.onSurface,
        tokens.border,
        tokens.rowHover,
      ),
      MkButtonVariant.ghost => (
        Colors.transparent,
        MkColors.brand,
        null,
        tokens.jamaTint,
      ),
      MkButtonVariant.danger => (
        tokens.udhaar,
        Colors.white,
        null,
        Color.lerp(tokens.udhaar, Colors.black, 0.12)!,
      ),
    };
    final minHeight = mkIsTouch(context) ? 48.0 : 40.0;

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(64, minHeight)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MkRadius.md),
          side: border == null ? BorderSide.none : BorderSide(color: border),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return variant == MkButtonVariant.ghost ? null : tokens.field;
        }
        if (states.contains(WidgetState.hovered)) return hover;
        return bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled) ? tokens.textFaint : fg,
      ),
      overlayColor: WidgetStatePropertyAll(fg.withValues(alpha: 0.08)),
      // Button text styles don't inherit the theme font; set it explicitly.
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontFamily: MkFonts.sans,
          fontFamilyFallback: MkFonts.fallback,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    final child = busy
        ? SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16),
                const SizedBox(width: MkSpacing.sm),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    // While busy the button keeps its colours (a spinner on a greyed-out
    // button reads as "disabled") but swallows taps.
    final button = TextButton(
      onPressed: busy && onPressed != null ? () {} : onPressed,
      style: style,
      child: Semantics(label: busy ? label : null, child: child),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
