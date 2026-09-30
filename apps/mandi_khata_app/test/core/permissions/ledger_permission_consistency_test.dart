import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';

/// The app checks khata_core `LedgerPosting.requiredPermission` before a
/// post (hide / refuse); the server enforces
/// `private.ledger_post_permission()` in the ledger_entries insert policy.
/// They must agree, so this reads the SQL from the migrations and compares.
void main() {
  final migrations =
      Directory('../../supabase/migrations')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  // The latest definition wins.
  final sql = migrations
      .map((f) => f.readAsStringSync())
      .where((s) => s.contains('function private.ledger_post_permission'))
      .last;
  final body = RegExp(
    r'function private\.ledger_post_permission.*?\$\$(.*?)\$\$',
    dotAll: true,
  ).firstMatch(sql)!.group(1)!;

  // Each `when <condition> then '<permission>'` branch.
  final branches = [
    for (final m in RegExp(
      r"when(.*?)then\s+'([a-z]+\.[a-z]+)'",
      dotAll: true,
    ).allMatches(body))
      (condition: m[1]!, permission: m[2]!),
  ];
  final sqlByRefType = <String, String>{
    for (final b in branches)
      for (final t in RegExp("'([a-z_]+)'").allMatches(b.condition))
        t[1]!: b.permission,
  };

  for (final type in RefType.values) {
    test('${type.dbName} needs the same permission in SQL', () {
      expect(
        LedgerPosting.requiredPermission(type)?.key,
        sqlByRefType[type.dbName],
      );
    });
  }

  test('a correction needs entries.reverse in SQL too', () {
    final correction = branches.singleWhere(
      (b) => b.condition.contains('p_replaces_id is not null'),
    );
    expect(correction.permission, Permission.entriesReverse.key);
    expect(
      LedgerPosting.requiredPermission(RefType.payment, isCorrection: true),
      Permission.entriesReverse,
    );
  });

  test('anything else needs no extra permission in SQL (else null)', () {
    expect(body, contains('else null'));
  });
}
