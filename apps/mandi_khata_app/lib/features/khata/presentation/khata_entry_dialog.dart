import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_line.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_picker.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Opens the manual khata entry dialog ("Khata entry"). With [original] it
/// edits that entry: the original is shown struck through and saving
/// reverses it and posts the new version (one transaction). Returns true
/// when something was saved.
Future<bool> showKhataEntryDialog(
  BuildContext context, {
  Party? party,
  LedgerEntry? original,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    barrierColor: MkColors.scrim,
    builder: (_) => KhataEntryDialog(party: party, original: original),
  );
  return saved ?? false;
}

class KhataEntryDialog extends ConsumerStatefulWidget {
  const KhataEntryDialog({super.key, this.party, this.original});

  /// Pre-selected party (opened from a party's page).
  final Party? party;

  /// The entry being edited, if any.
  final LedgerEntry? original;

  @override
  ConsumerState<KhataEntryDialog> createState() => _KhataEntryDialogState();
}

class _KhataEntryDialogState extends ConsumerState<KhataEntryDialog> {
  late Party? _party = widget.party;
  late Side _side = widget.original?.side ?? Side.udhaar;
  late Money? _amount = widget.original?.amount;
  late LedgerDate _date =
      widget.original?.entryDate ?? LedgerDate.fromDateTime(DateTime.now());
  late final _narration = TextEditingController(
    text: widget.original?.narration ?? '',
  );
  bool _saving = false;
  String? _error;
  bool _submitted = false;

  bool get _editing => widget.original != null;

  @override
  void dispose() {
    _narration.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_date.year, _date.month, _date.day),
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 366)),
    );
    if (picked != null) setState(() => _date = LedgerDate.fromDateTime(picked));
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final amount = _amount;
    if ((_party == null && !_editing) || amount == null || !amount.isPositive) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final writer = ref.read(khataWriterProvider);
    final result = _editing
        ? await writer.correct(
            widget.original!.id,
            side: _side,
            amount: amount,
            entryDate: _date,
            narration: _narration.text,
          )
        : await writer.addManual(
            partyId: _party!.id,
            side: _side,
            amount: amount,
            entryDate: _date,
            narration: _narration.text,
          );
    if (!mounted) return;
    final error = AppLocalizations.of(context).ledgerPostError(result);
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final original = widget.original;
    return MkDialog(
      title: _editing ? l10n.khataEditTitle : l10n.khataEntryTitle,
      maxWidth: 480,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (original != null) ...[
            Text(l10n.khataEditOriginal, style: theme.textTheme.labelMedium),
            const SizedBox(height: MkSpacing.xs),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: MkTokens.of(context).border),
                borderRadius: BorderRadius.circular(MkRadius.md),
              ),
              child: KhataLine(
                entry: original,
                balance: Money.zero,
                struck: true,
                partyName: widget.party?.name,
              ),
            ),
            const SizedBox(height: MkSpacing.sm),
            Text(l10n.khataEditExplain, style: theme.textTheme.bodySmall),
            const SizedBox(height: MkSpacing.lg),
          ] else
            PartyPicker(
              role: null,
              selected: _party,
              onSelected: (p) => setState(() => _party = p),
              label: l10n.khataFieldParty,
              hint: l10n.khataFieldPartyHint,
              autofocus: widget.party == null,
              errorText: _submitted && _party == null
                  ? l10n.partyErrorRequired
                  : null,
            ),
          const SizedBox(height: MkSpacing.md),
          SegmentedButton<Side>(
            key: const ValueKey('khata-side'),
            segments: [
              ButtonSegment(
                value: Side.udhaar,
                label: Text(l10n.khataSideUdhaar),
              ),
              ButtonSegment(value: Side.jama, label: Text(l10n.khataSideJama)),
            ],
            selected: {_side},
            onSelectionChanged: (s) => setState(() => _side = s.first),
          ),
          const SizedBox(height: MkSpacing.md),
          MkNumberField(
            key: const ValueKey('khata-amount'),
            label: l10n.khataFieldAmount,
            initialValue: _amount?.paise,
            autofocus: widget.party != null || _editing,
            errorText: _submitted && !(_amount?.isPositive ?? false)
                ? l10n.khataErrorAmount
                : null,
            onChanged: (p) =>
                setState(() => _amount = p == null ? null : Money(p)),
            onSubmitted: _save,
          ),
          const SizedBox(height: MkSpacing.md),
          InkWell(
            key: const ValueKey('khata-date'),
            onTap: _pickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.khataFieldDate,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
              child: Text(AppFormat.ledgerDate(context, _date)),
            ),
          ),
          const SizedBox(height: MkSpacing.md),
          MkTextField(
            key: const ValueKey('khata-narration'),
            controller: _narration,
            label: l10n.khataFieldNarration,
            maxLines: 2,
          ),
          if (_error != null) ...[
            const SizedBox(height: MkSpacing.md),
            Text(
              _error!,
              key: const ValueKey('khata-error'),
              style: TextStyle(color: MkTokens.of(context).udhaar),
            ),
          ],
        ],
      ),
      actions: [
        MkButton(
          label: l10n.commonCancel,
          variant: MkButtonVariant.ghost,
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
        ),
        MkButton(
          key: const ValueKey('khata-save'),
          label: _editing ? l10n.khataEditSave : l10n.khataEntrySave,
          icon: Icons.check,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}
