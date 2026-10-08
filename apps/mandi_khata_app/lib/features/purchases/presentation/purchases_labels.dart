import 'package:mandi_khata_app/features/purchases/domain/purchase.dart';
import 'package:mandi_khata_app/features/team/presentation/team_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

abstract final class PurchaseRoutes {
  static const list = '/shop/purchases';
  static const create = '/shop/purchases/new';
  static String detail(String id) => '/shop/purchases/$id';
}

extension PurchasesLabels on AppLocalizations {
  /// Why a save / reversal / return failed; null when it worked.
  String? purchaseResult(PurchaseResult r) => switch (r) {
    PurchaseSaved() => null,
    PurchaseInvalid(:final problems) =>
      problems.map(_problem).toSet().join('\n'),
    PurchaseReturnInvalid() => purchaseErrReturn,
    PurchaseNotPermitted(lockedYear: true) => yearLockedError,
    PurchaseNotPermitted(:final backdateDays?) => khataErrorBackdated(
      backdateDays,
    ),
    PurchaseNotPermitted(:final permission) => acctNeedsPermission(
      permissionName(permission),
    ),
    PurchaseNotFound() => purchaseNotFound,
    PurchaseLocked() => purchaseLocked,
    PurchaseInUse() => purchaseInUse,
  };

  String _problem(PurchaseProblem p) => switch (p) {
    PurchaseProblem.noSupplier => purchaseErrNoSupplier,
    PurchaseProblem.notASupplier => purchaseErrNotSupplier,
    PurchaseProblem.unknownProduct => purchaseErrProduct,
    PurchaseProblem.noLines => purchaseNoLines,
    PurchaseProblem.negativePaid ||
    PurchaseProblem.paidAboveTotal => purchaseErrPaid,
    PurchaseProblem.noBankAccount => purchaseErrBank,
    PurchaseProblem.badLine ||
    PurchaseProblem.noBatchNo ||
    PurchaseProblem.badDates ||
    PurchaseProblem.negativeCharges => purchaseErrInvalid,
  };
}
