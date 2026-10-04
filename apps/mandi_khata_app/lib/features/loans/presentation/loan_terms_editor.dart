import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/loans/presentation/rate_input.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Edits the interest terms of one loan. Starts from [initial] (the settings
/// cascade for this borrower) and reports every edit as an [InterestConfig],
/// or null while the rate is not valid. The loan snapshots whatever is here.
class LoanTermsEditor extends StatefulWidget {
  const LoanTermsEditor({
    required this.initial,
    required this.onChanged,
    super.key,
    this.perMonthInitially = false,
    this.showRateError = false,
  });

  final InterestConfig initial;
  final bool perMonthInitially;
  final ValueChanged<InterestConfig?> onChanged;

  /// Set after a failed save to flag a missing / invalid rate.
  final bool showRateError;

  @override
  State<LoanTermsEditor> createState() => _LoanTermsEditorState();
}

class _LoanTermsEditorState extends State<LoanTermsEditor> {
  late InterestConfig _config = widget.initial;
  Decimal? _rate;

  @override
  void initState() {
    super.initState();
    _rate = widget.initial.ratePa;
  }

  void _update(InterestConfig Function(InterestConfig) change) {
    setState(() => _config = change(_config));
    _report();
  }

  void _report() {
    final rate = _rate;
    if (!_config.enabled) {
      // The rate is not asked for, so a half-typed one cannot block saving.
      widget.onChanged(_config.copyWith(ratePa: rate ?? widget.initial.ratePa));
      return;
    }
    widget.onChanged(rate == null ? null : _config.copyWith(ratePa: rate));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String opt(String key, String value) => l10n.settingOption(key, value);
    Widget choices<T>(
      String keyPrefix,
      List<T> values,
      T selected,
      String Function(T) label,
      ValueChanged<T> onSelected,
    ) => Wrap(
      spacing: MkSpacing.sm,
      runSpacing: MkSpacing.xs,
      children: [
        for (final v in values)
          ChoiceChip(
            key: ValueKey('$keyPrefix-${v is Enum ? v.name : v}'),
            label: Text(label(v)),
            selected: v == selected,
            onSelected: (_) => onSelected(v),
          ),
      ],
    );
    Widget labelled(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: MkSpacing.xs),
        child,
      ],
    );
    const gap = SizedBox(height: MkSpacing.md);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          key: const ValueKey('terms-enabled'),
          contentPadding: EdgeInsets.zero,
          value: _config.enabled,
          title: Text(l10n.settingInterestEnabled),
          onChanged: (v) => _update((c) => c.copyWith(enabled: v)),
        ),
        if (_config.enabled) ...[
          RateInput(
            initialPa: widget.initial.ratePa,
            initialPerMonth: widget.perMonthInitially,
            errorText: widget.showRateError && _rate == null
                ? l10n.loanErrorRate
                : null,
            onChanged: (pa) {
              setState(() => _rate = pa);
              _report();
            },
          ),
          gap,
          labelled(
            l10n.settingInterestMethod,
            choices<InterestMethod>(
              'terms-method',
              InterestMethod.values,
              _config.method,
              (m) => opt('interest.method', m.name),
              (m) => _update((c) => c.copyWith(method: m)),
            ),
          ),
          if (_config.compounds) ...[
            gap,
            labelled(
              l10n.settingInterestCompounding,
              choices<CompoundingPeriod>(
                'terms-compounding',
                CompoundingPeriod.values,
                _config.compounding,
                (p) => opt('interest.compounding', p.dbName),
                (p) => _update((c) => c.copyWith(compounding: p)),
              ),
            ),
          ],
          gap,
          labelled(
            l10n.settingInterestAppropriation,
            choices<Appropriation>(
              'terms-appropriation',
              Appropriation.values,
              _config.appropriation,
              (a) => opt('interest.appropriation', a.dbName),
              (a) => _update((c) => c.copyWith(appropriation: a)),
            ),
          ),
          gap,
          MkNumberField(
            key: const ValueKey('terms-grace'),
            kind: MkNumberKind.integer,
            label: l10n.settingInterestGraceDays,
            initialValue: _config.graceDays,
            onChanged: (v) =>
                _update((c) => c.copyWith(graceDays: (v ?? 0).clamp(0, 365))),
          ),
          ExpansionTile(
            key: const ValueKey('terms-more'),
            tilePadding: EdgeInsets.zero,
            title: Text(l10n.loanTermsMore),
            children: [
              labelled(
                l10n.settingInterestDayBasis,
                choices<int>(
                  'terms-basis',
                  const [365, 360],
                  _config.dayBasis,
                  (d) => '$d',
                  (d) => _update((c) => c.copyWith(dayBasis: d)),
                ),
              ),
              gap,
              MkNumberField(
                key: const ValueKey('terms-min-days'),
                kind: MkNumberKind.integer,
                label: l10n.settingInterestMinDays,
                initialValue: _config.minDays,
                onChanged: (v) =>
                    _update((c) => c.copyWith(minDays: (v ?? 0).clamp(0, 365))),
              ),
              gap,
              labelled(
                l10n.settingInterestRounding,
                choices<InterestRounding>(
                  'terms-rounding',
                  InterestRounding.values,
                  _config.rounding,
                  (r) => opt('interest.rounding', r.dbName),
                  (r) => _update((c) => c.copyWith(rounding: r)),
                ),
              ),
              gap,
            ],
          ),
        ],
      ],
    );
  }
}
