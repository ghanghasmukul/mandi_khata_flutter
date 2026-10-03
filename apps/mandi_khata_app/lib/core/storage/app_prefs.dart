import 'dart:convert';

import 'package:mandi_khata_app/core/auth/app_lock/pin_hasher.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_prefs.g.dart';

/// This install's device id and short code in one business.
typedef DeviceRegistration = ({String id, String code});

/// Small per-install values that must be readable before (and without) the
/// synced database: who owns the local data, the last business, this
/// device's codes, the app-lock PIN.
///
/// Every key starts with `mk.` so [clearAll] never touches the Supabase
/// session, which the auth SDK keeps in the same store.
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'mk.';
  static const _dataOwner = '${_prefix}dataOwnerUserId';
  static const _lastTenant = '${_prefix}lastTenantId';
  static const _devicePrefix = '${_prefix}device.';
  static const _pin = '${_prefix}pin';
  static const _pinPromptSkipped = '${_prefix}pinPromptSkipped';
  static const _biometric = '${_prefix}biometricUnlock';
  static const _pinFailures = '${_prefix}pinFailures';
  static const _pinCooldownUntil = '${_prefix}pinCooldownUntil';

  /// Device-level UI choices survive sign-out, so they use another prefix
  /// that [clearAll] leaves alone.
  static const _uiLanguage = 'ui.language';

  /// The user whose data is in the local database. A different user signing
  /// in on this install starts from an empty database.
  String? get dataOwnerUserId => _prefs.getString(_dataOwner);
  Future<void> setDataOwnerUserId(String id) =>
      _prefs.setString(_dataOwner, id);

  String? get lastTenantId => _prefs.getString(_lastTenant);
  Future<void> setLastTenantId(String? id) => id == null
      ? _prefs.remove(_lastTenant)
      : _prefs.setString(_lastTenant, id);

  DeviceRegistration? device(String tenantId) {
    final raw = _prefs.getString('$_devicePrefix$tenantId');
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, Object?>;
    return (id: json['id']! as String, code: json['code']! as String);
  }

  Future<void> setDevice(String tenantId, DeviceRegistration device) =>
      _prefs.setString(
        '$_devicePrefix$tenantId',
        jsonEncode({'id': device.id, 'code': device.code}),
      );

  /// Forgets this install's registration in a business (after the owner
  /// revoked it), so picking the business registers a fresh device.
  Future<void> clearDevice(String tenantId) =>
      _prefs.remove('$_devicePrefix$tenantId');

  PinRecord? get pin {
    final raw = _prefs.getString(_pin);
    if (raw == null) return null;
    return PinRecord.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  Future<void> setPin(PinRecord? record) => record == null
      ? _prefs.remove(_pin)
      : _prefs.setString(_pin, jsonEncode(record.toJson()));

  bool get pinPromptSkipped => _prefs.getBool(_pinPromptSkipped) ?? false;
  Future<void> setPinPromptSkipped({required bool skipped}) =>
      _prefs.setBool(_pinPromptSkipped, skipped);

  bool get biometricUnlock => _prefs.getBool(_biometric) ?? false;
  Future<void> setBiometricUnlock({required bool enabled}) =>
      _prefs.setBool(_biometric, enabled);

  /// Wrong PINs in a row; kept across restarts so killing the app does not
  /// reset the cooldown.
  int get pinFailures => _prefs.getInt(_pinFailures) ?? 0;
  DateTime? get pinCooldownUntil {
    final raw = _prefs.getString(_pinCooldownUntil);
    return raw == null ? null : DateTime.parse(raw);
  }

  Future<void> setPinFailures(int failures, DateTime? cooldownUntil) async {
    await _prefs.setInt(_pinFailures, failures);
    if (cooldownUntil == null) {
      await _prefs.remove(_pinCooldownUntil);
    } else {
      await _prefs.setString(
        _pinCooldownUntil,
        cooldownUntil.toUtc().toIso8601String(),
      );
    }
  }

  /// Language picked on this install (`en` / `hi` / `pa`), or null to
  /// follow the profile / device.
  String? get uiLanguage => _prefs.getString(_uiLanguage);
  Future<void> setUiLanguage(String code) =>
      _prefs.setString(_uiLanguage, code);

  /// Forgets everything above except the UI language (sign-out, or another
  /// user signing in).
  Future<void> clearAll() async {
    for (final key in _prefs.getKeys().toList()) {
      if (key.startsWith(_prefix)) await _prefs.remove(key);
    }
  }
}

/// Opened once in `main()` and injected with an override.
@Riverpod(keepAlive: true)
AppPrefs appPrefs(Ref ref) =>
    throw UnimplementedError('appPrefsProvider must be overridden in main()');
