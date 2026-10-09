import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

Object? _json(Object? raw) {
  if (raw is! String || raw.isEmpty) return raw;
  try {
    return jsonDecode(raw);
  } on FormatException {
    return null;
  }
}

Map<String, bool> _boolMap(Object? raw) {
  final v = _json(raw);
  if (v is! Map) return const {};
  return {
    for (final e in v.entries)
      if (e.key is String && e.value is bool) e.key as String: e.value as bool,
  };
}

Map<String, int?> _limitMap(Object? raw) {
  final v = _json(raw);
  if (v is! Map) return const {};
  return {
    for (final e in v.entries)
      if (e.key is String && (e.value == null || e.value is int))
        e.key as String: e.value as int?,
  };
}

Map<String, int> _intMap(Object? raw) {
  final v = _json(raw);
  if (v is! Map) return const {};
  return {
    for (final e in v.entries)
      if (e.key is String && e.value is int) e.key as String: e.value as int,
  };
}

DateTime? _time(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw)?.toUtc() : null;

bool _flag(Object? raw, {bool fallback = false}) =>
    raw == null ? fallback : raw == 1 || raw == true;

/// A plan as the owner sees it.
@immutable
class PlanInfo {
  const PlanInfo({
    required this.spec,
    required this.name,
    required this.priceMonthly,
    required this.priceYearly,
    this.description,
    this.isPublic = false,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory PlanInfo.fromRow(Map<String, Object?> r) => PlanInfo(
    spec: PlanSpec(
      code: r['code']! as String,
      name: (r['name'] as String?) ?? '',
      modules: _boolMap(r['modules']),
      limits: _limitMap(r['limits']),
      maxUsers: r['max_users'] as int?,
      maxDevices: r['max_devices'] as int?,
      defaultSettings: switch (_json(r['default_settings'])) {
        final Map<dynamic, dynamic> m => {
          for (final e in m.entries)
            if (e.key is String) e.key as String: e.value,
        },
        _ => const {},
      },
    ),
    name: (r['name'] as String?) ?? (r['code']! as String),
    description: r['description'] as String?,
    priceMonthly: Money((r['price_monthly_paise'] as int?) ?? 0),
    priceYearly: Money((r['price_yearly_paise'] as int?) ?? 0),
    isPublic: _flag(r['is_public']),
    isActive: _flag(r['is_active'], fallback: true),
    sortOrder: (r['sort_order'] as int?) ?? 0,
  );

  final PlanSpec spec;
  final String name;
  final String? description;
  final Money priceMonthly;
  final Money priceYearly;
  final bool isPublic;
  final bool isActive;
  final int sortOrder;

  String get code => spec.code;
}

/// An add-on a business can buy.
@immutable
class AddonInfo {
  const AddonInfo({
    required this.spec,
    required this.name,
    required this.priceMonthly,
    required this.priceYearly,
    this.description,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory AddonInfo.fromRow(Map<String, Object?> r) => AddonInfo(
    spec: AddonSpec(
      code: r['code']! as String,
      grantsLimits: _intMap(r['grants_limits']),
      grantsModules: _boolMap(r['grants_modules']),
      maxQuantity: r['max_quantity'] as int?,
    ),
    name: (r['name'] as String?) ?? (r['code']! as String),
    description: r['description'] as String?,
    priceMonthly: Money((r['price_monthly_paise'] as int?) ?? 0),
    priceYearly: Money((r['price_yearly_paise'] as int?) ?? 0),
    isActive: _flag(r['is_active'], fallback: true),
    sortOrder: (r['sort_order'] as int?) ?? 0,
  );

  final AddonSpec spec;
  final String name;
  final String? description;
  final Money priceMonthly;
  final Money priceYearly;
  final bool isActive;
  final int sortOrder;

  String get code => spec.code;
}

/// The business's subscription row.
@immutable
class SubscriptionInfo {
  const SubscriptionInfo({
    required this.planCode,
    required this.terms,
    required this.billingCycle,
    this.addons = const [],
    this.overrides = EntitlementOverrides.none,
    this.discountPct = 0,
    this.discountNote,
    this.updatedAt,
  });

  factory SubscriptionInfo.fromRow(Map<String, Object?> r) {
    final addons = <({String code, int qty})>[];
    if (_json(r['addons']) case final List<dynamic> list) {
      for (final i in list) {
        if (i is Map && i['code'] is String && i['qty'] is int) {
          addons.add((code: i['code'] as String, qty: i['qty'] as int));
        }
      }
    }
    return SubscriptionInfo(
      planCode: r['plan_code']! as String,
      billingCycle: (r['billing_cycle'] as String?) ?? 'monthly',
      terms: SubscriptionTerms(
        status: SubscriptionStatus.parse(r['status'] as String?),
        trialEndsAt: _time(r['trial_ends_at']),
        currentPeriodEnd: _time(r['current_period_end']),
        graceDays: (r['grace_days'] as int?) ?? 7,
        graceUntil: _time(r['grace_until']),
        cancelledAt: _time(r['cancelled_at']),
        cancelledReadOnlyDays: (r['cancelled_readonly_days'] as int?) ?? 90,
      ),
      addons: addons,
      overrides: EntitlementOverrides.fromJson(_json(r['overrides'])),
      discountPct: ((r['discount_pct'] as num?) ?? 0).toDouble(),
      discountNote: r['discount_note'] as String?,
      updatedAt: _time(r['updated_at']),
    );
  }

  final String planCode;
  final String billingCycle;
  final SubscriptionTerms terms;
  final List<({String code, int qty})> addons;
  final EntitlementOverrides overrides;
  final double discountPct;
  final String? discountNote;
  final DateTime? updatedAt;
}

/// Subscription, plan and add-on catalogue together.
@immutable
class SubscriptionBundle {
  const SubscriptionBundle({
    required this.subscription,
    required this.plans,
    required this.addonCatalog,
  });

  final SubscriptionInfo subscription;
  final List<PlanInfo> plans;
  final List<AddonInfo> addonCatalog;

  PlanInfo? get plan {
    for (final p in plans) {
      if (p.code == subscription.planCode) return p;
    }
    return null;
  }

  /// Plan, add-ons and overrides combined. A plan that has not arrived yet
  /// (or was removed) grants nothing, like the server.
  Entitlements get entitlements {
    final p = plan;
    if (p == null) return Entitlements.none;
    final purchases = <AddonPurchase>[];
    for (final a in subscription.addons) {
      for (final c in addonCatalog) {
        if (c.code == a.code) purchases.add(AddonPurchase(c.spec, a.qty));
      }
    }
    return Entitlements.resolve(
      p.spec,
      addons: purchases,
      overrides: subscription.overrides,
    );
  }

  /// Plan default settings that the settings schema accepts.
  Map<String, Object?> get planDefaults =>
      validPlanDefaults(plan?.spec.defaultSettings ?? const {}, (key, value) {
        final parsed = SettingsSchema.parse(key);
        return parsed != null && parsed.def.validate(value) == null;
      });
}
