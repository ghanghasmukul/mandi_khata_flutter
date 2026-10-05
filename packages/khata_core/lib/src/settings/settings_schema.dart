import 'package:decimal/decimal.dart';
import 'package:khata_core/src/settings/setting_scope.dart';
import 'package:meta/meta.dart';

/// How a setting's value is stored (JSON) and edited.
enum SettingType {
  /// JSON `true` / `false`.
  boolean,

  /// JSON whole number (days, months, …).
  integer,

  /// Percentage as a JSON decimal string: `"18"`, `"2.5"`.
  percent,

  /// Other exact decimal as a JSON string (kg per bag).
  decimal,

  /// Money as whole paise (JSON integer). Never a fraction.
  paise,

  /// One of [SettingDef.options] (JSON string).
  choice,

  /// A list or map with its own validator (cess list, number series, …).
  structured,
}

/// Why a value was rejected.
enum SettingError { wrongType, tooSmall, tooLarge, notAllowed, invalid }

/// One configurable key: its type, limits, system default and where it may
/// be set. The single source of truth for the settings editor, the resolver
/// and validation before a write.
@immutable
class SettingDef {
  const SettingDef._({
    required this.key,
    required this.type,
    required Object? systemDefault,
    this.min,
    this.max,
    this.options,
    this.allowedInts,
    this.suffixName,
    this.suffixValues,
    this.suffixDefaults = const {},
    this.businessOnly = false,
    this.hidden = false,
    this._validator,
  }) : _default = systemDefault;

  const SettingDef.boolean(
    String key, {
    required bool fallback,
    bool businessOnly = false,
    String? suffixName,
    List<String>? suffixValues,
  }) : this._(
         key: key,
         type: SettingType.boolean,
         systemDefault: fallback,
         businessOnly: businessOnly,
         suffixName: suffixName,
         suffixValues: suffixValues,
       );

  const SettingDef.integer(
    String key, {
    required int fallback,
    int? min,
    int? max,
    List<int>? allowed,
    bool businessOnly = false,
    bool hidden = false,
  }) : this._(
         key: key,
         type: SettingType.integer,
         systemDefault: fallback,
         min: min,
         max: max,
         allowedInts: allowed,
         businessOnly: businessOnly,
         hidden: hidden,
       );

  const SettingDef.percent(
    String key, {
    required String fallback,
    int max = 100,
    String? suffixName,
  }) : this._(
         key: key,
         type: SettingType.percent,
         systemDefault: fallback,
         min: 0,
         max: max,
         suffixName: suffixName,
       );

  const SettingDef.decimal(
    String key, {
    required String fallback,
    required int min,
    required int max,
    String? suffixName,
  }) : this._(
         key: key,
         type: SettingType.decimal,
         systemDefault: fallback,
         min: min,
         max: max,
         suffixName: suffixName,
       );

  const SettingDef.paise(
    String key, {
    required int fallback,
    int max = 1000000,
    String? suffixName,
    bool businessOnly = false,
  }) : this._(
         key: key,
         type: SettingType.paise,
         systemDefault: fallback,
         min: 0,
         max: max,
         suffixName: suffixName,
         businessOnly: businessOnly,
       );

  const SettingDef.choice(
    String key, {
    required String fallback,
    required List<String> options,
    bool businessOnly = false,
    bool hidden = false,
    String? suffixName,
    List<String>? suffixValues,
    Map<String, Object?> suffixDefaults = const {},
  }) : this._(
         key: key,
         type: SettingType.choice,
         systemDefault: fallback,
         options: options,
         businessOnly: businessOnly,
         hidden: hidden,
         suffixName: suffixName,
         suffixValues: suffixValues,
         suffixDefaults: suffixDefaults,
       );

  const SettingDef.structured(
    String key, {
    required Object fallback,
    required bool Function(Object) validator,
    bool businessOnly = false,
    String? suffixName,
    List<String>? suffixValues,
    Map<String, Object?> suffixDefaults = const {},
  }) : this._(
         key: key,
         type: SettingType.structured,
         systemDefault: fallback,
         validator: validator,
         businessOnly: businessOnly,
         suffixName: suffixName,
         suffixValues: suffixValues,
         suffixDefaults: suffixDefaults,
       );

  /// Base key, e.g. `mandi.commission_pct`.
  final String key;
  final SettingType type;
  final Object? _default;

  /// Inclusive limits for numeric types (whole units: %, paise, days, kg).
  final int? min;
  final int? max;

  /// Allowed values for [SettingType.choice].
  final List<String>? options;

  /// Allowed values for an integer with a fixed set (day basis 365 | 360).
  final List<int>? allowedInts;

