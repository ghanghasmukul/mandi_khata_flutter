import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// A lot as stored locally, with the names the screens show.
@immutable
class Lot {
  const Lot({
    required this.id,
    required this.lotNo,
    required this.entryDate,
    required this.farmerId,
    required this.farmerName,
    required this.cropId,
    required this.cropCode,
    required this.cropName,
    required this.bags,
    required this.qtlFromBags,
    required this.status,
    this.farmerCode,
    this.farmerVillage,
    this.qtlMilli,
    this.rate,
    this.buyerId,
    this.buyerName,
    this.jFormNo,
    this.vehicleNo,
    this.notes,
    this.snapshot,
    this.gross,
    this.commission,
    this.netToFarmer,
    this.buyerTotal,
    this.postedAt,
  });

  /// From a `lots` row joined with the farmer, buyer and crop (see
  /// `LotsRepository`).
  factory Lot.fromRow(Map<String, Object?> r) {
    Money? money(String key) => switch (r[key]) {
      final int p => Money(p),
      _ => null,
    };
    final snapshot = r['charges_snapshot'] as String?;
    return Lot(
      id: r['id']! as String,
      lotNo: r['lot_no']! as String,
      entryDate: LedgerDate.parse(r['entry_date']! as String),
      farmerId: r['farmer_id']! as String,
      farmerName: (r['farmer_name'] as String?) ?? '',
      farmerCode: r['farmer_code'] as String?,
      farmerVillage: r['farmer_village'] as String?,
      cropId: r['crop_id']! as String,
      cropCode: (r['crop_code'] as String?) ?? '',
      cropName: {
        'en': (r['crop_name_en'] as String?) ?? '',
        'hi': ?r['crop_name_hi'] as String?,
        'pa': ?r['crop_name_pa'] as String?,
      },
      bags: (r['bags'] as int?) ?? 0,
      qtlMilli: r['qtl_milli'] as int?,
      qtlFromBags: r['qtl_from_bags'] == 1 || r['qtl_from_bags'] == true,
      rate: money('rate_paise_per_qtl'),
      buyerId: r['buyer_party_id'] as String?,
      buyerName: r['buyer_name'] as String?,
      jFormNo: r['j_form_no'] as String?,
      vehicleNo: r['vehicle_no'] as String?,
      notes: r['notes'] as String?,
      status: LotStatus.parse(r['status']! as String),
      snapshot: snapshot == null
          ? null
          : MandiConfig.fromJson(jsonDecode(snapshot) as Map<String, Object?>),
      gross: money('gross'),
      commission: money('commission'),
      netToFarmer: money('net_to_farmer'),
      buyerTotal: money('buyer_total'),
      postedAt: switch (r['posted_at']) {
        final String s => DateTime.parse(s),
        _ => null,
      },
    );
  }

  final String id;

  /// `L-W1-0001`.
  final String lotNo;
  final LedgerDate entryDate;
  final String farmerId;
  final String farmerName;
  final String? farmerCode;
  final String? farmerVillage;
  final String cropId;
  final String cropCode;

  /// Crop name by language code; `en` always present.
  final Map<String, String> cropName;
  final int bags;

  /// Thousandths of a quintal; null until weighed.
  final int? qtlMilli;
  final bool qtlFromBags;

  /// Per quintal; null until sold.
  final Money? rate;
  final String? buyerId;
  final String? buyerName;
  final String? jFormNo;
  final String? vehicleNo;
  final String? notes;
  final LotStatus status;

  /// The rates it was posted with; null until posted.
  final MandiConfig? snapshot;
  final Money? gross;

  /// Commission earned (zero when waived).
  final Money? commission;
  final Money? netToFarmer;
  final Money? buyerTotal;
  final DateTime? postedAt;

  /// Reversed before it was ever posted.
  bool get isCancelled => status == LotStatus.reversed && postedAt == null;

  /// Reversed after posting (its ledger entries were reversed).
  bool get isReversedAfterPosting =>
      status == LotStatus.reversed && postedAt != null;

  String cropNameIn(String languageCode) {
    final local = cropName[languageCode];
    return local == null || local.trim().isEmpty ? cropName['en']! : local;
  }

  /// Pre-fills the edit form.
  LotDraft toDraft() => LotDraft(
    entryDate: entryDate,
    farmerId: farmerId,
    cropId: cropId,
    bags: bags,
    qtlMilli: qtlMilli,
    qtlFromBags: qtlFromBags,
    rate: rate,
    buyerId: buyerId,
    jFormNo: jFormNo,
    vehicleNo: vehicleNo,
    notes: notes,
  );
}

