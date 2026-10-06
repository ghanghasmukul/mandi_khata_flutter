import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:powersync/powersync.dart';

/// One of our groups that the export uses, with its Tally group.
@immutable
class TallyGroupUse {
  const TallyGroupUse({
    required this.code,
    required this.name,
    required this.tallyGroup,
    required this.ledgers,
  });

  final String code;
  final String name;

  /// Null when no Tally group is set for it.
  final String? tallyGroup;
  final int ledgers;
}

/// What an export of a period would contain.
@immutable
class TallyExportPlan {
  const TallyExportPlan({required this.result, required this.groups});

  final TallyExportResult result;
  final List<TallyGroupUse> groups;
}

/// Builds the Tally Prime export of a period from the local journal
/// (docs/domain/posting-rules.md, 11.6). Finance members only.
class TallyExportRepository {
  TallyExportRepository(this._db);

  final PowerSyncDatabase _db;

  /// The business's group mapping over the defaults (`tally.group_map`).
  static Map<String, String> groupMap(Object? saved) => {
    ...defaultTallyGroupMap,
    if (saved is Map)
      for (final MapEntry(:key, :value) in saved.entries)
        if (key is String && value is String) key: value,
  };

  Future<TallyExportPlan> plan(
    String tenantId, {
    required String company,
    required LedgerDate from,
    required LedgerDate to,
    required Map<String, String> groupMap,
  }) => _db.readTransaction((tx) async {
    final chart = await ChartRepository.load(tx, tenantId);
    final entries = await tx.getAll(
      'SELECT e.id, e.source_key, e.entry_date, e.narration, '
      'v.voucher_no, v.voucher_type, p.receipt_no, x.expense_no, l.lot_no '
      'FROM journal_entries e '
      'LEFT JOIN vouchers v ON v.id = e.voucher_id '
      'AND v.tenant_id = e.tenant_id '
      "LEFT JOIN payments p ON e.source_key = 'payment:' || p.id "
      'AND p.tenant_id = e.tenant_id '
      "LEFT JOIN expenses x ON e.source_key = 'expense:' || x.id "
      'AND x.tenant_id = e.tenant_id '
      "LEFT JOIN lots l ON e.source_key = 'lot:' || l.id "
      'AND l.tenant_id = e.tenant_id '
      'WHERE e.tenant_id = ? AND e.entry_date >= ? AND e.entry_date <= ? '
      'ORDER BY e.entry_date, e.created_at, e.id',
      [tenantId, from.toString(), to.toString()],
    );
    final lines = await tx.getAll(
      'SELECT l.journal_entry_id, l.account_id, l.debit_paise, '
      'l.credit_paise FROM journal_lines l JOIN journal_entries e '
      'ON e.id = l.journal_entry_id AND e.tenant_id = l.tenant_id '
      'WHERE l.tenant_id = ? AND e.entry_date >= ? AND e.entry_date <= ? '
      'ORDER BY l.journal_entry_id, l.line_no',
      [tenantId, from.toString(), to.toString()],
    );
    final byEntry = <String, List<(String, Money, Money)>>{};
    for (final l in lines) {
      byEntry.putIfAbsent(l['journal_entry_id']! as String, () => []).add((
        l['account_id']! as String,
        Money(l['debit_paise']! as int),
        Money(l['credit_paise']! as int),
      ));
    }
    final used = <String>{for (final l in lines) l['account_id']! as String};
    final ledgers = <TallyLedgerIn>[];
    final groupCounts = <String, int>{};
    for (final id in used) {
      final a = chart.byId(id);
      if (a == null) continue;
      final code = _groupCode(chart, a);
      groupCounts[code] = (groupCounts[code] ?? 0) + 1;
      final kind = chart.kindForGroup(a.groupId);
      ledgers.add(
        TallyLedgerIn(
          id: id,
          name: a.name,
          groupCode: code,
          code: a.code,
          kind: TallyExport.kindOf(
            a.account,
            sales: kind == VoucherAccountKind.sales,
            purchase: kind == VoucherAccountKind.purchase,
          ),
        ),
      );
    }
    ledgers.sort((a, b) => a.name.compareTo(b.name));
    final vouchers = [
      for (final e in entries)
        TallyVoucherIn(
          id: e['id']! as String,
          date: LedgerDate.parse(e['entry_date']! as String),
          number:
              (e['voucher_no'] ??
                      e['receipt_no'] ??
                      e['expense_no'] ??
                      e['lot_no'])
                  as String?,
          narration: e['narration'] as String?,
          voucherType: e['voucher_type'] as String?,
          lines: byEntry[e['id']] ?? const [],
        ),
    ];
    final result = TallyExport.build(
      company: company,
      ledgers: ledgers,
      vouchers: vouchers,
      groupMap: groupMap,
    );
    final groups = [
      for (final MapEntry(key: code, value: n) in groupCounts.entries)
        TallyGroupUse(
          code: code,
          name:
              chart.groups.values
                  .where((g) => g.code == code)
                  .firstOrNull
                  ?.name ??
              code,
          tallyGroup: groupMap[code],
          ledgers: n,
        ),
    ]..sort((a, b) => a.name.compareTo(b.name));
    return TallyExportPlan(result: result, groups: groups);
  });

  /// The group code a ledger is exported under: its own group's code.
  static String _groupCode(Chart chart, ChartEntry a) =>
      chart.groups[a.groupId]?.code ?? 'unknown';

  /// A zip with `01-masters.xml`, `02-vouchers.xml` and `validation.txt`
  /// ([report] lines).
  static Uint8List zip(TallyExportResult r, List<String> report) {
    final archive = Archive()
      ..addFile(_file('01-masters.xml', r.mastersXml))
      ..addFile(_file('02-vouchers.xml', r.vouchersXml))
      ..addFile(_file('validation.txt', report.join('\n')));
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  static ArchiveFile _file(String name, String text) {
    final bytes = utf8.encode(text);
    return ArchiveFile(name, bytes.length, bytes);
  }
}
