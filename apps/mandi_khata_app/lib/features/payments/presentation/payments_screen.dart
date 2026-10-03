import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/payments/presentation/record_payment_dialog.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class PaymentRoutes {
  static const list = '/payments';
  static const accounts = '/payments/accounts';
  static String detail(String id) => '/payments/$id';
}

/// Payments and receipts: today's by default, filtered by date, direction,
/// mode and party / receipt / cheque number, with a totals row and a
/// "pending cheques" filter. Ctrl/⌘+N records one, Ctrl/⌘+F searches.
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final _searchFocus = FocusNode();
  PaymentFilter _filter = PaymentFilter(
    from: LedgerDate.fromDateTime(DateTime.now()),
    to: LedgerDate.fromDateTime(DateTime.now()),
  );

  /// Shown while the next query loads, so filtering never flashes empty.
  List<Payment>? _last;

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  void _record() => showRecordPaymentDialog(context);

  void _set(PaymentFilter f) => setState(() => _filter = f);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = ref.watch(canProvider(Permission.paymentsCreate));
    final canFinance = ref.watch(canProvider(Permission.financeView));
    final payments = ref.watch(paymentListProvider(_filter)).value ?? _last;
    _last = payments;
    return CallbackShortcuts(
      bindings: {
        ...primaryShortcut(LogicalKeyboardKey.keyF, _searchFocus.requestFocus),
        if (canAdd) ...primaryShortcut(LogicalKeyboardKey.keyN, _record),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(GateRoutes.home),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          floatingActionButton: canAdd
              ? FloatingActionButton.extended(
                  onPressed: _record,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.paymentRecordTitle),
                )
              : null,
          body: Column(
            children: [
              MkTopBar(
                title: l10n.paymentsTitle,
                actions: [
                  const SyncStatusChip(),
                  if (canFinance)
                    IconButton(
                      key: const ValueKey('payments-accounts'),
                      tooltip: l10n.accountsTitle,
                      onPressed: () => context.go(PaymentRoutes.accounts),
                      icon: const Icon(Icons.account_balance_outlined),
                    ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => context.go(GateRoutes.home),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              _Filters(
                filter: _filter,
                searchFocus: _searchFocus,
                onChanged: _set,
              ),
              Expanded(child: _body(l10n, payments, canAdd)),
              if (payments != null && payments.isNotEmpty)
                _TotalsBar(totals: PaymentTotals.of(payments)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n, List<Payment>? payments, bool canAdd) {
    if (payments == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (payments.isEmpty) {
      return MkEmptyState(
        icon: Icons.payments_outlined,
        title: l10n.paymentsEmpty,
        action: canAdd
            ? MkButton(
                label: l10n.paymentRecordTitle,
                icon: Icons.add,
                onPressed: _record,
              )
            : null,
      );
    }
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth < MkBreakpoints.rail
          ? ListView.builder(
              itemCount: payments.length,
              padding: const EdgeInsets.only(bottom: 88),
              itemBuilder: (context, i) => _PaymentTile(payment: payments[i]),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(
                MkSpacing.lg,
                0,
                MkSpacing.lg,
                MkSpacing.lg,
              ),
              child: _PaymentTable(payments: payments),
            ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.filter,
    required this.onChanged,
    required this.searchFocus,
  });

  final PaymentFilter filter;
  final ValueChanged<PaymentFilter> onChanged;
  final FocusNode searchFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(MkSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MkTextField(
            key: const ValueKey('payments-search'),
            focusNode: searchFocus,
            hint: l10n.paymentsSearchHint,
            prefix: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.search, size: 20),
            ),
            onChanged: (v) => onChanged(filter.copyWith(query: v)),
          ),
          const SizedBox(height: MkSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DateRangeChips(
                  from: filter.from,
                  to: filter.to,
                  keyPrefix: 'payments',
                  onChanged: (f, t) =>
                      onChanged(filter.copyWith(from: () => f, to: () => t)),
                ),
                const SizedBox(width: MkSpacing.md),
                DropdownButton<PaymentDirection?>(
                  key: const ValueKey('payments-direction'),
                  value: filter.direction,
                  items: [
                    DropdownMenuItem(child: Text(l10n.paymentsAllDirections)),
                    for (final d in PaymentDirection.values)
                      DropdownMenuItem(
                        value: d,
                        child: Text(l10n.paymentDirectionName(d)),
                      ),
                  ],
                  onChanged: (d) =>
                      onChanged(filter.copyWith(direction: () => d)),
                ),
                const SizedBox(width: MkSpacing.md),
                DropdownButton<PaymentMode?>(
                  key: const ValueKey('payments-mode'),
                  value: filter.mode,
                  items: [
                    DropdownMenuItem(child: Text(l10n.paymentsAllModes)),
                    for (final m in PaymentMode.values)
                      DropdownMenuItem(
                        value: m,
                        child: Text(l10n.paymentModeName(m)),
                      ),
                  ],
                  onChanged: (m) => onChanged(filter.copyWith(mode: () => m)),
                ),
                const SizedBox(width: MkSpacing.md),
                FilterChip(
                  key: const ValueKey('payments-pending-cheques'),
                  label: Text(l10n.paymentsPendingCheques),
                  selected: filter.pendingChequesOnly,
                  onSelected: (v) =>
                      onChanged(filter.copyWith(pendingChequesOnly: v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Direction and, for cheques, status as small chips.
class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: MkSpacing.xs,
      children: [
        if (payment.isReversed)
          MkRoleChip(label: l10n.paymentStatusReversed, warning: true),
        if (payment.chequeStatus != null)
          MkRoleChip(
            label: l10n.chequeStatusName(payment.chequeStatus!),
            warning: payment.chequeStatus == ChequeStatus.bounced,
          ),
      ],
    );
  }
}

MkMoneyTone _tone(Payment p) => p.isReversed
    ? MkMoneyTone.plain
    : p.direction == PaymentDirection.toParty
    ? MkMoneyTone.udhaar
    : MkMoneyTone.jama;

class _PaymentTable extends StatelessWidget {
  const _PaymentTable({required this.payments});

  final List<Payment> payments;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkDataTable<Payment>(
      minWidth: 860,
      rows: payments,
      onRowTap: (p) => context.go(PaymentRoutes.detail(p.id)),
      columns: [
        MkColumn(
          label: l10n.paymentsColNo,
          flex: 3,
          cell: (p) => Text(p.receiptNo, style: MkText.mono()),
          sortKey: (p) => p.receiptNo,
        ),
        MkColumn(
          label: l10n.paymentsColDate,
          flex: 3,
          cell: (p) => Text(AppFormat.ledgerDate(context, p.entryDate)),
          sortKey: (p) => p.entryDate,
        ),
        MkColumn(
          label: l10n.paymentsColParty,
          flex: 5,
          cell: (p) => Text(p.partyName, overflow: TextOverflow.ellipsis),
          sortKey: (p) => p.partyName.toLowerCase(),
        ),
        MkColumn(
          label: l10n.paymentsColType,
          flex: 3,
          cell: (p) => Text(l10n.paymentDirectionName(p.direction)),
        ),
        MkColumn(
          label: l10n.paymentsColMode,
          flex: 2,
          cell: (p) => Text(l10n.paymentModeName(p.mode)),
        ),
        MkColumn(
          label: l10n.paymentsColAmount,
          flex: 3,
          numeric: true,
          cell: (p) => MkMoneyText(p.amount, tone: _tone(p)),
          sortKey: (p) => p.amount.paise,
        ),
        MkColumn(
          label: l10n.paymentsColStatus,
          flex: 3,
          cell: (p) => _StatusChips(payment: p),
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      onTap: () => context.go(PaymentRoutes.detail(payment.id)),
      title: Text(
        payment.partyName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${payment.receiptNo} · ${l10n.paymentModeName(payment.mode)} · '
        '${AppFormat.ledgerDate(context, payment.entryDate)}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MkMoneyText(payment.amount, tone: _tone(payment)),
          _StatusChips(payment: payment),
        ],
      ),
    );
  }
}

class _TotalsBar extends StatelessWidget {
  const _TotalsBar({required this.totals});

  final PaymentTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    Widget item(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: MkSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ', style: TextStyle(color: tokens.textMuted)),
          value,
        ],
      ),
    );
    return DecoratedBox(
      key: const ValueKey('payments-totals'),
      decoration: BoxDecoration(
        color: tokens.background2,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MkSpacing.md),
        child: Wrap(
          alignment: WrapAlignment.end,
          runSpacing: MkSpacing.xs,
          children: [
            item(l10n.paymentsTotalCount, Text('${totals.count}')),
            item(
              l10n.paymentsTotalPaid,
              MkMoneyText(totals.paid, tone: MkMoneyTone.udhaar),
            ),
            item(
              l10n.paymentsTotalReceived,
              MkMoneyText(totals.received, tone: MkMoneyTone.jama),
            ),
          ],
        ),
      ),
    );
  }
}
