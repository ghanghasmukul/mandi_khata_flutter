import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('pa'),
  ];

  /// Shown when this build has no sync server configured.
  ///
  /// In en, this message translates to:
  /// **'Sync off'**
  String get syncOff;

  /// Sync in progress.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncSyncing;

  /// Last sync under a minute ago.
  ///
  /// In en, this message translates to:
  /// **'Synced · just now'**
  String get syncSyncedJustNow;

  /// Minutes since the last sync.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Synced · 1 min ago} other{Synced · {count} min ago}}'**
  String syncSyncedMinutesAgo(int count);

  /// Hours since the last sync.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Synced · 1 hr ago} other{Synced · {count} hr ago}}'**
  String syncSyncedHoursAgo(int count);

  /// Not connected; nothing waiting to upload.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncOffline;

  /// Not connected; changes waiting to upload.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Offline · 1 queued} other{Offline · {count} queued}}'**
  String syncOfflineQueued(int count);

  /// Server permanently rejected some changes; tap for details.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sync error · 1 change rejected} other{Sync error · {count} changes rejected}}'**
  String syncErrorCount(int count);

  /// Title of the sync errors dialog.
  ///
  /// In en, this message translates to:
  /// **'Changes the server rejected'**
  String get syncErrorsTitle;

  /// Explains the sync errors dialog.
  ///
  /// In en, this message translates to:
  /// **'These changes were not saved online. Everything else keeps syncing.'**
  String get syncErrorsBody;

  /// Clears the list of rejected changes.
  ///
  /// In en, this message translates to:
  /// **'Dismiss all'**
  String get syncErrorsDismiss;

  /// Generic close button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic retry button.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// Shown while local data is being prepared after sign-in.
  ///
  /// In en, this message translates to:
  /// **'Getting things ready…'**
  String get splashLoading;

  /// Login screen heading.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Mandi Khata'**
  String get loginTitle;

  /// Login screen explanation for phone sign-in.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a 6-digit code to your mobile by SMS.'**
  String get loginSubtitle;

  /// Tab: sign in with phone OTP.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get loginTabPhone;

  /// Tab: sign in with email and password.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginTabEmail;

  /// Phone field label.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get loginPhoneLabel;

  /// Phone number validation error.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit Indian mobile number'**
  String get loginPhoneInvalid;

  /// Button that sends the SMS code.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get loginSendOtp;

  /// OTP field label.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get loginOtpLabel;

  /// Confirms where the SMS code went.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String loginOtpSentTo(String phone);

  /// OTP validation error.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get loginOtpInvalidFormat;

  /// Button that checks the SMS code.
  ///
  /// In en, this message translates to:
  /// **'Verify and sign in'**
  String get loginVerify;

  /// Countdown before the code can be resent.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String loginResendIn(int seconds);

  /// Button to resend the SMS code.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get loginResend;

  /// Go back and edit the phone number.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get loginChangeNumber;

  /// Email field label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// Password field label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// Email sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginEmailSignIn;

  /// Email form validation error.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password'**
  String get loginEmailInvalid;

  /// The app has no server configuration.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is not set up in this build.'**
  String get authErrorNotConfigured;

  /// Sign-in needs internet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Connect and try again.'**
  String get authErrorNetwork;

  /// Wrong or expired SMS code.
  ///
  /// In en, this message translates to:
  /// **'That code is wrong or has expired.'**
  String get authErrorInvalidOtp;

  /// Wrong email/password.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get authErrorInvalidCredentials;

  /// Rate limited by the server.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a few minutes and try again.'**
  String get authErrorRateLimited;

  /// Phone sign-in unavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the SMS. Try again later or sign in with email.'**
  String get authErrorSms;

  /// Unexpected sign-in error.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Try again.'**
  String get authErrorUnknown;

  /// Business picker heading.
  ///
  /// In en, this message translates to:
  /// **'Choose a business'**
  String get tenantPickerTitle;

  /// Business picker explanation.
  ///
  /// In en, this message translates to:
  /// **'You can switch later from the account menu.'**
  String get tenantPickerSubtitle;

  /// Waiting for the first sync after sign-in.
  ///
  /// In en, this message translates to:
  /// **'Downloading your businesses… This needs internet the first time.'**
  String get tenantPickerLoading;

  /// Sync is not configured.
  ///
  /// In en, this message translates to:
  /// **'Sync is not set up in this build, so your businesses can\'t be loaded.'**
  String get tenantPickerNoSync;

  /// Signed-in user belongs to no business.
  ///
  /// In en, this message translates to:
  /// **'No business linked yet'**
  String get tenantPickerEmptyTitle;

  /// Explains what to do with no business.
  ///
  /// In en, this message translates to:
  /// **'Your account isn\'t part of any business. Ask the owner to add you, then open the app again.'**
  String get tenantPickerEmptyBody;

  /// Device registration needs internet once per business.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet once to set up this device for {business}.'**
  String deviceSetupOffline(String business);

  /// Server refused device registration.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t be set up for {business}.'**
  String deviceSetupFailed(String business);

  /// Role name.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// Role name.
  ///
  /// In en, this message translates to:
  /// **'Accountant'**
  String get roleAccountant;

  /// Role name.
  ///
  /// In en, this message translates to:
  /// **'Munshi'**
  String get roleMunshi;

  /// Role name.
  ///
  /// In en, this message translates to:
  /// **'Custom role'**
  String get roleCustom;

  /// PIN setup heading.
  ///
  /// In en, this message translates to:
  /// **'Set an app PIN'**
  String get pinSetupTitle;

  /// Explains the app PIN.
  ///
  /// In en, this message translates to:
  /// **'Asked when the app opens, so others can\'t see your khata. 4–6 digits, stays on this device.'**
  String get pinSetupBody;

  /// PIN confirmation step.
  ///
  /// In en, this message translates to:
  /// **'Enter the PIN again'**
  String get pinConfirmTitle;

  /// The two PIN entries differ.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
  String get pinMismatch;

  /// PIN length validation.
  ///
  /// In en, this message translates to:
  /// **'Use 4 to 6 digits'**
  String get pinTooShort;

  /// Skip setting a PIN.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get pinSkip;

  /// Toast after setting the PIN.
  ///
  /// In en, this message translates to:
  /// **'App PIN saved'**
  String get pinSaved;

  /// Enable biometric unlock.
  ///
  /// In en, this message translates to:
  /// **'Also unlock with fingerprint or face'**
  String get pinBiometricOption;

  /// PIN pad backspace (screen reader).
  ///
  /// In en, this message translates to:
  /// **'Delete digit'**
  String get pinPadDelete;

  /// PIN pad confirm key.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get pinPadOk;

  /// Lock screen heading.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get lockTitle;

  /// Lock screen error.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get lockWrongPin;

  /// Lock screen cooldown.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong tries. Try again in {seconds}s.'**
  String lockCooldown(int seconds);

  /// Biometric unlock button.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint'**
  String get lockUseBiometric;

  /// System biometric prompt text.
  ///
  /// In en, this message translates to:
  /// **'Unlock Mandi Khata'**
  String get lockBiometricReason;

  /// Escape hatch from the lock screen.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN? Sign out'**
  String get lockForgotPin;

  /// Account menu tooltip.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountMenu;

  /// Account menu item.
  ///
  /// In en, this message translates to:
  /// **'Switch business'**
  String get accountSwitchBusiness;

  /// Account menu item.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get accountLockNow;

  /// Account menu item.
  ///
  /// In en, this message translates to:
  /// **'Set app PIN'**
  String get accountSetPin;

  /// Account menu item.
  ///
  /// In en, this message translates to:
  /// **'Change app PIN'**
  String get accountChangePin;

  /// Account menu item.
  ///
  /// In en, this message translates to:
  /// **'Remove app PIN'**
  String get accountRemovePin;

  /// Account menu item.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// Shows the device code (e.g. W1).
  ///
  /// In en, this message translates to:
  /// **'This device: {code}'**
  String homeDeviceCode(String code);

  /// Placeholder until the dashboard exists.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard will appear here.'**
  String get homePlaceholder;

  /// Sign-out confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// Sign-out confirmation body.
  ///
  /// In en, this message translates to:
  /// **'This device\'s copy of the data will be removed. You\'ll need internet to sign in again.'**
  String get signOutBody;

  /// Warns that unsynced changes would be lost.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change hasn\'t been uploaded yet. Signing out now deletes it from this device.} other{{count} changes haven\'t been uploaded yet. Signing out now deletes them from this device.}}'**
  String signOutPendingBody(int count);

  /// Wait for upload before signing out.
  ///
  /// In en, this message translates to:
  /// **'Upload, then sign out'**
  String get signOutUploadFirst;

  /// Sign out losing unsynced changes.
  ///
  /// In en, this message translates to:
  /// **'Sign out and delete them'**
  String get signOutAnyway;

  /// Progress while waiting for upload.
  ///
  /// In en, this message translates to:
  /// **'Uploading changes…'**
  String get signOutUploading;

  /// Upload did not finish in time.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload everything. Check the internet and try again.'**
  String get signOutUploadFailed;

  /// Label of setting interest.enabled.
  ///
  /// In en, this message translates to:
  /// **'Charge interest'**
  String get settingInterestEnabled;

  /// Label of setting interest.rate_pa.
  ///
  /// In en, this message translates to:
  /// **'Interest rate (% per year)'**
  String get settingInterestRatePa;

  /// Label of setting interest.rate_unit_display.
  ///
  /// In en, this message translates to:
  /// **'Show rate as'**
  String get settingInterestRateUnitDisplay;

  /// Label of setting interest.method.
  ///
  /// In en, this message translates to:
  /// **'Interest method'**
  String get settingInterestMethod;

  /// Label of setting interest.compounding.
  ///
  /// In en, this message translates to:
  /// **'Compounding period'**
  String get settingInterestCompounding;

  /// Label of setting interest.day_basis.
  ///
  /// In en, this message translates to:
  /// **'Days in a year'**
  String get settingInterestDayBasis;

  /// Label of setting interest.grace_days.
  ///
  /// In en, this message translates to:
  /// **'Grace days'**
  String get settingInterestGraceDays;

  /// Label of setting interest.appropriation.
  ///
  /// In en, this message translates to:
  /// **'Repayment goes first to'**
  String get settingInterestAppropriation;

  /// Label of setting interest.apply_on.
  ///
  /// In en, this message translates to:
  /// **'Charge interest on'**
  String get settingInterestApplyOn;

  /// Label of setting interest.min_days.
  ///
  /// In en, this message translates to:
  /// **'Ignore periods shorter than (days)'**
  String get settingInterestMinDays;

  /// Label of setting interest.rounding.
  ///
  /// In en, this message translates to:
  /// **'Round interest to'**
  String get settingInterestRounding;

  /// Label of setting interest.post_frequency.
  ///
  /// In en, this message translates to:
  /// **'Post interest to khata'**
  String get settingInterestPostFrequency;

  /// Label of setting interest.pay_on_jama.
  ///
  /// In en, this message translates to:
  /// **'Pay interest when we owe the party'**
  String get settingInterestPayOnJama;

  /// Label of setting interest.pay_rate_pa.
  ///
  /// In en, this message translates to:
  /// **'Rate paid on jama (% per year)'**
  String get settingInterestPayRatePa;

  /// Label of setting mandi.commission_pct.
  ///
  /// In en, this message translates to:
  /// **'Commission (arhat) %'**
  String get settingMandiCommissionPct;

  /// Label of setting mandi.palledari_per_bag.
  ///
  /// In en, this message translates to:
  /// **'Palledari per bag'**
  String get settingMandiPalledariPerBag;

  /// Label of setting mandi.bardana_per_bag.
  ///
  /// In en, this message translates to:
  /// **'Bardana per bag'**
  String get settingMandiBardanaPerBag;

  /// Label of setting mandi.tulai_per_qtl.
  ///
  /// In en, this message translates to:
  /// **'Tulai per quintal'**
  String get settingMandiTulaiPerQtl;

  /// Label of setting mandi.mandi_fee_pct.
  ///
  /// In en, this message translates to:
  /// **'Mandi fee %'**
  String get settingMandiMandiFeePct;

  /// Label of setting mandi.cess.
  ///
  /// In en, this message translates to:
  /// **'Cess'**
  String get settingMandiCess;

  /// Label of setting mandi.charges_borne_by.
  ///
  /// In en, this message translates to:
  /// **'Who pays each charge'**
  String get settingMandiChargesBorneBy;

  /// Label of setting mandi.bag_weight_kg.
  ///
  /// In en, this message translates to:
  /// **'Bag weight (kg)'**
  String get settingMandiBagWeightKg;

  /// Label of setting shop.price_tiers.
  ///
  /// In en, this message translates to:
  /// **'Price tiers'**
  String get settingShopPriceTiers;

  /// Label of setting shop.default_tier_for_role.
  ///
  /// In en, this message translates to:
  /// **'Default price tier'**
  String get settingShopDefaultTierForRole;

  /// Label of setting shop.allow_negative_stock.
  ///
  /// In en, this message translates to:
  /// **'Allow selling below zero stock'**
  String get settingShopAllowNegativeStock;

  /// Label of setting shop.expiry_warn_days.
  ///
  /// In en, this message translates to:
  /// **'Warn before expiry (days)'**
  String get settingShopExpiryWarnDays;

  /// Label of setting shop.gst_enabled.
  ///
  /// In en, this message translates to:
  /// **'GST on invoices'**
  String get settingShopGstEnabled;

  /// Label of setting shop.post_credit_sale_to_khata.
  ///
  /// In en, this message translates to:
  /// **'Post credit sales to khata'**
  String get settingShopPostCreditSaleToKhata;

  /// Label of setting business.fy_start_month.
  ///
  /// In en, this message translates to:
  /// **'Financial year starts in month'**
  String get settingBusinessFyStartMonth;

  /// Label of setting business.number_series.
  ///
  /// In en, this message translates to:
  /// **'Number series'**
  String get settingBusinessNumberSeries;

  /// Label of setting app.modules.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get settingAppModules;

  /// Label of setting app.languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get settingAppLanguages;

  /// Label of setting app.default_language.
  ///
  /// In en, this message translates to:
  /// **'Default language'**
  String get settingAppDefaultLanguage;

  /// Label of setting print.receipt_size.
  ///
  /// In en, this message translates to:
  /// **'Receipt paper'**
  String get settingPrintReceiptSize;

  /// Label of setting notify.whatsapp_receipts.
  ///
  /// In en, this message translates to:
  /// **'Send receipts on WhatsApp'**
  String get settingNotifyWhatsappReceipts;

  /// Option pa of interest.rate_unit_display.
  ///
  /// In en, this message translates to:
  /// **'% per year'**
  String get settingOptInterestRateUnitDisplayPa;

  /// Option per100_per_month of interest.rate_unit_display.
  ///
  /// In en, this message translates to:
  /// **'₹ per 100 per month'**
  String get settingOptInterestRateUnitDisplayPer100PerMonth;

  /// Option simple of interest.method.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get settingOptInterestMethodSimple;

  /// Option compound of interest.method.
  ///
  /// In en, this message translates to:
  /// **'Compound (chakravridhi)'**
  String get settingOptInterestMethodCompound;

  /// Option monthly of interest.compounding.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get settingOptInterestCompoundingMonthly;

  /// Option quarterly of interest.compounding.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get settingOptInterestCompoundingQuarterly;

  /// Option halfyearly of interest.compounding.
  ///
  /// In en, this message translates to:
  /// **'Half-yearly'**
  String get settingOptInterestCompoundingHalfyearly;

  /// Option yearly of interest.compounding.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get settingOptInterestCompoundingYearly;

  /// Option on_fy_close of interest.compounding.
  ///
  /// In en, this message translates to:
  /// **'At financial year close'**
  String get settingOptInterestCompoundingOnFyClose;

  /// Option interest_first of interest.appropriation.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get settingOptInterestAppropriationInterestFirst;

  /// Option principal_first of interest.appropriation.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get settingOptInterestAppropriationPrincipalFirst;

  /// Option net_udhaar of interest.apply_on.
  ///
  /// In en, this message translates to:
  /// **'Net udhaar only'**
  String get settingOptInterestApplyOnNetUdhaar;

  /// Option loans_only of interest.apply_on.
  ///
  /// In en, this message translates to:
  /// **'Loans (karza) only'**
  String get settingOptInterestApplyOnLoansOnly;

  /// Option none of interest.apply_on.
  ///
  /// In en, this message translates to:
  /// **'No interest'**
  String get settingOptInterestApplyOnNone;

  /// Option paise of interest.rounding.
  ///
  /// In en, this message translates to:
  /// **'Paise'**
  String get settingOptInterestRoundingPaise;

  /// Option rupee of interest.rounding.
  ///
  /// In en, this message translates to:
  /// **'Rupee'**
  String get settingOptInterestRoundingRupee;

  /// Option ten_rupee of interest.rounding.
  ///
  /// In en, this message translates to:
  /// **'₹10'**
  String get settingOptInterestRoundingTenRupee;

  /// Option on_demand of interest.post_frequency.
  ///
  /// In en, this message translates to:
  /// **'When I choose'**
  String get settingOptInterestPostFrequencyOnDemand;

  /// Option monthly of interest.post_frequency.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get settingOptInterestPostFrequencyMonthly;

  /// Option quarterly of interest.post_frequency.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get settingOptInterestPostFrequencyQuarterly;

  /// Option fy_close of interest.post_frequency.
  ///
  /// In en, this message translates to:
  /// **'At financial year close'**
  String get settingOptInterestPostFrequencyFyClose;

  /// Option en of app.default_language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingOptAppDefaultLanguageEn;

  /// Option hi of app.default_language.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get settingOptAppDefaultLanguageHi;

  /// Option pa of app.default_language.
  ///
  /// In en, this message translates to:
  /// **'ਪੰਜਾਬੀ'**
  String get settingOptAppDefaultLanguagePa;

  /// Option a5 of print.receipt_size.
  ///
  /// In en, this message translates to:
  /// **'A5 paper'**
  String get settingOptPrintReceiptSizeA5;

  /// Option thermal_80 of print.receipt_size.
  ///
  /// In en, this message translates to:
  /// **'Thermal 80 mm'**
  String get settingOptPrintReceiptSizeThermal80;

  /// Option thermal_58 of print.receipt_size.
  ///
  /// In en, this message translates to:
  /// **'Thermal 58 mm'**
  String get settingOptPrintReceiptSizeThermal58;

  /// role farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get settingSuffixRoleFarmer;

  /// role customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get settingSuffixRoleCustomer;

  /// role supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get settingSuffixRoleSupplier;

  /// role vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get settingSuffixRoleVendor;

  /// role agency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get settingSuffixRoleAgency;

  /// role buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get settingSuffixRoleBuyer;

  /// doc receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get settingSuffixDocReceipt;

  /// doc lot.
  ///
  /// In en, this message translates to:
  /// **'Lots'**
  String get settingSuffixDocLot;

  /// doc sales_invoice.
  ///
  /// In en, this message translates to:
  /// **'Sales invoices'**
  String get settingSuffixDocSalesInvoice;

  /// doc purchase_invoice.
  ///
  /// In en, this message translates to:
  /// **'Purchase invoices'**
  String get settingSuffixDocPurchaseInvoice;

  /// doc karza.
  ///
  /// In en, this message translates to:
  /// **'Karza'**
  String get settingSuffixDocKarza;

  /// doc voucher.
  ///
  /// In en, this message translates to:
  /// **'Vouchers'**
  String get settingSuffixDocVoucher;

  /// module khata.
  ///
  /// In en, this message translates to:
  /// **'Khata'**
  String get settingSuffixModuleKhata;

  /// module arrivals.
  ///
  /// In en, this message translates to:
  /// **'Arrivals & lots'**
  String get settingSuffixModuleArrivals;

  /// module karza.
  ///
  /// In en, this message translates to:
  /// **'Karza & byaj'**
  String get settingSuffixModuleKarza;

  /// module accounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get settingSuffixModuleAccounting;

  /// module shop.
  ///
  /// In en, this message translates to:
  /// **'Input shop'**
  String get settingSuffixModuleShop;

  /// Settings group interest.
  ///
  /// In en, this message translates to:
  /// **'Interest (byaj)'**
  String get settingsGroupInterest;

  /// Settings group mandi.
  ///
  /// In en, this message translates to:
  /// **'Mandi charges'**
  String get settingsGroupMandi;

  /// Settings group shop.
  ///
  /// In en, this message translates to:
  /// **'Input shop'**
  String get settingsGroupShop;

  /// Settings group business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get settingsGroupBusiness;

  /// Settings group modules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get settingsGroupModules;

  /// Settings group app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsGroupApp;

  /// Settings group print.
  ///
  /// In en, this message translates to:
  /// **'Printing'**
  String get settingsGroupPrint;

  /// Settings group notify.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get settingsGroupNotify;

  /// Settings screen title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Scope picker label.
  ///
  /// In en, this message translates to:
  /// **'Settings for'**
  String get settingsScopeLabel;

  /// Business-level scope option.
  ///
  /// In en, this message translates to:
  /// **'Whole business'**
  String get settingsScopeBusiness;

  /// Explains party scope.
  ///
  /// In en, this message translates to:
  /// **'Pick a party to give them their own rates. Blank values follow the business.'**
  String get settingsScopeHint;

  /// Clears the value at this level.
  ///
  /// In en, this message translates to:
  /// **'Reset to inherited'**
  String get settingsReset;

  /// Save a typed setting value.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// Toast after saving a setting.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get settingsSaved;

  /// Structured settings not editable here yet.
  ///
  /// In en, this message translates to:
  /// **'Edited on its own screen (coming soon).'**
  String get settingsReadOnly;

  /// Setting is read-only for this member.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to change this.'**
  String get settingsNoPermission;

  /// No active business.
  ///
  /// In en, this message translates to:
  /// **'Choose a business first.'**
  String get settingsNoTenant;

  /// Value is set at the level being edited.
  ///
  /// In en, this message translates to:
  /// **'Set here'**
  String get settingSetHere;

  /// Source level.
  ///
  /// In en, this message translates to:
  /// **'From this document'**
  String get settingFromDocument;

  /// Source level.
  ///
  /// In en, this message translates to:
  /// **'From the party'**
  String get settingFromParty;

  /// Source level.
  ///
  /// In en, this message translates to:
  /// **'From the party group'**
  String get settingFromPartyGroup;

  /// Source level.
  ///
  /// In en, this message translates to:
  /// **'From business setting'**
  String get settingFromBusiness;

  /// Source level.
  ///
  /// In en, this message translates to:
  /// **'From your plan'**
  String get settingFromPlan;

  /// Source level.
  ///
  /// In en, this message translates to:
  /// **'App default'**
  String get settingFromDefault;

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid value'**
  String get settingErrorWrongType;

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'Too small (minimum {min})'**
  String settingErrorTooSmall(String min);

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'Too large (maximum {max})'**
  String settingErrorTooLarge(String max);

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'Not an allowed value'**
  String get settingErrorNotAllowed;

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get settingErrorInvalid;

  /// Key not allowed at this level.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be set here'**
  String get settingErrorNotHere;

  /// Interest rate in mandi units.
  ///
  /// In en, this message translates to:
  /// **'= ₹{amount} per 100 per month'**
  String settingRatePerMonth(String amount);

  /// Account menu: change the UI language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get accountLanguage;

  /// Account menu: open diagnostics (owner).
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get accountDiagnostics;

  /// Diagnostics screen title.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnosticsTitle;

  /// Shown to non-owners.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can open diagnostics.'**
  String get diagnosticsOwnerOnly;

  /// Status card title.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get diagnosticsDatabase;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Device code'**
  String get diagnosticsDeviceCode;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Sync connection'**
  String get diagnosticsConnection;

  /// Sync connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get diagnosticsOnline;

  /// Sync not connected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get diagnosticsOffline;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get diagnosticsLastSync;

  /// No sync yet.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get diagnosticsNever;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Changes waiting to upload'**
  String get diagnosticsQueued;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Local database size'**
  String get diagnosticsDbSize;

  /// Refresh button.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get diagnosticsRefresh;

  /// Card title.
  ///
  /// In en, this message translates to:
  /// **'Changes the server rejected'**
  String get diagnosticsRejected;

  /// Empty list.
  ///
  /// In en, this message translates to:
  /// **'No rejected changes.'**
  String get diagnosticsNoRejected;

  /// Re-queue a rejected change.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get diagnosticsRetry;

  /// Forget a rejected change.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get diagnosticsDiscard;

  /// Toast after retry.
  ///
  /// In en, this message translates to:
  /// **'Queued for upload again'**
  String get diagnosticsRequeued;

  /// Retry not possible.
  ///
  /// In en, this message translates to:
  /// **'This change can\'t be sent again. Discard it instead.'**
  String get diagnosticsNotRetryable;

  /// doc party.
  ///
  /// In en, this message translates to:
  /// **'Party codes'**
  String get settingSuffixDocParty;

  /// Parties screen title.
  ///
  /// In en, this message translates to:
  /// **'Parties'**
  String get partiesTitle;

  /// Search field hint.
  ///
  /// In en, this message translates to:
  /// **'Search name, village, mobile, code'**
  String get partiesSearchHint;

  /// Role filter: no filter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get partiesAll;

  /// Number of parties shown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 party} other{{count} parties}}'**
  String partiesCount(int count);

  /// Empty list title.
  ///
  /// In en, this message translates to:
  /// **'No parties yet'**
  String get partiesEmptyTitle;

  /// Empty list body.
  ///
  /// In en, this message translates to:
  /// **'Add the farmers, buyers and suppliers you deal with.'**
  String get partiesEmptyBody;

  /// No search results.
  ///
  /// In en, this message translates to:
  /// **'No party matches your search.'**
  String get partiesNoMatch;

  /// Add party button / form title.
  ///
  /// In en, this message translates to:
  /// **'Add party'**
  String get partiesAdd;

  /// Edit form title.
  ///
  /// In en, this message translates to:
  /// **'Edit party'**
  String get partyEditTitle;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get partyFieldCode;

  /// Hint: an automatic code will be used.
  ///
  /// In en, this message translates to:
  /// **'Leave blank for {code}'**
  String partyCodeAutoHint(String code);

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get partyFieldName;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get partyFieldRoles;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get partyFieldRelation;

  /// No relation.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get partyRelationNone;

  /// Son of.
  ///
  /// In en, this message translates to:
  /// **'S/o'**
  String get partyRelationSonOf;

  /// Daughter of.
  ///
  /// In en, this message translates to:
  /// **'D/o'**
  String get partyRelationDaughterOf;

  /// Wife of.
  ///
  /// In en, this message translates to:
  /// **'W/o'**
  String get partyRelationWifeOf;

  /// Proprietor of a firm.
  ///
  /// In en, this message translates to:
  /// **'Prop.'**
  String get partyRelationProprietor;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Father / husband name'**
  String get partyFieldFatherOrHusband;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get partyFieldMobile;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Other mobile'**
  String get partyFieldAltMobile;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get partyFieldVillage;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get partyFieldDistrict;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get partyFieldState;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar (last 4 digits)'**
  String get partyFieldAadhaar;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get partyFieldBankName;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get partyFieldBankAccount;

  /// Privacy note.
  ///
  /// In en, this message translates to:
  /// **'Only the last 4 digits are kept'**
  String get partyBankAccountHint;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'IFSC'**
  String get partyFieldIfsc;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'GSTIN'**
  String get partyFieldGstin;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get partyFieldNotes;

  /// Form section.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get partySectionIdentity;

  /// Form section.
  ///
  /// In en, this message translates to:
  /// **'Contact & address'**
  String get partySectionContact;

  /// Form section.
  ///
  /// In en, this message translates to:
  /// **'Bank & tax'**
  String get partySectionBank;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get partyErrorRequired;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one role'**
  String get partyErrorRoles;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit mobile number'**
  String get partyErrorMobile;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid IFSC, e.g. SBIN0001234'**
  String get partyErrorIfsc;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 15-character GSTIN'**
  String get partyErrorGstin;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Enter only the last 4 digits'**
  String get partyErrorAadhaar;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Another party already has this code'**
  String get partyErrorCodeTaken;

  /// Party missing.
  ///
  /// In en, this message translates to:
  /// **'This party was deleted.'**
  String get partyNotFound;

  /// Save button.
  ///
  /// In en, this message translates to:
  /// **'Save party'**
  String get partySave;

  /// Toast.
  ///
  /// In en, this message translates to:
  /// **'Party saved'**
  String get partySaved;

  /// Edit button.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get partyEdit;

  /// Delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get partyDelete;

  /// Delete confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String partyDeleteTitle(String name);

  /// Delete confirmation body.
  ///
  /// In en, this message translates to:
  /// **'The party is hidden from lists. Its history and audit log stay.'**
  String get partyDeleteBody;

  /// Toast.
  ///
  /// In en, this message translates to:
  /// **'Party deleted'**
  String get partyDeleted;

  /// Tab.
  ///
  /// In en, this message translates to:
  /// **'Khata'**
  String get partyTabKhata;

  /// Tab.
  ///
  /// In en, this message translates to:
  /// **'Lots'**
  String get partyTabLots;

  /// Tab.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get partyTabLoans;

  /// Tab.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get partyTabShop;

  /// Tab.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get partyTabDocuments;

  /// Tab.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get partyTabNotes;

  /// Placeholder tab.
  ///
  /// In en, this message translates to:
  /// **'This part arrives in a later update.'**
  String get partyTabComingSoon;

  /// Empty notes.
  ///
  /// In en, this message translates to:
  /// **'No notes.'**
  String get partyNoNotes;

  /// Crops master screen title.
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get cropsTitle;

  /// Add crop button / dialog title.
  ///
  /// In en, this message translates to:
  /// **'Add crop'**
  String get cropsAdd;

  /// Empty crops list.
  ///
  /// In en, this message translates to:
  /// **'No crops yet.'**
  String get cropsEmpty;

  /// Toggle to list inactive crops.
  ///
  /// In en, this message translates to:
  /// **'Show crops not in use'**
  String get cropsShowInactive;

  /// Badge on an inactive crop.
  ///
  /// In en, this message translates to:
  /// **'Not in use'**
  String get cropInactive;

  /// A rate per quintal.
  ///
  /// In en, this message translates to:
  /// **'{rate}/qtl'**
  String cropRatePerQtl(String rate);

  /// Crop without a reference rate.
  ///
  /// In en, this message translates to:
  /// **'No MSP / usual rate'**
  String get cropNoRate;

  /// Edit crop dialog title.
  ///
  /// In en, this message translates to:
  /// **'Edit crop'**
  String get cropEditTitle;

  /// Crop form field.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get cropFieldNameEn;

  /// Crop form field.
  ///
  /// In en, this message translates to:
  /// **'Name (Hindi)'**
  String get cropFieldNameHi;

  /// Crop form field.
  ///
  /// In en, this message translates to:
  /// **'Name (Punjabi)'**
  String get cropFieldNamePa;

  /// Crop form field.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get cropFieldCode;

  /// Help under the crop code field.
  ///
  /// In en, this message translates to:
  /// **'Small letters, digits and _. Cannot be changed later.'**
  String get cropCodeHint;

  /// Crop form field.
  ///
  /// In en, this message translates to:
  /// **'MSP / usual rate per qtl'**
  String get cropFieldStdRate;

  /// Crop form switch.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get cropFieldActive;

  /// Invalid crop code.
  ///
  /// In en, this message translates to:
  /// **'Start with a letter; use small letters, digits and _ (max 24).'**
  String get cropErrorCode;

  /// Missing crop name.
  ///
  /// In en, this message translates to:
  /// **'Enter the English name.'**
  String get cropErrorName;

  /// Invalid crop rate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get cropErrorRate;

  /// Duplicate crop code.
  ///
  /// In en, this message translates to:
  /// **'A crop with this code already exists.'**
  String get cropErrorCodeTaken;

  /// Crop missing.
  ///
  /// In en, this message translates to:
  /// **'This crop no longer exists.'**
  String get cropNotFound;

  /// Per-crop settings card title.
  ///
  /// In en, this message translates to:
  /// **'Mandi charges for this crop'**
  String get cropChargesTitle;

  /// Explains per-crop overrides.
  ///
  /// In en, this message translates to:
  /// **'Values not set here come from the business settings. A rate set for a farmer or a lot still wins.'**
  String get cropChargesHint;

  /// Heading of the sample calculation.
  ///
  /// In en, this message translates to:
  /// **'Example: {bags} bags · {qtl} qtl @ {rate}/qtl'**
  String cropExampleTitle(int bags, String qtl, String rate);

  /// Mandi charge name.
  ///
  /// In en, this message translates to:
  /// **'Arhat (commission)'**
  String get chargeCommission;

  /// Mandi charge name.
  ///
  /// In en, this message translates to:
  /// **'Palledari'**
  String get chargePalledari;

  /// Mandi charge name.
  ///
  /// In en, this message translates to:
  /// **'Bardana'**
  String get chargeBardana;

  /// Mandi charge name.
  ///
  /// In en, this message translates to:
  /// **'Tulai'**
  String get chargeTulai;

  /// Mandi charge name.
  ///
  /// In en, this message translates to:
  /// **'Mandi fee'**
  String get chargeMandiFee;

  /// Mandi charge name.
  ///
  /// In en, this message translates to:
  /// **'Cess'**
  String get chargeCess;

  /// Who pays a charge.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get payerFarmer;

  /// Who pays a charge.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get payerBuyer;

  /// Who pays a charge.
  ///
  /// In en, this message translates to:
  /// **'Arhtiya (us)'**
  String get payerArhtiya;

  /// Gross sale value of a lot.
  ///
  /// In en, this message translates to:
  /// **'Gross'**
  String get mandiGross;

  /// Net amount credited to the farmer.
  ///
  /// In en, this message translates to:
  /// **'Net to farmer (jama)'**
  String get mandiNetToFarmer;

  /// Total billed to the buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer pays (udhaar)'**
  String get mandiBuyerTotal;

  /// Who pays a charge line.
  ///
  /// In en, this message translates to:
  /// **'paid by {payer}'**
  String mandiPaidBy(String payer);

  /// Commission borne by the arhtiya.
  ///
  /// In en, this message translates to:
  /// **'waived'**
  String get mandiWaived;

  /// Add a cess row.
  ///
  /// In en, this message translates to:
  /// **'Add cess'**
  String get cessAdd;

  /// Cess name field.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. RDF)'**
  String get cessName;

  /// Cess percent field.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get cessPct;

  /// Remove a cess row.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get cessRemove;

  /// Edit button for list / map settings.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get settingsEdit;

  /// Link from settings to the crops screen.
  ///
  /// In en, this message translates to:
  /// **'Crops and per-crop charges'**
  String get settingsCropsLink;

  /// Arrivals (lots) screen title.
  ///
  /// In en, this message translates to:
  /// **'Arrivals'**
  String get arrivalsTitle;

  /// Empty arrivals list.
  ///
  /// In en, this message translates to:
  /// **'No lots for these filters'**
  String get arrivalsEmpty;

  /// Arrivals search hint.
  ///
  /// In en, this message translates to:
  /// **'Search farmer or lot no'**
  String get arrivalsSearchHint;

  /// Crop filter: no filter.
  ///
  /// In en, this message translates to:
  /// **'All crops'**
  String get arrivalsAllCrops;

  /// Status filter: no filter.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get arrivalsAllStatuses;

  /// Date filter chip.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rangeToday;

  /// Date filter chip (the day before today).
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get rangeYesterday;

  /// Date filter chip.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get rangeWeek;

  /// Date filter chip.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get rangeAll;

  /// Date filter chip that opens a range picker.
  ///
  /// In en, this message translates to:
  /// **'Pick dates…'**
  String get rangeCustom;

  /// Lot number column.
  ///
  /// In en, this message translates to:
  /// **'Lot no'**
  String get lotNo;

  /// Lot business date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get lotDate;

  /// Lot farmer field.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get lotFarmer;

  /// Lot crop field.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get lotCrop;

  /// Number of bags.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get lotBags;

  /// Bag count in a list row.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bag} other{{count} bags}}'**
  String lotBagsCount(int count);

  /// Weight in quintals.
  ///
  /// In en, this message translates to:
  /// **'Qtl'**
  String get lotQtl;

  /// Quintal unit after a number.
  ///
  /// In en, this message translates to:
  /// **'qtl'**
  String get lotQtlUnit;

  /// Checkbox: work out the weight from the bag count.
  ///
  /// In en, this message translates to:
  /// **'From bags × {kg} kg'**
  String lotQtlFromBags(String kg);

  /// Note that the weight was worked out from bags.
  ///
  /// In en, this message translates to:
  /// **'from bags'**
  String get lotQtlFromBagsShort;

  /// Rate per quintal.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get lotRate;

  /// Suffix after a per-quintal rate.
  ///
  /// In en, this message translates to:
  /// **'/ qtl'**
  String get lotPerQtl;

  /// Lot buyer field.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get lotBuyer;

  /// Buyer search hint.
  ///
  /// In en, this message translates to:
  /// **'Optional — type 3 letters'**
  String get lotBuyerHint;

  /// J-form number (mandi sale slip).
  ///
  /// In en, this message translates to:
  /// **'J-form no'**
  String get lotJForm;

  /// Tractor/truck number.
  ///
  /// In en, this message translates to:
  /// **'Vehicle no'**
  String get lotVehicle;

  /// Lot notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get lotNotes;

  /// Lot status column.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get lotStatusLabel;

  /// When the lot was posted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get lotPostedAt;

  /// Lot status.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get lotStatusArrived;

  /// Lot status.
  ///
  /// In en, this message translates to:
  /// **'Weighed'**
  String get lotStatusWeighed;

  /// Lot status.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get lotStatusSold;

  /// Lot status: posted to the khata.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get lotStatusPosted;

  /// Lot status.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get lotStatusReversed;

  /// Lot reversed before it was ever posted.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get lotStatusCancelled;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Bags cannot be negative'**
  String get lotProblemBags;

  /// Validation: weight missing or zero.
  ///
  /// In en, this message translates to:
  /// **'Enter the weight'**
  String get lotProblemWeight;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Rate must be more than zero'**
  String get lotProblemRate;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'The buyer cannot be the farmer'**
  String get lotProblemBuyerIsFarmer;

  /// Posting needs weight.
  ///
  /// In en, this message translates to:
  /// **'Weight is needed to post'**
  String get lotProblemNoWeight;

  /// Posting needs rate.
  ///
  /// In en, this message translates to:
  /// **'Rate is needed to post'**
  String get lotProblemNoRate;

  /// Posting needs a buyer.
  ///
  /// In en, this message translates to:
  /// **'Pick the buyer: some charges are billed to the buyer'**
  String get lotProblemBuyerRequired;

  /// Posting blocked: net would be zero or less.
  ///
  /// In en, this message translates to:
  /// **'Charges are more than the sale; nothing to credit to the farmer'**
  String get lotProblemNetNotPositive;

  /// Permission error.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do this'**
  String get lotErrorNotPermitted;

  /// Missing record.
  ///
  /// In en, this message translates to:
  /// **'Lot, farmer, buyer or crop not found'**
  String get lotErrorNotFound;

  /// Locked lot.
  ///
  /// In en, this message translates to:
  /// **'This lot is posted or reversed and cannot be changed'**
  String get lotErrorLocked;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Pick the farmer'**
  String get lotErrorPickFarmer;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Pick the crop'**
  String get lotErrorPickCrop;

  /// New lot title / button.
  ///
  /// In en, this message translates to:
  /// **'New arrival'**
  String get lotNewTitle;

  /// Edit lot title.
  ///
  /// In en, this message translates to:
  /// **'Edit lot'**
  String get lotEditTitle;

  /// The number the new lot will get.
  ///
  /// In en, this message translates to:
  /// **'Lot {number}'**
  String lotNextNo(String number);

  /// Save an incomplete lot.
  ///
  /// In en, this message translates to:
  /// **'Save (F10)'**
  String get lotSave;

  /// Save and post a complete lot.
  ///
  /// In en, this message translates to:
  /// **'Save & post (F10)'**
  String get lotSavePost;

  /// Save and start the next lot.
  ///
  /// In en, this message translates to:
  /// **'Save & new (Shift+F10)'**
  String get lotSaveNew;

  /// Save a sold lot without posting it.
  ///
  /// In en, this message translates to:
  /// **'Hold — don\'t post'**
  String get lotHold;

  /// Toast.
  ///
  /// In en, this message translates to:
  /// **'Lot {lotNo} saved'**
  String lotSavedToast(String lotNo);

  /// Toast.
  ///
  /// In en, this message translates to:
  /// **'Lot {lotNo} posted to the khata'**
  String lotPostedToast(String lotNo);

  /// Live calculation panel title.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get lotPreviewTitle;

  /// Calculation placeholder.
  ///
  /// In en, this message translates to:
  /// **'Enter crop, weight and rate to see arhat, charges and net.'**
  String get lotPreviewEmpty;

  /// Heading of the entries posting will make.
  ///
  /// In en, this message translates to:
  /// **'Posting writes to the khata:'**
  String get lotPostsTitle;

  /// Farmer's entry.
  ///
  /// In en, this message translates to:
  /// **'Jama to farmer'**
  String get lotPostsFarmer;

  /// Buyer's entry.
  ///
  /// In en, this message translates to:
  /// **'Udhaar to buyer'**
  String get lotPostsBuyer;

  /// Cancel an open lot.
  ///
  /// In en, this message translates to:
  /// **'Cancel lot'**
  String get lotCancel;

  /// Confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Cancel lot {lotNo}?'**
  String lotCancelTitle(String lotNo);

  /// Confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'Use this when the crop never came or was entered by mistake. Nothing was posted to the khata. This cannot be undone.'**
  String get lotCancelBody;

  /// Toast.
  ///
  /// In en, this message translates to:
  /// **'Lot {lotNo} cancelled'**
  String lotCancelledToast(String lotNo);

  /// Reverse a posted lot.
  ///
  /// In en, this message translates to:
  /// **'Reverse lot'**
  String get lotReverse;

  /// Confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Reverse lot {lotNo}?'**
  String lotReverseTitle(String lotNo);

  /// Confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'Its khata entries (farmer\'s jama, buyer\'s udhaar) are reversed on the same date. The lot stays in the records, marked reversed. You can then enter it again correctly.'**
  String get lotReverseBody;

  /// Toast.
  ///
  /// In en, this message translates to:
  /// **'Lot {lotNo} reversed'**
  String lotReversedToast(String lotNo);

  /// Start a new lot copied from a reversed one.
  ///
  /// In en, this message translates to:
  /// **'Enter again'**
  String get lotReenter;

  /// Edit an open lot.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get lotEdit;

  /// Edit an arrived lot at the counter.
  ///
  /// In en, this message translates to:
  /// **'Add weight & rate'**
  String get lotAddWeightRate;

  /// Details card title.
  ///
  /// In en, this message translates to:
  /// **'Lot'**
  String get lotDetailsTitle;

  /// Calculation card title.
  ///
  /// In en, this message translates to:
  /// **'Arhat & charges'**
  String get lotCalculationTitle;

  /// Calculation placeholder for open lots.
  ///
  /// In en, this message translates to:
  /// **'Shown once the lot is posted (with the rates of that day).'**
  String get lotNotPostedYet;

  /// Ledger entries of a lot.
  ///
  /// In en, this message translates to:
  /// **'Khata entries'**
  String get lotEntriesTitle;

  /// Entry made by posting a lot.
  ///
  /// In en, this message translates to:
  /// **'Crop sale'**
  String get lotEntryArrival;

  /// Reversal entry.
  ///
  /// In en, this message translates to:
  /// **'Reversal'**
  String get lotEntryReversal;

  /// Totals row: number of lots.
  ///
  /// In en, this message translates to:
  /// **'Lots'**
  String get lotsTotalCount;

  /// Wizard step 1.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get wizardStepFarmer;

  /// Wizard step 2.
  ///
  /// In en, this message translates to:
  /// **'Crop & bags'**
  String get wizardStepCrop;

  /// Wizard step 3.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get wizardStepConfirm;

  /// Wizard progress.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}: {title}'**
  String wizardStepOf(int step, int total, String title);

  /// Wizard back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get wizardBack;

  /// Wizard next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get wizardNext;

  /// Wizard note.
  ///
  /// In en, this message translates to:
  /// **'Weight and rate are added at the counter.'**
  String get wizardRateLater;

  /// Party search hint.
  ///
  /// In en, this message translates to:
  /// **'Type {count} letters to search'**
  String partyPickerHint(int count);

  /// Clear the picked party.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get partyPickerChange;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Crop sale'**
  String get khataRefArrival;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get khataRefPayment;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get khataRefReceipt;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Shop sale'**
  String get khataRefShopSale;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Shop return'**
  String get khataRefShopReturn;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get khataRefPurchase;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Loan given'**
  String get khataRefLoanDisbursal;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Loan repayment'**
  String get khataRefLoanRepayment;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get khataRefInterest;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get khataRefExpense;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Khata entry'**
  String get khataRefJournal;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get khataRefOpeningBalance;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Reversal'**
  String get khataRefReversal;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'reversal'**
  String get khataTagReversal;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get khataTagEdited;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'reversed'**
  String get khataTagReversed;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Entries older than {days, plural, =1{1 day} other{{days} days}}, or dated in the future, need an Accountant or Owner'**
  String khataErrorBackdated(int days);

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do this'**
  String get khataErrorNotPermitted;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'This party or entry no longer exists'**
  String get khataErrorNotFound;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero'**
  String get khataErrorAmount;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Nothing was changed'**
  String get khataErrorNothingChanged;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'This entry was already reversed'**
  String get khataErrorAlreadyReversed;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'A reversal cannot be changed; post a new entry'**
  String get khataErrorIsReversal;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get khataColDate;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get khataColDetails;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Party · details'**
  String get khataColPartyDetails;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Udhaar'**
  String get khataColUdhaar;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Jama'**
  String get khataColJama;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Baki'**
  String get khataColBaki;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Jama · we owe'**
  String get khataBalanceJama;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Udhaar · farmer owes'**
  String get khataBalanceUdhaarFarmer;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Udhaar · party owes'**
  String get khataBalanceUdhaarParty;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get khataBalanceSettled;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Khata entry'**
  String get khataEntryTitle;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Edit khata entry'**
  String get khataEditTitle;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Original entry (will be reversed)'**
  String get khataEditOriginal;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'The original stays in the khata, struck through, and the corrected entry is added.'**
  String get khataEditExplain;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get khataFieldParty;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Type a name, village or code'**
  String get khataFieldPartyHint;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Udhaar (party owes more)'**
  String get khataSideUdhaar;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Jama (we owe more)'**
  String get khataSideJama;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get khataFieldAmount;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get khataFieldDate;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Narration'**
  String get khataFieldNarration;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Post entry'**
  String get khataEntrySave;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Reverse and re-enter'**
  String get khataEditSave;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'All entries'**
  String get khataDayBookTitle;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'No entries for this filter'**
  String get khataDayBookEmpty;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Filter by party'**
  String get khataFilterParty;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get khataFilterAllTypes;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String khataEntriesCount(int count);

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Reverse this entry?'**
  String get khataReverseTitle;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'A mirror entry is added and both stay in the khata. This cannot be undone.'**
  String get khataReverseBody;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get khataReverse;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Entry reversed'**
  String get khataReversed;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Entry actions'**
  String get khataEntryActions;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Edit (reverse and re-enter)'**
  String get khataEdit;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'No entries in this period'**
  String get khataStatementEmpty;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Khata statement'**
  String get statementTitle;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get statementOpening;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Closing balance'**
  String get statementClosing;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statementTotals;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {pages}'**
  String statementPage(int page, int pages);

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Print / PDF'**
  String get statementPrint;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get statementShare;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'Type a command…'**
  String get paletteHint;

  /// Khata screens (step 1.4).
  ///
  /// In en, this message translates to:
  /// **'No matching command'**
  String get paletteNoMatch;

  /// Label of setting business.backdate_days.
  ///
  /// In en, this message translates to:
  /// **'Back-dating allowed (days)'**
  String get settingBusinessBackdateDays;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTitle;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get paymentRecordTitle;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get paymentPay;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get paymentReceive;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Paid to party'**
  String get paymentDirectionTo;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Received from party'**
  String get paymentDirectionFrom;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'No payments in this period'**
  String get paymentsEmpty;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Search party, receipt or cheque no.'**
  String get paymentsSearchHint;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'All modes'**
  String get paymentsAllModes;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Paid and received'**
  String get paymentsAllDirections;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Pending cheques'**
  String get paymentsPendingCheques;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTotalCount;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentsTotalPaid;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get paymentsTotalReceived;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get paymentsColNo;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get paymentsColDate;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get paymentsColParty;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get paymentsColType;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get paymentsColMode;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentsColAmount;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get paymentsColStatus;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentFieldAmount;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get paymentFieldDate;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get paymentFieldMode;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get paymentFieldAccount;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'UTR / reference'**
  String get paymentFieldReference;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cheque number'**
  String get paymentFieldChequeNo;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cheque date'**
  String get paymentFieldChequeDate;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get paymentFieldNarration;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentModeCash;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentModeBank;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get paymentModeUpi;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cheque'**
  String get paymentModeCheque;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentChequePending;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get paymentChequeCleared;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Bounced'**
  String get paymentChequeBounced;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get paymentStatusReversed;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Baki now'**
  String get paymentBakiNow;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'After this payment'**
  String get paymentBakiAfter;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Full baki'**
  String get paymentFullBaki;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Save payment'**
  String get paymentSave;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Saved as {receiptNo}'**
  String paymentSavedAs(String receiptNo);

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get paymentReceiptTitle;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Payment voucher'**
  String get paymentVoucherTitle;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Print receipt'**
  String get paymentPrintReceipt;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Share receipt'**
  String get paymentShareReceipt;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get paymentDone;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Mark cleared'**
  String get paymentMarkCleared;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Mark bounced'**
  String get paymentMarkBounced;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cheque bounced?'**
  String get paymentBounceTitle;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'This reverses the khata entry and the cash book line, dated the bounce date.'**
  String get paymentBounceBody;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Bounce date'**
  String get paymentBounceDate;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Reverse payment'**
  String get paymentReverse;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Reverse this payment?'**
  String get paymentReverseTitle;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'The khata entry and the cash book line are reversed. The payment stays on record as reversed.'**
  String get paymentReverseBody;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Payment reversed'**
  String get paymentReversedToast;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cheque marked cleared'**
  String get paymentClearedToast;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cheque bounced; entry reversed'**
  String get paymentBouncedToast;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'This payment no longer exists'**
  String get paymentNotFound;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to record this payment'**
  String get paymentErrorNotPermitted;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Payments above {limit} need an Accountant or Owner'**
  String paymentErrorLimit(String limit);

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Bank, UPI and cheque payments need finance access'**
  String get paymentErrorFinance;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'The party or bank account no longer exists'**
  String get paymentErrorNotFound;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'This payment or cheque can no longer change'**
  String get paymentErrorLocked;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero'**
  String get paymentErrorAmount;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Choose a bank account'**
  String get paymentErrorBank;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Enter the cheque number'**
  String get paymentErrorChequeNo;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Enter the cheque date'**
  String get paymentErrorChequeDate;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cheque details only go with a cheque'**
  String get paymentErrorChequeDetails;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'No bank accounts yet. Add one under Bank accounts.'**
  String get paymentNoBankAccounts;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Bank accounts'**
  String get accountsTitle;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Add bank account'**
  String get accountsAdd;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Edit bank account'**
  String get accountsEdit;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'No bank accounts yet'**
  String get accountsEmpty;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountCash;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountFieldName;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Bank name'**
  String get accountFieldBank;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Last 4 digits of account number'**
  String get accountFieldLast4;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'IFSC'**
  String get accountFieldIfsc;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Book balance'**
  String get accountBookBalance;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Switch off'**
  String get accountSwitchOff;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Switch on'**
  String get accountSwitchOn;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get accountInactive;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Enter an account name'**
  String get accountErrorName;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Exactly 4 digits'**
  String get accountErrorLast4;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Not a valid IFSC (e.g. SBIN0001234)'**
  String get accountErrorIfsc;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Bank accounts need finance access'**
  String get accountErrorNotPermitted;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Received from'**
  String get receiptReceivedFrom;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Paid to'**
  String get receiptPaidTo;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get receiptNo;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get receiptDate;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get receiptAmount;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get receiptMode;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get receiptReference;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cheque no.'**
  String get receiptChequeNo;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Cheque date'**
  String get receiptChequeDate;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Balance after this'**
  String get receiptBalanceAfter;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get receiptSignature;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'REVERSED'**
  String get receiptReversed;

  /// Payments & receipts (step 1.5).
  ///
  /// In en, this message translates to:
  /// **'Payment limit without an Accountant (₹, 0 = none)'**
  String get settingBusinessMunshiPaymentLimit;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lot in today} other{{count} lots in today}} · {amount} arhat earned'**
  String dashHeroLots(int count, String amount);

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'No lots in yet today'**
  String get dashHeroNoLots;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'We owe farmers'**
  String get dashWeOweFarmers;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Others owe us'**
  String get dashOthersOweUs;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Add farmer'**
  String get dashActionAddFarmer;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Lots in today'**
  String get dashStatLots;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'{qtl} qtl'**
  String dashStatQtl(String qtl);

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Arhat earned today'**
  String get dashStatEarned;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Paid out today'**
  String get dashStatPaid;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Receipts today'**
  String get dashStatReceipts;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Arhat earned · last 10 days'**
  String get dashChartTitle;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'No arhat earned in these days yet'**
  String get dashChartEmpty;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Crop mix by sale value · {year}'**
  String dashCropMixTitle(String year);

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'No posted sales this season yet'**
  String get dashCropMixEmpty;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lot} other{{count} lots}}'**
  String dashCropMixLots(int count);

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Where the money is'**
  String get dashMoneyTitle;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Farmer khata · we owe'**
  String get dashFarmersPayable;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Farmer khata · farmers owe us'**
  String get dashFarmersReceivable;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Other parties owe us'**
  String get dashOthersReceivable;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Needs you today'**
  String get dashNeedsTitle;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'Nothing needs you right now'**
  String get dashNeedsNothing;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change was rejected by the server} other{{count} changes were rejected by the server}}'**
  String dashNeedsSyncErrors(int count);

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 cheque due} other{{count} cheques due}} · {amount}'**
  String dashNeedsCheques(int count, String amount);

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change by a munshi in the last 7 days} other{{count} changes by munshis in the last 7 days}}'**
  String dashNeedsStaff(int count);

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'from posted lots'**
  String get dashStatEarnedSub;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'to parties'**
  String get dashStatPaidSub;

  /// Dashboard (step 1.6).
  ///
  /// In en, this message translates to:
  /// **'from parties'**
  String get dashStatReceiptsSub;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'pa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'pa':
      return AppLocalizationsPa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
