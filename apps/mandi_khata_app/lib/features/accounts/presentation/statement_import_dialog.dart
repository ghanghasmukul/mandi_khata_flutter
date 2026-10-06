import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Maps the columns of a bank statement ([sheet]) once, previews what is
/// read and imports it. Starts from the mapping saved for the account.
class StatementImportDialog extends ConsumerStatefulWidget {
  const StatementImportDialog({
    required this.accountId,
    required this.sheet,
    this.saved,
    super.key,
  });

  final String accountId;
  final Sheet sheet;
  final StatementMapping? saved;

  @override
  ConsumerState<StatementImportDialog> createState() => _ImportState();
}

class _ImportState extends ConsumerState<StatementImportDialog> {
  late int? _date = widget.saved?.date ?? 0;
  late StatementDateFormat _format =
      widget.saved?.dateFormat ?? StatementDateFormat.dmy;
  late int? _description = widget.saved?.description;
  late int? _reference = widget.saved?.reference;
  late int? _debit = widget.saved?.debit;
  late int? _credit = widget.saved?.credit;
  late int? _amount = widget.saved?.amount;
  late int? _balance = widget.saved?.balance;
  late int _header = widget.saved?.headerRows ?? 1;
  late bool _single = widget.saved?.amount != null;
  bool _busy = false;

  int get _columns => widget.sheet.rows.fold(
    0,
    (m, r) => r.cells.length > m ? r.cells.length : m,
  );

  StatementMapping? get _mapping {
    final date = _date;
    if (date == null) return null;
    final m = StatementMapping(
      date: date,
      dateFormat: _format,
      description: _description,
      reference: _reference,
      debit: _single ? null : _debit,
      credit: _single ? null : _credit,
      amount: _single ? _amount : null,
      balance: _balance,
      headerRows: _header,
    );
    return m.isValid ? m : null;
  }

  String _sample(int column) {
    for (final r in widget.sheet.rows.skip(_header)) {
      final v = r.cell(column);
      if (v.isNotEmpty) return v.length > 24 ? '${v.substring(0, 24)}…' : v;
    }
    return '';
  }

  Widget _column(String key, String label, int? value, ValueChanged<int?> set) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<int?>(
      key: ValueKey(key),
      initialValue: value,
      decoration: InputDecoration(labelText: label, isDense: true),
      items: [
        DropdownMenuItem(child: Text(l10n.reconNoColumn)),
        for (var i = 0; i < _columns; i++)
          DropdownMenuItem(
            value: i,
            child: Text(
              l10n.reconColumnN(i + 1, _sample(i)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (v) => setState(() => set(v)),
    );
  }

  String _error(AppLocalizations l10n, StatementRowError e) =>
      switch (e.problem) {
        StatementRowProblem.badDate => l10n.reconRowBadDate(e.rowNumber),
        StatementRowProblem.badAmount => l10n.reconRowBadAmount(e.rowNumber),
        StatementRowProblem.noAmount => l10n.reconRowNoAmount(e.rowNumber),
      };

  Future<void> _import() async {
    final mapping = _mapping;
    if (mapping == null || _busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final r = await ref
        .read(bankWriterProvider)
        .import(widget.accountId, widget.sheet, mapping);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (r != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.reconImportDone(r.added, r.duplicates, r.errors.length),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mapping = _mapping;
    final preview = mapping == null
        ? null
        : StatementParser.parse(widget.sheet, mapping);
    return AlertDialog(
      title: Text(l10n.reconImportTitle),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.reconMappingHelp),
              const SizedBox(height: MkSpacing.md),
              _column('map-date', l10n.reconColDate, _date, (v) => _date = v),
              DropdownButtonFormField<StatementDateFormat>(
                key: const ValueKey('map-format'),
                initialValue: _format,
                decoration: InputDecoration(
                  labelText: l10n.reconDateFormat,
                  isDense: true,
                ),
                items: [
                  for (final f in StatementDateFormat.values)
                    DropdownMenuItem(value: f, child: Text(f.label)),
                ],
                onChanged: (v) => setState(() => _format = v ?? _format),
              ),
              _column(
                'map-description',
                l10n.reconColDescription,
                _description,
                (v) => _description = v,
              ),
              _column(
                'map-reference',
                l10n.reconColReference,
                _reference,
                (v) => _reference = v,
              ),
              SwitchListTile(
                key: const ValueKey('map-single'),
                contentPadding: EdgeInsets.zero,
                value: _single,
                title: Text(l10n.reconUseAmount),
                onChanged: (v) => setState(() => _single = v),
              ),
              if (_single)
                _column(
                  'map-amount',
                  l10n.reconColAmount,
                  _amount,
                  (v) => _amount = v,
                )
              else ...[
                _column(
                  'map-debit',
                  l10n.reconColDebit,
                  _debit,
                  (v) => _debit = v,
                ),
                _column(
                  'map-credit',
                  l10n.reconColCredit,
                  _credit,
                  (v) => _credit = v,
                ),
              ],
              _column(
                'map-balance',
                l10n.reconColBalance,
                _balance,
                (v) => _balance = v,
              ),
              DropdownButtonFormField<int>(
                key: const ValueKey('map-header'),
                initialValue: _header,
                decoration: InputDecoration(
                  labelText: l10n.reconHeaderRows,
                  isDense: true,
                ),
                items: [
                  for (var i = 0; i <= 15; i++)
                    DropdownMenuItem(value: i, child: Text('$i')),
                ],
                onChanged: (v) => setState(() => _header = v ?? 1),
              ),
              const SizedBox(height: MkSpacing.md),
              if (preview != null) ...[
                Text(
                  l10n.reconPreview(preview.rows.length, preview.errors.length),
                  key: const ValueKey('map-preview'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                for (final e in preview.errors.take(8))
                  Text(
                    _error(l10n, e),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
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
          key: const ValueKey('map-import'),
          onPressed: preview == null || preview.rows.isEmpty || _busy
              ? null
              : _import,
          child: Text(l10n.reconImportButton),
        ),
      ],
    );
  }
}
