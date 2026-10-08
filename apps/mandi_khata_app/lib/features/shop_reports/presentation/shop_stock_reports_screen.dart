import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_table_view.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/shop_report_tables.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_report_frame.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_report_titles.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_reports_providers.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Batches that expired or expire within 30 / 60 / 90 days, with the stock
/// value at cost (only for members who may see shop profit).
class ShopExpiryScreen extends ConsumerWidget {
  const ShopExpiryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final title = shopReportTitles(l10n);
    final withCost = ref.watch(canProvider(Permission.shopViewProfit));
    final today = shopToday();
    final all = ref.watch(expiryRowsProvider(today)).value;
    final rows = all
        ?.where((r) => r.bucket != ExpiryBucket.later)
        .toList(growable: false);
    final t = rows == null
        ? null
        : ShopReportTables.expiry(rows, withCost: withCost, title: title);
    final byBucket = rows == null ? null : ExpiryReport.valueByBucket(rows);
    return ShopReportFrame(
      title: l10n.shrExpiryTitle,
      route: ShopReportRoutes.expiry,
      controls: [
        ShopExportBar(
          title: l10n.shrExpiryTitle,
          fileStem: 'expiry-$today',
          table: t,
          permission: Permission.financeView,
        ),
      ],
      body: t == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (withCost && byBucket != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MkSpacing.md,
                    ),
                    child: Wrap(
                      spacing: MkSpacing.md,
                      runSpacing: MkSpacing.sm,
                      children: [
                        for (final b in ExpiryBucket.values)
                          if (b != ExpiryBucket.later)
                            Chip(
                              key: ValueKey('bucket-${b.name}'),
                              label: Text(
                                '${ShopReportTables.bucketTitle(b, title)}: '
                                '${byBucket[b]!.format()}',
                              ),
                            ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MkSpacing.md,
                    ),
                    child: Text(l10n.shrExpiryValueHidden),
                  ),
                Expanded(
                  child: t.rows.isEmpty
                      ? MkEmptyState(title: l10n.shrNoExpiry)
                      : ReportTableView(table: t),
                ),
              ],
            ),
    );
  }
}

/// Products at or below their reorder level or running out soon, with the
/// suggested purchase quantity.
class ShopReorderScreen extends ConsumerWidget {
  const ShopReorderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final title = shopReportTitles(l10n);
    final today = shopToday();
    final rows = ref.watch(reorderSuggestionsProvider(today)).value;
    final t = rows == null
        ? null
        : ShopReportTables.reorder(rows, title: title);
    return ShopReportFrame(
      title: l10n.shrReorderTitle,
      route: ShopReportRoutes.reorder,
      controls: [
        ShopExportBar(
          title: l10n.shrReorderTitle,
          fileStem: 'reorder-$today',
          table: t,
          permission: Permission.financeView,
        ),
      ],
      body: t == null
          ? const Center(child: CircularProgressIndicator())
          : t.rows.isEmpty
          ? MkEmptyState(title: l10n.shrNoReorder)
          : ReportTableView(table: t),
    );
  }
}
