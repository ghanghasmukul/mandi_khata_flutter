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

  @override
  String get arrivalsTitle => 'ਆਮਦ';

  @override
  String get arrivalsEmpty => 'ਇਨ੍ਹਾਂ ਫ਼ਿਲਟਰਾਂ ਵਿੱਚ ਕੋਈ ਲਾਟ ਨਹੀਂ';

  @override
  String get arrivalsSearchHint => 'ਕਿਸਾਨ ਜਾਂ ਲਾਟ ਨੰਬਰ ਲੱਭੋ';

  @override
  String get arrivalsAllCrops => 'ਸਾਰੀਆਂ ਫ਼ਸਲਾਂ';

  @override
  String get arrivalsAllStatuses => 'ਸਾਰੀਆਂ ਸਥਿਤੀਆਂ';

  @override
  String get rangeToday => 'ਅੱਜ';

  @override
  String get rangeYesterday => 'ਕੱਲ੍ਹ';

  @override
  String get rangeWeek => 'ਪਿਛਲੇ 7 ਦਿਨ';

  @override
  String get rangeAll => 'ਸਾਰੀਆਂ ਤਾਰੀਖ਼ਾਂ';

  @override
  String get rangeCustom => 'ਤਾਰੀਖ਼ਾਂ ਚੁਣੋ…';

  @override
  String get lotNo => 'ਲਾਟ ਨੰ.';

  @override
  String get lotDate => 'ਤਾਰੀਖ਼';

  @override
  String get lotFarmer => 'ਕਿਸਾਨ';

  @override
  String get lotCrop => 'ਫ਼ਸਲ';

  @override
  String get lotBags => 'ਬੋਰੀਆਂ';

  @override
  String lotBagsCount(int count) {
    return '$count ਬੋਰੀਆਂ';
  }

  @override
  String get lotQtl => 'ਕੁਇੰਟਲ';

  @override
  String get lotQtlUnit => 'ਕੁਇੰਟਲ';

  @override
  String lotQtlFromBags(String kg) {
    return 'ਬੋਰੀਆਂ × $kg ਕਿਲੋ ਤੋਂ';
  }

  @override
  String get lotQtlFromBagsShort => 'ਬੋਰੀਆਂ ਤੋਂ';

  @override
  String get lotRate => 'ਭਾਅ';

  @override
  String get lotPerQtl => '/ ਕੁਇੰਟਲ';

  @override
  String get lotBuyer => 'ਖ਼ਰੀਦਦਾਰ';

  @override
  String get lotBuyerHint => 'ਚੋਣਵਾਂ — 3 ਅੱਖਰ ਲਿਖੋ';

  @override
  String get lotJForm => 'ਜੇ-ਫ਼ਾਰਮ ਨੰ.';

  @override
  String get lotVehicle => 'ਗੱਡੀ ਨੰ.';

  @override
  String get lotNotes => 'ਨੋਟ';

  @override
  String get lotStatusLabel => 'ਸਥਿਤੀ';

  @override
  String get lotPostedAt => 'ਖਾਤੇ ਵਿੱਚ ਦਰਜ';

  @override
  String get lotStatusArrived => 'ਆਇਆ';

  @override
  String get lotStatusWeighed => 'ਤੁਲਿਆ';

  @override
  String get lotStatusSold => 'ਵਿਕਿਆ';

  @override
  String get lotStatusPosted => 'ਖਾਤੇ ਵਿੱਚ';

  @override
  String get lotStatusReversed => 'ਉਲਟਾਇਆ';

  @override
  String get lotStatusCancelled => 'ਰੱਦ';

  @override
  String get lotProblemBags => 'ਬੋਰੀਆਂ ਘਟਾਓ ਵਿੱਚ ਨਹੀਂ ਹੋ ਸਕਦੀਆਂ';

  @override
  String get lotProblemWeight => 'ਵਜ਼ਨ ਲਿਖੋ';

  @override
  String get lotProblemRate => 'ਭਾਅ ਸਿਫ਼ਰ ਤੋਂ ਵੱਧ ਹੋਵੇ';

  @override
  String get lotProblemBuyerIsFarmer => 'ਖ਼ਰੀਦਦਾਰ ਤੇ ਕਿਸਾਨ ਇੱਕ ਨਹੀਂ ਹੋ ਸਕਦੇ';

  @override
  String get lotProblemNoWeight => 'ਖਾਤੇ ਵਿੱਚ ਪਾਉਣ ਲਈ ਵਜ਼ਨ ਚਾਹੀਦਾ ਹੈ';

  @override
  String get lotProblemNoRate => 'ਖਾਤੇ ਵਿੱਚ ਪਾਉਣ ਲਈ ਭਾਅ ਚਾਹੀਦਾ ਹੈ';

  @override
  String get lotProblemBuyerRequired =>
      'ਖ਼ਰੀਦਦਾਰ ਚੁਣੋ: ਕੁਝ ਖ਼ਰਚੇ ਖ਼ਰੀਦਦਾਰ ਤੋਂ ਲਏ ਜਾਂਦੇ ਹਨ';

  @override
  String get lotProblemNetNotPositive =>
      'ਖ਼ਰਚੇ ਵਿਕਰੀ ਤੋਂ ਵੱਧ ਹਨ; ਕਿਸਾਨ ਨੂੰ ਜਮ੍ਹਾਂ ਕਰਨ ਲਈ ਕੁਝ ਨਹੀਂ';

  @override
  String get lotErrorNotPermitted => 'ਤੁਹਾਨੂੰ ਇਸ ਦੀ ਇਜਾਜ਼ਤ ਨਹੀਂ';

  @override
  String get lotErrorNotFound => 'ਲਾਟ, ਕਿਸਾਨ, ਖ਼ਰੀਦਦਾਰ ਜਾਂ ਫ਼ਸਲ ਨਹੀਂ ਮਿਲੀ';

  @override
  String get lotErrorLocked =>
      'ਇਹ ਲਾਟ ਖਾਤੇ ਵਿੱਚ ਦਰਜ ਜਾਂ ਉਲਟਾਇਆ ਜਾ ਚੁੱਕਾ ਹੈ, ਬਦਲਿਆ ਨਹੀਂ ਜਾ ਸਕਦਾ';

  @override
  String get lotErrorPickFarmer => 'ਕਿਸਾਨ ਚੁਣੋ';

  @override
  String get lotErrorPickCrop => 'ਫ਼ਸਲ ਚੁਣੋ';

  @override
  String get lotNewTitle => 'ਨਵੀਂ ਆਮਦ';

  @override
  String get lotEditTitle => 'ਲਾਟ ਬਦਲੋ';

  @override
  String lotNextNo(String number) {
    return 'ਲਾਟ $number';
  }

  @override
  String get lotSave => 'ਸੇਵ ਕਰੋ (F10)';

  @override
  String get lotSavePost => 'ਸੇਵ ਕਰੋ ਤੇ ਖਾਤੇ ਵਿੱਚ ਪਾਓ (F10)';

  @override
  String get lotSaveNew => 'ਸੇਵ ਕਰੋ ਤੇ ਨਵਾਂ (Shift+F10)';

  @override
  String get lotHold => 'ਰੋਕੋ — ਖਾਤੇ ਵਿੱਚ ਨਾ ਪਾਓ';

  @override
  String lotSavedToast(String lotNo) {
    return 'ਲਾਟ $lotNo ਸੇਵ ਹੋਇਆ';
  }

  @override
  String lotPostedToast(String lotNo) {
    return 'ਲਾਟ $lotNo ਖਾਤੇ ਵਿੱਚ ਦਰਜ';
  }

  @override
  String get lotPreviewTitle => 'ਹਿਸਾਬ';

  @override
  String get lotPreviewEmpty =>
      'ਆੜ੍ਹਤ, ਖ਼ਰਚੇ ਤੇ ਸ਼ੁੱਧ ਰਕਮ ਵੇਖਣ ਲਈ ਫ਼ਸਲ, ਵਜ਼ਨ ਤੇ ਭਾਅ ਲਿਖੋ।';

  @override
  String get lotPostsTitle => 'ਖਾਤੇ ਵਿੱਚ ਇਹ ਦਰਜ ਹੋਵੇਗਾ:';

  @override
  String get lotPostsFarmer => 'ਕਿਸਾਨ ਨੂੰ ਜਮ੍ਹਾਂ';

  @override
  String get lotPostsBuyer => 'ਖ਼ਰੀਦਦਾਰ \'ਤੇ ਉਧਾਰ';

  @override
  String get lotCancel => 'ਲਾਟ ਰੱਦ ਕਰੋ';

  @override
  String lotCancelTitle(String lotNo) {
    return 'ਲਾਟ $lotNo ਰੱਦ ਕਰੀਏ?';
  }

  @override
  String get lotCancelBody =>
      'ਜਦੋਂ ਫ਼ਸਲ ਆਈ ਹੀ ਨਹੀਂ ਜਾਂ ਗ਼ਲਤੀ ਨਾਲ ਦਰਜ ਹੋਈ ਹੋਵੇ। ਖਾਤੇ ਵਿੱਚ ਕੁਝ ਦਰਜ ਨਹੀਂ ਸੀ ਹੋਇਆ। ਇਹ ਵਾਪਸ ਨਹੀਂ ਹੋਵੇਗਾ।';

  @override
  String lotCancelledToast(String lotNo) {
    return 'ਲਾਟ $lotNo ਰੱਦ';
  }

  @override
  String get lotReverse => 'ਲਾਟ ਉਲਟਾਓ';

  @override
  String lotReverseTitle(String lotNo) {
    return 'ਲਾਟ $lotNo ਉਲਟਾਈਏ?';
  }

  @override
  String get lotReverseBody =>
      'ਇਸ ਦੀਆਂ ਖਾਤਾ ਐਂਟਰੀਆਂ (ਕਿਸਾਨ ਦਾ ਜਮ੍ਹਾਂ, ਖ਼ਰੀਦਦਾਰ ਦਾ ਉਧਾਰ) ਉਸੇ ਤਾਰੀਖ਼ \'ਤੇ ਉਲਟਾਈਆਂ ਜਾਣਗੀਆਂ। ਲਾਟ ਰਿਕਾਰਡ ਵਿੱਚ \'ਉਲਟਾਇਆ\' ਰਹੇਗਾ। ਫਿਰ ਤੁਸੀਂ ਇਸ ਨੂੰ ਠੀਕ ਤਰ੍ਹਾਂ ਦੁਬਾਰਾ ਦਰਜ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String lotReversedToast(String lotNo) {
    return 'ਲਾਟ $lotNo ਉਲਟਾਇਆ';
  }

  @override
  String get lotReenter => 'ਦੁਬਾਰਾ ਦਰਜ ਕਰੋ';

  @override
  String get lotEdit => 'ਬਦਲੋ';

  @override
  String get lotAddWeightRate => 'ਵਜ਼ਨ ਤੇ ਭਾਅ ਪਾਓ';

  @override
  String get lotDetailsTitle => 'ਲਾਟ';

  @override
  String get lotCalculationTitle => 'ਆੜ੍ਹਤ ਤੇ ਖ਼ਰਚੇ';

  @override
  String get lotNotPostedYet =>
      'ਲਾਟ ਖਾਤੇ ਵਿੱਚ ਦਰਜ ਹੋਣ \'ਤੇ ਦਿਸੇਗਾ (ਉਸ ਦਿਨ ਦੇ ਰੇਟਾਂ ਨਾਲ)।';

  @override
  String get lotEntriesTitle => 'ਖਾਤਾ ਐਂਟਰੀਆਂ';

  @override
  String get lotEntryArrival => 'ਫ਼ਸਲ ਵਿਕਰੀ';

  @override
  String get lotEntryReversal => 'ਉਲਟ ਐਂਟਰੀ';

  @override
  String get lotsTotalCount => 'ਲਾਟ';

  @override
  String get wizardStepFarmer => 'ਕਿਸਾਨ';

  @override
  String get wizardStepCrop => 'ਫ਼ਸਲ ਤੇ ਬੋਰੀਆਂ';

  @override
  String get wizardStepConfirm => 'ਪੁਸ਼ਟੀ';

  @override
  String wizardStepOf(int step, int total, String title) {
    return 'ਕਦਮ $step/$total: $title';
  }

  @override
  String get wizardBack => 'ਪਿੱਛੇ';

  @override
  String get wizardNext => 'ਅੱਗੇ';

  @override
  String get wizardRateLater => 'ਵਜ਼ਨ ਤੇ ਭਾਅ ਕਾਊਂਟਰ \'ਤੇ ਪਾਏ ਜਾਣਗੇ।';

  @override
  String partyPickerHint(int count) {
    return 'ਲੱਭਣ ਲਈ $count ਅੱਖਰ ਲਿਖੋ';
  }

  @override
  String get partyPickerChange => 'ਬਦਲੋ';

  @override
  String get khataRefArrival => 'ਫਸਲ ਵਿਕਰੀ';

  @override
  String get khataRefPayment => 'ਭੁਗਤਾਨ';

  @override
  String get khataRefReceipt => 'ਰਸੀਦ';

  @override
  String get khataRefShopSale => 'ਦੁਕਾਨ ਵਿਕਰੀ';

  @override
  String get khataRefShopReturn => 'ਦੁਕਾਨ ਵਾਪਸੀ';

  @override
  String get khataRefPurchase => 'ਖਰੀਦ';

  @override
  String get khataRefLoanDisbursal => 'ਕਰਜ਼ਾ ਦਿੱਤਾ';

  @override
  String get khataRefLoanRepayment => 'ਕਰਜ਼ਾ ਵਾਪਸੀ';

  @override
  String get khataRefInterest => 'ਵਿਆਜ';

  @override
  String get khataRefExpense => 'ਖਰਚਾ';

  @override
  String get khataRefJournal => 'ਖਾਤਾ ਐਂਟਰੀ';

  @override
  String get khataRefOpeningBalance => 'ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ';

  @override
  String get khataRefReversal => 'ਉਲਟ ਐਂਟਰੀ';

  @override
  String get khataTagReversal => 'ਉਲਟ';

  @override
  String get khataTagEdited => 'ਸੁਧਾਰੀ ਗਈ';

  @override
  String get khataTagReversed => 'ਉਲਟਾ ਦਿੱਤੀ ਗਈ';

  @override
  String khataErrorBackdated(int days) {
    return '$days ਦਿਨ ਤੋਂ ਪੁਰਾਣੀ ਜਾਂ ਅਗਲੀ ਤਰੀਕ ਦੀ ਐਂਟਰੀ ਲਈ ਮੁਨੀਮ ਜਾਂ ਮਾਲਕ ਚਾਹੀਦਾ ਹੈ';
  }

  @override
  String get khataErrorNotPermitted => 'ਤੁਹਾਨੂੰ ਇਸ ਦੀ ਇਜਾਜ਼ਤ ਨਹੀਂ';

  @override
  String get khataErrorNotFound => 'ਇਹ ਪਾਰਟੀ ਜਾਂ ਐਂਟਰੀ ਹੁਣ ਮੌਜੂਦ ਨਹੀਂ';

  @override
  String get khataErrorAmount => 'ਸਿਫ਼ਰ ਤੋਂ ਵੱਧ ਰਕਮ ਲਿਖੋ';

  @override
  String get khataErrorNothingChanged => 'ਕੁਝ ਵੀ ਨਹੀਂ ਬਦਲਿਆ';

  @override
  String get khataErrorAlreadyReversed => 'ਇਹ ਐਂਟਰੀ ਪਹਿਲਾਂ ਹੀ ਉਲਟਾ ਦਿੱਤੀ ਗਈ ਹੈ';

  @override
  String get khataErrorIsReversal =>
      'ਉਲਟ ਐਂਟਰੀ ਬਦਲੀ ਨਹੀਂ ਜਾ ਸਕਦੀ; ਨਵੀਂ ਐਂਟਰੀ ਪਾਓ';

  @override
  String get khataColDate => 'ਤਰੀਕ';

  @override
  String get khataColDetails => 'ਵੇਰਵਾ';

  @override
  String get khataColPartyDetails => 'ਪਾਰਟੀ · ਵੇਰਵਾ';

  @override
  String get khataColUdhaar => 'ਉਧਾਰ';

  @override
  String get khataColJama => 'ਜਮ੍ਹਾ';

  @override
  String get khataColBaki => 'ਬਾਕੀ';

  @override
  String get khataBalanceJama => 'ਜਮ੍ਹਾ · ਸਾਨੂੰ ਦੇਣਾ ਹੈ';

  @override
  String get khataBalanceUdhaarFarmer => 'ਉਧਾਰ · ਕਿਸਾਨ ਨੇ ਦੇਣਾ ਹੈ';

  @override
  String get khataBalanceUdhaarParty => 'ਉਧਾਰ · ਪਾਰਟੀ ਨੇ ਦੇਣਾ ਹੈ';

  @override
  String get khataBalanceSettled => 'ਹਿਸਾਬ ਬਰਾਬਰ';

  @override
  String get khataEntryTitle => 'ਖਾਤਾ ਐਂਟਰੀ';

  @override
  String get khataEditTitle => 'ਖਾਤਾ ਐਂਟਰੀ ਸੁਧਾਰੋ';

  @override
  String get khataEditOriginal => 'ਅਸਲ ਐਂਟਰੀ (ਉਲਟਾ ਦਿੱਤੀ ਜਾਵੇਗੀ)';

  @override
  String get khataEditExplain =>
      'ਅਸਲ ਐਂਟਰੀ ਕੱਟੀ ਹੋਈ ਖਾਤੇ ਵਿੱਚ ਰਹੇਗੀ ਅਤੇ ਸਹੀ ਐਂਟਰੀ ਜੁੜੇਗੀ।';

  @override
  String get khataFieldParty => 'ਪਾਰਟੀ';

  @override
  String get khataFieldPartyHint => 'ਨਾਂ, ਪਿੰਡ ਜਾਂ ਕੋਡ ਲਿਖੋ';

  @override
  String get khataSideUdhaar => 'ਉਧਾਰ (ਪਾਰਟੀ ਦਾ ਦੇਣਾ ਵਧਿਆ)';

  @override
  String get khataSideJama => 'ਜਮ੍ਹਾ (ਸਾਡਾ ਦੇਣਾ ਵਧਿਆ)';

  @override
  String get khataFieldAmount => 'ਰਕਮ';

  @override
  String get khataFieldDate => 'ਤਰੀਕ';

  @override
  String get khataFieldNarration => 'ਵੇਰਵਾ';

  @override
  String get khataEntrySave => 'ਐਂਟਰੀ ਪਾਓ';

  @override
  String get khataEditSave => 'ਉਲਟਾ ਕੇ ਮੁੜ ਪਾਓ';

  @override
  String get khataDayBookTitle => 'ਸਾਰੀਆਂ ਐਂਟਰੀਆਂ';

  @override
  String get khataDayBookEmpty => 'ਇਸ ਫ਼ਿਲਟਰ ਵਿੱਚ ਕੋਈ ਐਂਟਰੀ ਨਹੀਂ';

  @override
  String get khataFilterParty => 'ਪਾਰਟੀ ਨਾਲ ਛਾਂਟੋ';

  @override
  String get khataFilterAllTypes => 'ਸਾਰੀਆਂ ਕਿਸਮਾਂ';

  @override
  String khataEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਐਂਟਰੀਆਂ',
      one: '1 ਐਂਟਰੀ',
    );
    return '$_temp0';
  }

  @override
  String get khataReverseTitle => 'ਇਹ ਐਂਟਰੀ ਉਲਟਾਓ?';

  @override
  String get khataReverseBody =>
      'ਉਲਟ ਐਂਟਰੀ ਜੁੜੇਗੀ ਅਤੇ ਦੋਵੇਂ ਖਾਤੇ ਵਿੱਚ ਰਹਿਣਗੀਆਂ। ਇਸਨੂੰ ਵਾਪਸ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਦਾ।';

  @override
  String get khataReverse => 'ਉਲਟਾਓ';

  @override
  String get khataReversed => 'ਐਂਟਰੀ ਉਲਟਾ ਦਿੱਤੀ ਗਈ';

  @override
  String get khataEntryActions => 'ਐਂਟਰੀ ਵਿਕਲਪ';

  @override
  String get khataEdit => 'ਸੁਧਾਰੋ (ਉਲਟਾ ਕੇ ਮੁੜ)';

  @override
  String get khataStatementEmpty => 'ਇਸ ਮਿਆਦ ਵਿੱਚ ਕੋਈ ਐਂਟਰੀ ਨਹੀਂ';

  @override
  String get statementTitle => 'ਖਾਤਾ ਵੇਰਵਾ';

  @override
  String get statementOpening => 'ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ';

  @override
  String get statementClosing => 'ਅੰਤਿਮ ਬਾਕੀ';

  @override
  String get statementTotals => 'ਕੁੱਲ';

  @override
  String statementPage(int page, int pages) {
    return 'ਸਫ਼ਾ $page / $pages';
  }

  @override
  String get statementPrint => 'ਪ੍ਰਿੰਟ / PDF';

  @override
  String get statementShare => 'ਭੇਜੋ';

  @override
  String get paletteHint => 'ਕਮਾਂਡ ਲਿਖੋ…';

  @override
  String get paletteNoMatch => 'ਕੋਈ ਕਮਾਂਡ ਨਹੀਂ ਮਿਲੀ';

  @override
  String get settingBusinessBackdateDays => 'ਪਿਛਲੀ ਤਰੀਕ ਦੀ ਛੋਟ (ਦਿਨ)';

  @override
  String get paymentsTitle => 'ਭੁਗਤਾਨ';

  @override
  String get paymentRecordTitle => 'ਭੁਗਤਾਨ ਦਰਜ ਕਰੋ';

  @override
  String get paymentPay => 'ਭੁਗਤਾਨ ਦਿਓ';

  @override
  String get paymentReceive => 'ਰਕਮ ਲਵੋ';

  @override
  String get paymentDirectionTo => 'ਪਾਰਟੀ ਨੂੰ ਦਿੱਤਾ';

  @override
  String get paymentDirectionFrom => 'ਪਾਰਟੀ ਤੋਂ ਮਿਲਿਆ';

  @override
  String get paymentsEmpty => 'ਇਸ ਮਿਆਦ ਵਿੱਚ ਕੋਈ ਭੁਗਤਾਨ ਨਹੀਂ';

  @override
  String get paymentsSearchHint => 'ਪਾਰਟੀ, ਰਸੀਦ ਜਾਂ ਚੈੱਕ ਨੰਬਰ ਲੱਭੋ';

  @override
  String get paymentsAllModes => 'ਸਾਰੇ ਤਰੀਕੇ';

  @override
  String get paymentsAllDirections => 'ਦਿੱਤਾ ਅਤੇ ਮਿਲਿਆ';

  @override
  String get paymentsPendingCheques => 'ਬਕਾਇਆ ਚੈੱਕ';

  @override
  String get paymentsTotalCount => 'ਭੁਗਤਾਨ';

  @override
  String get paymentsTotalPaid => 'ਦਿੱਤਾ';

  @override
  String get paymentsTotalReceived => 'ਮਿਲਿਆ';

  @override
  String get paymentsColNo => 'ਨੰਬਰ';

  @override
  String get paymentsColDate => 'ਤਰੀਕ';

  @override
  String get paymentsColParty => 'ਪਾਰਟੀ';

  @override
  String get paymentsColType => 'ਕਿਸਮ';

  @override
  String get paymentsColMode => 'ਤਰੀਕਾ';

  @override
  String get paymentsColAmount => 'ਰਕਮ';

  @override
  String get paymentsColStatus => 'ਸਥਿਤੀ';

  @override
  String get paymentFieldAmount => 'ਰਕਮ';

  @override
  String get paymentFieldDate => 'ਤਰੀਕ';

  @override
  String get paymentFieldMode => 'ਤਰੀਕਾ';

  @override
  String get paymentFieldAccount => 'ਬੈਂਕ ਖਾਤਾ';

  @override
  String get paymentFieldReference => 'UTR / ਹਵਾਲਾ';

  @override
  String get paymentFieldChequeNo => 'ਚੈੱਕ ਨੰਬਰ';

  @override
  String get paymentFieldChequeDate => 'ਚੈੱਕ ਦੀ ਤਰੀਕ';

  @override
  String get paymentFieldNarration => 'ਟਿੱਪਣੀ';

  @override
  String get paymentModeCash => 'ਨਕਦ';

  @override
  String get paymentModeBank => 'ਬੈਂਕ ਟ੍ਰਾਂਸਫਰ';

  @override
  String get paymentModeUpi => 'UPI';

  @override
  String get paymentModeCheque => 'ਚੈੱਕ';

  @override
  String get paymentChequePending => 'ਬਕਾਇਆ';

  @override
  String get paymentChequeCleared => 'ਕਲੀਅਰ';

  @override
  String get paymentChequeBounced => 'ਬਾਊਂਸ';

  @override
  String get paymentStatusReversed => 'ਉਲਟਾਇਆ';

  @override
  String get paymentBakiNow => 'ਹੁਣ ਬਾਕੀ';

  @override
  String get paymentBakiAfter => 'ਇਸ ਭੁਗਤਾਨ ਤੋਂ ਬਾਅਦ';

  @override
  String get paymentFullBaki => 'ਪੂਰਾ ਬਾਕੀ';

  @override
  String get paymentSave => 'ਭੁਗਤਾਨ ਸੰਭਾਲੋ';

  @override
  String paymentSavedAs(String receiptNo) {
    return '$receiptNo ਵਜੋਂ ਸੰਭਾਲਿਆ';
  }

  @override
  String get paymentReceiptTitle => 'ਰਸੀਦ';

  @override
  String get paymentVoucherTitle => 'ਭੁਗਤਾਨ ਵਾਊਚਰ';

  @override
  String get paymentPrintReceipt => 'ਰਸੀਦ ਪ੍ਰਿੰਟ ਕਰੋ';

  @override
  String get paymentShareReceipt => 'ਰਸੀਦ ਭੇਜੋ';

  @override
  String get paymentDone => 'ਹੋ ਗਿਆ';

  @override
  String get paymentMarkCleared => 'ਕਲੀਅਰ ਕਰੋ';

  @override
  String get paymentMarkBounced => 'ਬਾਊਂਸ ਕਰੋ';

  @override
  String get paymentBounceTitle => 'ਚੈੱਕ ਬਾਊਂਸ ਹੋਇਆ?';

  @override
  String get paymentBounceBody =>
      'ਇਸ ਨਾਲ ਖਾਤਾ ਐਂਟਰੀ ਅਤੇ ਕੈਸ਼ ਬੁੱਕ ਦੀ ਲਾਈਨ ਉਲਟ ਜਾਵੇਗੀ, ਬਾਊਂਸ ਦੀ ਤਰੀਕ ਨਾਲ।';

  @override
  String get paymentBounceDate => 'ਬਾਊਂਸ ਦੀ ਤਰੀਕ';

  @override
  String get paymentReverse => 'ਭੁਗਤਾਨ ਉਲਟਾਓ';

  @override
  String get paymentReverseTitle => 'ਇਹ ਭੁਗਤਾਨ ਉਲਟਾਈਏ?';

  @override
  String get paymentReverseBody =>
      'ਖਾਤਾ ਐਂਟਰੀ ਅਤੇ ਕੈਸ਼ ਬੁੱਕ ਦੀ ਲਾਈਨ ਉਲਟਾ ਦਿੱਤੀ ਜਾਵੇਗੀ। ਭੁਗਤਾਨ \"ਉਲਟਾਇਆ\" ਵਜੋਂ ਰਿਕਾਰਡ ਵਿੱਚ ਰਹੇਗਾ।';

  @override
  String get paymentReversedToast => 'ਭੁਗਤਾਨ ਉਲਟਾਇਆ ਗਿਆ';

  @override
  String get paymentClearedToast => 'ਚੈੱਕ ਕਲੀਅਰ ਕੀਤਾ ਗਿਆ';

  @override
  String get paymentBouncedToast => 'ਚੈੱਕ ਬਾਊਂਸ; ਐਂਟਰੀ ਉਲਟਾਈ ਗਈ';

  @override
  String get paymentNotFound => 'ਇਹ ਭੁਗਤਾਨ ਹੁਣ ਮੌਜੂਦ ਨਹੀਂ';

  @override
  String get paymentErrorNotPermitted =>
      'ਤੁਹਾਨੂੰ ਇਹ ਭੁਗਤਾਨ ਦਰਜ ਕਰਨ ਦੀ ਇਜਾਜ਼ਤ ਨਹੀਂ';

  @override
  String paymentErrorLimit(String limit) {
    return '$limit ਤੋਂ ਵੱਧ ਦੇ ਭੁਗਤਾਨ ਲਈ ਮੁਨੀਮ ਜਾਂ ਮਾਲਕ ਚਾਹੀਦਾ ਹੈ';
  }

  @override
  String get paymentErrorFinance =>
      'ਬੈਂਕ, UPI ਅਤੇ ਚੈੱਕ ਭੁਗਤਾਨ ਲਈ ਫਾਇਨੈਂਸ ਇਜਾਜ਼ਤ ਚਾਹੀਦੀ ਹੈ';

  @override
  String get paymentErrorNotFound => 'ਪਾਰਟੀ ਜਾਂ ਬੈਂਕ ਖਾਤਾ ਹੁਣ ਮੌਜੂਦ ਨਹੀਂ';

  @override
  String get paymentErrorLocked => 'ਇਹ ਭੁਗਤਾਨ ਜਾਂ ਚੈੱਕ ਹੁਣ ਨਹੀਂ ਬਦਲ ਸਕਦਾ';

  @override
  String get paymentErrorAmount => 'ਸਿਫ਼ਰ ਤੋਂ ਵੱਧ ਰਕਮ ਲਿਖੋ';

  @override
  String get paymentErrorBank => 'ਬੈਂਕ ਖਾਤਾ ਚੁਣੋ';

  @override
  String get paymentErrorChequeNo => 'ਚੈੱਕ ਨੰਬਰ ਲਿਖੋ';

  @override
  String get paymentErrorChequeDate => 'ਚੈੱਕ ਦੀ ਤਰੀਕ ਲਿਖੋ';

  @override
  String get paymentErrorChequeDetails => 'ਚੈੱਕ ਦੀ ਜਾਣਕਾਰੀ ਸਿਰਫ਼ ਚੈੱਕ ਨਾਲ ਦਿਓ';

  @override
  String get paymentNoBankAccounts =>
      'ਅਜੇ ਕੋਈ ਬੈਂਕ ਖਾਤਾ ਨਹੀਂ। \"ਬੈਂਕ ਖਾਤੇ\" ਵਿੱਚ ਜੋੜੋ।';

  @override
  String get accountsTitle => 'ਬੈਂਕ ਖਾਤੇ';

  @override
  String get accountsAdd => 'ਬੈਂਕ ਖਾਤਾ ਜੋੜੋ';

  @override
  String get accountsEdit => 'ਬੈਂਕ ਖਾਤਾ ਬਦਲੋ';

  @override
  String get accountsEmpty => 'ਅਜੇ ਕੋਈ ਬੈਂਕ ਖਾਤਾ ਨਹੀਂ';

  @override
  String get accountCash => 'ਨਕਦ';

  @override
  String get accountFieldName => 'ਖਾਤੇ ਦਾ ਨਾਂ';

  @override
  String get accountFieldBank => 'ਬੈਂਕ ਦਾ ਨਾਂ';

  @override
  String get accountFieldLast4 => 'ਖਾਤਾ ਨੰਬਰ ਦੇ ਆਖਰੀ 4 ਅੰਕ';

  @override
  String get accountFieldIfsc => 'IFSC';

  @override
  String get accountBookBalance => 'ਬਹੀ ਬਕਾਇਆ';

  @override
  String get accountSwitchOff => 'ਬੰਦ ਕਰੋ';

  @override
  String get accountSwitchOn => 'ਚਾਲੂ ਕਰੋ';

  @override
  String get accountInactive => 'ਬੰਦ';

  @override
  String get accountErrorName => 'ਖਾਤੇ ਦਾ ਨਾਂ ਲਿਖੋ';

  @override
  String get accountErrorLast4 => 'ਠੀਕ 4 ਅੰਕ';

  @override
  String get accountErrorIfsc => 'ਸਹੀ IFSC ਨਹੀਂ (ਜਿਵੇਂ SBIN0001234)';

  @override
  String get accountErrorNotPermitted =>
      'ਬੈਂਕ ਖਾਤਿਆਂ ਲਈ ਫਾਇਨੈਂਸ ਇਜਾਜ਼ਤ ਚਾਹੀਦੀ ਹੈ';

  @override
  String get receiptReceivedFrom => 'ਪ੍ਰਾਪਤ ਕੀਤਾ';

  @override
  String get receiptPaidTo => 'ਭੁਗਤਾਨ ਕੀਤਾ';

  @override
  String get receiptNo => 'ਨੰਬਰ';

  @override
  String get receiptDate => 'ਤਰੀਕ';

  @override
  String get receiptAmount => 'ਰਕਮ';

  @override
  String get receiptMode => 'ਤਰੀਕਾ';

  @override
  String get receiptReference => 'ਹਵਾਲਾ';

  @override
  String get receiptChequeNo => 'ਚੈੱਕ ਨੰ.';

  @override
  String get receiptChequeDate => 'ਚੈੱਕ ਦੀ ਤਰੀਕ';

  @override
  String get receiptBalanceAfter => 'ਇਸ ਤੋਂ ਬਾਅਦ ਬਾਕੀ';

  @override
  String get receiptSignature => 'ਦਸਤਖ਼ਤ';

  @override
  String get receiptReversed => 'ਉਲਟਾਇਆ';

  @override
  String get settingBusinessMunshiPaymentLimit =>
      'ਮੁਨੀਮ ਲਈ ਭੁਗਤਾਨ ਸੀਮਾ (₹, 0 = ਕੋਈ ਨਹੀਂ)';

  @override
  String dashHeroLots(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਅੱਜ $count ਲਾਟ ਆਏ',
    );
    return '$_temp0 · $amount ਆੜ੍ਹਤ ਕਮਾਈ';
  }

  @override
  String get dashHeroNoLots => 'ਅੱਜ ਹਜੇ ਤੱਕ ਕੋਈ ਲਾਟ ਨਹੀਂ ਆਇਆ';

  @override
  String get dashWeOweFarmers => 'ਸਾਨੂੰ ਕਿਸਾਨਾਂ ਨੂੰ ਦੇਣਾ ਹੈ';

  @override
  String get dashOthersOweUs => 'ਹੋਰਾਂ ਤੋਂ ਸਾਨੂੰ ਲੈਣਾ ਹੈ';

  @override
  String get dashActionAddFarmer => 'ਕਿਸਾਨ ਜੋੜੋ';

  @override
  String get dashStatLots => 'ਅੱਜ ਦੇ ਲਾਟ';

  @override
  String dashStatQtl(String qtl) {
    return '$qtl ਕੁਇੰਟਲ';
  }

  @override
  String get dashStatEarned => 'ਅੱਜ ਦੀ ਆੜ੍ਹਤ ਕਮਾਈ';

  @override
  String get dashStatPaid => 'ਅੱਜ ਦਿੱਤਾ ਗਿਆ';

  @override
  String get dashStatReceipts => 'ਅੱਜ ਦੀ ਪ੍ਰਾਪਤੀ';

  @override
  String get dashChartTitle => 'ਆੜ੍ਹਤ ਕਮਾਈ · ਪਿਛਲੇ 10 ਦਿਨ';

  @override
  String get dashChartEmpty => 'ਇਨ੍ਹਾਂ ਦਿਨਾਂ ਵਿੱਚ ਹਜੇ ਕੋਈ ਆੜ੍ਹਤ ਕਮਾਈ ਨਹੀਂ';

  @override
  String dashCropMixTitle(String year) {
    return 'ਵਿਕਰੀ ਮੁੱਲ ਅਨੁਸਾਰ ਫ਼ਸਲ · $year';
  }

  @override
  String get dashCropMixEmpty => 'ਇਸ ਸੀਜ਼ਨ ਵਿੱਚ ਹਜੇ ਕੋਈ ਵਿਕਰੀ ਪੋਸਟ ਨਹੀਂ ਹੋਈ';

  @override
  String dashCropMixLots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਲਾਟ',
    );
    return '$_temp0';
  }

  @override
  String get dashMoneyTitle => 'ਪੈਸਾ ਕਿੱਥੇ ਹੈ';

  @override
  String get dashFarmersPayable => 'ਕਿਸਾਨ ਖਾਤਾ · ਸਾਨੂੰ ਦੇਣਾ ਹੈ';

  @override
  String get dashFarmersReceivable => 'ਕਿਸਾਨ ਖਾਤਾ · ਕਿਸਾਨਾਂ ਤੋਂ ਲੈਣਾ ਹੈ';

  @override
  String get dashOthersReceivable => 'ਹੋਰ ਪਾਰਟੀਆਂ ਤੋਂ ਲੈਣਾ ਹੈ';

  @override
  String get dashNeedsTitle => 'ਅੱਜ ਤੁਹਾਡੀ ਲੋੜ ਹੈ';

  @override
  String get dashNeedsNothing => 'ਹੁਣੇ ਕੁਝ ਵੀ ਜ਼ਰੂਰੀ ਨਹੀਂ';

  @override
  String dashNeedsSyncErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਬਦਲਾਅ ਸਰਵਰ ਨੇ ਰੱਦ ਕੀਤੇ',
    );
    return '$_temp0';
  }

  @override
  String dashNeedsCheques(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਚੈੱਕ ਦੀ ਤਾਰੀਖ ਆ ਗਈ',
    );
    return '$_temp0 · $amount';
  }

  @override
  String dashNeedsStaff(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਪਿਛਲੇ 7 ਦਿਨਾਂ ਵਿੱਚ ਮੁਨਸ਼ੀ ਦੇ $count ਬਦਲਾਅ',
    );
    return '$_temp0';
  }

  @override
  String get dashStatEarnedSub => 'ਪੋਸਟ ਕੀਤੇ ਲਾਟਾਂ ਤੋਂ';

  @override
  String get dashStatPaidSub => 'ਪਾਰਟੀਆਂ ਨੂੰ';

  @override
  String get dashStatReceiptsSub => 'ਪਾਰਟੀਆਂ ਤੋਂ';

  @override
  String get reportsTitle => 'ਰਿਪੋਰਟਾਂ';

  @override
  String get reportOutstanding => 'ਬਕਾਇਆ (ਬਾਕੀ)';

  @override
  String get reportArrivals => 'ਆਮਦ ਰਜਿਸਟਰ';

  @override
  String get reportCommission => 'ਆੜ੍ਹਤ ਕਮਾਈ';

  @override
  String get reportPayments => 'ਭੁਗਤਾਨ ਰਜਿਸਟਰ';

  @override
  String get reportStatements => 'ਪਾਰਟੀ ਵੇਰਵੇ';

  @override
  String get reportColCode => 'ਕੋਡ';

  @override
  String get reportColParty => 'ਪਾਰਟੀ';

  @override
  String get reportColVillage => 'ਪਿੰਡ';

  @override
  String get reportColWeOwe => 'ਅਸੀਂ ਦੇਣਾ ਹੈ';

  @override
  String get reportColTheyOwe => 'ਸਾਨੂੰ ਲੈਣਾ ਹੈ';

  @override
  String get reportColLastEntry => 'ਆਖਰੀ ਐਂਟਰੀ';

  @override
  String get reportColDays => 'ਦਿਨ';

  @override
  String get reportColAgeing => 'ਮਿਆਦ';

  @override
  String get reportColLot => 'ਲਾਟ';

  @override
  String get reportColDate => 'ਤਾਰੀਖ਼';

  @override
  String get reportColFarmer => 'ਕਿਸਾਨ';

  @override
  String get reportColCrop => 'ਫ਼ਸਲ';

  @override
  String get reportColBags => 'ਬੋਰੀਆਂ';

  @override
  String get reportColQtl => 'ਕੁਇੰਟਲ';

  @override
  String get reportColRate => 'ਭਾਅ / ਕੁਇੰਟਲ';

  @override
  String get reportColGross => 'ਕੁੱਲ ਵਿਕਰੀ';

  @override
  String get reportColCharges => 'ਕਟੌਤੀ';

  @override
  String get reportColNet => 'ਕਿਸਾਨ ਨੂੰ ਸ਼ੁੱਧ';

  @override
  String get reportColBuyer => 'ਖਰੀਦਦਾਰ';

  @override
  String get reportColStatus => 'ਸਥਿਤੀ';

  @override
  String get reportColLots => 'ਲਾਟ';

  @override
  String get reportColSaleValue => 'ਵਿਕਰੀ ਮੁੱਲ';

  @override
  String get reportColArhat => 'ਆੜ੍ਹਤ';

  @override
  String get reportColReceipt => 'ਰਸੀਦ ਨੰ.';

  @override
  String get reportColMode => 'ਤਰੀਕਾ';

  @override
  String get reportColReceived => 'ਪ੍ਰਾਪਤ';

  @override
  String get reportColPaid => 'ਦਿੱਤਾ';

  @override
  String get reportColReference => 'ਹਵਾਲਾ';

  @override
  String get reportColOpening => 'ਸ਼ੁਰੂਆਤੀ';

  @override
  String get reportColUdhaar => 'ਉਧਾਰ';

  @override
  String get reportColJama => 'ਜਮ੍ਹਾ';

  @override
  String get reportColClosing => 'ਅੰਤਮ ਬਾਕੀ';

  @override
  String get reportTotal => 'ਕੁੱਲ';

  @override
  String get reportAgeUpTo30 => '0–30 ਦਿਨ';

  @override
  String get reportAgeUpTo90 => '31–90 ਦਿਨ';

  @override
  String get reportAgeUpTo180 => '91–180 ਦਿਨ';

  @override
  String get reportAgeOver180 => '180 ਦਿਨਾਂ ਤੋਂ ਵੱਧ';

  @override
  String get reportAgeingTitle => 'ਪੁਰਾਣਾ ਬਕਾਇਆ';

  @override
  String reportAsOf(String date) {
    return '$date ਤੱਕ';
  }

  @override
  String reportPeriod(String range) {
    return 'ਮਿਆਦ: $range';
  }

  @override
  String get reportSideAll => 'ਸਾਰੇ';

  @override
  String get reportSidePayable => 'ਅਸੀਂ ਦੇਣਾ ਹੈ';

  @override
  String get reportSideReceivable => 'ਸਾਨੂੰ ਲੈਣਾ ਹੈ';

  @override
  String get reportFilterAllCrops => 'ਸਾਰੀਆਂ ਫ਼ਸਲਾਂ';

  @override
  String get reportFilterAllModes => 'ਸਾਰੇ ਤਰੀਕੇ';

  @override
  String get reportFilterAllVillages => 'ਸਾਰੇ ਪਿੰਡ';

  @override
  String get reportFilterAsOf => 'ਇਸ ਤਾਰੀਖ਼ ਤੱਕ';

  @override
  String get reportExportPdf => 'PDF';

  @override
  String get reportExportExcel => 'Excel';

  @override
  String get reportExportCsv => 'CSV';

  @override
  String get reportPrint => 'ਪ੍ਰਿੰਟ';

  @override
  String get reportExportLocked => 'ਐਕਸਪੋਰਟ ਲਈ ਵਿੱਤ ਇਜਾਜ਼ਤ ਚਾਹੀਦੀ ਹੈ';

  @override
  String get reportRestricted => 'ਇਸ ਰਿਪੋਰਟ ਲਈ ਵਿੱਤ ਇਜਾਜ਼ਤ ਚਾਹੀਦੀ ਹੈ';

  @override
  String reportRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਕਤਾਰਾਂ',
    );
    return '$_temp0';
  }

  @override
  String get reportEmpty => 'ਇਨ੍ਹਾਂ ਫ਼ਿਲਟਰਾਂ ਲਈ ਕੁਝ ਨਹੀਂ';

  @override
  String reportExportSaved(String name) {
    return '$name ਸੇਵ ਹੋਈ';
  }

  @override
  String reportExportFailed(String error) {
    return 'ਐਕਸਪੋਰਟ ਨਹੀਂ ਹੋਇਆ: $error';
  }

  @override
  String get reportStatementsHelp =>
      'ਪਿੰਡ ਦੇ ਹਰ ਕਿਸਾਨ ਦਾ ਵੇਰਵਾ ਇੱਕ PDF ਵਿੱਚ, ਹਰ ਇੱਕ ਨਵੇਂ ਪੰਨੇ ਤੋਂ।';

  @override
  String reportStatementsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਕਿਸਾਨ',
    );
    return '$_temp0';
  }

  @override
  String get reportStatementsPdf => 'ਵੇਰਵੇ PDF';

  @override
  String get teamTitle => 'ਯੂਜ਼ਰ ਅਤੇ ਇਜਾਜ਼ਤਾਂ';

  @override
  String get teamTabPeople => 'ਲੋਕ';

  @override
  String get teamTabDevices => 'ਡਿਵਾਈਸ';

  @override
  String get teamInvite => 'ਕਿਸੇ ਨੂੰ ਜੋੜੋ';

  @override
  String get teamNoAccess => 'ਯੂਜ਼ਰ ਸਿਰਫ਼ ਮਾਲਕ ਸੰਭਾਲ ਸਕਦਾ ਹੈ।';

  @override
  String get teamYou => 'ਤੁਸੀਂ';

  @override
  String get teamInactive => 'ਬੰਦ ਕੀਤਾ';

  @override
  String teamDevicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਡਿਵਾਈਸ',
    );
    return '$_temp0';
  }

  @override
  String get teamPendingInvites => 'ਜੁੜਨ ਦੀ ਉਡੀਕ';

  @override
  String teamInviteExpires(String date) {
    return '$date ਨੂੰ ਖਤਮ';
  }

  @override
  String get teamInviteExpired => 'ਖਤਮ ਹੋ ਗਿਆ';

  @override
  String get teamInviteCancel => 'ਸੱਦਾ ਰੱਦ ਕਰੋ';

  @override
  String get teamInviteCancelled => 'ਸੱਦਾ ਰੱਦ ਹੋਇਆ';

  @override
  String get teamEmptyPeople => 'ਹਾਲੇ ਇੱਥੇ ਕੋਈ ਨਹੀਂ।';

  @override
  String get teamEmptyDevices => 'ਹਾਲੇ ਕੋਈ ਡਿਵਾਈਸ ਨਹੀਂ।';

  @override
  String get teamRole => 'ਭੂਮਿਕਾ';

  @override
  String get teamPermissions => 'ਉਹ ਕੀ ਕਰ ਸਕਦੇ ਹਨ';

  @override
  String get teamPermissionsHelp =>
      'ਇਸ ਵਿਅਕਤੀ ਲਈ ਇਜਾਜ਼ਤ ਚਾਲੂ ਜਾਂ ਬੰਦ ਕਰੋ। ਬਿੰਦੀ ਦਾ ਮਤਲਬ ਭੂਮਿਕਾ ਦੇ ਡਿਫ਼ਾਲਟ ਤੋਂ ਬਦਲਾਅ ਹੈ।';

  @override
  String get teamPermissionChanged => 'ਭੂਮਿਕਾ ਦੇ ਡਿਫ਼ਾਲਟ ਤੋਂ ਵੱਖਰਾ';

  @override
  String get teamPermissionSensitive => 'ਤਾਕਤਵਰ: ਸੋਚ-ਸਮਝ ਕੇ ਦਿਓ';

  @override
  String get teamOwnerAll =>
      'ਮਾਲਕ ਸਭ ਕੁਝ ਕਰ ਸਕਦਾ ਹੈ। ਇਸਨੂੰ ਬਦਲਿਆ ਨਹੀਂ ਜਾ ਸਕਦਾ।';

  @override
  String get teamDeviceLimit => 'ਮਨਜ਼ੂਰ ਡਿਵਾਈਸ';

  @override
  String get teamSave => 'ਬਦਲਾਅ ਸੇਵ ਕਰੋ';

  @override
  String get teamSaved => 'ਸੇਵ ਹੋਇਆ';

  @override
  String get teamDeactivate => 'ਬੰਦ ਕਰੋ';

  @override
  String get teamReactivate => 'ਮੁੜ ਚਾਲੂ ਕਰੋ';

  @override
  String teamDeactivateTitle(String name) {
    return '$name ਨੂੰ ਬੰਦ ਕਰੀਏ?';
  }

  @override
  String get teamDeactivateBody =>
      'ਉਹ ਇਹ ਕਾਰੋਬਾਰ ਨਹੀਂ ਖੋਲ੍ਹ ਸਕਣਗੇ ਅਤੇ ਉਨ੍ਹਾਂ ਦੇ ਡਿਵਾਈਸ ਤੋਂ ਡੇਟਾ ਹਟ ਜਾਵੇਗਾ। ਉਨ੍ਹਾਂ ਦੀਆਂ ਪੁਰਾਣੀਆਂ ਐਂਟਰੀਆਂ ਬਹੀ ਵਿੱਚ ਰਹਿਣਗੀਆਂ।';

  @override
  String get teamDeactivated => 'ਬੰਦ ਕੀਤਾ ਗਿਆ';

  @override
  String get teamReactivated => 'ਮੁੜ ਚਾਲੂ ਹੋਇਆ';

  @override
  String get teamErrLastOwner =>
      'ਕਾਰੋਬਾਰ ਵਿੱਚ ਘੱਟੋ-ਘੱਟ ਇੱਕ ਚਾਲੂ ਮਾਲਕ ਰਹਿਣਾ ਜ਼ਰੂਰੀ ਹੈ।';

  @override
  String get teamErrProtected =>
      'ਮਾਲਕ ਨੂੰ ਸਿਰਫ਼ ਮਾਲਕ ਬਦਲ ਸਕਦਾ ਹੈ, ਅਤੇ ਤੁਸੀਂ ਆਪਣੀ ਪਹੁੰਚ ਆਪ ਨਹੀਂ ਬਦਲ ਸਕਦੇ।';

  @override
  String get teamErrNotFound => 'ਇਹ ਵਿਅਕਤੀ ਨਹੀਂ ਮਿਲਿਆ।';

  @override
  String get teamDeviceThis => 'ਇਹ ਡਿਵਾਈਸ';

  @override
  String teamDeviceLastSeen(String when) {
    return 'ਆਖਰੀ ਵਾਰ $when';
  }

  @override
  String get teamDeviceNeverSeen => 'ਹਾਲੇ ਤੱਕ ਨਹੀਂ ਦਿਸਿਆ';

  @override
  String get teamDeviceRevoke => 'ਹਟਾਓ';

  @override
  String get teamDeviceRevoked => 'ਹਟਾਇਆ ਗਿਆ';

  @override
  String teamRevokeTitle(String code) {
    return 'ਡਿਵਾਈਸ $code ਹਟਾਈਏ?';
  }

  @override
  String get teamRevokeBody =>
      'ਇਹ ਸਿੰਕ ਕਰਨਾ ਬੰਦ ਕਰ ਦੇਵੇਗਾ ਅਤੇ ਇਸਦੀ ਐਪ ਬੰਦ ਹੋ ਜਾਵੇਗੀ। ਆਫ਼ਲਾਈਨ ਕੀਤੇ ਬਦਲਾਅ ਰੱਦ ਹੋਣਗੇ। ਇਸਨੂੰ ਵਾਪਸ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਦਾ; ਵਿਅਕਤੀ ਨਵੀਂ ਡਿਵਾਈਸ ਜੋੜ ਸਕਦਾ ਹੈ।';

  @override
  String get teamRevokeDone => 'ਡਿਵਾਈਸ ਹਟਾਈ ਗਈ';

  @override
  String get teamErrThisDevice => 'ਜਿਸ ਡਿਵਾਈਸ ਤੇ ਤੁਸੀਂ ਹੋ ਉਸਨੂੰ ਨਹੀਂ ਹਟਾ ਸਕਦੇ।';

  @override
  String get permission_partiesManage => 'ਪਾਰਟੀ ਵੇਖੋ ਤੇ ਜੋੜੋ';

  @override
  String get permission_arrivalsManage => 'ਆਮਦ ਅਤੇ ਲਾਟ';

  @override
  String get permission_paymentsCreate => 'ਭੁਗਤਾਨ ਦਰਜ ਕਰੋ';

  @override
  String get permission_entriesReverse => 'ਪੁਰਾਣੀ ਐਂਟਰੀ ਬਦਲੋ ਜਾਂ ਉਲਟਾਓ';

  @override
  String get permission_loansManage => 'ਕਰਜ਼ਾ ਦਿਓ, ਵਿਆਜ ਬਦਲੋ';

  @override
  String get permission_financeView => 'ਬੈਂਕ ਵੇਰਵੇ, ਮੁਨਾਫ਼ਾ, ਰਿਪੋਰਟ ਐਕਸਪੋਰਟ';

  @override
  String get permission_adminManage => 'ਯੂਜ਼ਰ, ਮਾਡਿਊਲ, ਸਬਸਕ੍ਰਿਪਸ਼ਨ';

  @override
  String get permission_masterDelete => 'ਪਾਰਟੀ ਅਤੇ ਹੋਰ ਮਾਸਟਰ ਡੇਟਾ ਹਟਾਓ';

  @override
  String get permission_settingsManage => 'ਪੂਰੇ ਕਾਰੋਬਾਰ ਦੀ ਸੈਟਿੰਗ';

  @override
  String get permission_auditView => 'ਆਡਿਟ ਲੌਗ ਵੇਖੋ';

  @override
  String get inviteTitle => 'ਕਿਸੇ ਨੂੰ ਜੋੜੋ';

  @override
  String get invitePhone => 'ਮੋਬਾਈਲ ਨੰਬਰ';

  @override
  String get inviteName => 'ਨਾਂ (ਚੋਣਵਾਂ)';

  @override
  String get inviteChannel => 'ਭੇਜੋ';

  @override
  String get inviteChannelWhatsapp => 'ਵਟਸਐਪ';

  @override
  String get inviteChannelSms => 'SMS';

  @override
  String get inviteSend => 'ਸੱਦਾ ਭੇਜੋ';

  @override
  String get inviteErrPhone => 'ਸਹੀ 10 ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਪਾਓ।';

  @override
  String get inviteErrRole =>
      'ਇਸ ਭੂਮਿਕਾ ਨੂੰ ਸੱਦਾ ਨਹੀਂ ਦਿੱਤਾ ਜਾ ਸਕਦਾ। ਮਾਲਕ ਸੱਦੇ ਨਾਲ ਨਹੀਂ ਜੁੜਦੇ।';

  @override
  String get inviteErrAlreadyMember =>
      'ਇਹ ਵਿਅਕਤੀ ਪਹਿਲਾਂ ਹੀ ਤੁਹਾਡੀ ਟੀਮ ਵਿੱਚ ਹੈ।';

  @override
  String get inviteErrAlreadyInvited =>
      'ਇਸ ਨੰਬਰ ਨੂੰ ਪਹਿਲਾਂ ਹੀ ਸੱਦਾ ਭੇਜਿਆ ਜਾ ਚੁੱਕਾ ਹੈ।';

  @override
  String get inviteErrNotAllowed => 'ਲੋਕਾਂ ਨੂੰ ਸਿਰਫ਼ ਮਾਲਕ ਜੋੜ ਸਕਦਾ ਹੈ।';

  @override
  String get inviteErrOffline =>
      'ਸੱਦਾ ਭੇਜਣ ਲਈ ਇੰਟਰਨੈੱਟ ਚਾਹੀਦਾ ਹੈ। ਜੁੜ ਕੇ ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get inviteErrFailed => 'ਸੱਦਾ ਨਹੀਂ ਬਣ ਸਕਿਆ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String inviteSentWhatsapp(String phone) {
    return '$phone ਨੂੰ ਵਟਸਐਪ ਤੇ ਸੱਦਾ ਭੇਜਿਆ ਗਿਆ।';
  }

  @override
  String inviteSentSms(String phone) {
    return '$phone ਨੂੰ SMS ਨਾਲ ਸੱਦਾ ਭੇਜਿਆ ਗਿਆ।';
  }

  @override
  String get inviteNotSentTitle => 'ਸੱਦਾ ਸੇਵ ਹੋਇਆ: ਆਪ ਭੇਜੋ';

  @override
  String inviteNotSentBody(String phone) {
    return 'ਕੋਈ ਮੈਸੇਜ ਸੇਵਾ ਚਾਲੂ ਨਹੀਂ ਹੈ, ਇਸ ਲਈ ਕੁਝ ਨਹੀਂ ਭੇਜਿਆ ਗਿਆ। ਇਹ ਸੁਨੇਹਾ ਕਾਪੀ ਕਰਕੇ $phone ਨੂੰ ਭੇਜੋ। ਉਸ ਨੰਬਰ ਨਾਲ ਸਾਈਨ ਇਨ ਕਰਦੇ ਹੀ ਉਹ ਜੁੜ ਜਾਣਗੇ।';
  }

  @override
  String get inviteCopy => 'ਸੁਨੇਹਾ ਕਾਪੀ ਕਰੋ';

  @override
  String get inviteCopied => 'ਕਾਪੀ ਹੋਇਆ';

  @override
  String get deviceRevokedTitle => 'ਇਹ ਡਿਵਾਈਸ ਹਟਾ ਦਿੱਤੀ ਗਈ';

  @override
  String get deviceRevokedBody =>
      'ਮਾਲਕ ਨੇ ਇਸ ਡਿਵਾਈਸ ਨੂੰ ਹਟਾ ਦਿੱਤਾ ਹੈ। ਇੱਥੋਂ ਹੁਣ ਕੁਝ ਸੇਵ ਨਹੀਂ ਹੋ ਸਕਦਾ। ਆਫ਼ਲਾਈਨ ਕੀਤੇ ਬਦਲਾਅ ਮਨਜ਼ੂਰ ਨਹੀਂ ਹੋਏ।';

  @override
  String get deviceRevokedSetupAgain => 'ਇਸ ਡਿਵਾਈਸ ਨੂੰ ਮੁੜ ਜੋੜੋ';

  @override
  String get tenantPickerCheckInvites => 'ਸੱਦੇ ਵੇਖੋ';

  @override
  String get tenantPickerNoInvites =>
      'ਤੁਹਾਡੇ ਨੰਬਰ ਲਈ ਹਾਲੇ ਕੋਈ ਸੱਦਾ ਨਹੀਂ ਮਿਲਿਆ।';

  @override
  String get tenantPickerInvitesOffline => 'ਸੱਦੇ ਵੇਖਣ ਲਈ ਇੰਟਰਨੈੱਟ ਨਾਲ ਜੁੜੋ।';

  @override
  String deviceSetupLimit(String business) {
    return 'ਇਸ ਅਕਾਊਂਟ ਦੇ $business ਵਿੱਚ ਸਾਰੀਆਂ ਡਿਵਾਈਸਾਂ ਵਰਤੀਆਂ ਜਾ ਚੁੱਕੀਆਂ ਹਨ। ਮਾਲਕ ਨੂੰ ਕਹੋ ਕਿ ਕੋਈ ਪੁਰਾਣੀ ਹਟਾ ਦੇਵੇ।';
  }

  @override
  String deviceSetupRevoked(String business) {
    return 'ਇਸ ਡਿਵਾਈਸ ਨੂੰ $business ਦੇ ਮਾਲਕ ਨੇ ਹਟਾ ਦਿੱਤਾ ਹੈ।';
  }

  @override
  String get auditTitle => 'ਆਡਿਟ ਲੌਗ';

  @override
  String get auditNoAccess => 'ਆਡਿਟ ਲੌਗ ਸਿਰਫ਼ ਮਾਲਕ ਵੇਖ ਸਕਦਾ ਹੈ।';

  @override
  String get auditFilterUser => 'ਵਿਅਕਤੀ';

  @override
  String get auditFilterTable => 'ਰਿਕਾਰਡ ਦੀ ਕਿਸਮ';

  @override
  String get auditAllUsers => 'ਸਭ';

  @override
  String get auditAllTables => 'ਸਾਰੇ ਰਿਕਾਰਡ';

  @override
  String get auditOnlyMoney => 'ਸਿਰਫ਼ ਰਕਮ ਦੇ ਬਦਲਾਅ ਅਤੇ ਉਲਟਾਅ';

  @override
  String get auditEmpty => 'ਕੋਈ ਐਂਟਰੀ ਨਹੀਂ ਮਿਲੀ।';

  @override
  String get auditShowMore => 'ਹੋਰ ਵਿਖਾਓ';

  @override
  String get auditBadgeMoneyEdit => 'ਰਕਮ ਬਦਲੀ';

  @override
  String get auditBadgeReversal => 'ਉਲਟਾਅ';

  @override
  String auditByUser(String name, String role) {
    return '$name · $role';
  }

  @override
  String auditOnDevice(String code) {
    return 'ਡਿਵਾਈਸ $code';
  }

  @override
  String get auditSystem => 'ਸਿਸਟਮ';

  @override
  String auditMoreFields(int count) {
    return '+$count ਹੋਰ';
  }

  @override
  String get auditEmptyValue => '—';

  @override
  String get auditYes => 'ਹਾਂ';

  @override
  String get auditNo => 'ਨਹੀਂ';

  @override
  String get auditAction_insert => 'ਜੋੜਿਆ';

  @override
  String get auditAction_update => 'ਬਦਲਿਆ';

  @override
  String get auditAction_reverse => 'ਉਲਟਾਇਆ';

  @override
  String get auditAction_soft_delete => 'ਹਟਾਇਆ';

  @override
  String get auditAction_restore => 'ਵਾਪਸ ਲਿਆਂਦਾ';

  @override
  String get auditTable_ledger_entries => 'ਖਾਤਾ ਐਂਟਰੀ';

  @override
  String get auditTable_payments => 'ਭੁਗਤਾਨ';

  @override
  String get auditTable_cash_bank_entries => 'ਨਕਦ / ਬੈਂਕ ਲਾਈਨ';

  @override
  String get auditTable_lots => 'ਲਾਟ';

  @override
  String get auditTable_parties => 'ਪਾਰਟੀ';

  @override
  String get auditTable_party_roles => 'ਪਾਰਟੀ ਦੀ ਭੂਮਿਕਾ';

  @override
  String get auditTable_crops => 'ਫ਼ਸਲ';

  @override
  String get auditTable_bank_accounts => 'ਬੈਂਕ ਖਾਤਾ';

  @override
  String get auditTable_settings => 'ਸੈਟਿੰਗ';

  @override
  String get auditTable_tenant_members => 'ਟੀਮ ਮੈਂਬਰ';

  @override
  String get auditTable_member_invites => 'ਸੱਦਾ';

  @override
  String get auditTable_devices => 'ਡਿਵਾਈਸ';

  @override
  String get auditField_amount_paise => 'ਰਕਮ';

  @override
  String get auditField_gross => 'ਕੁੱਲ ਮੁੱਲ';

  @override
  String get auditField_commission => 'ਕਮਿਸ਼ਨ';

  @override
  String get auditField_net_to_farmer => 'ਕਿਸਾਨ ਨੂੰ ਸ਼ੁੱਧ';

  @override
  String get auditField_buyer_total => 'ਖਰੀਦਦਾਰ ਦਾ ਕੁੱਲ';

  @override
  String get auditField_rate_paise_per_qtl => 'ਭਾਅ ਪ੍ਰਤੀ ਕੁਇੰਟਲ';

  @override
  String get auditField_qtl_milli => 'ਕੁਇੰਟਲ';

  @override
  String get auditField_status => 'ਸਥਿਤੀ';

  @override
  String get auditField_role => 'ਭੂਮਿਕਾ';

  @override
  String get auditField_is_active => 'ਚਾਲੂ';

  @override
  String get auditField_device_limit => 'ਮਨਜ਼ੂਰ ਡਿਵਾਈਸ';

  @override
  String get auditField_custom_permissions => 'ਇਜਾਜ਼ਤ ਵਿੱਚ ਬਦਲਾਅ';

  @override
  String get auditField_revoked_at => 'ਹਟਾਉਣ ਦਾ ਸਮਾਂ';

  @override
  String get auditField_phone => 'ਮੋਬਾਈਲ';

  @override
  String get auditField_name => 'ਨਾਂ';

  @override
  String get auditField_cheque_status => 'ਚੈੱਕ';

  @override
  String get auditField_entry_date => 'ਤਾਰੀਖ';

  @override
  String get auditField_side => 'ਪਾਸਾ';

  @override
  String get auditField_direction => 'ਦਿਸ਼ਾ';
}
