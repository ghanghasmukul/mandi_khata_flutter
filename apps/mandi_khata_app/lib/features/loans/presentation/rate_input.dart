import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// An interest rate typed as % a year or as "₹ per 100 per month" (₹1.5 =
/// 18% a year); changing the unit converts what is typed. Reports the rate
/// in % per annum, or null while it is not a valid rate (khata_core
/// `LoanRules.parseRate`: 0 to 100, at most four decimals).
class RateInput extends StatefulWidget {
  const RateInput({
    required this.initialPa,
    required this.onChanged,
    super.key,
    this.initialPerMonth = false,
    this.errorText,
    this.autofocus = false,
    this.fieldKey,
  });

  final Decimal? initialPa;
  final bool initialPerMonth;

  /// % per annum, or null when what is typed is not a valid rate.
  final ValueChanged<Decimal?> onChanged;
  final String? errorText;
  final bool autofocus;
  final Key? fieldKey;

  @override
  State<RateInput> createState() => _RateInputState();
}

class _RateInputState extends State<RateInput> {
  late bool _perMonth = widget.initialPerMonth;
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialPa == null
        ? ''
        : (_perMonth
                  ? InterestRate.per100PerMonthFromPa(widget.initialPa!)
                  : widget.initialPa!)
              .toString(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Decimal? _pa() {
    final typed = Decimal.tryParse(_controller.text.trim());
    if (typed == null) return null;
    final pa = _perMonth ? InterestRate.paFromPer100PerMonth(typed) : typed;
    return LoanRules.parseRate(pa.toString()) == null ? null : pa;
  }

  void _setUnit(bool perMonth) {
    if (perMonth == _perMonth) return;
    final typed = Decimal.tryParse(_controller.text.trim());
    if (typed != null) {
      final converted = perMonth
          ? InterestRate.per100PerMonthFromPa(typed)
          : InterestRate.paFromPer100PerMonth(typed);
      _controller.text = converted.toString();
    }
    setState(() => _perMonth = perMonth);
    widget.onChanged(_pa());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: MkSpacing.sm,
          runSpacing: MkSpacing.xs,
          children: [
            ChoiceChip(
              key: const ValueKey('rate-unit-pa'),
              label: Text(
                l10n.settingOption('interest.rate_unit_display', 'pa'),
              ),
              selected: !_perMonth,
              onSelected: (_) => _setUnit(false),
            ),
            ChoiceChip(
              key: const ValueKey('rate-unit-month'),
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
        const SizedBox(height: MkSpacing.sm),
        MkTextField(
          key: widget.fieldKey ?? const ValueKey('rate-input'),
          controller: _controller,
          label: _perMonth
              ? l10n.onboardingInterestRatePerMonthLabel
              : l10n.settingInterestRatePa,
          autofocus: widget.autofocus,
          errorText: widget.errorText,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,4})?')),
          ],
          onChanged: (_) => widget.onChanged(_pa()),
        ),
      ],
    );
  }
}
