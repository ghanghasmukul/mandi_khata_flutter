import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart' show Permission;
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_labels.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The lines of one journal entry; a voucher can be reversed from here
/// (`entries.reverse`), other documents only from their own screen.
class JournalEntryDialog extends ConsumerWidget {
  const JournalEntryDialog({required this.row, super.key});

  final JournalDayRow row;

  static Future<void> show(BuildContext context, JournalDayRow row) =>
      showDialog<void>(
        context: context,
        builder: (_) => JournalEntryDialog(row: row),
      );

  Future<void> _reverse(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.voucherReverse),
        content: Text(l10n.voucherReverseBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('voucher-reverse-confirm'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(l10n.voucherReverse),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final result = await ref
        .read(accountsWriterProvider)
        .reverse(row.voucher!.id);
    if (!context.mounted) return;
    final error = l10n.voucherResult(result);
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lines = ref.watch(journalLinesProvider(row.id)).value ?? const [];
    final canReverse = ref.watch(canProvider(Permission.entriesReverse));
    final v = row.voucher;
    final source = l10n.sourceTypeName(row.sourceType);
    return AlertDialog(
      title: Text(
        v == null
            ? '${l10n.journalEntryTitle} · $source'
            : '${l10n.voucherTypeName(v.type)} ${v.voucherNo}',
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppFormat.ledgerDate(context, row.date)),
            if (row.narration != null) Text(row.narration!),
            const Divider(),
            Row(
              children: [
                Expanded(flex: 3, child: Text(l10n.voucherAccount)),
                Expanded(
                  child: Text(l10n.journalDebit, textAlign: TextAlign.right),
                ),
                Expanded(
                  child: Text(l10n.journalCredit, textAlign: TextAlign.right),
                ),
              ],
            ),
            for (final l in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        [
                          l.account?.label ?? l10n.journalAccountNotSynced,
                          if (l.memo != null) l.memo!,
                        ].join(' · '),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l.debit.isZero ? '' : l.debit.format(),
                        textAlign: TextAlign.right,
                        style: MkText.mono(),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l.credit.isZero ? '' : l.credit.format(),
                        textAlign: TextAlign.right,
                        style: MkText.mono(),
                      ),
                    ),
                  ],
                ),
              ),
            if (v == null && !row.isReversal) ...[
              const SizedBox(height: MkSpacing.md),
              Text(
                l10n.dayBookReverseOnDocument,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (v != null && !v.isReversed && canReverse)
          TextButton.icon(
            key: const ValueKey('voucher-reverse'),
            onPressed: () => _reverse(context, ref),
            icon: const Icon(Icons.undo),
            label: Text(l10n.voucherReverse),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}
