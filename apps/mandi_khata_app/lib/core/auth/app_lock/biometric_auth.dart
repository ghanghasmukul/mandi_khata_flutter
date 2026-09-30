import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'biometric_auth.g.dart';

final _log = Logger('app_lock');

/// Fingerprint / face unlock as a shortcut for the PIN (Android only).
abstract interface class BiometricAuth {
  /// Whether this device has biometrics enrolled.
  Future<bool> isAvailable();

  /// Shows the system prompt; false when cancelled or failed.
  Future<bool> authenticate(String reason);
}

class LocalBiometricAuth implements BiometricAuth {
  final _auth = LocalAuthentication();

  static bool get _platformSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<bool> isAvailable() async {
    if (!_platformSupported) return false;
    try {
      return await _auth.canCheckBiometrics &&
          (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on Exception catch (e) {
      _log.info('Biometrics unavailable: $e');
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    if (!_platformSupported) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      _log.info('Biometric unlock failed: ${e.code}');
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
BiometricAuth biometricAuth(Ref ref) => LocalBiometricAuth();

@riverpod
Future<bool> biometricAvailable(Ref ref) =>
    ref.watch(biometricAuthProvider).isAvailable();
