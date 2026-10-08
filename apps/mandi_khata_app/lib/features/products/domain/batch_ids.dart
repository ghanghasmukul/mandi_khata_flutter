import 'package:uuid/uuid.dart';

/// Deterministic batch ids: the same (tenant, product, batch no) is the same
/// row on every device, so two offline devices converge instead of hitting
/// the unique (tenant, product, batch_no) constraint on upload.
abstract final class BatchIds {
  static const _ns = '3e7a1c52-90d4-4b68-a2f5-7c1d8e4b6a09';

  static String of(String tenantId, String productId, String batchNo) =>
      const Uuid().v5(_ns, '$tenantId|batch|$productId|$batchNo');
}
