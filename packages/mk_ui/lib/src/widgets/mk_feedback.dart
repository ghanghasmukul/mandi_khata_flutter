import 'package:flutter/material.dart';
import 'package:mk_ui/src/theme.dart';
import 'package:mk_ui/src/tokens.dart';

/// Placeholder for an empty list or screen: icon, title, message, action.
class MkEmptyState extends StatelessWidget {
  const MkEmptyState({
    required this.title,
    super.key,
    this.icon = Icons.inbox_outlined,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// Usually an `MkButton`.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MkSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tokens.field,
                  borderRadius: BorderRadius.circular(MkRadius.lg),
                ),
                child: Icon(icon, color: tokens.textFaint, size: 26),
              ),
              const SizedBox(height: MkSpacing.lg),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  style: TextStyle(fontSize: 12.5, color: tokens.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: MkSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum MkToastTone { info, success, error }

/// Short confirmation at the bottom centre ("Receipt R-3008 saved").
abstract final class MkToast {
  static void show(
    BuildContext context,
    String message, {
    MkToastTone tone = MkToastTone.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final tokens = MkTokens.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final icon = switch (tone) {
      MkToastTone.info => null,
      MkToastTone.success => Icon(
        Icons.check_circle,
        size: 16,
        color: tokens.gold,
      ),
      MkToastTone.error => Icon(
        Icons.error_outline,
        size: 16,
        color: tokens.udhaar,
      ),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          width: width >= MkBreakpoints.rail ? 420 : null,
          content: Row(
            children: [
              if (icon != null) ...[icon, const SizedBox(width: 10)],
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}

/// Centred modal card with a title, body and actions. Esc closes it.
class MkDialog extends StatelessWidget {
  const MkDialog({
    required this.title,
    required this.content,
    super.key,
    this.actions = const [],
    this.maxWidth = 440,
  });

  final String title;
  final Widget content;

  /// Usually `MkButton`s; the last one is the main action.
  final List<Widget> actions;
  final double maxWidth;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: MkColors.scrim,
      builder: (_) =>
          MkDialog(title: title, content: content, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(MkSpacing.xxl),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(MkSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: MkSpacing.md),
              Flexible(
                child: SingleChildScrollView(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: 13,
                      color: MkTokens.of(context).textBody,
                    ),
                    child: content,
                  ),
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: MkSpacing.xl),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: MkSpacing.sm,
                  runSpacing: MkSpacing.sm,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
