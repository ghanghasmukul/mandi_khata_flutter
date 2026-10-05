import 'package:khata_core/src/interest/interest_config.dart';

/// Party-level interest overrides (docs/domain/settings-cascade.md): turns
/// what an owner edits for one party into the `interest.*` setting values to
/// write at party level.
abstract final class PartyInterestOverrides {
  /// The terms as the editor shows them. "Interest on" means interest
  /// applies at all, so a party with `apply_on = none` (a supplier by
  /// default) shows as off.
  static InterestConfig forEditing(InterestConfig resolved) =>
      resolved.copyWith(enabled: resolved.applicable);

  /// The party-level values for the edit: a key's new value when it differs
  /// from [inherited] (what the party would get without its own row), `null`
  /// to go back to inherited when it does not. Switching interest off sets
  /// only `interest.enabled`, leaving the other overrides as they are.
  static Map<String, Object?> diff({
    required InterestConfig inherited,
    required InterestConfig edited,
  }) {
    final base = forEditing(inherited);
    Object? pick<T>(T value, T inheritedValue, Object? stored) =>
        value == inheritedValue ? null : stored;

    final result = <String, Object?>{
      'interest.enabled': pick(edited.enabled, base.enabled, edited.enabled),
    };
    if (!edited.enabled) return result;

    // Switching on a party that is off by apply_on means the whole khata.
    final applyOn = edited.applyOn == ApplyOn.none
        ? ApplyOn.netUdhaar
        : edited.applyOn;
    return result..addAll({
      'interest.apply_on': pick(applyOn, inherited.applyOn, applyOn.dbName),
      'interest.rate_pa': pick(
        edited.ratePa,
        inherited.ratePa,
        edited.ratePa.toString(),
      ),
      'interest.method': pick(
        edited.method,
        inherited.method,
        edited.method.name,
      ),
      'interest.compounding': pick(
        edited.compounding,
        inherited.compounding,
        edited.compounding.dbName,
      ),
      'interest.day_basis': pick(
        edited.dayBasis,
        inherited.dayBasis,
        edited.dayBasis,
      ),
      'interest.grace_days': pick(
        edited.graceDays,
        inherited.graceDays,
        edited.graceDays,
      ),
      'interest.appropriation': pick(
        edited.appropriation,
        inherited.appropriation,
        edited.appropriation.dbName,
      ),
      'interest.min_days': pick(
        edited.minDays,
        inherited.minDays,
        edited.minDays,
      ),
      'interest.rounding': pick(
        edited.rounding,
        inherited.rounding,
        edited.rounding.dbName,
      ),
    });
  }

  /// Every editable value written explicitly, for a bulk apply: each chosen
  /// party gets its own row whatever the business default is.
  static Map<String, Object?> explicit(InterestConfig edited) {
    if (!edited.enabled) return {'interest.enabled': false};
    return {
      'interest.enabled': true,
      'interest.apply_on': edited.applyOn == ApplyOn.none
          ? ApplyOn.netUdhaar.dbName
          : edited.applyOn.dbName,
      'interest.rate_pa': edited.ratePa.toString(),
      'interest.method': edited.method.name,
      'interest.compounding': edited.compounding.dbName,
      'interest.day_basis': edited.dayBasis,
      'interest.grace_days': edited.graceDays,
      'interest.appropriation': edited.appropriation.dbName,
      'interest.min_days': edited.minDays,
      'interest.rounding': edited.rounding.dbName,
    };
  }
}
