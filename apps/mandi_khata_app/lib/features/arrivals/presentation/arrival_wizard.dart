import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_providers.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_screen.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/lot_form_fields.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_picker.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// "New arrival" for the munshi at the mandi gate: farmer → crop and bags →
/// confirm. Saves the lot as arrived; weight and rate are added later at
/// the counter.
class ArrivalWizard extends ConsumerStatefulWidget {
  const ArrivalWizard({super.key});

  @override
  ConsumerState<ArrivalWizard> createState() => _ArrivalWizardState();
}

class _ArrivalWizardState extends ConsumerState<ArrivalWizard> {
  int _step = 0;
  Party? _farmer;
  Crop? _crop;
  int _bags = 0;
  String _vehicle = '';
  bool _saving = false;

  /// Bumped after a save to clear the fields for the next arrival.
  int _gen = 0;

  bool get _canNext => switch (_step) {
    0 => _farmer != null,
    1 => _crop != null && _bags > 0,
    _ => !_saving,
  };

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    final result = await ref
        .read(lotWriterProvider)
        .save(
          LotDraft(
            entryDate: LedgerDate.fromDateTime(DateTime.now()),
            farmerId: _farmer!.id,
            cropId: _crop!.id,
            bags: _bags,
            vehicleNo: _vehicle,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result case LotSaved(:final lotNo)) {
      MkToast.show(
        context,
        l10n.lotSavedToast(lotNo),
        tone: MkToastTone.success,
      );
      // Ready for the next tractor; the crop usually repeats.
      setState(() {
        _step = 0;
        _farmer = null;
        _bags = 0;
        _vehicle = '';
        _gen++;
      });
    } else {
      MkToast.show(
        context,
        l10n.lotSaveError(result)!,
        tone: MkToastTone.error,
      );
    }
  }

  void _next() {
    if (!_canNext) return;
    if (_step < 2) {
      setState(() => _step++);
    } else {
      unawaited(_save());
    }
  }

  void _back() {
    if (_step == 0) {
      context.go(ArrivalRoutes.list);
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titles = [
      l10n.wizardStepFarmer,
      l10n.wizardStepCrop,
      l10n.wizardStepConfirm,
    ];
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.lotNewTitle,
            subtitle: l10n.wizardStepOf(_step + 1, 3, titles[_step]),
            actions: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => context.go(ArrivalRoutes.list),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          LinearProgressIndicator(value: (_step + 1) / 3),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(MkSpacing.lg),
              children: [
                switch (_step) {
                  0 => PartyPicker(
                    key: ValueKey('wizard-farmer-$_gen'),
                    role: PartyRole.farmer,
                    label: l10n.lotFarmer,
                    selected: _farmer,
                    autofocus: true,
                    onSelected: (p) => setState(() => _farmer = p),
                  ),
                  1 => _cropAndBags(l10n),
                  _ => _summary(l10n),
                },
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(MkSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: MkButton(
                      label: _step == 0 ? l10n.commonCancel : l10n.wizardBack,
                      variant: MkButtonVariant.secondary,
                      expand: true,
                      onPressed: _back,
                    ),
                  ),
                  const SizedBox(width: MkSpacing.md),
                  Expanded(
                    child: MkButton(
                      key: const ValueKey('wizard-next'),
                      label: _step < 2 ? l10n.wizardNext : l10n.lotSave,
                      expand: true,
                      busy: _saving,
                      onPressed: _canNext ? _next : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cropAndBags(AppLocalizations l10n) {
    final lang = Localizations.localeOf(context).languageCode;
    final crops = ref.watch(cropListProvider()).value ?? const <Crop>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.lotCrop, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: MkSpacing.sm),
        Wrap(
          spacing: MkSpacing.sm,
          runSpacing: MkSpacing.sm,
          children: [
            for (final c in crops)
              ChoiceChip(
                key: ValueKey('wizard-crop-${c.code}'),
                label: Text(c.nameIn(lang)),
                selected: _crop?.id == c.id,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                onSelected: (_) => setState(() => _crop = c),
              ),
          ],
        ),
        const SizedBox(height: MkSpacing.lg),
        MkNumberField(
          key: ValueKey('wizard-bags-$_gen'),
          kind: MkNumberKind.integer,
          label: l10n.lotBags,
          initialValue: _bags == 0 ? null : _bags,
          onChanged: (v) => setState(() => _bags = v ?? 0),
          onSubmitted: _next,
        ),
        const SizedBox(height: MkSpacing.md),
        MkTextField(
          key: ValueKey('wizard-vehicle-$_gen'),
          initialValue: _vehicle,
          label: l10n.lotVehicle,
          onChanged: (v) => _vehicle = v,
        ),
      ],
    );
  }

  Widget _summary(AppLocalizations l10n) {
    final lang = Localizations.localeOf(context).languageCode;
    final nextNo = ref.watch(nextLotNoProvider).value;
    return MkCard(
      title: nextNo == null ? null : l10n.lotNextNo(nextNo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LotInfoRow(l10n.lotFarmer, l10n.partyFullName(_farmer!)),
          LotInfoRow(l10n.lotCrop, _crop!.nameIn(lang)),
          LotInfoRow(l10n.lotBags, '$_bags'),
          if (_vehicle.trim().isNotEmpty)
            LotInfoRow(l10n.lotVehicle, _vehicle.trim().toUpperCase()),
          const SizedBox(height: MkSpacing.sm),
          Text(
            l10n.wizardRateLater,
            style: TextStyle(color: MkTokens.of(context).textMuted),
          ),
        ],
      ),
    );
  }
}