  /// When set, the key also accepts one extra segment, e.g. a crop code:
  /// `mandi.commission_pct.wheat`. Null = no suffix.
  final String? suffixName;

  /// The only suffixes allowed (null = any lowercase identifier).
  final List<String>? suffixValues;

  /// System defaults that depend on the suffix.
  final Map<String, Object?> suffixDefaults;

  /// Only the business (tenant scope) may set it.
  final bool businessOnly;

  /// App bookkeeping (onboarding progress): stored like any setting, but not
  /// shown in the settings editor.
  final bool hidden;

  final bool Function(Object)? _validator;

  bool get hasSuffix => suffixName != null;

  /// The system default (level "system"), for a suffix if given.
  Object? defaultFor(String? suffix) =>
      suffix != null && suffixDefaults.containsKey(suffix)
      ? suffixDefaults[suffix]
      : _default;

  bool allowedAt(SettingScope scope) =>
      !businessOnly || scope == SettingScope.tenant;

  /// Null when [value] is acceptable. Null itself means "inherit" and is
  /// always acceptable.
  SettingError? validate(Object? value) {
    if (value == null) return null;
    switch (type) {
      case SettingType.boolean:
        return value is bool ? null : SettingError.wrongType;
      case SettingType.integer:
      case SettingType.paise:
        if (value is! int) return SettingError.wrongType;
        final allowed = allowedInts;
        if (allowed != null && !allowed.contains(value)) {
          return SettingError.notAllowed;
        }
        return _range(Decimal.fromInt(value));
      case SettingType.percent:
      case SettingType.decimal:
        final d = SettingsSchema.decimalOf(value);
        return d == null ? SettingError.wrongType : _range(d);
      case SettingType.choice:
        if (value is! String) return SettingError.wrongType;
        return options!.contains(value) ? null : SettingError.notAllowed;
      case SettingType.structured:
        try {
          return _validator!(value) ? null : SettingError.invalid;
        } on Object {
          return SettingError.invalid;
        }
    }
  }

  SettingError? _range(Decimal d) {
    if (min != null && d < Decimal.fromInt(min!)) return SettingError.tooSmall;
    if (max != null && d > Decimal.fromInt(max!)) return SettingError.tooLarge;
    return null;
  }
}

/// A full key split into its definition and optional suffix.
@immutable
class SettingKey {
  const SettingKey(this.def, [this.suffix]);

  final SettingDef def;
  final String? suffix;

  String get full => suffix == null ? def.key : '${def.key}.$suffix';

  @override
  bool operator ==(Object other) =>
      other is SettingKey && other.def.key == def.key && other.suffix == suffix;

  @override
  int get hashCode => Object.hash(def.key, suffix);
}

/// Every v1 key from `docs/domain/settings-cascade.md`.
abstract final class SettingsSchema {
  static const partyRoles = [
    'farmer',
    'customer',
    'supplier',
    'vendor',
    'agency',
    'buyer',
  ];
  static const chargeNames = [
    'commission',
    'palledari',
    'bardana',
    'tulai',
    'mandi_fee',
    'cess',
  ];
  static const chargePayers = ['farmer', 'buyer', 'arhtiya'];
  static const languages = ['en', 'hi', 'pa'];
  static const modules = ['khata', 'arrivals', 'karza', 'accounting', 'shop'];

