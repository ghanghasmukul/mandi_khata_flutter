import 'package:decimal/decimal.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/party_rules.dart';
import 'package:khata_core/src/shop_math.dart';
import 'package:meta/meta.dart';

/// GST state codes (first two digits of a GSTIN).
abstract final class GstStates {
  static const names = <String, String>{
    '01': 'Jammu and Kashmir',
    '02': 'Himachal Pradesh',
    '03': 'Punjab',
    '04': 'Chandigarh',
    '05': 'Uttarakhand',
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '10': 'Bihar',
    '11': 'Sikkim',
    '12': 'Arunachal Pradesh',
    '13': 'Nagaland',
    '14': 'Manipur',
    '15': 'Mizoram',
    '16': 'Tripura',
    '17': 'Meghalaya',
    '18': 'Assam',
    '19': 'West Bengal',
    '20': 'Jharkhand',
    '21': 'Odisha',
    '22': 'Chhattisgarh',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '26': 'Dadra and Nagar Haveli and Daman and Diu',
    '27': 'Maharashtra',
    '29': 'Karnataka',
    '30': 'Goa',
    '31': 'Lakshadweep',
    '32': 'Kerala',
    '33': 'Tamil Nadu',
    '34': 'Puducherry',
    '35': 'Andaman and Nicobar Islands',
    '36': 'Telangana',
    '37': 'Andhra Pradesh',
    '38': 'Ladakh',
    '97': 'Other Territory',
  };

  static bool isValid(String code) => names.containsKey(code);

  static String? nameOf(String code) => names[code];

  /// Whether [text] is a GSTIN with a known state and a correct check
  /// character (case and spaces ignored).
  static bool isValidGstin(String text) => stateOfGstin(text) != null;

  /// The state code of a valid GSTIN, else null.
  static String? stateOfGstin(String text) {
    final g = Gstin.normalise(text.replaceAll(RegExp(r'\s'), ''));
    if (g == null) return null;
    final code = g.substring(0, 2);
    return isValid(code) ? code : null;
  }
}

/// Where a supply is taxed (docs/domain/shop-rules.md section 4).
abstract final class PlaceOfSupply {
  /// The customer's GSTIN state, else [customerStateCode], else the
  /// tenant's own state (a counter sale).
  static String of({
    required String tenantStateCode,
    String? customerGstin,
    String? customerStateCode,
  }) {
    final g = customerGstin == null
        ? null
        : GstStates.stateOfGstin(customerGstin);
    if (g != null) return g;
    if (customerStateCode != null && GstStates.isValid(customerStateCode)) {
      return customerStateCode;
    }
    return tenantStateCode;
  }

  /// IGST applies when the place of supply is another state than the
  /// tenant's. Unknown tenant state counts as the same state.
  static bool isInterState(String tenantStateCode, String placeOfSupply) =>
      tenantStateCode.isNotEmpty && tenantStateCode != placeOfSupply;
}

/// GST rates in basis points of a percent (1800 = 18%, 25 = 0.25%).
abstract final class GstRates {
  /// 0, 0.25, 3, 5, 12, 18, 28 percent.
  static const valid = [0, 25, 300, 500, 1200, 1800, 2800];

  static bool isValid(int? rateBp) => rateBp != null && valid.contains(rateBp);

  /// `"18"` / `"0.25"` / `18` -> basis points; null if not a number or
  /// more than two decimals.
  static int? parse(Object? value) {
    final d = switch (value) {
      final String s => Decimal.tryParse(s.trim()),
      final int i => Decimal.fromInt(i),
      _ => null,
    };
    if (d == null) return null;
    final bp = d * Decimal.fromInt(100);
    return bp.isInteger ? bp.toBigInt().toInt() : null;
  }

  /// 1800 -> `18`, 25 -> `0.25`, 250 -> `2.5`.
  static String format(int rateBp) {
    final fraction = (rateBp % 100)
        .toString()
        .padLeft(2, '0')
        .replaceFirst(RegExp(r'0+$'), '');
    return fraction.isEmpty ? '${rateBp ~/ 100}' : '${rateBp ~/ 100}.$fraction';
  }
}

/// A GST problem on a product or a line.
enum GstIssue { missingHsn, invalidHsn, missingRate, invalidRate }

abstract final class GstChecks {
  static final _hsn = RegExp(r'^(\d{4}|\d{6}|\d{8})$');

  /// What is wrong with a product's tax data (empty = fine).
  static List<GstIssue> issues({String? hsn, int? rateBp}) {
    final h = hsn?.trim() ?? '';
    return [
      if (h.isEmpty)
        GstIssue.missingHsn
      else if (!_hsn.hasMatch(h))
        GstIssue.invalidHsn,
      if (rateBp == null)
        GstIssue.missingRate
      else if (!GstRates.isValid(rateBp))
        GstIssue.invalidRate,
    ];
  }
}

/// How tax is worked out for a document.
@immutable
final class GstMode {
  const GstMode({
    this.enabled = true,
    this.pricesIncludeGst = true,
    this.interState = false,
  });

  /// `shop.gst_enabled`; false = every rate counts as 0.
  final bool enabled;

