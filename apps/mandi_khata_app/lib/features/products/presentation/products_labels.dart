import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/products/data/stock_repository.dart';
import 'package:mandi_khata_app/features/products/domain/opening_stock_import.dart';
import 'package:mandi_khata_app/features/products/domain/product.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

extension ProductLabels on AppLocalizations {
  String productUnit(ProductUnit u) => switch (u) {
    ProductUnit.bag => prodUnitBag,
    ProductUnit.btl => prodUnitBtl,
    ProductUnit.ltr => prodUnitLtr,
    ProductUnit.kg => prodUnitKg,
    ProductUnit.pkt => prodUnitPkt,
    ProductUnit.pc => prodUnitPc,
  };

  String stockReason(StockMovementReason r) => switch (r) {
    StockMovementReason.purchase => prodReasonPurchase,
    StockMovementReason.sale => prodReasonSale,
    StockMovementReason.saleReturn => prodReasonSaleReturn,
    StockMovementReason.purchaseReturn => prodReasonPurchaseReturn,
    StockMovementReason.adjustment => prodReasonAdjustment,
    StockMovementReason.opening => prodReasonOpening,
  };

  String productProblem(ProductProblem p) => switch (p) {
    ProductProblem.nameMissing => prodErrName,
    ProductProblem.skuMissing => prodErrSku,
    ProductProblem.gstRateInvalid => prodErrGst,
    ProductProblem.hsnInvalid => prodErrHsn,
    ProductProblem.reorderInvalid => prodErrReorder,
    ProductProblem.priceInvalid => prodErrPrice,
  };

  String productFailure(ProductResult r) => switch (r) {
    ProductSaved() => prodSaved,
    ProductInvalid(:final problems) => problems.map(productProblem).join('\n'),
    ProductDuplicate(:final field, :final otherName) =>
      field == ProductDuplicateField.sku
          ? prodErrDupSku(otherName)
          : prodErrDupBarcode(otherName),
    ProductNotPermitted() => prodErrNotPermitted,
    ProductNotFound() => prodErrNotFound,
    ProductUnitLocked() => prodErrUnitLocked,
    ProductHasStock() => prodErrHasStock,
  };

  String stockFailure(StockResult r) => switch (r) {
    StockAdjusted() || OpeningStockImported() => prodAdjDone,
    StockInvalid(:final problems) => problems.map(adjustProblem).join('\n'),
    StockNotPermitted(:final lockedYear) =>
      lockedYear ? prodAdjErrLocked : prodErrNotPermitted,
    StockNotFound() => prodErrNotFound,
    StockBatchExists() => prodAdjErrExists,
    OpeningStockAlready() => prodImpAlready,
    OpeningStockInvalid() => prodImpErrorsFound(1),
    OpeningStockStale(:final rowNumber) => prodImpStale(rowNumber),
  };

  String adjustProblem(StockAdjustProblem p) => switch (p) {
    StockAdjustProblem.noteMissing => prodAdjErrNote,
    StockAdjustProblem.zeroQuantity => prodAdjErrZero,
    StockAdjustProblem.wouldGoNegative => prodAdjErrNegative,
    StockAdjustProblem.badDate => prodAdjErrDate,
  };

  String rowProblem(StockRowProblem p) => switch (p) {
    StockRowProblem.unknownProduct => prodImpProbUnknown,
    StockRowProblem.ambiguousProduct => prodImpProbAmbiguous,
    StockRowProblem.qtyInvalid => prodImpProbQty,
    StockRowProblem.costInvalid => prodImpProbCost,
    StockRowProblem.mfgInvalid => prodImpProbMfg,
    StockRowProblem.expiryInvalid => prodImpProbExpiry,
    StockRowProblem.expiryBeforeMfg => prodImpProbExpiryBeforeMfg,
    StockRowProblem.duplicateInFile => prodImpProbDuplicate,
  };

  String sheetProblem(StockSheetProblem p) => switch (p) {
    StockSheetProblem.empty => prodImpSheetEmpty,
    StockSheetProblem.noProductColumn => prodImpNoProductCol,
    StockSheetProblem.noQtyColumn => prodImpNoQtyCol,
    StockSheetProblem.noCostColumn => prodImpNoCostCol,
  };
}

String tierLabel(String tier) =>
    tier.isEmpty ? tier : tier[0].toUpperCase() + tier.substring(1);
