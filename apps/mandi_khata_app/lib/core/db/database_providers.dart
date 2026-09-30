import 'package:flutter/foundation.dart';
import 'package:mandi_khata_app/core/db/app_database.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_providers.g.dart';

const _fileName = 'mandi_khata.db';

/// The one local database. Every screen reads and writes only this; sync to
/// Supabase happens in the background (see SyncController).
@Riverpod(keepAlive: true)
Future<PowerSyncDatabase> powerSyncDatabase(Ref ref) async {
  // Web keeps the database in the browser (OPFS / IndexedDB) by name.
  final path = kIsWeb
      ? _fileName
      : p.join((await getApplicationSupportDirectory()).path, _fileName);
  final db = PowerSyncDatabase(schema: powerSyncSchema, path: path);
  await db.initialize();
  ref.onDispose(db.close);
  return db;
}

/// Typed Drift access to the same database.
@Riverpod(keepAlive: true)
Future<AppDatabase> appDatabase(Ref ref) async {
  final db = AppDatabase(await ref.watch(powerSyncDatabaseProvider.future));
  ref.onDispose(db.close);
  return db;
}
