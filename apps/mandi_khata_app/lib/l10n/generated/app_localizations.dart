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
