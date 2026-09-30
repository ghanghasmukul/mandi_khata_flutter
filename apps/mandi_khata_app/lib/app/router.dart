import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/app/home_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/lock_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/login_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/select_tenant_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/set_pin_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/splash_screen.dart';
import 'package:mandi_khata_app/features/dev_gallery/presentation/gallery_screen.dart';
import 'package:mandi_khata_app/features/dev_sync/presentation/dev_sync_screen.dart';
import 'package:mandi_khata_app/features/diagnostics/presentation/diagnostics_screen.dart';
import 'package:mandi_khata_app/features/settings/presentation/settings_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

abstract final class AppRoutes {
  static const String home = GateRoutes.home;
  static const String login = GateRoutes.login;
  static const String selectTenant = GateRoutes.selectTenant;
  static const String lock = GateRoutes.lock;
  static const String setPin = GateRoutes.setPin;
  static const settings = '/settings';

  /// Owner-only health page. In every build (support needs it).
  static const diagnostics = '/dev/diagnostics';

  /// Design-system gallery. Not registered in release builds.
  static const gallery = '/dev/gallery';

  /// Offline / sync test bench. Not registered in release builds.
  static const sync = '/dev/sync';
}

/// The app's router. Guards follow [gateStepProvider]: signed out → login,
/// locked → PIN, no business → picker.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final refresh = ValueNotifier<GateStep>(ref.read(gateStepProvider));
  ref.listen(gateStepProvider, (_, step) => refresh.value = step);

  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) =>
        redirectFor(refresh.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: GateRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectTenant,
        builder: (context, state) => const SelectTenantScreen(),
      ),
      GoRoute(
        path: AppRoutes.lock,
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: AppRoutes.setPin,
        builder: (context, state) => const SetPinScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.diagnostics,
        builder: (context, state) => const DiagnosticsScreen(),
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
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
}
