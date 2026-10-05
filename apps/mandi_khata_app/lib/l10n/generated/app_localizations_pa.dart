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

  @override
  String get onboardingTitle => 'ਆਪਣਾ ਕਾਰੋਬਾਰ ਸੈੱਟ ਕਰੋ';

  @override
  String get onboardingBack => 'ਪਿੱਛੇ';

  @override
  String get onboardingNext => 'ਸੇਵ ਕਰੋ ਅਤੇ ਅੱਗੇ ਵਧੋ';

  @override
  String get onboardingFinish => 'ਸੈੱਟਅੱਪ ਪੂਰਾ ਕਰੋ';

  @override
  String get onboardingSkip => 'ਹੁਣ ਲਈ ਸੈੱਟਅੱਪ ਛੱਡੋ';

  @override
  String onboardingStepOf(int current, int total) {
    return 'ਕਦਮ $current / $total';
  }

  @override
  String get onboardingErrNotPermitted =>
      'ਤੁਹਾਨੂੰ ਇਹ ਸੇਵ ਕਰਨ ਦੀ ਇਜਾਜ਼ਤ ਨਹੀਂ ਹੈ।';

  @override
  String get onboardingErrInvalid =>
      'ਇਹ ਜਾਣਕਾਰੀ ਸੇਵ ਨਹੀਂ ਹੋ ਸਕੀ। ਕਿਰਪਾ ਕਰਕੇ ਜਾਂਚੋ।';

  @override
  String get onboardingOwnerOnly =>
      'ਸੈੱਟਅੱਪ ਸਿਰਫ਼ ਕਾਰੋਬਾਰ ਦਾ ਮਾਲਕ ਚਲਾ ਸਕਦਾ ਹੈ।';

  @override
  String get onboardingBusinessTitle => 'ਕਾਰੋਬਾਰ ਦੀ ਜਾਣਕਾਰੀ';

  @override
  String get onboardingBusinessHint => 'ਇਹ ਰਸੀਦਾਂ ਅਤੇ ਸਟੇਟਮੈਂਟਾਂ ਤੇ ਛਪਣਗੇ।';

  @override
  String get onboardingBusinessName => 'ਕਾਰੋਬਾਰ ਦਾ ਨਾਮ';

  @override
  String get onboardingLegalName => 'ਕਾਨੂੰਨੀ ਨਾਮ (ਚੋਣਵਾਂ)';

  @override
  String get onboardingGstin => 'GSTIN (ਚੋਣਵਾਂ)';

  @override
  String get onboardingPhone => 'ਫ਼ੋਨ (ਚੋਣਵਾਂ)';

  @override
  String get onboardingAddress => 'ਪਤਾ (ਚੋਣਵਾਂ)';

  @override
  String get onboardingGstinInvalid => 'ਇਹ GSTIN ਸਹੀ ਨਹੀਂ ਹੈ।';

  @override
  String get onboardingPhoneInvalid => '10 ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਪਾਓ।';

  @override
  String get onboardingMandiTitle => 'ਮੰਡੀ ਅਤੇ ਰਾਜ';

  @override
  String get onboardingMandiHint => 'ਤੁਹਾਡੀ ਦੁਕਾਨ ਕਿੱਥੇ ਹੈ।';

  @override
  String get onboardingState => 'ਰਾਜ';

  @override
  String get onboardingStateOther => 'ਹੋਰ / ਸੂਚੀ ਵਿੱਚ ਨਹੀਂ';

  @override
  String get onboardingMandiName => 'ਮੰਡੀ';

  @override
  String get onboardingMandiNameHint => 'ਜਿਵੇਂ ਖੰਨਾ, ਨਾਭਾ';

  @override
  String get onboardingCropsTitle => 'ਤੁਸੀਂ ਜਿਨ੍ਹਾਂ ਫ਼ਸਲਾਂ ਦਾ ਕੰਮ ਕਰਦੇ ਹੋ';

  @override
  String get onboardingCropsHint =>
      'ਬੰਦ ਕੀਤੀਆਂ ਫ਼ਸਲਾਂ ਫਾਰਮਾਂ ਵਿੱਚ ਨਹੀਂ ਦਿਸਣਗੀਆਂ। ਬਾਅਦ ਵਿੱਚ ਬਦਲ ਸਕਦੇ ਹੋ।';

  @override
  String get onboardingCropsNone => 'ਘੱਟੋ-ਘੱਟ ਇੱਕ ਫ਼ਸਲ ਚੁਣੋ।';

  @override
  String get onboardingSelectAll => 'ਸਾਰੀਆਂ ਚੁਣੋ';

  @override
  String get onboardingSelectNone => 'ਸਾਰੀਆਂ ਹਟਾਓ';

  @override
  String get onboardingChargesTitle => 'ਡਿਫਾਲਟ ਕਮਿਸ਼ਨ ਅਤੇ ਖਰਚੇ';

  @override
  String get onboardingChargesHint =>
      'ਹਰ ਲਾਟ ਤੇ ਲੱਗਣਗੇ, ਜਦ ਤੱਕ ਕਿਸੇ ਫ਼ਸਲ ਜਾਂ ਕਿਸਾਨ ਦਾ ਆਪਣਾ ਰੇਟ ਨਾ ਹੋਵੇ।';

  @override
  String get onboardingChargesCascade =>
      'ਹਰ ਫ਼ਸਲ ਅਤੇ ਹਰ ਪਾਰਟੀ ਲਈ ਬਾਅਦ ਵਿੱਚ ਵੱਖਰਾ ਰੇਟ ਰੱਖਿਆ ਜਾ ਸਕਦਾ ਹੈ।';

  @override
  String get onboardingNumberInvalid => 'ਸਹੀ ਨੰਬਰ ਪਾਓ।';

  @override
  String get onboardingInterestTitle => 'ਵਿਆਜ ਦੇ ਡਿਫਾਲਟ';

  @override
  String get onboardingInterestHint => 'ਵਿਆਜ ਦਾ ਤੁਹਾਡਾ ਆਮ ਰੇਟ ਅਤੇ ਤਰੀਕਾ।';

  @override
  String get onboardingInterestStoredOnly =>
      'ਹੁਣ ਸਿਰਫ਼ ਸੇਵ ਹੁੰਦਾ ਹੈ। ਵਿਆਜ ਦੀ ਗਿਣਤੀ ਬਾਅਦ ਦੇ ਅੱਪਡੇਟ ਵਿੱਚ ਆਵੇਗੀ।';

  @override
  String get onboardingLanguageTitle => 'ਭਾਸ਼ਾ';

  @override
  String get onboardingLanguageHint =>
      'ਐਪ ਹੁਣ ਬਦਲ ਜਾਵੇਗੀ। ਇਹੀ ਤੁਹਾਡੇ ਕਾਰੋਬਾਰ ਦੀ ਡਿਫਾਲਟ ਭਾਸ਼ਾ ਹੋਵੇਗੀ।';

  @override
  String get onboardingInviteTitle => 'ਆਪਣੇ ਮੁਨਸ਼ੀ ਨੂੰ ਸੱਦਾ ਦਿਓ';

  @override
  String get onboardingInviteHint =>
      'ਚੋਣਵਾਂ। ਉਹ ਗੇਟ ਤੇ ਆਮਦ ਅਤੇ ਭੁਗਤਾਨ ਦਰਜ ਕਰਨਗੇ।';

  @override
  String get onboardingInviteButton => 'ਕਿਸੇ ਨੂੰ ਸੱਦਾ ਦਿਓ';

  @override
  String get onboardingInviteLater =>
      'ਇੰਟਰਨੈੱਟ ਚਾਹੀਦਾ ਹੈ। ਬਾਅਦ ਵਿੱਚ ਟੀਮ ਤੋਂ ਵੀ ਸੱਦਾ ਦੇ ਸਕਦੇ ਹੋ।';

  @override
  String get onboardingDoneTitle => 'ਤੁਹਾਡਾ ਕਾਰੋਬਾਰ ਤਿਆਰ ਹੈ';

  @override
  String get onboardingDoneBody =>
      'ਹੁਣ ਆਪਣੀਆਂ ਪਾਰਟੀਆਂ ਉਨ੍ਹਾਂ ਦੇ ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ ਨਾਲ ਲਿਆਓ, ਜਾਂ ਇੱਕ-ਇੱਕ ਕਰਕੇ ਜੋੜੋ।';

  @override
  String get onboardingDoneImport => 'ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ ਇੰਪੋਰਟ ਕਰੋ';

  @override
  String get onboardingDoneAddParty => 'ਪਾਰਟੀ ਜੋੜੋ';

  @override
  String get onboardingDoneHome => 'ਡੈਸ਼ਬੋਰਡ ਤੇ ਜਾਓ';

  @override
  String get auditTable_opening_balance_imports => 'ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ ਇੰਪੋਰਟ';

  @override
  String get auditTable_tenants => 'ਕਾਰੋਬਾਰ ਦੀ ਜਾਣਕਾਰੀ';

  @override
  String get obTitle => 'ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ ਇੰਪੋਰਟ ਕਰੋ';

  @override
  String get obNoAccess =>
      'ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ ਸਿਰਫ਼ ਮਾਲਕ ਜਾਂ ਮੁਨੀਮ ਇੰਪੋਰਟ ਕਰ ਸਕਦੇ ਹਨ।';

  @override
  String get obSourceTitle => 'ਤੁਹਾਡੀ ਫ਼ਾਈਲ';

  @override
  String get obFormatHelp =>
      'ਹਰ ਪਾਰਟੀ ਦੀ ਇੱਕ ਕਤਾਰ। ਕਾਲਮ: ਨਾਮ, ਪਿੰਡ, ਮੋਬਾਈਲ, ਰਕਮ ਅਤੇ Dr/Cr (ਜਾਂ ਵੱਖਰੇ ਉਧਾਰ ਅਤੇ ਜਮ੍ਹਾ ਕਾਲਮ)। ਕੋਡ ਅਤੇ ਪਿਤਾ ਦਾ ਨਾਮ ਚੋਣਵੇਂ। CSV ਜਾਂ Excel (.xlsx)।';

  @override
  String get obChooseFile => 'CSV ਜਾਂ Excel ਫ਼ਾਈਲ ਚੁਣੋ';

  @override
  String get obPasteLabel => 'ਜਾਂ Excel ਤੋਂ ਪੇਸਟ ਕਰੋ';

  @override
  String get obPasteHint => 'ਨਾਮ, ਪਿੰਡ, ਰਕਮ, Dr/Cr';

  @override
  String get obReadPasted => 'ਪੇਸਟ ਕੀਤੀ ਸਾਰਣੀ ਪੜ੍ਹੋ';

  @override
  String get obReadOldExcel =>
      'ਪੁਰਾਣੀ .xls ਫ਼ਾਈਲ ਨਹੀਂ ਪੜ੍ਹੀ ਜਾ ਸਕਦੀ। ਇਸਨੂੰ .xlsx ਜਾਂ CSV ਵਿੱਚ ਸੇਵ ਕਰਕੇ ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get obReadUnreadable => 'ਇਹ ਫ਼ਾਈਲ ਪੜ੍ਹੀ ਨਹੀਂ ਜਾ ਸਕੀ।';

  @override
  String get obProblemEmpty => 'ਫ਼ਾਈਲ ਖਾਲੀ ਹੈ।';

  @override
  String get obProblemNoName =>
      'ਪਹਿਲੀ ਕਤਾਰ ਸਿਰਲੇਖ ਹੋਣੀ ਚਾਹੀਦੀ ਹੈ ਜਿਸ ਵਿੱਚ ਨਾਮ ਦਾ ਕਾਲਮ ਹੋਵੇ।';

  @override
  String get obProblemNoAmount =>
      'ਰਕਮ ਦਾ ਕਾਲਮ ਨਹੀਂ ਮਿਲਿਆ। ਰਕਮ (Dr/Cr ਨਾਲ), ਜਾਂ ਉਧਾਰ ਅਤੇ ਜਮ੍ਹਾ ਕਾਲਮ ਜੋੜੋ।';

  @override
  String obProblemTooMany(int max) {
    return 'ਬਹੁਤ ਜ਼ਿਆਦਾ ਕਤਾਰਾਂ। ਇੱਕ ਵਾਰ ਵਿੱਚ ਵੱਧ ਤੋਂ ਵੱਧ $max ਪਾਰਟੀਆਂ ਇੰਪੋਰਟ ਕਰੋ।';
  }

  @override
  String get obOptionsTitle => 'ਕਿਵੇਂ ਪੜ੍ਹਨਾ ਹੈ';

  @override
  String get obAsOn => 'ਬਾਕੀ ਇਸ ਤਾਰੀਖ ਤੱਕ';

  @override
  String get obDefaultSide =>
      'ਜੇ ਕਿਸੇ ਕਤਾਰ ਵਿੱਚ Dr/Cr ਨਾ ਹੋਵੇ, ਤਾਂ ਰਕਮ ਨੂੰ ਮੰਨੋ';

  @override
  String get obSideNone => 'ਚੁਣੀ ਨਹੀਂ';

  @override
  String get obSideUdhaar => 'ਉਧਾਰ (ਪਾਰਟੀ ਸਾਨੂੰ ਦੇਵੇਗੀ)';

  @override
  String get obSideJama => 'ਜਮ੍ਹਾ (ਸਾਨੂੰ ਪਾਰਟੀ ਨੂੰ ਦੇਣਾ ਹੈ)';

  @override
  String get obDefaultRole => 'ਨਵੀਆਂ ਪਾਰਟੀਆਂ ਇਸ ਰੂਪ ਵਿੱਚ ਜੁੜਣਗੀਆਂ';

  @override
  String get obSumRows => 'ਕਤਾਰਾਂ';

  @override
  String get obSumNewParties => 'ਨਵੀਆਂ ਪਾਰਟੀਆਂ';

  @override
  String get obSumMatched => 'ਮੌਜੂਦਾ ਪਾਰਟੀਆਂ';

  @override
  String get obSumProblems => 'ਸਮੱਸਿਆ ਵਾਲੀਆਂ ਕਤਾਰਾਂ';

  @override
  String get obSumNet => 'ਕੁੱਲ';

  @override
  String get obNetWeOwe => 'ਕੁੱਲ ਮਿਲਾ ਕੇ ਸਾਨੂੰ ਦੇਣਾ ਹੈ';

  @override
  String get obNetTheyOwe => 'ਕੁੱਲ ਮਿਲਾ ਕੇ ਸਾਨੂੰ ਮਿਲਣਾ ਹੈ';

  @override
  String obMatchedWith(String name) {
    return 'ਮੌਜੂਦਾ ਪਾਰਟੀ: $name';
  }

  @override
  String obNewParty(String role) {
    return 'ਨਵੀਂ ਪਾਰਟੀ ($role)';
  }

  @override
  String get obErrNameMissing => 'ਨਾਮ ਨਹੀਂ ਹੈ।';

  @override
  String get obErrAmountInvalid =>
      'ਰਕਮ ਸਹੀ ਨੰਬਰ ਨਹੀਂ ਹੈ (ਦਸ਼ਮਲਵ ਦੇ 2 ਅੰਕ ਤੱਕ)।';

  @override
  String get obErrAmountNegative => 'ਰਕਮ ਰਿਣਾਤਮਕ ਹੈ। ਮਾਇਨਸ ਦੀ ਥਾਂ Dr/Cr ਲਿਖੋ।';

  @override
  String get obErrSideMissing =>
      'ਸਾਫ਼ ਨਹੀਂ ਕਿ ਉਧਾਰ ਹੈ ਜਾਂ ਜਮ੍ਹਾ। Dr/Cr ਲਿਖੋ ਜਾਂ ਉੱਪਰ ਚੁਣੋ।';

  @override
  String get obErrSideUnknown => 'Dr/Cr ਦਾ ਮੁੱਲ ਸਮਝ ਨਹੀਂ ਆਇਆ।';

  @override
  String get obErrSideConflict => 'ਉਧਾਰ ਅਤੇ ਜਮ੍ਹਾ ਦੋਵਾਂ ਵਿੱਚ ਰਕਮ ਹੈ।';

  @override
  String get obErrMobileInvalid => 'ਮੋਬਾਈਲ ਨੰਬਰ ਸਹੀ ਨਹੀਂ ਹੈ।';

  @override
  String get obErrRoleUnknown => 'ਪਾਰਟੀ ਦੀ ਕਿਸਮ ਸਮਝ ਨਹੀਂ ਆਈ।';

  @override
  String obErrDuplicateInFile(String row) {
    return 'ਕਤਾਰ $row ਵਾਲੀ ਹੀ ਪਾਰਟੀ।';
  }

  @override
  String obErrPossibleDuplicate(String code) {
    return 'ਇਸ ਨਾਮ ਦੀ ਪਾਰਟੀ ਪਹਿਲਾਂ ਤੋਂ ਹੈ (ਕੋਡ $code)। ਕਤਾਰ ਵਿੱਚ ਉਸਦਾ ਕੋਡ, ਪਿੰਡ ਜਾਂ ਮੋਬਾਈਲ ਜੋੜੋ।';
  }

  @override
  String obErrCodeTaken(String code) {
    return 'ਕੋਡ $code ਕਿਸੇ ਹੋਰ ਪਾਰਟੀ ਦਾ ਹੈ।';
  }

  @override
  String get obErrAlreadyHasOpening =>
      'ਇਸ ਪਾਰਟੀ ਦਾ ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ ਪਹਿਲਾਂ ਤੋਂ ਦਰਜ ਹੈ।';

  @override
  String get obWarnNoAmount => 'ਰਕਮ ਨਹੀਂ: ਪਾਰਟੀ ਬਿਨਾਂ ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ ਦੇ ਜੁੜੇਗੀ।';

  @override
  String get obWarnNameDiffers =>
      'ਕੋਡ ਨਾਲ ਮਿਲੀ, ਪਰ ਨਾਮ ਸੇਵ ਕੀਤੀ ਪਾਰਟੀ ਤੋਂ ਵੱਖਰਾ ਹੈ।';

  @override
  String get obWarnMobileOfOther =>
      'ਇਹ ਮੋਬਾਈਲ ਨੰਬਰ ਕਿਸੇ ਹੋਰ ਪਾਰਟੀ ਕੋਲ ਪਹਿਲਾਂ ਤੋਂ ਹੈ।';

  @override
  String get obProblemsOnly => 'ਸਿਰਫ਼ ਸਮੱਸਿਆਵਾਂ';

  @override
  String obImportButton(int count) {
    return '$count ਬਾਕੀ ਇੰਪੋਰਟ ਕਰੋ';
  }

  @override
  String obImportValidButton(int count, int skipped) {
    return '$count ਬਾਕੀ ਇੰਪੋਰਟ ਕਰੋ, $skipped ਸਮੱਸਿਆ ਵਾਲੀਆਂ ਕਤਾਰਾਂ ਛੱਡੋ';
  }

  @override
  String get obConfirmTitle => 'ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ ਇੰਪੋਰਟ ਕਰਨਾ ਹੈ?';

  @override
  String obConfirmBody(
    int entries,
    int parties,
    String udhaar,
    String jama,
    String date,
  ) {
    return '$date ਤੱਕ $entries ਬਾਕੀ ਅਤੇ $parties ਨਵੀਆਂ ਪਾਰਟੀਆਂ। ਉਧਾਰ $udhaar, ਜਮ੍ਹਾ $jama। ਐਂਟਰੀ ਬਾਅਦ ਵਿੱਚ ਬਦਲੀ ਨਹੀਂ ਜਾ ਸਕਦੀ, ਸਿਰਫ਼ ਉਲਟਾਈ ਜਾ ਸਕਦੀ ਹੈ।';
  }

  @override
  String get obImportNow => 'ਇੰਪੋਰਟ ਕਰੋ';

  @override
  String get obResAlready =>
      'ਇਹੀ ਫ਼ਾਈਲ ਇਸ ਤਾਰੀਖ ਲਈ ਪਹਿਲਾਂ ਹੀ ਇੰਪੋਰਟ ਹੋ ਚੁੱਕੀ ਹੈ।';

  @override
  String get obResNothing =>
      'ਇੰਪੋਰਟ ਕਰਨ ਨੂੰ ਕੁਝ ਨਹੀਂ: ਸਭ ਕੁਝ ਪਹਿਲਾਂ ਤੋਂ ਵਹੀ ਵਿੱਚ ਹੈ।';

  @override
  String get obResNotPermitted =>
      'ਤੁਹਾਨੂੰ ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ ਇੰਪੋਰਟ ਕਰਨ ਦੀ ਇਜਾਜ਼ਤ ਨਹੀਂ ਹੈ।';

  @override
  String get obResBadDate => 'ਤਾਰੀਖ ਅੱਗੇ ਦੀ ਨਹੀਂ ਹੋ ਸਕਦੀ।';

  @override
  String obResStale(int row) {
    return 'ਕਤਾਰ $row ਪ੍ਰੀਵਿਊ ਤੋਂ ਬਾਅਦ ਬਦਲ ਗਈ (ਦੂਜਾ ਡਿਵਾਈਸ?)। ਕੁਝ ਇੰਪੋਰਟ ਨਹੀਂ ਹੋਇਆ; ਪ੍ਰੀਵਿਊ ਨਵਾਂ ਕਰ ਦਿੱਤਾ ਗਿਆ।';
  }

  @override
  String get obDoneTitle => 'ਸ਼ੁਰੂਆਤੀ ਬਾਕੀ ਇੰਪੋਰਟ ਹੋ ਗਿਆ';

  @override
  String obDoneBody(int entries, int parties, String udhaar, String jama) {
    return '$entries ਬਾਕੀ ਦਰਜ ਹੋਏ, $parties ਪਾਰਟੀਆਂ ਜੁੜੀਆਂ। ਉਧਾਰ $udhaar, ਜਮ੍ਹਾ $jama।';
  }

  @override
  String get obDoneParties => 'ਪਾਰਟੀਆਂ ਵੇਖੋ';

  @override
  String get onboardingCropsEmpty =>
      'ਇਸ ਡਿਵਾਈਸ ਤੇ ਹਾਲੇ ਕੋਈ ਫ਼ਸਲ ਨਹੀਂ ਆਈ। ਉਹ ਸਰਵਰ ਤੋਂ ਸਿੰਕ ਹੁੰਦੀਆਂ ਹਨ; ਬਾਅਦ ਵਿੱਚ ਫ਼ਸਲਾਂ ਵਿੱਚ ਚੁਣ ਸਕਦੇ ਹੋ।';

  @override
  String get onboardingInterestRatePerMonthLabel =>
      'ਵਿਆਜ ਦਰ (₹ ਪ੍ਰਤੀ 100 ਪ੍ਰਤੀ ਮਹੀਨਾ)';

  @override
  String updateAvailableTitle(String version) {
    return 'ਮੰਡੀ ਖਾਤਾ $version ਉਪਲਬਧ ਹੈ';
  }

  @override
  String updateRequiredTitle(String version) {
    return 'ਕਿਰਪਾ ਕਰਕੇ ਮੰਡੀ ਖਾਤਾ $version ਵਿੱਚ ਅੱਪਡੇਟ ਕਰੋ। ਇਹ ਸੰਸਕਰਣ ਹੁਣ ਸਮਰਥਿਤ ਨਹੀਂ ਹੈ।';
  }

  @override
  String get updateDownload => 'ਡਾਊਨਲੋਡ';

  @override
  String get updateLater => 'ਬਾਅਦ ਵਿੱਚ';

  @override
  String get loansTitle => 'ਕਰਜ਼ਾ (ਲੋਨ)';

  @override
  String get loansIssue => 'ਕਰਜ਼ਾ ਦਿਓ';

  @override
  String get loansEmpty => 'ਅਜੇ ਕੋਈ ਕਰਜ਼ਾ ਨਹੀਂ';

  @override
  String get loansSearchHint => 'ਕਰਜ਼ਦਾਰ ਜਾਂ ਕਰਜ਼ਾ ਨੰਬਰ ਲੱਭੋ';

  @override
  String get loansFilterOpen => 'ਚਾਲੂ';

  @override
  String get loansFilterClosed => 'ਬੰਦ';

  @override
  String get loansFilterAll => 'ਸਾਰੇ';

  @override
  String get loansTotalCount => 'ਚਾਲੂ ਕਰਜ਼ੇ';

  @override
  String get loansTotalPrincipal => 'ਬਕਾਇਆ ਮੂਲ';

  @override
  String get loansTotalInterest => 'ਬਕਾਇਆ ਵਿਆਜ';

  @override
  String get loansTotalOverdue => 'ਮਿਆਦ ਲੰਘੇ';

  @override
  String loanCardIssued(String amount) {
    return '$amount ਦਿੱਤਾ';
  }

  @override
  String get loanCardOutstanding => 'ਮੂਲ';

  @override
  String get loanCardByaj => 'ਵਿਆਜ';

  @override
  String get loanCardPayable => 'ਕੁੱਲ ਦੇਣਯੋਗ';

  @override
  String loanCardRecovered(String percent) {
    return '$percent% ਵਸੂਲ';
  }

  @override
  String loanCardDaysLeft(String count) {
    return '$count ਦਿਨ ਬਾਕੀ';
  }

  @override
  String get loanCardDueToday => 'ਅੱਜ ਦੇਣਯੋਗ';

  @override
  String loanCardOverdue(String count) {
    return '$count ਦਿਨ ਦੇਰ';
  }

  @override
  String get loanCardNoDue => 'ਕੋਈ ਮਿਤੀ ਨਹੀਂ';

  @override
  String loanCardDue(String date) {
    return 'ਮਿਆਦ $date';
  }

  @override
  String get loanHealthOnTrack => 'ਠੀਕ ਚੱਲ ਰਿਹਾ';

  @override
  String get loanHealthDueSoon => 'ਜਲਦੀ ਦੇਣਯੋਗ';

  @override
  String get loanHealthOverdue => 'ਮਿਆਦ ਲੰਘੀ';

  @override
  String get loanHealthSettled => 'ਚੁਕਤਾ';

  @override
  String get loanStatusClosed => 'ਬੰਦ';

  @override
  String get loanStatusWrittenOff => 'ਵੱਟੇ ਖਾਤੇ';

  @override
  String get loanIssueTitle => 'ਕਰਜ਼ਾ ਦਿਓ';

  @override
  String get loanFieldBorrower => 'ਕਰਜ਼ਦਾਰ';

  @override
  String get loanFieldAmount => 'ਕਰਜ਼ੇ ਦੀ ਰਕਮ';

  @override
  String get loanFieldIssueDate => 'ਦੇਣ ਦੀ ਮਿਤੀ';

  @override
  String get loanFieldDueDate => 'ਮਿਆਦ ਦੀ ਮਿਤੀ (ਮਰਜ਼ੀ ਅਨੁਸਾਰ)';

  @override
  String get loanFieldPurpose => 'ਮਕਸਦ';

  @override
  String get loanFieldGuarantor => 'ਗਾਰੰਟਰ (ਮਰਜ਼ੀ ਅਨੁਸਾਰ)';

  @override
  String get loanFieldNotes => 'ਨੋਟ';

  @override
  String get loanClearDate => 'ਮਿਤੀ ਹਟਾਓ';

  @override
  String get loanTermsTitle => 'ਵਿਆਜ ਦੀਆਂ ਸ਼ਰਤਾਂ';

  @override
  String loanTermsFrom(String source) {
    return '$source। ਇੱਥੋਂ ਦੀਆਂ ਤਬਦੀਲੀਆਂ ਸਿਰਫ਼ ਇਸ ਕਰਜ਼ੇ ਉੱਤੇ ਲਾਗੂ ਹੋਣਗੀਆਂ।';
  }

  @override
  String get loanFieldRate => 'ਵਿਆਜ ਦਰ';

  @override
  String get loanTermsMore => 'ਹੋਰ ਸ਼ਰਤਾਂ';

  @override
  String get loanPayOutTitle => 'ਪੈਸੇ ਕਿਵੇਂ ਦਿੱਤੇ ਜਾ ਰਹੇ ਹਨ?';

  @override
  String loanNextNo(String no) {
    return 'ਕਰਜ਼ਾ ਨੰਬਰ $no';
  }

  @override
  String get loanNoticeNetUdhaar =>
      'ਤੁਹਾਡਾ ਕਾਰੋਬਾਰ ਪੂਰੇ ਖਾਤੇ ਉੱਤੇ ਵਿਆਜ ਲਾਉਂਦਾ ਹੈ। ਇਹ ਕਰਜ਼ਾ ਆਪਣਾ ਵੱਖਰਾ ਵਿਆਜ ਖਾਤਾ ਰੱਖਦਾ ਹੈ, ਇਸ ਲਈ ਇਸੇ ਰਕਮ ਉੱਤੇ ਖਾਤੇ ਵਿੱਚ ਦੁਬਾਰਾ ਵਿਆਜ ਨਾ ਲਾਓ।';

  @override
  String get loanSaveIssue => 'ਕਰਜ਼ਾ ਦਿਓ';

  @override
  String loanIssuedAs(String no) {
    return 'ਕਰਜ਼ਾ $no ਦਿੱਤਾ ਗਿਆ';
  }

  @override
  String get loanDetailAsOf => 'ਇਸ ਮਿਤੀ ਤੱਕ';

  @override
  String get loanDetailToday => 'ਅੱਜ';

  @override
  String loanPayableOn(String date) {
    return '$date ਨੂੰ ਦੇਣਯੋਗ';
  }

  @override
  String get loanPrincipalOutstanding => 'ਬਕਾਇਆ ਮੂਲ';

  @override
  String get loanInterestAccrued => 'ਜਮ੍ਹਾਂ ਵਿਆਜ';

  @override
  String get loanInterestRecovered => 'ਵਸੂਲ ਵਿਆਜ';

  @override
  String get loanPrincipalRecovered => 'ਵਸੂਲ ਮੂਲ';

  @override
  String get loanCurrentRate => 'ਦਰ';

  @override
  String loanRatePa(String rate) {
    return '$rate% ਸਾਲਾਨਾ';
  }

  @override
  String loanRatePerMonth(String rate) {
    return '₹$rate ਪ੍ਰਤੀ 100 ਪ੍ਰਤੀ ਮਹੀਨਾ';
  }

  @override
  String get loanTermsSummary => 'ਸ਼ਰਤਾਂ';

  @override
  String get loanInterestFree => 'ਵਿਆਜ ਨਹੀਂ';

  @override
  String loanGraceDays(String count) {
    return '$count ਦਿਨ ਦੀ ਛੋਟ';
  }

  @override
  String get loanActionRepay => 'ਵਾਪਸੀ ਦਰਜ ਕਰੋ';

  @override
  String get loanActionRate => 'ਦਰ ਬਦਲੋ';

  @override
  String get loanActionClose => 'ਕਰਜ਼ਾ ਬੰਦ ਕਰੋ';

  @override
  String get loanActionWriteOff => 'ਵੱਟੇ ਖਾਤੇ ਪਾਓ';

  @override
  String get loanBorrowerLink => 'ਖਾਤਾ ਖੋਲ੍ਹੋ';

  @override
  String get loanNotFound => 'ਕਰਜ਼ਾ ਨਹੀਂ ਮਿਲਿਆ';

  @override
  String loanClosedOn(String status, String date) {
    return '$date ਨੂੰ $status';
  }

  @override
  String get loanStmtTitle => 'ਵਿਆਜ ਦਾ ਹਿਸਾਬ';

  @override
  String get loanStmtEmpty => 'ਅਜੇ ਕੋਈ ਐਂਟਰੀ ਨਹੀਂ';

  @override
  String get loanColFrom => 'ਤੋਂ';

  @override
  String get loanColTo => 'ਤੱਕ';

  @override
  String get loanColEvent => 'ਵੇਰਵਾ';

  @override
  String get loanColDebit => 'ਦਿੱਤਾ';

  @override
  String get loanColCredit => 'ਮਿਲਿਆ';

  @override
  String get loanColDays => 'ਦਿਨ';

  @override
  String get loanColPrincipal => 'ਮੂਲ';

  @override
  String get loanColRate => 'ਦਰ %';

  @override
  String get loanColInterest => 'ਵਿਆਜ';

  @override
  String get loanRowAccrue => 'ਇਨ੍ਹਾਂ ਦਿਨਾਂ ਦਾ ਵਿਆਜ';

  @override
  String get loanRowDebit => 'ਕਰਜ਼ਾ ਦਿੱਤਾ';

  @override
  String get loanRowCredit => 'ਵਾਪਸੀ';

  @override
  String get loanRowCompound => 'ਵਿਆਜ ਮੂਲ ਵਿੱਚ ਜੋੜਿਆ';

  @override
  String loanRowRate(String rate) {
    return 'ਦਰ ਬਦਲ ਕੇ $rate% ਹੋਈ';
  }

  @override
  String loanRowSplit(String interest, String principal) {
    return 'ਵਿਆਜ $interest · ਮੂਲ $principal';
  }

  @override
  String loanRowSurplus(String amount) {
    return 'ਵਾਧੂ $amount ਜਮ੍ਹਾਂ ਰੱਖਿਆ';
  }

  @override
  String get loanRateChangesTitle => 'ਦਰ ਵਿੱਚ ਤਬਦੀਲੀਆਂ';

  @override
  String get loanRateAtIssue => 'ਦੇਣ ਵੇਲੇ';

  @override
  String get loanRepayTitle => 'ਵਾਪਸੀ ਦਰਜ ਕਰੋ';

  @override
  String get loanRepayAmount => 'ਮਿਲੀ ਰਕਮ';

  @override
  String get loanRepayDate => 'ਮਿਤੀ';

  @override
  String get loanRepaySourcePay => 'ਪੈਸੇ ਮਿਲੇ';

  @override
  String get loanRepaySourceCrop => 'ਫ਼ਸਲ ਦੀ ਰਕਮ ਵਿੱਚੋਂ';

  @override
  String loanRepayCropAvailable(String amount) {
    return 'ਖਾਤੇ ਵਿੱਚ ਫ਼ਸਲ ਦੀ ਰਕਮ: $amount';
  }

  @override
  String get loanRepayCropNone =>
      'ਇਸ ਪਾਰਟੀ ਦੇ ਖਾਤੇ ਵਿੱਚ ਸਮਾਯੋਜਨ ਲਈ ਫ਼ਸਲ ਦੀ ਕੋਈ ਰਕਮ ਨਹੀਂ ਹੈ।';

  @override
  String get loanRepayFullPayable => 'ਪੂਰਾ ਦੇਣਯੋਗ';

  @override
  String get loanPreviewTitle => 'ਇਹ ਵਾਪਸੀ';

  @override
  String get loanPreviewInterest => 'ਵਿਆਜ ਚੁਕਾਏਗੀ';

  @override
  String get loanPreviewPrincipal => 'ਮੂਲ ਚੁਕਾਏਗੀ';

  @override
  String get loanPreviewBefore => 'ਪਹਿਲਾਂ ਦੇਣਯੋਗ';

  @override
  String get loanPreviewAfter => 'ਬਾਅਦ ਵਿੱਚ ਦੇਣਯੋਗ';

  @override
  String get loanPreviewCropNote =>
      'ਪਾਰਟੀ ਦਾ ਖਾਤੇ ਦਾ ਸ਼ੁੱਧ ਬਕਾਇਆ ਨਹੀਂ ਬਦਲੇਗਾ; ਕਰਜ਼ਾ ਉਨ੍ਹਾਂ ਦੀ ਫ਼ਸਲ ਦੀ ਰਕਮ ਨਾਲ ਚੁਕਤਾ ਹੋਵੇਗਾ।';

  @override
  String get loanRepaySave => 'ਵਾਪਸੀ ਦਰਜ ਕਰੋ';

  @override
  String get loanRepaid => 'ਵਾਪਸੀ ਦਰਜ ਹੋਈ';

  @override
  String get loanRateTitle => 'ਵਿਆਜ ਦਰ ਬਦਲੋ';

  @override
  String loanRateCurrent(String rate) {
    return 'ਮੌਜੂਦਾ ਦਰ: $rate';
  }

  @override
  String get loanRateNew => 'ਨਵੀਂ ਦਰ';

  @override
  String get loanRateEffective => 'ਇਸ ਮਿਤੀ ਤੋਂ ਲਾਗੂ';

  @override
  String get loanRateReason => 'ਕਾਰਨ (ਮਰਜ਼ੀ ਅਨੁਸਾਰ)';

  @override
  String get loanRateSave => 'ਦਰ ਬਦਲੋ';

  @override
  String get loanRateChanged => 'ਦਰ ਬਦਲੀ ਗਈ';

  @override
  String get loanCloseTitle => 'ਕਰਜ਼ਾ ਬੰਦ ਕਰੋ';

  @override
  String get loanWriteOffTitle => 'ਕਰਜ਼ਾ ਵੱਟੇ ਖਾਤੇ ਪਾਓ';

  @override
  String get loanCloseDate => 'ਬੰਦ ਕਰਨ ਦੀ ਮਿਤੀ';

  @override
  String get loanCloseReason => 'ਕਾਰਨ';

  @override
  String get loanCloseReasonOptional => 'ਨੋਟ (ਮਰਜ਼ੀ ਅਨੁਸਾਰ)';

  @override
  String loanCloseStillDue(String amount) {
    return '$amount ਅਜੇ ਦੇਣਯੋਗ ਹੈ। ਪਹਿਲਾਂ ਵਾਪਸੀ ਦਰਜ ਕਰੋ, ਜਾਂ ਕਰਜ਼ਾ ਵੱਟੇ ਖਾਤੇ ਪਾਓ।';
  }

  @override
  String get loanCloseAllPaid =>
      'ਕੁਝ ਦੇਣਯੋਗ ਨਹੀਂ ਹੈ। ਬੰਦ ਕਰਨ ਨਾਲ ਦਰਜ ਹੋਵੇਗਾ ਕਿ ਕਰਜ਼ਾ ਪੂਰਾ ਚੁਕਤਾ ਹੈ।';

  @override
  String loanWriteOffBody(String amount) {
    return '$amount ਵੱਟੇ ਖਾਤੇ ਜਾਵੇਗਾ ਅਤੇ ਵਿਆਜ ਰੁਕ ਜਾਵੇਗਾ। ਜਦੋਂ ਤੱਕ ਤੁਸੀਂ ਮਾਫ਼ ਨਹੀਂ ਕਰਦੇ, ਪਾਰਟੀ ਦੇ ਖਾਤੇ ਵਿੱਚ ਬਕਾਇਆ ਦਿਸਦਾ ਰਹੇਗਾ। ਇਹ ਵਾਪਸ ਨਹੀਂ ਹੋ ਸਕਦਾ।';
  }

  @override
  String get loanCloseConfirm => 'ਕਰਜ਼ਾ ਬੰਦ ਕਰੋ';

  @override
  String get loanWriteOffConfirm => 'ਵੱਟੇ ਖਾਤੇ ਪਾਓ';

  @override
  String get loanClosedDone => 'ਕਰਜ਼ਾ ਬੰਦ ਹੋਇਆ';

  @override
  String get loanWrittenOffDone => 'ਕਰਜ਼ਾ ਵੱਟੇ ਖਾਤੇ ਪਾਇਆ ਗਿਆ';

  @override
  String get loanErrorAmount => 'ਰਕਮ ਭਰੋ';

  @override
  String get loanErrorDue => 'ਮਿਆਦ ਦੀ ਮਿਤੀ ਦੇਣ ਦੀ ਮਿਤੀ ਤੋਂ ਪਹਿਲਾਂ ਨਹੀਂ ਹੋ ਸਕਦੀ';

  @override
  String get loanErrorGuarantor => 'ਕਰਜ਼ਦਾਰ ਆਪਣਾ ਗਾਰੰਟਰ ਨਹੀਂ ਹੋ ਸਕਦਾ';

  @override
  String get loanErrorRate => '0 ਤੋਂ 100 ਵਿਚਕਾਰ ਦਰ ਭਰੋ (4 ਦਸ਼ਮਲਵ ਤੱਕ)';

  @override
  String get loanErrorEffective =>
      'ਦਰ ਕਰਜ਼ਾ ਦੇਣ ਤੋਂ ਪਹਿਲਾਂ ਦੀ ਮਿਤੀ ਤੋਂ ਸ਼ੁਰੂ ਨਹੀਂ ਹੋ ਸਕਦੀ';

  @override
  String get loanErrorNotActive => 'ਇਹ ਕਰਜ਼ਾ ਪਹਿਲਾਂ ਹੀ ਬੰਦ ਹੈ';

  @override
  String get loanErrorStillDue => 'ਇਸ ਕਰਜ਼ੇ ਉੱਤੇ ਅਜੇ ਕੁਝ ਦੇਣਯੋਗ ਹੈ';

  @override
  String get loanErrorInterestNotPosted =>
      'ਪਹਿਲਾਂ ਇਸ ਕਰਜ਼ੇ ਦਾ ਵਿਆਜ ਖਾਤੇ ਵਿੱਚ ਚਾੜ੍ਹੋ; ਬੰਦ ਕਰਜ਼ੇ ਉੱਤੇ ਵਿਆਜ ਨਹੀਂ ਚੜ੍ਹ ਸਕਦਾ';

  @override
  String get loanErrorNothingToWriteOff =>
      'ਵੱਟੇ ਖਾਤੇ ਪਾਉਣ ਲਈ ਕੁਝ ਨਹੀਂ ਬਚਿਆ; ਕਰਜ਼ਾ ਬੰਦ ਕਰੋ';

  @override
  String get loanErrorReason => 'ਕਾਰਨ ਦੱਸੋ';

  @override
  String get loanErrorClosedBefore =>
      'ਮਿਤੀ ਇਸ ਕਰਜ਼ੇ ਦੀ ਆਖ਼ਰੀ ਐਂਟਰੀ ਤੋਂ ਪਹਿਲਾਂ ਦੀ ਨਹੀਂ ਹੋ ਸਕਦੀ';

  @override
  String get loanErrorNotPermitted => 'ਇਹ ਸਿਰਫ਼ ਮਾਲਕ ਕਰ ਸਕਦਾ ਹੈ';

  @override
  String get loanErrorNotPermittedRepay =>
      'ਭੁਗਤਾਨ ਦਰਜ ਕਰਨ ਦੀ ਇਜਾਜ਼ਤ ਚਾਹੀਦੀ ਹੈ (ਫ਼ਸਲ ਦੀ ਰਕਮ ਸਮਾਯੋਜਿਤ ਕਰਨ ਲਈ ਮੁਨੀਮ ਜਾਂ ਮਾਲਕ)';

  @override
  String get loanErrorNotFound =>
      'ਪਾਰਟੀ, ਕਰਜ਼ਾ ਜਾਂ ਬੈਂਕ ਖਾਤਾ ਇਸ ਕਾਰੋਬਾਰ ਵਿੱਚ ਨਹੀਂ ਮਿਲਿਆ';

  @override
  String loanErrorExceeds(String payable) {
    return 'ਇਸ ਦਿਨ ਦੇਣਯੋਗ $payable ਤੋਂ ਵੱਧ। ਸਿਰਫ਼ ਦੇਣਯੋਗ ਰਕਮ ਦਰਜ ਕਰੋ।';
  }

  @override
  String loanErrorExceedsCrop(String available) {
    return 'ਖਾਤੇ ਵਿੱਚ ਫ਼ਸਲ ਦੀ ਰਕਮ ($available) ਤੋਂ ਵੱਧ';
  }

  @override
  String get paymentLoanNote =>
      'ਇਹ ਭੁਗਤਾਨ ਇੱਕ ਕਰਜ਼ੇ ਨਾਲ ਜੁੜਿਆ ਹੈ। ਕਰਜ਼ਾ ਚਾਲੂ ਰਹਿਣ ਤੱਕ ਵਾਪਸੀ ਇੱਥੋਂ ਉਲਟਾਈ ਜਾ ਸਕਦੀ ਹੈ; ਕਰਜ਼ੇ ਵਿੱਚ ਦਿੱਤਾ ਪੈਸਾ ਉਲਟਾਇਆ ਨਹੀਂ ਜਾ ਸਕਦਾ।';

  @override
  String get paymentLoanLink => 'ਕਰਜ਼ਾ ਖੋਲ੍ਹੋ';

  @override
  String get loanOpenFromParty => 'ਕਰਜ਼ੇ';

  @override
  String get partyTabByaj => 'ਵਿਆਜ';

  @override
  String get byajNoInterest => 'ਇਸ ਪਾਰਟੀ ਉੱਤੇ ਵਿਆਜ ਨਹੀਂ ਲੱਗਦਾ।';

  @override
  String get byajLoansOnly =>
      'ਇਸ ਪਾਰਟੀ ਉੱਤੇ ਵਿਆਜ ਸਿਰਫ਼ ਵੱਖ-ਵੱਖ ਕਰਜ਼ਿਆਂ ਉੱਤੇ ਚੱਲਦਾ ਹੈ। ਕਰਜ਼ਾ ਟੈਬ ਵੇਖੋ।';

  @override
  String get byajKhataNote =>
      'ਵਿਆਜ ਪੂਰੇ ਖਾਤੇ ਉੱਤੇ ਚੱਲਦਾ ਹੈ, ਕਰਜ਼ਾ ਸਮੇਤ। ਇਸ ਪਾਰਟੀ ਦਾ ਕਰਜ਼ਾ ਦੂਜੀ ਵਾਰ ਵਿਆਜ ਨਹੀਂ ਲਾਉਂਦਾ।';

  @override
  String get byajLoanCoveredNote =>
      'ਇਸ ਕਰਜ਼ੇ ਦਾ ਵਿਆਜ ਇਸ ਦੀਆਂ ਆਪਣੀਆਂ ਸ਼ਰਤਾਂ ਉੱਤੇ ਚੱਲਦਾ ਹੈ। ਪਾਰਟੀ ਦੇ ਖਾਤੇ ਦੇ ਵਿਆਜ ਵਿੱਚ ਇਹ ਸ਼ਾਮਲ ਨਹੀਂ ਹੈ, ਅਤੇ ਡਿਫਾਲਟ ਦਰ ਬਦਲਣ ਨਾਲ ਇਹ ਨਹੀਂ ਬਦਲਦਾ।';

  @override
  String get byajTermsTitle => 'ਵਿਆਜ ਦੀਆਂ ਸ਼ਰਤਾਂ';

  @override
  String get byajEditTerms => 'ਸ਼ਰਤਾਂ ਬਦਲੋ';

  @override
  String byajSourced(String value, String source) {
    return '$value · $source';
  }

  @override
  String get byajCreditBalance => 'ਪਾਰਟੀ ਦੀ ਜਮ੍ਹਾ ਰਕਮ ਜੋ ਸਾਡੇ ਕੋਲ ਹੈ';

  @override
  String get byajRowDebit => 'ਉਧਾਰ ਦੀ ਐਂਟਰੀ';

  @override
  String get byajRowCredit => 'ਜਮ੍ਹਾ ਦੀ ਐਂਟਰੀ';

  @override
  String get byajNoEntries => 'ਖਾਤੇ ਵਿੱਚ ਹਾਲੇ ਕੋਈ ਐਂਟਰੀ ਨਹੀਂ';

  @override
  String byajDialogTitle(String name) {
    return 'ਵਿਆਜ ਦੀਆਂ ਸ਼ਰਤਾਂ · $name';
  }

  @override
  String get byajDialogHint =>
      'ਸਿਰਫ਼ ਤੁਹਾਡੇ ਬਦਲੇ ਹਿੱਸੇ ਇਸ ਪਾਰਟੀ ਲਈ ਰਹਿੰਦੇ ਹਨ। ਬਾਕੀ ਕਾਰੋਬਾਰ ਦੀਆਂ ਤੈਅ ਸ਼ਰਤਾਂ ਅਨੁਸਾਰ ਚੱਲਦਾ ਹੈ।';

  @override
  String get byajUseDefaults => 'ਕਾਰੋਬਾਰ ਦੀਆਂ ਤੈਅ ਸ਼ਰਤਾਂ ਲਾਓ';

  @override
  String get byajSave => 'ਸ਼ਰਤਾਂ ਸੰਭਾਲੋ';

  @override
  String get byajSaved => 'ਵਿਆਜ ਦੀਆਂ ਸ਼ਰਤਾਂ ਸੰਭਾਲ ਲਈਆਂ ਗਈਆਂ';

  @override
  String get byajNoPermission =>
      'ਵਿਆਜ ਦੀਆਂ ਸ਼ਰਤਾਂ ਬਦਲਣ ਲਈ ਕਰਜ਼ੇ ਦੀ ਇਜਾਜ਼ਤ (ਮਾਲਕ) ਚਾਹੀਦੀ ਹੈ।';

  @override
  String get byajBulkOpen => 'ਕਈ ਪਾਰਟੀਆਂ ਦਾ ਵਿਆਜ ਇਕੱਠਾ ਤੈਅ ਕਰੋ';

  @override
  String get byajBulkTitle => 'ਕਈ ਪਾਰਟੀਆਂ ਦਾ ਵਿਆਜ ਤੈਅ ਕਰੋ';

  @override
  String get byajBulkIntro =>
      'ਪਾਰਟੀਆਂ ਚੁਣੋ (ਜਿਵੇਂ ਇੱਕ ਪਿੰਡ), ਸ਼ਰਤਾਂ ਤੈਅ ਕਰੋ ਅਤੇ ਲਾਗੂ ਕਰੋ। ਹਰ ਪਾਰਟੀ ਦੀਆਂ ਆਪਣੀਆਂ ਸ਼ਰਤਾਂ ਬਣਨਗੀਆਂ, ਜੋ ਕਾਰੋਬਾਰ ਦੀਆਂ ਤੈਅ ਸ਼ਰਤਾਂ ਤੋਂ ਉੱਪਰ ਚੱਲਣਗੀਆਂ।';

  @override
  String get byajBulkVillage => 'ਪਿੰਡ';

  @override
  String get byajBulkAllVillages => 'ਸਾਰੇ ਪਿੰਡ';

  @override
  String get byajBulkSelectAll => 'ਵਿਖਾਈਆਂ ਸਾਰੀਆਂ ਚੁਣੋ';

  @override
  String get byajBulkNone => 'ਕੋਈ ਪਾਰਟੀ ਨਹੀਂ ਮਿਲੀ';

  @override
  String byajBulkApply(int count) {
    return '$count ਪਾਰਟੀਆਂ ਉੱਤੇ ਲਾਗੂ ਕਰੋ';
  }

  @override
  String byajBulkDone(int count) {
    return '$count ਪਾਰਟੀਆਂ ਲਈ ਵਿਆਜ ਦੀਆਂ ਸ਼ਰਤਾਂ ਤੈਅ ਹੋਈਆਂ';
  }

  @override
  String get byajBulkFailed =>
      'ਕੁਝ ਪਾਰਟੀਆਂ ਸੰਭਾਲੀਆਂ ਨਹੀਂ ਜਾ ਸਕੀਆਂ। ਇਜਾਜ਼ਤ ਜਾਂਚ ਕੇ ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get postInterestTitle => 'ਵਿਆਜ ਚੜ੍ਹਾਓ';

  @override
  String get postInterestIntro =>
      'ਹੁਣ ਤੱਕ ਦਾ ਵਿਆਜ ਖਾਤੇ ਵਿੱਚ ਇੱਕ ਉਧਾਰ ਐਂਟਰੀ ਵਜੋਂ ਜੁੜੇਗਾ। ਪੱਕਾ ਕਰਨ ਤੱਕ ਕੁਝ ਨਹੀਂ ਚੜ੍ਹਦਾ।';

  @override
  String get postInterestNone => 'ਅੱਜ ਲਈ ਚੜ੍ਹਾਉਣ ਵਾਲਾ ਵਿਆਜ ਨਹੀਂ ਹੈ।';

  @override
  String postInterestConfirm(String amount) {
    return '$amount ਚੜ੍ਹਾਓ';
  }

  @override
  String postInterestDone(String amount) {
    return 'ਵਿਆਜ ਚੜ੍ਹਿਆ: $amount';
  }

  @override
  String get postInterestAmount => 'ਚੜ੍ਹਾਉਣ ਵਾਲਾ ਵਿਆਜ';

  @override
  String get postColParty => 'ਪਾਰਟੀ';

  @override
  String get postColAccount => 'ਖਾਤਾ';

  @override
  String get postColPeriod => 'ਮਿਆਦ';

  @override
  String get postColTerms => 'ਸ਼ਰਤਾਂ';

  @override
  String get postAccountKhata => 'ਪੂਰਾ ਖਾਤਾ';

  @override
  String postAccountLoan(String no) {
    return 'ਕਰਜ਼ਾ $no';
  }

  @override
  String postPeriod(String from, String to) {
    return '$from ਤੋਂ $to ਤੱਕ';
  }

  @override
  String postTerms(String rate, String method) {
    return '$rate% ਸਾਲਾਨਾ, $method';
  }

  @override
  String get postSkipAlready => 'ਇਸ ਦਿਨ ਤੱਕ ਪਹਿਲਾਂ ਹੀ ਚੜ੍ਹ ਚੁੱਕਾ ਹੈ';

  @override
  String get postSkipNotFound => 'ਪਾਰਟੀ ਜਾਂ ਕਰਜ਼ਾ ਨਹੀਂ ਮਿਲਿਆ';

  @override
  String get postSkipBackdated =>
      'ਇਹ ਤਾਰੀਖ਼ ਤੁਹਾਡੀ ਭੂਮਿਕਾ ਲਈ ਬਹੁਤ ਪੁਰਾਣੀ ਹੈ। ਮਾਲਕ ਨੂੰ ਕਹੋ।';

  @override
  String get postSkipChanged =>
      'ਤੁਹਾਡੇ ਵੇਖਣ ਤੋਂ ਬਾਅਦ ਅੰਕੜੇ ਬਦਲ ਗਏ ਹਨ। ਖਾਤਾ ਦੁਬਾਰਾ ਖੋਲ੍ਹ ਕੇ ਜਾਂਚੋ।';

  @override
  String get postNothing => 'ਕੁਝ ਨਹੀਂ ਚੜ੍ਹਿਆ।';

  @override
  String get postErrorNotPermitted =>
      'ਤੁਸੀਂ ਵਿਆਜ ਨਹੀਂ ਚੜ੍ਹਾ ਸਕਦੇ। ਮਾਲਕ ਨੂੰ ਕਹੋ।';

  @override
  String get postErrorFuture => 'ਅਗਲੀ ਤਾਰੀਖ਼ ਤੱਕ ਵਿਆਜ ਨਹੀਂ ਚੜ੍ਹ ਸਕਦਾ।';

  @override
  String get postBulkIntro =>
      'ਚੁਣੇ ਦਿਨ ਤੱਕ ਹਰ ਪਾਰਟੀ ਤੇ ਕਰਜ਼ੇ ਦਾ ਵਿਆਜ। ਜੋ ਨਾ ਚੜ੍ਹਾਉਣਾ ਹੋਵੇ ਉਸ ਦਾ ਨਿਸ਼ਾਨ ਹਟਾਓ। ਦੁਬਾਰਾ ਚਲਾਉਣ ਤੇ ਉਹੀ ਮਿਆਦ ਦੋ ਵਾਰ ਨਹੀਂ ਚੜ੍ਹਦੀ।';

  @override
  String get postBulkAsOf => 'ਵਿਆਜ ਇਸ ਦਿਨ ਤੱਕ';

  @override
  String postBulkSuggested(String date) {
    return 'ਸੁਝਾਅ: $date';
  }

  @override
  String get postBulkNone => 'ਇਸ ਦਿਨ ਤੱਕ ਚੜ੍ਹਾਉਣ ਵਾਲਾ ਵਿਆਜ ਨਹੀਂ ਹੈ।';

  @override
  String postBulkTotal(int count, String amount) {
    return '$count ਚੁਣੇ · $amount';
  }

  @override
  String postBulkPost(int count) {
    return '$count ਚੜ੍ਹਾਓ';
  }

  @override
  String postBulkDone(int count, String amount) {
    return '$count ਐਂਟਰੀਆਂ ਚੜ੍ਹੀਆਂ, $amount।';
  }

  @override
  String postBulkSkipped(int count) {
    return '$count ਛੱਡੀਆਂ ਗਈਆਂ (ਪਹਿਲਾਂ ਚੜ੍ਹ ਚੁੱਕੀਆਂ ਜਾਂ ਇਜਾਜ਼ਤ ਨਹੀਂ)।';
  }

  @override
  String get byajPosted => 'ਹੁਣ ਤੱਕ ਚੜ੍ਹਿਆ ਵਿਆਜ';

  @override
  String get byajUnposted => 'ਲੱਗਿਆ, ਪਰ ਚੜ੍ਹਿਆ ਨਹੀਂ';

  @override
  String get settleTitle => 'ਹਿਸਾਬ ਕਰੋ';

  @override
  String get settleIntro =>
      'ਇਸ ਪਾਰਟੀ ਦਾ ਇੱਕ ਦਿਨ ਤੱਕ ਹਿਸਾਬ: ਵਿਆਜ ਖਾਤੇ ਵਿੱਚ ਜੁੜਦਾ ਹੈ, ਚਾਹੋ ਤਾਂ ਛੋਟ ਘਟਦੀ ਹੈ, ਅਤੇ ਅੰਤ ਵਿੱਚ ਪਾਰਟੀ ਦਿੰਦੀ ਹੈ ਜਾਂ ਤੁਸੀਂ ਦਿੰਦੇ ਹੋ।';

  @override
  String get settleAsOf => 'ਹਿਸਾਬ ਇਸ ਦਿਨ ਤੱਕ';

  @override
  String get settleCropProceeds => 'ਫ਼ਸਲ ਦੀ ਰਕਮ';

  @override
  String get settlePayments => 'ਭੁਗਤਾਨ ਅਤੇ ਰਸੀਦਾਂ';

  @override
  String get settleLoans => 'ਕਰਜ਼ੇ (ਦਿੱਤੇ ਤੇ ਮੋੜੇ)';

  @override
  String get settleInterestPosted => 'ਪਹਿਲਾਂ ਚੜ੍ਹਿਆ ਵਿਆਜ';

  @override
  String get settleKhataBalance => 'ਹੁਣ ਖਾਤੇ ਦਾ ਬਾਕੀ';

  @override
  String get settleNothing => 'ਇਸ ਤਾਰੀਖ਼ ਤੱਕ ਕੋਈ ਵਿਆਜ ਬਾਕੀ ਨਹੀਂ।';

  @override
  String get settleReason => 'ਛੋਟ ਦਾ ਕਾਰਨ';

  @override
  String get settleWaiver => 'ਵਿਆਜ ਵਿੱਚ ਛੋਟ';

  @override
  String get settleInterestDue => 'ਦੇਣ ਵਾਲਾ ਵਿਆਜ';

  @override
  String get settleReceivable => 'ਪਾਰਟੀ ਤੁਹਾਨੂੰ ਦੇਵੇਗੀ';

  @override
  String get settlePayable => 'ਤੁਸੀਂ ਪਾਰਟੀ ਨੂੰ ਦੇਵੋਗੇ';

  @override
  String get settleSettled => 'ਹਿਸਾਬ ਬਰਾਬਰ';

  @override
  String settleDone(String interest, String waived) {
    return 'ਹਿਸਾਬ ਹੋਇਆ। ਵਿਆਜ $interest ਚੜ੍ਹਿਆ, $waived ਦੀ ਛੋਟ।';
  }

  @override
  String get settleNextHint => 'ਹੁਣ ਖਾਤੇ ਤੋਂ ਭੁਗਤਾਨ ਜਾਂ ਰਸੀਦ ਦਰਜ ਕਰੋ।';

  @override
  String get settlePrint => 'ਪਰਚੀ ਛਾਪੋ';

  @override
  String get settlePost => 'ਵਿਆਜ ਚੜ੍ਹਾਓ ਤੇ ਹਿਸਾਬ ਕਰੋ';

  @override
  String get settleOpenKhata => 'ਖਾਤੇ ਤੇ ਵਾਪਸ';

  @override
  String get settleInterestOnKhata => 'ਖਾਤੇ ਤੇ ਵਿਆਜ';

  @override
  String settleInterestOnLoan(String no) {
    return 'ਕਰਜ਼ੇ $no ਤੇ ਵਿਆਜ';
  }

  @override
  String get settleErrorNegative => 'ਛੋਟ ਰਿਣਾਤਮਕ ਨਹੀਂ ਹੋ ਸਕਦੀ।';

  @override
  String get settleErrorExceeds => 'ਛੋਟ ਲੱਗੇ ਵਿਆਜ ਤੋਂ ਵੱਧ ਹੈ।';

  @override
  String get settleErrorReason => 'ਛੋਟ ਦਾ ਕਾਰਨ ਲਿਖੋ।';

  @override
  String get settleErrorUnknown => 'ਉਸ ਖਾਤੇ ਵਿੱਚ ਛੋਟ ਦੇਣ ਵਾਲਾ ਵਿਆਜ ਨਹੀਂ ਹੈ।';

  @override
  String get settleErrorNeedsReverse => 'ਛੋਟ ਲਈ ਮੁਨੀਮ ਜਾਂ ਮਾਲਕ ਚਾਹੀਦਾ ਹੈ।';

  @override
  String get slipTitle => 'ਹਿਸਾਬ ਦੀ ਪਰਚੀ';

  @override
  String slipAsOf(String date) {
    return 'ਹਿਸਾਬ $date ਤੱਕ';
  }

  @override
  String slipReason(String reason) {
    return 'ਛੋਟ ਦਾ ਕਾਰਨ: $reason';
  }

  @override
  String get slipSignParty => 'ਪਾਰਟੀ ਦੇ ਦਸਤਖ਼ਤ';

  @override
  String get slipSignOwner => 'ਅਧਿਕਾਰਤ ਦਸਤਖ਼ਤ';

  @override
  String get settingBusinessCreditLimit =>
      'ਹਰ ਪਾਰਟੀ ਦੀ ਉਧਾਰ ਹੱਦ (₹, 0 = ਕੋਈ ਨਹੀਂ)';

  @override
  String get reportKarza => 'ਕਰਜ਼ਾ ਰਜਿਸਟਰ';

  @override
  String get reportInterestEarned => 'ਕਮਾਇਆ ਵਿਆਜ';

  @override
  String get reportColLoan => 'ਕਰਜ਼ਾ';

  @override
  String get reportColIssued => 'ਦਿੱਤਾ';

  @override
  String get reportColDue => 'ਦੇਣ ਦੀ ਤਾਰੀਖ਼';

  @override
  String get reportColPrincipal => 'ਮੂਲ';

  @override
  String get reportColRepaid => 'ਮੋੜਿਆ';

  @override
  String get reportColOutstanding => 'ਬਾਕੀ';

  @override
  String get reportColInterestAccrued => 'ਲੱਗਿਆ ਵਿਆਜ';

  @override
  String get reportColInterestRecovered => 'ਵਸੂਲਿਆ ਵਿਆਜ';

  @override
  String get reportColDaysOverdue => 'ਦੇਰੀ ਦੇ ਦਿਨ';

  @override
  String get reportColOverdueAge => 'ਦੇਰੀ ਦੀ ਉਮਰ';

  @override
  String get reportColPosted => 'ਖਾਤੇ ਵਿੱਚ ਚੜ੍ਹਿਆ';

  @override
  String get reportColWaived => 'ਛੋਟ ਦਿੱਤੀ';

  @override
  String get reportColUnposted => 'ਲੱਗਿਆ, ਚੜ੍ਹਿਆ ਨਹੀਂ';

  @override
  String get reportColEarned => 'ਕਮਾਈ (ਚੜ੍ਹਿਆ + ਲੱਗਿਆ)';

  @override
  String get reportInterestHelp =>
      'ਚੜ੍ਹਿਆ ਤੇ ਛੋਟ ਮਿਆਦ ਦੇ ਹਨ। ਲੱਗਿਆ, ਚੜ੍ਹਿਆ ਨਹੀਂ, ਅੱਜ ਤੱਕ ਦਾ ਹੈ।';

  @override
  String reportKarzaOverdueCount(int count) {
    return '$count ਦੇਰੀ ਵਿੱਚ';
  }

  @override
  String dashNeedsLoansOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਕਰਜ਼ਿਆਂ ਦੀ ਤਾਰੀਖ਼ ਲੰਘ ਗਈ',
      one: '1 ਕਰਜ਼ੇ ਦੀ ਤਾਰੀਖ਼ ਲੰਘ ਗਈ',
    );
    return '$_temp0';
  }

  @override
  String dashNeedsLoansDueSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਕਰਜ਼ੇ 7 ਦਿਨਾਂ ਵਿੱਚ ਦੇਣੇ',
      one: '1 ਕਰਜ਼ਾ 7 ਦਿਨਾਂ ਵਿੱਚ ਦੇਣਾ',
    );
    return '$_temp0';
  }

  @override
  String dashNeedsOverLimit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਪਾਰਟੀਆਂ ਉਧਾਰ ਹੱਦ ਤੋਂ ਉੱਪਰ',
      one: '1 ਪਾਰਟੀ ਉਧਾਰ ਹੱਦ ਤੋਂ ਉੱਪਰ',
    );
    return '$_temp0';
  }

  @override
  String dashNeedsInterestUnposted(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਖਾਤੇ',
      one: '1 ਖਾਤਾ',
    );
    return 'ਪਿਛਲੀ ਤਿਮਾਹੀ ਦਾ ਵਿਆਜ ਚੜ੍ਹਿਆ ਨਹੀਂ: $_temp0, $amount';
  }

  @override
  String get byajPrintStatement => 'ਵਿਆਜ ਦਾ ਹਿਸਾਬ ਛਾਪੋ';

  @override
  String get byajStatementTitle => 'ਵਿਆਜ ਦਾ ਹਿਸਾਬ';

  @override
  String byajStatementTerms(String rate, String method) {
    return '$rate% ਸਾਲਾਨਾ, $method';
  }
}
