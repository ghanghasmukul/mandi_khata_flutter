import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_providers.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_widgets.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Step 1: name, GSTIN, phone, address of the business.
class BusinessStep extends ConsumerStatefulWidget {
  const BusinessStep({required this.step, super.key});

  final StepContext step;

  @override
  ConsumerState<BusinessStep> createState() => _BusinessStepState();
}

class _BusinessStepState extends ConsumerState<BusinessStep> {
  late final TextEditingController _name;
  late final TextEditingController _legal;
  late final TextEditingController _gstin;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  Map<BusinessField, FieldProblem> _problems = const {};
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final t = ref.read(tenantRowProvider).value ?? const {};
    String text(String k) => (t[k] as String?) ?? '';
    _name = TextEditingController(text: text('name'));
    _legal = TextEditingController(text: text('legal_name'));
    _gstin = TextEditingController(text: text('gstin'));
    _phone = TextEditingController(text: text('phone'));
    _address = TextEditingController(text: text('address'));
  }

  @override
  void dispose() {
    _name.dispose();
    _legal.dispose();
    _gstin.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final l10n = AppLocalizations.of(context);
    final details = BusinessDetails(
      name: _name.text,
      legalName: _legal.text,
      gstin: _gstin.text,
      address: _address.text,
      phone: _phone.text,
    );
    final problems = details.validate();
    if (problems.isNotEmpty) {
      setState(() {
        _problems = problems;
        _error = null;
      });
      return;
    }
    setState(() {
      _problems = const {};
      _busy = true;
      _error = null;
    });
    final failure = await ref
        .read(onboardingActionsProvider)
        .saveBusiness(details.columns());
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _busy = false;
        _error = l10n.onboardingFailure(failure);
      });
      return;
    }
    await widget.step.onNext();
  }

  String? _problemText(AppLocalizations l10n, BusinessField f) =>
      switch (_problems[f]) {
        FieldProblem.required => l10n.partyErrorRequired,
        FieldProblem.invalid => switch (f) {
          BusinessField.gstin => l10n.onboardingGstinInvalid,
          _ => l10n.onboardingPhoneInvalid,
        },
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StepFrame(
      title: l10n.onboardingBusinessTitle,
      subtitle: l10n.onboardingBusinessHint,
      busy: _busy,
      error: _error,
      onBack: widget.step.onBack,
      onNext: _next,
      children: [
        MkTextField(
          key: const ValueKey('biz-name'),
          controller: _name,
          label: l10n.onboardingBusinessName,
          errorText: _problemText(l10n, BusinessField.name),
          autofocus: true,
          textInputAction: TextInputAction.next,
        ),
        fieldGap,
        MkTextField(
          key: const ValueKey('biz-legal'),
          controller: _legal,
          label: l10n.onboardingLegalName,
          textInputAction: TextInputAction.next,
        ),
        fieldGap,
        MkTextField(
          key: const ValueKey('biz-gstin'),
          controller: _gstin,
          label: l10n.onboardingGstin,
          hint: '03AAAAA0000A1Z5',
          errorText: _problemText(l10n, BusinessField.gstin),
          textInputAction: TextInputAction.next,
        ),
        fieldGap,
        MkTextField(
          key: const ValueKey('biz-phone'),
          controller: _phone,
          label: l10n.onboardingPhone,
          hint: '98140 22110',
          keyboardType: TextInputType.phone,
          errorText: _problemText(l10n, BusinessField.phone),
          textInputAction: TextInputAction.next,
        ),
        fieldGap,
        MkTextField(
          key: const ValueKey('biz-address'),
          controller: _address,
          label: l10n.onboardingAddress,
          maxLines: 2,
        ),
      ],
    );
  }
}

/// Step 2: state and mandi.
class MandiStep extends ConsumerStatefulWidget {
  const MandiStep({required this.step, super.key});

  final StepContext step;

  @override
  ConsumerState<MandiStep> createState() => _MandiStepState();
}

