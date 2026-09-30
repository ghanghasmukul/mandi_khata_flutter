import 'package:flutter/foundation.dart';

/// What the top-bar sync chip shows. Rejected changes win over everything,
/// then offline, then "syncing", then "synced · N min ago".
@immutable
sealed class SyncIndicator {
  const SyncIndicator();
}

/// This build has no sync server (no POWERSYNC_URL / Supabase config).
final class SyncOff extends SyncIndicator {
  const SyncOff();
}

/// The server permanently rejected [count] changes (see `sync_errors`).
final class SyncRejected extends SyncIndicator {
  const SyncRejected(this.count);
  final int count;

  @override
  bool operator ==(Object other) =>
      other is SyncRejected && other.count == count;
  @override
  int get hashCode => count.hashCode;
}

/// Not connected; [queued] local changes are waiting to upload.
final class SyncOffline extends SyncIndicator {
  const SyncOffline(this.queued);
  final int queued;

  @override
  bool operator ==(Object other) =>
      other is SyncOffline && other.queued == queued;
  @override
  int get hashCode => queued.hashCode;
}

/// Connected and moving data (or connecting).
final class SyncBusy extends SyncIndicator {
  const SyncBusy();
}

/// Connected and idle; last completed sync at [at] (null = not yet).
final class SyncDone extends SyncIndicator {
  const SyncDone(this.at);
  final DateTime? at;

  @override
  bool operator ==(Object other) => other is SyncDone && other.at == at;
  @override
  int get hashCode => at.hashCode;
}

/// Picks the indicator from the raw sync state.
SyncIndicator syncIndicatorFor({
  required bool configured,
  required bool connected,
  required bool connecting,
  required bool transferring,
  required int queued,
  required int rejected,
  DateTime? lastSyncedAt,
}) {
  if (!configured) return const SyncOff();
  if (rejected > 0) return SyncRejected(rejected);
  if (!connected && !connecting) return SyncOffline(queued);
  if (connecting || transferring || queued > 0) return const SyncBusy();
  return SyncDone(lastSyncedAt);
}

/// Whole minutes / hours since [at], for "Synced · 2 min ago".
({int minutes, int hours}) ageOf(DateTime at, DateTime now) {
  final age = now.difference(at);
  final minutes = age.isNegative ? 0 : age.inMinutes;
  return (minutes: minutes, hours: minutes ~/ 60);
}
