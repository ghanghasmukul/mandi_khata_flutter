import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/purchases/domain/purchase.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchases_labels.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchases_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

class _Line {
  PurchaseProduct? product;
  final batchNo = TextEditingController();
  final mfg = TextEditingController();
  final expiry = TextEditingController();
  final qty = TextEditingController();
  int cost = 0;
  int? rateBp;

  void dispose() {
    batchNo.dispose();
    mfg.dispose();
    expiry.dispose();
    qty.dispose();
  }

  static LedgerDate? date(String text) {
    try {
      return text.trim().isEmpty ? null : LedgerDate.parse(text.trim());
    } on FormatException {
      return null;
    }
  }

  int get qtyMilli => Qty.parse(qty.text) ?? 0;

  PurchaseLineDraft? toDraft() {
    final p = product;
    if (p == null) return null;
    return PurchaseLineDraft(
      productId: p.id,
      batchNo: batchNo.text,
      qtyMilli: qtyMilli,
      unitCost: Money(cost),
      rateBp: rateBp ?? p.gstRateBp,
      hsn: p.hsn,
      mfgDate: date(mfg.text),
      expiry: date(expiry.text),
    );
  }
}

/// Keyboard-first purchase entry. `F2` adds a line, `Ctrl/Cmd+Enter` saves.
class PurchaseEntryScreen extends ConsumerStatefulWidget {
  const PurchaseEntryScreen({super.key});

  @override
  ConsumerState<PurchaseEntryScreen> createState() => _EntryState();
}

class _EntryState extends ConsumerState<PurchaseEntryScreen> {
  SupplierOption? _supplier;
  final _invoiceNo = TextEditingController();
  LedgerDate _invoiceDate = LedgerDate.fromDateTime(DateTime.now());
  final _lines = <_Line>[_Line()];
  int _freight = 0;
  int _other = 0;
  int _paid = 0;
  final _roundOff = TextEditingController();
  bool _cash = true;
  String? _bankId;
  int? _creditDays;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _invoiceNo.dispose();
    _roundOff.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  Money get _round {
    final m = Money.tryParse(_roundOff.text.replaceFirst('-', ''));
    if (m == null) return Money.zero;
    return _roundOff.text.trim().startsWith('-') ? -m : m;
  }

  PurchaseTotals? get _totals {
    final lines = [
      for (final l in _lines)
        if (l.toDraft() case final d? when d.qtyMilli > 0)
          PurchaseLine(
            productId: d.productId,
            batchNo: d.batchNo,
            qtyMilli: d.qtyMilli,
            unitCost: d.unitCost,
            rateBp: d.rateBp,
          ),
    ];
    if (lines.isEmpty) return null;
    return PurchaseRules.compute(
      lines: lines,
      freight: Money(_freight),
      otherCharges: Money(_other),
      roundOff: _round,
    );
  }

