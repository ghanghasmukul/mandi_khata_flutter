import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/payments/presentation/record_payment_dialog.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/dues_models.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/shop_report_tables.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_report_frame.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_report_titles.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_reports_providers.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Payables and receivables (step 4.4): breakdowns of the khata by source.
/// A party's net position is the single khata balance; nothing here adds to
/// it.
class ShopDuesScreen extends ConsumerStatefulWidget {
  const ShopDuesScreen({super.key});

  @override
  ConsumerState<ShopDuesScreen> createState() => _ShopDuesState();
}

class _ShopDuesState extends ConsumerState<ShopDuesScreen> {
  int _tab = 0;
  final LedgerDate _today = shopToday();

  Future<void> _settle(String partyId, PaymentDirection direction) async {
    final party = await ref.read(partyProvider(partyId).future);
    if (party == null || !mounted) return;
    await showRecordPaymentDialog(context, party: party, direction: direction);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = shopReportTitles(l10n);
    final payables = ref.watch(supplierPayablesProvider(_today)).value;
    final receivables = ref.watch(customerReceivablesProvider).value;
    final table = _tab == 0
        ? (payables == null
              ? null
              : ShopReportTables.payables(payables, title: title))
        : (receivables == null
              ? null
              : ShopReportTables.receivables(receivables, title: title));
    return ShopReportFrame(
      title: l10n.shrDuesTitle,
      route: ShopReportRoutes.dues,
      controls: [
        SegmentedButton<int>(
          key: const ValueKey('dues-tabs'),
          segments: [
            ButtonSegment(value: 0, label: Text(l10n.shrTabPayables)),
            ButtonSegment(value: 1, label: Text(l10n.shrTabReceivables)),
          ],
          selected: {_tab},
          onSelectionChanged: (s) => setState(() => _tab = s.first),
        ),
        ShopExportBar(
          title: _tab == 0 ? l10n.shrTabPayables : l10n.shrTabReceivables,
          fileStem: _tab == 0 ? 'supplier-payables' : 'customer-receivables',
          table: table,
          permission: Permission.financeView,
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MkSpacing.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.shrDuesNote,
                key: const ValueKey('dues-note'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: _tab == 0
                ? _Payables(
                    rows: payables,
                    onPay: (id) {
                      unawaited(_settle(id, PaymentDirection.toParty));
                    },
                  )
                : _Receivables(
                    rows: receivables,
                    onCollect: (id) {
                      unawaited(_settle(id, PaymentDirection.fromParty));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Future<void> showKhataBreakdown(
  BuildContext context, {
  required String partyId,
  required String name,
}) => showDialog<void>(
  context: context,
  builder: (_) => _BreakdownDialog(partyId: partyId, name: name),
);

class _BreakdownDialog extends ConsumerWidget {
  const _BreakdownDialog({required this.partyId, required this.name});

  final String partyId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(khataBreakdownProvider(partyId)).value;
    return AlertDialog(
      key: const ValueKey('breakdown-dialog'),
      title: Text(l10n.shrBreakdownTitle(name)),
      content: SizedBox(
        width: 420,
        child: data == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.shrBreakdownNote),
                  const SizedBox(height: MkSpacing.md),
                  for (final e in data.parts.entries)
                    ListTile(
                      dense: true,
                      title: Text(l10n.shrRefType(e.key)),
                      trailing: Text(e.value.format()),
                    ),
                  const Divider(),
                  ListTile(
                    key: const ValueKey('breakdown-balance'),
                    dense: true,
                    title: Text(
                      l10n.shrBreakdownBalance,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      data.balance.format(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({
    required this.label,
    required this.onAction,
    required this.onBreakdown,
    required this.enabled,
    required this.keyPrefix,
    this.disabledHint,
  });

  final String label;
  final VoidCallback onAction;
  final VoidCallback onBreakdown;
  final bool enabled;
  final String keyPrefix;
  final String? disabledHint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final can = ref.watch(canProvider(Permission.paymentsCreate));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: enabled ? '' : (disabledHint ?? ''),
          child: MkButton(
            key: ValueKey(keyPrefix),
            label: label,
            variant: MkButtonVariant.secondary,
            onPressed: can && enabled ? onAction : null,
          ),
        ),
        const SizedBox(width: MkSpacing.sm),
        IconButton(
          key: ValueKey('$keyPrefix-breakdown'),
          tooltip: l10n.shrBreakdown,
          icon: const Icon(Icons.account_tree_outlined),
          onPressed: onBreakdown,
        ),
      ],
    );
  }
}

class _Payables extends StatelessWidget {
  const _Payables({required this.rows, required this.onPay});

  final List<SupplierPayable>? rows;
  final ValueChanged<String> onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = rows;
    if (list == null) return const Center(child: CircularProgressIndicator());
    if (list.isEmpty) return MkEmptyState(title: l10n.shrNoPayables);
    final total = list.fold<Money>(Money.zero, (a, r) => a + r.outstanding);
    return Column(
      children: [
        Expanded(
          child: MkDataTable<SupplierPayable>(
            minWidth: 820,
            rows: list,
            columns: [
              MkColumn(
                label: l10n.shrColSupplier,
                flex: 3,
                cell: (r) => Text(r.name),
                sortKey: (r) => r.name.toLowerCase(),
              ),
              MkColumn(
                label: l10n.shrColUnpaidBills,
                numeric: true,
                flex: 2,
                cell: (r) => Text(r.outstanding.format()),
                sortKey: (r) => r.outstanding.paise,
              ),
              MkColumn(
                label: l10n.shrColDueDate,
                flex: 2,
                cell: (r) => Text(
                  r.oldestDue == null
                      ? ''
                      : AppFormat.ledgerDate(context, r.oldestDue!),
                ),
                sortKey: (r) => r.oldestDue?.toString() ?? '',
              ),
              MkColumn(
                label: l10n.shrColDaysOverdue,
                flex: 2,
                cell: (r) => Text(
                  r.isOverdue
                      ? l10n.shrOverdueDays(r.daysOverdue)
                      : l10n.shrNotDue,
                  style: r.isOverdue
                      ? TextStyle(color: MkTokens.of(context).udhaar)
                      : null,
                ),
                sortKey: (r) => r.daysOverdue,
              ),
              MkColumn(
                label: l10n.shrColKhataBalance,
                numeric: true,
                flex: 2,
                cell: (r) => Text(r.khataBalance.format()),
                sortKey: (r) => r.khataBalance.paise,
              ),
              MkColumn(
                label: '',
                flex: 3,
                cell: (r) => _Actions(
                  keyPrefix: 'pay-${r.partyId}',
                  label: l10n.shrPay,
                  enabled: true,
                  onAction: () => onPay(r.partyId),
                  onBreakdown: () => showKhataBreakdown(
                    context,
                    partyId: r.partyId,
                    name: r.name,
                  ),
                ),
              ),
            ],
          ),
        ),
        _TotalStrip(label: l10n.shrColUnpaidBills, value: total),
      ],
    );
  }
}

class _Receivables extends StatelessWidget {
  const _Receivables({required this.rows, required this.onCollect});

  final List<CustomerReceivable>? rows;
  final ValueChanged<String> onCollect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = rows;
    if (list == null) return const Center(child: CircularProgressIndicator());
    if (list.isEmpty) return MkEmptyState(title: l10n.shrNoReceivables);
    final total = list.fold<Money>(Money.zero, (a, r) => a + r.receivable);
    return Column(
      children: [
        Expanded(
          child: MkDataTable<CustomerReceivable>(
            minWidth: 900,
            rows: list,
            columns: [
              MkColumn(
                label: l10n.shrColCustomer,
                flex: 3,
                cell: (r) => Text(r.name),
                sortKey: (r) => r.name.toLowerCase(),
              ),
              MkColumn(
                label: l10n.shrColShopSales,
                numeric: true,
                flex: 2,
                cell: (r) => Text(r.shopSales.format()),
                sortKey: (r) => r.shopSales.paise,
              ),
              MkColumn(
                label: l10n.shrColShopReturns,
                numeric: true,
                flex: 2,
                cell: (r) => Text(r.shopReturns.format()),
                sortKey: (r) => r.shopReturns.paise,
              ),
              MkColumn(
                label: l10n.shrColToCollect,
                numeric: true,
                flex: 2,
                cell: (r) => Text(r.receivable.format()),
                sortKey: (r) => r.receivable.paise,
              ),
              MkColumn(
                label: l10n.shrColKhataBalance,
                numeric: true,
                flex: 2,
                cell: (r) => Text(r.khataBalance.format()),
                sortKey: (r) => r.khataBalance.paise,
              ),
              MkColumn(
                label: '',
                flex: 3,
                cell: (r) => _Actions(
                  keyPrefix: 'collect-${r.partyId}',
                  label: l10n.shrCollect,
                  enabled: r.receivable.isPositive,
                  disabledHint: l10n.shrCollectDisabled,
                  onAction: () => onCollect(r.partyId),
                  onBreakdown: () => showKhataBreakdown(
                    context,
                    partyId: r.partyId,
                    name: r.name,
                  ),
                ),
              ),
            ],
          ),
        ),
        _TotalStrip(label: l10n.shrColToCollect, value: total),
      ],
    );
  }
}

class _TotalStrip extends StatelessWidget {
  const _TotalStrip({required this.label, required this.value});

  final String label;
  final Money value;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    padding: const EdgeInsets.all(MkSpacing.md),
    child: Text(
      '$label: ${value.format()}',
      key: const ValueKey('dues-total'),
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}