  static const all = <SettingDef>[
    // Interest (byaj)
    SettingDef.boolean('interest.enabled', fallback: true),
    SettingDef.percent('interest.rate_pa', fallback: '18'),
    SettingDef.choice(
      'interest.rate_unit_display',
      fallback: 'pa',
      options: ['pa', 'per100_per_month'],
    ),
    SettingDef.choice(
      'interest.method',
      fallback: 'simple',
      options: ['simple', 'compound'],
    ),
    SettingDef.choice(
      'interest.compounding',
      fallback: 'quarterly',
      options: ['monthly', 'quarterly', 'halfyearly', 'yearly', 'on_fy_close'],
    ),
    SettingDef.integer(
      'interest.day_basis',
      fallback: 365,
      allowed: [365, 360],
    ),
    SettingDef.integer('interest.grace_days', fallback: 0, min: 0, max: 365),
    SettingDef.choice(
      'interest.appropriation',
      fallback: 'interest_first',
      options: ['interest_first', 'principal_first'],
    ),
    SettingDef.choice(
      'interest.apply_on',
      fallback: 'net_udhaar',
      options: ['net_udhaar', 'loans_only', 'none'],
    ),
    SettingDef.integer('interest.min_days', fallback: 0, min: 0, max: 365),
    SettingDef.choice(
      'interest.rounding',
      fallback: 'rupee',
      options: ['paise', 'rupee', 'ten_rupee'],
    ),
    SettingDef.choice(
      'interest.post_frequency',
      fallback: 'on_demand',
      options: ['on_demand', 'monthly', 'quarterly', 'fy_close'],
    ),
    SettingDef.boolean('interest.pay_on_jama', fallback: false),
    SettingDef.percent('interest.pay_rate_pa', fallback: '0'),

    // Mandi (arhat & charges); every key can be per crop.
    SettingDef.percent(
      'mandi.commission_pct',
      fallback: '2.5',
      max: 20,
      suffixName: 'crop',
    ),
    SettingDef.paise(
      'mandi.palledari_per_bag',
      fallback: 1200,
      suffixName: 'crop',
    ),
    SettingDef.paise(
      'mandi.bardana_per_bag',
      fallback: 800,
      suffixName: 'crop',
    ),
    SettingDef.paise('mandi.tulai_per_qtl', fallback: 300, suffixName: 'crop'),
    SettingDef.percent(
      'mandi.mandi_fee_pct',
      fallback: '1',
      max: 20,
      suffixName: 'crop',
    ),
    SettingDef.structured(
      'mandi.cess',
      fallback: <Object?>[],
      validator: _validCessList,
      suffixName: 'crop',
    ),
    SettingDef.structured(
      'mandi.charges_borne_by',
      fallback: {
        'commission': 'farmer',
        'palledari': 'farmer',
        'bardana': 'farmer',
        'tulai': 'farmer',
        'mandi_fee': 'farmer',
        'cess': 'farmer',
      },
      validator: _validChargesBorneBy,
      suffixName: 'crop',
    ),
    SettingDef.decimal(
      'mandi.bag_weight_kg',
      fallback: '50',
      min: 1,
      max: 200,
      suffixName: 'crop',
    ),

    // Shop
    SettingDef.structured(
      'shop.price_tiers',
      fallback: ['farmer', 'retail', 'vendor', 'wholesale'],
      validator: _validTierList,
      businessOnly: true,
    ),
    SettingDef.structured(
      'shop.default_tier_for_role',
      fallback: 'retail',
      validator: _validIdentifier,
      businessOnly: true,
      suffixName: 'role',
      suffixValues: partyRoles,
      suffixDefaults: {'farmer': 'farmer', 'vendor': 'vendor'},
    ),
    SettingDef.boolean(
      'shop.allow_negative_stock',
      fallback: false,
      businessOnly: true,
    ),
    SettingDef.integer(
      'shop.expiry_warn_days',
      fallback: 180,
      min: 0,
      max: 3650,
      businessOnly: true,
    ),
    SettingDef.boolean('shop.gst_enabled', fallback: true, businessOnly: true),
    SettingDef.boolean(
      'shop.post_credit_sale_to_khata',
      fallback: true,
      businessOnly: true,
    ),

    // Business / numbering / app
    SettingDef.integer(
      'business.fy_start_month',
      fallback: 4,
      min: 1,
      max: 12,
      businessOnly: true,
    ),
    // Entries dated more than this many days before the day they are
    // recorded (or in the future) need `entries.reverse`.
    SettingDef.integer(
      'business.backdate_days',
      fallback: 3,
      min: 0,
      max: 3650,
      businessOnly: true,
    ),
    // A payment to a party above this amount (paise) needs
    // `entries.reverse`. 0 = no limit.
    SettingDef.paise(
      'business.munshi_payment_limit',
      fallback: 0,
      max: 100000000000,
      businessOnly: true,
    ),
    // The most a party may owe (paise); 0 = no limit. A business default
    // that a party (or group) can override. Only an alert: it blocks nothing.
    SettingDef.paise('business.credit_limit', fallback: 0, max: 100000000000),
    SettingDef.structured(
      'business.number_series',
      fallback: {'prefix': 'X-', 'next': 1},
      validator: _validNumberSeries,
      businessOnly: true,
      suffixName: 'doc',
      suffixValues: [
        'receipt',
        'lot',
        'sales_invoice',
        'purchase_invoice',
        'karza',
        'voucher',
        'party',
      ],
      suffixDefaults: {
        'receipt': {'prefix': 'R-', 'next': 1},
        'lot': {'prefix': 'L-', 'next': 1},
        'sales_invoice': {'prefix': 'SI-', 'next': 1},
        'purchase_invoice': {'prefix': 'PI-', 'next': 1},
        'karza': {'prefix': 'KZ-', 'next': 1},
        'voucher': {'prefix': 'V-', 'next': 1},
        'party': {'prefix': 'P-', 'next': 1},
      },
    ),
    SettingDef.boolean(
      'app.modules',
      fallback: true,
      businessOnly: true,
      suffixName: 'module',
      suffixValues: modules,
    ),
    SettingDef.structured(
      'app.languages',
      fallback: ['en', 'hi', 'pa'],
      validator: _validLanguages,
      businessOnly: true,
    ),
    SettingDef.choice(
      'app.default_language',
      fallback: 'en',
      options: languages,
      businessOnly: true,
    ),
    SettingDef.choice(
      'print.receipt_size',
      fallback: 'a5',
      options: ['a5', 'thermal_80', 'thermal_58'],
      businessOnly: true,
    ),
    SettingDef.boolean(
      'notify.whatsapp_receipts',
      fallback: false,
      businessOnly: true,
    ),

    // Onboarding wizard progress (hidden from the settings editor): the
    // wizard resumes on any device from these two rows.
    SettingDef.choice(
      'onboarding.status',
      fallback: 'not_started',
      options: onboardingStatuses,
      businessOnly: true,
      hidden: true,
    ),
    SettingDef.integer(
      'onboarding.step',
      fallback: 0,
      min: 0,
      max: 20,
      businessOnly: true,
      hidden: true,
    ),
  ];

