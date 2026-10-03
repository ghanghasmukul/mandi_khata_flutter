import 'package:decimal/decimal.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/party_rules.dart';
import 'package:khata_core/src/permissions.dart';
import 'package:khata_core/src/settings/interest_rate.dart';
import 'package:khata_core/src/settings/settings_schema.dart';
import 'package:meta/meta.dart';

/// The first-run wizard's steps, in order. [OnboardingRules.resume] maps the
/// stored `onboarding.step` (the number of steps finished) back to one.
enum OnboardingStep {
  business,
  mandi,
  crops,
  charges,
  interest,
  language,
  invite,
}

/// A state a business can be in (GST state code, 2 digits).
@immutable
class IndianState {
  const IndianState(this.code, this.en, this.hi, this.pa);

  final String code;
  final String en;
  final String hi;
  final String pa;

  String nameIn(String languageCode) => switch (languageCode) {
    'hi' => hi,
    'pa' => pa,
    _ => en,
  };
}

abstract final class OnboardingRules {
  /// Where mandi businesses are, home states first (CLAUDE.md: Punjab,
  /// Haryana, Rajasthan first). Codes are GST state codes.
  static const states = <IndianState>[
    IndianState('03', 'Punjab', 'पंजाब', 'ਪੰਜਾਬ'),
    IndianState('06', 'Haryana', 'हरियाणा', 'ਹਰਿਆਣਾ'),
    IndianState('08', 'Rajasthan', 'राजस्थान', 'ਰਾਜਸਥਾਨ'),
    IndianState('09', 'Uttar Pradesh', 'उत्तर प्रदेश', 'ਉੱਤਰ ਪ੍ਰਦੇਸ਼'),
    IndianState('23', 'Madhya Pradesh', 'मध्य प्रदेश', 'ਮੱਧ ਪ੍ਰਦੇਸ਼'),
    IndianState('24', 'Gujarat', 'गुजरात', 'ਗੁਜਰਾਤ'),
    IndianState('27', 'Maharashtra', 'महाराष्ट्र', 'ਮਹਾਰਾਸ਼ਟਰ'),
    IndianState('07', 'Delhi', 'दिल्ली', 'ਦਿੱਲੀ'),
    IndianState('02', 'Himachal Pradesh', 'हिमाचल प्रदेश', 'ਹਿਮਾਚਲ ਪ੍ਰਦੇਸ਼'),
    IndianState('05', 'Uttarakhand', 'उत्तराखंड', 'ਉੱਤਰਾਖੰਡ'),
    IndianState('04', 'Chandigarh', 'चंडीगढ़', 'ਚੰਡੀਗੜ੍ਹ'),
    IndianState(
      '01',
      'Jammu and Kashmir',
      'जम्मू और कश्मीर',
      'ਜੰਮੂ ਅਤੇ ਕਸ਼ਮੀਰ',
    ),
    IndianState('10', 'Bihar', 'बिहार', 'ਬਿਹਾਰ'),
  ];

  static IndianState? stateByCode(String? code) {
    for (final s in states) {
      if (s.code == code) return s;
    }
    return null;
  }

  /// Which step to show: [finished] steps are done (the stored
  /// `onboarding.step`), clamped to the first and last step.
  static OnboardingStep resume(int finished) =>
      OnboardingStep.values[finished.clamp(
        0,
        OnboardingStep.values.length - 1,
      )];

  /// Whether to open the wizard by itself. Only the owner, only on a
  /// business that has not been through it, has no parties or khata entries
  /// yet, and only once this device has finished its first sync (before
  /// that, "no settings" may just mean "not downloaded yet").
  static bool needsOnboarding({
    required MemberRole role,
    required String status,
    required bool hasParties,
    required bool hasEntries,
    required bool synced,
  }) =>
      synced &&
      role == MemberRole.owner &&
      (status == 'not_started' || status == 'in_progress') &&
      // A business that already works is never interrupted, but a half-done
      // wizard resumes even though its first steps wrote settings.
      (status == 'in_progress' || (!hasParties && !hasEntries));

  /// A whole-number percentage or decimal such as `2.5`, as the canonical
  /// string the settings store (`"2.5"`). Null if not a number.
  static String? decimalText(String input) {
    final d = Decimal.tryParse(input.trim().replaceAll(',', ''));
    return d?.toString();
  }
}

enum BusinessField { name, gstin, phone }

enum FieldProblem { required, invalid }

/// Step 1: business details, as typed.
@immutable
class BusinessDetails {
  const BusinessDetails({
    required this.name,
    this.legalName,
    this.gstin,
    this.address,
    this.phone,
  });

  final String name;
  final String? legalName;
  final String? gstin;
  final String? address;
  final String? phone;

