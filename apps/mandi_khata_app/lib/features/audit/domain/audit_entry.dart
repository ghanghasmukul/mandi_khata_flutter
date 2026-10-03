import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

Map<String, Object?>? _decode(Object? raw) {
  if (raw is! String || raw.isEmpty) return null;
  try {
    final v = jsonDecode(raw);
    return v is Map<String, Object?> ? v : null;
  } on FormatException {
    return null;
  }
}

/// One row of `audit_log` with names filled in and its [kind] classified.
@immutable
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.table,
    required this.rowId,
    required this.action,
    required this.kind,
    required this.createdAt,
    this.before,
    this.after,
    this.userId,
    this.userName,
    this.role,
    this.deviceCode,
    this.subject,
  });

  factory AuditEntry.fromRow(Map<String, Object?> r) {
    final table = r['table_name']! as String;
    final action = r['action']! as String;
    final before = _decode(r['before']);
    final after = _decode(r['after']);
    return AuditEntry(
      id: r['id']! as String,
      table: table,
      rowId: r['row_id']! as String,
      action: action,
      before: before,
      after: after,
      kind: AuditRules.classify(
        table: table,
        action: action,
        before: before,
        after: after,
      ),
      userId: r['user_id'] as String?,
      userName: r['user_name'] as String?,
      role: r['role'] as String?,
      deviceCode: r['device_code'] as String?,
      subject: r['subject'] as String?,
      createdAt:
          DateTime.tryParse(r['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String table;
  final String rowId;

  /// `insert`, `update`, `reverse`, `soft_delete`, `restore`.
  final String action;
  final AuditKind kind;
  final Map<String, Object?>? before;
  final Map<String, Object?>? after;
  final String? userId;
  final String? userName;

  /// Role of the writer at the time (filled by the server).
  final String? role;
  final String? deviceCode;

  /// What the row is about: party name, receipt / lot number, device code…
  final String? subject;
  final DateTime createdAt;

  bool get highlighted => AuditRules.isHighlighted(kind);

  /// Keys to show: the changed ones (all of them for an insert). A reversal
  /// mirrors its original, so nothing "changes"; its amounts are shown
  /// anyway.
  List<String> get changedKeys {
    final changed = AuditRules.changedKeys(before, after);
    if (kind != AuditKind.reversal) return changed;
    final money = [
      for (final k in after?.keys ?? const <String>[])
        if (AuditRules.moneyColumns.contains(k) && !changed.contains(k)) k,
    ];
    return [...changed, ...money..sort()];
  }
}

/// What the audit screen is filtered by. Dates are local days, inclusive.
@immutable
class AuditFilter {
  const AuditFilter({
    this.userId,
    this.table,
    this.from,
    this.to,
    this.onlyHighlighted = false,
  });

  final String? userId;
  final String? table;
  final LedgerDate? from;
  final LedgerDate? to;

  /// Only money edits and reversals.
  final bool onlyHighlighted;

  AuditFilter copyWith({
    String? Function()? userId,
    String? Function()? table,
    ({LedgerDate? from, LedgerDate? to})? range,
    bool? onlyHighlighted,
  }) => AuditFilter(
    userId: userId == null ? this.userId : userId(),
    table: table == null ? this.table : table(),
    from: range == null ? from : range.from,
    to: range == null ? to : range.to,
    onlyHighlighted: onlyHighlighted ?? this.onlyHighlighted,
  );

  @override
  bool operator ==(Object other) =>
      other is AuditFilter &&
      other.userId == userId &&
      other.table == table &&
      other.from == from &&
      other.to == to &&
      other.onlyHighlighted == onlyHighlighted;

  @override
  int get hashCode => Object.hash(userId, table, from, to, onlyHighlighted);
}
