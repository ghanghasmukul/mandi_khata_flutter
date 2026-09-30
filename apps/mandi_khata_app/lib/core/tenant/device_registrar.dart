import 'package:flutter/foundation.dart';
import 'package:mandi_khata_app/app/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'device_registrar.g.dart';

/// The `devices.platform` value for this build, or null for platforms the
/// app does not ship on (iOS, Linux).
String? currentDevicePlatform() {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.windows => 'windows',
    TargetPlatform.macOS => 'macos',
    _ => null,
  };
}

/// Registering needs the server, which hands out codes that never collide.
class DeviceRegistrationException implements Exception {
  const DeviceRegistrationException({required this.offline, this.detail});

  /// True when the server could not be reached (as opposed to refusing).
  final bool offline;
  final String? detail;

  @override
  String toString() =>
      'DeviceRegistrationException(offline: $offline, $detail)';
}

/// Creates (or refreshes) this install's row in `devices` for a business and
/// returns its short code (`W1`, `A3`, …).
abstract interface class DeviceRegistrar {
  Future<String> register({
    required String deviceId,
    required String tenantId,
    required String platform,
  });
}

/// Calls `register_device()`, which allocates the code under a per-business
/// lock (see the tenancy migration).
class SupabaseDeviceRegistrar implements DeviceRegistrar {
  SupabaseDeviceRegistrar(this._client);

  final SupabaseClient _client;

  @override
  Future<String> register({
    required String deviceId,
    required String tenantId,
    required String platform,
  }) async {
    try {
      final row = await _client.rpc<Map<String, dynamic>>(
        'register_device',
        params: {
          'p_device_id': deviceId,
          'p_tenant_id': tenantId,
          'p_platform': platform,
        },
      );
      return row['device_code'] as String;
    } on PostgrestException catch (e) {
      throw DeviceRegistrationException(offline: false, detail: e.message);
    } on Exception catch (e) {
      throw DeviceRegistrationException(offline: true, detail: '$e');
    }
  }
}

class _UnconfiguredRegistrar implements DeviceRegistrar {
  const _UnconfiguredRegistrar();

  @override
  Future<String> register({
    required String deviceId,
    required String tenantId,
    required String platform,
  }) => Future.error(
    const DeviceRegistrationException(offline: true, detail: 'no config'),
  );
}

@Riverpod(keepAlive: true)
DeviceRegistrar deviceRegistrar(Ref ref) {
  if (!Env.hasSupabase) return const _UnconfiguredRegistrar();
  try {
    return SupabaseDeviceRegistrar(Supabase.instance.client);
  } on Object {
    return const _UnconfiguredRegistrar();
  }
}
