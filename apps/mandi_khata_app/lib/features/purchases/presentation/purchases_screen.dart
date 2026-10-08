import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/purchases/domain/purchase.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchases_labels.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchases_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mk_ui/mk_ui.dart';

/// Purchase list: filters (date, status, supplier), totals, `Ctrl+N` adds.
class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  LedgerDate? _from = LedgerDate.fromDateTime(DateTime.now()).addDays(-29);
  LedgerDate? _to = LedgerDate.fromDateTime(DateTime.now());
  PurchaseStatusFilter _status = PurchaseStatusFilter.all;
  String? _supplierId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = ref.watch(canProvider(Permission.purchasesCreate));
    final filter = PurchaseFilter(
      supplierId: _supplierId,
      from: _from,
      to: _to,
      status: _status,
    );
    final rows =
        ref.watch(purchaseListProvider(filter)).value ??
        const <PurchaseSummary>[];
    final suppliers =
        ref.watch(supplierOptionsProvider('')).value ??
        const <SupplierOption>[];
    final live = rows.where((p) => !p.isReversed);
    final total = live.fold(Money.zero, (s, p) => s + p.total);
    final owed = live.fold(Money.zero, (s, p) => s + p.outstanding);
    void add() => context.go(PurchaseRoutes.create);
    return CallbackShortcuts(
      bindings: {
        if (canAdd) ...{
          const SingleActivator(LogicalKeyboardKey.keyN, control: true): add,
          const SingleActivator(LogicalKeyboardKey.keyN, meta: true): add,
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          floatingActionButton: canAdd
              ? FloatingActionButton.extended(
                  key: const ValueKey('purchase-add'),
                  onPressed: add,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.purchaseNew),
                )
              : null,
          body: Column(
            children: [
              MkTopBar(
                title: l10n.purchasesTitle,
                subtitle:
                    '${l10n.purchaseTotal}: ${total.format()} · '
                    '${l10n.purchaseUnpaid}: ${owed.format()}',
              ),
              Padding(
                padding: const EdgeInsets.all(MkSpacing.sm),
                child: Wrap(
                  spacing: MkSpacing.sm,
                  runSpacing: MkSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DateRangeChips(
                      keyPrefix: 'purchases',
                      from: _from,
                      to: _to,
                      onChanged: (f, t) => setState(() {
                        _from = f;
                        _to = t;
                      }),
                    ),
                    SegmentedButton<PurchaseStatusFilter>(
                      key: const ValueKey('purchase-status'),
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: PurchaseStatusFilter.all,
                          label: Text(l10n.purchaseStatusAll),
                        ),
                        ButtonSegment(
                          value: PurchaseStatusFilter.unpaid,
                          label: Text(l10n.purchaseStatusUnpaid),
                        ),
                        ButtonSegment(
                          value: PurchaseStatusFilter.reversed,
                          label: Text(l10n.purchaseStatusReversed),
                        ),
                      ],
                      selected: {_status},
                      onSelectionChanged: (s) =>
                          setState(() => _status = s.first),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<String?>(
                        key: const ValueKey('purchase-supplier-filter'),
                        initialValue: _supplierId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.purchaseSupplier,
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            child: Text(l10n.purchaseStatusAll),
                          ),
                          for (final s in suppliers)
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                        ],
                        onChanged: (v) => setState(() => _supplierId = v),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? MkEmptyState(title: l10n.purchasesEmpty)
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: rows.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) => _Row(rows[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.p);

  final PurchaseSummary p;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final due = p.dueDate;
    return ListTile(
      key: ValueKey('purchase-${p.id}'),
      minVerticalPadding: 12,
      onTap: () => context.go(PurchaseRoutes.detail(p.id)),
      title: Text('${p.purchaseNo} · ${p.supplierName}'),
      subtitle: Text(
        [
          AppFormat.ledgerDate(context, p.date),
          if (p.supplierInvoiceNo != null) p.supplierInvoiceNo!,
          if (p.isReversed) l10n.purchaseReversedTag,
          if (p.isUnpaid && due != null)
            '${l10n.purchaseDueDate}: ${AppFormat.ledgerDate(context, due)}',
          if (p.overdueDays > 0) l10n.purchaseOverdue(p.overdueDays),
        ].join(' · '),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            p.total.format(),
            style: TextStyle(
              decoration: p.isReversed ? TextDecoration.lineThrough : null,
            ),
          ),
          if (p.isUnpaid)
            Text(
              '${l10n.purchaseUnpaid} ${p.outstanding.format()}',
              style: TextStyle(
                color: p.overdueDays > 0
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
