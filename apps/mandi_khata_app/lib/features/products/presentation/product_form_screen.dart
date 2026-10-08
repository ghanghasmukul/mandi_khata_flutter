import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/products/domain/product.dart';
import 'package:mandi_khata_app/features/products/domain/stock.dart';
import 'package:mandi_khata_app/features/products/presentation/products_labels.dart';
import 'package:mandi_khata_app/features/products/presentation/products_providers.dart';
import 'package:mandi_khata_app/features/products/presentation/products_routes.dart';
import 'package:mandi_khata_app/features/products/presentation/stock_adjust_dialog.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

/// Add / edit a product. Keyboard-first: Tab through the fields, Ctrl/Cmd+S
/// saves. When editing it also lists the batches (tap one for its stock
/// book) and offers the stock adjustment.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductFormScreen> {
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _barcode = TextEditingController();
  final _brand = TextEditingController();
  final _pack = TextEditingController();
  final _hsn = TextEditingController();
  final _reorder = TextEditingController();
  final _prices = <String, TextEditingController>{};
  ProductUnit _unit = ProductUnit.bag;
  int _gstBp = 500;
  String? _categoryId;
  bool _loaded = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _sku, _barcode, _brand, _pack, _hsn, _reorder]) {
      c.dispose();
    }
    for (final c in _prices.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _priceCtl(String tier) =>
      _prices.putIfAbsent(tier, TextEditingController.new);

  void _fill(Product p) {
    _loaded = true;
    _name.text = p.name;
    _sku.text = p.sku;
    _barcode.text = p.barcode ?? '';
    _brand.text = p.brand ?? '';
    _pack.text = p.packSize ?? '';
    _hsn.text = p.hsn ?? '';
    _reorder.text = p.reorderLevelMilli == 0
        ? ''
        : Qty.format(p.reorderLevelMilli);
    _unit = p.unit;
    _gstBp = p.gstRateBp;
    _categoryId = p.categoryId;
    for (final e in p.prices.prices.entries) {
      _priceCtl(e.key).text = (e.value.paise / 100)
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'\.?0+$'), '');
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final tiers = ref.read(priceTiersProvider);
    final prices = <String, int>{};
    for (final t in tiers) {
      final text = _priceCtl(t).text.trim();
      if (text.isEmpty) continue;
      final m = Money.tryParse(text);
      if (m == null) {
        setState(() => _error = l10n.prodErrPrice);
        return;
      }
      prices[t] = m.paise;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(productsWriterProvider)
        .save(
          ProductInput(
            sku: _sku.text,
            barcode: _barcode.text,
            name: _name.text,
            brand: _brand.text,
            categoryId: _categoryId,
            unit: _unit,
            packSize: _pack.text,
            hsn: _hsn.text,
            gstRateBp: _gstBp,
            reorderLevelMilli: Qty.parse(_reorder.text) ?? 0,
            prices: prices,
          ),
          id: widget.productId,
        );
    if (!mounted) return;
    if (result is ProductSaved) {
      MkToast.show(context, l10n.prodSaved);
      context.go(ProductRoutes.list);
    } else {
      setState(() {
        _busy = false;
        _error = l10n.productFailure(result);
      });
    }
  }

  Future<void> _newCategory() async {
    final l10n = AppLocalizations.of(context);
    final c = TextEditingController();
    final name = await MkDialog.show<String>(
      context,
      title: l10n.prodAddCategory,
      content: MkTextField(controller: c, autofocus: true),
      actions: [
        Builder(
          builder: (ctx) => MkButton(
            label: l10n.prodAdjApply,
            onPressed: () => Navigator.of(ctx).pop(c.text),
          ),
        ),
      ],
    );
    c.dispose();
    if (name == null || name.trim().isEmpty) return;
    final id = await ref.read(productsWriterProvider).addCategory(name);
    if (id != null && mounted) setState(() => _categoryId = id);
  }

  Future<void> _toggleActive(Product p) async {
    await ref.read(productsWriterProvider).setActive(p.id, active: !p.isActive);
  }

  Future<void> _delete(Product p) async {
    final l10n = AppLocalizations.of(context);
    final ok = await MkDialog.show<bool>(
      context,
      title: l10n.prodDelete,
      content: Text(l10n.prodDeleteConfirm),
      actions: [
        Builder(
          builder: (c) => MkButton(
            label: l10n.commonCancel,
            variant: MkButtonVariant.secondary,
            onPressed: () => Navigator.of(c).pop(false),
          ),
        ),
        Builder(
          builder: (c) => MkButton(
            key: const ValueKey('prod-delete-confirm'),
            label: l10n.prodDelete,
            variant: MkButtonVariant.danger,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ),
      ],
    );
    if (ok != true || !mounted) return;
    final result = await ref.read(productsWriterProvider).delete(p.id);
    if (!mounted) return;
    if (result is ProductSaved) {
      context.go(ProductRoutes.list);
    } else {
      setState(() => _error = l10n.productFailure(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editing = widget.productId != null;
    final stock = editing
        ? ref.watch(productWithStockProvider(widget.productId!)).value
        : null;
    if (editing && !_loaded && stock != null) _fill(stock.product);
    if (!editing && !_loaded) {
      final sku = ref.watch(suggestedSkuProvider).value;
      if (sku != null) {
        _loaded = true;
        _sku.text = sku;
      }
    }
    final manage = ref.watch(canProvider(Permission.productsManage));
    final adjust = ref.watch(canProvider(Permission.stockAdjust));
    final profit = ref.watch(canProvider(Permission.shopViewProfit));
    final canDelete = ref.watch(canProvider(Permission.masterDelete));
    final tiers = ref.watch(priceTiersProvider);
    final categories = ref.watch(productCategoriesProvider).value ?? const [];
    if (!manage) {
      return Scaffold(
        body: MkEmptyState(icon: Icons.lock_outline, title: l10n.prodNoAccess),
      );
    }
    final gst = [
      for (final bp in GstRates.valid) bp,
      if (!GstRates.isValid(_gstBp)) _gstBp,
    ];

    return CallbackShortcuts(
      bindings: primaryShortcut(LogicalKeyboardKey.keyS, _save),
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(
                title: editing ? l10n.prodFormEdit : l10n.prodFormNew,
                actions: [
                  IconButton(
                    tooltip: l10n.commonCancel,
                    onPressed: () => context.go(ProductRoutes.list),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(MkSpacing.lg),
                  children: [
                    MkCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MkTextField(
                            key: const ValueKey('pf-name'),
                            controller: _name,
                            label: l10n.prodFieldName,
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: MkSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MkTextField(
                                  key: const ValueKey('pf-sku'),
                                  controller: _sku,
                                  label: l10n.prodFieldSku,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: MkSpacing.md),
                              Expanded(
                                child: MkTextField(
                                  key: const ValueKey('pf-barcode'),
                                  controller: _barcode,
                                  label: l10n.prodFieldBarcode,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: MkSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MkTextField(
                                  controller: _brand,
                                  label: l10n.prodFieldBrand,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: MkSpacing.md),
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  key: const ValueKey('pf-category'),
                                  initialValue:
                                      categories.any((c) => c.id == _categoryId)
                                      ? _categoryId
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: l10n.prodFieldCategory,
                                    suffixIcon: IconButton(
                                      tooltip: l10n.prodAddCategory,
                                      onPressed: _newCategory,
                                      icon: const Icon(Icons.add),
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      child: Text(l10n.prodNoCategory),
                                    ),
                                    for (final c in categories)
                                      DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _categoryId = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: MkSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<ProductUnit>(
                                  key: const ValueKey('pf-unit'),
                                  initialValue: _unit,
                                  decoration: InputDecoration(
                                    labelText: l10n.prodFieldUnit,
                                  ),
                                  items: [
                                    for (final u in ProductUnit.values)
                                      DropdownMenuItem(
                                        value: u,
                                        child: Text(l10n.productUnit(u)),
                                      ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _unit = v ?? _unit),
                                ),
                              ),
                              const SizedBox(width: MkSpacing.md),
                              Expanded(
                                child: MkTextField(
                                  controller: _pack,
                                  label: l10n.prodFieldPackSize,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: MkSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: MkTextField(
                                  key: const ValueKey('pf-hsn'),
                                  controller: _hsn,
                                  label: l10n.prodFieldHsn,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: MkSpacing.md),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  key: const ValueKey('pf-gst'),
                                  initialValue: _gstBp,
                                  decoration: InputDecoration(
                                    labelText: l10n.prodFieldGst,
                                  ),
                                  items: [
                                    for (final bp in gst)
                                      DropdownMenuItem(
                                        value: bp,
                                        child: Text(GstRates.format(bp)),
                                      ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _gstBp = v ?? _gstBp),
                                ),
                              ),
                              const SizedBox(width: MkSpacing.md),
                              Expanded(
                                child: MkTextField(
                                  key: const ValueKey('pf-reorder'),
                                  controller: _reorder,
                                  label: l10n.prodFieldReorder,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: MkSpacing.lg),
                    MkCard(
                      title: l10n.prodFieldPrices,
                      child: Wrap(
                        spacing: MkSpacing.md,
                        runSpacing: MkSpacing.md,
                        children: [
                          for (final t in tiers)
                            SizedBox(
                              width: 160,
                              child: MkTextField(
                                key: ValueKey('pf-price-$t'),
                                controller: _priceCtl(t),
                                label: tierLabel(t),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: MkSpacing.md),
                        child: Text(
                          _error!,
                          key: const ValueKey('pf-error'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: MkSpacing.lg),
                    Wrap(
                      spacing: MkSpacing.sm,
                      runSpacing: MkSpacing.sm,
                      children: [
                        MkButton(
                          key: const ValueKey('pf-save'),
                          label: l10n.prodSave,
                          icon: Icons.check,
                          busy: _busy,
                          onPressed: _save,
                        ),
                        if (stock != null) ...[
                          if (adjust)
                            MkButton(
                              key: const ValueKey('pf-adjust'),
                              label: l10n.prodAdjTitle,
                              variant: MkButtonVariant.secondary,
                              icon: Icons.tune,
                              onPressed: () =>
                                  showStockAdjustDialog(context, stock),
                            ),
                          MkButton(
                            label: stock.product.isActive
                                ? l10n.prodDeactivate
                                : l10n.prodActivate,
                            variant: MkButtonVariant.secondary,
                            onPressed: () => _toggleActive(stock.product),
                          ),
                          if (canDelete)
                            MkButton(
                              key: const ValueKey('pf-delete'),
                              label: l10n.prodDelete,
                              variant: MkButtonVariant.danger,
                              onPressed: () => _delete(stock.product),
                            ),
                        ],
                      ],
                    ),
                    if (stock != null) ...[
                      const SizedBox(height: MkSpacing.lg),
                      _BatchList(stock: stock, profit: profit),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchList extends StatelessWidget {
  const _BatchList({required this.stock, required this.profit});

  final ProductWithStock stock;
  final bool profit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = LedgerDate.fromDateTime(DateTime.now());
    return MkCard(
      title: l10n.prodColBatches,
      child: Column(
        children: [
          for (final b in stock.batches)
            ListTile(
              key: ValueKey('batch-${b.batchNo}'),
              contentPadding: EdgeInsets.zero,
              title: Text(b.batchNo),
              subtitle: Text(
                [
                  if (b.expiry != null)
                    '${l10n.prodBatchExpiry}: ${_date(context, b.expiry!)}',
                  if (b.isExpired(today)) l10n.prodBatchExpiredTag,
                  if (profit) b.cost.format(),
                ].join(' · '),
              ),
              trailing: Text(
                '${Qty.format(b.remainingMilli)} '
                '${l10n.productUnit(stock.product.unit)}',
              ),
              onTap: () =>
                  context.go(ProductRoutes.batch(stock.product.id, b.id)),
            ),
        ],
      ),
    );
  }
}

String _date(BuildContext context, LedgerDate d) =>
    AppFormat.ledgerDate(context, d);
