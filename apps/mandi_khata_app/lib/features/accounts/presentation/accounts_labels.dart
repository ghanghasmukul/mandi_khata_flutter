import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/team/presentation/team_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

extension AccountsLabels on AppLocalizations {
  String voucherTypeName(VoucherType t) => switch (t) {
    VoucherType.contra => voucherTypeContra,
    VoucherType.payment => voucherTypePayment,
    VoucherType.receipt => voucherTypeReceipt,
    VoucherType.sales => voucherTypeSales,
    VoucherType.purchase => voucherTypePurchase,
    VoucherType.journal => voucherTypeJournal,
  };

  String voucherProblem(VoucherProblem p) => switch (p) {
    VoucherProblem.tooFewLines => voucherProblemTooFewLines,
    VoucherProblem.amountNotPositive => voucherProblemAmount,
    VoucherProblem.unbalanced => voucherProblemUnbalanced,
    VoucherProblem.duplicateAccount => voucherProblemDuplicate,
    VoucherProblem.inactiveAccount => voucherProblemInactive,
    VoucherProblem.contraNeedsBooksOnly => voucherProblemContra,
    VoucherProblem.paymentNeedsBookCredit => voucherProblemPayment,
    VoucherProblem.receiptNeedsBookDebit => voucherProblemReceipt,
    VoucherProblem.salesNeedsSalesCredit => voucherProblemSales,
    VoucherProblem.purchaseNeedsPurchaseDebit => voucherProblemPurchase,
    VoucherProblem.journalNoBooks => voucherProblemJournal,
  };

  /// What went wrong with a voucher save / reversal, or null when it worked.
  String? voucherResult(VoucherSaveResult r) => switch (r) {
    VoucherSaved() => null,
    VoucherInvalid(:final problems) => problems.map(voucherProblem).join('\n'),
    VoucherNotPermitted(lockedYear: true) => yearLockedError,
    VoucherNotPermitted(:final backdateDays?) => khataErrorBackdated(
      backdateDays,
    ),
    VoucherNotPermitted(:final permission) => acctNeedsPermission(
      permissionName(permission),
    ),
    VoucherNotFound() => voucherNotFound,
    VoucherLocked() => voucherLocked,
  };

  /// The kind of document behind a journal entry (`source_type`).
  String sourceTypeName(String sourceType) => switch (sourceType) {
    'lot' => sourceLot,
    'payment' => sourcePayment,
    'interest' => sourceInterest,
    'waiver' => sourceWaiver,
    'entry' => sourceEntry,
    'reversal' => sourceReversal,
    'voucher' => khataRefVoucher,
    'expense' => khataRefExpense,
    'year_close' => yearCloseEntry,
    _ => sourceType,
  };

  String accountProblem(AccountProblem p) => switch (p) {
    AccountProblem.nameEmpty => chartProblemNameEmpty,
    AccountProblem.nameTaken => chartProblemNameTaken,
    AccountProblem.groupNotAllowed => chartProblemGroup,
    AccountProblem.notOwn => chartProblemNotOwn,
  };

  /// `₹1,200 Dr` / `₹300 Cr` / `₹0`.
  String drCr(Money net) {
    if (net.isZero) return Money.zero.format();
    final text = net.abs().format();
    return net.isPositive ? chartDrBalance(text) : chartCrBalance(text);
  }
}
