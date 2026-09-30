// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get syncOff => 'सिंक बंद';

  @override
  String get syncSyncing => 'सिंक हो रहा है…';

  @override
  String get syncSyncedJustNow => 'सिंक हुआ · अभी';

  @override
  String syncSyncedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सिंक हुआ · $count मिनट पहले',
    );
    return '$_temp0';
  }

  @override
  String syncSyncedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सिंक हुआ · $count घंटे पहले',
    );
    return '$_temp0';
  }

  @override
  String get syncOffline => 'ऑफ़लाइन';

  @override
  String syncOfflineQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ऑफ़लाइन · $count बाकी',
    );
    return '$_temp0';
  }

  @override
  String syncErrorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सिंक त्रुटि · $count बदलाव अस्वीकार',
    );
    return '$_temp0';
  }

  @override
  String get syncErrorsTitle => 'सर्वर ने ये बदलाव अस्वीकार किए';

  @override
  String get syncErrorsBody =>
      'ये बदलाव ऑनलाइन सेव नहीं हुए। बाकी सब सिंक होता रहेगा।';

  @override
  String get syncErrorsDismiss => 'सब हटाएँ';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonRetry => 'फिर से कोशिश करें';

  @override
  String get splashLoading => 'तैयारी हो रही है…';

  @override
  String get loginTitle => 'मंडी खाता में साइन इन करें';

  @override
  String get loginSubtitle =>
      'हम आपके मोबाइल पर SMS से 6 अंकों का कोड भेजेंगे।';

  @override
  String get loginTabPhone => 'मोबाइल नंबर';

  @override
  String get loginTabEmail => 'ईमेल';

  @override
  String get loginPhoneLabel => 'मोबाइल नंबर';

  @override
  String get loginPhoneInvalid => '10 अंकों का भारतीय मोबाइल नंबर डालें';

  @override
  String get loginSendOtp => 'कोड भेजें';

  @override
  String get loginOtpLabel => '6 अंकों का कोड';

  @override
  String loginOtpSentTo(String phone) {
    return 'कोड $phone पर भेजा गया';
  }

  @override
  String get loginOtpInvalidFormat => '6 अंकों का कोड डालें';

  @override
  String get loginVerify => 'जाँचें और साइन इन करें';

  @override
  String loginResendIn(int seconds) {
    return '$seconds सेकंड में दोबारा भेजें';
  }

  @override
  String get loginResend => 'कोड दोबारा भेजें';

  @override
  String get loginChangeNumber => 'नंबर बदलें';

  @override
  String get loginEmailLabel => 'ईमेल';

  @override
  String get loginPasswordLabel => 'पासवर्ड';

  @override
  String get loginEmailSignIn => 'साइन इन करें';

  @override
  String get loginEmailInvalid => 'अपना ईमेल और पासवर्ड डालें';

  @override
  String get authErrorNotConfigured => 'इस बिल्ड में साइन इन सेट नहीं है।';

  @override
  String get authErrorNetwork => 'इंटरनेट नहीं है। कनेक्ट करके फिर कोशिश करें।';

  @override
  String get authErrorInvalidOtp =>
      'कोड गलत है या उसकी समय-सीमा खत्म हो गई है।';

  @override
  String get authErrorInvalidCredentials => 'ईमेल या पासवर्ड गलत है।';

  @override
  String get authErrorRateLimited =>
      'बहुत ज़्यादा कोशिशें। कुछ मिनट रुककर फिर कोशिश करें।';

  @override
  String get authErrorSms =>
      'SMS नहीं भेजा जा सका। बाद में कोशिश करें या ईमेल से साइन इन करें।';

  @override
  String get authErrorUnknown => 'साइन इन नहीं हो सका। फिर कोशिश करें।';

  @override
  String get tenantPickerTitle => 'व्यापार चुनें';

  @override
  String get tenantPickerSubtitle => 'आप बाद में अकाउंट मेनू से बदल सकते हैं।';

  @override
  String get tenantPickerLoading =>
      'आपके व्यापार डाउनलोड हो रहे हैं… पहली बार इंटरनेट ज़रूरी है।';

  @override
  String get tenantPickerNoSync =>
      'इस बिल्ड में सिंक सेट नहीं है, इसलिए व्यापार लोड नहीं हो सकते।';

  @override
  String get tenantPickerEmptyTitle => 'अभी कोई व्यापार जुड़ा नहीं है';

  @override
  String get tenantPickerEmptyBody =>
      'आपका अकाउंट किसी व्यापार में नहीं है। मालिक से जुड़वाएँ, फिर ऐप दोबारा खोलें।';

  @override
  String deviceSetupOffline(String business) {
    return '$business के लिए यह डिवाइस सेट करने हेतु एक बार इंटरनेट से जुड़ें।';
  }

  @override
  String deviceSetupFailed(String business) {
    return '$business के लिए यह डिवाइस सेट नहीं हो सका।';
  }

  @override
  String get roleOwner => 'मालिक';

  @override
  String get roleAccountant => 'मुनीम';

  @override
  String get roleMunshi => 'मुंशी';

  @override
  String get roleCustom => 'कस्टम भूमिका';

  @override
  String get pinSetupTitle => 'ऐप PIN सेट करें';

  @override
  String get pinSetupBody =>
      'ऐप खुलने पर पूछा जाएगा, ताकि दूसरे आपका खाता न देख सकें। 4–6 अंक, सिर्फ़ इसी डिवाइस पर।';

  @override
  String get pinConfirmTitle => 'PIN दोबारा डालें';

  @override
  String get pinMismatch => 'PIN मेल नहीं खाते। फिर कोशिश करें।';

  @override
  String get pinTooShort => '4 से 6 अंक रखें';

  @override
  String get pinSkip => 'अभी छोड़ें';

  @override
  String get pinSaved => 'ऐप PIN सेव हो गया';

  @override
  String get pinBiometricOption => 'फिंगरप्रिंट या चेहरे से भी खोलें';

  @override
  String get pinPadDelete => 'अंक मिटाएँ';

  @override
  String get pinPadOk => 'ठीक है';

  @override
  String get lockTitle => 'अपना PIN डालें';

  @override
  String get lockWrongPin => 'गलत PIN';

  @override
  String lockCooldown(int seconds) {
    return 'बहुत गलत कोशिशें। $seconds सेकंड बाद फिर कोशिश करें।';
  }

  @override
  String get lockUseBiometric => 'फिंगरप्रिंट से खोलें';

  @override
  String get lockBiometricReason => 'मंडी खाता खोलें';

  @override
  String get lockForgotPin => 'PIN भूल गए? साइन आउट करें';

  @override
  String get accountMenu => 'अकाउंट';

  @override
  String get accountSwitchBusiness => 'व्यापार बदलें';

  @override
  String get accountLockNow => 'अभी लॉक करें';

  @override
  String get accountSetPin => 'ऐप PIN सेट करें';

  @override
  String get accountChangePin => 'ऐप PIN बदलें';

  @override
  String get accountRemovePin => 'ऐप PIN हटाएँ';

  @override
  String get accountSignOut => 'साइन आउट';

  @override
  String homeDeviceCode(String code) {
    return 'यह डिवाइस: $code';
  }

  @override
  String get homePlaceholder => 'आपका डैशबोर्ड यहाँ दिखेगा।';

  @override
  String get signOutTitle => 'साइन आउट करें?';

  @override
  String get signOutBody =>
      'इस डिवाइस से डेटा की कॉपी हट जाएगी। दोबारा साइन इन के लिए इंटरनेट चाहिए।';

  @override
  String signOutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count बदलाव अभी अपलोड नहीं हुए हैं। अभी साइन आउट करने पर वे इस डिवाइस से मिट जाएँगे।',
      one:
          '1 बदलाव अभी अपलोड नहीं हुआ है। अभी साइन आउट करने पर वह इस डिवाइस से मिट जाएगा।',
    );
    return '$_temp0';
  }

  @override
  String get signOutUploadFirst => 'पहले अपलोड, फिर साइन आउट';

  @override
  String get signOutAnyway => 'साइन आउट करें और मिटाएँ';

  @override
  String get signOutUploading => 'बदलाव अपलोड हो रहे हैं…';

  @override
  String get signOutUploadFailed =>
      'सब कुछ अपलोड नहीं हो सका। इंटरनेट जाँचकर फिर कोशिश करें।';
}
