import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrival_wizard.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_providers.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_screen.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/lot_form_fields.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/lot_preview_panel.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_picker.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

/// New lot ([lotId] null), a copy of [copyFromId], or an open lot to edit.
/// Keyboard first: farmer → crop → bags → qtl → rate → buyer; the
/// calculation updates live. F10 / Ctrl+S saves (and posts once weight and
/// rate are in), Shift+F10 saves and starts the next lot, Esc goes back.
/// On a phone, a new lot opens the 3-step gate wizard instead.
class LotFormScreen extends ConsumerStatefulWidget {
  const LotFormScreen({super.key, this.lotId, this.copyFromId});

  final String? lotId;
  final String? copyFromId;

  @override
  ConsumerState<LotFormScreen> createState() => _LotFormScreenState();
}

class _LotFormScreenState extends ConsumerState<LotFormScreen> {
  final _qtl = TextEditingController();
  final _jForm = TextEditingController();
  final _vehicle = TextEditingController();
  final _notes = TextEditingController();
  final _farmerFocus = FocusNode();
  final _cropFocus = FocusNode();
  final _bagsFocus = FocusNode();

  Party? _farmer;
  Party? _buyer;
  String? _cropId;
  LedgerDate _date = LedgerDate.fromDateTime(DateTime.now());
  int _bags = 0;
  int? _ratePaise;
  bool _qtlFromBags = false;
  bool _saving = false;
  bool _missingFarmer = false;
  bool _missingCrop = false;
  Set<LotProblem> _problems = const {};

  /// Bumped to rebuild the stateful number fields with new values.
  int _gen = 0;
  late bool _loading = (widget.lotId ?? widget.copyFromId) != null;

  bool get _editing => widget.lotId != null;

  @override
  void initState() {
    super.initState();
    final from = widget.lotId ?? widget.copyFromId;
    if (from != null) unawaited(_load(from));
  }

  /// The first value of an auto-disposed stream provider. Listening keeps
  /// it alive until the value arrives; a bare `ref.read(….future)` lets it
  /// be disposed first and never completes.
  Future<T> _first<T>(
    ProviderListenable<AsyncValue<T>> provider,
    ProviderListenable<Future<T>> future,
  ) async {
    final sub = ref.listenManual(provider, (_, _) {});
    try {
      return await ref.read(future);
    } finally {
      sub.close();
    }
  }

  Future<void> _load(String id) async {
    final lot = await _first(lotProvider(id), lotProvider(id).future);
    Party? farmer;
    Party? buyer;
    if (lot != null) {
      final f = partyProvider(lot.farmerId);
      farmer = await _first(f, f.future);
      if (lot.buyerId != null) {
        final b = partyProvider(lot.buyerId!);
        buyer = await _first(b, b.future);
      }
    }
    if (!mounted) return;
    setState(() {
      if (lot != null) _fill(lot.toDraft(), farmer, buyer);
      _loading = false;
    });
  }

  void _fill(LotDraft d, Party? farmer, Party? buyer) {
    _farmer = farmer;
    _buyer = buyer;
    _cropId = d.cropId;
    _date = d.entryDate;
    _bags = d.bags;
    _ratePaise = d.rate?.paise;
    _qtlFromBags = d.qtlFromBags;
    _qtl.text = d.qtlMilli == null ? '' : Quintals.format(d.qtlMilli!);
    _jForm.text = d.jFormNo ?? '';
    _vehicle.text = d.vehicleNo ?? '';
    _notes.text = d.notes ?? '';
    _gen++;
  }

  /// After "save & new": keeps the date and crop (lots come in runs of
  /// one crop), clears the rest.
  void _resetForNext() {
    _farmer = null;
    _buyer = null;
    _bags = 0;
    _ratePaise = null;
    _qtlFromBags = false;
    _problems = const {};
    for (final c in [_qtl, _jForm, _vehicle, _notes]) {
      c.clear();
    }
    _gen++;
  }

