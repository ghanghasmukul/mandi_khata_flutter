import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_providers.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_widgets.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

Object? _resolved(WidgetRef ref, String key) =>
    ref.read(settingsResolverProvider(businessTarget))?.resolve(key).value;

String _percent(Object? v) => v?.toString() ?? '';

String _rupees(Object? paise) =>
    paise is int ? Money(paise).format(symbol: false) : '';

/// Step 4: default commission and charges (business level of the cascade;
/// each crop and party can still override them).
class ChargesStep extends ConsumerStatefulWidget {
  const ChargesStep({required this.step, super.key});

  final StepContext step;

  @override
  ConsumerState<ChargesStep> createState() => _ChargesStepState();
}

class _ChargesStepState extends ConsumerState<ChargesStep> {
  late final Map<String, TextEditingController> _c;
  Set<String> _problems = const {};
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _c = {
      'mandi.commission_pct': TextEditingController(
        text: _percent(_resolved(ref, 'mandi.commission_pct')),
      ),
      'mandi.palledari_per_bag': TextEditingController(
        text: _rupees(_resolved(ref, 'mandi.palledari_per_bag')),
      ),
      'mandi.bardana_per_bag': TextEditingController(
        text: _rupees(_resolved(ref, 'mandi.bardana_per_bag')),
      ),
      'mandi.tulai_per_qtl': TextEditingController(
        text: _rupees(_resolved(ref, 'mandi.tulai_per_qtl')),
      ),
      'mandi.mandi_fee_pct': TextEditingController(
        text: _percent(_resolved(ref, 'mandi.mandi_fee_pct')),
      ),
      'mandi.bag_weight_kg': TextEditingController(
        text: _percent(_resolved(ref, 'mandi.bag_weight_kg')),
      ),
    };
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _next() async {
    final l10n = AppLocalizations.of(context);
    String t(String key) => _c[key]!.text;
    final parsed = ChargeDefaults(
      commissionPct: t('mandi.commission_pct'),
      palledariPerBag: t('mandi.palledari_per_bag'),
      bardanaPerBag: t('mandi.bardana_per_bag'),
      tulaiPerQtl: t('mandi.tulai_per_qtl'),
      mandiFeePct: t('mandi.mandi_fee_pct'),
      bagWeightKg: t('mandi.bag_weight_kg'),
    ).toSettings();
    if (parsed.problems.isNotEmpty) {
      setState(() {
        _problems = parsed.problems;
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
        .saveSettings(parsed.values);
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _busy = false;
        _error = l10n.onboardingErrNotPermitted;
      });
      return;
    }
    await widget.step.onNext();
  }

