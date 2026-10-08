import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/features/products/presentation/batch_detail_screen.dart';
import 'package:mandi_khata_app/features/products/presentation/product_form_screen.dart';
import 'package:mandi_khata_app/features/products/presentation/products_routes.dart';
import 'package:mandi_khata_app/features/products/presentation/products_screen.dart';
import 'package:mandi_khata_app/features/products/presentation/stock_import_screen.dart';

/// Every screen under `/shop/products` (step 4.1). Fixed paths come before
/// `:id` so "new" and "import" are never read as ids.
List<RouteBase> productRoutes() => [
  GoRoute(
    path: ProductRoutes.list,
    builder: (context, state) => const ProductsScreen(),
  ),
  GoRoute(
    path: ProductRoutes.create,
    builder: (context, state) => const ProductFormScreen(),
  ),
  GoRoute(
    path: ProductRoutes.import,
    builder: (context, state) => const StockImportScreen(),
  ),
  GoRoute(
    path: '${ProductRoutes.list}/:id',
    builder: (context, state) =>
        ProductFormScreen(productId: state.pathParameters['id']),
  ),
  GoRoute(
    path: '${ProductRoutes.list}/:id/batch/:batchId',
    builder: (context, state) => BatchDetailScreen(
      productId: state.pathParameters['id']!,
      batchId: state.pathParameters['batchId']!,
    ),
  ),
];
