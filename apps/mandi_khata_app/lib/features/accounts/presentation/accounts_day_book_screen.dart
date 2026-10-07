import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_labels.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/accounts/presentation/journal_entry_dialog.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mk_ui/mk_ui.dart';

/// The accounts day book: every journal entry (vouchers and documents) of a
/// date range, filter by voucher type, tap for the lines and to reverse a
/// voucher. Needs `finance.view` (the journal syncs to finance members).
class AccountsDayBookScreen extends ConsumerStatefulWidget {
  const AccountsDayBookScreen({super.key});

  @override
  ConsumerState<AccountsDayBookScreen> createState() => _DayBookState();
}

class _DayBookState extends ConsumerState<AccountsDayBookScreen> {
  LedgerDate? _from = LedgerDate.fromDateTime(DateTime.now());
  LedgerDate? _to = LedgerDate.fromDateTime(DateTime.now());
  VoucherType? _type;
  bool _vouchersOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows =
        ref
            .watch(
              journalDayBookProvider(
                from: _from ?? LedgerDate(2000, 1, 1),
                to: _to ?? LedgerDate(2999, 12, 31),
                voucherType: _type,
                vouchersOnly: _vouchersOnly,
              ),
            )
            .value ??
        const <JournalDayRow>[];
    final total = rows
        .where((r) => !r.isReversal && !r.isReversed)
        .fold(Money.zero, (s, r) => s + r.total);
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
              MkTopBar(title: l10n.dayBookAccountsTitle),
              Padding(
                padding: const EdgeInsets.all(MkSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateRangeChips(
                      keyPrefix: 'acct-day',
                      from: _from,
                      to: _to,
                      onChanged: (f, t) => setState(() {
                        _from = f;
                        _to = t;
                      }),
                    ),
                    const SizedBox(height: MkSpacing.sm),
                    Wrap(
                      spacing: MkSpacing.sm,
                      children: [
                        FilterChip(
                          key: const ValueKey('day-vouchers-only'),
                          label: Text(l10n.dayBookVouchersOnly),
                          selected: _vouchersOnly,
                          onSelected: (v) => setState(() => _vouchersOnly = v),
                        ),
                        ChoiceChip(
                          label: Text(l10n.dayBookAllTypes),
                          selected: _type == null,
                          onSelected: (_) => setState(() => _type = null),
                        ),
                        for (final t in VoucherType.values)
                          ChoiceChip(
                            key: ValueKey('day-type-${t.dbName}'),
                            label: Text(l10n.voucherTypeName(t)),
                            selected: _type == t,
                            onSelected: (_) => setState(() => _type = t),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? MkEmptyState(title: l10n.dayBookNoEntries)
                    : ListView.separated(
                        itemCount: rows.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) => _Row(row: rows[i]),
                      ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(MkSpacing.md),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Text(
                  '${rows.length} · ${total.format()}',
                  key: const ValueKey('day-total'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
  const _Row({required this.row});

  final JournalDayRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final v = row.voucher;
    final struck = row.isReversed || row.isReversal;
    return ListTile(
      key: ValueKey('day-row-${row.id}'),
      onTap: () => JournalEntryDialog.show(context, row),
      title: Text(
        v == null
            ? '${l10n.sourceTypeName(row.sourceType)} · ${row.narration ?? ''}'
            : '${l10n.voucherTypeName(v.type)} · ${v.voucherNo}',
        style: TextStyle(
          decoration: row.isReversed ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        [
          AppFormat.ledgerDate(context, row.date),
          if (v?.narration != null) v!.narration!,
          if (row.isReversed) l10n.voucherReversedTag,
        ].join(' · '),
      ),
      trailing: Text(
        row.total.format(),
        style: MkText.mono().copyWith(
          color: struck ? Theme.of(context).disabledColor : null,
        ),
      ),
    );
  }
}
