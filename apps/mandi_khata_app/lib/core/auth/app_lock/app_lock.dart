import 'package:flutter/foundation.dart';
import 'package:mandi_khata_app/core/auth/app_lock/biometric_auth.dart';
import 'package:mandi_khata_app/core/auth/app_lock/lock_policy.dart';
import 'package:mandi_khata_app/core/auth/app_lock/pin_hasher.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/utils/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lock.g.dart';

/// PIN lock is for devices that stay signed in at a counter or in a pocket;
/// the web app relies on the browser session instead.
@Riverpod(keepAlive: true)
bool appLockSupported(Ref ref) =>
    !kIsWeb &&
    const {
      TargetPlatform.android,
      TargetPlatform.windows,
      TargetPlatform.macOS,
    }.contains(defaultTargetPlatform);

@immutable
class AppLockState {
  const AppLockState({
    required this.supported,
    required this.hasPin,
    required this.locked,
    required this.setupPromptPending,
    required this.biometricEnabled,
    this.pinLength,
    this.failures = 0,
    this.cooldownUntil,
  });

  final bool supported;
  final bool hasPin;

  /// The lock screen must be passed before anything else is shown.
  final bool locked;

  /// Offer to set a PIN (once, until set or skipped).
  final bool setupPromptPending;
  final bool biometricEnabled;
  final int? pinLength;
  final int failures;
  final DateTime? cooldownUntil;
}

enum UnlockResult { unlocked, wrongPin, coolingDown }

/// The local app lock: a 4–6 digit PIN (hashed, never leaves the device),
/// optionally fingerprint / face on Android.
///
/// Locks on a cold start and after [LockPolicy.backgroundTimeout] in the
/// background. Signing in never locks: the user just proved who they are.
@Riverpod(keepAlive: true)
class AppLock extends _$AppLock {
  DateTime? _backgroundedAt;

  @override
  AppLockState build() {
    // listen, not watch: a rebuild would re-lock the app.
    ref.listen(sessionProvider, (previous, next) {
      if (next is SignedIn && previous is SignedIn) return;
      _backgroundedAt = null;
      state = _load(locked: false);
    });
    return _load(locked: ref.read(sessionProvider) is SignedIn);
  }

  AppPrefs get _prefs => ref.read(appPrefsProvider);
  DateTime _now() => ref.read(clockProvider)();

  AppLockState _load({required bool locked}) {
    final supported = ref.read(appLockSupportedProvider);
    final pin = supported ? _prefs.pin : null;
    return AppLockState(
      supported: supported,
      hasPin: pin != null,
      locked: locked && pin != null,
      setupPromptPending: supported && pin == null && !_prefs.pinPromptSkipped,
      biometricEnabled: pin != null && _prefs.biometricUnlock,
      pinLength: pin?.length,
      failures: _prefs.pinFailures,
      cooldownUntil: _prefs.pinCooldownUntil,
    );
  }

  void _reload({bool? locked}) => state = _load(locked: locked ?? state.locked);

  Future<void> setPin(String pin) async {
    final record = await compute(PinHasher.create, pin);
    await _prefs.setPin(record);
    await _prefs.setPinFailures(0, null);
    _reload(locked: false);
  }

  Future<void> removePin() async {
    await _prefs.setPin(null);
    await _prefs.setBiometricUnlock(enabled: false);
    // Removing it on purpose is an answer to the prompt too.
    await _prefs.setPinPromptSkipped(skipped: true);
    _reload(locked: false);
  }

  Future<void> skipSetup() async {
    await _prefs.setPinPromptSkipped(skipped: true);
    _reload();
  }

  Future<void> setBiometric({required bool enabled}) async {
    await _prefs.setBiometricUnlock(enabled: enabled);
    _reload();
  }

  void lockNow() {
    if (state.hasPin) _reload(locked: true);
  }

  Future<UnlockResult> unlock(String pin) async {
    final record = _prefs.pin;
    if (record == null) {
      _reload(locked: false);
      return UnlockResult.unlocked;
    }
    final until = state.cooldownUntil;
    if (until != null && _now().isBefore(until)) {
      return UnlockResult.coolingDown;
    }
    final ok = await compute(_verify, (pin, record));
    if (ok) {
      await _prefs.setPinFailures(0, null);
      _reload(locked: false);
      return UnlockResult.unlocked;
    }
    final failures = state.failures + 1;
    final wait = LockPolicy.cooldownAfter(failures);
    await _prefs.setPinFailures(
      failures,
      wait == Duration.zero ? null : _now().add(wait),
    );
    _reload();
    return UnlockResult.wrongPin;
  }

  /// Returns true if the system prompt succeeded.
  Future<bool> unlockWithBiometric(String reason) async {
    if (!state.biometricEnabled) return false;
    final ok = await ref.read(biometricAuthProvider).authenticate(reason);
    if (ok) {
      await _prefs.setPinFailures(0, null);
      _reload(locked: false);
    }
    return ok;
  }

  /// App went to the background (minimised, screen off, switched away).
  void onBackgrounded() => _backgroundedAt ??= _now();

  void onResumed() {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null || !state.hasPin) return;
    if (LockPolicy.shouldLockAfter(_now().difference(since))) lockNow();
  }
}

bool _verify((String, PinRecord) args) => PinHasher.verify(args.$1, args.$2);