  Widget _field(
    String key, {
    required String label,
    required String prefix,
    required bool last,
  }) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: MkSpacing.md),
      child: MkTextField(
        key: ValueKey('charge-$key'),
        controller: _c[key],
        label: label,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 12, right: 6),
          child: Center(widthFactor: 1, child: Text(prefix)),
        ),
        errorText: _problems.contains(key)
            ? l10n.onboardingNumberInvalid
            : null,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onSubmitted: last ? (_) => _next() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StepFrame(
      title: l10n.onboardingChargesTitle,
      subtitle: l10n.onboardingChargesHint,
      busy: _busy,
      error: _error,
      onBack: widget.step.onBack,
      onNext: _next,
      children: [
        _field(
          'mandi.commission_pct',
          label: l10n.settingLabel('mandi.commission_pct'),
          prefix: '%',
          last: false,
        ),
        _field(
          'mandi.palledari_per_bag',
          label: l10n.settingLabel('mandi.palledari_per_bag'),
          prefix: '₹',
          last: false,
        ),
        _field(
          'mandi.bardana_per_bag',
          label: l10n.settingLabel('mandi.bardana_per_bag'),
          prefix: '₹',
          last: false,
        ),
        _field(
          'mandi.tulai_per_qtl',
          label: l10n.settingLabel('mandi.tulai_per_qtl'),
          prefix: '₹',
          last: false,
        ),
        _field(
          'mandi.mandi_fee_pct',
          label: l10n.settingLabel('mandi.mandi_fee_pct'),
          prefix: '%',
          last: false,
        ),
        _field(
          'mandi.bag_weight_kg',
          label: l10n.settingLabel('mandi.bag_weight_kg'),
          prefix: 'kg',
          last: true,
        ),
        Text(
          l10n.onboardingChargesCascade,
          style: TextStyle(color: MkTokens.of(context).textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

/// Step 5: interest defaults. Stored only; the engine arrives in Phase 2.
class InterestStep extends ConsumerStatefulWidget {
  const InterestStep({required this.step, super.key});

  final StepContext step;

  @override
  ConsumerState<InterestStep> createState() => _InterestStepState();
}

class _InterestStepState extends ConsumerState<InterestStep> {
  late final TextEditingController _rate;
  late bool _enabled;
  late bool _perMonth;
  late String _method;
  late String _compounding;
  bool _rateInvalid = false;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _enabled = _resolved(ref, 'interest.enabled') == true;
    _perMonth =
        _resolved(ref, 'interest.rate_unit_display') == 'per100_per_month';
    _method = (_resolved(ref, 'interest.method') as String?) ?? 'simple';
    _compounding =
        (_resolved(ref, 'interest.compounding') as String?) ?? 'quarterly';
    final pa = SettingsSchema.decimalOf(_resolved(ref, 'interest.rate_pa'));
    _rate = TextEditingController(
      text: pa == null
          ? ''
          : (_perMonth ? InterestRate.per100PerMonthFromPa(pa) : pa).toString(),
    );
  }

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  /// Changing the unit converts what is typed, so 18 % a year reads 1.5.
  void _setUnit(bool perMonth) {
    if (perMonth == _perMonth) return;
    final typed = Decimal.tryParse(_rate.text.trim());
    if (typed != null) {
      final converted = perMonth
          ? InterestRate.per100PerMonthFromPa(typed)
          : InterestRate.paFromPer100PerMonth(typed);
      _rate.text = converted.toString();
    }
    setState(() => _perMonth = perMonth);
  }

  Future<void> _next() async {
    final l10n = AppLocalizations.of(context);
    final parsed = InterestDefaults(
      enabled: _enabled,
      rate: _rate.text,
      perHundredPerMonth: _perMonth,
      method: _method,
      compounding: _compounding,
    ).toSettings();
    if (parsed.problems.isNotEmpty) {
      setState(() {
        _rateInvalid = true;
        _error = null;
      });
      return;
    }
    setState(() {
      _rateInvalid = false;
      _busy = true;
      _error = null;
    });
    final failure = await ref
        .read(onboardingActionsProvider)
        .saveSettings(parsed.values);
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _busy = false;
        _error = l10n.onboardingErrNotPermitted;
      });
      return;
    }
    await widget.step.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StepFrame(
      title: l10n.onboardingInterestTitle,
      subtitle: l10n.onboardingInterestHint,
      busy: _busy,
      error: _error,
      onBack: widget.step.onBack,
      onNext: _next,
      children: [
        SwitchListTile(
          key: const ValueKey('interest-enabled'),
          contentPadding: EdgeInsets.zero,
          value: _enabled,
          title: Text(l10n.settingLabel('interest.enabled')),
          onChanged: (v) => setState(() => _enabled = v),
        ),
        fieldGap,
        Wrap(
          spacing: MkSpacing.sm,
          children: [
            ChoiceChip(
              key: const ValueKey('interest-unit-pa'),
              label: Text(
                l10n.settingOption('interest.rate_unit_display', 'pa'),
              ),
              selected: !_perMonth,
              onSelected: (_) => _setUnit(false),
            ),
            ChoiceChip(
              key: const ValueKey('interest-unit-month'),
              label: Text(
                l10n.settingOption(
                  'interest.rate_unit_display',
                  'per100_per_month',
                ),
              ),
              selected: _perMonth,
              onSelected: (_) => _setUnit(true),
            ),
          ],
        ),
        fieldGap,
        MkTextField(
          key: const ValueKey('interest-rate'),
          controller: _rate,
          // The label follows the unit: "(% per year)" above a per-month
          // field misled owners (step 1.9 gap).
          label: _perMonth
              ? l10n.onboardingInterestRatePerMonthLabel
              : l10n.settingLabel('interest.rate_pa'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 12, right: 6),
            child: Center(widthFactor: 1, child: Text(_perMonth ? '₹' : '%')),
          ),
          errorText: _rateInvalid ? l10n.onboardingNumberInvalid : null,
        ),
        fieldGap,
        Wrap(
          spacing: MkSpacing.sm,
          children: [
            for (final m in const ['simple', 'compound'])
              ChoiceChip(
                key: ValueKey('interest-method-$m'),
                label: Text(l10n.settingOption('interest.method', m)),
                selected: _method == m,
                onSelected: (_) => setState(() => _method = m),
              ),
          ],
        ),
        if (_method == 'compound') ...[
          fieldGap,
          DropdownMenu<String>(
            key: const ValueKey('interest-compounding'),
            label: Text(l10n.settingLabel('interest.compounding')),
            initialSelection: _compounding,
            expandedInsets: EdgeInsets.zero,
            onSelected: (v) => setState(() => _compounding = v ?? _compounding),
            dropdownMenuEntries: [
              for (final o in const [
                'monthly',
                'quarterly',
                'halfyearly',
                'yearly',
                'on_fy_close',
              ])
                DropdownMenuEntry(
                  value: o,
                  label: l10n.settingOption('interest.compounding', o),
                ),
            ],
          ),
        ],
        fieldGap,
        Text(
          l10n.onboardingInterestStoredOnly,
          style: TextStyle(color: MkTokens.of(context).textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
