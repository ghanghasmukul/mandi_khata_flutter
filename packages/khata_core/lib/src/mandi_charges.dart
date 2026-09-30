import 'package:decimal/decimal.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/settings/settings_resolver.dart';
import 'package:khata_core/src/settings/settings_schema.dart';
import 'package:meta/meta.dart';

/// A charge on a lot (docs/domain/ledger-and-mandi.md, "Mandi arrival").
/// Order is the order lines are shown and printed in.
enum MandiCharge {
  commission('commission'),
  palledari('palledari'),
  bardana('bardana'),
  tulai('tulai'),
  mandiFee('mandi_fee'),
  cess('cess');

  const MandiCharge(this.key);

  /// Name in `mandi.charges_borne_by` and in snapshots.
  final String key;

  static MandiCharge? parse(String key) {
    for (final c in values) {
      if (c.key == key) return c;
    }
    return null;
  }
}

/// Who pays a charge.
enum ChargePayer {
  farmer,
  buyer,

  /// The arhtiya absorbs it. For commission this means it is waived.
  arhtiya;

  static ChargePayer? parse(String name) {
    for (final p in values) {
      if (p.name == name) return p;
    }
    return null;
  }
}

/// One named cess (`mandi.cess` list entry), e.g. RDF 2%.
@immutable
class CessRate {
  const CessRate(this.name, this.pct);

  final String name;
  final Decimal pct;

  Map<String, Object?> toJson() => {'name': name, 'pct': pct.toString()};

  @override
  bool operator ==(Object other) =>
      other is CessRate && other.name == name && other.pct == pct;

  @override
  int get hashCode => Object.hash(name, pct);
}

/// The resolved mandi rates for one lot. Built from the settings cascade
/// and snapshotted into the lot row when it is posted, so later changes to
/// the business defaults never change an old lot.
@immutable
class MandiConfig {
  const MandiConfig({
    required this.commissionPct,
    required this.palledariPerBag,
    required this.bardanaPerBag,
    required this.tulaiPerQtl,
    required this.mandiFeePct,
    required this.cess,
    required this.borneBy,
    required this.bagWeightKg,
  });

  /// Resolves every `mandi.*` key for a lot of [cropCode] (per-crop keys
  /// win within each level) for [partyId] (the farmer) and [lotId].
  factory MandiConfig.resolve(
    SettingsResolver resolver, {
    String? cropCode,
    String? partyId,
    String? partyGroupId,
    String? lotId,
  }) {
    ResolvedSetting get(String key) => resolver.resolve(
      cropCode == null ? key : '$key.$cropCode',
      partyId: partyId,
      partyGroupId: partyGroupId,
      documentId: lotId,
    );
    return MandiConfig(
      commissionPct: get('mandi.commission_pct').asDecimal,
      palledariPerBag: get('mandi.palledari_per_bag').asMoney,
      bardanaPerBag: get('mandi.bardana_per_bag').asMoney,
      tulaiPerQtl: get('mandi.tulai_per_qtl').asMoney,
      mandiFeePct: get('mandi.mandi_fee_pct').asDecimal,
      // Values were validated by the resolver, so parsing cannot fail.
      cess: _cessFrom(get('mandi.cess').value)!,
      borneBy: _borneByFrom(get('mandi.charges_borne_by').value)!,
      bagWeightKg: get('mandi.bag_weight_kg').asDecimal,
    );
  }

  /// Reads a snapshot written by [toJson]. Throws [FormatException] if it
  /// is not a valid snapshot.
  factory MandiConfig.fromJson(Map<String, Object?> json) {
    Decimal dec(String key, String setting) {
      final v = json[key];
      final def = SettingsSchema.parse(setting)!.def;
      final parsed = SettingsSchema.decimalOf(v);
      if (parsed == null || def.validate(v) != null) {
        throw FormatException('Bad $key in mandi snapshot', v);
      }
      return parsed;
    }

    Money money(String key) {
      final v = json[key];
      if (v is! int || v < 0) {
        throw FormatException('Bad $key in mandi snapshot', v);
      }
      return Money(v);
    }

    final cess = _cessFrom(json['cess']);
    if (cess == null) {
      throw FormatException('Bad cess in mandi snapshot', json['cess']);
    }
    final borneBy = _borneByFrom(json['charges_borne_by']);
    if (borneBy == null) {
      throw FormatException(
        'Bad charges_borne_by in mandi snapshot',
        json['charges_borne_by'],
      );
    }
    return MandiConfig(
      commissionPct: dec('commission_pct', 'mandi.commission_pct'),
      palledariPerBag: money('palledari_per_bag'),
      bardanaPerBag: money('bardana_per_bag'),
      tulaiPerQtl: money('tulai_per_qtl'),
      mandiFeePct: dec('mandi_fee_pct', 'mandi.mandi_fee_pct'),
      cess: cess,
      borneBy: borneBy,
      bagWeightKg: dec('bag_weight_kg', 'mandi.bag_weight_kg'),
    );
  }

