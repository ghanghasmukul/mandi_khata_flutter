import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/app/env.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mk_ui/mk_ui.dart';

/// Placeholder start screen until auth and the dashboard exist.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MkSidebarBrand(appName: 'Mandi Khata', compact: true),
            const SizedBox(height: MkSpacing.lg),
            Text('Mandi Khata', style: theme.textTheme.displaySmall),
            const SizedBox(height: MkSpacing.sm),
            Text(
              Env.hasSupabase ? 'Configuration loaded' : 'No configuration',
              style: theme.textTheme.bodySmall,
            ),
            // Developer-only entry point; the route does not exist in release.
            if (!kReleaseMode) ...[
              const SizedBox(height: MkSpacing.xxl),
              MkButton(
                label: 'Design gallery',
                variant: MkButtonVariant.secondary,
                icon: Icons.palette_outlined,
                onPressed: () => context.go(AppRoutes.gallery),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
