// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get syncOff => 'ਸਿੰਕ ਬੰਦ';

  @override
  String get syncSyncing => 'ਸਿੰਕ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String get syncSyncedJustNow => 'ਸਿੰਕ ਹੋਇਆ · ਹੁਣੇ';

  @override
  String syncSyncedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਸਿੰਕ ਹੋਇਆ · $count ਮਿੰਟ ਪਹਿਲਾਂ',
    );
    return '$_temp0';
  }

  @override
  String syncSyncedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਸਿੰਕ ਹੋਇਆ · $count ਘੰਟੇ ਪਹਿਲਾਂ',
    );
    return '$_temp0';
  }

  @override
  String get syncOffline => 'ਆਫ਼ਲਾਈਨ';

  @override
  String syncOfflineQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਆਫ਼ਲਾਈਨ · $count ਬਾਕੀ',
    );
    return '$_temp0';
  }

  @override
  String syncErrorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਸਿੰਕ ਗਲਤੀ · $count ਬਦਲਾਅ ਰੱਦ',
    );
    return '$_temp0';
  }

  @override
  String get syncErrorsTitle => 'ਸਰਵਰ ਨੇ ਇਹ ਬਦਲਾਅ ਰੱਦ ਕੀਤੇ';

  @override
  String get syncErrorsBody =>
      'ਇਹ ਬਦਲਾਅ ਆਨਲਾਈਨ ਸੇਵ ਨਹੀਂ ਹੋਏ। ਬਾਕੀ ਸਭ ਸਿੰਕ ਹੁੰਦਾ ਰਹੇਗਾ।';

  @override
  String get syncErrorsDismiss => 'ਸਭ ਹਟਾਓ';

  @override
  String get commonClose => 'ਬੰਦ ਕਰੋ';

  @override
  String get commonCancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get commonRetry => 'ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get splashLoading => 'ਤਿਆਰੀ ਹੋ ਰਹੀ ਹੈ…';

  @override
  String get loginTitle => 'ਮੰਡੀ ਖਾਤਾ ਵਿੱਚ ਸਾਈਨ ਇਨ ਕਰੋ';

  @override
  String get loginSubtitle =>
      'ਅਸੀਂ ਤੁਹਾਡੇ ਮੋਬਾਈਲ \'ਤੇ SMS ਰਾਹੀਂ 6 ਅੰਕਾਂ ਦਾ ਕੋਡ ਭੇਜਾਂਗੇ।';

  @override
  String get loginTabPhone => 'ਮੋਬਾਈਲ ਨੰਬਰ';

  @override
  String get loginTabEmail => 'ਈਮੇਲ';

  @override
  String get loginPhoneLabel => 'ਮੋਬਾਈਲ ਨੰਬਰ';

  @override
  String get loginPhoneInvalid => '10 ਅੰਕਾਂ ਦਾ ਭਾਰਤੀ ਮੋਬਾਈਲ ਨੰਬਰ ਪਾਓ';

  @override
  String get loginSendOtp => 'ਕੋਡ ਭੇਜੋ';

  @override
  String get loginOtpLabel => '6 ਅੰਕਾਂ ਦਾ ਕੋਡ';

  @override
  String loginOtpSentTo(String phone) {
    return 'ਕੋਡ $phone \'ਤੇ ਭੇਜਿਆ ਗਿਆ';
  }

  @override
  String get loginOtpInvalidFormat => '6 ਅੰਕਾਂ ਦਾ ਕੋਡ ਪਾਓ';

  @override
  String get loginVerify => 'ਜਾਂਚੋ ਅਤੇ ਸਾਈਨ ਇਨ ਕਰੋ';

  @override
  String loginResendIn(int seconds) {
    return '$seconds ਸਕਿੰਟ ਵਿੱਚ ਦੁਬਾਰਾ ਭੇਜੋ';
  }

  @override
  String get loginResend => 'ਕੋਡ ਦੁਬਾਰਾ ਭੇਜੋ';

  @override
  String get loginChangeNumber => 'ਨੰਬਰ ਬਦਲੋ';

  @override
  String get loginEmailLabel => 'ਈਮੇਲ';

  @override
  String get loginPasswordLabel => 'ਪਾਸਵਰਡ';

  @override
  String get loginEmailSignIn => 'ਸਾਈਨ ਇਨ ਕਰੋ';

  @override
  String get loginEmailInvalid => 'ਆਪਣੀ ਈਮੇਲ ਅਤੇ ਪਾਸਵਰਡ ਪਾਓ';

  @override
  String get authErrorNotConfigured => 'ਇਸ ਬਿਲਡ ਵਿੱਚ ਸਾਈਨ ਇਨ ਸੈੱਟ ਨਹੀਂ ਹੈ।';

  @override
  String get authErrorNetwork =>
      'ਇੰਟਰਨੈੱਟ ਨਹੀਂ ਹੈ। ਕਨੈਕਟ ਕਰਕੇ ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get authErrorInvalidOtp => 'ਕੋਡ ਗਲਤ ਹੈ ਜਾਂ ਉਸਦੀ ਮਿਆਦ ਖਤਮ ਹੋ ਗਈ ਹੈ।';

  @override
  String get authErrorInvalidCredentials => 'ਈਮੇਲ ਜਾਂ ਪਾਸਵਰਡ ਗਲਤ ਹੈ।';

  @override
  String get authErrorRateLimited =>
      'ਬਹੁਤ ਜ਼ਿਆਦਾ ਕੋਸ਼ਿਸ਼ਾਂ। ਕੁਝ ਮਿੰਟ ਰੁਕ ਕੇ ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get authErrorSms =>
      'SMS ਨਹੀਂ ਭੇਜਿਆ ਜਾ ਸਕਿਆ। ਬਾਅਦ ਵਿੱਚ ਕੋਸ਼ਿਸ਼ ਕਰੋ ਜਾਂ ਈਮੇਲ ਨਾਲ ਸਾਈਨ ਇਨ ਕਰੋ।';

  @override
  String get authErrorUnknown => 'ਸਾਈਨ ਇਨ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get tenantPickerTitle => 'ਕਾਰੋਬਾਰ ਚੁਣੋ';

  @override
  String get tenantPickerSubtitle =>
      'ਤੁਸੀਂ ਬਾਅਦ ਵਿੱਚ ਅਕਾਊਂਟ ਮੀਨੂ ਤੋਂ ਬਦਲ ਸਕਦੇ ਹੋ।';

  @override
  String get tenantPickerLoading =>
      'ਤੁਹਾਡੇ ਕਾਰੋਬਾਰ ਡਾਊਨਲੋਡ ਹੋ ਰਹੇ ਹਨ… ਪਹਿਲੀ ਵਾਰ ਇੰਟਰਨੈੱਟ ਲੋੜੀਂਦਾ ਹੈ।';

  @override
  String get tenantPickerNoSync =>
      'ਇਸ ਬਿਲਡ ਵਿੱਚ ਸਿੰਕ ਸੈੱਟ ਨਹੀਂ ਹੈ, ਇਸ ਲਈ ਕਾਰੋਬਾਰ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕਦੇ।';

  @override
  String get tenantPickerEmptyTitle => 'ਅਜੇ ਕੋਈ ਕਾਰੋਬਾਰ ਜੁੜਿਆ ਨਹੀਂ';

  @override
  String get tenantPickerEmptyBody =>
      'ਤੁਹਾਡਾ ਅਕਾਊਂਟ ਕਿਸੇ ਕਾਰੋਬਾਰ ਵਿੱਚ ਨਹੀਂ ਹੈ। ਮਾਲਕ ਨੂੰ ਜੋੜਨ ਲਈ ਕਹੋ, ਫਿਰ ਐਪ ਦੁਬਾਰਾ ਖੋਲ੍ਹੋ।';

  @override
  String deviceSetupOffline(String business) {
    return '$business ਲਈ ਇਹ ਡਿਵਾਈਸ ਸੈੱਟ ਕਰਨ ਲਈ ਇੱਕ ਵਾਰ ਇੰਟਰਨੈੱਟ ਨਾਲ ਜੁੜੋ।';
  }

  @override
  String deviceSetupFailed(String business) {
    return '$business ਲਈ ਇਹ ਡਿਵਾਈਸ ਸੈੱਟ ਨਹੀਂ ਹੋ ਸਕੀ।';
  }

  @override
  String get roleOwner => 'ਮਾਲਕ';

  @override
  String get roleAccountant => 'ਮੁਨੀਮ';

  @override
  String get roleMunshi => 'ਮੁਨਸ਼ੀ';

  @override
  String get roleCustom => 'ਕਸਟਮ ਭੂਮਿਕਾ';

  @override
  String get pinSetupTitle => 'ਐਪ PIN ਸੈੱਟ ਕਰੋ';

  @override
  String get pinSetupBody =>
      'ਐਪ ਖੁੱਲ੍ਹਣ \'ਤੇ ਪੁੱਛਿਆ ਜਾਵੇਗਾ, ਤਾਂ ਜੋ ਹੋਰ ਤੁਹਾਡਾ ਖਾਤਾ ਨਾ ਵੇਖ ਸਕਣ। 4–6 ਅੰਕ, ਸਿਰਫ਼ ਇਸ ਡਿਵਾਈਸ \'ਤੇ।';

  @override
  String get pinConfirmTitle => 'PIN ਦੁਬਾਰਾ ਪਾਓ';

  @override
  String get pinMismatch => 'PIN ਮੇਲ ਨਹੀਂ ਖਾਂਦੇ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get pinTooShort => '4 ਤੋਂ 6 ਅੰਕ ਰੱਖੋ';

  @override
  String get pinSkip => 'ਹੁਣੇ ਛੱਡੋ';

  @override
  String get pinSaved => 'ਐਪ PIN ਸੇਵ ਹੋ ਗਿਆ';

  @override
  String get pinBiometricOption => 'ਫਿੰਗਰਪ੍ਰਿੰਟ ਜਾਂ ਚਿਹਰੇ ਨਾਲ ਵੀ ਖੋਲ੍ਹੋ';

  @override
  String get pinPadDelete => 'ਅੰਕ ਮਿਟਾਓ';

  @override
  String get pinPadOk => 'ਠੀਕ ਹੈ';

  @override
  String get lockTitle => 'ਆਪਣਾ PIN ਪਾਓ';

  @override
  String get lockWrongPin => 'ਗਲਤ PIN';

  @override
  String lockCooldown(int seconds) {
    return 'ਬਹੁਤ ਗਲਤ ਕੋਸ਼ਿਸ਼ਾਂ। $seconds ਸਕਿੰਟ ਬਾਅਦ ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';
  }

  @override
  String get lockUseBiometric => 'ਫਿੰਗਰਪ੍ਰਿੰਟ ਨਾਲ ਖੋਲ੍ਹੋ';

  @override
  String get lockBiometricReason => 'ਮੰਡੀ ਖਾਤਾ ਖੋਲ੍ਹੋ';

  @override
  String get lockForgotPin => 'PIN ਭੁੱਲ ਗਏ? ਸਾਈਨ ਆਊਟ ਕਰੋ';

  @override
  String get accountMenu => 'ਅਕਾਊਂਟ';

  @override
  String get accountSwitchBusiness => 'ਕਾਰੋਬਾਰ ਬਦਲੋ';

  @override
  String get accountLockNow => 'ਹੁਣੇ ਲੌਕ ਕਰੋ';

  @override
  String get accountSetPin => 'ਐਪ PIN ਸੈੱਟ ਕਰੋ';

  @override
  String get accountChangePin => 'ਐਪ PIN ਬਦਲੋ';

  @override
  String get accountRemovePin => 'ਐਪ PIN ਹਟਾਓ';

  @override
  String get accountSignOut => 'ਸਾਈਨ ਆਊਟ';

  @override
  String homeDeviceCode(String code) {
    return 'ਇਹ ਡਿਵਾਈਸ: $code';
  }

  @override
  String get homePlaceholder => 'ਤੁਹਾਡਾ ਡੈਸ਼ਬੋਰਡ ਇੱਥੇ ਦਿਖੇਗਾ।';

  @override
  String get signOutTitle => 'ਸਾਈਨ ਆਊਟ ਕਰਨਾ ਹੈ?';

  @override
  String get signOutBody =>
      'ਇਸ ਡਿਵਾਈਸ ਤੋਂ ਡੇਟਾ ਦੀ ਕਾਪੀ ਹਟ ਜਾਵੇਗੀ। ਦੁਬਾਰਾ ਸਾਈਨ ਇਨ ਲਈ ਇੰਟਰਨੈੱਟ ਚਾਹੀਦਾ ਹੈ।';

  @override
  String signOutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ਬਦਲਾਅ ਅਜੇ ਅੱਪਲੋਡ ਨਹੀਂ ਹੋਏ। ਹੁਣ ਸਾਈਨ ਆਊਟ ਕਰਨ \'ਤੇ ਉਹ ਇਸ ਡਿਵਾਈਸ ਤੋਂ ਮਿਟ ਜਾਣਗੇ।',
      one:
          '1 ਬਦਲਾਅ ਅਜੇ ਅੱਪਲੋਡ ਨਹੀਂ ਹੋਇਆ। ਹੁਣ ਸਾਈਨ ਆਊਟ ਕਰਨ \'ਤੇ ਉਹ ਇਸ ਡਿਵਾਈਸ ਤੋਂ ਮਿਟ ਜਾਵੇਗਾ।',
    );
    return '$_temp0';
  }

  @override
  String get signOutUploadFirst => 'ਪਹਿਲਾਂ ਅੱਪਲੋਡ, ਫਿਰ ਸਾਈਨ ਆਊਟ';

  @override
  String get signOutAnyway => 'ਸਾਈਨ ਆਊਟ ਕਰੋ ਅਤੇ ਮਿਟਾਓ';

  @override
  String get signOutUploading => 'ਬਦਲਾਅ ਅੱਪਲੋਡ ਹੋ ਰਹੇ ਹਨ…';

  @override
  String get signOutUploadFailed =>
      'ਸਭ ਕੁਝ ਅੱਪਲੋਡ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਇੰਟਰਨੈੱਟ ਜਾਂਚ ਕੇ ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get settingInterestEnabled => 'ਵਿਆਜ ਲਗਾਓ';

  @override
  String get settingInterestRatePa => 'ਵਿਆਜ ਦਰ (% ਸਾਲਾਨਾ)';

  @override
  String get settingInterestRateUnitDisplay => 'ਦਰ ਇੰਝ ਦਿਖਾਓ';

  @override
  String get settingInterestMethod => 'ਵਿਆਜ ਦਾ ਤਰੀਕਾ';

  @override
  String get settingInterestCompounding => 'ਚੱਕਰਵਾਧਾ ਮਿਆਦ';

  @override
  String get settingInterestDayBasis => 'ਸਾਲ ਦੇ ਦਿਨ';

  @override
  String get settingInterestGraceDays => 'ਛੋਟ ਦੇ ਦਿਨ';

  @override
  String get settingInterestAppropriation => 'ਭੁਗਤਾਨ ਪਹਿਲਾਂ ਕਿਸ ਵਿੱਚ ਜਾਵੇ';

  @override
  String get settingInterestApplyOn => 'ਵਿਆਜ ਕਿਸ \'ਤੇ ਲੱਗੇ';

  @override
  String get settingInterestMinDays => 'ਇਸ ਤੋਂ ਘੱਟ ਦਿਨਾਂ ਦੀ ਮਿਆਦ ਛੱਡੋ';

  @override
  String get settingInterestRounding => 'ਵਿਆਜ ਨੂੰ ਗੋਲ ਕਰੋ';

  @override
  String get settingInterestPostFrequency => 'ਵਿਆਜ ਖਾਤੇ ਵਿੱਚ ਕਦੋਂ ਚੜ੍ਹੇ';

  @override
  String get settingInterestPayOnJama => 'ਜਮ੍ਹਾਂ \'ਤੇ ਵਿਆਜ ਦਿਓ';

  @override
  String get settingInterestPayRatePa => 'ਜਮ੍ਹਾਂ \'ਤੇ ਦਰ (% ਸਾਲਾਨਾ)';

  @override
  String get settingMandiCommissionPct => 'ਆੜ੍ਹਤ ਕਮਿਸ਼ਨ %';

  @override
  String get settingMandiPalledariPerBag => 'ਪੱਲੇਦਾਰੀ ਪ੍ਰਤੀ ਬੋਰੀ';

  @override
  String get settingMandiBardanaPerBag => 'ਬਾਰਦਾਨਾ ਪ੍ਰਤੀ ਬੋਰੀ';

  @override
  String get settingMandiTulaiPerQtl => 'ਤੁਲਾਈ ਪ੍ਰਤੀ ਕੁਇੰਟਲ';

  @override
  String get settingMandiMandiFeePct => 'ਮੰਡੀ ਫੀਸ %';

  @override
  String get settingMandiCess => 'ਸੈੱਸ';

  @override
  String get settingMandiChargesBorneBy => 'ਕਿਹੜਾ ਖਰਚਾ ਕੌਣ ਦੇਵੇ';

  @override
  String get settingMandiBagWeightKg => 'ਬੋਰੀ ਦਾ ਭਾਰ (ਕਿਲੋ)';

  @override
  String get settingShopPriceTiers => 'ਕੀਮਤ ਸ਼੍ਰੇਣੀਆਂ';

  @override
  String get settingShopDefaultTierForRole => 'ਡਿਫਾਲਟ ਕੀਮਤ ਸ਼੍ਰੇਣੀ';

  @override
  String get settingShopAllowNegativeStock => 'ਜ਼ੀਰੋ ਤੋਂ ਘੱਟ ਸਟਾਕ \'ਤੇ ਵੀ ਵੇਚੋ';

  @override
  String get settingShopExpiryWarnDays =>
      'ਮਿਆਦ ਖਤਮ ਹੋਣ ਤੋਂ ਪਹਿਲਾਂ ਚੇਤਾਵਨੀ (ਦਿਨ)';

  @override
  String get settingShopGstEnabled => 'ਬਿੱਲ \'ਤੇ GST';

  @override
  String get settingShopPostCreditSaleToKhata => 'ਉਧਾਰ ਵਿਕਰੀ ਖਾਤੇ ਵਿੱਚ ਚੜ੍ਹਾਓ';

  @override
  String get settingBusinessFyStartMonth => 'ਵਿੱਤੀ ਸਾਲ ਸ਼ੁਰੂ ਹੋਣ ਦਾ ਮਹੀਨਾ';

  @override
  String get settingBusinessNumberSeries => 'ਨੰਬਰ ਸੀਰੀਜ਼';

  @override
  String get settingAppModules => 'ਮਾਡਿਊਲ';

  @override
  String get settingAppLanguages => 'ਭਾਸ਼ਾਵਾਂ';

  @override
  String get settingAppDefaultLanguage => 'ਡਿਫਾਲਟ ਭਾਸ਼ਾ';

  @override
  String get settingPrintReceiptSize => 'ਰਸੀਦ ਦਾ ਕਾਗਜ਼';

  @override
  String get settingNotifyWhatsappReceipts => 'WhatsApp \'ਤੇ ਰਸੀਦ ਭੇਜੋ';

  @override
  String get settingOptInterestRateUnitDisplayPa => '% ਸਾਲਾਨਾ';

  @override
  String get settingOptInterestRateUnitDisplayPer100PerMonth =>
      '₹ ਪ੍ਰਤੀ 100 ਪ੍ਰਤੀ ਮਹੀਨਾ';

  @override
  String get settingOptInterestMethodSimple => 'ਸਾਧਾਰਨ';

  @override
  String get settingOptInterestMethodCompound => 'ਚੱਕਰਵਾਧਾ';

  @override
  String get settingOptInterestCompoundingMonthly => 'ਮਹੀਨਾਵਾਰ';

  @override
  String get settingOptInterestCompoundingQuarterly => 'ਤਿਮਾਹੀ';

  @override
  String get settingOptInterestCompoundingHalfyearly => 'ਛਿਮਾਹੀ';

  @override
  String get settingOptInterestCompoundingYearly => 'ਸਾਲਾਨਾ';

  @override
  String get settingOptInterestCompoundingOnFyClose => 'ਵਿੱਤੀ ਸਾਲ ਦੇ ਅੰਤ \'ਤੇ';

  @override
  String get settingOptInterestAppropriationInterestFirst => 'ਵਿਆਜ';

  @override
  String get settingOptInterestAppropriationPrincipalFirst => 'ਮੂਲ';

  @override
  String get settingOptInterestApplyOnNetUdhaar => 'ਸਿਰਫ਼ ਸ਼ੁੱਧ ਉਧਾਰ';

  @override
  String get settingOptInterestApplyOnLoansOnly => 'ਸਿਰਫ਼ ਕਰਜ਼ਾ';

  @override
  String get settingOptInterestApplyOnNone => 'ਵਿਆਜ ਨਹੀਂ';

  @override
  String get settingOptInterestRoundingPaise => 'ਪੈਸੇ';

  @override
  String get settingOptInterestRoundingRupee => 'ਰੁਪਿਆ';

  @override
  String get settingOptInterestRoundingTenRupee => '₹10';

  @override
  String get settingOptInterestPostFrequencyOnDemand => 'ਜਦੋਂ ਮੈਂ ਚੁਣਾਂ';

  @override
  String get settingOptInterestPostFrequencyMonthly => 'ਮਹੀਨਾਵਾਰ';

  @override
  String get settingOptInterestPostFrequencyQuarterly => 'ਤਿਮਾਹੀ';

  @override
  String get settingOptInterestPostFrequencyFyClose => 'ਵਿੱਤੀ ਸਾਲ ਦੇ ਅੰਤ \'ਤੇ';

  @override
  String get settingOptAppDefaultLanguageEn => 'English';

  @override
  String get settingOptAppDefaultLanguageHi => 'हिंदी';

  @override
  String get settingOptAppDefaultLanguagePa => 'ਪੰਜਾਬੀ';

  @override
  String get settingOptPrintReceiptSizeA5 => 'A5 ਕਾਗਜ਼';

  @override
  String get settingOptPrintReceiptSizeThermal80 => 'ਥਰਮਲ 80 ਮਿਮੀ';

  @override
  String get settingOptPrintReceiptSizeThermal58 => 'ਥਰਮਲ 58 ਮਿਮੀ';

  @override
  String get settingSuffixRoleFarmer => 'ਕਿਸਾਨ';

  @override
  String get settingSuffixRoleCustomer => 'ਗਾਹਕ';

  @override
  String get settingSuffixRoleSupplier => 'ਸਪਲਾਇਰ';

  @override
  String get settingSuffixRoleVendor => 'ਵੈਂਡਰ';

  @override
  String get settingSuffixRoleAgency => 'ਏਜੰਸੀ';

  @override
  String get settingSuffixRoleBuyer => 'ਖਰੀਦਦਾਰ';

  @override
  String get settingSuffixDocReceipt => 'ਰਸੀਦਾਂ';

  @override
  String get settingSuffixDocLot => 'ਲਾਟ';

  @override
  String get settingSuffixDocSalesInvoice => 'ਵਿਕਰੀ ਬਿੱਲ';

  @override
  String get settingSuffixDocPurchaseInvoice => 'ਖਰੀਦ ਬਿੱਲ';

  @override
  String get settingSuffixDocKarza => 'ਕਰਜ਼ਾ';

  @override
  String get settingSuffixDocVoucher => 'ਵਾਊਚਰ';

  @override
  String get settingSuffixModuleKhata => 'ਖਾਤਾ';

  @override
  String get settingSuffixModuleArrivals => 'ਆਮਦ ਅਤੇ ਲਾਟ';

  @override
  String get settingSuffixModuleKarza => 'ਕਰਜ਼ਾ ਅਤੇ ਵਿਆਜ';

  @override
  String get settingSuffixModuleAccounting => 'ਲੇਖਾ';

  @override
  String get settingSuffixModuleShop => 'ਖਾਦ-ਬੀਜ ਦੁਕਾਨ';

  @override
  String get settingsGroupInterest => 'ਵਿਆਜ';

  @override
  String get settingsGroupMandi => 'ਮੰਡੀ ਖਰਚੇ';

  @override
  String get settingsGroupShop => 'ਖਾਦ-ਬੀਜ ਦੁਕਾਨ';

  @override
  String get settingsGroupBusiness => 'ਕਾਰੋਬਾਰ';

  @override
  String get settingsGroupModules => 'ਮਾਡਿਊਲ';

  @override
  String get settingsGroupApp => 'ਐਪ';

  @override
  String get settingsGroupPrint => 'ਪ੍ਰਿੰਟਿੰਗ';

  @override
  String get settingsGroupNotify => 'ਸੁਨੇਹੇ';

  @override
  String get settingsTitle => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get settingsScopeLabel => 'ਸੈਟਿੰਗਾਂ ਕਿਸ ਲਈ';

  @override
  String get settingsScopeBusiness => 'ਪੂਰਾ ਕਾਰੋਬਾਰ';

  @override
  String get settingsScopeHint =>
      'ਕਿਸੇ ਪਾਰਟੀ ਨੂੰ ਚੁਣ ਕੇ ਉਸ ਦੀਆਂ ਵੱਖਰੀਆਂ ਦਰਾਂ ਰੱਖੋ। ਖਾਲੀ ਮੁੱਲ ਕਾਰੋਬਾਰ ਦੀ ਸੈਟਿੰਗ ਮੰਨਦੇ ਹਨ।';

  @override
  String get settingsReset => 'ਪਹਿਲਾਂ ਵਾਂਗ ਕਰੋ';

  @override
  String get settingsSave => 'ਸੇਵ ਕਰੋ';

  @override
  String get settingsSaved => 'ਸੇਵ ਹੋ ਗਿਆ';

  @override
  String get settingsReadOnly => 'ਇਸ ਦੀ ਵੱਖਰੀ ਸਕ੍ਰੀਨ \'ਤੇ ਬਦਲੇਗਾ (ਜਲਦੀ)।';

  @override
  String get settingsNoPermission => 'ਤੁਹਾਨੂੰ ਇਸ ਨੂੰ ਬਦਲਣ ਦੀ ਇਜਾਜ਼ਤ ਨਹੀਂ ਹੈ।';

  @override
  String get settingsNoTenant => 'ਪਹਿਲਾਂ ਕਾਰੋਬਾਰ ਚੁਣੋ।';

  @override
  String get settingSetHere => 'ਇੱਥੇ ਸੈੱਟ ਹੈ';

  @override
  String get settingFromDocument => 'ਇਸ ਦਸਤਾਵੇਜ਼ ਤੋਂ';

  @override
  String get settingFromParty => 'ਪਾਰਟੀ ਤੋਂ';

  @override
  String get settingFromPartyGroup => 'ਪਾਰਟੀ ਸਮੂਹ ਤੋਂ';

  @override
  String get settingFromBusiness => 'ਕਾਰੋਬਾਰ ਦੀ ਸੈਟਿੰਗ ਤੋਂ';

  @override
  String get settingFromPlan => 'ਤੁਹਾਡੇ ਪਲਾਨ ਤੋਂ';

  @override
  String get settingFromDefault => 'ਐਪ ਡਿਫਾਲਟ';

  @override
  String get settingErrorWrongType => 'ਸਹੀ ਮੁੱਲ ਪਾਓ';

  @override
  String settingErrorTooSmall(String min) {
    return 'ਬਹੁਤ ਘੱਟ (ਘੱਟੋ-ਘੱਟ $min)';
  }

  @override
  String settingErrorTooLarge(String max) {
    return 'ਬਹੁਤ ਜ਼ਿਆਦਾ (ਵੱਧ ਤੋਂ ਵੱਧ $max)';
  }

  @override
  String get settingErrorNotAllowed => 'ਇਹ ਮੁੱਲ ਮਨਜ਼ੂਰ ਨਹੀਂ';

  @override
  String get settingErrorInvalid => 'ਗਲਤ ਮੁੱਲ';

  @override
  String get settingErrorNotHere => 'ਇਸ ਨੂੰ ਇੱਥੇ ਸੈੱਟ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਦਾ';

  @override
  String settingRatePerMonth(String amount) {
    return '= ₹$amount ਪ੍ਰਤੀ 100 ਪ੍ਰਤੀ ਮਹੀਨਾ';
  }

  @override
  String get accountLanguage => 'ਭਾਸ਼ਾ';

  @override
  String get accountDiagnostics => 'ਡਾਇਗਨੌਸਟਿਕਸ';

  @override
  String get diagnosticsTitle => 'ਡਾਇਗਨੌਸਟਿਕਸ';

  @override
  String get diagnosticsOwnerOnly => 'ਡਾਇਗਨੌਸਟਿਕਸ ਸਿਰਫ਼ ਮਾਲਕ ਖੋਲ੍ਹ ਸਕਦੇ ਹਨ।';

  @override
  String get diagnosticsDatabase => 'ਇਹ ਡਿਵਾਈਸ';

  @override
  String get diagnosticsDeviceCode => 'ਡਿਵਾਈਸ ਕੋਡ';

  @override
  String get diagnosticsConnection => 'ਸਿੰਕ ਕਨੈਕਸ਼ਨ';

  @override
  String get diagnosticsOnline => 'ਜੁੜਿਆ ਹੈ';

  @override
  String get diagnosticsOffline => 'ਜੁੜਿਆ ਨਹੀਂ';

  @override
  String get diagnosticsLastSync => 'ਆਖਰੀ ਸਿੰਕ';

  @override
  String get diagnosticsNever => 'ਕਦੇ ਨਹੀਂ';

  @override
  String get diagnosticsQueued => 'ਅੱਪਲੋਡ ਲਈ ਬਾਕੀ ਬਦਲਾਅ';

  @override
  String get diagnosticsDbSize => 'ਲੋਕਲ ਡੇਟਾਬੇਸ ਦਾ ਆਕਾਰ';

  @override
  String get diagnosticsRefresh => 'ਰਿਫ੍ਰੈਸ਼ ਕਰੋ';

  @override
  String get diagnosticsRejected => 'ਸਰਵਰ ਨੇ ਜੋ ਬਦਲਾਅ ਨਹੀਂ ਮੰਨੇ';

  @override
  String get diagnosticsNoRejected => 'ਕੋਈ ਬਦਲਾਅ ਰੱਦ ਨਹੀਂ ਹੋਇਆ।';

  @override
  String get diagnosticsRetry => 'ਫਿਰ ਭੇਜੋ';

  @override
  String get diagnosticsDiscard => 'ਹਟਾਓ';

  @override
  String get diagnosticsRequeued => 'ਮੁੜ ਅੱਪਲੋਡ ਲਈ ਰੱਖਿਆ ਗਿਆ';

  @override
  String get diagnosticsNotRetryable =>
      'ਇਹ ਬਦਲਾਅ ਦੁਬਾਰਾ ਨਹੀਂ ਭੇਜਿਆ ਜਾ ਸਕਦਾ। ਇਸ ਨੂੰ ਹਟਾ ਦਿਓ।';

  @override
  String get settingSuffixDocParty => 'ਪਾਰਟੀ ਕੋਡ';

  @override
  String get partiesTitle => 'ਪਾਰਟੀਆਂ';

  @override
  String get partiesSearchHint => 'ਨਾਮ, ਪਿੰਡ, ਮੋਬਾਈਲ, ਕੋਡ ਖੋਜੋ';

  @override
  String get partiesAll => 'ਸਾਰੇ';

  @override
  String partiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਪਾਰਟੀਆਂ',
      one: '1 ਪਾਰਟੀ',
    );
    return '$_temp0';
  }

  @override
  String get partiesEmptyTitle => 'ਅਜੇ ਕੋਈ ਪਾਰਟੀ ਨਹੀਂ';

  @override
  String get partiesEmptyBody =>
      'ਜਿਨ੍ਹਾਂ ਕਿਸਾਨਾਂ, ਖਰੀਦਦਾਰਾਂ ਅਤੇ ਸਪਲਾਇਰਾਂ ਨਾਲ ਕੰਮ ਹੁੰਦਾ ਹੈ, ਉਨ੍ਹਾਂ ਨੂੰ ਜੋੜੋ।';

  @override
  String get partiesNoMatch => 'ਖੋਜ ਨਾਲ ਕੋਈ ਪਾਰਟੀ ਨਹੀਂ ਮਿਲੀ।';

  @override
  String get partiesAdd => 'ਪਾਰਟੀ ਜੋੜੋ';

  @override
  String get partyEditTitle => 'ਪਾਰਟੀ ਬਦਲੋ';

  @override
  String get partyFieldCode => 'ਕੋਡ';

  @override
  String partyCodeAutoHint(String code) {
    return 'ਖਾਲੀ ਛੱਡੋ ਤਾਂ $code';
  }

  @override
  String get partyFieldName => 'ਨਾਮ';

  @override
  String get partyFieldRoles => 'ਭੂਮਿਕਾ';

  @override
  String get partyFieldRelation => 'ਸਬੰਧ';

  @override
  String get partyRelationNone => 'ਕੋਈ ਨਹੀਂ';

  @override
  String get partyRelationSonOf => 'ਪੁੱਤਰ';

  @override
  String get partyRelationDaughterOf => 'ਧੀ';

  @override
  String get partyRelationWifeOf => 'ਪਤਨੀ';

  @override
  String get partyRelationProprietor => 'ਪ੍ਰੋਪਰਾਈਟਰ';

  @override
  String get partyFieldFatherOrHusband => 'ਪਿਤਾ / ਪਤੀ ਦਾ ਨਾਮ';

  @override
  String get partyFieldMobile => 'ਮੋਬਾਈਲ';

  @override
  String get partyFieldAltMobile => 'ਦੂਜਾ ਮੋਬਾਈਲ';

  @override
  String get partyFieldVillage => 'ਪਿੰਡ';

  @override
  String get partyFieldDistrict => 'ਜ਼ਿਲ੍ਹਾ';

  @override
  String get partyFieldState => 'ਰਾਜ';

  @override
  String get partyFieldAadhaar => 'ਆਧਾਰ (ਆਖਰੀ 4 ਅੰਕ)';

  @override
  String get partyFieldBankName => 'ਬੈਂਕ';

  @override
  String get partyFieldBankAccount => 'ਖਾਤਾ ਨੰਬਰ';

  @override
  String get partyBankAccountHint => 'ਸਿਰਫ਼ ਆਖਰੀ 4 ਅੰਕ ਰੱਖੇ ਜਾਂਦੇ ਹਨ';

  @override
  String get partyFieldIfsc => 'IFSC';

  @override
  String get partyFieldGstin => 'GSTIN';

  @override
  String get partyFieldNotes => 'ਨੋਟ';

  @override
  String get partySectionIdentity => 'ਪਾਰਟੀ';

  @override
  String get partySectionContact => 'ਸੰਪਰਕ ਅਤੇ ਪਤਾ';

  @override
  String get partySectionBank => 'ਬੈਂਕ ਅਤੇ ਟੈਕਸ';

  @override
  String get partyErrorRequired => 'ਲੋੜੀਂਦਾ';

  @override
  String get partyErrorRoles => 'ਘੱਟੋ-ਘੱਟ ਇੱਕ ਭੂਮਿਕਾ ਚੁਣੋ';

  @override
  String get partyErrorMobile => '10 ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਪਾਓ';

  @override
  String get partyErrorIfsc => 'ਸਹੀ IFSC ਪਾਓ, ਜਿਵੇਂ SBIN0001234';

  @override
  String get partyErrorGstin => 'ਸਹੀ 15 ਅੱਖਰਾਂ ਦਾ GSTIN ਪਾਓ';

  @override
  String get partyErrorAadhaar => 'ਸਿਰਫ਼ ਆਖਰੀ 4 ਅੰਕ ਪਾਓ';

  @override
  String get partyErrorCodeTaken => 'ਇਹ ਕੋਡ ਕਿਸੇ ਹੋਰ ਪਾਰਟੀ ਦਾ ਹੈ';

  @override
  String get partyNotFound => 'ਇਹ ਪਾਰਟੀ ਹਟਾ ਦਿੱਤੀ ਗਈ ਹੈ।';

  @override
  String get partySave => 'ਪਾਰਟੀ ਸੇਵ ਕਰੋ';

  @override
  String get partySaved => 'ਪਾਰਟੀ ਸੇਵ ਹੋ ਗਈ';

  @override
  String get partyEdit => 'ਬਦਲੋ';

  @override
  String get partyDelete => 'ਹਟਾਓ';

  @override
  String partyDeleteTitle(String name) {
    return '$name ਨੂੰ ਹਟਾਉਣਾ ਹੈ?';
  }

  @override
  String get partyDeleteBody =>
      'ਪਾਰਟੀ ਸੂਚੀ ਤੋਂ ਲੁਕ ਜਾਵੇਗੀ। ਉਸ ਦਾ ਇਤਿਹਾਸ ਅਤੇ ਆਡਿਟ ਲੌਗ ਰਹੇਗਾ।';

  @override
  String get partyDeleted => 'ਪਾਰਟੀ ਹਟਾ ਦਿੱਤੀ ਗਈ';

  @override
  String get partyTabKhata => 'ਖਾਤਾ';

  @override
  String get partyTabLots => 'ਲਾਟ';

  @override
  String get partyTabLoans => 'ਕਰਜ਼ੇ';

  @override
  String get partyTabShop => 'ਦੁਕਾਨ';

  @override
  String get partyTabDocuments => 'ਦਸਤਾਵੇਜ਼';

  @override
  String get partyTabNotes => 'ਨੋਟ';

  @override
  String get partyTabComingSoon => 'ਇਹ ਹਿੱਸਾ ਅਗਲੇ ਅਪਡੇਟ ਵਿੱਚ ਆਵੇਗਾ।';

  @override
  String get partyNoNotes => 'ਕੋਈ ਨੋਟ ਨਹੀਂ।';

  @override
  String get cropsTitle => 'ਫ਼ਸਲਾਂ';

  @override
  String get cropsAdd => 'ਫ਼ਸਲ ਜੋੜੋ';

  @override
  String get cropsEmpty => 'ਹਾਲੇ ਕੋਈ ਫ਼ਸਲ ਨਹੀਂ।';

  @override
  String get cropsShowInactive => 'ਬੰਦ ਫ਼ਸਲਾਂ ਵੀ ਵਿਖਾਓ';

  @override
  String get cropInactive => 'ਬੰਦ';

  @override
  String cropRatePerQtl(String rate) {
    return '$rate/ਕੁਇੰਟਲ';
  }

  @override
  String get cropNoRate => 'MSP / ਆਮ ਭਾਅ ਨਹੀਂ';

  @override
  String get cropEditTitle => 'ਫ਼ਸਲ ਬਦਲੋ';

  @override
  String get cropFieldNameEn => 'ਨਾਮ (ਅੰਗਰੇਜ਼ੀ)';

  @override
  String get cropFieldNameHi => 'ਨਾਮ (ਹਿੰਦੀ)';

  @override
  String get cropFieldNamePa => 'ਨਾਮ (ਪੰਜਾਬੀ)';

  @override
  String get cropFieldCode => 'ਕੋਡ';

  @override
  String get cropCodeHint =>
      'ਛੋਟੇ ਅੰਗਰੇਜ਼ੀ ਅੱਖਰ, ਅੰਕ ਤੇ _। ਬਾਅਦ ਵਿੱਚ ਨਹੀਂ ਬਦਲੇਗਾ।';

  @override
  String get cropFieldStdRate => 'MSP / ਆਮ ਭਾਅ ਪ੍ਰਤੀ ਕੁਇੰਟਲ';

  @override
  String get cropFieldActive => 'ਚਾਲੂ';

  @override
  String get cropErrorCode =>
      'ਅੱਖਰ ਨਾਲ ਸ਼ੁਰੂ ਕਰੋ; ਛੋਟੇ ਅੱਖਰ, ਅੰਕ ਤੇ _ (ਵੱਧ ਤੋਂ ਵੱਧ 24)।';

  @override
  String get cropErrorName => 'ਅੰਗਰੇਜ਼ੀ ਨਾਮ ਲਿਖੋ।';

  @override
  String get cropErrorRate => 'ਸਹੀ ਰਕਮ ਲਿਖੋ।';

  @override
  String get cropErrorCodeTaken => 'ਇਸ ਕੋਡ ਦੀ ਫ਼ਸਲ ਪਹਿਲਾਂ ਹੀ ਹੈ।';

  @override
  String get cropNotFound => 'ਇਹ ਫ਼ਸਲ ਹੁਣ ਨਹੀਂ ਹੈ।';

  @override
  String get cropChargesTitle => 'ਇਸ ਫ਼ਸਲ ਦੇ ਮੰਡੀ ਖ਼ਰਚੇ';

  @override
  String get cropChargesHint =>
      'ਜੋ ਇੱਥੇ ਸੈੱਟ ਨਹੀਂ, ਉਹ ਕਾਰੋਬਾਰ ਦੀ ਸੈਟਿੰਗ ਤੋਂ ਆਵੇਗਾ। ਕਿਸਾਨ ਜਾਂ ਲਾਟ ਲਈ ਸੈੱਟ ਰੇਟ ਫਿਰ ਵੀ ਉੱਪਰ ਰਹੇਗਾ।';

  @override
  String cropExampleTitle(int bags, String qtl, String rate) {
    return 'ਉਦਾਹਰਨ: $bags ਬੋਰੀਆਂ · $qtl ਕੁਇੰਟਲ @ $rate/ਕੁਇੰਟਲ';
  }

  @override
  String get chargeCommission => 'ਆੜ੍ਹਤ (ਕਮਿਸ਼ਨ)';

  @override
  String get chargePalledari => 'ਪੱਲੇਦਾਰੀ';

  @override
  String get chargeBardana => 'ਬਾਰਦਾਨਾ';

  @override
  String get chargeTulai => 'ਤੁਲਾਈ';

  @override
  String get chargeMandiFee => 'ਮੰਡੀ ਫੀਸ';

  @override
  String get chargeCess => 'ਸੈੱਸ';

  @override
  String get payerFarmer => 'ਕਿਸਾਨ';

  @override
  String get payerBuyer => 'ਖ਼ਰੀਦਦਾਰ';

  @override
  String get payerArhtiya => 'ਆੜ੍ਹਤੀ (ਅਸੀਂ)';

  @override
  String get mandiGross => 'ਕੁੱਲ ਰਕਮ';

  @override
  String get mandiNetToFarmer => 'ਕਿਸਾਨ ਨੂੰ ਸ਼ੁੱਧ (ਜਮ੍ਹਾਂ)';

  @override
  String get mandiBuyerTotal => 'ਖ਼ਰੀਦਦਾਰ ਦੇਵੇਗਾ (ਉਧਾਰ)';

  @override
  String mandiPaidBy(String payer) {
    return '$payer ਦੇਵੇਗਾ';
  }

  @override
  String get mandiWaived => 'ਮਾਫ਼';

  @override
  String get cessAdd => 'ਸੈੱਸ ਜੋੜੋ';

  @override
  String get cessName => 'ਨਾਮ (ਜਿਵੇਂ RDF)';

  @override
  String get cessPct => '%';

  @override
  String get cessRemove => 'ਹਟਾਓ';

  @override
  String get settingsEdit => 'ਬਦਲੋ';

  @override
  String get settingsCropsLink => 'ਫ਼ਸਲਾਂ ਤੇ ਫ਼ਸਲ-ਵਾਰ ਖ਼ਰਚੇ';
}
