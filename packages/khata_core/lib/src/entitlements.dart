import 'package:meta/meta.dart';

/// What a plan row says (docs/domain/saas-rules.md section 1).
@immutable
final class PlanSpec {
  const PlanSpec({
    required this.code,
    this.name = '',
    this.modules = const {},
    this.limits = const {},
    this.maxUsers,
    this.maxDevices,
    this.defaultSettings = const {},
  });

  final String code;
  final String name;

  /// A module that is missing is off.
  final Map<String, bool> modules;

  /// A limit that is missing or null is unlimited.
  final Map<String, int?> limits;

  /// Shortcut columns; they set the `users` and `devices` limits.
  final int? maxUsers;
  final int? maxDevices;

  /// Settings for the plan level of the cascade.
  final Map<String, Object?> defaultSettings;
}

/// What an add-on row grants, per unit bought.
@immutable
final class AddonSpec {
  const AddonSpec({
    required this.code,
    this.grantsLimits = const {},
    this.grantsModules = const {},
    this.maxQuantity,
  });

  final String code;
  final Map<String, int> grantsLimits;
  final Map<String, bool> grantsModules;
  final int? maxQuantity;
}

/// One add-on a business has bought.
@immutable
final class AddonPurchase {
  const AddonPurchase(this.addon, this.quantity);

  final AddonSpec addon;
  final int quantity;
}

/// Per-business exceptions set by the super-admin. They win over the plan
/// and the add-ons.
@immutable
final class EntitlementOverrides {
  const EntitlementOverrides({this.modules = const {}, this.limits = const {}});

  /// Reads `{"modules": {...}, "limits": {...}}`; anything of the wrong type
  /// is ignored (an unreadable override grants nothing).
  factory EntitlementOverrides.fromJson(Object? json) {
    if (json is! Map) return none;
    final modules = <String, bool>{};
    final limits = <String, int?>{};
    final m = json['modules'];
    if (m is Map) {
      for (final e in m.entries) {
        if (e.key is String && e.value is bool) {
          modules[e.key as String] = e.value as bool;
        }
      }
    }
    final l = json['limits'];
    if (l is Map) {
      for (final e in l.entries) {
        final v = e.value;
        if (e.key is String && (v == null || (v is int && v >= 0))) {
          limits[e.key as String] = v as int?;
        }
      }
    }
    return EntitlementOverrides(modules: modules, limits: limits);
  }

  /// Absolute: true switches a module on, false off.
  final Map<String, bool> modules;

  /// Absolute: a number replaces the limit, null means unlimited.
  final Map<String, int?> limits;

  static const none = EntitlementOverrides();
}

/// How full a counted limit is.
enum LimitState { ok, atLimit, over }

/// The modules and limits a business really has.
@immutable
final class Entitlements {
  const Entitlements({this.modules = const {}, this.limits = const {}});

  /// The single place that combines plan, add-ons and overrides.
  factory Entitlements.resolve(
    PlanSpec plan, {
    Iterable<AddonPurchase> addons = const [],
    EntitlementOverrides overrides = EntitlementOverrides.none,
  }) {
    final modules = <String, bool>{...plan.modules};
    final limits = <String, int?>{...plan.limits};
    if (plan.maxUsers != null || !limits.containsKey('users')) {
      limits['users'] = plan.maxUsers;
    }
    if (plan.maxDevices != null || !limits.containsKey('devices')) {
      limits['devices'] = plan.maxDevices;
    }

    for (final p in addons) {
      if (p.quantity <= 0) continue;
      final qty = switch (p.addon.maxQuantity) {
        final max? when p.quantity > max => max,
        _ => p.quantity,
      };
      for (final e in p.addon.grantsModules.entries) {
        if (e.value) modules[e.key] = true;
      }
      for (final e in p.addon.grantsLimits.entries) {
        final base = limits[e.key];
        // Unlimited stays unlimited; a limit the plan never had is not
        // created by an add-on.
        if (limits.containsKey(e.key) && base != null) {
          limits[e.key] = base + e.value * qty;
        }
      }
    }

    modules.addAll(overrides.modules);
    limits.addAll(overrides.limits);
    return Entitlements(
      modules: Map.unmodifiable(modules),
      limits: Map.unmodifiable(limits),
    );
  }

  factory Entitlements.fromJson(Object? json) {
    if (json is! Map) return none;
    final overrides = EntitlementOverrides.fromJson(json);
    return Entitlements(modules: overrides.modules, limits: overrides.limits);
  }

  /// Nothing allowed: used until a subscription has been read.
  static const none = Entitlements();

  /// Every module on and no limits (offline fallback for a trial that has
  /// not synced its plan yet is *not* this: see the app's provider).
  static const unrestricted = Entitlements(
    modules: {
      'khata': true,
      'arrivals': true,
      'karza': true,
      'accounting': true,
      'shop': true,
    },
  );

  final Map<String, bool> modules;
  final Map<String, int?> limits;

  bool module(String key) => modules[key] ?? false;

  /// Null = unlimited.
  int? limit(String key) => limits[key];

  /// Whether one more of [key] fits when [current] already exist.
  bool canAdd(String key, int current) {
    final cap = limit(key);
    return cap == null || current < cap;
  }

  LimitState state(String key, int current) {
    final cap = limit(key);
    if (cap == null || current < cap) return LimitState.ok;
    return current == cap ? LimitState.atLimit : LimitState.over;
  }

  /// The business's own switch can only turn a module off.
  bool moduleOn(String key, {required bool switchOn}) =>
      module(key) && switchOn;

  /// `{modules, limits}` for the signed token.
  Map<String, Object?> toJson() => {'modules': modules, 'limits': limits};
}

/// Settings of a plan that are valid for the plan level of the cascade.
/// [isValid] says whether the settings schema accepts a key and value.
Map<String, Object?> validPlanDefaults(
  Map<String, Object?> raw,
  bool Function(String key, Object? value) isValid,
) => {
  for (final e in raw.entries)
    if (e.value != null && isValid(e.key, e.value)) e.key: e.value,
};
