import 'package:mandi_khata_app/core/auth/app_lock/app_lock.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/device_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gate.g.dart';

/// Where the user is in getting into the app. Drives the router guards.
enum GateStep {
  /// Clearing a previous user's local data.
  starting,
  signedOut,
  locked,
  chooseTenant,

  /// The owner revoked this install: nothing else is reachable.
  deviceRevoked,

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
  if (ref.watch(deviceRevokedProvider).value ?? false) {
    return GateStep.deviceRevoked;
  }
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
  static const deviceRevoked = '/device-revoked';

  /// Developer pages that exist only in debug builds and work signed out.
  static const debugOnly = {'/dev/gallery', '/dev/sync'};
}

/// The go_router redirect: null to stay, else where to go.
///
/// Debug-only developer pages ([GateRoutes.debugOnly]) are never
/// redirected; `/dev/diagnostics` ships in release and is guarded like any
/// other page.
String? redirectFor(GateStep step, String location) {
  if (GateRoutes.debugOnly.contains(location)) return null;
  final required = switch (step) {
    GateStep.starting => GateRoutes.splash,
    GateStep.signedOut => GateRoutes.login,
    GateStep.locked => GateRoutes.lock,
    GateStep.chooseTenant => GateRoutes.selectTenant,
    GateStep.deviceRevoked => GateRoutes.deviceRevoked,
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
    GateRoutes.deviceRevoked,
  };
  return gatePages.contains(location) ? GateRoutes.home : null;
}
