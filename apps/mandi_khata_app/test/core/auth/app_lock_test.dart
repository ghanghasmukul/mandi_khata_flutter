import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/auth/app_lock/app_lock.dart';
import 'package:mandi_khata_app/core/auth/app_lock/biometric_auth.dart';
import 'package:mandi_khata_app/core/auth/app_lock/pin_hasher.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/utils/clock.dart';

import '../../helpers/fakes.dart';

class FakeBiometric implements BiometricAuth {
  bool result = true;
  int prompts = 0;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return result;
  }

  @override
  Future<bool> isAvailable() async => true;
}

void main() {
  late AppPrefs prefs;
  late DateTime now;
  late FakeBiometric biometric;

  setUp(() async {
    prefs = await makePrefs();
    await prefs.setDataOwnerUserId(userA.id);
    now = DateTime.utc(2026, 9, 30, 10);
    biometric = FakeBiometric();
  });

  ProviderContainer container({
    AuthUser? user = userA,
    bool supported = true,
    FakeAuthRepository? auth,
  }) {
    return ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          auth ?? FakeAuthRepository(user),
        ),
        appPrefsProvider.overrideWithValue(prefs),
        localDataWiperProvider.overrideWithValue(() async {}),
        appLockSupportedProvider.overrideWithValue(supported),
        clockProvider.overrideWithValue(() => now),
        biometricAuthProvider.overrideWithValue(biometric),
      ],
    )..listen(appLockProvider, (_, _) {});
  }

  Future<void> storePin(String pin) =>
      prefs.setPin(PinHasher.create(pin, iterations: 10));

  test('no PIN: unlocked, and offers to set one until skipped', () async {
    final c = container();
    expect(c.read(appLockProvider).locked, isFalse);
    expect(c.read(appLockProvider).setupPromptPending, isTrue);

    await c.read(appLockProvider.notifier).skipSetup();
    expect(c.read(appLockProvider).setupPromptPending, isFalse);
  });

  test('setting a PIN does not lock the app straight away', () async {
    final c = container();
    await c.read(appLockProvider.notifier).setPin('4821');
    final s = c.read(appLockProvider);
    expect(s.hasPin, isTrue);
    expect(s.locked, isFalse);
    expect(s.pinLength, 4);
    expect(s.setupPromptPending, isFalse);
    expect(PinHasher.verify('4821', prefs.pin!), isTrue);
  });

  test('cold start with a PIN is locked; right PIN unlocks', () async {
    await storePin('482913');
    final c = container();
    expect(c.read(appLockProvider).locked, isTrue);

    final result = await c.read(appLockProvider.notifier).unlock('482913');
    expect(result, UnlockResult.unlocked);
    expect(c.read(appLockProvider).locked, isFalse);
  });

  test('wrong PINs: five free tries, then a cooldown that survives a '
      'restart', () async {
    await storePin('1234');
    var c = container();
    final lock = c.read(appLockProvider.notifier);
    for (var i = 0; i < 5; i++) {
      expect(await lock.unlock('0000'), UnlockResult.wrongPin);
    }
    expect(
      c.read(appLockProvider).cooldownUntil,
      now.add(const Duration(seconds: 30)),
    );
    // Even the right PIN waits out the cooldown.
    expect(await lock.unlock('1234'), UnlockResult.coolingDown);

    // Killing the app does not reset it.
    c.dispose();
    c = container();
    expect(c.read(appLockProvider).failures, 5);
    expect(
      await c.read(appLockProvider.notifier).unlock('1234'),
      UnlockResult.coolingDown,
    );

    now = now.add(const Duration(seconds: 31));
    expect(
      await c.read(appLockProvider.notifier).unlock('1234'),
      UnlockResult.unlocked,
    );
    expect(c.read(appLockProvider).failures, 0);
    expect(prefs.pinCooldownUntil, isNull);
  });

  test('locks again only after two minutes in the background', () async {
    await storePin('1234');
    final c = container();
    final lock = c.read(appLockProvider.notifier);
    await lock.unlock('1234');

    lock.onBackgrounded();
    now = now.add(const Duration(minutes: 1));
    lock.onResumed();
    expect(c.read(appLockProvider).locked, isFalse);

    lock.onBackgrounded();
    now = now.add(const Duration(minutes: 3));
    lock.onResumed();
    expect(c.read(appLockProvider).locked, isTrue);
  });

  test('signing in never locks (the user just proved who they are)', () async {
    await storePin('1234');
    final auth = FakeAuthRepository();
    final c = container(auth: auth);
    expect(c.read(appLockProvider).locked, isFalse);

    auth.emit(userA);
    await pumpEventQueue();
    expect(c.read(sessionProvider), isA<SignedIn>());
    expect(c.read(appLockProvider).locked, isFalse);
    expect(c.read(appLockProvider).hasPin, isTrue);
  });

  test('web (unsupported): never locked, never prompted', () async {
    await storePin('1234');
    final c = container(supported: false);
    final s = c.read(appLockProvider);
    expect(s.locked, isFalse);
    expect(s.hasPin, isFalse);
    expect(s.setupPromptPending, isFalse);
  });

  test('biometric unlock only when enabled', () async {
    await storePin('1234');
    final c = container();
    final lock = c.read(appLockProvider.notifier);
    expect(await lock.unlockWithBiometric('Unlock'), isFalse);
    expect(biometric.prompts, 0);

    await lock.setBiometric(enabled: true);
    expect(await lock.unlockWithBiometric('Unlock'), isTrue);
    expect(c.read(appLockProvider).locked, isFalse);
  });

  test('removing the PIN unlocks and turns biometrics off', () async {
    await storePin('1234');
    await prefs.setBiometricUnlock(enabled: true);
    final c = container();
    await c.read(appLockProvider.notifier).removePin();
    final s = c.read(appLockProvider);
    expect(s.hasPin, isFalse);
    expect(s.locked, isFalse);
    expect(s.biometricEnabled, isFalse);
    expect(s.setupPromptPending, isFalse);
  });
}