class _MandiStepState extends ConsumerState<MandiStep> {
  late final TextEditingController _mandi;
  String? _state;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final t = ref.read(tenantRowProvider).value ?? const {};
    _mandi = TextEditingController(text: (t['mandi_name'] as String?) ?? '');
    _state = t['state_code'] as String?;
  }

  @override
  void dispose() {
    _mandi.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final mandi = _mandi.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final failure = await ref.read(onboardingActionsProvider).saveBusiness({
      'state_code': _state,
      'mandi_name': mandi.isEmpty ? null : mandi,
    });
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _busy = false;
        _error = l10n.onboardingFailure(failure);
      });
      return;
    }
    await widget.step.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return StepFrame(
      title: l10n.onboardingMandiTitle,
      subtitle: l10n.onboardingMandiHint,
      busy: _busy,
      error: _error,
      onBack: widget.step.onBack,
      onNext: _next,
      children: [
        DropdownMenu<String?>(
          key: const ValueKey('mandi-state'),
          label: Text(l10n.onboardingState),
          initialSelection: _state,
          expandedInsets: EdgeInsets.zero,
          onSelected: (v) => setState(() => _state = v),
          dropdownMenuEntries: [
            for (final s in OnboardingRules.states)
              DropdownMenuEntry(value: s.code, label: s.nameIn(lang)),
            DropdownMenuEntry(value: null, label: l10n.onboardingStateOther),
          ],
        ),
        fieldGap,
        MkTextField(
          key: const ValueKey('mandi-name'),
          controller: _mandi,
          label: l10n.onboardingMandiName,
          hint: l10n.onboardingMandiNameHint,
          onSubmitted: (_) => _next(),
        ),
      ],
    );
  }
}

/// Step 3: which crops the business deals in.
class CropsStep extends ConsumerStatefulWidget {
  const CropsStep({required this.step, super.key});

  final StepContext step;

  @override
  ConsumerState<CropsStep> createState() => _CropsStepState();
}

class _CropsStepState extends ConsumerState<CropsStep> {
  Set<String>? _chosen;
  String? _error;
  bool _busy = false;

  Future<void> _next() async {
    final l10n = AppLocalizations.of(context);
    final chosen = _chosen;
    if (chosen == null) return;
    final all = ref.read(cropListProvider(includeInactive: true)).value;
    if (all != null && all.isEmpty) {
      // Nothing to choose from (crops not synced yet): do not trap the
      // owner in the wizard.
      await widget.step.onNext();
      return;
    }
    if (chosen.isEmpty) {
      setState(() => _error = l10n.onboardingCropsNone);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final failure = await ref.read(onboardingActionsProvider).saveCrops(chosen);
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _busy = false;
        _error = l10n.onboardingFailure(failure);
      });
      return;
    }
    await widget.step.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final crops = ref.watch(cropListProvider(includeInactive: true)).value;
    final chosen = _chosen ??= crops == null
        ? null
        : {
            for (final c in crops)
              if (c.isActive) c.id,
          };
    return StepFrame(
      title: l10n.onboardingCropsTitle,
      subtitle: l10n.onboardingCropsHint,
      busy: _busy,
      error: _error,
      onBack: widget.step.onBack,
      onNext: chosen == null ? null : _next,
      children: [
        if (crops == null || chosen == null)
          const Center(child: CircularProgressIndicator())
        else if (crops.isEmpty)
          Text(l10n.onboardingCropsEmpty, key: const ValueKey('crops-empty'))
        else ...[
          Wrap(
            spacing: MkSpacing.sm,
            children: [
              TextButton(
                key: const ValueKey('crops-all'),
                onPressed: () =>
                    setState(() => _chosen = {for (final c in crops) c.id}),
                child: Text(l10n.onboardingSelectAll),
              ),
              TextButton(
                key: const ValueKey('crops-none'),
                onPressed: () => setState(() => _chosen = <String>{}),
                child: Text(l10n.onboardingSelectNone),
              ),
            ],
          ),
          for (final c in crops)
            CheckboxListTile(
              key: ValueKey('crop-${c.code}'),
              value: chosen.contains(c.id),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(c.nameIn(lang)),
              onChanged: (v) => setState(() {
                if (v ?? false) {
                  chosen.add(c.id);
                } else {
                  chosen.remove(c.id);
                }
                _error = null;
              }),
            ),
        ],
      ],
    );
  }
}