/// What the lot form holds.
@immutable
class LotDraft {
  const LotDraft({
    required this.entryDate,
    required this.farmerId,
    required this.cropId,
    this.bags = 0,
    this.qtlMilli,
    this.qtlFromBags = false,
    this.rate,
    this.buyerId,
    this.jFormNo,
    this.vehicleNo,
    this.notes,
  });

  final LedgerDate entryDate;
  final String farmerId;
  final String cropId;
  final int bags;
  final int? qtlMilli;
  final bool qtlFromBags;
  final Money? rate;
  final String? buyerId;
  final String? jFormNo;
  final String? vehicleNo;
  final String? notes;

  Set<LotProblem> validate() => LotRules.validate(
    farmerId: farmerId,
    bags: bags,
    qtlMilli: qtlMilli,
    rate: rate,
    buyerId: buyerId,
  );

  /// Values for the lot's own columns (not status or posting amounts),
  /// trimmed, empty text as null.
  Map<String, Object?> columns() {
    String? clean(String? s) {
      final t = s?.trim();
      return t == null || t.isEmpty ? null : t;
    }

    return {
      'entry_date': entryDate.toString(),
      'farmer_id': farmerId,
      'crop_id': cropId,
      'bags': bags,
      'qtl_milli': qtlMilli,
      'qtl_from_bags': qtlFromBags ? 1 : 0,
      'rate_paise_per_qtl': rate?.paise,
      'buyer_party_id': buyerId,
      'j_form_no': clean(jFormNo),
      'vehicle_no': clean(vehicleNo)?.toUpperCase(),
      'notes': clean(notes),
    };
  }
}

/// Filters for the arrivals list. All null = every lot.
@immutable
class LotFilter {
  const LotFilter({
    this.from,
    this.to,
    this.cropId,
    this.status,
    this.query = '',
  });

  final LedgerDate? from;
  final LedgerDate? to;
  final String? cropId;
  final LotStatus? status;

  /// Matches the farmer's name or code, or the lot number.
  final String query;

  LotFilter copyWith({
    LedgerDate? Function()? from,
    LedgerDate? Function()? to,
    String? Function()? cropId,
    LotStatus? Function()? status,
    String? query,
  }) => LotFilter(
    from: from == null ? this.from : from(),
    to: to == null ? this.to : to(),
    cropId: cropId == null ? this.cropId : cropId(),
    status: status == null ? this.status : status(),
    query: query ?? this.query,
  );

  @override
  bool operator ==(Object other) =>
      other is LotFilter &&
      other.from == from &&
      other.to == to &&
      other.cropId == cropId &&
      other.status == status &&
      other.query == query;

  @override
  int get hashCode => Object.hash(from, to, cropId, status, query);
}

/// Totals of a list of lots. Cancelled and reversed lots are left out:
/// they are not business done.
@immutable
class LotTotals {
  const LotTotals({
    required this.count,
    required this.bags,
    required this.qtlMilli,
    required this.gross,
    required this.netToFarmer,
  });

  factory LotTotals.of(Iterable<Lot> lots) {
    var count = 0;
    var bags = 0;
    var qtl = 0;
    var gross = Money.zero;
    var net = Money.zero;
    for (final l in lots) {
      if (l.status == LotStatus.reversed) continue;
      count++;
      bags += l.bags;
      qtl += l.qtlMilli ?? 0;
      gross += l.gross ?? Money.zero;
      net += l.netToFarmer ?? Money.zero;
    }
    return LotTotals(
      count: count,
      bags: bags,
      qtlMilli: qtl,
      gross: gross,
      netToFarmer: net,
    );
  }

  final int count;
  final int bags;
  final int qtlMilli;

  /// Of posted lots only (open lots have no amounts yet).
  final Money gross;
  final Money netToFarmer;
}

sealed class LotSaveResult {
  const LotSaveResult();
}

final class LotSaved extends LotSaveResult {
  const LotSaved(this.id, this.lotNo, this.status);

  final String id;
  final String lotNo;
  final LotStatus status;
}

final class LotNotPermitted extends LotSaveResult {
  const LotNotPermitted(this.permission);

  final Permission permission;
}

/// The lot, its farmer, buyer or crop does not exist in this business.
final class LotNotFound extends LotSaveResult {
  const LotNotFound();
}

final class LotInvalid extends LotSaveResult {
  const LotInvalid(this.problems);

  final Set<LotProblem> problems;
}

/// The lot is posted or reversed: it cannot be edited or cancelled, and
/// only a posted lot can be reversed.
final class LotLocked extends LotSaveResult {
  const LotLocked(this.status);

  final LotStatus status;
}
