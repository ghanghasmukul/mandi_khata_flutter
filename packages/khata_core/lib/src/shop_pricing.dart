import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/party_rules.dart';
import 'package:meta/meta.dart';

/// The tenant's price tiers and how a bill picks its default one
/// (docs/domain/shop-rules.md section 2).
@immutable
final class PriceTiers {
  const PriceTiers({
    this.tiers = defaultTiers,
    this.defaultTier = 'retail',
    this.byRole = const {},
  });

  static const defaultTiers = ['farmer', 'retail', 'vendor', 'wholesale'];

  /// The tiers in display order (`shop.price_tiers`); never empty.
  final List<String> tiers;

  /// Tier of a walk-in and fallback (`shop.default_tier`).
  final String defaultTier;

  /// `shop.default_tier_for_role.<role>`, resolved for every role.
  final Map<PartyRole, String> byRole;

  /// The order in which a party's roles are asked.
  static const List<PartyRole> rolePriority = [
    PartyRole.vendor,
    PartyRole.farmer,
    PartyRole.customer,
    PartyRole.buyer,
    PartyRole.supplier,
    PartyRole.agency,
  ];

  String get _fallback => tiers.contains(defaultTier) ? defaultTier : tiers[0];

  /// The default tier for a bill to a party with [roles] (empty = walk-in).
  String tierFor(Set<PartyRole> roles) {
    for (final role in rolePriority) {
      final tier = byRole[role];
      if (roles.contains(role) && tier != null) {
        return tiers.contains(tier) ? tier : _fallback;
      }
    }
    return _fallback;
  }
}

/// How a price was found.
@immutable
final class PriceLookup {
  const PriceLookup(this.price, this.tier, {required this.fellBack});

  final Money price;

  /// The tier the price belongs to.
  final String tier;

  /// True when the wanted tier had no price.
  final bool fellBack;
}

/// A product's `prices` (`{tier: paise}`).
@immutable
final class TierPrices {
  const TierPrices(this.prices);

  /// From JSON; entries that are not a non-negative whole number are
  /// ignored (a price is never guessed).
  factory TierPrices.fromJson(Map<String, Object?> json) => TierPrices({
    for (final e in json.entries)
      if (e.value is int && (e.value! as int) >= 0)
        e.key: Money(e.value! as int),
  });

  final Map<String, Money> prices;

  Map<String, int> toJson() => {
    for (final e in prices.entries) e.key: e.value.paise,
  };

  /// The price for [tier]; else for the default tier, then `retail`, then
  /// the first tier of [config] that has one. Null when there is none (the
  /// cashier types a price).
  PriceLookup? lookup(String tier, PriceTiers config) {
    final direct = prices[tier];
    if (direct != null) return PriceLookup(direct, tier, fellBack: false);
    for (final t in [config.defaultTier, 'retail', ...config.tiers]) {
      final p = prices[t];
      if (p != null) return PriceLookup(p, t, fellBack: true);
    }
    return null;
  }
}
