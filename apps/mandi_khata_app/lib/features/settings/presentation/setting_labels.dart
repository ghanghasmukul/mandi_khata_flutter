// GENERATED from the settings label table (see docs/decisions.md,
// 2026-09-30). Every key, option, suffix and group in
// khata_core's SettingsSchema has a label in en / hi / pa; a test checks it.
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

extension SettingLabels on AppLocalizations {
  /// Label of a base key (`mandi.commission_pct`).
  String settingLabel(String key) => switch (key) {
    'interest.enabled' => settingInterestEnabled,
    'interest.rate_pa' => settingInterestRatePa,
    'interest.rate_unit_display' => settingInterestRateUnitDisplay,
    'interest.method' => settingInterestMethod,
    'interest.compounding' => settingInterestCompounding,
    'interest.day_basis' => settingInterestDayBasis,
    'interest.grace_days' => settingInterestGraceDays,
    'interest.appropriation' => settingInterestAppropriation,
    'interest.apply_on' => settingInterestApplyOn,
    'interest.min_days' => settingInterestMinDays,
    'interest.rounding' => settingInterestRounding,
    'interest.post_frequency' => settingInterestPostFrequency,
    'interest.pay_on_jama' => settingInterestPayOnJama,
    'interest.pay_rate_pa' => settingInterestPayRatePa,
    'mandi.commission_pct' => settingMandiCommissionPct,
    'mandi.palledari_per_bag' => settingMandiPalledariPerBag,
    'mandi.bardana_per_bag' => settingMandiBardanaPerBag,
    'mandi.tulai_per_qtl' => settingMandiTulaiPerQtl,
    'mandi.mandi_fee_pct' => settingMandiMandiFeePct,
    'mandi.cess' => settingMandiCess,
    'mandi.charges_borne_by' => settingMandiChargesBorneBy,
    'mandi.bag_weight_kg' => settingMandiBagWeightKg,
    'shop.price_tiers' => settingShopPriceTiers,
    'shop.default_tier_for_role' => settingShopDefaultTierForRole,
    'shop.allow_negative_stock' => settingShopAllowNegativeStock,
    'shop.expiry_warn_days' => settingShopExpiryWarnDays,
    'shop.gst_enabled' => settingShopGstEnabled,
    'shop.post_credit_sale_to_khata' => settingShopPostCreditSaleToKhata,
    'business.fy_start_month' => settingBusinessFyStartMonth,
    'business.backdate_days' => settingBusinessBackdateDays,
    'business.munshi_payment_limit' => settingBusinessMunshiPaymentLimit,
    'business.credit_limit' => settingBusinessCreditLimit,
    'business.number_series' => settingBusinessNumberSeries,
    'app.modules' => settingAppModules,
    'app.languages' => settingAppLanguages,
    'app.default_language' => settingAppDefaultLanguage,
    'print.receipt_size' => settingPrintReceiptSize,
    'notify.whatsapp_receipts' => settingNotifyWhatsappReceipts,
    _ => key,
  };

  /// Label of a choice value; [id] is `<baseKey>=<value>`.
  String settingOptionById(String id) => switch (id) {
    'interest.rate_unit_display=pa' => settingOptInterestRateUnitDisplayPa,
    'interest.rate_unit_display=per100_per_month' =>
      settingOptInterestRateUnitDisplayPer100PerMonth,
    'interest.method=simple' => settingOptInterestMethodSimple,
    'interest.method=compound' => settingOptInterestMethodCompound,
    'interest.compounding=monthly' => settingOptInterestCompoundingMonthly,
    'interest.compounding=quarterly' => settingOptInterestCompoundingQuarterly,
    'interest.compounding=halfyearly' =>
      settingOptInterestCompoundingHalfyearly,
    'interest.compounding=yearly' => settingOptInterestCompoundingYearly,
    'interest.compounding=on_fy_close' =>
      settingOptInterestCompoundingOnFyClose,
    'interest.appropriation=interest_first' =>
      settingOptInterestAppropriationInterestFirst,
    'interest.appropriation=principal_first' =>
      settingOptInterestAppropriationPrincipalFirst,
    'interest.apply_on=net_udhaar' => settingOptInterestApplyOnNetUdhaar,
    'interest.apply_on=loans_only' => settingOptInterestApplyOnLoansOnly,
    'interest.apply_on=none' => settingOptInterestApplyOnNone,
    'interest.rounding=paise' => settingOptInterestRoundingPaise,
    'interest.rounding=rupee' => settingOptInterestRoundingRupee,
    'interest.rounding=ten_rupee' => settingOptInterestRoundingTenRupee,
    'interest.post_frequency=on_demand' =>
      settingOptInterestPostFrequencyOnDemand,
    'interest.post_frequency=monthly' => settingOptInterestPostFrequencyMonthly,
    'interest.post_frequency=quarterly' =>
      settingOptInterestPostFrequencyQuarterly,
    'interest.post_frequency=fy_close' =>
      settingOptInterestPostFrequencyFyClose,
    'app.default_language=en' => settingOptAppDefaultLanguageEn,
    'app.default_language=hi' => settingOptAppDefaultLanguageHi,
    'app.default_language=pa' => settingOptAppDefaultLanguagePa,
    'print.receipt_size=a5' => settingOptPrintReceiptSizeA5,
    'print.receipt_size=thermal_80' => settingOptPrintReceiptSizeThermal80,
    'print.receipt_size=thermal_58' => settingOptPrintReceiptSizeThermal58,
    _ => id,
  };

