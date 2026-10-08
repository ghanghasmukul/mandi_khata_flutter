import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_picker.dart';
import 'package:mandi_khata_app/features/pos/domain/pos_cart.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_cart_panel.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_held_dialog.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_labels.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_payment_dialog.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_product_grid.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_providers.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_saved_dialog.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_scan.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_settings.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sales_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class PosRoutes {
  static const pos = '/shop/pos';
}

/// Counter sale, keyboard first. F2 new bill, F3 search, F4 customer,
/// F10 pay, + / - quantity of the selected line, Del removes it, Esc clears
/// the search. A barcode scanner types like a keyboard: scan = type + Enter.
/// "5*urea" + Enter adds 5 units.
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode(debugLabel: 'pos-search');
  final _partyFocus = FocusNode(debugLabel: 'pos-party');
  int _highlight = 0;
  int _selected = -1;
  bool _saving = false;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    _partyFocus.dispose();
    super.dispose();
  }

  PosCartController get _cart => ref.read(posCartControllerProvider.notifier);

  List<PosProduct> _matches(List<PosProduct> all) {
    final q = SearchIntent.parse(_search.text).query;
    return [
      for (final p in all)
        if (p.matches(q)) p,
    ];
  }

  void _focusSearch() {
    _searchFocus.requestFocus();
    _search.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _search.text.length,
    );
  }

  void _newBill() {
    _cart.clear();
    setState(() {
      _selected = -1;
      _highlight = 0;
      _search.clear();
    });
    _focusSearch();
  }

  /// Adds [p] ([qtyMilli] units) unless it cannot be sold at all.
  void _add(PosProduct p, {int qtyMilli = Qty.unit}) {
    final settings = ref.read(shopSettingsProvider) ?? const ShopSettings();
    final left = p.sellableMilli(blockExpired: settings.policy.blockExpired);
    final l10n = AppLocalizations.of(context);
    if (left <= 0 && !settings.policy.allowNegative) {
      MkToast.show(context, l10n.posOutOfStock, tone: MkToastTone.error);
      return;
    }
    _cart.add(p, qtyMilli: qtyMilli);
    setState(() {
      _selected = ref
          .read(posCartControllerProvider)
          .lines
          .indexWhere((l) => l.product.id == p.id);
      _search.clear();
      _highlight = 0;
    });
    _focusSearch();
  }

  /// Enter in the search box: an exact barcode / SKU wins, else the
  /// highlighted match.
  void _submit(List<PosProduct> all) {
    final intent = SearchIntent.parse(_search.text);
    if (intent.query.isEmpty) return;
    final q = intent.query.toLowerCase();
    final exact = all.where(
      (p) => p.barcode?.toLowerCase() == q || p.sku.toLowerCase() == q,
    );
    final list = _matches(all);
    final p = exact.isNotEmpty
        ? exact.first
        : list.isEmpty
        ? null
        : list[_highlight.clamp(0, list.length - 1)];
    if (p == null) {
      MkToast.show(
        context,
        AppLocalizations.of(context).posNoProducts,
        tone: MkToastTone.error,
      );
      return;
    }
    _add(p, qtyMilli: intent.qtyMilli);
  }

  /// A camera scan takes the exact same path as typing the code + Enter.
  void _onScanned(String code, List<PosProduct> all) {
    _search.text = code;
    _submit(all);
  }

  bool get _typingElsewhere {
    final f = FocusManager.instance.primaryFocus;
    if (f == null || f == _searchFocus) return false;
    return f.context?.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is KeyUpEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.f2) {
      _newBill();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.f3) {
      _focusSearch();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.f4) {
      _partyFocus.requestFocus();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.f10) {
      unawaited(_pay());
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.escape) {
      if (_search.text.isNotEmpty) {
        setState(() {
          _search.clear();
          _highlight = 0;
        });
      } else {
        _focusSearch();
      }
      return KeyEventResult.handled;
    }
    final searching = _search.text.isNotEmpty;
    if (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.arrowUp) {
      final d = k == LogicalKeyboardKey.arrowDown ? 1 : -1;
      if (searching) {
        setState(() => _highlight = (_highlight + d).clamp(0, 9999));
      } else if (!_typingElsewhere) {
        final n = ref.read(posCartControllerProvider).lines.length;
        if (n > 0) setState(() => _selected = (_selected + d).clamp(0, n - 1));
      } else {
        return KeyEventResult.ignored;
      }
      return KeyEventResult.handled;
    }
    // Quantity and delete keys must not steal typing.
    if (searching || _typingElsewhere) return KeyEventResult.ignored;
    final plus =
        k == LogicalKeyboardKey.add ||
        k == LogicalKeyboardKey.numpadAdd ||
        k == LogicalKeyboardKey.equal;
    final minus =
        k == LogicalKeyboardKey.minus || k == LogicalKeyboardKey.numpadSubtract;
    if (plus || minus) {
      if (_selected >= 0) _cart.bump(_selected, plus ? Qty.unit : -Qty.unit);
      _clampSelected();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.delete || k == LogicalKeyboardKey.backspace) {
      if (_selected >= 0) _cart.remove(_selected);
      _clampSelected();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _clampSelected() {
    final n = ref.read(posCartControllerProvider).lines.length;
    setState(() => _selected = n == 0 ? -1 : _selected.clamp(0, n - 1));
  }

  Future<void> _pay() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final settings = ref.read(shopSettingsProvider);
    final cart = ref.read(posCartControllerProvider);
    final totals = settings == null ? null : cart.totals(settings);
    if (settings == null || totals == null || cart.isEmpty) {
      MkToast.show(context, l10n.posErrorNoLines, tone: MkToastTone.error);
      return;
    }
    final pay = await showPosPaymentDialog(
      context,
      total: totals.total,
      partyId: cart.partyId,
      partyName: cart.partyName,
    );
    if (pay == null || !mounted) {
      _focusSearch();
      return;
    }
    setState(() => _saving = true);
    final names = {for (final l in cart.lines) l.product.id: l.product.name};
    final result = await ref
        .read(saleWriterProvider)
        .create(
          cart.toDraft(
            settings: settings,
            payment: pay.split,
            upiAccountId: pay.upiAccountId,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    final error = l10n.saleSaveError(result, names);
    if (error != null || result is! SaleSaved) {
      MkToast.show(context, error ?? '', tone: MkToastTone.error);
      return;
    }
    _cart.clear();
    setState(() => _selected = -1);
    await showPosSavedDialog(context, result, total: totals.total);
    if (mounted) _focusSearch();
  }

  Future<void> _hold() async {
    final l10n = AppLocalizations.of(context);
    if (await _cart.hold() && mounted) {
      MkToast.show(context, l10n.posHeldSaved, tone: MkToastTone.success);
      setState(() => _selected = -1);
      _focusSearch();
    }
  }

  Future<void> _edit(int i) async {
    final cart = ref.read(posCartControllerProvider);
    if (i < 0 || i >= cart.lines.length) return;
    await showLineEditDialog(context, ref, i, cart.lines[i]);
    if (mounted) _focusSearch();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!ref.watch(canProvider(Permission.salesCreate))) {
      return Scaffold(
        body: Column(
          children: [
            MkTopBar(title: l10n.posTitle),
            Expanded(
              child: MkEmptyState(
                icon: Icons.lock_outline,
                title: l10n.posErrorNotPermitted,
              ),
            ),
          ],
        ),
      );
    }
    final settings = ref.watch(shopSettingsProvider) ?? const ShopSettings();
    final cart = ref.watch(posCartControllerProvider);
    final all = ref.watch(posCatalogProvider).value ?? const <PosProduct>[];
    final matches = _matches(all);
    if (_highlight >= matches.length) _highlight = 0;
    final totals = cart.totals(settings);
    final tier = cart.effectiveTier(settings);
    final held = ref.watch(heldBillsProvider).value?.length ?? 0;

    final searchField = MkTextField(
      key: const ValueKey('pos-search'),
      controller: _search,
      focusNode: _searchFocus,
      autofocus: true,
      hint: l10n.posSearchHint,
      prefix: const Icon(Icons.search),
      suffix: PosScanButton(
        onCode: (code) => _onScanned(
          code,
          ref.read(posCatalogProvider).value ?? const <PosProduct>[],
        ),
      ),
      textInputAction: TextInputAction.done,
      onChanged: (_) => setState(() => _highlight = 0),
      onSubmitted: (_) => _submit(all),
    );

    final tierChips = Wrap(
      spacing: MkSpacing.sm,
      runSpacing: MkSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l10n.posTierLabel),
        for (final t in settings.tiers.tiers)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: ChoiceChip(
              key: ValueKey('pos-tier-$t'),
              label: Text(l10n.tierName(t)),
              selected: t == tier,
              onSelected: (_) => _cart.setTier(t),
            ),
          ),
      ],
    );

    final cartPane = _CartPane(
      cart: cart,
      totals: totals,
      selected: _selected,
      held: held,
      saving: _saving,
      blockExpired: settings.policy.blockExpired,
      partyFocus: _partyFocus,
      onSelect: (i) => setState(() => _selected = i),
      onBump: (i, d) {
        _cart.bump(i, d);
        _clampSelected();
      },
      onRemove: (i) {
        _cart.remove(i);
        _clampSelected();
      },
      onEdit: _edit,
      onPay: _pay,
      onHold: _hold,
      onRecall: () => showHeldBillsDialog(context),
      onNew: _newBill,
      onPartyChosen: _focusSearch,
    );

    final productsPane = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(MkSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: MkSpacing.xs),
              tierChips,
            ],
          ),
        ),
        Expanded(
          child: PosProductGrid(
            products: matches,
            settings: settings.tiers,
            tier: tier,
            highlight: _search.text.isEmpty ? -1 : _highlight,
            blockExpired: settings.policy.blockExpired,
            onAdd: _add,
          ),
        ),
      ],
    );

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        body: Column(
          children: [
            MkTopBar(title: l10n.posTitle),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  if (c.maxWidth >= 860) {
                    return Row(
                      children: [
                        Expanded(flex: 3, child: productsPane),
                        const VerticalDivider(width: 1),
                        Expanded(flex: 2, child: cartPane),
                      ],
                    );
                  }
                  // Phone: search on top; the results replace the cart while
                  // typing.
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(MkSpacing.sm),
                        child: searchField,
                      ),
                      Expanded(
                        child: _search.text.isNotEmpty
                            ? PosProductGrid(
                                products: matches,
                                settings: settings.tiers,
                                tier: tier,
                                highlight: _highlight,
                                blockExpired: settings.policy.blockExpired,
                                onAdd: _add,
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: MkSpacing.sm,
                                    ),
                                    child: tierChips,
                                  ),
                                  Expanded(child: cartPane),
                                ],
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartPane extends ConsumerWidget {
  const _CartPane({
    required this.cart,
    required this.totals,
    required this.selected,
    required this.held,
    required this.saving,
    required this.blockExpired,
    required this.partyFocus,
    required this.onSelect,
    required this.onBump,
    required this.onRemove,
    required this.onEdit,
    required this.onPay,
    required this.onHold,
    required this.onRecall,
    required this.onNew,
    required this.onPartyChosen,
  });

  final PosCart cart;
  final SaleTotals? totals;
  final int selected;
  final int held;
  final bool saving;
  final bool blockExpired;
  final FocusNode partyFocus;
  final ValueChanged<int> onSelect;
  final void Function(int, int) onBump;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onEdit;
  final VoidCallback onPay;
  final VoidCallback onHold;
  final VoidCallback onRecall;
  final VoidCallback onNew;
  final VoidCallback onPartyChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(posCartControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(MkSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PartyPicker(
                key: const ValueKey('pos-party'),
                role: null,
                focusNode: partyFocus,
                minChars: 2,
                label: l10n.posCustomer,
                selected: cart.partyId == null ? null : _PartyFromCart.of(cart),
                onSelected: (p) {
                  controller.setParty(p);
                  onPartyChosen();
                },
              ),
              Wrap(
                children: [
                  TextButton.icon(
                    onPressed: onNew,
                    icon: const Icon(Icons.add),
                    label: Text('${l10n.posNewBill} (F2)'),
                  ),
                  TextButton.icon(
                    key: const ValueKey('pos-recall'),
                    onPressed: onRecall,
                    icon: const Icon(Icons.pause_circle_outline),
                    label: Text(
                      held > 0 ? '${l10n.posRecall} ($held)' : l10n.posRecall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: PosCartLines(
            cart: cart,
            selected: selected,
            totals: totals,
            blockExpired: blockExpired,
            onSelect: onSelect,
            onBump: onBump,
            onRemove: onRemove,
            onEdit: onEdit,
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(MkSpacing.sm),
          child: Column(
            children: [
              _DiscountField(cart: cart),
              PosTotalsBlock(totals: totals),
              const SizedBox(height: MkSpacing.sm),
              Row(
                children: [
                  MkButton(
                    key: const ValueKey('pos-hold'),
                    label: l10n.posHold,
                    variant: MkButtonVariant.secondary,
                    onPressed: cart.isEmpty ? null : onHold,
                  ),
                  const SizedBox(width: MkSpacing.sm),
                  Expanded(
                    child: MkButton(
                      key: const ValueKey('pos-pay'),
                      label: '${l10n.posPay} (F10)',
                      expand: true,
                      busy: saving,
                      onPressed: cart.isEmpty ? null : onPay,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MkSpacing.xs),
              Text(
                l10n.posShortcuts,
                style: TextStyle(
                  fontSize: 11,
                  color: MkTokens.of(context).textFaint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The customer chosen for the bill, as the picker wants to show it.
abstract final class _PartyFromCart {
  static Party of(PosCart c) => Party(
    id: c.partyId!,
    code: '',
    name: c.partyName ?? '',
    roles: c.partyRoles,
    gstin: c.partyGstin,
    state: c.partyState,
  );
}

/// Bill discount in percent (2 or 2.5).
class _DiscountField extends ConsumerWidget {
  const _DiscountField({required this.cart});

  final PosCart cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: Text(l10n.posInvoiceDiscount)),
        SizedBox(
          width: 90,
          child: MkTextField(
            key: const ValueKey('pos-discount'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: cart.discountPercentBp == null
                ? ''
                : Qty.format(cart.discountPercentBp! * 10),
            onChanged: (t) {
              final milli = Qty.parse(t);
              ref
                  .read(posCartControllerProvider.notifier)
                  .setDiscountPercent(milli == null ? null : milli ~/ 10);
            },
          ),
        ),
      ],
    );
  }
}
