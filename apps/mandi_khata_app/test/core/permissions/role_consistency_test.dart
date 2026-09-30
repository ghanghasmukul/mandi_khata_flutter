import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';

/// The app's role table (khata_core `MemberRole.allows`) only hides UI; the
/// server enforces `private.role_allows()`. They must agree, so this reads
/// the SQL from the migrations and compares.
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
      .where((s) => s.contains('function private.role_allows'))
      .last;
  final body = RegExp(
    r'function private\.role_allows.*?\$\$(.*?)\$\$',
    dotAll: true,
  ).firstMatch(sql)!.group(1)!;

  Set<String> sqlGrants(String role) {
    final m = RegExp(
      "when '$role' then p_permission in \\((.*?)\\)",
      dotAll: true,
    ).firstMatch(body);
    if (m == null) return {};
    return RegExp(
      "'([a-z_.]+)'",
    ).allMatches(m.group(1)!).map((x) => x[1]!).toSet();
  }

  test('owner is all-powerful in SQL too', () {
    expect(body, contains("when 'owner' then true"));
  });

  for (final role in [MemberRole.accountant, MemberRole.munshi]) {
    test('${role.name} grants match SQL role_allows()', () {
      final dart = {
        for (final p in Permission.values)
          if (role.allows(p)) p.key,
      };
      expect(dart, sqlGrants(role.name));
    });
  }

  test('every SQL permission key exists in the Permission enum', () {
    final keys = RegExp(
      r"'([a-z]+\.[a-z]+)'",
    ).allMatches(body).map((m) => m[1]!);
    for (final k in keys) {
      expect(Permission.fromKey(k), isNotNull, reason: k);
    }
  });

  test('custom role gets nothing in SQL (else false)', () {
    expect(body, contains('else false'));
  });
}
