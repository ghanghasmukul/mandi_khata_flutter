import 'package:khata_core/src/settings/setting_scope.dart';

/// A member's role in a business (`tenant_members.role`).
enum MemberRole {
  owner,
  accountant,
  munshi,
  custom;

  /// Unknown roles get nothing, like `custom`.
  static MemberRole parse(String value) =>
      values.firstWhere((r) => r.name == value, orElse: () => custom);

  /// Role defaults from docs/domain/ledger-and-mandi.md. Must match the SQL
  /// `private.role_allows()` (checked by an app test).
  bool allows(Permission p) => switch (this) {
    owner => true,
    accountant => const {
      Permission.partiesManage,
      Permission.arrivalsManage,
      Permission.paymentsCreate,
      Permission.entriesReverse,
      Permission.financeView,
      Permission.productsManage,
      Permission.purchasesCreate,
      Permission.salesCreate,
      Permission.salesReturn,
      Permission.stockAdjust,
      Permission.shopViewProfit,
    }.contains(p),
    munshi => const {
      Permission.partiesManage,
      Permission.arrivalsManage,
      Permission.paymentsCreate,
      Permission.salesCreate,
    }.contains(p),
    custom => false,
  };
}

/// Everything the app gates. [key] is what `custom_permissions` and the SQL
/// `private.has_permission()` use.
enum Permission {
  partiesManage('parties.manage'),
  arrivalsManage('arrivals.manage'),
  paymentsCreate('payments.create'),
  entriesReverse('entries.reverse'),
  loansManage('loans.manage'),
  financeView('finance.view'),
  adminManage('admin.manage'),
  masterDelete('master.delete'),
  settingsManage('settings.manage'),
  auditView('audit.view'),

  /// Shop (phase 4, docs/domain/shop-rules.md section 9).
  productsManage('products.manage'),
  purchasesCreate('purchases.create'),
  salesCreate('sales.create'),
  salesReturn('sales.return'),
  stockAdjust('stock.adjust'),
  shopViewProfit('shop.view_profit');

  const Permission(this.key);

  final String key;

  static Permission? fromKey(String key) {
    for (final p in values) {
      if (p.key == key) return p;
    }
    return null;
  }
}

/// Same rule as SQL `private.has_permission()`: owners always; else a
/// boolean in [custom] wins; else the role default.
bool hasPermission(
  MemberRole role,
  Map<String, Object?> custom,
  Permission permission,
) {
  if (role == MemberRole.owner) return true;
  final override = custom[permission.key];
  if (override is bool) return override;
  return role.allows(permission);
}

/// Same rule as SQL `private.can_write_setting()` for an active member:
/// business / party-group scope needs `settings.manage`, and `interest.*`
/// needs `loans.manage` at every scope.
bool canWriteSetting(
  String key,
  SettingScope scope,
  bool Function(Permission) can,
) {
  if ((scope == SettingScope.tenant || scope == SettingScope.partyGroup) &&
      !can(Permission.settingsManage)) {
    return false;
  }
  if (key.startsWith('interest.') && !can(Permission.loansManage)) {
    return false;
  }
  return true;
}
