import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_entry_dialog.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

enum _Action { edit, reverse }

/// Edit / reverse menu of one khata line. Nothing for members without
/// `entries.reverse`, for a reversal, an entry already reversed, or an entry
/// posted by a document (a lot, payment…): those are corrected through the
/// document, never edited in the khata.
class EntryActionsMenu extends ConsumerWidget {
  const EntryActionsMenu({
    required this.entry,
    required this.reversed,
    super.key,
    this.partyName,
    this.party,
  });

  final LedgerEntry entry;
  final bool reversed;
  final String? partyName;
  final Party? party;

  /// Manual entries (`journal`) may be edited here; document entries not.
  /// A journal line that points at a document (a loan adjusted against crop
  /// proceeds) belongs to it and is not edited here.
  static bool canEdit(LedgerEntry e) =>
      (e.refType == RefType.journal && e.refId == null) ||
      e.refType == RefType.openingBalance;

  Future<void> _reverse(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await MkDialog.show<bool>(
      context,
      title: l10n.khataReverseTitle,
      content: Text(l10n.khataReverseBody),
      actions: [
        Builder(
          builder: (c) => MkButton(
            label: l10n.commonCancel,
            variant: MkButtonVariant.ghost,
            onPressed: () => Navigator.of(c).pop(false),
          ),
        ),
        Builder(
          builder: (c) => MkButton(
            label: l10n.khataReverse,
            icon: Icons.undo,
            variant: MkButtonVariant.danger,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ),
      ],
    );
    if (ok != true || !context.mounted) return;
    final result = await ref.read(khataWriterProvider).reverse(entry.id);
    if (!context.mounted) return;
    final error = l10n.ledgerPostError(result);
    MkToast.show(
      context,
      error ?? l10n.khataReversed,
      tone: error == null ? MkToastTone.success : MkToastTone.error,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final can = ref.watch(canProvider(Permission.entriesReverse));
    if (!can || entry.isReversal || reversed) return const SizedBox.shrink();
    final editable = canEdit(entry);
    return PopupMenuButton<_Action>(
      tooltip: l10n.khataEntryActions,
      icon: const Icon(Icons.more_vert),
      onSelected: (a) async {
        switch (a) {
          case _Action.edit:
            await showKhataEntryDialog(
              context,
              party:
                  party ??
                  Party(
                    id: entry.partyId,
                    code: '',
                    name: partyName ?? '',
                    roles: const {},
                  ),
              original: entry,
            );
          case _Action.reverse:
            await _reverse(context, ref);
        }
      },
      itemBuilder: (_) => [
        if (editable)
          PopupMenuItem(
            value: _Action.edit,
            child: ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.khataEdit),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        PopupMenuItem(
          value: _Action.reverse,
          child: ListTile(
            leading: const Icon(Icons.undo),
            title: Text(l10n.khataReverse),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