  /// `onboarding.status`: `not_started` until the owner begins, then
  /// `in_progress`, then `completed` (or `skipped`).
  static const onboardingStatuses = [
    'not_started',
    'in_progress',
    'completed',
    'skipped',
  ];

  /// Keys the settings editor shows.
  static List<SettingDef> get visible => [
    for (final d in all)
      if (!d.hidden) d,
  ];

  static final Map<String, SettingDef> _byKey = {for (final d in all) d.key: d};

  static final _identifier = RegExp(r'^[a-z][a-z0-9_]*$');

  /// Splits a full key (`mandi.commission_pct.wheat`) into its definition
  /// and suffix; null if the key is not in the schema.
  static SettingKey? parse(String key) {
    final exact = _byKey[key];
    if (exact != null) {
      // Keys with a fixed suffix list (role, doc, module) need the suffix.
      return exact.suffixValues == null ? SettingKey(exact) : null;
    }
    final dot = key.lastIndexOf('.');
    if (dot <= 0) return null;
    final def = _byKey[key.substring(0, dot)];
    final suffix = key.substring(dot + 1);
    if (def == null || !def.hasSuffix || !_identifier.hasMatch(suffix)) {
      return null;
    }
    final allowed = def.suffixValues;
    if (allowed != null && !allowed.contains(suffix)) return null;
    return SettingKey(def, suffix);
  }

  /// An exact decimal from a stored value: a string (canonical) or a JSON
  /// number (older rows). Null if it is neither.
  static Decimal? decimalOf(Object? value) => switch (value) {
    final String s => Decimal.tryParse(s.trim()),
    final int i => Decimal.fromInt(i),
    // A JSON number decodes to a double; its shortest text form is the
    // literal that was stored, so parsing that is exact.
    final double d when d.isFinite => Decimal.tryParse(d.toString()),
    _ => null,
  };

  static bool _validIdentifier(Object v) =>
      v is String && _identifier.hasMatch(v);

  static bool _validCessList(Object v) =>
      v is List &&
      v.every(
        (e) =>
            e is Map &&
            e['name'] is String &&
            (e['name'] as String).trim().isNotEmpty &&
            (decimalOf(e['pct']) ?? Decimal.fromInt(-1)) >= Decimal.zero &&
            decimalOf(e['pct'])! <= Decimal.fromInt(100),
      );

  static bool _validChargesBorneBy(Object v) =>
      v is Map &&
      v.entries.every(
        (e) => chargeNames.contains(e.key) && chargePayers.contains(e.value),
      );

  static bool _validTierList(Object v) =>
      v is List &&
      v.isNotEmpty &&
      v.every(_validIdentifierOrFalse) &&
      v.toSet().length == v.length;

  static bool _validIdentifierOrFalse(Object? v) =>
      v != null && _validIdentifier(v);

  static bool _validNumberSeries(Object v) =>
      v is Map &&
      v['prefix'] is String &&
      RegExp(r'^[A-Z]{1,4}-$').hasMatch(v['prefix'] as String) &&
      v['next'] is int &&
      (v['next'] as int) >= 1;

  static bool _validLanguages(Object v) =>
      v is List &&
      v.isNotEmpty &&
      v.every(languages.contains) &&
      v.toSet().length == v.length;
}
