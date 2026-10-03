import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/team/presentation/team_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

extension AuditLabels on AppLocalizations {
  String auditAction(String action) => switch (action) {
    'insert' => auditAction_insert,
    'update' => auditAction_update,
    'reverse' => auditAction_reverse,
    'soft_delete' => auditAction_soft_delete,
    'restore' => auditAction_restore,
    _ => action,
  };

  String auditTable(String table) => switch (table) {
    'ledger_entries' => auditTable_ledger_entries,
    'payments' => auditTable_payments,
    'cash_bank_entries' => auditTable_cash_bank_entries,
    'lots' => auditTable_lots,
    'parties' => auditTable_parties,
    'party_roles' => auditTable_party_roles,
    'crops' => auditTable_crops,
    'bank_accounts' => auditTable_bank_accounts,
    'settings' => auditTable_settings,
    'tenant_members' => auditTable_tenant_members,
    'member_invites' => auditTable_member_invites,
    'devices' => auditTable_devices,
    _ => table,
  };

  /// A column name people can read; unknown columns are tidied up
  /// (`entry_date` → `entry date`).
  String auditField(String key) => switch (key) {
    'amount_paise' => auditField_amount_paise,
    'gross' => auditField_gross,
    'commission' => auditField_commission,
    'net_to_farmer' => auditField_net_to_farmer,
    'buyer_total' => auditField_buyer_total,
    'rate_paise_per_qtl' => auditField_rate_paise_per_qtl,
    'qtl_milli' => auditField_qtl_milli,
    'status' => auditField_status,
    'role' => auditField_role,
    'is_active' => auditField_is_active,
    'device_limit' => auditField_device_limit,
    'custom_permissions' => auditField_custom_permissions,
    'revoked_at' => auditField_revoked_at,
    'phone' => auditField_phone,
    'name' => auditField_name,
    'cheque_status' => auditField_cheque_status,
    'entry_date' => auditField_entry_date,
    'side' => auditField_side,
    'direction' => auditField_direction,
    _ => key.replaceAll('_', ' '),
  };

  /// A stored value in words: money as rupees, weights in quintals,
  /// permission overrides by name, roles by their local name.
  String auditValue(String key, Object? value) {
    if (value == null) return auditEmptyValue;
    if (value is bool) return value ? auditYes : auditNo;
    if (value is int && AuditRules.isPaiseColumn(key)) {
      return Money(value).format();
    }
    if (value is int && key == 'qtl_milli') return Quintals.format(value);
    if (key == 'role' && value is String) {
      return roleName(MemberRole.parse(value));
    }
    if (key == 'custom_permissions' && value is Map) {
      if (value.isEmpty) return auditEmptyValue;
      final parts = <String>[];
      for (final e in value.entries) {
        final state = e.value == true ? auditYes : auditNo;
        parts.add('${_permission('${e.key}')}: $state');
      }
      return parts.join(', ');
    }
    if (value is Map || value is List) return jsonEncode(value);
    final text = value.toString();
    return text.isEmpty ? auditEmptyValue : text;
  }

  String _permission(String key) {
    final p = Permission.fromKey(key);
    return p == null ? key : permissionName(p);
  }
}
