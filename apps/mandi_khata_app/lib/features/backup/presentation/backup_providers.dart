import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/backup/data/backup_runner.dart';
import 'package:mandi_khata_app/features/backup/data/backup_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_providers.g.dart';

/// Scheduled local backups exist on Windows and macOS only.
bool get localBackupSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS);

@Riverpod(keepAlive: true)
Future<BackupService> backupService(Ref ref) async =>
    BackupService(await ref.watch(powerSyncDatabaseProvider.future));

/// Time of the last backup of the active business on this PC; refreshed by
/// [backupRunNow] and the scheduler.
@Riverpod(keepAlive: true)
class LastBackup extends _$LastBackup {
  @override
  DateTime? build() {
    final tenantId = ref.watch(activeTenantProvider);
    return tenantId == null
        ? null
        : ref.read(appPrefsProvider).backupLastAt(tenantId);
  }

  // A notifier method, not a setter: callers are other providers.
  // ignore: use_setters_to_change_properties
  void set(DateTime at) => state = at;
}

/// Writes a backup now with the saved folder / passphrase. Returns the file
/// path, or null when the backup is not set up.
@riverpod
Future<String?> backupRunNow(Ref ref) async {
  final prefs = ref.read(appPrefsProvider);
  final tenantId = ref.read(activeTenantProvider);
  final membership = ref.read(activeMembershipProvider);
  final folder = prefs.backupFolder;
  final pass = prefs.backupPassphrase;
  if (tenantId == null || folder == null || pass == null) return null;
  final service = await ref.read(backupServiceProvider.future);
  final now = DateTime.now();
  final path = await BackupRunner(service).run(
    tenantId: tenantId,
    tenantName: membership?.tenantName ?? '',
    folder: folder,
    passphrase: pass,
    now: now,
  );
  await prefs.setBackupLastAt(tenantId, now);
  ref.read(lastBackupProvider.notifier).set(now);
  return path;
}

/// Checks every 15 minutes whether the daily backup is due and runs it.
/// Watched for the app's lifetime (main.dart); does nothing off desktop or
/// when the owner has not turned it on.
@Riverpod(keepAlive: true)
void backupScheduler(Ref ref) {
  if (!localBackupSupported) return;
  var busy = false;
  Future<void> tick() async {
    final prefs = ref.read(appPrefsProvider);
    final tenantId = ref.read(activeTenantProvider);
    if (busy || tenantId == null || !prefs.backupEnabled) return;
    if (!BackupRunner.isDue(prefs.backupLastAt(tenantId), DateTime.now())) {
      return;
    }
    busy = true;
    try {
      await ref.read(backupRunNowProvider.future);
    } on Object {
      // Folder missing (USB not plugged in): try again at the next tick.
    } finally {
      busy = false;
    }
  }

  final timer = Timer.periodic(
    const Duration(minutes: 15),
    (_) => unawaited(tick()),
  );
  ref.onDispose(timer.cancel);
  unawaited(Future<void>.delayed(const Duration(seconds: 30), tick));
}
