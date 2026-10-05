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

  @override
  String get arrivalsTitle => 'Arrivals';

  @override
  String get arrivalsEmpty => 'No lots for these filters';

  @override
  String get arrivalsSearchHint => 'Search farmer or lot no';

  @override
  String get arrivalsAllCrops => 'All crops';

  @override
  String get arrivalsAllStatuses => 'All statuses';

  @override
  String get rangeToday => 'Today';

  @override
  String get rangeYesterday => 'Yesterday';

  @override
  String get rangeWeek => 'Last 7 days';

  @override
  String get rangeAll => 'All dates';

  @override
  String get rangeCustom => 'Pick dates…';

  @override
  String get lotNo => 'Lot no';

  @override
  String get lotDate => 'Date';

  @override
  String get lotFarmer => 'Farmer';

  @override
  String get lotCrop => 'Crop';

  @override
  String get lotBags => 'Bags';

  @override
  String lotBagsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bags',
      one: '1 bag',
    );
    return '$_temp0';
  }

  @override
  String get lotQtl => 'Qtl';

  @override
  String get lotQtlUnit => 'qtl';

  @override
  String lotQtlFromBags(String kg) {
    return 'From bags × $kg kg';
  }

  @override
  String get lotQtlFromBagsShort => 'from bags';

  @override
  String get lotRate => 'Rate';

  @override
  String get lotPerQtl => '/ qtl';

  @override
  String get lotBuyer => 'Buyer';

  @override
  String get lotBuyerHint => 'Optional — type 3 letters';

  @override
  String get lotJForm => 'J-form no';

  @override
  String get lotVehicle => 'Vehicle no';

  @override
  String get lotNotes => 'Notes';

  @override
  String get lotStatusLabel => 'Status';

  @override
  String get lotPostedAt => 'Posted';

  @override
  String get lotStatusArrived => 'Arrived';

  @override
  String get lotStatusWeighed => 'Weighed';

  @override
  String get lotStatusSold => 'Sold';

  @override
  String get lotStatusPosted => 'Posted';

  @override
  String get lotStatusReversed => 'Reversed';

  @override
  String get lotStatusCancelled => 'Cancelled';

  @override
  String get lotProblemBags => 'Bags cannot be negative';

  @override
  String get lotProblemWeight => 'Enter the weight';

  @override
  String get lotProblemRate => 'Rate must be more than zero';

  @override
  String get lotProblemBuyerIsFarmer => 'The buyer cannot be the farmer';

  @override
  String get lotProblemNoWeight => 'Weight is needed to post';

  @override
  String get lotProblemNoRate => 'Rate is needed to post';

  @override
  String get lotProblemBuyerRequired =>
      'Pick the buyer: some charges are billed to the buyer';

  @override
  String get lotProblemNetNotPositive =>
      'Charges are more than the sale; nothing to credit to the farmer';

  @override
  String get lotErrorNotPermitted => 'You are not allowed to do this';

  @override
  String get lotErrorNotFound => 'Lot, farmer, buyer or crop not found';

  @override
  String get lotErrorLocked =>
      'This lot is posted or reversed and cannot be changed';

  @override
  String get lotErrorPickFarmer => 'Pick the farmer';

  @override
  String get lotErrorPickCrop => 'Pick the crop';

  @override
  String get lotNewTitle => 'New arrival';

  @override
  String get lotEditTitle => 'Edit lot';

  @override
  String lotNextNo(String number) {
    return 'Lot $number';
  }

  @override
  String get lotSave => 'Save (F10)';

  @override
  String get lotSavePost => 'Save & post (F10)';

  @override
  String get lotSaveNew => 'Save & new (Shift+F10)';

  @override
  String get lotHold => 'Hold — don\'t post';

  @override
  String lotSavedToast(String lotNo) {
    return 'Lot $lotNo saved';
  }

  @override
  String lotPostedToast(String lotNo) {
    return 'Lot $lotNo posted to the khata';
  }

  @override
  String get lotPreviewTitle => 'Calculation';

  @override
  String get lotPreviewEmpty =>
      'Enter crop, weight and rate to see arhat, charges and net.';

  @override
  String get lotPostsTitle => 'Posting writes to the khata:';

  @override
  String get lotPostsFarmer => 'Jama to farmer';

  @override
  String get lotPostsBuyer => 'Udhaar to buyer';

  @override
  String get lotCancel => 'Cancel lot';

  @override
  String lotCancelTitle(String lotNo) {
    return 'Cancel lot $lotNo?';
  }

  @override
  String get lotCancelBody =>
      'Use this when the crop never came or was entered by mistake. Nothing was posted to the khata. This cannot be undone.';

  @override
  String lotCancelledToast(String lotNo) {
    return 'Lot $lotNo cancelled';
  }

  @override
  String get lotReverse => 'Reverse lot';

  @override
  String lotReverseTitle(String lotNo) {
    return 'Reverse lot $lotNo?';
  }

  @override
  String get lotReverseBody =>
      'Its khata entries (farmer\'s jama, buyer\'s udhaar) are reversed on the same date. The lot stays in the records, marked reversed. You can then enter it again correctly.';

  @override
  String lotReversedToast(String lotNo) {
    return 'Lot $lotNo reversed';
  }

  @override
  String get lotReenter => 'Enter again';

  @override
  String get lotEdit => 'Edit';

  @override
  String get lotAddWeightRate => 'Add weight & rate';

  @override
  String get lotDetailsTitle => 'Lot';

  @override
  String get lotCalculationTitle => 'Arhat & charges';

  @override
  String get lotNotPostedYet =>
      'Shown once the lot is posted (with the rates of that day).';

  @override
  String get lotEntriesTitle => 'Khata entries';

  @override
  String get lotEntryArrival => 'Crop sale';

  @override
  String get lotEntryReversal => 'Reversal';

  @override
  String get lotsTotalCount => 'Lots';

  @override
  String get wizardStepFarmer => 'Farmer';

  @override
  String get wizardStepCrop => 'Crop & bags';

  @override
  String get wizardStepConfirm => 'Confirm';

  @override
  String wizardStepOf(int step, int total, String title) {
    return 'Step $step of $total: $title';
  }

  @override
  String get wizardBack => 'Back';

  @override
  String get wizardNext => 'Next';

  @override
  String get wizardRateLater => 'Weight and rate are added at the counter.';

  @override
  String partyPickerHint(int count) {
    return 'Type $count letters to search';
  }

  @override
  String get partyPickerChange => 'Change';

  @override
  String get khataRefArrival => 'Crop sale';

  @override
  String get khataRefPayment => 'Payment';

  @override
  String get khataRefReceipt => 'Receipt';

  @override
  String get khataRefShopSale => 'Shop sale';

  @override
  String get khataRefShopReturn => 'Shop return';

  @override
  String get khataRefPurchase => 'Purchase';

  @override
  String get khataRefLoanDisbursal => 'Loan given';

  @override
  String get khataRefLoanRepayment => 'Loan repayment';

  @override
  String get khataRefInterest => 'Interest';

  @override
  String get khataRefExpense => 'Expense';

  @override
  String get khataRefJournal => 'Khata entry';

  @override
  String get khataRefOpeningBalance => 'Opening balance';

  @override
  String get khataRefReversal => 'Reversal';

  @override
  String get khataTagReversal => 'reversal';

  @override
  String get khataTagEdited => 'edited';

  @override
  String get khataTagReversed => 'reversed';

  @override
  String khataErrorBackdated(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Entries older than $_temp0, or dated in the future, need an Accountant or Owner';
  }

  @override
  String get khataErrorNotPermitted => 'You are not allowed to do this';

  @override
  String get khataErrorNotFound => 'This party or entry no longer exists';

  @override
  String get khataErrorAmount => 'Enter an amount above zero';

  @override
  String get khataErrorNothingChanged => 'Nothing was changed';

  @override
  String get khataErrorAlreadyReversed => 'This entry was already reversed';

  @override
  String get khataErrorIsReversal =>
      'A reversal cannot be changed; post a new entry';

  @override
  String get khataColDate => 'Date';

  @override
  String get khataColDetails => 'Details';

  @override
  String get khataColPartyDetails => 'Party · details';

  @override
  String get khataColUdhaar => 'Udhaar';

  @override
  String get khataColJama => 'Jama';

  @override
  String get khataColBaki => 'Baki';

  @override
  String get khataBalanceJama => 'Jama · we owe';

  @override
  String get khataBalanceUdhaarFarmer => 'Udhaar · farmer owes';

  @override
  String get khataBalanceUdhaarParty => 'Udhaar · party owes';

  @override
  String get khataBalanceSettled => 'Settled';

  @override
  String get khataEntryTitle => 'Khata entry';

  @override
  String get khataEditTitle => 'Edit khata entry';

  @override
  String get khataEditOriginal => 'Original entry (will be reversed)';

  @override
  String get khataEditExplain =>
      'The original stays in the khata, struck through, and the corrected entry is added.';

  @override
  String get khataFieldParty => 'Party';

  @override
  String get khataFieldPartyHint => 'Type a name, village or code';

  @override
  String get khataSideUdhaar => 'Udhaar (party owes more)';

  @override
  String get khataSideJama => 'Jama (we owe more)';

  @override
  String get khataFieldAmount => 'Amount';

  @override
  String get khataFieldDate => 'Date';

  @override
  String get khataFieldNarration => 'Narration';

  @override
  String get khataEntrySave => 'Post entry';

  @override
  String get khataEditSave => 'Reverse and re-enter';

  @override
  String get khataDayBookTitle => 'All entries';

  @override
  String get khataDayBookEmpty => 'No entries for this filter';

  @override
  String get khataFilterParty => 'Filter by party';

  @override
  String get khataFilterAllTypes => 'All types';

  @override
  String khataEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get khataReverseTitle => 'Reverse this entry?';

  @override
  String get khataReverseBody =>
      'A mirror entry is added and both stay in the khata. This cannot be undone.';

  @override
  String get khataReverse => 'Reverse';

  @override
  String get khataReversed => 'Entry reversed';

  @override
  String get khataEntryActions => 'Entry actions';

  @override
  String get khataEdit => 'Edit (reverse and re-enter)';

  @override
  String get khataStatementEmpty => 'No entries in this period';

  @override
  String get statementTitle => 'Khata statement';

  @override
  String get statementOpening => 'Opening balance';

  @override
  String get statementClosing => 'Closing balance';

  @override
  String get statementTotals => 'Total';

  @override
  String statementPage(int page, int pages) {
    return 'Page $page of $pages';
  }

  @override
  String get statementPrint => 'Print / PDF';

  @override
  String get statementShare => 'Share';

  @override
  String get paletteHint => 'Type a command…';

  @override
  String get paletteNoMatch => 'No matching command';

  @override
  String get settingBusinessBackdateDays => 'Back-dating allowed (days)';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get paymentRecordTitle => 'Record payment';

  @override
  String get paymentPay => 'Pay';

  @override
  String get paymentReceive => 'Receive';

  @override
  String get paymentDirectionTo => 'Paid to party';

  @override
  String get paymentDirectionFrom => 'Received from party';

  @override
  String get paymentsEmpty => 'No payments in this period';

  @override
  String get paymentsSearchHint => 'Search party, receipt or cheque no.';

  @override
  String get paymentsAllModes => 'All modes';

  @override
  String get paymentsAllDirections => 'Paid and received';

  @override
  String get paymentsPendingCheques => 'Pending cheques';

  @override
  String get paymentsTotalCount => 'Payments';

  @override
  String get paymentsTotalPaid => 'Paid';

  @override
  String get paymentsTotalReceived => 'Received';

  @override
  String get paymentsColNo => 'No.';

  @override
  String get paymentsColDate => 'Date';

  @override
  String get paymentsColParty => 'Party';

  @override
  String get paymentsColType => 'Type';

  @override
  String get paymentsColMode => 'Mode';

  @override
  String get paymentsColAmount => 'Amount';

  @override
  String get paymentsColStatus => 'Status';

  @override
  String get paymentFieldAmount => 'Amount';

  @override
  String get paymentFieldDate => 'Date';

  @override
  String get paymentFieldMode => 'Mode';

  @override
  String get paymentFieldAccount => 'Bank account';

  @override
  String get paymentFieldReference => 'UTR / reference';

  @override
  String get paymentFieldChequeNo => 'Cheque number';

  @override
  String get paymentFieldChequeDate => 'Cheque date';

  @override
  String get paymentFieldNarration => 'Note';

  @override
  String get paymentModeCash => 'Cash';

  @override
  String get paymentModeBank => 'Bank transfer';

  @override
  String get paymentModeUpi => 'UPI';

  @override
  String get paymentModeCheque => 'Cheque';

  @override
  String get paymentChequePending => 'Pending';

  @override
  String get paymentChequeCleared => 'Cleared';

  @override
  String get paymentChequeBounced => 'Bounced';

  @override
  String get paymentStatusReversed => 'Reversed';

  @override
  String get paymentBakiNow => 'Baki now';

  @override
  String get paymentBakiAfter => 'After this payment';

  @override
  String get paymentFullBaki => 'Full baki';

  @override
  String get paymentSave => 'Save payment';

  @override
  String paymentSavedAs(String receiptNo) {
    return 'Saved as $receiptNo';
  }

  @override
  String get paymentReceiptTitle => 'Receipt';

  @override
  String get paymentVoucherTitle => 'Payment voucher';

  @override
  String get paymentPrintReceipt => 'Print receipt';

  @override
  String get paymentShareReceipt => 'Share receipt';

  @override
  String get paymentDone => 'Done';

  @override
  String get paymentMarkCleared => 'Mark cleared';

  @override
  String get paymentMarkBounced => 'Mark bounced';

  @override
  String get paymentBounceTitle => 'Cheque bounced?';

  @override
  String get paymentBounceBody =>
      'This reverses the khata entry and the cash book line, dated the bounce date.';

  @override
  String get paymentBounceDate => 'Bounce date';

  @override
  String get paymentReverse => 'Reverse payment';

  @override
  String get paymentReverseTitle => 'Reverse this payment?';

  @override
  String get paymentReverseBody =>
      'The khata entry and the cash book line are reversed. The payment stays on record as reversed.';

  @override
  String get paymentReversedToast => 'Payment reversed';

  @override
  String get paymentClearedToast => 'Cheque marked cleared';

  @override
  String get paymentBouncedToast => 'Cheque bounced; entry reversed';

  @override
  String get paymentNotFound => 'This payment no longer exists';

  @override
  String get paymentErrorNotPermitted =>
      'You are not allowed to record this payment';

  @override
  String paymentErrorLimit(String limit) {
    return 'Payments above $limit need an Accountant or Owner';
  }

  @override
  String get paymentErrorFinance =>
      'Bank, UPI and cheque payments need finance access';

  @override
  String get paymentErrorNotFound =>
      'The party or bank account no longer exists';

  @override
  String get paymentErrorLocked =>
      'This payment or cheque can no longer change';

  @override
  String get paymentErrorAmount => 'Enter an amount above zero';

  @override
  String get paymentErrorBank => 'Choose a bank account';

  @override
  String get paymentErrorChequeNo => 'Enter the cheque number';

  @override
  String get paymentErrorChequeDate => 'Enter the cheque date';

  @override
  String get paymentErrorChequeDetails =>
      'Cheque details only go with a cheque';

  @override
  String get paymentNoBankAccounts =>
      'No bank accounts yet. Add one under Bank accounts.';

  @override
  String get accountsTitle => 'Bank accounts';

  @override
  String get accountsAdd => 'Add bank account';

  @override
  String get accountsEdit => 'Edit bank account';

  @override
  String get accountsEmpty => 'No bank accounts yet';

  @override
  String get accountCash => 'Cash';

  @override
  String get accountFieldName => 'Account name';

  @override
  String get accountFieldBank => 'Bank name';

  @override
  String get accountFieldLast4 => 'Last 4 digits of account number';

  @override
  String get accountFieldIfsc => 'IFSC';

  @override
  String get accountBookBalance => 'Book balance';

  @override
  String get accountSwitchOff => 'Switch off';

  @override
  String get accountSwitchOn => 'Switch on';

  @override
  String get accountInactive => 'Off';

  @override
  String get accountErrorName => 'Enter an account name';

  @override
  String get accountErrorLast4 => 'Exactly 4 digits';

  @override
  String get accountErrorIfsc => 'Not a valid IFSC (e.g. SBIN0001234)';

  @override
  String get accountErrorNotPermitted => 'Bank accounts need finance access';

  @override
  String get receiptReceivedFrom => 'Received from';

  @override
  String get receiptPaidTo => 'Paid to';

  @override
  String get receiptNo => 'No.';

  @override
  String get receiptDate => 'Date';

  @override
  String get receiptAmount => 'Amount';

  @override
  String get receiptMode => 'Mode';

  @override
  String get receiptReference => 'Reference';

  @override
  String get receiptChequeNo => 'Cheque no.';

  @override
  String get receiptChequeDate => 'Cheque date';

  @override
  String get receiptBalanceAfter => 'Balance after this';

  @override
  String get receiptSignature => 'Signature';

  @override
  String get receiptReversed => 'REVERSED';

  @override
  String get settingBusinessMunshiPaymentLimit =>
      'Payment limit without an Accountant (₹, 0 = none)';

  @override
  String dashHeroLots(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lots in today',
      one: '1 lot in today',
    );
    return '$_temp0 · $amount arhat earned';
  }

  @override
  String get dashHeroNoLots => 'No lots in yet today';

  @override
  String get dashWeOweFarmers => 'We owe farmers';

  @override
  String get dashOthersOweUs => 'Others owe us';

  @override
  String get dashActionAddFarmer => 'Add farmer';

  @override
  String get dashStatLots => 'Lots in today';

  @override
  String dashStatQtl(String qtl) {
    return '$qtl qtl';
  }

  @override
  String get dashStatEarned => 'Arhat earned today';

  @override
  String get dashStatPaid => 'Paid out today';

  @override
  String get dashStatReceipts => 'Receipts today';

  @override
  String get dashChartTitle => 'Arhat earned · last 10 days';

  @override
  String get dashChartEmpty => 'No arhat earned in these days yet';

  @override
  String dashCropMixTitle(String year) {
    return 'Crop mix by sale value · $year';
  }

  @override
  String get dashCropMixEmpty => 'No posted sales this season yet';

  @override
  String dashCropMixLots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lots',
      one: '1 lot',
    );
    return '$_temp0';
  }

  @override
  String get dashMoneyTitle => 'Where the money is';

  @override
  String get dashFarmersPayable => 'Farmer khata · we owe';

  @override
  String get dashFarmersReceivable => 'Farmer khata · farmers owe us';

  @override
  String get dashOthersReceivable => 'Other parties owe us';

  @override
  String get dashNeedsTitle => 'Needs you today';

  @override
  String get dashNeedsNothing => 'Nothing needs you right now';

  @override
  String dashNeedsSyncErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes were rejected by the server',
      one: '1 change was rejected by the server',
    );
    return '$_temp0';
  }

  @override
  String dashNeedsCheques(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cheques due',
      one: '1 cheque due',
    );
    return '$_temp0 · $amount';
  }

  @override
  String dashNeedsStaff(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes by munshis in the last 7 days',
      one: '1 change by a munshi in the last 7 days',
    );
    return '$_temp0';
  }

  @override
  String get dashStatEarnedSub => 'from posted lots';

  @override
  String get dashStatPaidSub => 'to parties';

  @override
  String get dashStatReceiptsSub => 'from parties';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportOutstanding => 'Outstanding (baki)';

  @override
  String get reportArrivals => 'Arrival register';

  @override
  String get reportCommission => 'Commission earned';

  @override
  String get reportPayments => 'Payment register';

  @override
  String get reportStatements => 'Party statements';

  @override
  String get reportColCode => 'Code';

  @override
  String get reportColParty => 'Party';

  @override
  String get reportColVillage => 'Village';

  @override
  String get reportColWeOwe => 'We owe';

  @override
  String get reportColTheyOwe => 'They owe us';

  @override
  String get reportColLastEntry => 'Last entry';

  @override
  String get reportColDays => 'Days';

  @override
  String get reportColAgeing => 'Age band';

  @override
  String get reportColLot => 'Lot';

  @override
  String get reportColDate => 'Date';

  @override
  String get reportColFarmer => 'Farmer';

  @override
  String get reportColCrop => 'Crop';

  @override
  String get reportColBags => 'Bags';

  @override
  String get reportColQtl => 'Qtl';

  @override
  String get reportColRate => 'Rate / qtl';

  @override
  String get reportColGross => 'Gross';

  @override
  String get reportColCharges => 'Charges';

  @override
  String get reportColNet => 'Net to farmer';

  @override
  String get reportColBuyer => 'Buyer';

  @override
  String get reportColStatus => 'Status';

  @override
  String get reportColLots => 'Lots';

  @override
  String get reportColSaleValue => 'Sale value';

  @override
  String get reportColArhat => 'Arhat';

  @override
  String get reportColReceipt => 'Receipt no.';

  @override
  String get reportColMode => 'Mode';

  @override
  String get reportColReceived => 'Received';

  @override
  String get reportColPaid => 'Paid';

  @override
  String get reportColReference => 'Reference';

  @override
  String get reportColOpening => 'Opening';

  @override
  String get reportColUdhaar => 'Udhaar';

  @override
  String get reportColJama => 'Jama';

  @override
  String get reportColClosing => 'Closing baki';

  @override
  String get reportTotal => 'Total';

  @override
  String get reportAgeUpTo30 => '0–30 days';

  @override
  String get reportAgeUpTo90 => '31–90 days';

  @override
  String get reportAgeUpTo180 => '91–180 days';

  @override
  String get reportAgeOver180 => 'Over 180 days';

  @override
  String get reportAgeingTitle => 'Ageing';

  @override
  String reportAsOf(String date) {
    return 'As of $date';
  }

  @override
  String reportPeriod(String range) {
    return 'Period: $range';
  }

  @override
  String get reportSideAll => 'All';

  @override
  String get reportSidePayable => 'We owe';

  @override
  String get reportSideReceivable => 'They owe us';

  @override
  String get reportFilterAllCrops => 'All crops';

  @override
  String get reportFilterAllModes => 'All modes';

  @override
  String get reportFilterAllVillages => 'All villages';

  @override
  String get reportFilterAsOf => 'As of date';

  @override
  String get reportExportPdf => 'PDF';

  @override
  String get reportExportExcel => 'Excel';

  @override
  String get reportExportCsv => 'CSV';

  @override
  String get reportPrint => 'Print';

  @override
  String get reportExportLocked => 'Exporting needs finance access';

  @override
  String get reportRestricted => 'This report needs finance access';

  @override
  String reportRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows',
      one: '1 row',
    );
    return '$_temp0';
  }

  @override
  String get reportEmpty => 'Nothing to show for these filters';

  @override
  String reportExportSaved(String name) {
    return 'Saved $name';
  }

  @override
  String reportExportFailed(String error) {
    return 'Could not export: $error';
  }

  @override
  String get reportStatementsHelp =>
      'One PDF with a statement for every farmer of the village, each starting on a new page.';

  @override
  String reportStatementsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count farmers',
      one: '1 farmer',
    );
    return '$_temp0';
  }

  @override
  String get reportStatementsPdf => 'Statements PDF';

  @override
  String get teamTitle => 'Users & permissions';

  @override
  String get teamTabPeople => 'People';

  @override
  String get teamTabDevices => 'Devices';

  @override
  String get teamInvite => 'Invite someone';

  @override
  String get teamNoAccess => 'Only the owner can manage users.';

  @override
  String get teamYou => 'You';

  @override
  String get teamInactive => 'Deactivated';

  @override
  String teamDevicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices',
      one: '1 device',
      zero: 'No devices',
    );
    return '$_temp0';
  }

  @override
  String get teamPendingInvites => 'Waiting to join';

  @override
  String teamInviteExpires(String date) {
    return 'Expires $date';
  }

  @override
  String get teamInviteExpired => 'Expired';

  @override
  String get teamInviteCancel => 'Cancel invite';

  @override
  String get teamInviteCancelled => 'Invite cancelled';

  @override
  String get teamEmptyPeople => 'No one here yet.';

  @override
  String get teamEmptyDevices => 'No devices yet.';

  @override
  String get teamRole => 'Role';

  @override
  String get teamPermissions => 'What they can do';

  @override
  String get teamPermissionsHelp =>
      'Switch a permission on or off for this person. A dot marks a change from the role\'s default.';

  @override
  String get teamPermissionChanged => 'Different from the role default';

  @override
  String get teamPermissionSensitive => 'Powerful: grant with care';

  @override
  String get teamOwnerAll =>
      'Owners can do everything. This cannot be changed.';

  @override
  String get teamDeviceLimit => 'Devices allowed';

  @override
  String get teamSave => 'Save changes';

  @override
  String get teamSaved => 'Saved';

  @override
  String get teamDeactivate => 'Deactivate';

  @override
  String get teamReactivate => 'Reactivate';

  @override
  String teamDeactivateTitle(String name) {
    return 'Deactivate $name?';
  }

  @override
  String get teamDeactivateBody =>
      'They can no longer open this business and its data leaves their devices. Their past entries stay in the books.';

  @override
  String get teamDeactivated => 'Deactivated';

  @override
  String get teamReactivated => 'Reactivated';

  @override
  String get teamErrLastOwner =>
      'A business must keep at least one active owner.';

  @override
  String get teamErrProtected =>
      'Only an owner can change an owner, and you cannot change your own access.';

  @override
  String get teamErrNotFound => 'This person was not found.';

  @override
  String get teamDeviceThis => 'This device';

  @override
  String teamDeviceLastSeen(String when) {
    return 'Last seen $when';
  }

  @override
  String get teamDeviceNeverSeen => 'Not seen yet';

  @override
  String get teamDeviceRevoke => 'Revoke';

  @override
  String get teamDeviceRevoked => 'Revoked';

  @override
  String teamRevokeTitle(String code) {
    return 'Revoke device $code?';
  }

  @override
  String get teamRevokeBody =>
      'It stops syncing and the app on it is blocked. Changes it made while offline are rejected. This cannot be undone; the person can set up a new device.';

  @override
  String get teamRevokeDone => 'Device revoked';

  @override
  String get teamErrThisDevice => 'You cannot revoke the device you are using.';

  @override
  String get permission_partiesManage => 'View and add parties';

  @override
  String get permission_arrivalsManage => 'Arrivals and lots';

  @override
  String get permission_paymentsCreate => 'Record payments';

  @override
  String get permission_entriesReverse => 'Edit or reverse past entries';

  @override
  String get permission_loansManage => 'Issue loans, change interest';

  @override
  String get permission_financeView => 'Bank details, profit, report export';

  @override
  String get permission_adminManage => 'Users, modules, subscription';

  @override
  String get permission_masterDelete => 'Delete parties and other master data';

  @override
  String get permission_settingsManage => 'Business-wide settings';

  @override
  String get permission_auditView => 'View the audit log';

  @override
  String get inviteTitle => 'Invite someone';

  @override
  String get invitePhone => 'Mobile number';

  @override
  String get inviteName => 'Name (optional)';

  @override
  String get inviteChannel => 'Send by';

  @override
  String get inviteChannelWhatsapp => 'WhatsApp';

  @override
  String get inviteChannelSms => 'SMS';

  @override
  String get inviteSend => 'Send invite';

  @override
  String get inviteErrPhone => 'Enter a valid 10-digit mobile number.';

  @override
  String get inviteErrRole =>
      'This role cannot be invited. Owners are not added by invite.';

  @override
  String get inviteErrAlreadyMember => 'This person is already on your team.';

  @override
  String get inviteErrAlreadyInvited =>
      'This number already has a pending invite.';

  @override
  String get inviteErrNotAllowed => 'Only the owner can invite people.';

  @override
  String get inviteErrOffline =>
      'Inviting needs internet. Connect and try again.';

  @override
  String get inviteErrFailed => 'The invite couldn\'t be created. Try again.';

  @override
  String inviteSentWhatsapp(String phone) {
    return 'Invite sent on WhatsApp to $phone.';
  }

  @override
  String inviteSentSms(String phone) {
    return 'Invite sent by SMS to $phone.';
  }

  @override
  String get inviteNotSentTitle => 'Invite saved: send it yourself';

  @override
  String inviteNotSentBody(String phone) {
    return 'No message service is set up, so nothing was sent. Copy this message and send it to $phone. They join when they sign in with that number.';
  }

  @override
  String get inviteCopy => 'Copy message';

  @override
  String get inviteCopied => 'Copied';

  @override
  String get deviceRevokedTitle => 'This device was removed';

  @override
  String get deviceRevokedBody =>
      'The owner revoked this device. Nothing more can be saved from here. Changes made offline were not accepted.';

  @override
  String get deviceRevokedSetupAgain => 'Set up this device again';

  @override
  String get tenantPickerCheckInvites => 'Check for invitations';

  @override
  String get tenantPickerNoInvites =>
      'No invitation found for your number yet.';

  @override
  String get tenantPickerInvitesOffline =>
      'Connect to the internet to check for invitations.';

  @override
  String deviceSetupLimit(String business) {
    return 'This account already uses all its devices in $business. Ask the owner to revoke an old one.';
  }

  @override
  String deviceSetupRevoked(String business) {
    return 'This device was removed by the owner of $business.';
  }

  @override
  String get auditTitle => 'Audit log';

  @override
  String get auditNoAccess => 'Only the owner can see the audit log.';

  @override
  String get auditFilterUser => 'Person';

  @override
  String get auditFilterTable => 'Record type';

  @override
  String get auditAllUsers => 'Everyone';

  @override
  String get auditAllTables => 'All records';

  @override
  String get auditOnlyMoney => 'Money edits and reversals only';

  @override
  String get auditEmpty => 'No entries match.';

  @override
  String get auditShowMore => 'Show more';

  @override
  String get auditBadgeMoneyEdit => 'Amount changed';

  @override
  String get auditBadgeReversal => 'Reversal';

  @override
  String auditByUser(String name, String role) {
    return '$name · $role';
  }

  @override
  String auditOnDevice(String code) {
    return 'device $code';
  }

  @override
  String get auditSystem => 'System';

  @override
  String auditMoreFields(int count) {
    return '+$count more';
  }

  @override
  String get auditEmptyValue => '—';

  @override
  String get auditYes => 'Yes';

  @override
  String get auditNo => 'No';

  @override
  String get auditAction_insert => 'Added';

  @override
  String get auditAction_update => 'Changed';

  @override
  String get auditAction_reverse => 'Reversed';

  @override
  String get auditAction_soft_delete => 'Deleted';

  @override
  String get auditAction_restore => 'Restored';

  @override
  String get auditTable_ledger_entries => 'Khata entry';

  @override
  String get auditTable_payments => 'Payment';

  @override
  String get auditTable_cash_bank_entries => 'Cash / bank line';

  @override
  String get auditTable_lots => 'Lot';

  @override
  String get auditTable_parties => 'Party';

  @override
  String get auditTable_party_roles => 'Party role';

  @override
  String get auditTable_crops => 'Crop';

  @override
  String get auditTable_bank_accounts => 'Bank account';

  @override
  String get auditTable_settings => 'Setting';

  @override
  String get auditTable_tenant_members => 'Team member';

  @override
  String get auditTable_member_invites => 'Invitation';

  @override
  String get auditTable_devices => 'Device';

  @override
  String get auditField_amount_paise => 'Amount';

  @override
  String get auditField_gross => 'Gross value';

  @override
  String get auditField_commission => 'Commission';

  @override
  String get auditField_net_to_farmer => 'Net to farmer';

  @override
  String get auditField_buyer_total => 'Buyer total';

  @override
  String get auditField_rate_paise_per_qtl => 'Rate per quintal';

  @override
  String get auditField_qtl_milli => 'Quintals';

  @override
  String get auditField_status => 'Status';

  @override
  String get auditField_role => 'Role';

  @override
  String get auditField_is_active => 'Active';

  @override
  String get auditField_device_limit => 'Devices allowed';

  @override
  String get auditField_custom_permissions => 'Permission changes';

  @override
  String get auditField_revoked_at => 'Revoked at';

  @override
  String get auditField_phone => 'Mobile';

  @override
  String get auditField_name => 'Name';

  @override
  String get auditField_cheque_status => 'Cheque';

  @override
  String get auditField_entry_date => 'Date';

  @override
  String get auditField_side => 'Side';

  @override
  String get auditField_direction => 'Direction';

  @override
  String get onboardingTitle => 'Set up your business';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Save and continue';

  @override
  String get onboardingFinish => 'Finish setup';

  @override
  String get onboardingSkip => 'Skip setup for now';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingErrNotPermitted =>
      'You do not have permission to save this.';

  @override
  String get onboardingErrInvalid =>
      'These details could not be saved. Please check them.';

  @override
  String get onboardingOwnerOnly =>
      'Only the business owner can run the setup.';

  @override
  String get onboardingBusinessTitle => 'Business details';

  @override
  String get onboardingBusinessHint =>
      'These print on receipts and statements.';

  @override
  String get onboardingBusinessName => 'Business name';

  @override
  String get onboardingLegalName => 'Legal name (optional)';

  @override
  String get onboardingGstin => 'GSTIN (optional)';

  @override
  String get onboardingPhone => 'Phone (optional)';

  @override
  String get onboardingAddress => 'Address (optional)';

  @override
  String get onboardingGstinInvalid => 'This GSTIN is not valid.';

  @override
  String get onboardingPhoneInvalid => 'Enter a 10-digit mobile number.';

  @override
  String get onboardingMandiTitle => 'Mandi and state';

  @override
  String get onboardingMandiHint => 'Where your shop is.';

  @override
  String get onboardingState => 'State';

  @override
  String get onboardingStateOther => 'Other / not listed';

  @override
  String get onboardingMandiName => 'Mandi (market yard)';

  @override
  String get onboardingMandiNameHint => 'e.g. Khanna, Nabha';

  @override
  String get onboardingCropsTitle => 'Crops you deal in';

  @override
  String get onboardingCropsHint =>
      'Switched-off crops stay hidden in forms. You can change this later.';

  @override
  String get onboardingCropsNone => 'Choose at least one crop.';

  @override
  String get onboardingSelectAll => 'Select all';

  @override
  String get onboardingSelectNone => 'Clear all';

  @override
  String get onboardingChargesTitle => 'Default commission and charges';

  @override
  String get onboardingChargesHint =>
      'Used on every lot unless a crop or farmer has its own rate.';

  @override
  String get onboardingChargesCascade =>
      'Each crop and each party can override these later.';

  @override
  String get onboardingNumberInvalid => 'Enter a valid number.';

  @override
  String get onboardingInterestTitle => 'Interest defaults';

  @override
  String get onboardingInterestHint => 'Your usual rate and method for byaj.';

  @override
  String get onboardingInterestStoredOnly =>
      'Saved only for now. Interest is calculated in a later update.';

  @override
  String get onboardingLanguageTitle => 'Language';

  @override
  String get onboardingLanguageHint =>
      'The app switches now. This is also the default for your business.';

  @override
  String get onboardingInviteTitle => 'Invite your munshi';

  @override
  String get onboardingInviteHint =>
      'Optional. They enter arrivals and payments at the gate.';

  @override
  String get onboardingInviteButton => 'Invite someone';

  @override
  String get onboardingInviteLater =>
      'Needs internet. You can also invite people later from Team.';

  @override
  String get onboardingDoneTitle => 'Your business is ready';

  @override
  String get onboardingDoneBody =>
      'Next, bring in your parties with their opening baki, or add them one by one.';

  @override
  String get onboardingDoneImport => 'Import opening balances';

  @override
  String get onboardingDoneAddParty => 'Add a party';

  @override
  String get onboardingDoneHome => 'Go to dashboard';

  @override
  String get auditTable_opening_balance_imports => 'Opening balance import';

  @override
  String get auditTable_tenants => 'Business details';

  @override
  String get obTitle => 'Import opening balances';

  @override
  String get obNoAccess =>
      'Only the owner or accountant can import opening balances.';

  @override
  String get obSourceTitle => 'Your file';

  @override
  String get obFormatHelp =>
      'One row per party. Columns: Name, Village, Mobile, Amount and Dr/Cr (or separate Udhaar and Jama columns). Code and Father are optional. CSV or Excel (.xlsx).';

  @override
  String get obChooseFile => 'Choose CSV or Excel file';

  @override
  String get obPasteLabel => 'Or paste from Excel';

  @override
  String get obPasteHint => 'Name, Village, Amount, Dr/Cr';

  @override
  String get obReadPasted => 'Read pasted table';

  @override
  String get obReadOldExcel =>
      'Old .xls files cannot be read. Save it as .xlsx or CSV and try again.';

  @override
  String get obReadUnreadable => 'This file could not be read.';

  @override
  String get obProblemEmpty => 'The file is empty.';

  @override
  String get obProblemNoName =>
      'The first row must be a header with a Name column.';

  @override
  String get obProblemNoAmount =>
      'No amount column found. Add Amount (with Dr/Cr), or Udhaar and Jama columns.';

  @override
  String obProblemTooMany(int max) {
    return 'Too many rows. Import at most $max parties at a time.';
  }

  @override
  String get obOptionsTitle => 'How to read it';

  @override
  String get obAsOn => 'Balances as on';

  @override
  String get obDefaultSide =>
      'If a row does not say Dr/Cr, treat the amount as';

  @override
  String get obSideNone => 'Not chosen';

  @override
  String get obSideUdhaar => 'Udhaar (party owes us)';

  @override
  String get obSideJama => 'Jama (we owe the party)';

  @override
  String get obDefaultRole => 'New parties are added as';

  @override
  String get obSumRows => 'Rows';

  @override
  String get obSumNewParties => 'New parties';

  @override
  String get obSumMatched => 'Existing parties';

  @override
  String get obSumProblems => 'Problem rows';

  @override
  String get obSumNet => 'Net';

  @override
  String get obNetWeOwe => 'we owe overall';

  @override
  String get obNetTheyOwe => 'they owe overall';

  @override
  String obMatchedWith(String name) {
    return 'Existing party: $name';
  }

  @override
  String obNewParty(String role) {
    return 'New party ($role)';
  }

  @override
  String get obErrNameMissing => 'Name is missing.';

  @override
  String get obErrAmountInvalid =>
      'Amount is not a valid number (up to 2 decimals).';

  @override
  String get obErrAmountNegative =>
      'Amount is negative. Use Dr/Cr instead of a minus sign.';

  @override
  String get obErrSideMissing =>
      'Not clear if this is udhaar or jama. Add Dr/Cr or choose above.';

  @override
  String get obErrSideUnknown => 'Dr/Cr value not understood.';

  @override
  String get obErrSideConflict => 'Both Udhaar and Jama have an amount.';

  @override
  String get obErrMobileInvalid => 'Mobile number is not valid.';

  @override
  String get obErrRoleUnknown => 'Party type not understood.';

  @override
  String obErrDuplicateInFile(String row) {
    return 'Same party as row $row.';
  }

  @override
  String obErrPossibleDuplicate(String code) {
    return 'A party with this name exists (code $code). Add its code, village or mobile to the row.';
  }

  @override
  String obErrCodeTaken(String code) {
    return 'Code $code belongs to a different party.';
  }

  @override
  String get obErrAlreadyHasOpening =>
      'This party already has an opening balance.';

  @override
  String get obWarnNoAmount =>
      'No amount: the party is added without an opening balance.';

  @override
  String get obWarnNameDiffers =>
      'Matched by code, but the name differs from the saved party.';

  @override
  String get obWarnMobileOfOther =>
      'This mobile number is already used by another party.';

  @override
  String get obProblemsOnly => 'Problems only';

  @override
  String obImportButton(int count) {
    return 'Import $count balances';
  }

  @override
  String obImportValidButton(int count, int skipped) {
    return 'Import $count balances, skip $skipped problem rows';
  }

  @override
  String get obConfirmTitle => 'Import opening balances?';

  @override
  String obConfirmBody(
    int entries,
    int parties,
    String udhaar,
    String jama,
    String date,
  ) {
    return '$entries balances and $parties new parties as on $date. Udhaar $udhaar, Jama $jama. Entries cannot be edited later, only reversed.';
  }

  @override
  String get obImportNow => 'Import';

  @override
  String get obResAlready =>
      'This exact file was already imported for this date.';

  @override
  String get obResNothing =>
      'Nothing to import: everything is already in the books.';

  @override
  String get obResNotPermitted =>
      'You do not have permission to import opening balances.';

  @override
  String get obResBadDate => 'The date cannot be in the future.';

  @override
  String obResStale(int row) {
    return 'Row $row changed since the preview (another device?). Nothing was imported; the preview was refreshed.';
  }

  @override
  String get obDoneTitle => 'Opening balances imported';

  @override
  String obDoneBody(int entries, int parties, String udhaar, String jama) {
    return '$entries balances posted, $parties parties added. Udhaar $udhaar, Jama $jama.';
  }

  @override
  String get obDoneParties => 'View parties';

  @override
  String get onboardingCropsEmpty =>
      'No crops have arrived on this device yet. They sync from the server; you can pick them later under Crops.';

  @override
  String get onboardingInterestRatePerMonthLabel =>
      'Interest rate (₹ per 100 per month)';

  @override
  String updateAvailableTitle(String version) {
    return 'Mandi Khata $version is available';
  }

  @override
  String updateRequiredTitle(String version) {
    return 'Please update Mandi Khata to $version. This version is no longer supported.';
  }

  @override
  String get updateDownload => 'Download';

  @override
  String get updateLater => 'Later';

  @override
  String get loansTitle => 'Loans (karza)';

  @override
  String get loansIssue => 'Issue loan';

  @override
  String get loansEmpty => 'No loans here yet';

  @override
  String get loansSearchHint => 'Search borrower or loan number';

  @override
  String get loansFilterOpen => 'Open';

  @override
  String get loansFilterClosed => 'Closed';

  @override
  String get loansFilterAll => 'All';

  @override
  String get loansTotalCount => 'Open loans';

  @override
  String get loansTotalPrincipal => 'Principal out';

  @override
  String get loansTotalInterest => 'Byaj due';

  @override
  String get loansTotalOverdue => 'Overdue';

  @override
  String loanCardIssued(String amount) {
    return 'Issued $amount';
  }

  @override
  String get loanCardOutstanding => 'Principal';

  @override
  String get loanCardByaj => 'Byaj';

  @override
  String get loanCardPayable => 'Payable';

  @override
  String loanCardRecovered(String percent) {
    return '$percent% recovered';
  }

  @override
  String loanCardDaysLeft(String count) {
    return '$count days left';
  }

  @override
  String get loanCardDueToday => 'Due today';

  @override
  String loanCardOverdue(String count) {
    return '$count days overdue';
  }

  @override
  String get loanCardNoDue => 'No due date';

  @override
  String loanCardDue(String date) {
    return 'Due $date';
  }

  @override
  String get loanHealthOnTrack => 'On track';

  @override
  String get loanHealthDueSoon => 'Due soon';

  @override
  String get loanHealthOverdue => 'Overdue';

  @override
  String get loanHealthSettled => 'Paid up';

  @override
  String get loanStatusClosed => 'Closed';

  @override
  String get loanStatusWrittenOff => 'Written off';

  @override
  String get loanIssueTitle => 'Issue loan';

  @override
  String get loanFieldBorrower => 'Borrower';

  @override
  String get loanFieldAmount => 'Loan amount';

  @override
  String get loanFieldIssueDate => 'Issue date';

  @override
  String get loanFieldDueDate => 'Due date (optional)';

  @override
  String get loanFieldPurpose => 'Purpose';

  @override
  String get loanFieldGuarantor => 'Guarantor (optional)';

  @override
  String get loanFieldNotes => 'Notes';

  @override
  String get loanClearDate => 'Clear date';

  @override
  String get loanTermsTitle => 'Interest terms';

  @override
  String loanTermsFrom(String source) {
    return '$source. Changes here apply to this loan only.';
  }

  @override
  String get loanFieldRate => 'Interest rate';

  @override
  String get loanTermsMore => 'More terms';

  @override
  String get loanPayOutTitle => 'How is the money given?';

  @override
  String loanNextNo(String no) {
    return 'Loan no. $no';
  }

  @override
  String get loanNoticeNetUdhaar =>
      'Your business charges interest on the whole khata. This loan keeps its own interest account, so do not charge the same money again on the khata.';

  @override
  String get loanSaveIssue => 'Issue loan';

  @override
  String loanIssuedAs(String no) {
    return 'Loan $no issued';
  }

  @override
  String get loanDetailAsOf => 'As of date';

  @override
  String get loanDetailToday => 'Today';

  @override
  String loanPayableOn(String date) {
    return 'Payable on $date';
  }

  @override
  String get loanPrincipalOutstanding => 'Principal outstanding';

  @override
  String get loanInterestAccrued => 'Byaj accrued';

  @override
  String get loanInterestRecovered => 'Byaj recovered';

  @override
  String get loanPrincipalRecovered => 'Principal recovered';

  @override
  String get loanCurrentRate => 'Rate';

  @override
  String loanRatePa(String rate) {
    return '$rate% a year';
  }

  @override
  String loanRatePerMonth(String rate) {
    return '₹$rate per 100 per month';
  }

  @override
  String get loanTermsSummary => 'Terms';

  @override
  String get loanInterestFree => 'No interest';

  @override
  String loanGraceDays(String count) {
    return '$count days grace';
  }

  @override
  String get loanActionRepay => 'Record repayment';

  @override
  String get loanActionRate => 'Change rate';

  @override
  String get loanActionClose => 'Close loan';

  @override
  String get loanActionWriteOff => 'Write off';

  @override
  String get loanBorrowerLink => 'Open khata';

  @override
  String get loanNotFound => 'Loan not found';

  @override
  String loanClosedOn(String status, String date) {
    return '$status on $date';
  }

  @override
  String get loanStmtTitle => 'Interest statement';

  @override
  String get loanStmtEmpty => 'No entries yet';

  @override
  String get loanColFrom => 'From';

  @override
  String get loanColTo => 'To';

  @override
  String get loanColEvent => 'Event';

  @override
  String get loanColDebit => 'Given';

  @override
  String get loanColCredit => 'Received';

  @override
  String get loanColDays => 'Days';

  @override
  String get loanColPrincipal => 'Principal';

  @override
  String get loanColRate => 'Rate %';

  @override
  String get loanColInterest => 'Byaj';

  @override
  String get loanRowAccrue => 'Interest for the days';

  @override
  String get loanRowDebit => 'Loan given';

  @override
  String get loanRowCredit => 'Repayment';

  @override
  String get loanRowCompound => 'Byaj added to principal';

  @override
  String loanRowRate(String rate) {
    return 'Rate changed to $rate%';
  }

  @override
  String loanRowSplit(String interest, String principal) {
    return 'Byaj $interest · Principal $principal';
  }

  @override
  String loanRowSurplus(String amount) {
    return 'Extra $amount kept as credit';
  }

  @override
  String get loanRateChangesTitle => 'Rate changes';

  @override
  String get loanRateAtIssue => 'At issue';

  @override
  String get loanRepayTitle => 'Record repayment';

  @override
  String get loanRepayAmount => 'Amount received';

  @override
  String get loanRepayDate => 'Date';

  @override
  String get loanRepaySourcePay => 'Money received';

  @override
  String get loanRepaySourceCrop => 'From crop proceeds';

  @override
  String loanRepayCropAvailable(String amount) {
    return 'Crop proceeds in the khata: $amount';
  }

  @override
  String get loanRepayCropNone =>
      'This party has no crop proceeds in the khata to set off.';

  @override
  String get loanRepayFullPayable => 'Full payable';

  @override
  String get loanPreviewTitle => 'This repayment';

  @override
  String get loanPreviewInterest => 'Pays byaj';

  @override
  String get loanPreviewPrincipal => 'Pays principal';

  @override
  String get loanPreviewBefore => 'Payable before';

  @override
  String get loanPreviewAfter => 'Payable after';

  @override
  String get loanPreviewCropNote =>
      'The party\'s net khata balance does not change; the loan is paid off against their crop proceeds.';

  @override
  String get loanRepaySave => 'Record repayment';

  @override
  String get loanRepaid => 'Repayment recorded';

  @override
  String get loanRateTitle => 'Change interest rate';

  @override
  String loanRateCurrent(String rate) {
    return 'Current rate: $rate';
  }

  @override
  String get loanRateNew => 'New rate';

  @override
  String get loanRateEffective => 'Effective from';

  @override
  String get loanRateReason => 'Reason (optional)';

  @override
  String get loanRateSave => 'Change rate';

  @override
  String get loanRateChanged => 'Rate changed';

  @override
  String get loanCloseTitle => 'Close loan';

  @override
  String get loanWriteOffTitle => 'Write off loan';

  @override
  String get loanCloseDate => 'Closing date';

  @override
  String get loanCloseReason => 'Reason';

  @override
  String get loanCloseReasonOptional => 'Note (optional)';

  @override
  String loanCloseStillDue(String amount) {
    return '$amount is still due. Record the repayment first, or write the loan off.';
  }

  @override
  String get loanCloseAllPaid =>
      'Nothing is due. Closing records that the loan is fully paid.';

  @override
  String loanWriteOffBody(String amount) {
    return '$amount will be written off and the interest stops. The party\'s khata still shows what they owe until you waive it. This cannot be undone.';
  }

  @override
  String get loanCloseConfirm => 'Close loan';

  @override
  String get loanWriteOffConfirm => 'Write off';

  @override
  String get loanClosedDone => 'Loan closed';

  @override
  String get loanWrittenOffDone => 'Loan written off';

  @override
  String get loanErrorAmount => 'Enter the amount';

  @override
  String get loanErrorDue => 'The due date cannot be before the issue date';

  @override
  String get loanErrorGuarantor => 'The borrower cannot be their own guarantor';

  @override
  String get loanErrorRate => 'Enter a rate from 0 to 100 (up to 4 decimals)';

  @override
  String get loanErrorEffective =>
      'A rate cannot start before the loan was issued';

  @override
  String get loanErrorNotActive => 'This loan is already closed';

  @override
  String get loanErrorStillDue => 'Something is still due on this loan';

  @override
  String get loanErrorInterestNotPosted =>
      'Post the interest of this loan to the khata first; a closed loan cannot be charged any more';

  @override
  String get loanErrorNothingToWriteOff =>
      'Nothing is left to write off; close the loan instead';

  @override
  String get loanErrorReason => 'Give a reason';

  @override
  String get loanErrorClosedBefore =>
      'The date cannot be before the last entry of this loan';

  @override
  String get loanErrorNotPermitted => 'Only the owner can do this';

  @override
  String get loanErrorNotPermittedRepay =>
      'You need permission to record payments (and an Accountant or Owner to adjust crop proceeds)';

  @override
  String get loanErrorNotFound =>
      'The party, loan or bank account was not found in this business';

  @override
  String loanErrorExceeds(String payable) {
    return 'More than the $payable due on this day. Record only what is due.';
  }

  @override
  String loanErrorExceedsCrop(String available) {
    return 'More than the crop proceeds in the khata ($available)';
  }

  @override
  String get paymentLoanNote =>
      'This payment belongs to a loan. A repayment can be reversed here while the loan is open; the money given out for a loan cannot be reversed.';

  @override
  String get paymentLoanLink => 'Open loan';

  @override
  String get loanOpenFromParty => 'Loans';

  @override
  String get partyTabByaj => 'Byaj';

  @override
  String get byajNoInterest => 'No interest is charged on this party.';

  @override
  String get byajLoansOnly =>
      'Interest runs on this party\'s individual loans only. See the Loans tab.';

  @override
  String get byajKhataNote =>
      'Byaj runs on the whole khata, loans included. A loan of this party does not charge byaj a second time.';

  @override
  String get byajLoanCoveredNote =>
      'This loan has its own byaj on the terms it was issued with. The party\'s khata byaj does not include it, and changing the default rate does not change it.';

  @override
  String get byajTermsTitle => 'Interest terms';

  @override
  String get byajEditTerms => 'Edit terms';

  @override
  String byajSourced(String value, String source) {
    return '$value · $source';
  }

  @override
  String get byajCreditBalance => 'Credit we hold for the party';

  @override
  String get byajRowDebit => 'Udhaar entry';

  @override
  String get byajRowCredit => 'Jama entry';

  @override
  String get byajNoEntries => 'No entries in the khata yet';

  @override
  String byajDialogTitle(String name) {
    return 'Byaj terms · $name';
  }

  @override
  String get byajDialogHint =>
      'Only what you change is kept for this party. The rest keeps following the business default.';

  @override
  String get byajUseDefaults => 'Use business defaults';

  @override
  String get byajSave => 'Save terms';

  @override
  String get byajSaved => 'Interest terms saved';

  @override
  String get byajNoPermission =>
      'Changing interest terms needs the loans permission (owner).';

  @override
  String get byajBulkOpen => 'Set interest for many parties';

  @override
  String get byajBulkTitle => 'Set interest for many parties';

  @override
  String get byajBulkIntro =>
      'Pick the parties (for example one village), set the terms, and apply. Each party gets its own terms, which win over the business default.';

  @override
  String get byajBulkVillage => 'Village';

  @override
  String get byajBulkAllVillages => 'All villages';

  @override
  String get byajBulkSelectAll => 'Select all shown';

  @override
  String get byajBulkNone => 'No parties match';

  @override
  String byajBulkApply(int count) {
    return 'Apply to $count parties';
  }

  @override
  String byajBulkDone(int count) {
    return 'Interest terms set for $count parties';
  }

  @override
  String get byajBulkFailed =>
      'Some parties could not be saved. Check your permission and try again.';

  @override
  String get postInterestTitle => 'Post interest';

  @override
  String get postInterestIntro =>
      'This adds the interest charged so far to the khata as one udhaar entry. Nothing is posted until you confirm.';

  @override
  String get postInterestNone => 'No interest to post for today.';

  @override
  String postInterestConfirm(String amount) {
    return 'Post $amount';
  }

  @override
  String postInterestDone(String amount) {
    return 'Interest posted: $amount';
  }

  @override
  String get postInterestAmount => 'Interest to post';

  @override
  String get postColParty => 'Party';

  @override
  String get postColAccount => 'Account';

  @override
  String get postColPeriod => 'Period';

  @override
  String get postColTerms => 'Terms';

  @override
  String get postAccountKhata => 'Whole khata';

  @override
  String postAccountLoan(String no) {
    return 'Loan $no';
  }

  @override
  String postPeriod(String from, String to) {
    return '$from to $to';
  }

  @override
  String postTerms(String rate, String method) {
    return '$rate% p.a., $method';
  }

  @override
  String get postSkipAlready => 'Already posted up to this day';

  @override
  String get postSkipNotFound => 'The party or loan was not found';

  @override
  String get postSkipBackdated =>
      'This date is too old for your role. Ask the owner.';

  @override
  String get postSkipChanged =>
      'The figures changed since you looked. Open the account again and check them.';

  @override
  String get postNothing => 'Nothing was posted.';

  @override
  String get postErrorNotPermitted =>
      'You are not allowed to post interest. Ask the owner.';

  @override
  String get postErrorFuture => 'Interest cannot be posted for a future date.';

  @override
  String get postBulkIntro =>
      'Interest charged up to the chosen day for every party and loan that has some. Untick what you do not want to post. Running it again never posts the same period twice.';

  @override
  String get postBulkAsOf => 'Interest up to';

  @override
  String postBulkSuggested(String date) {
    return 'Suggested: $date';
  }

  @override
  String get postBulkNone => 'No interest to post up to this day.';

  @override
  String postBulkTotal(int count, String amount) {
    return '$count selected · $amount';
  }

  @override
  String postBulkPost(int count) {
    return 'Post $count';
  }

  @override
  String postBulkDone(int count, String amount) {
    return 'Posted $count entries, $amount.';
  }

  @override
  String postBulkSkipped(int count) {
    return '$count left out (already posted or not allowed).';
  }

  @override
  String get byajPosted => 'Interest posted so far';

  @override
  String get byajUnposted => 'Charged, not yet posted';

  @override
  String get settleTitle => 'Hisaab karo';

  @override
  String get settleIntro =>
      'Settle this party up to a day: the interest is added to the khata, an optional discount is taken off, and the final amount is what the party pays or you pay.';

  @override
  String get settleAsOf => 'Settle up to';

  @override
  String get settleCropProceeds => 'Crop proceeds';

  @override
  String get settlePayments => 'Payments and receipts';

  @override
  String get settleLoans => 'Loans (given and repaid)';

  @override
  String get settleInterestPosted => 'Interest already posted';

  @override
  String get settleKhataBalance => 'Khata balance now';

  @override
  String get settleNothing => 'No interest is due on this date.';

  @override
  String get settleReason => 'Reason for the discount';

  @override
  String get settleWaiver => 'Discount on interest';

  @override
  String get settleInterestDue => 'Interest to pay';

  @override
  String get settleReceivable => 'Party pays you';

  @override
  String get settlePayable => 'You pay the party';

  @override
  String get settleSettled => 'Settled';

  @override
  String settleDone(String interest, String waived) {
    return 'Settled. Interest $interest posted, $waived waived.';
  }

  @override
  String get settleNextHint =>
      'Now record the payment or receipt from the khata.';

  @override
  String get settlePrint => 'Print slip';

  @override
  String get settlePost => 'Post interest and settle';

  @override
  String get settleOpenKhata => 'Back to khata';

  @override
  String get settleInterestOnKhata => 'Interest on the khata';

  @override
  String settleInterestOnLoan(String no) {
    return 'Interest on loan $no';
  }

  @override
  String get settleErrorNegative => 'A discount cannot be negative.';

  @override
  String get settleErrorExceeds =>
      'The discount is more than the interest charged.';

  @override
  String get settleErrorReason => 'Write the reason for the discount.';

  @override
  String get settleErrorUnknown =>
      'There is no interest to waive on that account.';

  @override
  String get settleErrorNeedsReverse =>
      'A discount needs the accountant or owner.';

  @override
  String get slipTitle => 'Settlement slip (hisaab)';

  @override
  String slipAsOf(String date) {
    return 'Settled up to $date';
  }

  @override
  String slipReason(String reason) {
    return 'Reason for discount: $reason';
  }

  @override
  String get slipSignParty => 'Party signature';

  @override
  String get slipSignOwner => 'Authorised signature';

  @override
  String get settingBusinessCreditLimit =>
      'Credit limit per party (₹, 0 = none)';

  @override
  String get reportKarza => 'Karza register';

  @override
  String get reportInterestEarned => 'Interest earned';

  @override
  String get reportColLoan => 'Loan';

  @override
  String get reportColIssued => 'Issued';

  @override
  String get reportColDue => 'Due';

  @override
  String get reportColPrincipal => 'Principal';

  @override
  String get reportColRepaid => 'Repaid';

  @override
  String get reportColOutstanding => 'Outstanding';

  @override
  String get reportColInterestAccrued => 'Interest accrued';

  @override
  String get reportColInterestRecovered => 'Interest recovered';

  @override
  String get reportColDaysOverdue => 'Days overdue';

  @override
  String get reportColOverdueAge => 'Overdue age';

  @override
  String get reportColPosted => 'Posted to khata';

  @override
  String get reportColWaived => 'Waived';

  @override
  String get reportColUnposted => 'Accrued, not yet posted';

  @override
  String get reportColEarned => 'Earned (posted + accrued)';

  @override
  String get reportInterestHelp =>
      'Posted and waived are for the period. Accrued, not yet posted is as of today.';

  @override
  String reportKarzaOverdueCount(int count) {
    return '$count overdue';
  }

  @override
  String dashNeedsLoansOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count loans are overdue',
      one: '1 loan is overdue',
    );
    return '$_temp0';
  }

  @override
  String dashNeedsLoansDueSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count loans are due in 7 days',
      one: '1 loan is due in 7 days',
    );
    return '$_temp0';
  }

  @override
  String dashNeedsOverLimit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties are over the credit limit',
      one: '1 party is over the credit limit',
    );
    return '$_temp0';
  }

  @override
  String dashNeedsInterestUnposted(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
    );
    return 'Interest for the last quarter is not posted: $_temp0, $amount';
  }

  @override
  String get byajPrintStatement => 'Print byaj statement';

  @override
  String get byajStatementTitle => 'Byaj statement';

  @override
  String byajStatementTerms(String rate, String method) {
    return '$rate% p.a., $method';
  }
}
