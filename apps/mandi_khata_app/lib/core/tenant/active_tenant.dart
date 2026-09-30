import 'dart:async';

import 'package:logging/logging.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/device_registrar.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'active_tenant.g.dart';

final _log = Logger('tenant');

/// The business the app is working in (its id), or null until one is
/// picked. Every business query filters by this (CLAUDE.md rule 1).
///
/// Restored from the last session without any network, so an offline launch
/// opens straight into the last business.
@Riverpod(keepAlive: true)
class ActiveTenant extends _$ActiveTenant {
  @override
  String? build() {
    final session = ref.watch(sessionProvider);
    if (session is! SignedIn) return null;

    ref
      ..listen(myMembershipsProvider, (_, _) => _dropIfNoLongerMember())
      ..listen(hasSyncedProvider, (_, _) => _dropIfNoLongerMember());

    final id = _prefs.lastTenantId;
    // A business only becomes active once this device has a code in it.
    final device = id == null ? null : _prefs.device(id);
    if (id == null || device == null) return null;
    scheduleMicrotask(() => _touch(id, device.id));
    return id;
  }

  AppPrefs get _prefs => ref.read(appPrefsProvider);

  /// Makes [tenantId] active, registering this device in it first if needed
  /// (that needs internet once per business).
  ///
  /// Throws [DeviceRegistrationException].
  Future<void> select(String tenantId) async {
    final existing = _prefs.device(tenantId);
    if (existing == null) {
      final platform = currentDevicePlatform();
      if (platform == null) {
        throw const DeviceRegistrationException(
          offline: false,
          detail: 'unsupported platform',
        );
      }
      final deviceId = const Uuid().v4();
      final code = await ref
          .read(deviceRegistrarProvider)
          .register(deviceId: deviceId, tenantId: tenantId, platform: platform);
      await _prefs.setDevice(tenantId, (id: deviceId, code: code));
    } else {
      unawaited(_touch(tenantId, existing.id));
    }
    await _prefs.setLastTenantId(tenantId);
    state = tenantId;
  }

  /// Back to the business picker ("switch business").
  Future<void> clear() async {
    await _prefs.setLastTenantId(null);
    state = null;
  }

  /// Updates `last_seen_at` when online; silently skipped offline.
  Future<void> _touch(String tenantId, String deviceId) async {
    final platform = currentDevicePlatform();
    if (platform == null) return;
    try {
      await ref
          .read(deviceRegistrarProvider)
          .register(deviceId: deviceId, tenantId: tenantId, platform: platform);
    } on DeviceRegistrationException catch (e) {
      if (!e.offline) _log.warning('Device refresh refused: ${e.detail}');
    }
  }

  /// Removed or deactivated members lose the business once a full sync
  /// confirms it (never on a half-downloaded database).
  void _dropIfNoLongerMember() {
    final id = state;
    if (id == null) return;
    final memberships = ref.read(myMembershipsProvider).value;
    if (memberships == null || !ref.read(hasSyncedProvider)) return;
    if (memberships.any((m) => m.tenantId == id)) return;
    _log.info('No longer a member of the active business');
    unawaited(clear());
  }
}

/// This device's registration in the active business.
@riverpod
DeviceRegistration? activeDevice(Ref ref) {
  final tenantId = ref.watch(activeTenantProvider);
  return tenantId == null ? null : ref.read(appPrefsProvider).device(tenantId);
}

/// The signed-in user's membership in the active business, once loaded.
@riverpod
Membership? activeMembership(Ref ref) {
  final tenantId = ref.watch(activeTenantProvider);
  final memberships = ref.watch(myMembershipsProvider).value;
  if (tenantId == null || memberships == null) return null;
  for (final m in memberships) {
    if (m.tenantId == tenantId) return m;
  }
  return null;
}
