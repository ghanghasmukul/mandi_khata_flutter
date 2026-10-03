import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_status.g.dart';

/// True once the owner has revoked THIS install in the active business (the
/// `devices` row synced down with `revoked_at`). The gate then blocks the
/// app; the server already refuses this device's writes.
@riverpod
Stream<bool> deviceRevoked(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  final device = ref.watch(activeDeviceProvider);
  if (tenantId == null || device == null) {
    yield false;
    return;
  }
  final db = await ref.watch(powerSyncDatabaseProvider.future);
  yield* db
      .watch(
        'SELECT revoked_at FROM devices WHERE tenant_id = ? AND id = ?',
        parameters: [tenantId, device.id],
        triggerOnTables: const {'devices'},
      )
      .map((rows) => rows.isNotEmpty && rows.first['revoked_at'] != null);
}