  String settingOption(String key, String value) =>
      settingOptionById('$key=$value');

  /// Label of a key suffix; [id] is `<suffixName>=<value>` (`role=farmer`).
  String settingSuffixById(String id) => switch (id) {
    'role=farmer' => settingSuffixRoleFarmer,
    'role=customer' => settingSuffixRoleCustomer,
    'role=supplier' => settingSuffixRoleSupplier,
    'role=vendor' => settingSuffixRoleVendor,
    'role=agency' => settingSuffixRoleAgency,
    'role=buyer' => settingSuffixRoleBuyer,
    'doc=receipt' => settingSuffixDocReceipt,
    'doc=lot' => settingSuffixDocLot,
    'doc=sales_invoice' => settingSuffixDocSalesInvoice,
    'doc=purchase_invoice' => settingSuffixDocPurchaseInvoice,
    'doc=karza' => settingSuffixDocKarza,
    'doc=voucher' => settingSuffixDocVoucher,
    'doc=contra_voucher' => '$voucherTypeContra · $khataRefVoucher',
    'doc=payment_voucher' => '$voucherTypePayment · $khataRefVoucher',
    'doc=receipt_voucher' => '$voucherTypeReceipt · $khataRefVoucher',
    'doc=sales_voucher' => '$voucherTypeSales · $khataRefVoucher',
    'doc=purchase_voucher' => '$voucherTypePurchase · $khataRefVoucher',
    'doc=journal_voucher' => '$voucherTypeJournal · $khataRefVoucher',
    'doc=expense' => khataRefExpense,
    'doc=party' => settingSuffixDocParty,
    'module=khata' => settingSuffixModuleKhata,
    'module=arrivals' => settingSuffixModuleArrivals,
    'module=karza' => settingSuffixModuleKarza,
    'module=accounting' => settingSuffixModuleAccounting,
    'module=shop' => settingSuffixModuleShop,
    _ => id,
  };

  String settingSuffix(String suffixName, String value) =>
      settingSuffixById('$suffixName=$value');

  /// Title of a group of settings (`interest`, `mandi`, `modules`, …).
  String settingGroup(String group) => switch (group) {
    'interest' => settingsGroupInterest,
    'mandi' => settingsGroupMandi,
    'shop' => settingsGroupShop,
    'business' => settingsGroupBusiness,
    'modules' => settingsGroupModules,
    'app' => settingsGroupApp,
    'print' => settingsGroupPrint,
    'notify' => settingsGroupNotify,
    _ => group,
  };
}

extension MandiLabels on AppLocalizations {
  String mandiCharge(MandiCharge c) => switch (c) {
    MandiCharge.commission => chargeCommission,
    MandiCharge.palledari => chargePalledari,
    MandiCharge.bardana => chargeBardana,
    MandiCharge.tulai => chargeTulai,
    MandiCharge.mandiFee => chargeMandiFee,
    MandiCharge.cess => chargeCess,
  };

  String chargePayer(ChargePayer p) => switch (p) {
    ChargePayer.farmer => payerFarmer,
    ChargePayer.buyer => payerBuyer,
    ChargePayer.arhtiya => payerArhtiya,
  };
}
