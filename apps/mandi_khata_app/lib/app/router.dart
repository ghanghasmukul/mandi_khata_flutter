import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/app/home_screen.dart';
import 'package:mandi_khata_app/features/dev_gallery/presentation/gallery_screen.dart';
import 'package:mandi_khata_app/features/dev_sync/presentation/dev_sync_screen.dart';

abstract final class AppRoutes {
  static const home = '/';

  /// Design-system gallery. Not registered in release builds.
  static const gallery = '/dev/gallery';

  /// Offline / sync test bench. Not registered in release builds.
  static const sync = '/dev/sync';
}

/// Builds the app's router. Auth and tenant guards arrive in step 0.5.
GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      if (!kReleaseMode) ...[
        GoRoute(
          path: AppRoutes.gallery,
          builder: (context, state) => const GalleryScreen(),
        ),
        GoRoute(
          path: AppRoutes.sync,
          builder: (context, state) => const DevSyncScreen(),
        ),
      ],
    ],
  );
}
