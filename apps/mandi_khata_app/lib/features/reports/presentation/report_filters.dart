import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:mandi_khata_app/features/reports/presentation/reports_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/date_range_chips.dart';
import 'package:mk_ui/mk_ui.dart';

/// The filters of one report; each report shows the ones that apply.
class ReportFilters extends ConsumerWidget {
  const ReportFilters({
    required this.kind,
    required this.filter,
    required this.today,
    required this.onChanged,
    super.key,
  });

  final ReportKind kind;
  final ReportFilter filter;
  final LedgerDate today;
  final ValueChanged<ReportFilter> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;

    Widget range() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DateRangeChips(
        from: filter.from,
        to: filter.to,
        keyPrefix: 'report',
        onChanged: (f, t) =>
            onChanged(filter.copyWith(from: () => f, to: () => t)),
      ),
    );

    final crops =
        ref.watch(cropListProvider(includeInactive: true)).value ?? <Crop>[];
    final villages = ref.watch(farmerVillagesProvider).value ?? <String>[];

    final children = switch (kind) {
      ReportKind.outstanding => [
        OutlinedButton.icon(
          key: const ValueKey('report-asof'),
          icon: const Icon(Icons.event_outlined),
          label: Text(
            '${l10n.reportFilterAsOf}: '
            '${AppFormat.ledgerDate(context, filter.asOf ?? today)}',
          ),
          onPressed: () async {
            final d = filter.asOf ?? today;
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(d.year, d.month, d.day),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onChanged(
                filter.copyWith(asOf: () => LedgerDate.fromDateTime(picked)),
              );
            }
          },
        ),
        for (final (s, label) in [
          (OutstandingSide.all, l10n.reportSideAll),
          (OutstandingSide.payable, l10n.reportSidePayable),
          (OutstandingSide.receivable, l10n.reportSideReceivable),
        ])
          ChoiceChip(
            key: ValueKey('report-side-${s.name}'),
            label: Text(label),
            selected: filter.side == s,
            onSelected: (_) => onChanged(filter.copyWith(side: s)),
          ),
      ],
      ReportKind.arrivals => [
        range(),
        DropdownButton<String?>(
          key: const ValueKey('report-crop'),
          value: filter.cropId,
          items: [
            DropdownMenuItem(child: Text(l10n.reportFilterAllCrops)),
            for (final c in crops)
              DropdownMenuItem(value: c.id, child: Text(c.nameIn(language))),
          ],
          onChanged: (id) => onChanged(filter.copyWith(cropId: () => id)),
        ),
      ],
      ReportKind.commission => [range()],
      ReportKind.payments => [
        range(),
        DropdownButton<PaymentMode?>(
          key: const ValueKey('report-mode'),
          value: filter.mode,
          items: [
            DropdownMenuItem(child: Text(l10n.reportFilterAllModes)),
            for (final m in PaymentMode.values)
              DropdownMenuItem(value: m, child: Text(l10n.paymentModeName(m))),
          ],
          onChanged: (m) => onChanged(filter.copyWith(mode: () => m)),
        ),
      ],
      ReportKind.statements => [
        range(),
        DropdownButton<String?>(
          key: const ValueKey('report-village'),
          value: filter.village,
          items: [
            DropdownMenuItem(child: Text(l10n.reportFilterAllVillages)),
            for (final v in villages)
              DropdownMenuItem(value: v, child: Text(v)),
          ],
          onChanged: (v) => onChanged(filter.copyWith(village: () => v)),
        ),
      ],
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MkSpacing.lg,
        vertical: MkSpacing.sm,
      ),
      child: Wrap(
        spacing: MkSpacing.md,
        runSpacing: MkSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}