  final Decimal commissionPct;
  final Money palledariPerBag;
  final Money bardanaPerBag;
  final Money tulaiPerQtl;
  final Decimal mandiFeePct;
  final List<CessRate> cess;

  /// Who pays each charge; every [MandiCharge] has an entry.
  final Map<MandiCharge, ChargePayer> borneBy;

  /// For "qtl from bags" ([MandiCharges.qtlMilliFromBags]).
  final Decimal bagWeightKg;

  ChargePayer payerOf(MandiCharge charge) => borneBy[charge]!;

  /// Snapshot for `lots.charges_snapshot`: decimals as strings, money as
  /// paise, the same shapes as the settings.
  Map<String, Object?> toJson() => {
    'commission_pct': commissionPct.toString(),
    'palledari_per_bag': palledariPerBag.paise,
    'bardana_per_bag': bardanaPerBag.paise,
    'tulai_per_qtl': tulaiPerQtl.paise,
    'mandi_fee_pct': mandiFeePct.toString(),
    'cess': [for (final c in cess) c.toJson()],
    'charges_borne_by': {
      for (final c in MandiCharge.values) c.key: payerOf(c).name,
    },
    'bag_weight_kg': bagWeightKg.toString(),
  };

  /// Null if [value] is not a valid `mandi.cess` list.
  static List<CessRate>? _cessFrom(Object? value) {
    final def = SettingsSchema.parse('mandi.cess')!.def;
    if (value == null || def.validate(value) != null) return null;
    return List.unmodifiable([
      for (final e in value as List)
        CessRate(
          ((e as Map)['name'] as String).trim(),
          SettingsSchema.decimalOf(e['pct'])!,
        ),
    ]);
  }

  /// Null if [value] is not a valid `mandi.charges_borne_by` map. Charges it
  /// leaves out are paid by the farmer (the system default).
  static Map<MandiCharge, ChargePayer>? _borneByFrom(Object? value) {
    final def = SettingsSchema.parse('mandi.charges_borne_by')!.def;
    if (value == null || def.validate(value) != null) return null;
    final map = value as Map;
    return Map.unmodifiable({
      for (final c in MandiCharge.values)
        c: ChargePayer.parse(map[c.key] as String? ?? '') ?? ChargePayer.farmer,
    });
  }

  @override
  bool operator ==(Object other) =>
      other is MandiConfig &&
      other.commissionPct == commissionPct &&
      other.palledariPerBag == palledariPerBag &&
      other.bardanaPerBag == bardanaPerBag &&
      other.tulaiPerQtl == tulaiPerQtl &&
      other.mandiFeePct == mandiFeePct &&
      _listEquals(other.cess, cess) &&
      MandiCharge.values.every((c) => other.payerOf(c) == payerOf(c)) &&
      other.bagWeightKg == bagWeightKg;

  @override
  int get hashCode => Object.hash(
    commissionPct,
    palledariPerBag,
    bardanaPerBag,
    tulaiPerQtl,
    mandiFeePct,
    Object.hashAll(cess),
    Object.hashAll([for (final c in MandiCharge.values) payerOf(c)]),
    bagWeightKg,
  );

