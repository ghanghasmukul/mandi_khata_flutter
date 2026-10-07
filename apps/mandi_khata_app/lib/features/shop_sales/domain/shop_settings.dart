import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// The shop settings a bill needs, resolved once (docs/domain/shop-rules.md
/// section 8). Built from the settings cascade so the POS preview and the
/// repository that saves the bill always agree.
@immutable
class ShopSettings {
  const ShopSettings({
    this.gstEnabled = true,
    this.pricesIncludeGst = true,
    this.roundToRupee = true,
    this.policy = const StockPolicy(),
    this.tiers = const PriceTiers(),
    this.tenantStateCode = '',
    this.gstin = '',
    this.creditLimits = const _NoCreditLimits(),
  });

  /// Reads every key from [r]. [PriceTiers.byRole] gets one entry per role.
  factory ShopSettings.from(SettingsResolver r) {
    String text(String key) => r.resolve(key).value! as String;
    bool flag(String key) => r.resolve(key).value! as bool;
    final tiers = [
      for (final t in r.resolve('shop.price_tiers').value! as List<Object?>)
        t! as String,
    ];
    return ShopSettings(
      gstEnabled: flag('shop.gst_enabled'),
      pricesIncludeGst: flag('shop.prices_include_gst'),
      roundToRupee: flag('shop.round_invoice_to_rupee'),
      policy: StockPolicy(
        blockExpired: flag('shop.block_expired'),
        allowNegative: flag('shop.allow_negative_stock'),
        expiryWarnDays: r.resolve('shop.expiry_warn_days').value! as int,
      ),
      tiers: PriceTiers(
        tiers: tiers.isEmpty ? PriceTiers.defaultTiers : tiers,
        defaultTier: text('shop.default_tier'),
        byRole: {
          for (final role in PartyRole.values)
            role: text('shop.default_tier_for_role.${role.name}'),
        },
      ),
      tenantStateCode: text('business.state_code'),
      gstin: text('business.gstin'),
      creditLimits: _ResolverLimits(r),
    );
  }

  /// `shop.gst_enabled`
  final bool gstEnabled;

  /// `shop.prices_include_gst`
  final bool pricesIncludeGst;

  /// `shop.round_invoice_to_rupee`
  final bool roundToRupee;

  /// `shop.block_expired`, `shop.allow_negative_stock`,
  /// `shop.expiry_warn_days`.
  final StockPolicy policy;
  final PriceTiers tiers;

  /// `business.state_code` (2 digits, "" = unknown).
  final String tenantStateCode;

  /// `business.gstin`
  final String gstin;
  final CreditLimits creditLimits;

  /// Credit limit in paise for [partyId] (0 = no limit): the party's own
  /// override, else the business's.
  int creditLimitFor(String? partyId) => creditLimits.limitFor(partyId);

  GstMode gstMode({required bool interState}) => GstMode(
    enabled: gstEnabled,
    pricesIncludeGst: pricesIncludeGst,
    interState: interState,
  );
}

/// Source of `business.credit_limit` per party.
abstract interface class CreditLimits {
  int limitFor(String? partyId);
}

class _NoCreditLimits implements CreditLimits {
  const _NoCreditLimits();

  @override
  int limitFor(String? partyId) => 0;
}

class _ResolverLimits implements CreditLimits {
  const _ResolverLimits(this._r);

  final SettingsResolver _r;

  @override
  int limitFor(String? partyId) =>
      _r.resolve('business.credit_limit', partyId: partyId).value! as int;
}

/// Where a bill is taxed: the place of supply and whether that is another
/// state than the shop's (IGST) (shop-rules section 4).
@immutable
class SupplyPlace {
  const SupplyPlace(this.code, {required this.interState});

  /// Customer's GSTIN state, else the state they live in, else the shop's.
  factory SupplyPlace.of(
    ShopSettings settings, {
    String? customerGstin,
    String? customerState,
  }) {
    final code = PlaceOfSupply.of(
      tenantStateCode: settings.tenantStateCode,
      customerGstin: customerGstin,
      customerStateCode: _codeOfState(customerState),
    );
    return SupplyPlace(
      code,
      interState: PlaceOfSupply.isInterState(settings.tenantStateCode, code),
    );
  }

  final String code;
  final bool interState;

  /// "Punjab" / "03" -> "03". Names are matched ignoring case.
  static String? _codeOfState(String? state) {
    final s = state?.trim();
    if (s == null || s.isEmpty) return null;
    if (GstStates.isValid(s)) return s;
    for (final e in GstStates.names.entries) {
      if (e.value.toLowerCase() == s.toLowerCase()) return e.key;
    }
    return null;
  }
}
