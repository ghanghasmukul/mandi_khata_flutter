abstract final class ProductRoutes {
  static const list = '/shop/products';
  static const create = '/shop/products/new';
  static const import = '/shop/products/import';
  static String edit(String id) => '/shop/products/$id';
  static String batch(String productId, String batchId) =>
      '/shop/products/$productId/batch/$batchId';
}
