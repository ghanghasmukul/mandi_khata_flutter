import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/device_registrar.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';

import '../../helpers/fakes.dart';

const gupta = Membership(
  tenantId: 't-gupta',
  tenantName: 'Gupta Trading Co.',
  role: MemberRole.owner,
);
const sharma = Membership(
  tenantId: 't-sharma',
  tenantName: 'Sharma Arhat Agency',
  role: MemberRole.munshi,
);

void main() {
  late AppPrefs prefs;
  late FakeRegistrar registrar;
  late FakeAuthRepository auth;
  late StreamController<List<Membership>> memberships;
  late ValueNotifier<bool> synced;

  setUp(() async {
    prefs = await makePrefs();
    await prefs.setDataOwnerUserId(userA.id);
    registrar = FakeRegistrar();
    auth = FakeAuthRepository(userA);
    memberships = StreamController.broadcast();
    synced = ValueNotifier(false);
  });

  tearDown(() async {
    await memberships.close();
    synced.dispose();
  });

  ProviderContainer container() {
    return ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        appPrefsProvider.overrideWithValue(prefs),
        localDataWiperProvider.overrideWithValue(() async {}),
        deviceRegistrarProvider.overrideWithValue(registrar),
        myMembershipsProvider.overrideWith((ref) => memberships.stream),
        hasSyncedProvider.overrideWith((ref) {
          void changed() => ref.invalidateSelf();
          synced.addListener(changed);
          ref.onDispose(() => synced.removeListener(changed));
          return synced.value;
        }),
      ],
    )..listen(activeTenantProvider, (_, _) {});
  }

  test('nothing picked yet: null', () {
    expect(container().read(activeTenantProvider), isNull);
  });

  test('picking a business registers this device once and remembers '
      'both', () async {
    final c = container();
    await c.read(activeTenantProvider.notifier).select(gupta.tenantId);

    expect(c.read(activeTenantProvider), gupta.tenantId);
    expect(registrar.calls.single.tenantId, gupta.tenantId);
    expect(registrar.calls.single.platform, 'android');
    expect(prefs.lastTenantId, gupta.tenantId);
    final device = prefs.device(gupta.tenantId)!;
    expect(device.code, 'A1');
    expect(device.id, registrar.calls.single.deviceId);
    expect(c.read(activeDeviceProvider)?.code, 'A1');
  });

  test('each business gets its own device row and code', () async {
    final c = container();
    final tenant = c.read(activeTenantProvider.notifier);
    await tenant.select(gupta.tenantId);
    await tenant.select(sharma.tenantId);

    expect(prefs.device(gupta.tenantId)!.code, 'A1');
    expect(prefs.device(sharma.tenantId)!.code, 'A2');
    expect(
      prefs.device(gupta.tenantId)!.id,
      isNot(prefs.device(sharma.tenantId)!.id),
    );
  });

  test(
    're-picking reuses the stored code (only a last-seen refresh)',
    () async {
      final c = container();
      final tenant = c.read(activeTenantProvider.notifier);
      await tenant.select(gupta.tenantId);
      final device = prefs.device(gupta.tenantId)!;
      await tenant.clear();
      await tenant.select(gupta.tenantId);
      await pumpEventQueue();

      expect(prefs.device(gupta.tenantId), device);
      expect(registrar.calls.map((c) => c.deviceId).toSet(), {device.id});
    },
  );

  test('offline first pick fails cleanly and picks nothing', () async {
    registrar.failWith = const DeviceRegistrationException(offline: true);
    final c = container();
    await expectLater(
      c.read(activeTenantProvider.notifier).select(gupta.tenantId),
      throwsA(isA<DeviceRegistrationException>()),
    );
    expect(c.read(activeTenantProvider), isNull);
    expect(prefs.lastTenantId, isNull);
    expect(prefs.device(gupta.tenantId), isNull);
  });

  test('offline launch restores the last business without a network', () async {
    await prefs.setDevice(gupta.tenantId, (id: 'dev-1', code: 'W1'));
    await prefs.setLastTenantId(gupta.tenantId);
    registrar.failWith = const DeviceRegistrationException(offline: true);

    final c = container();
    expect(c.read(activeTenantProvider), gupta.tenantId);
    await pumpEventQueue();
    // The last-seen refresh was attempted and failed quietly.
    expect(registrar.calls, hasLength(1));
    expect(c.read(activeTenantProvider), gupta.tenantId);
  });

  test('a remembered business without a device code is not active', () async {
    await prefs.setLastTenantId(gupta.tenantId);
    expect(container().read(activeTenantProvider), isNull);
  });

  test('removed from the business: dropped once a full sync confirms '
      'it', () async {
    await prefs.setDevice(gupta.tenantId, (id: 'dev-1', code: 'W1'));
    await prefs.setLastTenantId(gupta.tenantId);
    final c = container();

    // Before the first full sync an empty list proves nothing.
    memberships.add(const [sharma]);
    await pumpEventQueue();
    expect(c.read(activeTenantProvider), gupta.tenantId);

    synced.value = true;
    await pumpEventQueue();
    expect(c.read(activeTenantProvider), isNull);
    expect(prefs.lastTenantId, isNull);
  });

  test('signing out clears the active business', () async {
    final c = container();
    await c.read(activeTenantProvider.notifier).select(gupta.tenantId);
    auth.emit(null);
    await pumpEventQueue();
    expect(c.read(sessionProvider), isA<SignedOut>());
    expect(c.read(activeTenantProvider), isNull);
  });
}
