import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/pos/data/pos_catalog.dart';
import 'package:mandi_khata_app/features/pos/domain/pos_cart.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_settings.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sales_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_providers.g.dart';

@Riverpod(keepAlive: true)
Future<PosCatalog> posCatalogRepository(Ref ref) async =>
    PosCatalog(await ref.watch(powerSyncDatabaseProvider.future));

@Riverpod(keepAlive: true)
Future<HeldBillsRepository> heldBillsRepository(Ref ref) async =>
    HeldBillsRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Products with prices and stock for the counter. Live.
@riverpod
Stream<List<PosProduct>> posCatalog(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(posCatalogRepositoryProvider.future);
  yield* repo.watch(tenantId, LedgerDate.fromDateTime(DateTime.now()));
}

/// Bills on hold on this device. Live.
@riverpod
Stream<List<HeldBill>> heldBills(Ref ref) async* {
  final ctx = ref.watch(writeContextProvider);
  if (ctx == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(heldBillsRepositoryProvider.future);
  yield* repo.watch(ctx.tenantId, ctx.deviceId);
}

/// The bill being made. Kept alive so a bill survives a trip to another
/// screen.
@Riverpod(keepAlive: true)
class PosCartController extends _$PosCartController {
  @override
  PosCart build() {
    // A different business starts with an empty counter.
    ref.watch(activeTenantProvider);
    return const PosCart();
  }

  ShopSettings get _settings =>
      ref.read(shopSettingsProvider) ?? const ShopSettings();

  Money? _priceOf(PosProduct p, PosCart cart) =>
      p.prices.lookup(cart.effectiveTier(_settings), _settings.tiers)?.price;

  /// Adds [qtyMilli] of [product]: a second scan of the same product with
  /// the same price adds to its line.
  void add(PosProduct product, {int qtyMilli = Qty.unit}) {
    final price = _priceOf(product, state);
    final i = state.lines.indexWhere(
      (l) => l.product.id == product.id && !l.manualPrice,
    );
    if (i >= 0 && price != null) {
      final l = state.lines[i];
      _setLines([
        for (var k = 0; k < state.lines.length; k++)
          if (k == i)
            l.copyWith(qtyMilli: l.qtyMilli + qtyMilli)
          else
            state.lines[k],
      ]);
      return;
    }
    _setLines([
      ...state.lines,
      PosCartLine(
        product: product,
        qtyMilli: qtyMilli,
        unitPrice: price ?? Money.zero,
        manualPrice: price == null,
      ),
    ]);
  }

  void _setLines(List<PosCartLine> lines) {
    state = state.copyWith(lines: lines);
  }

  void _update(int i, PosCartLine Function(PosCartLine) f) {
    if (i < 0 || i >= state.lines.length) return;
    _setLines([
      for (var k = 0; k < state.lines.length; k++)
        if (k == i) f(state.lines[k]) else state.lines[k],
    ]);
  }

  void setQty(int i, int qtyMilli) {
    if (qtyMilli <= 0) return remove(i);
    _update(i, (l) => _clampDiscount(l.copyWith(qtyMilli: qtyMilli)));
  }

  void bump(int i, int deltaMilli) {
    if (i < 0 || i >= state.lines.length) return;
    setQty(i, state.lines[i].qtyMilli + deltaMilli);
  }

  void setPrice(int i, Money price) => _update(
    i,
    (l) => _clampDiscount(l.copyWith(unitPrice: price, manualPrice: true)),
  );

  void setLineDiscount(int i, Money d) =>
      _update(i, (l) => _clampDiscount(l.copyWith(lineDiscount: d)));

  PosCartLine _clampDiscount(PosCartLine l) {
    final gross = l.toCartLine().gross;
    return l.lineDiscount > gross ? l.copyWith(lineDiscount: gross) : l;
  }

  void remove(int i) {
    if (i < 0 || i >= state.lines.length) return;
    _setLines([
      for (var k = 0; k < state.lines.length; k++)
        if (k != i) state.lines[k],
    ]);
  }

  /// Bill discount in percent basis points (null clears).
  void setDiscountPercent(int? bp) => state = bp == null || bp <= 0
      ? state.copyWith(clearDiscount: true)
      : state
            .copyWith(clearDiscount: true)
            .copyWith(discountPercentBp: bp > 10000 ? 10000 : bp);

  void setDiscountAmount(Money? m) => state = m == null || !m.isPositive
      ? state.copyWith(clearDiscount: true)
      : state.copyWith(clearDiscount: true).copyWith(discountAmount: m);

  /// Picks the price tier by hand for this bill and reprices the lines
  /// whose price was not typed.
  void setTier(String tier) {
    final cart = state.copyWith(tier: tier, tierChosen: true);
    state = _repriced(cart);
  }

  /// Sets the customer (null = walk-in). Unless the cashier chose a tier,
  /// it follows the customer's role (`shop.default_tier_for_role.*`).
  void setParty(Party? p) {
    var cart = state.withParty(
      id: p?.id,
      name: p?.name,
      roles: p?.roles ?? const {},
      gstin: p?.gstin,
      state: p?.state,
    );
    if (!cart.tierChosen) {
      cart = PosCart(
        lines: cart.lines,
        partyId: cart.partyId,
        partyName: cart.partyName,
        partyRoles: cart.partyRoles,
        partyGstin: cart.partyGstin,
        partyState: cart.partyState,
        walkInName: cart.walkInName,
        discountPercentBp: cart.discountPercentBp,
        discountAmount: cart.discountAmount,
      );
    }
    state = _repriced(cart);
  }

  PosCart _repriced(PosCart cart) {
    final tier = cart.effectiveTier(_settings);
    return cart.copyWith(
      lines: [
        for (final l in cart.lines)
          if (l.manualPrice)
            l
          else
            l.copyWith(
              unitPrice:
                  l.product.prices.lookup(tier, _settings.tiers)?.price ??
                  l.unitPrice,
            ),
      ],
    );
  }

  /// F2: a fresh bill.
  void clear() => state = const PosCart();

  /// The cart as JSON for the `held_bills` table.
  Map<String, Object?> toPayload() => {
    'party_id': state.partyId,
    'party_name': state.partyName,
    'party_roles': [for (final r in state.partyRoles) r.name],
    'party_gstin': state.partyGstin,
    'party_state': state.partyState,
    'tier': state.tier,
    'tier_chosen': state.tierChosen,
    'walk_in_name': state.walkInName,
    'discount_bp': state.discountPercentBp,
    'discount_paise': state.discountAmount?.paise,
    'lines': [
      for (final l in state.lines)
        {
          'product_id': l.product.id,
          'qty_milli': l.qtyMilli,
          'price_paise': l.unitPrice.paise,
          'discount_paise': l.lineDiscount.paise,
          'manual': l.manualPrice,
        },
    ],
  };

  /// Recalls a held bill; products that are gone or inactive are skipped
  /// (returns how many). Prices are the ones held.
  int restore(Map<String, Object?> payload, List<PosProduct> catalog) {
    final byId = {for (final p in catalog) p.id: p};
    final lines = <PosCartLine>[];
    var skipped = 0;
    for (final raw in (payload['lines'] as List?) ?? const []) {
      final m = raw as Map;
      final p = byId[m['product_id']];
      if (p == null) {
        skipped++;
        continue;
      }
      lines.add(
        PosCartLine(
          product: p,
          qtyMilli: m['qty_milli']! as int,
          unitPrice: Money(m['price_paise']! as int),
          lineDiscount: Money((m['discount_paise'] as int?) ?? 0),
          manualPrice: (m['manual'] as bool?) ?? false,
        ),
      );
    }
    state = PosCart(
      lines: lines,
      tier: payload['tier'] as String?,
      tierChosen: (payload['tier_chosen'] as bool?) ?? false,
      partyId: payload['party_id'] as String?,
      partyName: payload['party_name'] as String?,
      partyRoles: {
        for (final r in (payload['party_roles'] as List?) ?? const [])
          ?PartyRole.parse(r as String),
      },
      partyGstin: payload['party_gstin'] as String?,
      partyState: payload['party_state'] as String?,
      walkInName: payload['walk_in_name'] as String?,
      discountPercentBp: payload['discount_bp'] as int?,
      discountAmount: payload['discount_paise'] == null
          ? null
          : Money(payload['discount_paise']! as int),
    );
    return skipped;
  }

  /// Puts the current bill on hold and starts a new one.
  Future<bool> hold() async {
    final ctx = ref.read(writeContextProvider);
    if (ctx == null || state.isEmpty) return false;
    final repo = await ref.read(heldBillsRepositoryProvider.future);
    await repo.hold(ctx, toPayload());
    clear();
    return true;
  }
}
