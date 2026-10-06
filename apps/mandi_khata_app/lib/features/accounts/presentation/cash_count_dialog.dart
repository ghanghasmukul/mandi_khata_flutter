import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/accounts/data/cash_count_repository.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_labels.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/features/team/presentation/team_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Day-close cash count: pieces per note, the total against the cash book,
/// and (owner / accountant) posting the difference to Cash Short / Excess.
class CashCountDialog extends ConsumerStatefulWidget {
  const CashCountDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => const CashCountDialog(),
  );

  @override
  ConsumerState<CashCountDialog> createState() => _CashCountDialogState();
}

class _CashCountDialogState extends ConsumerState<CashCountDialog> {
  final LedgerDate _date = LedgerDate.fromDateTime(DateTime.now());
  final _counts = <int, int>{};
  Money _loose = Money.zero;
  Money? _book;
  bool _post = true;
  final _note = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      ref.read(bankWriterProvider).cashBalance(_date).then((b) {
        if (mounted) setState(() => _book = b);
      }),
    );
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  CashCount get _count => CashCount(_counts, loose: _loose);

  Future<void> _save(bool canPost) async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    final diff = _book == null ? Money.zero : _count.difference(_book!);
    final result = await ref
        .read(bankWriterProvider)
        .saveCount(
          _date,
          _count,
          postDifference: canPost && _post && !diff.isZero,
          note: _note.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    switch (result) {
      case CashCountSaved(:final voucherNo):
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              voucherNo == null
                  ? l10n.cashCountSaved
                  : l10n.cashCountSavedPosted(voucherNo),
            ),
          ),
        );
      case CashCountNotPermitted(:final permission):
        setState(
          () => _error = l10n.acctNeedsPermission(
            l10n.permissionName(permission),
          ),
        );
      case CashCountVoucherRefused(:final result):
        setState(() => _error = l10n.voucherResult(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canPost = ref.watch(canProvider(Permission.entriesReverse));
    final total = _count.total;
    final book = _book;
    final diff = book == null ? null : total - book;
    final tokens = MkTokens.of(context);
    return AlertDialog(
      title: Text(l10n.cashCountTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.cashCountNotes),
              for (final d in cashDenominations)
                Row(
                  children: [
                    SizedBox(width: 64, child: Text('₹$d ×')),
                    Expanded(
                      child: TextField(
                        key: ValueKey('count-$d'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(isDense: true),
                        onChanged: (v) =>
                            setState(() => _counts[d] = int.tryParse(v) ?? 0),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: Text(
                        Money.rupees(d * (_counts[d] ?? 0)).format(),
                        textAlign: TextAlign.right,
                        style: MkText.mono(),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: MkSpacing.sm),
              MkNumberField(
                key: const ValueKey('count-loose'),
                label: l10n.cashCountLoose,
                onChanged: (p) => setState(() => _loose = Money(p ?? 0)),
              ),
              const Divider(),
              Text(
                l10n.cashCountCounted(total.format()),
                key: const ValueKey('count-total'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (book != null) Text(l10n.cashCountBook(book.format())),
              if (diff != null)
                Text(
                  diff.isZero
                      ? l10n.cashCountMatches
                      : diff.isPositive
                      ? l10n.cashCountExcess(diff.format())
                      : l10n.cashCountShort(diff.abs().format()),
                  key: const ValueKey('count-difference'),
                  style: TextStyle(
                    color: diff.isZero ? tokens.jama : tokens.udhaar,
                  ),
                ),
              if (canPost && diff != null && !diff.isZero)
                CheckboxListTile(
                  key: const ValueKey('count-post'),
                  contentPadding: EdgeInsets.zero,
                  value: _post,
                  onChanged: (v) => setState(() => _post = v ?? false),
                  title: Text(l10n.cashCountPost),
                ),
              MkTextField(label: l10n.cashCountNote, controller: _note),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('count-save'),
          onPressed: book == null ? null : () => _save(canPost),
          child: Text(l10n.cashCountSave),
        ),
      ],
    );
  }
}
