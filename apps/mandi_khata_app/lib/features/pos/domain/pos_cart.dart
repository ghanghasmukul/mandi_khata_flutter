import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_settings.dart';

/// A product as the counter sees it: price per tier and stock left.
@immutable
class PosProduct {
  const PosProduct({
    required this.id,
    required this.sku,
    required this.name,
    required this.unit,
    required this.prices,
    required this.stockMilli,
    this.barcode,
    this.brand,
    this.hsn,
    this.rateBp,
    this.expiredMilli = 0,
    this.nearestExpiry,
  });

  final String id;
  final String sku;
  final String? barcode;
  final String name;
  final String? brand;
  final String unit;
  final String? hsn;
  final int? rateBp;
  final TierPrices prices;

  /// Σ stock movements of the product.
  final int stockMilli;

  /// Part of the stock that sits in expired batches.
  final int expiredMilli;
  final LedgerDate? nearestExpiry;

  /// What can be sold: expired stock is left out when the policy blocks it.
  int sellableMilli({required bool blockExpired}) =>
      blockExpired ? stockMilli - expiredMilli : stockMilli;

  /// Matches the search text: name, brand, SKU or barcode.
  bool matches(String q) {
    final t = q.trim().toLowerCase();
    if (t.isEmpty) return true;
    return name.toLowerCase().contains(t) ||
        (brand?.toLowerCase().contains(t) ?? false) ||
        sku.toLowerCase().contains(t) ||
        (barcode?.toLowerCase().contains(t) ?? false);
  }
}

/// One line in the cart.
@immutable
class PosCartLine {
  const PosCartLine({
    required this.product,
    required this.qtyMilli,
    required this.unitPrice,
    this.lineDiscount = Money.zero,
    this.manualPrice = false,
  });

  final PosProduct product;
  final int qtyMilli;
  final Money unitPrice;
  final Money lineDiscount;

  /// The cashier typed the price: a tier change leaves it alone.
  final bool manualPrice;

  CartLine toCartLine() => CartLine(
    productId: product.id,
    name: product.name,
    qtyMilli: qtyMilli,
    unitPrice: unitPrice,
    lineDiscount: lineDiscount,
    rateBp: product.rateBp,
    hsn: product.hsn,
  );

  PosCartLine copyWith({
    int? qtyMilli,
    Money? unitPrice,
    Money? lineDiscount,
    bool? manualPrice,
  }) => PosCartLine(
    product: product,
    qtyMilli: qtyMilli ?? this.qtyMilli,
    unitPrice: unitPrice ?? this.unitPrice,
    lineDiscount: lineDiscount ?? this.lineDiscount,
    manualPrice: manualPrice ?? this.manualPrice,
  );
}

/// The bill being made at the counter.
@immutable
class PosCart {
  const PosCart({
    this.lines = const [],
    this.tier,
    this.partyId,
    this.partyName,
    this.partyRoles = const {},
    this.partyGstin,
    this.partyState,
    this.walkInName,
    this.discountPercentBp,
    this.discountAmount,
    this.tierChosen = false,
  });

  final List<PosCartLine> lines;

  /// Null until the first line: then the default tier for the customer.
  final String? tier;
  final bool tierChosen;
  final String? partyId;
  final String? partyName;
  final Set<PartyRole> partyRoles;
  final String? partyGstin;
  final String? partyState;
  final String? walkInName;

  /// Bill discount: a percent (basis points) or a fixed amount, not both.
  final int? discountPercentBp;
  final Money? discountAmount;

  bool get isEmpty => lines.isEmpty;

  InvoiceDiscount get discount => discountPercentBp != null
      ? InvoiceDiscount.percent(discountPercentBp!)
      : discountAmount != null && discountAmount!.isPositive
      ? InvoiceDiscount.amount(discountAmount!)
      : const InvoiceDiscount.none();

  PosCart copyWith({
    List<PosCartLine>? lines,
    String? tier,
    bool? tierChosen,
    int? discountPercentBp,
    Money? discountAmount,
    bool clearDiscount = false,
    String? walkInName,
  }) => PosCart(
    lines: lines ?? this.lines,
    tier: tier ?? this.tier,
    tierChosen: tierChosen ?? this.tierChosen,
    partyId: partyId,
    partyName: partyName,
    partyRoles: partyRoles,
    partyGstin: partyGstin,
    partyState: partyState,
    walkInName: walkInName ?? this.walkInName,
    discountPercentBp: clearDiscount
        ? null
        : discountPercentBp ?? this.discountPercentBp,
    discountAmount: clearDiscount
        ? null
        : discountAmount ?? this.discountAmount,
  );

  PosCart withParty({
    String? id,
    String? name,
    Set<PartyRole> roles = const {},
    String? gstin,
    String? state,
  }) => PosCart(
    lines: lines,
    tier: tier,
    tierChosen: tierChosen,
    partyId: id,
    partyName: name,
    partyRoles: roles,
    partyGstin: gstin,
    partyState: state,
    walkInName: walkInName,
    discountPercentBp: discountPercentBp,
    discountAmount: discountAmount,
  );

  /// The tier the bill is priced in under [settings].
  String effectiveTier(ShopSettings settings) =>
      tier ?? settings.tiers.tierFor(partyRoles);

  /// Worked-out bill, or null when the cart is empty or a discount is
  /// beyond its base.
  SaleTotals? totals(ShopSettings settings) {
    if (lines.isEmpty) return null;
    final place = SupplyPlace.of(
      settings,
      customerGstin: partyGstin,
      customerState: partyState,
    );
    try {
      return SaleCalculator.compute(
        lines: [for (final l in lines) l.toCartLine()],
        mode: settings.gstMode(interState: place.interState),
        discount: discount,
        roundToRupee: settings.roundToRupee,
      );
      // SaleCalculator throws ArgumentError for an impossible discount.
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return null;
    }
  }

  SaleDraft toDraft({
    required ShopSettings settings,
    required PaymentSplit payment,
    String? upiAccountId,
    LedgerDate? date,
    String? notes,
  }) => SaleDraft(
    entryDate: date,
    partyId: partyId,
    customerName: partyId == null ? walkInName : null,
    tier: effectiveTier(settings),
    discount: discount,
    payment: payment,
    upiAccountId: upiAccountId,
    notes: notes,
    lines: [
      for (final l in lines)
        SaleDraftLine(
          productId: l.product.id,
          qtyMilli: l.qtyMilli,
          unitPrice: l.unitPrice,
          lineDiscount: l.lineDiscount,
        ),
    ],
  );
}

/// What the product search decides for the typed text.
@immutable
class SearchIntent {
  const SearchIntent(this.qtyMilli, this.query);

  /// `5*urea` = 5 units of "urea". Anything else = one unit.
  factory SearchIntent.parse(String text) {
    final star = text.indexOf('*');
    if (star > 0) {
      final q = Qty.parse(text.substring(0, star));
      if (q != null && q > 0) {
        return SearchIntent(q, text.substring(star + 1).trim());
      }
    }
    return SearchIntent(Qty.unit, text.trim());
  }

  final int qtyMilli;
  final String query;
}
