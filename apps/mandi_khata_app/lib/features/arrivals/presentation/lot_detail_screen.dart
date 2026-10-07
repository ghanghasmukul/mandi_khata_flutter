import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_providers.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_screen.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/lot_form_fields.dart';
import 'package:mandi_khata_app/features/crops/presentation/mandi_breakdown_view.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One lot: its details, the full calculation (from the rates it was
/// posted with), the khata entries it made, and Edit / Cancel (open lots)
/// or Reverse (posted lots, `entries.reverse`).
class LotDetailScreen extends ConsumerWidget {
  const LotDetailScreen({required this.lotId, super.key});

  final String lotId;

  Future<void> _confirmAndRun(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String message,
    required String action,
    required Future<LotSaveResult> Function() run,
    required String done,
  }) async {
    final l10n = AppLocalizations.of(context);
    final ok = await MkDialog.show<bool>(
      context,
      title: title,
      content: Text(message),
      actions: [
        MkButton(
          label: l10n.commonCancel,
          variant: MkButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        MkButton(
          key: const ValueKey('lot-confirm'),
          label: action,
          variant: MkButtonVariant.danger,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (ok != true) return;
    final result = await run();
    if (!context.mounted) return;
    final error = l10n.lotSaveError(result);
    MkToast.show(
      context,
      error ?? done,
      tone: error == null ? MkToastTone.success : MkToastTone.error,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lot = ref.watch(lotProvider(lotId));
    final canManage = ref.watch(canProvider(Permission.arrivalsManage));
    final canReverse = ref.watch(canProvider(Permission.entriesReverse));
    final l = lot.value;
    void back() => context.go(ArrivalRoutes.list);

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): back},
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(
                title: l?.lotNo ?? l10n.arrivalsTitle,
                subtitle: l == null ? null : l10n.lotStatus(l),
              ),
              Expanded(
                child: switch (lot) {
                  AsyncValue(value: null, isLoading: true) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  AsyncValue(value: null) => MkEmptyState(
                    icon: Icons.search_off,
                    title: l10n.lotErrorNotFound,
                  ),
                  AsyncValue(value: final l?) => ListView(
                    padding: const EdgeInsets.all(MkSpacing.lg),
                    children: [
                      _Actions(
                        lot: l,
                        canManage: canManage,
                        canReverse: canReverse,
                        onCancel: () => _confirmAndRun(
                          context,
                          ref,
                          title: l10n.lotCancelTitle(l.lotNo),
                          message: l10n.lotCancelBody,
                          action: l10n.lotCancel,
                          done: l10n.lotCancelledToast(l.lotNo),
                          run: () => ref.read(lotWriterProvider).cancel(l.id),
                        ),
                        onReverse: () => _confirmAndRun(
                          context,
                          ref,
                          title: l10n.lotReverseTitle(l.lotNo),
                          message: l10n.lotReverseBody,
                          action: l10n.lotReverse,
                          done: l10n.lotReversedToast(l.lotNo),
                          run: () => ref.read(lotWriterProvider).reverse(l.id),
                        ),
                      ),
                      const SizedBox(height: MkSpacing.md),
                      _Details(lot: l),
                      const SizedBox(height: MkSpacing.md),
                      _Calculation(lot: l),
                      const SizedBox(height: MkSpacing.md),
                      _Entries(lot: l),
                    ],
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.lot,
    required this.canManage,
    required this.canReverse,
    required this.onCancel,
    required this.onReverse,
  });

  final Lot lot;
  final bool canManage;
  final bool canReverse;
  final VoidCallback onCancel;
  final VoidCallback onReverse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: MkSpacing.sm,
      runSpacing: MkSpacing.sm,
      children: [
        if (lot.status.isOpen && canManage) ...[
          MkButton(
            key: const ValueKey('lot-edit'),
            label: lot.status == LotStatus.arrived
                ? l10n.lotAddWeightRate
                : l10n.lotEdit,
            icon: Icons.edit_outlined,
            onPressed: () => context.go(ArrivalRoutes.edit(lot.id)),
          ),
          MkButton(
            key: const ValueKey('lot-cancel'),
            label: l10n.lotCancel,
            variant: MkButtonVariant.secondary,
            icon: Icons.block,
            onPressed: onCancel,
          ),
        ],
        if (lot.status == LotStatus.posted && canReverse)
          MkButton(
            key: const ValueKey('lot-reverse'),
            label: l10n.lotReverse,
            variant: MkButtonVariant.danger,
            icon: Icons.undo,
            onPressed: onReverse,
          ),
        if (lot.isReversedAfterPosting && canManage)
          MkButton(
            key: const ValueKey('lot-copy'),
            label: l10n.lotReenter,
            variant: MkButtonVariant.secondary,
            icon: Icons.content_copy,
            onPressed: () => context.go(ArrivalRoutes.copy(lot.id)),
          ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.lot});

  final Lot lot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final l = lot;
    return MkCard(
      title: l10n.lotDetailsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LotInfoRow(l10n.lotDate, AppFormat.ledgerDate(context, l.entryDate)),
          LotInfoRow(
            l10n.lotFarmer,
            [l.farmerName, ?l.farmerCode, ?l.farmerVillage].join(' · '),
          ),
          LotInfoRow(l10n.lotCrop, l.cropNameIn(lang)),
          LotInfoRow(l10n.lotBags, '${l.bags}'),
          LotInfoRow(
            l10n.lotQtl,
            l.qtlMilli == null
                ? '—'
                : [
                    Quintals.format(l.qtlMilli!),
                    if (l.qtlFromBags) '(${l10n.lotQtlFromBagsShort})',
                  ].join('  '),
          ),
          LotInfoRow(
            l10n.lotRate,
            l.rate == null ? '—' : '${l.rate!.format()} ${l10n.lotPerQtl}',
          ),
          if (l.buyerName != null) LotInfoRow(l10n.lotBuyer, l.buyerName!),
          if (l.jFormNo != null) LotInfoRow(l10n.lotJForm, l.jFormNo!),
          if (l.vehicleNo != null) LotInfoRow(l10n.lotVehicle, l.vehicleNo!),
          if (l.notes != null) LotInfoRow(l10n.lotNotes, l.notes!),
          if (l.postedAt != null)
            LotInfoRow(
              l10n.lotPostedAt,
              AppFormat.dateTime(context, l.postedAt!),
            ),
        ],
      ),
    );
  }
}

/// Posted lots show the calculation from their snapshot, never from
/// today's settings.
class _Calculation extends StatelessWidget {
  const _Calculation({required this.lot});

  final Lot lot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = lot.snapshot;
    final qtl = lot.qtlMilli;
    final rate = lot.rate;
    if (config == null || qtl == null || rate == null) {
      return MkCard(
        title: l10n.lotCalculationTitle,
        child: Text(
          l10n.lotNotPostedYet,
          style: TextStyle(color: MkTokens.of(context).textMuted),
        ),
      );
    }
    final b = MandiCharges.calculate(
      LotInput(bags: lot.bags, qtlMilli: qtl, rate: rate),
      config,
    );
    return MkCard(
      title: l10n.lotCalculationTitle,
      child: MandiBreakdownView(breakdown: b),
    );
  }
}

class _Entries extends ConsumerWidget {
  const _Entries({required this.lot});

  final Lot lot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(lotEntriesProvider(lot.id)).value ?? const [];
    if (entries.isEmpty) return const SizedBox.shrink();
    String party(String id) => id == lot.farmerId
        ? lot.farmerName
        : id == lot.buyerId
        ? lot.buyerName ?? ''
        : '';
    return MkCard(
      title: l10n.lotEntriesTitle,
      child: Column(
        children: [
          for (final e in entries)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(party(e.partyId)),
              subtitle: Text(
                [
                  AppFormat.ledgerDate(context, e.entryDate),
                  if (e.isReversal)
                    l10n.lotEntryReversal
                  else
                    l10n.lotEntryArrival,
                ].join(' · '),
              ),
              trailing: MkMoneyText(
                e.amount,
                tone: e.side == Side.jama
                    ? MkMoneyTone.jama
                    : MkMoneyTone.udhaar,
              ),
            ),
        ],
      ),
    );
  }
}
