/// How the audit log screen groups an entry.
enum AuditKind {
  /// Edit of an amount, rate or weight on a posted money record: shown
  /// highlighted.
  moneyEdit,

  /// A reversal of money (ledger entry, payment, lot, book line):
  /// highlighted.
  reversal,

  /// Team, role, permission, invite or device change.
  team,

  /// A business setting changed.
  setting,

  /// Everything else (a new party, a new lot, …).
  normal,
}

/// Classifies `audit_log` rows for the audit screen. Pure; the app only
/// formats the result.
abstract final class AuditRules {
  /// Tables whose rows are money records.
  static const moneyTables = {
    'ledger_entries',
    'payments',
    'cash_bank_entries',
    'lots',
    'bank_accounts',
  };

  /// Columns that hold an amount, rate or weight.
  static const moneyColumns = {
    'amount_paise',
    'gross',
    'commission',
    'net_to_farmer',
    'buyer_total',
    'rate_paise_per_qtl',
    'qtl_milli',
    'opening_balance_paise',
  };

  /// Tables about people and access.
  static const teamTables = {'tenant_members', 'member_invites', 'devices'};

  /// Every table the log can show, for the table filter.
  static const knownTables = [
    'ledger_entries',
    'payments',
    'cash_bank_entries',
    'lots',
    'parties',
    'party_roles',
    'crops',
    'bank_accounts',
    'settings',
    'tenant_members',
    'member_invites',
    'devices',
  ];

  static AuditKind classify({
    required String table,
    required String action,
    Map<String, Object?>? before,
    Map<String, Object?>? after,
  }) {
    final money = moneyTables.contains(table);
    if (money && action == 'reverse') return AuditKind.reversal;
    if (money && action == 'update') {
      final touched = changedKeys(before, after);
      if (touched.any(moneyColumns.contains)) return AuditKind.moneyEdit;
    }
    if (teamTables.contains(table)) return AuditKind.team;
    if (table == 'settings') return AuditKind.setting;
    return AuditKind.normal;
  }

  /// Whether the entry deserves attention (money edit or reversal).
  static bool isHighlighted(AuditKind kind) =>
      kind == AuditKind.moneyEdit || kind == AuditKind.reversal;

  /// Keys whose value differs between [before] and [after], in key order.
  /// Insert rows (no `before`) list every key of `after`.
  static List<String> changedKeys(
    Map<String, Object?>? before,
    Map<String, Object?>? after,
  ) {
    final keys = <String>{...?before?.keys, ...?after?.keys}.toList()..sort();
    return [
      for (final k in keys)
        if (!_same(before?[k], after?[k])) k,
    ];
  }

  static bool _same(Object? a, Object? b) {
    if (a is Map || a is List || b is Map || b is List) {
      return a.toString() == b.toString();
    }
    return a == b;
  }

  /// Whether [key] holds money in paise (shown as ₹ in the app) rather than
  /// a weight or a plain number.
  static bool isPaiseColumn(String key) =>
      key == 'amount_paise' ||
      key == 'gross' ||
      key == 'commission' ||
      key == 'net_to_farmer' ||
      key == 'buyer_total' ||
      key == 'rate_paise_per_qtl' ||
      key == 'opening_balance_paise';
}