  static bool _blank(String? v) => v == null || v.trim().isEmpty;

  Map<BusinessField, FieldProblem> validate() => {
    if (_blank(name)) BusinessField.name: FieldProblem.required,
    if (!_blank(gstin) && Gstin.normalise(gstin!) == null)
      BusinessField.gstin: FieldProblem.invalid,
    if (!_blank(phone) && IndianMobile.normalise(phone!) == null)
      BusinessField.phone: FieldProblem.invalid,
  };

  /// The `tenants` columns to store (blank → null, GSTIN upper-case, phone
  /// 10 digits). Call only when [validate] is empty.
  Map<String, Object?> columns() {
    String? clean(String? v) {
      final t = v?.trim().replaceAll(RegExp(r'\s+'), ' ');
      return t == null || t.isEmpty ? null : t;
    }

    return {
      'name': clean(name),
      'legal_name': clean(legalName),
      'gstin': _blank(gstin) ? null : Gstin.normalise(gstin!),
      'address': clean(address),
      'phone': _blank(phone) ? null : IndianMobile.normalise(phone!),
    };
  }
}

/// Step 4: default commission and charges, as typed (rupees and percent).
@immutable
class ChargeDefaults {
  const ChargeDefaults({
    required this.commissionPct,
    required this.palledariPerBag,
    required this.bardanaPerBag,
    required this.tulaiPerQtl,
    required this.mandiFeePct,
    required this.bagWeightKg,
  });

  final String commissionPct;

  /// Rupees, e.g. `12` or `12.50`.
  final String palledariPerBag;
  final String bardanaPerBag;
  final String tulaiPerQtl;
  final String mandiFeePct;
  final String bagWeightKg;

  /// Setting key → value in the schema's storage form (percent as decimal
  /// string, money as whole paise). Keys that do not validate are in
  /// `problems` instead.
  ({Map<String, Object> values, Set<String> problems}) toSettings() {
    final values = <String, Object>{};
    final problems = <String>{};
    void percent(String key, String input) {
      final t = OnboardingRules.decimalText(input);
      (t != null && SettingsSchema.parse(key)!.def.validate(t) == null)
          ? values[key] = t
          : problems.add(key);
    }

    void paise(String key, String input) {
      final m = Money.tryParse(input);
      (m != null &&
              !m.isNegative &&
              SettingsSchema.parse(key)!.def.validate(m.paise) == null)
          ? values[key] = m.paise
          : problems.add(key);
    }

    percent('mandi.commission_pct', commissionPct);
    paise('mandi.palledari_per_bag', palledariPerBag);
    paise('mandi.bardana_per_bag', bardanaPerBag);
    paise('mandi.tulai_per_qtl', tulaiPerQtl);
    percent('mandi.mandi_fee_pct', mandiFeePct);
    final bag = OnboardingRules.decimalText(bagWeightKg);
    (bag != null &&
            SettingsSchema.parse('mandi.bag_weight_kg')!.def.validate(bag) ==
                null)
        ? values['mandi.bag_weight_kg'] = bag
        : problems.add('mandi.bag_weight_kg');
    return (values: values, problems: problems);
  }
}

/// Step 5: interest defaults. Stored only; the engine arrives in Phase 2.
@immutable
class InterestDefaults {
  const InterestDefaults({
    required this.enabled,
    required this.rate,
    required this.perHundredPerMonth,
    required this.method,
    required this.compounding,
  });

  final bool enabled;

  /// As typed: % per annum, or ₹ per 100 per month when
  /// `perHundredPerMonth`.
  final String rate;
  final bool perHundredPerMonth;

  /// `simple` | `compound`.
  final String method;
  final String compounding;

  ({Map<String, Object> values, Set<String> problems}) toSettings() {
    final values = <String, Object>{
      'interest.enabled': enabled,
      'interest.rate_unit_display': perHundredPerMonth
          ? 'per100_per_month'
          : 'pa',
      'interest.method': method,
    };
    final problems = <String>{};
    final typed = Decimal.tryParse(rate.trim().replaceAll(',', ''));
    if (typed == null) {
      problems.add('interest.rate_pa');
    } else {
      final pa = perHundredPerMonth
          ? InterestRate.paFromPer100PerMonth(typed)
          : typed;
      final text = pa.toString();
      if (SettingsSchema.parse('interest.rate_pa')!.def.validate(text) ==
          null) {
        values['interest.rate_pa'] = text;
      } else {
        problems.add('interest.rate_pa');
      }
    }
    if (method == 'compound') values['interest.compounding'] = compounding;
    for (final MapEntry(:key, :value) in values.entries) {
      if (SettingsSchema.parse(key)!.def.validate(value) != null) {
        problems.add(key);
      }
    }
    return (values: values, problems: problems);
  }
}