  /// `shop.prices_include_gst`
  final bool pricesIncludeGst;

  /// IGST instead of CGST + SGST.
  final bool interState;
}

/// The tax of one amount.
@immutable
final class GstSplit {
  const GstSplit({
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
  });

  /// Tax of [amount] at [rateBp] (shop-rules section 4).
  ///
  /// Inclusive: [amount] already holds the tax, so taxable is
  /// `amount × 10000 / (10000 + rate)` and the tax the rest. Exclusive: the
  /// tax is added on top. Intra-state CGST is half of the tax (floor) and
  /// SGST the rest; inter-state it is all IGST.
  factory GstSplit.of(
    Money amount,
    int rateBp, {
    required bool inclusive,
    required bool interState,
  }) {
    if (amount.isNegative) {
      throw ArgumentError.value(amount, 'amount', 'must not be negative');
    }
    final Money taxable;
    final int tax;
    if (inclusive) {
      taxable = Money(
        ShopMath.mulDivRound(amount.paise, 10000, 10000 + rateBp),
      );
      tax = amount.paise - taxable.paise;
    } else {
      taxable = amount;
      tax = ShopMath.mulDivRound(amount.paise, rateBp, 10000);
    }
    if (interState) {
      return GstSplit(
        taxable: taxable,
        cgst: Money.zero,
        sgst: Money.zero,
        igst: Money(tax),
      );
    }
    return GstSplit(
      taxable: taxable,
      cgst: Money(tax ~/ 2),
      sgst: Money(tax - tax ~/ 2),
      igst: Money.zero,
    );
  }

  static const zero = GstSplit(
    taxable: Money.zero,
    cgst: Money.zero,
    sgst: Money.zero,
    igst: Money.zero,
  );

  final Money taxable;
  final Money cgst;
  final Money sgst;
  final Money igst;

  Money get tax => cgst + sgst + igst;

  /// Taxable + tax.
  Money get total => taxable + tax;

  /// The same amounts with the signs flipped (a credit note in a report).
  GstSplit operator -() =>
      GstSplit(taxable: -taxable, cgst: -cgst, sgst: -sgst, igst: -igst);

  GstSplit operator +(GstSplit o) => GstSplit(
    taxable: taxable + o.taxable,
    cgst: cgst + o.cgst,
    sgst: sgst + o.sgst,
    igst: igst + o.igst,
  );
}

/// One line to tax: [amount] is the line value after every discount.
@immutable
final class GstLineInput {
  const GstLineInput({required this.amount, this.rateBp, this.hsn});

  final Money amount;

  /// Null = no rate set: taxed at 0 and flagged.
  final int? rateBp;
  final String? hsn;
}

/// Tax of a whole document: per line, summed.
@immutable
final class GstInvoice {
  const GstInvoice({required this.lines, required this.issues});

  factory GstInvoice.compute(List<GstLineInput> lines, GstMode mode) {
    final splits = <GstSplit>[];
    final issues = <int, List<GstIssue>>{};
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (mode.enabled) {
        final found = GstChecks.issues(hsn: l.hsn, rateBp: l.rateBp);
        if (found.isNotEmpty) issues[i] = found;
      }
      splits.add(
        GstSplit.of(
          l.amount,
          mode.enabled ? l.rateBp ?? 0 : 0,
          inclusive: mode.pricesIncludeGst,
          interState: mode.interState,
        ),
      );
    }
    return GstInvoice(lines: splits, issues: issues);
  }

  final List<GstSplit> lines;

  /// Problems by line index (only when GST is on).
  final Map<int, List<GstIssue>> issues;

  GstSplit get total => lines.fold(GstSplit.zero, (a, s) => a + s);
}

/// One row of the HSN summary.
@immutable
final class HsnRow {
  const HsnRow({
    required this.hsn,
    required this.rateBp,
    required this.qtyMilli,
    required this.split,
  });

  final String hsn;
  final int rateBp;
  final int qtyMilli;
  final GstSplit split;
}

/// A line for the HSN summary.
@immutable
final class HsnInput {
  const HsnInput({
    required this.hsn,
    required this.rateBp,
    required this.qtyMilli,
    required this.split,
  });

  final String hsn;
  final int rateBp;
  final int qtyMilli;
  final GstSplit split;
}

abstract final class HsnSummary {
  /// Lines grouped by HSN and rate, sorted by HSN then rate. A missing HSN
  /// is grouped under the empty string.
  static List<HsnRow> build(Iterable<HsnInput> lines) {
    final groups = <(String, int), HsnRow>{};
    for (final l in lines) {
      final key = (l.hsn.trim(), l.rateBp);
      final old = groups[key];
      groups[key] = HsnRow(
        hsn: key.$1,
        rateBp: l.rateBp,
        qtyMilli: (old?.qtyMilli ?? 0) + l.qtyMilli,
        split: old == null ? l.split : old.split + l.split,
      );
    }
    return groups.values.toList()..sort((a, b) {
      final c = a.hsn.compareTo(b.hsn);
      return c != 0 ? c : a.rateBp.compareTo(b.rateBp);
    });
  }
}
