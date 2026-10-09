import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/db/app_database.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';

/// A synced table has to be declared in five places. This test keeps them in
/// step: Postgres migrations, the `powersync` publication, sync streams, the
/// PowerSync schema and the Drift tables.
void main() {
  final repo = Directory.current.parent.parent; // apps/mandi_khata_app → root
  final migrations = Directory('${repo.path}/supabase/migrations')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .map((f) => f.readAsStringSync())
      .join('\n');

  final sqlTables = _parseCreateTables(migrations);
  final names = {for (final t in syncedTables) t.name};

  test('every synced table exists in the migrations with matching columns', () {
    for (final table in syncedTables) {
      final sql = sqlTables[table.name];
      expect(sql, isNotNull, reason: '${table.name} missing from migrations');
      expect(
        {...table.columns.keys, 'id'},
        sql!.keys.toSet(),
        reason: 'columns of ${table.name}',
      );
      for (final MapEntry(key: column, value: kind) in table.columns.entries) {
        expect(
          kind,
          _kindFor(sql[column]!),
          reason: '${table.name}.$column is ${sql[column]} in SQL',
        );
      }
    }
  });

  test('every synced table except platform ones has tenant_id', () {
    // Platform tables hold no business data: they are the same for everyone.
    const platform = {
      'tenants',
      'app_users',
      'plans',
      'plan_addons',
      'platform_settings',
      'announcements',
    };
    for (final table in syncedTables) {
      if (platform.contains(table.name)) continue;
      expect(table.columns, contains('tenant_id'), reason: table.name);
    }
  });

  test('the powersync publication lists exactly the synced tables', () {
    final match = RegExp(
      'create publication powersync for table([^;]+);',
    ).firstMatch(migrations);
    expect(match, isNotNull);
    final added = RegExp(
      'alter publication powersync add table ([^;]+);',
    ).allMatches(migrations).map((m) => m.group(1)!);
    final published = RegExp(r'public\.([a-z_]+)')
        .allMatches([match!.group(1)!, ...added].join(','))
        .map((m) => m.group(1)!)
        .toSet();
    expect(published, names);
  });

  test('sync streams select from every synced table', () {
    final yaml = File(
      '${repo.path}/powersync/sync-streams.yaml',
    ).readAsStringSync();
    final selected = RegExp(
      r'SELECT \* FROM ([a-z_]+)',
    ).allMatches(yaml).map((m) => m.group(1)!).toSet();
    expect(selected, names);
  });

  test('Drift tables match the PowerSync schema', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final drift = {
      for (final t in db.allTables)
        t.actualTableName: {for (final c in t.$columns) c.name},
    };
    for (final table in syncedTables) {
      expect(drift[table.name], {
        ...table.columns.keys,
        'id',
      }, reason: 'Drift columns of ${table.name}');
    }
    expect(drift['sync_errors'], {
      'id',
      for (final c in syncErrorsTable.columns) c.name,
    });
    expect(drift.keys.toSet(), {...names, 'sync_errors'});
  });
}

/// table → column → SQL type, from `create table public.x (...)` blocks
/// plus later `alter table … add column`.
Map<String, Map<String, String>> _parseCreateTables(String sql) {
  final tables = <String, Map<String, String>>{};
  final block = RegExp(
    r'create table public\.([a-z_]+) \((.*?)\n\);',
    dotAll: true,
  );
  final column = RegExp('^  ([a-z_][a-z0-9_]*) ([a-z]+)', multiLine: true);
  const notColumns = {'constraint', 'unique', 'foreign', 'primary', 'check'};
  for (final m in block.allMatches(sql)) {
    tables[m.group(1)!] = {
      for (final c in column.allMatches(m.group(2)!))
        if (!notColumns.contains(c.group(1))) c.group(1)!: c.group(2)!,
    };
  }
  // Columns added later: `alter table public.x add column y type, ...;`
  final alter = RegExp(r'alter table public\.([a-z_]+)\s+(add column [^;]+);');
  final added = RegExp('add column ([a-z_][a-z0-9_]*) ([a-z]+)');
  for (final m in alter.allMatches(sql)) {
    final columns = tables[m.group(1)!];
    if (columns == null) continue;
    for (final c in added.allMatches(m.group(2)!)) {
      columns[c.group(1)!] = c.group(2)!;
    }
  }
  return tables;
}

ColumnKind _kindFor(String sqlType) => switch (sqlType) {
  'jsonb' => ColumnKind.json,
  'boolean' => ColumnKind.boolean,
  'integer' || 'bigint' => ColumnKind.integer,
  'numeric' => ColumnKind.real,
  _ => ColumnKind.text, // uuid, text, timestamptz, date
};
