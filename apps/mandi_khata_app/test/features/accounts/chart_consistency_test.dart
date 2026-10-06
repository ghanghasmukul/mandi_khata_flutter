import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';

const t1 = '11111111-1111-4111-8111-111111111111';

/// The chart lives in two places that must agree: the Dart enums that the
/// posting rules use and the SQL seed that creates the accounts on the
/// server. These tests keep them in step, and keep the Dart UUID v5 ids
/// equal to the server's `private.chart_id` (the same constants are asserted
/// in supabase/tests/16_chart_of_accounts_journal.test.sql).
void main() {
  final repo = Directory.current.parent.parent;
  final sql = File(
    '${repo.path}/supabase/migrations/'
    '20261005171417_chart_of_accounts_and_journal.sql',
  ).readAsStringSync();

  test('account ids equal the UUID v5 ids of the server', () {
    expect(
      JournalWriter.accountId(
        t1,
        const SystemJournalAccount(SystemAccount.commissionIncome),
      ),
      'dd8ccca6-8be7-537b-afb1-ba337008b796',
    );
    expect(
      JournalWriter.accountId(
        t1,
        const PartyAccount('f0000000-0000-4000-8000-000000000001'),
      ),
      '3dee5529-6ccf-5c01-934d-b49c64136380',
    );
    expect(
      JournalWriter.accountId(
        t1,
        const BookAccount('a0000000-0000-4000-8000-000000000001'),
      ),
      '22aa4ef0-39a4-576b-b6d8-64d8d4d0bcc2',
    );
    expect(
      JournalWriter.groupId(t1, AccountGroup.sundryDebtors),
      'c335cbd3-7ca9-5fb3-87ce-bbc8e13608d2',
    );
  });

  test('the SQL group seed lists exactly the AccountGroup enum', () {
    final block = sql.substring(
      sql.indexOf('function private.seed_chart_groups'),
      sql.indexOf('function private.seed_chart_accounts'),
    );
    final rows = RegExp(
      r"\('([a-z_]+)',\s+'([^']+)',\s+(null|'[a-z_]+'),\s+'([a-z]+)'\)",
    ).allMatches(block).toList();
    expect(rows, hasLength(AccountGroup.values.length));
    for (final g in AccountGroup.values) {
      final m = rows.singleWhere((r) => r.group(1) == g.code);
      expect(m.group(2), g.name, reason: g.code);
      expect(
        m.group(3),
        g.parent == null ? 'null' : "'${g.parent!.code}'",
        reason: '${g.code} parent',
      );
      expect(m.group(4), g.nature.name, reason: '${g.code} nature');
    }
  });

  test('the SQL account seed lists exactly the SystemAccount enum', () {
    final block = sql.substring(
      sql.indexOf('function private.seed_chart_accounts'),
      sql.indexOf('function private.party_account_group'),
    );
    final rows = RegExp(
      r"\('([a-z_]+)',\s+'([^']+)',\s+'([a-z_]+)'\)",
    ).allMatches(block).toList();
    expect(rows, hasLength(SystemAccount.values.length));
    for (final a in SystemAccount.values) {
      final m = rows.singleWhere((r) => r.group(1) == a.code);
      expect(m.group(2), a.name, reason: a.code);
      expect(m.group(3), a.group.code, reason: '${a.code} group');
    }
  });
}
