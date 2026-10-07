import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/accounts/presentation/cash_count_dialog.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statement_export_bar.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mk_ui/mk_ui.dart';

/// The cash / bank book of one account: opening, every day's receipts and
/// payments with a day total, closing. A munshi sees the Cash book only.
/// The Cash book has "Count cash" (day close).
class CashBookScreen extends ConsumerStatefulWidget {
  const CashBookScreen({this.accountId, super.key});

  final String? accountId;

  @override
  ConsumerState<CashBookScreen> createState() => _CashBookState();
}

class _CashBookState extends ConsumerState<CashBookScreen> {
  late String? _accountId = widget.accountId;
  LedgerDate? _from = LedgerDate.fromDateTime(DateTime.now()).addDays(-6);
  LedgerDate? _to = LedgerDate.fromDateTime(DateTime.now());

  ReportTable _table(AppLocalizations l10n, CashBook book) {
    final rows = <List<Object?>>[
      [_from, l10n.cashBookOpening, null, null, book.opening],
    ];
    for (final d in book.days) {
      var running = d.opening;
      for (final l in d.lines) {
        running += l.signed;
        rows.add([
          d.date,
          l.text ?? '',
          if (l.isIn) l.amount else null,
          if (l.isIn) null else l.amount,
          running,
        ]);
      }
    }
    return ReportTable(
      columns: [
        ReportColumn(l10n.cashBookColDate, ReportColumnKind.date),
        ReportColumn(l10n.cashBookColText, ReportColumnKind.text),
        ReportColumn(l10n.cashBookColIn, ReportColumnKind.money),
        ReportColumn(l10n.cashBookColOut, ReportColumnKind.money),
        ReportColumn(l10n.cashBookColBalance, ReportColumnKind.money),
      ],
      rows: rows,
      totals: [
        l10n.cashBookClosing,
        null,
        book.receipts,
        book.payments,
        book.closing,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accounts =
        ref.watch(bankAccountListProvider()).value ?? const <BankAccount>[];
    final selected =
        accounts.where((a) => a.id == _accountId).firstOrNull ??
        accounts.firstOrNull;
    final book = selected == null
        ? null
        : ref.watch(cashBookProvider(selected.id, from: _from, to: _to)).value;
    final canCount = ref.watch(canProvider(Permission.paymentsCreate));
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(AccountRoutes.hub),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(title: l10n.cashBookTitle),
              Padding(
                padding: const EdgeInsets.all(MkSpacing.md),
                child: Wrap(
                  spacing: MkSpacing.md,
                  runSpacing: MkSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<String>(
                      key: const ValueKey('cash-book-account'),
                      value: selected?.id,
                      hint: Text(l10n.cashBookAccount),
                      items: [
                        for (final a in accounts)
                          DropdownMenuItem(value: a.id, child: Text(a.name)),
                      ],
                      onChanged: (v) => setState(() => _accountId = v),
                    ),
                    DateRangeChips(
                      keyPrefix: 'cash-book',
                      from: _from,
                      to: _to,
                      onChanged: (f, t) => setState(() {
                        _from = f;
                        _to = t;
                      }),
                    ),
                    if (selected?.kind == AccountKind.cash && canCount)
                      MkButton(
                        key: const ValueKey('cash-count'),
                        label: l10n.cashCountTitle,
                        icon: Icons.calculate_outlined,
                        variant: MkButtonVariant.secondary,
                        onPressed: () => CashCountDialog.show(context),
                      ),
                    if (book != null && selected != null)
                      StatementExportBar(
                        title: '${l10n.cashBookTitle} · ${selected.name}',
                        fileStem: 'cash-book-${_to ?? 'all'}',
                        table: _table(l10n, book),
                      ),
                  ],
                ),
              ),
              if (book != null) _Summary(book: book),
              Expanded(
                child: book == null
                    ? const Center(child: CircularProgressIndicator())
                    : book.days.isEmpty
                    ? MkEmptyState(title: l10n.cashBookEmpty)
                    : ListView(
                        children: [for (final d in book.days) _Day(day: d)],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.book});

  final CashBook book;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget cell(String key, String label, Money m) => Padding(
      padding: const EdgeInsets.only(right: MkSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(m.format(), key: ValueKey(key), style: MkText.mono()),
        ],
      ),
    );
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(MkSpacing.md),
      child: Wrap(
        children: [
          cell('book-opening', l10n.cashBookOpening, book.opening),
          cell('book-receipts', l10n.cashBookReceipts, book.receipts),
          cell('book-payments', l10n.cashBookPayments, book.payments),
          cell('book-closing', l10n.cashBookClosing, book.closing),
        ],
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({required this.day});

  final CashBookDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mono = MkText.mono();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MkSpacing.md,
            MkSpacing.md,
            MkSpacing.md,
            MkSpacing.xs,
          ),
          child: Text(
            '${AppFormat.ledgerDate(context, day.date)} · '
            '${l10n.cashBookOpening} ${day.opening.format()}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        for (final l in day.lines)
          ListTile(
            dense: true,
            title: Text(l.text ?? ''),
            trailing: Text(
              l.isIn ? '+${l.amount.format()}' : '−${l.amount.format()}',
              style: mono.copyWith(
                color: l.isIn
                    ? MkTokens.of(context).jama
                    : MkTokens.of(context).udhaar,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MkSpacing.md),
          child: Text(
            '${l10n.cashBookDayTotal}: ${l10n.cashBookColIn} '
            '${day.receipts.format()} · ${l10n.cashBookColOut} '
            '${day.payments.format()} · ${l10n.cashBookClosing} '
            '${day.closing.format()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
