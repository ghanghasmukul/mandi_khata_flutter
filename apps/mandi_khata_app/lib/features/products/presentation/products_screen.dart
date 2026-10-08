import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/products/domain/product.dart';
import 'package:mandi_khata_app/features/products/domain/stock.dart';
import 'package:mandi_khata_app/features/products/presentation/products_labels.dart';
import 'package:mandi_khata_app/features/products/presentation/products_providers.dart';
import 'package:mandi_khata_app/features/products/presentation/products_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

/// Products & stock: summary tiles, filters and the table with batches, cost,
/// tier prices, margin, stock and value. Cost, margin and value are hidden
/// without `shop.view_profit`. Ctrl/Cmd+F searches, Ctrl/Cmd+N adds.
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  ProductFilter _filter = const ProductFilter();
  List<ProductWithStock>? _last;

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add() => context.go(ProductRoutes.create);

  void _set(StockFilter f) => setState(
    () => _filter = ProductFilter(
      query: _filter.query,
      categoryId: _filter.categoryId,
      stock: _filter.stock == f ? StockFilter.all : f,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final manage = ref.watch(canProvider(Permission.productsManage));
    final adjust = ref.watch(canProvider(Permission.stockAdjust));
    final profit = ref.watch(canProvider(Permission.shopViewProfit));
    final tiers = ref.watch(priceTiersProvider);
    final today = LedgerDate.fromDateTime(DateTime.now());
    final warn = ref.watch(expiryWarnDaysProvider);
    final products = ref.watch(productListProvider(_filter)).value ?? _last;
    _last = products;
    final summary = ref.watch(stockSummaryProvider).value;
    final categories = ref.watch(productCategoriesProvider).value ?? const [];

    if (!manage) {
      return Scaffold(
        body: MkEmptyState(icon: Icons.lock_outline, title: l10n.prodNoAccess),
      );
    }
    return CallbackShortcuts(
      bindings: {
        ...primaryShortcut(LogicalKeyboardKey.keyF, _focus.requestFocus),
        ...primaryShortcut(LogicalKeyboardKey.keyN, _add),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            key: const ValueKey('prod-add'),
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: Text(l10n.prodAdd),
          ),
          body: Column(
            children: [
              MkTopBar(
                title: l10n.prodTitle,
                actions: [
                  if (adjust)
                    IconButton(
                      key: const ValueKey('prod-import'),
                      tooltip: l10n.prodImpTitle,
                      onPressed: () => context.go(ProductRoutes.import),
                      icon: const Icon(Icons.upload_file_outlined),
                    ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(MkSpacing.lg),
                  children: [
                    _Tiles(
                      summary: summary,
                      profit: profit,
                      selected: _filter.stock,
                      onFilter: _set,
                    ),
                    const SizedBox(height: MkSpacing.lg),
                    _Filters(
                      search: _search,
                      focus: _focus,
                      filter: _filter,
                      categories: categories,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                    const SizedBox(height: MkSpacing.md),
                    _table(l10n, products, tiers, profit, adjust, today, warn),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _table(
    AppLocalizations l10n,
    List<ProductWithStock>? products,
    List<String> tiers,
    bool profit,
    bool adjust,
    LedgerDate today,
    int warn,
  ) {
    if (products == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (products.isEmpty) {
      final searching =
          _filter.query.isNotEmpty ||
          _filter.categoryId != null ||
          _filter.stock != StockFilter.all;
      return MkEmptyState(
        icon: Icons.inventory_2_outlined,
        title: searching ? l10n.prodNoMatch : l10n.prodEmptyTitle,
        message: searching ? null : l10n.prodEmptyBody,
      );
    }
    final cols = <MkColumn<ProductWithStock>>[
      MkColumn(
        label: l10n.prodColProduct,
        flex: 3,
        sortKey: (p) => p.product.name.toLowerCase(),
        cell: (p) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              [p.product.sku, ?p.product.brand].join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      MkColumn(
        label: l10n.prodColBatches,
        flex: 3,
        cell: (p) => _Batches(p: p, today: today, warn: warn),
      ),
      if (profit)
        MkColumn(
          label: l10n.prodColCost,
          numeric: true,
          cell: (p) => Text(p.referenceCost?.format() ?? '—'),
        ),
      MkColumn(
        label: l10n.prodColPrices,
        flex: 3,
        cell: (p) => Text(
          [
            for (final t in tiers)
              if (p.product.prices.prices[t] != null)
                '${tierLabel(t)} ${p.product.prices.prices[t]!.format()}',
          ].join('  '),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      if (profit)
        MkColumn(
          label: l10n.prodColMargin,
          numeric: true,
          cell: (p) {
            final bp = tiers
                .map(p.marginBp)
                .firstWhere((m) => m != null, orElse: () => null);
            return Text(bp == null ? '—' : Margin.format(bp));
          },
        ),
      MkColumn(
        label: l10n.prodColStock,
        numeric: true,
        sortKey: (p) => p.totalMilli,
        cell: (p) => Text(
          '${Qty.format(p.totalMilli)} ${l10n.productUnit(p.product.unit)}',
          style: TextStyle(
            color: p.status == ProductStockStatus.ok
                ? null
                : Theme.of(context).colorScheme.error,
          ),
        ),
      ),
      if (profit)
        MkColumn(
          label: l10n.prodColValue,
          numeric: true,
          sortKey: (p) => p.valueAtCost.paise,
          cell: (p) => Text(p.valueAtCost.format()),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.prodCount(products.length),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: MkSpacing.sm),
        MkDataTable<ProductWithStock>(
          columns: cols,
          rows: products,
          minWidth: 820,
          initialSortColumn: 0,
          onRowTap: (p) => context.go(ProductRoutes.edit(p.product.id)),
        ),
      ],
    );
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({
    required this.summary,
    required this.profit,
    required this.selected,
    required this.onFilter,
  });

  final StockSummary? summary;
  final bool profit;
  final StockFilter selected;
  final ValueChanged<StockFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = summary;
    String n(int? v) => v == null ? '…' : '$v';
    final tiles = [
      if (profit)
        MkStatTile(
          key: const ValueKey('prod-tile-value'),
          label: l10n.prodTileValue,
          value: s == null ? '…' : s.valueAtCost.format(),
        ),
      MkStatTile(
        key: const ValueKey('prod-tile-low'),
        label: l10n.prodTileLow,
        value: n(s?.lowCount),
        onTap: () => onFilter(StockFilter.low),
      ),
      MkStatTile(
        key: const ValueKey('prod-tile-out'),
        label: l10n.prodTileOut,
        value: n(s?.outCount),
        onTap: () => onFilter(StockFilter.out),
      ),
      MkStatTile(
        key: const ValueKey('prod-tile-expiring'),
        label: l10n.prodTileExpiring,
        value: n(s?.expiringCount),
        onTap: () => onFilter(StockFilter.expiring),
      ),
      MkStatTile(
        key: const ValueKey('prod-tile-expired'),
        label: l10n.prodTileExpired,
        value: n(s?.expiredCount),
        onTap: () => onFilter(StockFilter.expired),
      ),
    ];
    return Wrap(
      spacing: MkSpacing.md,
      runSpacing: MkSpacing.md,
      children: [for (final t in tiles) SizedBox(width: 190, child: t)],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.search,
    required this.focus,
    required this.filter,
    required this.categories,
    required this.onChanged,
  });

  final TextEditingController search;
  final FocusNode focus;
  final ProductFilter filter;
  final List<ProductCategory> categories;
  final ValueChanged<ProductFilter> onChanged;

  ProductFilter _with({String? query, Object? category, StockFilter? stock}) =>
      ProductFilter(
        query: query ?? filter.query,
        categoryId: category == null
            ? filter.categoryId
            : (category as String?),
        stock: stock ?? filter.stock,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      StockFilter.all: l10n.prodFilterAll,
      StockFilter.low: l10n.prodFilterLow,
      StockFilter.out: l10n.prodFilterOut,
      StockFilter.expiring: l10n.prodFilterExpiring,
      StockFilter.expired: l10n.prodFilterExpired,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MkTextField(
          key: const ValueKey('prod-search'),
          controller: search,
          focusNode: focus,
          hint: l10n.prodSearchHint,
          prefix: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search, size: 20),
          ),
          onChanged: (v) => onChanged(_with(query: v)),
        ),
        const SizedBox(height: MkSpacing.sm),
        Wrap(
          spacing: MkSpacing.sm,
          runSpacing: MkSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final e in labels.entries)
              ChoiceChip(
                key: ValueKey('prod-filter-${e.key.name}'),
                label: Text(e.value),
                selected: filter.stock == e.key,
                onSelected: (_) => onChanged(_with(stock: e.key)),
              ),
            DropdownButton<String?>(
              key: const ValueKey('prod-category'),
              value: categories.any((c) => c.id == filter.categoryId)
                  ? filter.categoryId
                  : null,
              hint: Text(l10n.prodAllCategories),
              items: [
                DropdownMenuItem(child: Text(l10n.prodAllCategories)),
                for (final c in categories)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => onChanged(
                ProductFilter(
                  query: filter.query,
                  categoryId: v,
                  stock: filter.stock,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Batches extends StatelessWidget {
  const _Batches({required this.p, required this.today, required this.warn});

  final ProductWithStock p;
  final LedgerDate today;
  final int warn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stocked = p.stocked;
    if (stocked.isEmpty) {
      return Text(
        l10n.prodNoBatches,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Wrap(
      spacing: MkSpacing.xs,
      runSpacing: 2,
      children: [
        for (final b in stocked)
          ActionChip(
            visualDensity: VisualDensity.compact,
            label: Text(
              l10n.prodBatchLine(b.batchNo, Qty.format(b.remainingMilli)),
            ),
            avatar: b.isExpired(today)
                ? const Icon(Icons.error_outline, size: 14)
                : b.isExpiring(today, warn)
                ? const Icon(Icons.schedule, size: 14)
                : null,
            onPressed: () =>
                context.go(ProductRoutes.batch(p.product.id, b.id)),
          ),
      ],
    );
  }
}
