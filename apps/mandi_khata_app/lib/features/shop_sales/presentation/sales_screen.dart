import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_labels.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_screen.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_settings.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sales_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class SalesRoutes {
  static const list = '/shop/sales';
  static String detail(String id) => '/shop/sales/$id';
}

/// Shop sales: party, items, tier, total and the paid / udhaar split, with
/// filters (date, payment, tier, text) and totals.
class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  SaleFilter _filter = SaleFilter(
    from: LedgerDate.fromDateTime(DateTime.now()),
    to: LedgerDate.fromDateTime(DateTime.now()),
  );
  List<SaleRecord>? _last;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canSell = ref.watch(canProvider(Permission.salesCreate));
    final sales = ref.watch(saleListProvider(_filter)).value ?? _last;
    _last = sales;
    final tiers =
        (ref.watch(shopSettingsProvider) ?? const ShopSettings()).tiers.tiers;
    return Scaffold(
      floatingActionButton: canSell
          ? FloatingActionButton.extended(
              onPressed: () => context.go(PosRoutes.pos),
              icon: const Icon(Icons.add),
              label: Text(l10n.salesNewSale),
            )
          : null,
      body: Column(
        children: [
          MkTopBar(title: l10n.salesTitle),
          Padding(
            padding: const EdgeInsets.all(MkSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MkTextField(
                  key: const ValueKey('sales-search'),
                  hint: l10n.salesSearchHint,
                  prefix: const Icon(Icons.search, size: 20),
                  onChanged: (v) =>
                      setState(() => _filter = _filter.copyWith(query: v)),
                ),
                const SizedBox(height: MkSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      DateRangeChips(
                        from: _filter.from,
                        to: _filter.to,
                        keyPrefix: 'sales',
                        onChanged: (f, t) => setState(
                          () => _filter = f == null && t == null
                              ? _filter.copyWith(clearDates: true)
                              : _filter.copyWith(from: f, to: t),
                        ),
                      ),
                      const SizedBox(width: MkSpacing.md),
                      DropdownButton<SalePaymentKind?>(
                        key: const ValueKey('sales-payment'),
                        value: _filter.payment,
                        items: [
                          DropdownMenuItem(child: Text(l10n.salesFilterAll)),
                          DropdownMenuItem(
                            value: SalePaymentKind.cash,
                            child: Text(l10n.posPayCash),
                          ),
                          DropdownMenuItem(
                            value: SalePaymentKind.upi,
                            child: Text(l10n.posPayUpi),
                          ),
                          DropdownMenuItem(
                            value: SalePaymentKind.udhaar,
                            child: Text(l10n.posPayUdhaar),
                          ),
                        ],
                        onChanged: (v) => setState(
                          () => _filter = v == null
                              ? _filter.copyWith(clearPayment: true)
                              : _filter.copyWith(payment: v),
                        ),
                      ),
                      const SizedBox(width: MkSpacing.md),
                      DropdownButton<String?>(
                        key: const ValueKey('sales-tier'),
                        value: tiers.contains(_filter.tier)
                            ? _filter.tier
                            : null,
                        items: [
                          DropdownMenuItem(child: Text(l10n.posTierLabel)),
                          for (final t in tiers)
                            DropdownMenuItem(
                              value: t,
                              child: Text(l10n.tierName(t)),
                            ),
                        ],
                        onChanged: (v) => setState(
                          () => _filter = v == null
                              ? _filter.copyWith(clearTier: true)
                              : _filter.copyWith(tier: v),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _body(l10n, sales)),
          if (sales != null && sales.isNotEmpty) _Totals(sales: sales),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations l10n, List<SaleRecord>? sales) {
    if (sales == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (sales.isEmpty) {
      return MkEmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.salesEmpty,
      );
    }
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth < MkBreakpoints.rail
          ? ListView.builder(
              itemCount: sales.length,
              padding: const EdgeInsets.only(bottom: 88),
              itemBuilder: (context, i) => _SaleTile(sale: sales[i]),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(
                MkSpacing.lg,
                0,
                MkSpacing.lg,
                MkSpacing.lg,
              ),
              child: _SaleTable(sales: sales),
            ),
    );
  }
}

String _customer(AppLocalizations l10n, SaleRecord s) =>
    s.displayName ?? l10n.posWalkIn;

class _SaleTable extends StatelessWidget {
  const _SaleTable({required this.sales});

  final List<SaleRecord> sales;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkDataTable<SaleRecord>(
      minWidth: 900,
      rows: sales,
      onRowTap: (s) => context.go(SalesRoutes.detail(s.id)),
      columns: [
        MkColumn(
          label: l10n.salesColNo,
          flex: 3,
          cell: (s) => Text(s.saleNo, style: MkText.mono()),
          sortKey: (s) => s.saleNo,
        ),
        MkColumn(
          label: l10n.salesColDate,
          flex: 3,
          cell: (s) => Text(AppFormat.ledgerDate(context, s.entryDate)),
          sortKey: (s) => s.entryDate,
        ),
        MkColumn(
          label: l10n.salesColCustomer,
          flex: 5,
          cell: (s) =>
              Text(_customer(l10n, s), overflow: TextOverflow.ellipsis),
        ),
        MkColumn(
          label: l10n.salesColItems,
          flex: 2,
          numeric: true,
          cell: (s) => Text('${s.itemCount}'),
        ),
        MkColumn(
          label: l10n.salesColTier,
          flex: 2,
          cell: (s) => Text(s.tier == null ? '' : l10n.tierName(s.tier!)),
        ),
        MkColumn(
          label: l10n.salesColTotal,
          flex: 3,
          numeric: true,
          cell: (s) => MkMoneyText(s.total),
          sortKey: (s) => s.total.paise,
        ),
        MkColumn(
          label: l10n.salesColPaid,
          flex: 3,
          numeric: true,
          cell: (s) => MkMoneyText(s.paidNow, tone: MkMoneyTone.jama),
        ),
        MkColumn(
          label: l10n.salesColUdhaar,
          flex: 3,
          numeric: true,
          cell: (s) => MkMoneyText(s.paidCredit, tone: MkMoneyTone.udhaar),
        ),
        MkColumn(
          label: '',
          flex: 2,
          cell: (s) => s.isReversed
              ? MkRoleChip(label: l10n.salesReversedTag, warning: true)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SaleTile extends StatelessWidget {
  const _SaleTile({required this.sale});

  final SaleRecord sale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      minVerticalPadding: 12,
      onTap: () => context.go(SalesRoutes.detail(sale.id)),
      title: Text(
        _customer(l10n, sale),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${sale.saleNo} · ${AppFormat.ledgerDate(context, sale.entryDate)}'
        '${_udhaarText(l10n, sale)}'
        '${sale.isReversed ? ' · ${l10n.salesReversedTag}' : ''}',
      ),
      trailing: MkMoneyText(sale.total, size: 15),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.sales});

  final List<SaleRecord> sales;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = SalesSummary.of(sales);
    return Material(
      color: MkTokens.of(context).surfaceAlt,
      child: Padding(
        padding: const EdgeInsets.all(MkSpacing.md),
        child: Text(
          l10n.salesTotalsBar(
            s.count,
            s.total.format(),
            s.cash.format(),
            s.upi.format(),
            s.udhaar.format(),
          ),
          key: const ValueKey('sales-totals'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

String _udhaarText(AppLocalizations l10n, SaleRecord s) =>
    s.paidCredit.isPositive
    ? ' · ${l10n.posPayUdhaar} ${s.paidCredit.format()}'
    : '';
