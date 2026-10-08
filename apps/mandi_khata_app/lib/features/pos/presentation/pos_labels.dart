import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/pos/domain/pos_cart.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

extension PosLabels on AppLocalizations {
  /// A tier id in words; the four standard tiers are translated, a custom
  /// one is shown as written.
  String tierName(String tier) => switch (tier) {
    'farmer' => posTierFarmer,
    'retail' => posTierRetail,
    'vendor' => posTierVendor,
    'wholesale' => posTierWholesale,
    _ => tier.isEmpty ? tier : tier[0].toUpperCase() + tier.substring(1),
  };

  String saleProblem(SaleProblem p) => switch (p) {
    SaleProblem.noLines => posErrorNoLines,
    SaleProblem.badQuantity ||
    SaleProblem.badPrice ||
    SaleProblem.badDiscount => posErrorBadLine,
    SaleProblem.productMissing => posErrorProductGone,
    SaleProblem.paymentMismatch ||
    SaleProblem.negativePayment => posErrorPayMismatch,
    SaleProblem.udhaarNeedsParty => posErrorUdhaarParty,
    SaleProblem.upiNeedsAccount => posErrorUpiAccount,
  };

  /// A message for a failed save, or null when it saved. [names] maps a
  /// product id to its name for stock messages.
  String? saleSaveError(SaleSaveResult r, Map<String, String> names) =>
      switch (r) {
        SaleSaved() => null,
        SaleNotPermitted(lockedYear: true) => yearLockedError,
        SaleNotPermitted(:final backdateDays?) => khataErrorBackdated(
          backdateDays,
        ),
        SaleNotPermitted() => posErrorNotPermitted,
        SaleInvalid(:final problems) => [
          for (final p in problems) saleProblem(p),
        ].join('\n'),
        SaleStockRefused(:final issues) => [
          for (final i in issues)
            switch (i.error) {
              StockErrorKind.insufficientStock => posErrorStock(
                names[i.productId] ?? '',
              ),
              StockErrorKind.expiredBlocked => posErrorExpired(
                names[i.productId] ?? '',
              ),
            },
        ].join('\n'),
        SaleNotFound() => salesNotFound,
        SaleLocked() => salesReverseLocked,
      };

  String? stockWarning(StockWarningKind k) => switch (k) {
    StockWarningKind.expiredSold => posWarnExpiredSold,
    StockWarningKind.negativeStock => posWarnNegative,
    StockWarningKind.nearExpiry => posWarnNearExpiry,
  };

  String? returnError(ReturnSaveResult r) => switch (r) {
    ReturnSaved() => null,
    ReturnNotPermitted(lockedYear: true) => yearLockedError,
    ReturnNotPermitted(:final backdateDays?) => khataErrorBackdated(
      backdateDays,
    ),
    ReturnNotPermitted() => salesReturnErrNotPermitted,
    ReturnInvalid(:final problems) => [
      for (final p in problems)
        switch (p) {
          ReturnProblem.noItems => salesReturnErrNoItems,
          ReturnProblem.badQuantity => salesReturnErrQty,
          ReturnProblem.noParty => salesReturnErrParty,
          ReturnProblem.upiNeedsAccount => salesReturnErrUpi,
        },
    ].join('\n'),
    ReturnNotFound() => salesNotFound,
    ReturnLocked() => salesReverseLocked,
  };

  /// Stock left of [p] as text with its unit, e.g. "12 bag".
  String stockText(PosProduct p, {required bool blockExpired}) => posStockLeft(
    '${Qty.format(p.sellableMilli(blockExpired: blockExpired))} ${p.unit}',
  );
}
