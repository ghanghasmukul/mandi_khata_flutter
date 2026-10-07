import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/sync/sync_indicator.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// "Synced · 2 min ago" / "Offline · 4 queued" / "Sync error · 1 change
/// rejected" — for the top bar. Tapping it when changes were rejected opens
/// the list of what the server refused.
class SyncStatusChip extends ConsumerStatefulWidget {
  const SyncStatusChip({super.key, this.onDark = false});

  /// Plain text on the dark sidebar instead of a pill.
  final bool onDark;

  @override
  ConsumerState<SyncStatusChip> createState() => _SyncStatusChipState();
}

class _SyncStatusChipState extends ConsumerState<SyncStatusChip> {
  // Keeps "N min ago" current without a sync event.
  late final Timer _tick = Timer.periodic(
    const Duration(seconds: 30),
    (_) => setState(() {}),
  );

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicator = ref.watch(syncIndicatorProvider);
    if (indicator == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);

    final (label, dot) = switch (indicator) {
      SyncOff() => (l10n.syncOff, tokens.textFaint),
      SyncRejected(:final count) => (l10n.syncErrorCount(count), tokens.udhaar),
      SyncOffline(:final queued) => (
        queued == 0 ? l10n.syncOffline : l10n.syncOfflineQueued(queued),
        MkColors.pending,
      ),
      SyncBusy() => (l10n.syncSyncing, MkColors.pending),
      SyncDone(:final at) => (_syncedLabel(l10n, at), MkColors.synced),
    };

    final onDark = widget.onDark;
    final chip = Container(
      padding: onDark
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: onDark
          ? null
          : BoxDecoration(
              color: indicator is SyncRejected
                  ? tokens.udhaarTint
                  : tokens.surfaceAlt,
              border: Border.all(color: tokens.border),
              borderRadius: BorderRadius.circular(MkRadius.pill),
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: onDark
                  ? tokens.sidebarMuted
                  : indicator is SyncRejected
                  ? tokens.udhaar
                  : tokens.textMuted,
            ),
          ),
        ],
      ),
    );

    if (indicator is! SyncRejected) {
      return Semantics(liveRegion: true, label: label, child: chip);
    }
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(MkRadius.pill),
        onTap: () => _showErrors(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: mkIsTouch(context) ? 48 : 0),
          child: Center(widthFactor: 1, child: chip),
        ),
      ),
    );
  }

  String _syncedLabel(AppLocalizations l10n, DateTime? at) {
    if (at == null) return l10n.syncSyncing;
    final age = ageOf(at, DateTime.now());
    if (age.minutes < 1) return l10n.syncSyncedJustNow;
    if (age.hours < 1) return l10n.syncSyncedMinutesAgo(age.minutes);
    return l10n.syncSyncedHoursAgo(age.hours);
  }

  Future<void> _showErrors(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkDialog.show<void>(
      context,
      title: l10n.syncErrorsTitle,
      content: const _SyncErrorList(),
      actions: [
        MkButton(
          label: l10n.syncErrorsDismiss,
          variant: MkButtonVariant.ghost,
          onPressed: () async {
            final navigator = Navigator.of(context);
            await dismissSyncErrors(await ref.read(appDatabaseProvider.future));
            navigator.pop();
          },
        ),
        MkButton(
          label: l10n.commonClose,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _SyncErrorList extends ConsumerWidget {
  const _SyncErrorList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errors = ref.watch(syncErrorsProvider).value ?? const [];
    final tokens = MkTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(AppLocalizations.of(context).syncErrorsBody),
        const SizedBox(height: MkSpacing.md),
        for (final e in errors)
          Padding(
            padding: const EdgeInsets.only(bottom: MkSpacing.sm),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${e.table} · ${e.op} · ${e.code ?? '—'}\n',
                    style: MkText.mono(size: 11.5, color: tokens.textMuted),
                  ),
                  TextSpan(text: e.message),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
