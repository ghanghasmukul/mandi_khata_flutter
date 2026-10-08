import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/accounts/presentation/statement_page.dart';
import 'package:mandi_khata_app/features/reports/presentation/report_table_view.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/shop_report_tables.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_report_frame.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_report_titles.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_reports_providers.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

enum ProfitGrouping { product, category, month }

/// Shop profit by product, category or month (step 4.5). Needs
/// `shop.view_profit`: it shows cost prices.
class ShopProfitScreen extends ConsumerStatefulWidget {
  const ShopProfitScreen({super.key});

  @override
  ConsumerState<ShopProfitScreen> createState() => _ShopProfitState();
}

class _ShopProfitState extends ConsumerState<ShopProfitScreen> {
  LedgerDate _from = FinancialYear.containing(shopToday()).start;
  LedgerDate _to = shopToday();
  ProfitGrouping _by = ProfitGrouping.product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allowed = ref.watch(canProvider(Permission.shopViewProfit));
    final title = shopReportTitles(l10n);
    ReportTable? table;
    if (allowed) {
      final records = ref.watch(profitRecordsProvider(_from, _to)).value;
      if (records != null) {
        final rows = switch (_by) {
          ProfitGrouping.product => ShopProfit.byProduct(records),
          ProfitGrouping.category => ShopProfit.byCategory(
            records,
            uncategorised: l10n.shrUncategorised,
          ),
          ProfitGrouping.month => ShopProfit.byMonth(records),
        };
        table = ShopReportTables.units(
          ShopProfit.table(
            rows,
            keyTitle: switch (_by) {
              ProfitGrouping.product => 'Product',
              ProfitGrouping.category => l10n.shrByCategory,
              ProfitGrouping.month => l10n.shrByMonth,
            },
            title: title,
          ),
        );
      }
    }
    final t = table;
    return ShopReportFrame(
      title: l10n.shrProfitTitle,
      route: ShopReportRoutes.profit,
      controls: allowed
          ? [
              PeriodChips(
                from: _from,
                to: _to,
                onChanged: (f, t) => setState(() {
                  _from = f;
                  _to = t;
                }),
              ),
              SegmentedButton<ProfitGrouping>(
                key: const ValueKey('profit-grouping'),
                segments: [
                  ButtonSegment(
                    value: ProfitGrouping.product,
                    label: Text(l10n.shrByProduct),
                  ),
                  ButtonSegment(
                    value: ProfitGrouping.category,
                    label: Text(l10n.shrByCategory),
                  ),
                  ButtonSegment(
                    value: ProfitGrouping.month,
                    label: Text(l10n.shrByMonth),
                  ),
                ],
                selected: {_by},
                onSelectionChanged: (s) => setState(() => _by = s.first),
              ),
              ShopExportBar(
                title: l10n.shrProfitTitle,
                fileStem: 'shop-profit-${_by.name}-$_from-$_to',
                table: t,
                permission: Permission.shopViewProfit,
                filterLines: ['$_from – $_to'],
              ),
            ]
          : const [],
      body: !allowed
          ? MkEmptyState(
              key: const ValueKey('profit-locked'),
              title: l10n.shrProfitTitle,
              message: l10n.shrProfitLocked,
              icon: Icons.lock_outline,
            )
          : t == null
          ? const Center(child: CircularProgressIndicator())
          : t.rows.isEmpty
          ? MkEmptyState(title: l10n.shrNoSales)
          : ReportTableView(table: t),
    );
  }
}