  void _addLine() => setState(() => _lines.add(_Line()));

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final drafts = [for (final l in _lines) ?l.toDraft()];
    setState(() {
      _saving = true;
      _error = null;
    });
    final r = await ref
        .read(purchaseWriterProvider)
        .create(
          PurchaseDraft(
            supplierId: _supplier?.id ?? '',
            invoiceDate: _invoiceDate,
            supplierInvoiceNo: _invoiceNo.text,
            lines: drafts,
            freight: Money(_freight),
            otherCharges: Money(_other),
            roundOff: _round,
            paid: Money(_paid),
            paidInCash: _cash,
            bankAccountId: _cash ? null : _bankId,
            creditDays: _creditDays,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    final error = l10n.purchaseResult(r);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.purchaseSaved((r as PurchaseSaved).number))),
    );
    context.go(PurchaseRoutes.detail(r.id));
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: DateTime(
        _invoiceDate.year,
        _invoiceDate.month,
        _invoiceDate.day,
      ),
    );
    if (d != null) setState(() => _invoiceDate = LedgerDate.fromDateTime(d));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canCreate = ref.watch(canProvider(Permission.purchasesCreate));
    final canBank = ref.watch(canProvider(Permission.financeView));
    final banks = <BankAccount>[
      for (final a
          in ref.watch(bankAccountListProvider()).value ??
              const <BankAccount>[])
        if (a.kind == AccountKind.bank && a.isActive) a,
    ];
    final defaultDays = ref.watch(supplierCreditDaysProvider);
    final days = _creditDays ?? defaultDays;
    final totals = _totals;
    final total = totals?.total ?? Money.zero;
    final unpaid = total - Money(_paid);
    final due = AppFormat.ledgerDate(
      context,
      PurchaseRules.dueDate(_invoiceDate, days),
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): _addLine,
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _save,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _save,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(PurchaseRoutes.list),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(title: l10n.purchaseNew),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(MkSpacing.md),
                  children: [
                    Wrap(
                      spacing: MkSpacing.sm,
                      runSpacing: MkSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: _SupplierPicker(
                            selected: _supplier,
                            onPicked: (s) => setState(() => _supplier = s),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: MkTextField(
                            key: const ValueKey('purchase-invoice-no'),
                            label: l10n.purchaseSupplierInvoiceNo,
                            controller: _invoiceNo,
                          ),
                        ),
                        TextButton.icon(
                          key: const ValueKey('purchase-invoice-date'),
                          onPressed: _pickDate,
                          icon: const Icon(Icons.event, size: 18),
                          label: Text(
                            '${l10n.purchaseInvoiceDate}: '
                            '${AppFormat.ledgerDate(context, _invoiceDate)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: MkSpacing.md),
                    for (var i = 0; i < _lines.length; i++)
                      _LineCard(
                        key: ObjectKey(_lines[i]),
                        line: _lines[i],
                        index: i,
                        onChanged: () => setState(() {}),
                        onRemove: _lines.length == 1
                            ? null
                            : () =>
                                  setState(() => _lines.removeAt(i).dispose()),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        key: const ValueKey('purchase-add-line'),
                        onPressed: _addLine,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.purchaseAddLine),
                      ),
                    ),
                    const Divider(),
                    Wrap(
                      spacing: MkSpacing.sm,
                      runSpacing: MkSpacing.sm,
                      children: [
                        _money(
                          'purchase-freight',
                          l10n.purchaseFreight,
                          (v) => _freight = v,
                        ),
                        _money(
                          'purchase-other',
                          l10n.purchaseOtherCharges,
                          (v) => _other = v,
                        ),
                        SizedBox(
                          width: 150,
                          child: MkTextField(
                            key: const ValueKey('purchase-roundoff'),
                            label: l10n.purchaseRoundOff,
                            controller: _roundOff,
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: true,
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: MkSpacing.md),
                    if (totals != null) ...[
                      _total(l10n.purchaseTaxable, totals.gst.taxable),
                      _total(l10n.purchaseGst, totals.gst.tax),
                    ],
                    _total(l10n.purchaseTotal, total, bold: true),
                    const SizedBox(height: MkSpacing.md),
                    Wrap(
                      spacing: MkSpacing.sm,
                      runSpacing: MkSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _money(
                          'purchase-paid',
                          l10n.purchasePaidNow,
                          (v) => _paid = v,
                        ),
                        if (canBank)
                          SegmentedButton<bool>(
                            key: const ValueKey('purchase-mode'),
                            showSelectedIcon: false,
                            segments: [
                              ButtonSegment(
                                value: true,
                                label: Text(l10n.purchaseCash),
                              ),
                              ButtonSegment(
                                value: false,
                                label: Text(l10n.purchaseBank),
                              ),
                            ],
                            selected: {_cash},
                            onSelectionChanged: (s) =>
                                setState(() => _cash = s.first),
                          ),
                        if (!_cash)
                          SizedBox(
                            width: 220,
                            child: DropdownButtonFormField<String>(
                              key: const ValueKey('purchase-bank'),
                              initialValue: _bankId,
                              decoration: InputDecoration(
                                labelText: l10n.purchaseBankAccount,
                              ),
                              items: [
                                for (final b in banks)
                                  DropdownMenuItem(
                                    value: b.id,
                                    child: Text(b.name),
                                  ),
                              ],
                              onChanged: (v) => setState(() => _bankId = v),
                            ),
                          ),
                        SizedBox(
                          width: 130,
                          child: MkNumberField(
                            key: const ValueKey('purchase-credit-days'),
                            kind: MkNumberKind.integer,
                            label: l10n.purchaseCreditDays,
                            initialValue: defaultDays,
                            onChanged: (v) => setState(() => _creditDays = v),
                          ),
                        ),
                        if (unpaid.isPositive)
                          Text('${l10n.purchaseDueDate}: $due'),
                      ],
                    ),
                    if (unpaid.isPositive) _total(l10n.purchaseUnpaid, unpaid),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: MkSpacing.sm),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(MkSpacing.sm),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    key: const ValueKey('purchase-save'),
                    onPressed: canCreate && !_saving ? _save : null,
                    child: Text(l10n.purchaseSave),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _money(String key, String label, void Function(int) set) => SizedBox(
    width: 160,
    child: MkNumberField(
      key: ValueKey(key),
      label: label,
      onChanged: (p) => setState(() => set(p ?? 0)),
    ),
  );

  Widget _total(String k, Money v, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k),
        Text(
          v.format(),
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      ],
    ),
  );
}

