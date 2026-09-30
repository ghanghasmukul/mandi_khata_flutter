import 'package:mandi_khata_app/core/auth/app_lock/app_lock.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gate.g.dart';

/// Where the user is in getting into the app. Drives the router guards.
enum GateStep {
  /// Clearing a previous user's local data.
  starting,
  signedOut,
  locked,
  chooseTenant,

  /// First run on a lockable device: offer to set a PIN.
  setupPin,
  ready,
}

@riverpod
GateStep gateStep(Ref ref) {
  final session = ref.watch(sessionProvider);
  switch (session) {
    case SessionPreparing():
      return GateStep.starting;
    case SignedOut():
      return GateStep.signedOut;
    case SignedIn():
      break;
  }
  final lock = ref.watch(appLockProvider);
  if (lock.locked) return GateStep.locked;
  if (ref.watch(activeTenantProvider) == null) return GateStep.chooseTenant;
  if (lock.setupPromptPending) return GateStep.setupPin;
  return GateStep.ready;
}

abstract final class GateRoutes {
  static const home = '/';
  static const splash = '/splash';
  static const login = '/login';
  static const lock = '/lock';
  static const selectTenant = '/select-tenant';
  static const setPin = '/set-pin';
}

/// The go_router redirect: null to stay, else where to go.
///
/// Developer pages (`/dev/…`, debug builds only) are never redirected.
String? redirectFor(GateStep step, String location) {
  if (location.startsWith('/dev/')) return null;
  final required = switch (step) {
    GateStep.starting => GateRoutes.splash,
    GateStep.signedOut => GateRoutes.login,
    GateStep.locked => GateRoutes.lock,
    GateStep.chooseTenant => GateRoutes.selectTenant,
    GateStep.setupPin => GateRoutes.setPin,
    GateStep.ready => null,
  };
  if (required != null) return location == required ? null : required;
  // Ready: leave the gate pages. /set-pin stays reachable to change the PIN.
  const gatePages = {
    GateRoutes.splash,
    GateRoutes.login,
    GateRoutes.lock,
    GateRoutes.selectTenant,
  };
  return gatePages.contains(location) ? GateRoutes.home : null;
}
