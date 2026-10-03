import 'package:decimal/decimal.dart';
import 'package:khata_core/src/party_rules.dart';
import 'package:khata_core/src/settings/setting_scope.dart';
import 'package:khata_core/src/settings/settings_resolver.dart';
import 'package:meta/meta.dart';

/// `interest.method`.
enum InterestMethod {
  simple,
  compound;

  static InterestMethod parse(String v) =>
      values.firstWhere((e) => e.name == v);
}

/// `interest.compounding` (only used when the method is compound).
enum CompoundingPeriod {
  monthly(1),
  quarterly(3),
  halfyearly(6),
  yearly(12),
  onFyClose(0);

  const CompoundingPeriod(this.months);

  /// Months between compounding dates; 0 for [onFyClose] (every 31 March).
  final int months;

  String get dbName => switch (this) {
    onFyClose => 'on_fy_close',
    _ => name,
  };

  static CompoundingPeriod parse(String v) =>
      values.firstWhere((e) => e.dbName == v);
}

/// `interest.appropriation`: how a repayment is split.
enum Appropriation {
  interestFirst('interest_first'),
  principalFirst('principal_first');

  const Appropriation(this.dbName);

  final String dbName;

  static Appropriation parse(String v) =>
      values.firstWhere((e) => e.dbName == v);
}

/// `interest.apply_on`.
enum ApplyOn {
  netUdhaar('net_udhaar'),
  loansOnly('loans_only'),
  none('none');

  const ApplyOn(this.dbName);

  final String dbName;

  static ApplyOn parse(String v) => values.firstWhere((e) => e.dbName == v);
}

/// `interest.rounding`: applied to the final accrued total only.
enum InterestRounding {
  paise('paise', 1),
  rupee('rupee', 100),
  tenRupee('ten_rupee', 1000);

  const InterestRounding(this.dbName, this.unitPaise);

  final String dbName;

  /// The multiple of paise the total is rounded (half-up) to.
  final int unitPaise;

  static InterestRounding parse(String v) =>
      values.firstWhere((e) => e.dbName == v);
}

/// Everything the engine needs to know about the interest rules of one
/// account, resolved from the settings cascade (docs/domain/settings-cascade.md).
///
/// Loans store this as their snapshot, so later changes to the business
/// default never alter an existing loan.
@immutable
class InterestConfig {
  InterestConfig({
    required this.ratePa,
    this.enabled = true,
    this.method = InterestMethod.simple,
    this.compounding = CompoundingPeriod.quarterly,
    this.dayBasis = 365,
    this.graceDays = 0,
    this.appropriation = Appropriation.interestFirst,
    this.applyOn = ApplyOn.netUdhaar,
    this.minDays = 0,
    this.rounding = InterestRounding.rupee,
    this.payOnJama = false,
    Decimal? payRatePa,
  }) : payRatePa = payRatePa ?? Decimal.zero,
       assert(dayBasis == 365 || dayBasis == 360, 'day basis is 365 or 360'),
       assert(graceDays >= 0 && minDays >= 0, 'days cannot be negative');

  /// Resolves every `interest.*` key for [partyId] / [documentId].
  ///
  /// Spec rule 5: a party whose roles are all supplier / agency gets
  /// `apply_on = none` **unless** `interest.apply_on` was set for that party,
  /// its group or the document (an explicit choice always wins).
  factory InterestConfig.fromSettings(
    SettingsResolver resolver, {
    String? partyId,
    String? partyGroupId,
    String? documentId,
    Set<PartyRole> partyRoles = const {},
  }) {
    ResolvedSetting get(String key) => resolver.resolve(
      key,
      partyId: partyId,
      partyGroupId: partyGroupId,
      documentId: documentId,
    );

    final applyOnSetting = get('interest.apply_on');
    final inheritedOnly = switch (applyOnSetting.level) {
      SettingLevel.tenant || SettingLevel.plan || SettingLevel.system => true,
      _ => false,
    };
    final supplierOnly =
        partyRoles.isNotEmpty &&
        partyRoles.every(
          (r) => r == PartyRole.supplier || r == PartyRole.agency,
        );

    return InterestConfig(
      enabled: get('interest.enabled').asBool,
      ratePa: get('interest.rate_pa').asDecimal,
      method: InterestMethod.parse(get('interest.method').asString),
      compounding: CompoundingPeriod.parse(
        get('interest.compounding').asString,
      ),
      dayBasis: get('interest.day_basis').asInt,
      graceDays: get('interest.grace_days').asInt,
      appropriation: Appropriation.parse(
        get('interest.appropriation').asString,
      ),
      applyOn: supplierOnly && inheritedOnly
          ? ApplyOn.none
          : ApplyOn.parse(applyOnSetting.asString),
      minDays: get('interest.min_days').asInt,
      rounding: InterestRounding.parse(get('interest.rounding').asString),
      payOnJama: get('interest.pay_on_jama').asBool,
      payRatePa: get('interest.pay_rate_pa').asDecimal,
    );
  }

  final bool enabled;

  /// Percent per annum (18 = 18%).
  final Decimal ratePa;
  final InterestMethod method;
  final CompoundingPeriod compounding;
  final int dayBasis;
  final int graceDays;
  final Appropriation appropriation;
  final ApplyOn applyOn;
  final int minDays;
  final InterestRounding rounding;
  final bool payOnJama;

  /// Percent per annum paid to the party while we hold their credit.
  final Decimal payRatePa;

  /// Whether any interest is charged or paid at all.
  bool get applicable => enabled && applyOn != ApplyOn.none;

  bool get compounds => method == InterestMethod.compound;
}