class _SupplierPicker extends ConsumerWidget {
  const _SupplierPicker({required this.selected, required this.onPicked});

  final SupplierOption? selected;
  final ValueChanged<SupplierOption> onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Autocomplete<SupplierOption>(
      key: const ValueKey('purchase-supplier'),
      displayStringForOption: (s) => '${s.name} (${s.code})',
      optionsBuilder: (text) async {
        final tenantId = ref.read(activeTenantProvider);
        if (tenantId == null) return const [];
        final repo = await ref.read(purchaseRepositoryProvider.future);
        return await repo.watchSuppliers(tenantId, query: text.text).first;
      },
      onSelected: onPicked,
      fieldViewBuilder: (context, controller, focus, submit) => TextField(
        controller: controller,
        focusNode: focus,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.purchaseSupplier),
      ),
    );
  }
}

class _LineCard extends ConsumerWidget {
  const _LineCard({
    required this.line,
    required this.index,
    required this.onChanged,
    required this.onRemove,
    super.key,
  });

  final _Line line;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MkSpacing.sm),
        child: Wrap(
          spacing: MkSpacing.sm,
          runSpacing: MkSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: Autocomplete<PurchaseProduct>(
                key: ValueKey('purchase-product-$index'),
                displayStringForOption: (p) => p.name,
                optionsBuilder: (text) async {
                  final tenantId = ref.read(activeTenantProvider);
                  if (tenantId == null) return const [];
                  final repo = await ref.read(
                    purchaseRepositoryProvider.future,
                  );
                  return await repo.searchProducts(tenantId, text.text);
                },
                onSelected: (p) async {
                  line.product = p;
                  line.rateBp = p.gstRateBp;
                  final hints = await ref.read(
                    purchaseBatchHintsProvider(p.id).future,
                  );
                  if (hints.isNotEmpty && line.batchNo.text.isEmpty) {
                    final h = hints.first;
                    line.batchNo.text = h.batchNo;
                    line.mfg.text = h.mfgDate?.toString() ?? '';
                    line.expiry.text = h.expiry?.toString() ?? '';
                    line.cost = h.cost.paise;
                  }
                  onChanged();
                },
                fieldViewBuilder: (context, controller, focus, submit) =>
                    TextField(
                      controller: controller,
                      focusNode: focus,
                      decoration: InputDecoration(
                        labelText: l10n.purchaseProduct,
                      ),
                    ),
              ),
            ),
            SizedBox(
              width: 110,
              child: MkTextField(
                key: ValueKey('purchase-batch-$index'),
                label: l10n.purchaseBatchNo,
                controller: line.batchNo,
                onChanged: (_) => onChanged(),
              ),
            ),
            SizedBox(
              width: 130,
              child: MkTextField(
                label: l10n.purchaseMfg,
                hint: 'YYYY-MM-DD',
                controller: line.mfg,
              ),
            ),
            SizedBox(
              width: 130,
              child: MkTextField(
                label: l10n.purchaseExpiry,
                hint: 'YYYY-MM-DD',
                controller: line.expiry,
              ),
            ),
            SizedBox(
              width: 90,
              child: MkTextField(
                key: ValueKey('purchase-qty-$index'),
                label: l10n.purchaseQty,
                controller: line.qty,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
            SizedBox(
              width: 130,
              child: MkNumberField(
                key: ValueKey('purchase-cost-$index-${line.cost}'),
                label: l10n.purchaseCost,
                initialValue: line.cost == 0 ? null : line.cost,
                onChanged: (v) {
                  line.cost = v ?? 0;
                  onChanged();
                },
              ),
            ),
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<int>(
                key: ValueKey('purchase-gst-$index-${line.rateBp}'),
                initialValue: GstRates.valid.contains(line.rateBp)
                    ? line.rateBp
                    : null,
                decoration: InputDecoration(labelText: l10n.purchaseGstRate),
                items: [
                  for (final r in GstRates.valid)
                    DropdownMenuItem(value: r, child: Text(GstRates.format(r))),
                ],
                onChanged: (v) {
                  line.rateBp = v;
                  onChanged();
                },
              ),
            ),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      ),
    );
  }
}
