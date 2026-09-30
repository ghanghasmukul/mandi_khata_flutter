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
}
