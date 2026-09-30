// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get syncOff => 'Sync off';

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String get syncSyncedJustNow => 'Synced · just now';

  @override
  String syncSyncedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Synced · $count min ago',
      one: 'Synced · 1 min ago',
    );
    return '$_temp0';
  }

  @override
  String syncSyncedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Synced · $count hr ago',
      one: 'Synced · 1 hr ago',
    );
    return '$_temp0';
  }

  @override
  String get syncOffline => 'Offline';

  @override
  String syncOfflineQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Offline · $count queued',
      one: 'Offline · 1 queued',
    );
    return '$_temp0';
  }

  @override
  String syncErrorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sync error · $count changes rejected',
      one: 'Sync error · 1 change rejected',
    );
    return '$_temp0';
  }

  @override
  String get syncErrorsTitle => 'Changes the server rejected';

  @override
  String get syncErrorsBody =>
      'These changes were not saved online. Everything else keeps syncing.';

  @override
  String get syncErrorsDismiss => 'Dismiss all';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Try again';

  @override
  String get splashLoading => 'Getting things ready…';

  @override
  String get loginTitle => 'Sign in to Mandi Khata';

  @override
  String get loginSubtitle =>
      'We\'ll send a 6-digit code to your mobile by SMS.';

  @override
  String get loginTabPhone => 'Mobile number';

  @override
  String get loginTabEmail => 'Email';

  @override
  String get loginPhoneLabel => 'Mobile number';

  @override
  String get loginPhoneInvalid => 'Enter a 10-digit Indian mobile number';

  @override
  String get loginSendOtp => 'Send code';

  @override
  String get loginOtpLabel => '6-digit code';

  @override
  String loginOtpSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get loginOtpInvalidFormat => 'Enter the 6-digit code';

  @override
  String get loginVerify => 'Verify and sign in';

  @override
  String loginResendIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get loginResend => 'Resend code';

  @override
  String get loginChangeNumber => 'Change number';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginEmailSignIn => 'Sign in';

  @override
  String get loginEmailInvalid => 'Enter your email and password';

  @override
  String get authErrorNotConfigured => 'Sign-in is not set up in this build.';

  @override
  String get authErrorNetwork =>
      'No internet connection. Connect and try again.';

  @override
  String get authErrorInvalidOtp => 'That code is wrong or has expired.';

  @override
  String get authErrorInvalidCredentials => 'Wrong email or password.';

  @override
  String get authErrorRateLimited =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get authErrorSms =>
      'Couldn\'t send the SMS. Try again later or sign in with email.';

  @override
  String get authErrorUnknown => 'Sign-in failed. Try again.';

  @override
  String get tenantPickerTitle => 'Choose a business';

  @override
  String get tenantPickerSubtitle =>
      'You can switch later from the account menu.';

  @override
  String get tenantPickerLoading =>
      'Downloading your businesses… This needs internet the first time.';

  @override
  String get tenantPickerNoSync =>
      'Sync is not set up in this build, so your businesses can\'t be loaded.';

  @override
  String get tenantPickerEmptyTitle => 'No business linked yet';

  @override
  String get tenantPickerEmptyBody =>
      'Your account isn\'t part of any business. Ask the owner to add you, then open the app again.';

  @override
  String deviceSetupOffline(String business) {
    return 'Connect to the internet once to set up this device for $business.';
  }

  @override
  String deviceSetupFailed(String business) {
    return 'This device couldn\'t be set up for $business.';
  }

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAccountant => 'Accountant';

  @override
  String get roleMunshi => 'Munshi';

  @override
  String get roleCustom => 'Custom role';

  @override
  String get pinSetupTitle => 'Set an app PIN';

  @override
  String get pinSetupBody =>
      'Asked when the app opens, so others can\'t see your khata. 4–6 digits, stays on this device.';

  @override
  String get pinConfirmTitle => 'Enter the PIN again';

  @override
  String get pinMismatch => 'PINs don\'t match. Try again.';

  @override
  String get pinTooShort => 'Use 4 to 6 digits';

  @override
  String get pinSkip => 'Skip for now';

  @override
  String get pinSaved => 'App PIN saved';

  @override
  String get pinBiometricOption => 'Also unlock with fingerprint or face';

  @override
  String get pinPadDelete => 'Delete digit';

  @override
  String get pinPadOk => 'OK';

  @override
  String get lockTitle => 'Enter your PIN';

  @override
  String get lockWrongPin => 'Wrong PIN';

  @override
  String lockCooldown(int seconds) {
    return 'Too many wrong tries. Try again in ${seconds}s.';
  }

  @override
  String get lockUseBiometric => 'Use fingerprint';

  @override
  String get lockBiometricReason => 'Unlock Mandi Khata';

  @override
  String get lockForgotPin => 'Forgot PIN? Sign out';

  @override
  String get accountMenu => 'Account';

  @override
  String get accountSwitchBusiness => 'Switch business';

  @override
  String get accountLockNow => 'Lock now';

  @override
  String get accountSetPin => 'Set app PIN';

  @override
  String get accountChangePin => 'Change app PIN';

  @override
  String get accountRemovePin => 'Remove app PIN';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String homeDeviceCode(String code) {
    return 'This device: $code';
  }

  @override
  String get homePlaceholder => 'Your dashboard will appear here.';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutBody =>
      'This device\'s copy of the data will be removed. You\'ll need internet to sign in again.';

  @override
  String signOutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count changes haven\'t been uploaded yet. Signing out now deletes them from this device.',
      one:
          '1 change hasn\'t been uploaded yet. Signing out now deletes it from this device.',
    );
    return '$_temp0';
  }

  @override
  String get signOutUploadFirst => 'Upload, then sign out';

  @override
  String get signOutAnyway => 'Sign out and delete them';

  @override
  String get signOutUploading => 'Uploading changes…';

  @override
  String get signOutUploadFailed =>
      'Couldn\'t upload everything. Check the internet and try again.';

  @override
  String get settingInterestEnabled => 'Charge interest';

  @override
  String get settingInterestRatePa => 'Interest rate (% per year)';

  @override
  String get settingInterestRateUnitDisplay => 'Show rate as';

  @override
  String get settingInterestMethod => 'Interest method';

  @override
  String get settingInterestCompounding => 'Compounding period';

  @override
  String get settingInterestDayBasis => 'Days in a year';

  @override
  String get settingInterestGraceDays => 'Grace days';

  @override
  String get settingInterestAppropriation => 'Repayment goes first to';

  @override
  String get settingInterestApplyOn => 'Charge interest on';

  @override
  String get settingInterestMinDays => 'Ignore periods shorter than (days)';

  @override
  String get settingInterestRounding => 'Round interest to';

  @override
  String get settingInterestPostFrequency => 'Post interest to khata';

  @override
  String get settingInterestPayOnJama => 'Pay interest when we owe the party';

  @override
  String get settingInterestPayRatePa => 'Rate paid on jama (% per year)';

  @override
  String get settingMandiCommissionPct => 'Commission (arhat) %';

  @override
  String get settingMandiPalledariPerBag => 'Palledari per bag';

  @override
  String get settingMandiBardanaPerBag => 'Bardana per bag';

  @override
  String get settingMandiTulaiPerQtl => 'Tulai per quintal';

  @override
  String get settingMandiMandiFeePct => 'Mandi fee %';

  @override
  String get settingMandiCess => 'Cess';

  @override
  String get settingMandiChargesBorneBy => 'Who pays each charge';

  @override
  String get settingMandiBagWeightKg => 'Bag weight (kg)';

  @override
  String get settingShopPriceTiers => 'Price tiers';

  @override
  String get settingShopDefaultTierForRole => 'Default price tier';

  @override
  String get settingShopAllowNegativeStock => 'Allow selling below zero stock';

  @override
  String get settingShopExpiryWarnDays => 'Warn before expiry (days)';

  @override
  String get settingShopGstEnabled => 'GST on invoices';

  @override
  String get settingShopPostCreditSaleToKhata => 'Post credit sales to khata';

  @override
  String get settingBusinessFyStartMonth => 'Financial year starts in month';

  @override
  String get settingBusinessNumberSeries => 'Number series';

  @override
  String get settingAppModules => 'Module';

  @override
  String get settingAppLanguages => 'Languages';

  @override
  String get settingAppDefaultLanguage => 'Default language';

  @override
  String get settingPrintReceiptSize => 'Receipt paper';

  @override
  String get settingNotifyWhatsappReceipts => 'Send receipts on WhatsApp';

  @override
  String get settingOptInterestRateUnitDisplayPa => '% per year';

  @override
  String get settingOptInterestRateUnitDisplayPer100PerMonth =>
      '₹ per 100 per month';

  @override
  String get settingOptInterestMethodSimple => 'Simple';

  @override
  String get settingOptInterestMethodCompound => 'Compound (chakravridhi)';

  @override
  String get settingOptInterestCompoundingMonthly => 'Monthly';

  @override
  String get settingOptInterestCompoundingQuarterly => 'Quarterly';

  @override
  String get settingOptInterestCompoundingHalfyearly => 'Half-yearly';

  @override
  String get settingOptInterestCompoundingYearly => 'Yearly';

  @override
  String get settingOptInterestCompoundingOnFyClose =>
      'At financial year close';

  @override
  String get settingOptInterestAppropriationInterestFirst => 'Interest';

  @override
  String get settingOptInterestAppropriationPrincipalFirst => 'Principal';

  @override
  String get settingOptInterestApplyOnNetUdhaar => 'Net udhaar only';

  @override
  String get settingOptInterestApplyOnLoansOnly => 'Loans (karza) only';

  @override
  String get settingOptInterestApplyOnNone => 'No interest';

  @override
  String get settingOptInterestRoundingPaise => 'Paise';

  @override
  String get settingOptInterestRoundingRupee => 'Rupee';

  @override
  String get settingOptInterestRoundingTenRupee => '₹10';

  @override
  String get settingOptInterestPostFrequencyOnDemand => 'When I choose';

  @override
  String get settingOptInterestPostFrequencyMonthly => 'Monthly';

  @override
  String get settingOptInterestPostFrequencyQuarterly => 'Quarterly';

  @override
  String get settingOptInterestPostFrequencyFyClose =>
      'At financial year close';

  @override
  String get settingOptAppDefaultLanguageEn => 'English';

  @override
  String get settingOptAppDefaultLanguageHi => 'हिंदी';

  @override
  String get settingOptAppDefaultLanguagePa => 'ਪੰਜਾਬੀ';

  @override
  String get settingOptPrintReceiptSizeA5 => 'A5 paper';

  @override
  String get settingOptPrintReceiptSizeThermal80 => 'Thermal 80 mm';

  @override
  String get settingOptPrintReceiptSizeThermal58 => 'Thermal 58 mm';

  @override
  String get settingSuffixRoleFarmer => 'Farmer';

  @override
  String get settingSuffixRoleCustomer => 'Customer';

  @override
  String get settingSuffixRoleSupplier => 'Supplier';

  @override
  String get settingSuffixRoleVendor => 'Vendor';

  @override
  String get settingSuffixRoleAgency => 'Agency';

  @override
  String get settingSuffixRoleBuyer => 'Buyer';

  @override
  String get settingSuffixDocReceipt => 'Receipts';

  @override
  String get settingSuffixDocLot => 'Lots';

  @override
  String get settingSuffixDocSalesInvoice => 'Sales invoices';

  @override
  String get settingSuffixDocPurchaseInvoice => 'Purchase invoices';

  @override
  String get settingSuffixDocKarza => 'Karza';

  @override
  String get settingSuffixDocVoucher => 'Vouchers';

  @override
  String get settingSuffixModuleKhata => 'Khata';

  @override
  String get settingSuffixModuleArrivals => 'Arrivals & lots';

  @override
  String get settingSuffixModuleKarza => 'Karza & byaj';

  @override
  String get settingSuffixModuleAccounting => 'Accounting';

  @override
  String get settingSuffixModuleShop => 'Input shop';

  @override
  String get settingsGroupInterest => 'Interest (byaj)';

  @override
  String get settingsGroupMandi => 'Mandi charges';

  @override
  String get settingsGroupShop => 'Input shop';

  @override
  String get settingsGroupBusiness => 'Business';

  @override
  String get settingsGroupModules => 'Modules';

  @override
  String get settingsGroupApp => 'App';

  @override
  String get settingsGroupPrint => 'Printing';

  @override
  String get settingsGroupNotify => 'Messages';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsScopeLabel => 'Settings for';

  @override
  String get settingsScopeBusiness => 'Whole business';

  @override
  String get settingsScopeHint =>
      'Pick a party to give them their own rates. Blank values follow the business.';

  @override
  String get settingsReset => 'Reset to inherited';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get settingsReadOnly => 'Edited on its own screen (coming soon).';

  @override
  String get settingsNoPermission =>
      'You don\'t have permission to change this.';

  @override
  String get settingsNoTenant => 'Choose a business first.';

  @override
  String get settingSetHere => 'Set here';

  @override
  String get settingFromDocument => 'From this document';

  @override
  String get settingFromParty => 'From the party';

  @override
  String get settingFromPartyGroup => 'From the party group';

  @override
  String get settingFromBusiness => 'From business setting';

  @override
  String get settingFromPlan => 'From your plan';

  @override
  String get settingFromDefault => 'App default';

  @override
  String get settingErrorWrongType => 'Enter a valid value';

  @override
  String settingErrorTooSmall(String min) {
    return 'Too small (minimum $min)';
  }

  @override
  String settingErrorTooLarge(String max) {
    return 'Too large (maximum $max)';
  }

  @override
  String get settingErrorNotAllowed => 'Not an allowed value';

  @override
  String get settingErrorInvalid => 'Invalid value';

  @override
  String get settingErrorNotHere => 'This can\'t be set here';

  @override
  String settingRatePerMonth(String amount) {
    return '= ₹$amount per 100 per month';
  }

  @override
  String get accountLanguage => 'Language';

  @override
  String get accountDiagnostics => 'Diagnostics';

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get diagnosticsOwnerOnly => 'Only the owner can open diagnostics.';

  @override
  String get diagnosticsDatabase => 'This device';

  @override
  String get diagnosticsDeviceCode => 'Device code';

  @override
  String get diagnosticsConnection => 'Sync connection';

  @override
  String get diagnosticsOnline => 'Connected';

  @override
  String get diagnosticsOffline => 'Not connected';

  @override
  String get diagnosticsLastSync => 'Last sync';

  @override
  String get diagnosticsNever => 'Never';

  @override
  String get diagnosticsQueued => 'Changes waiting to upload';

  @override
  String get diagnosticsDbSize => 'Local database size';

  @override
  String get diagnosticsRefresh => 'Refresh';

  @override
  String get diagnosticsRejected => 'Changes the server rejected';

  @override
  String get diagnosticsNoRejected => 'No rejected changes.';

  @override
  String get diagnosticsRetry => 'Retry';

  @override
  String get diagnosticsDiscard => 'Discard';

  @override
  String get diagnosticsRequeued => 'Queued for upload again';

  @override
  String get diagnosticsNotRetryable =>
      'This change can\'t be sent again. Discard it instead.';

  @override
  String get settingSuffixDocParty => 'Party codes';

  @override
  String get partiesTitle => 'Parties';

  @override
  String get partiesSearchHint => 'Search name, village, mobile, code';

  @override
  String get partiesAll => 'All';

  @override
  String partiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '1 party',
    );
    return '$_temp0';
  }

  @override
  String get partiesEmptyTitle => 'No parties yet';

  @override
  String get partiesEmptyBody =>
      'Add the farmers, buyers and suppliers you deal with.';

  @override
  String get partiesNoMatch => 'No party matches your search.';

  @override
  String get partiesAdd => 'Add party';

  @override
  String get partyEditTitle => 'Edit party';

  @override
  String get partyFieldCode => 'Code';

  @override
  String partyCodeAutoHint(String code) {
    return 'Leave blank for $code';
  }

  @override
  String get partyFieldName => 'Name';

  @override
  String get partyFieldRoles => 'Roles';

  @override
  String get partyFieldRelation => 'Relation';

  @override
  String get partyRelationNone => 'None';

  @override
  String get partyRelationSonOf => 'S/o';

  @override
  String get partyRelationDaughterOf => 'D/o';

  @override
  String get partyRelationWifeOf => 'W/o';

  @override
  String get partyRelationProprietor => 'Prop.';

  @override
  String get partyFieldFatherOrHusband => 'Father / husband name';

  @override
  String get partyFieldMobile => 'Mobile';

  @override
  String get partyFieldAltMobile => 'Other mobile';

  @override
  String get partyFieldVillage => 'Village';

  @override
  String get partyFieldDistrict => 'District';

  @override
  String get partyFieldState => 'State';

  @override
  String get partyFieldAadhaar => 'Aadhaar (last 4 digits)';

  @override
  String get partyFieldBankName => 'Bank';

  @override
  String get partyFieldBankAccount => 'Account number';

  @override
  String get partyBankAccountHint => 'Only the last 4 digits are kept';

  @override
  String get partyFieldIfsc => 'IFSC';

  @override
  String get partyFieldGstin => 'GSTIN';

  @override
  String get partyFieldNotes => 'Notes';

  @override
  String get partySectionIdentity => 'Party';

  @override
  String get partySectionContact => 'Contact & address';

  @override
  String get partySectionBank => 'Bank & tax';

  @override
  String get partyErrorRequired => 'Required';

  @override
  String get partyErrorRoles => 'Pick at least one role';

  @override
  String get partyErrorMobile => 'Enter a 10-digit mobile number';

  @override
  String get partyErrorIfsc => 'Enter a valid IFSC, e.g. SBIN0001234';

  @override
  String get partyErrorGstin => 'Enter a valid 15-character GSTIN';

  @override
  String get partyErrorAadhaar => 'Enter only the last 4 digits';

  @override
  String get partyErrorCodeTaken => 'Another party already has this code';

  @override
  String get partyNotFound => 'This party was deleted.';

  @override
  String get partySave => 'Save party';

  @override
  String get partySaved => 'Party saved';

  @override
  String get partyEdit => 'Edit';

  @override
  String get partyDelete => 'Delete';

  @override
  String partyDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get partyDeleteBody =>
      'The party is hidden from lists. Its history and audit log stay.';

  @override
  String get partyDeleted => 'Party deleted';

  @override
  String get partyTabKhata => 'Khata';

  @override
  String get partyTabLots => 'Lots';

  @override
  String get partyTabLoans => 'Loans';

  @override
  String get partyTabShop => 'Shop';

  @override
  String get partyTabDocuments => 'Documents';

  @override
  String get partyTabNotes => 'Notes';

  @override
  String get partyTabComingSoon => 'This part arrives in a later update.';

  @override
  String get partyNoNotes => 'No notes.';

  @override
  String get cropsTitle => 'Crops';

  @override
  String get cropsAdd => 'Add crop';

  @override
  String get cropsEmpty => 'No crops yet.';

  @override
  String get cropsShowInactive => 'Show crops not in use';

  @override
  String get cropInactive => 'Not in use';

  @override
  String cropRatePerQtl(String rate) {
    return '$rate/qtl';
  }

  @override
  String get cropNoRate => 'No MSP / usual rate';

  @override
  String get cropEditTitle => 'Edit crop';

  @override
  String get cropFieldNameEn => 'Name (English)';

  @override
  String get cropFieldNameHi => 'Name (Hindi)';

  @override
  String get cropFieldNamePa => 'Name (Punjabi)';

  @override
  String get cropFieldCode => 'Code';

  @override
  String get cropCodeHint =>
      'Small letters, digits and _. Cannot be changed later.';

  @override
  String get cropFieldStdRate => 'MSP / usual rate per qtl';

  @override
  String get cropFieldActive => 'In use';

  @override
  String get cropErrorCode =>
      'Start with a letter; use small letters, digits and _ (max 24).';

  @override
  String get cropErrorName => 'Enter the English name.';

  @override
  String get cropErrorRate => 'Enter a valid amount.';

  @override
  String get cropErrorCodeTaken => 'A crop with this code already exists.';

  @override
  String get cropNotFound => 'This crop no longer exists.';

  @override
  String get cropChargesTitle => 'Mandi charges for this crop';

  @override
  String get cropChargesHint =>
      'Values not set here come from the business settings. A rate set for a farmer or a lot still wins.';

  @override
  String cropExampleTitle(int bags, String qtl, String rate) {
    return 'Example: $bags bags · $qtl qtl @ $rate/qtl';
  }

  @override
  String get chargeCommission => 'Arhat (commission)';

  @override
  String get chargePalledari => 'Palledari';

  @override
  String get chargeBardana => 'Bardana';

  @override
  String get chargeTulai => 'Tulai';

  @override
  String get chargeMandiFee => 'Mandi fee';

  @override
  String get chargeCess => 'Cess';

  @override
  String get payerFarmer => 'Farmer';

  @override
  String get payerBuyer => 'Buyer';

  @override
  String get payerArhtiya => 'Arhtiya (us)';

  @override
  String get mandiGross => 'Gross';

  @override
  String get mandiNetToFarmer => 'Net to farmer (jama)';

  @override
  String get mandiBuyerTotal => 'Buyer pays (udhaar)';

  @override
  String mandiPaidBy(String payer) {
    return 'paid by $payer';
  }

  @override
  String get mandiWaived => 'waived';

  @override
  String get cessAdd => 'Add cess';

  @override
  String get cessName => 'Name (e.g. RDF)';

  @override
  String get cessPct => '%';

  @override
  String get cessRemove => 'Remove';

  @override
  String get settingsEdit => 'Edit';

  @override
  String get settingsCropsLink => 'Crops and per-crop charges';
}
