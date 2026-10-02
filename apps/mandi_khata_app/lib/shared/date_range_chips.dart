import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

enum _DateRange { today, yesterday, week, all, custom }

/// Today / yesterday / last 7 days / all / custom range chips. Both null =
/// all dates. Chip keys are `<keyPrefix>-range-<name>`.
class DateRangeChips extends StatelessWidget {
  const DateRangeChips({
    required this.from,
    required this.to,
    required this.onChanged,
    required this.keyPrefix,
    super.key,
  });

  final LedgerDate? from;
  final LedgerDate? to;
  final void Function(LedgerDate? from, LedgerDate? to) onChanged;
  final String keyPrefix;

  static LedgerDate _day(int daysAgo) =>
      LedgerDate.fromDateTime(DateTime.now()).addDays(-daysAgo);

  _DateRange get _range {
    if (from == null && to == null) return _DateRange.all;
    if (from == _day(0) && to == _day(0)) return _DateRange.today;
    if (from == _day(1) && to == _day(1)) return _DateRange.yesterday;
    if (from == _day(6) && to == _day(0)) return _DateRange.week;
    return _DateRange.custom;
  }

  Future<void> _pick(BuildContext context) async {
    DateTime asDate(LedgerDate d) => DateTime(d.year, d.month, d.day);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: from == null || to == null
          ? null
          : DateTimeRange(start: asDate(from!), end: asDate(to!)),
    );
    if (picked != null) {
      onChanged(
        LedgerDate.fromDateTime(picked.start),
        LedgerDate.fromDateTime(picked.end),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final range = _range;
    Widget chip(_DateRange r, String label, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(right: MkSpacing.sm),
      child: ChoiceChip(
        key: ValueKey('$keyPrefix-range-${r.name}'),
        label: Text(label),
        selected: range == r,
        onSelected: (_) => onTap(),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip(
          _DateRange.today,
          l10n.rangeToday,
          () => onChanged(_day(0), _day(0)),
        ),
        chip(
          _DateRange.yesterday,
          l10n.rangeYesterday,
          () => onChanged(_day(1), _day(1)),
        ),
        chip(
          _DateRange.week,
          l10n.rangeWeek,
          () => onChanged(_day(6), _day(0)),
        ),
        chip(_DateRange.all, l10n.rangeAll, () => onChanged(null, null)),
        chip(
          _DateRange.custom,
          range == _DateRange.custom
              ? '${from == null ? '…' : AppFormat.ledgerDate(context, from!)}'
                    ' – '
                    '${to == null ? '…' : AppFormat.ledgerDate(context, to!)}'
              : l10n.rangeCustom,
          () => _pick(context),
        ),
      ],
    );
  }
}