  static bool _listEquals(List<CessRate> a, List<CessRate> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// What was weighed and the rate it sold at.
@immutable
class LotInput {
  const LotInput({
    required this.bags,
    required this.qtlMilli,
    required this.rate,
  });

  final int bags;

  /// Weight in thousandths of a quintal (8.64 qtl = 8640).
  final int qtlMilli;

  /// Rate per quintal.
  final Money rate;
}

/// One charge on a lot.
@immutable
class ChargeLine {
  const ChargeLine({
    required this.charge,
    required this.amount,
    required this.payer,
    this.name,
  });

  final MandiCharge charge;

  /// The cess name (`RDF`); null for other charges.
  final String? name;
  final Money amount;
  final ChargePayer payer;
}

/// The full calculation for one lot.
@immutable
class MandiBreakdown {
  const MandiBreakdown({required this.gross, required this.lines});

  final Money gross;

  /// Every charge, in [MandiCharge] order, cess lines in list order. Zero
  /// lines are included so the breakdown always has the same shape.
  final List<ChargeLine> lines;

  Money _sum(bool Function(ChargeLine) test) =>
      lines.where(test).fold(Money.zero, (a, l) => a + l.amount);

  /// The commission line, whoever pays it.
  Money get commission => _sum((l) => l.charge == MandiCharge.commission);

  /// Commission the arhtiya actually earns (zero when waived).
  Money get commissionEarned => _sum(
    (l) => l.charge == MandiCharge.commission && l.payer != ChargePayer.arhtiya,
  );

  /// Charges taken out of the farmer's money (incl. commission).
  Money get farmerDeductions => _sum((l) => l.payer == ChargePayer.farmer);

  /// Charges added to the buyer's bill.
  Money get buyerCharges => _sum((l) => l.payer == ChargePayer.buyer);

  /// Charges the arhtiya pays from their own pocket. A waived commission is
  /// not a cost, so it is not counted.
  Money get arhtiyaCharges => _sum(
    (l) => l.payer == ChargePayer.arhtiya && l.charge != MandiCharge.commission,
  );

  /// Jama to the farmer's khata.
  Money get netToFarmer => gross - farmerDeductions;

  /// Udhaar to the buyer's khata.
  Money get buyerTotal => gross + buyerCharges;
}

/// Arhat and mandi charges, exactly per docs/domain/ledger-and-mandi.md:
///
/// ```text
/// gross      = round(qtl × rate_per_qtl)
/// commission = round(gross × commission_pct / 100)
/// palledari  = bags × palledari_per_bag
/// bardana    = bags × bardana_per_bag
/// tulai      = round(qtl × tulai_per_qtl)
/// mandi_fee  = round(gross × mandi_fee_pct / 100)
/// cess_i     = round(gross × cess_i_pct / 100)
/// net_to_farmer = gross − Σ charges borne by the farmer
/// ```
///
/// Every rounding is half-up to the paisa, each line on its own.
abstract final class MandiCharges {
  static final _hundred = Decimal.fromInt(100);

  static MandiBreakdown calculate(LotInput lot, MandiConfig config) {
    if (lot.bags < 0) throw ArgumentError.value(lot.bags, 'bags');
    if (lot.qtlMilli < 0) throw ArgumentError.value(lot.qtlMilli, 'qtlMilli');
    if (lot.rate.isNegative) throw ArgumentError.value(lot.rate, 'rate');

    final gross = Money(_perQtl(lot.qtlMilli, lot.rate.paise));
    Money pct(Decimal p) => Money(
      (Decimal.fromInt(gross.paise) * p / _hundred)
          .toDecimal(scaleOnInfinitePrecision: 10)
          .round()
          .toBigInt()
          .toInt(),
    );
    ChargeLine line(MandiCharge c, Money amount, [String? name]) => ChargeLine(
      charge: c,
      amount: amount,
      payer: config.payerOf(c),
      name: name,
    );

    return MandiBreakdown(
      gross: gross,
      lines: List.unmodifiable([
        line(MandiCharge.commission, pct(config.commissionPct)),
        line(
          MandiCharge.palledari,
          Money(lot.bags * config.palledariPerBag.paise),
        ),
        line(MandiCharge.bardana, Money(lot.bags * config.bardanaPerBag.paise)),
        line(
          MandiCharge.tulai,
          Money(_perQtl(lot.qtlMilli, config.tulaiPerQtl.paise)),
        ),
        line(MandiCharge.mandiFee, pct(config.mandiFeePct)),
        for (final c in config.cess) line(MandiCharge.cess, pct(c.pct), c.name),
      ]),
    );
  }

  /// Weight from bag count: bags × kg per bag, in thousandths of a quintal
  /// (1 qtl = 100 kg, so 0.1 kg per unit), rounded half-up.
  static int qtlMilliFromBags(int bags, Decimal bagWeightKg) {
    if (bags < 0) throw ArgumentError.value(bags, 'bags');
    if (bagWeightKg < Decimal.zero) {
      throw ArgumentError.value(bagWeightKg, 'bagWeightKg');
    }
    return (Decimal.fromInt(bags) * bagWeightKg * Decimal.ten)
        .round()
        .toBigInt()
        .toInt();
  }

  /// round(qtlMilli / 1000 × paisePerQtl), half-up, in exact integers.
  static int _perQtl(int qtlMilli, int paisePerQtl) =>
      ((BigInt.from(qtlMilli) * BigInt.from(paisePerQtl) + BigInt.from(500)) ~/
              BigInt.from(1000))
          .toInt();
}
