import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_dues_screen.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_gst_screen.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_profit_screen.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_routes.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_stock_reports_screen.dart';

/// Every report screen under `/shop` (steps 4.4 and 4.5).
List<RouteBase> shopReportRoutes() => [
  GoRoute(
    path: ShopReportRoutes.dues,
    builder: (context, state) => const ShopDuesScreen(),
  ),
  GoRoute(
    path: ShopReportRoutes.profit,
    builder: (context, state) => const ShopProfitScreen(),
  ),
  GoRoute(
    path: ShopReportRoutes.gst,
    builder: (context, state) => const ShopGstScreen(),
  ),
  GoRoute(
    path: ShopReportRoutes.expiry,
    builder: (context, state) => const ShopExpiryScreen(),
  ),
  GoRoute(
    path: ShopReportRoutes.reorder,
    builder: (context, state) => const ShopReorderScreen(),
  ),
];
