import 'package:drift/drift.dart';
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:mandi_khata_app/core/db/tables.dart';
import 'package:powersync/powersync.dart' show PowerSyncDatabase;

part 'app_database.g.dart';

/// Typed queries (Drift) on top of the PowerSync database.
///
/// Reads and writes go to the same local SQLite file PowerSync syncs, so every
/// Drift write lands in the upload queue and every synced change updates
/// Drift `watch()` streams.
@DriftDatabase(
  tables: [
    Tenants,
    AppUsers,
    TenantMembers,
    Devices,
    Settings,
    AuditLog,
    Parties,
    PartyRoles,
    NumberSeries,
    SyncErrors,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(PowerSyncDatabase db) : super(SqliteAsyncDriftConnection(db));

  /// For tests that only need the table definitions.
  @visibleForTesting
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  /// PowerSync creates and updates the schema (as views); Drift must not.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {},
    onUpgrade: (m, from, to) async {},
  );
}