  @override
  void dispose() {
    for (final c in [_qtl, _jForm, _vehicle, _notes]) {
      c.dispose();
    }
    for (final f in [_farmerFocus, _cropFocus, _bagsFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  void _back() => context.go(
    _editing ? ArrivalRoutes.detail(widget.lotId!) : ArrivalRoutes.list,
  );

  Crop? _crop(List<Crop>? crops) {
    for (final c in crops ?? const <Crop>[]) {
      if (c.id == _cropId) return c;
    }
    return null;
  }

  MandiConfig? _config(Crop? crop) {
    final farmer = _farmer;
    final target = (
      partyId: farmer?.id,
      partyGroupId: farmer?.partyGroupId,
      documentId: widget.lotId,
    );
    final resolver = ref.watch(settingsResolverProvider(target));
    if (resolver == null || crop == null) return null;
    return MandiConfig.resolve(
      resolver,
      cropCode: crop.code,
      partyId: target.partyId,
      partyGroupId: target.partyGroupId,
      lotId: target.documentId,
    );
  }

  int? _qtlMilli(MandiConfig? config) => _qtlFromBags
      ? (config == null || _bags <= 0
            ? null
            : MandiCharges.qtlMilliFromBags(_bags, config.bagWeightKg))
      : Quintals.parseMilli(_qtl.text);

  Future<void> _save({required bool post, bool andNew = false}) async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final farmer = _farmer;
    final cropId = _cropId;
    setState(() {
      _missingFarmer = farmer == null;
      _missingCrop = cropId == null;
    });
    if (farmer == null || cropId == null) return;
    final crops = ref.read(cropListProvider(includeInactive: true)).value;
    final draft = LotDraft(
      entryDate: _date,
      farmerId: farmer.id,
      cropId: cropId,
      bags: _bags,
      qtlMilli: _qtlMilli(_config(_crop(crops))),
      qtlFromBags: _qtlFromBags,
      rate: _ratePaise == null ? null : Money(_ratePaise!),
      buyerId: _buyer?.id,
      jFormNo: _jForm.text,
      vehicleNo: _vehicle.text,
      notes: _notes.text,
    );
    setState(() => _saving = true);
    final result = await ref
        .read(lotWriterProvider)
        .save(draft, id: widget.lotId, post: post);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _problems = result is LotInvalid ? result.problems : const {};
    });
    switch (result) {
      case LotSaved(:final id, :final lotNo, :final status):
        MkToast.show(
          context,
          status == LotStatus.posted
              ? l10n.lotPostedToast(lotNo)
              : l10n.lotSavedToast(lotNo),
          tone: MkToastTone.success,
        );
        if (andNew) {
          if (_editing || widget.copyFromId != null) {
            context.go(ArrivalRoutes.create);
            return;
          }
          setState(_resetForNext);
          _farmerFocus.requestFocus();
        } else {
          context.go(ArrivalRoutes.detail(id));
        }
      case LotInvalid():
        break;
      case LotNotPermitted() || LotNotFound() || LotLocked():
        MkToast.show(
          context,
          l10n.lotSaveError(result)!,
          tone: MkToastTone.error,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final narrow = MediaQuery.sizeOf(context).width < MkBreakpoints.rail;
    if (narrow && widget.lotId == null && widget.copyFromId == null) {
      return const ArrivalWizard();
    }
    final crops = ref.watch(cropListProvider(includeInactive: true)).value;
    final crop = _crop(crops);
    final config = _config(crop);
    final qtlMilli = _qtlMilli(config);
    final rate = _ratePaise == null ? null : Money(_ratePaise!);
    final complete = qtlMilli != null && rate != null;
    final nextNo = _editing ? null : ref.watch(nextLotNoProvider).value;

    void save() => _save(post: true);
    void saveNew() => _save(post: true, andNew: true);

    final preview = LotPreviewPanel(
      config: config,
      farmerId: _farmer?.id,
      buyerId: _buyer?.id,
      bags: _bags,
      qtlMilli: qtlMilli,
      rate: rate,
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f10): save,
        const SingleActivator(LogicalKeyboardKey.f10, shift: true): saveNew,
        ...primaryShortcut(LogicalKeyboardKey.keyS, save),
        const SingleActivator(LogicalKeyboardKey.escape): _back,
      },
      child: Scaffold(
        body: Column(
          children: [
            MkTopBar(
              title: _editing ? l10n.lotEditTitle : l10n.lotNewTitle,
              subtitle: nextNo == null ? null : l10n.lotNextNo(nextNo),
              actions: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: _back,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                      builder: (context, c) {
                        final form = _form(l10n, config);
                        if (c.maxWidth < MkBreakpoints.sidebar) {
                          return ListView(
                            padding: const EdgeInsets.all(MkSpacing.lg),
                            children: [
                              form,
                              const SizedBox(height: MkSpacing.lg),
                              preview,
                            ],
                          );
                        }
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(MkSpacing.xxl),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: form),
                              const SizedBox(width: MkSpacing.xxl),
                              Expanded(flex: 2, child: preview),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            _ActionBar(
              complete: complete,
              saving: _saving,
              onSave: save,
              onSaveNew: saveNew,
              onHold: () => _save(post: false),
              onCancel: _back,
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(AppLocalizations l10n, MandiConfig? config) {
    const gap = SizedBox(height: MkSpacing.md, width: MkSpacing.md);
    Widget pair(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        gap,
        Expanded(child: b),
      ],
    );
    final autoQtl = _qtlFromBags ? _qtlMilli(config) : null;
    return FocusTraversalGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: LotDateField(
              date: _date,
              onChanged: (d) => setState(() => _date = d),
            ),
          ),
          gap,
          PartyPicker(
            key: const ValueKey('lot-farmer'),
            role: PartyRole.farmer,
            label: l10n.lotFarmer,
            selected: _farmer,
            focusNode: _farmerFocus,
            autofocus: !_editing,
            errorText: _missingFarmer && _farmer == null
                ? l10n.lotErrorPickFarmer
                : null,
            onSelected: (p) {
              setState(() => _farmer = p);
              if (p != null) _cropFocus.requestFocus();
            },
          ),
          gap,
          CropSelector(
            cropId: _cropId,
            focusNode: _cropFocus,
            errorText: _missingCrop && _cropId == null
                ? l10n.lotErrorPickCrop
                : null,
            onSelected: (c) {
              setState(() => _cropId = c.id);
              _bagsFocus.requestFocus();
            },
          ),
          gap,
          pair(
            MkNumberField(
              key: ValueKey('lot-bags-$_gen'),
              kind: MkNumberKind.integer,
              label: l10n.lotBags,
              focusNode: _bagsFocus,
              initialValue: _bags == 0 ? null : _bags,
              textInputAction: TextInputAction.next,
              errorText: _problems.contains(LotProblem.bagsNegative)
                  ? l10n.lotProblemBags
                  : null,
              onChanged: (v) => setState(() => _bags = v ?? 0),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_qtlFromBags)
                  MkTextField(
                    key: ValueKey('lot-qtl-auto-$autoQtl'),
                    initialValue: autoQtl == null
                        ? ''
                        : Quintals.format(autoQtl),
                    enabled: false,
                    label: l10n.lotQtl,
                  )
                else
                  MkTextField(
                    key: const ValueKey('lot-qtl'),
                    controller: _qtl,
                    label: l10n.lotQtl,
                    hint: '0.000',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [QtlInputFormatter()],
                    textInputAction: TextInputAction.next,
                    errorText:
                        _problems.contains(LotProblem.weightNotPositive) ||
                            _problems.contains(LotProblem.noWeight)
                        ? l10n.lotProblemWeight
                        : null,
                    onChanged: (_) => setState(() {}),
                  ),
                CheckboxListTile(
                  key: const ValueKey('lot-qtl-from-bags'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _qtlFromBags,
                  title: Text(
                    l10n.lotQtlFromBags(config?.bagWeightKg.toString() ?? '…'),
                  ),
                  onChanged: (v) => setState(() => _qtlFromBags = v ?? false),
                ),
              ],
            ),
          ),
          gap,
          MkNumberField(
            key: ValueKey('lot-rate-$_gen'),
            label: l10n.lotRate,
            suffixText: l10n.lotPerQtl,
            initialValue: _ratePaise,
            textInputAction: TextInputAction.next,
            errorText: _problems.contains(LotProblem.rateNotPositive)
                ? l10n.lotProblemRate
                : null,
            onChanged: (v) => setState(() => _ratePaise = v),
          ),
          gap,
          PartyPicker(
            key: const ValueKey('lot-buyer'),
            role: PartyRole.buyer,
            label: l10n.lotBuyer,
            hint: l10n.lotBuyerHint,
            selected: _buyer,
            errorText:
                _problems.contains(LotProblem.buyerRequired) ||
                    _problems.contains(LotProblem.buyerIsFarmer)
                ? l10n.lotProblem(
                    _problems.contains(LotProblem.buyerRequired)
                        ? LotProblem.buyerRequired
                        : LotProblem.buyerIsFarmer,
                  )
                : null,
            onSelected: (p) => setState(() => _buyer = p),
          ),
          gap,
          pair(
            MkTextField(
              controller: _jForm,
              label: l10n.lotJForm,
              textInputAction: TextInputAction.next,
            ),
            MkTextField(
              controller: _vehicle,
              label: l10n.lotVehicle,
              textInputAction: TextInputAction.next,
            ),
          ),
          gap,
          MkTextField(controller: _notes, label: l10n.lotNotes, maxLines: 2),
          if (_problems.contains(LotProblem.netNotPositive)) ...[
            gap,
            Text(
              l10n.lotProblemNetNotPositive,
              style: TextStyle(color: MkTokens.of(context).udhaar),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.complete,
    required this.saving,
    required this.onSave,
    required this.onSaveNew,
    required this.onHold,
    required this.onCancel,
  });

  final bool complete;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onSaveNew;
  final VoidCallback onHold;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MkSpacing.md),
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: MkSpacing.sm,
          runSpacing: MkSpacing.sm,
          children: [
            MkButton(
              label: l10n.commonCancel,
              variant: MkButtonVariant.ghost,
              onPressed: onCancel,
            ),
            if (complete)
              MkButton(
                key: const ValueKey('lot-hold'),
                label: l10n.lotHold,
                variant: MkButtonVariant.secondary,
                onPressed: saving ? null : onHold,
              ),
            MkButton(
              key: const ValueKey('lot-save-new'),
              label: l10n.lotSaveNew,
              variant: MkButtonVariant.secondary,
              onPressed: saving ? null : onSaveNew,
            ),
            MkButton(
              key: const ValueKey('lot-save'),
              label: complete ? l10n.lotSavePost : l10n.lotSave,
              icon: complete ? Icons.check : Icons.save_outlined,
              busy: saving,
              onPressed: saving ? null : onSave,
            ),
          ],
        ),
      ),
    );
  }
}
