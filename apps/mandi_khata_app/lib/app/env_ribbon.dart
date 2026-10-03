import 'package:flutter/material.dart';

/// Corner ribbon marking a build made with the dev config, so nobody mistakes
/// it for the production app.
///
/// The label is a technical environment tag (like a version number), not
/// user-facing copy, so it is deliberately not translated. It sits bottom-right
/// to stay clear of the top bar's language and account buttons.
class EnvRibbon extends StatelessWidget {
  const EnvRibbon({required this.show, required this.child, super.key});

  /// Whether to draw the ribbon (see `Env.isDev`).
  final bool show;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!show) return child;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        message: 'DEV',
        location: BannerLocation.bottomEnd,
        color: const Color(0xFFD97706),
        child: child,
      ),
    );
  }
}
