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

  @override
  String get settingInterestEnabled => 'ब्याज लगाएँ';

  @override
  String get settingInterestRatePa => 'ब्याज दर (% सालाना)';

  @override
  String get settingInterestRateUnitDisplay => 'दर ऐसे दिखाएँ';

  @override
  String get settingInterestMethod => 'ब्याज का तरीका';

  @override
  String get settingInterestCompounding => 'चक्रवृद्धि अवधि';

  @override
  String get settingInterestDayBasis => 'साल के दिन';

  @override
  String get settingInterestGraceDays => 'छूट के दिन';

  @override
  String get settingInterestAppropriation => 'भुगतान पहले किसमें जाए';

  @override
  String get settingInterestApplyOn => 'ब्याज किस पर लगे';

  @override
  String get settingInterestMinDays => 'इससे कम दिनों की अवधि छोड़ें';

  @override
  String get settingInterestRounding => 'ब्याज को गोल करें';

  @override
  String get settingInterestPostFrequency => 'ब्याज खाते में कब चढ़े';

  @override
  String get settingInterestPayOnJama => 'जमा पर ब्याज दें';

  @override
  String get settingInterestPayRatePa => 'जमा पर दर (% सालाना)';

  @override
  String get settingMandiCommissionPct => 'आढ़त कमीशन %';

  @override
  String get settingMandiPalledariPerBag => 'पल्लेदारी प्रति बोरी';

  @override
  String get settingMandiBardanaPerBag => 'बारदाना प्रति बोरी';

  @override
  String get settingMandiTulaiPerQtl => 'तुलाई प्रति क्विंटल';

  @override
  String get settingMandiMandiFeePct => 'मंडी शुल्क %';

  @override
  String get settingMandiCess => 'सेस';

  @override
  String get settingMandiChargesBorneBy => 'कौन-सा खर्च कौन दे';

  @override
  String get settingMandiBagWeightKg => 'बोरी का वज़न (किलो)';

  @override
  String get settingShopPriceTiers => 'मूल्य श्रेणियाँ';

  @override
  String get settingShopDefaultTierForRole => 'डिफ़ॉल्ट मूल्य श्रेणी';

  @override
  String get settingShopAllowNegativeStock => 'शून्य से कम स्टॉक पर भी बेचें';

  @override
  String get settingShopExpiryWarnDays => 'समाप्ति से पहले चेतावनी (दिन)';

  @override
  String get settingShopGstEnabled => 'बिल पर GST';

  @override
  String get settingShopPostCreditSaleToKhata => 'उधार बिक्री खाते में चढ़ाएँ';

  @override
  String get settingBusinessFyStartMonth => 'वित्त वर्ष शुरू होने का महीना';

  @override
  String get settingBusinessNumberSeries => 'नंबर सीरीज़';

  @override
  String get settingAppModules => 'मॉड्यूल';

  @override
  String get settingAppLanguages => 'भाषाएँ';

  @override
  String get settingAppDefaultLanguage => 'डिफ़ॉल्ट भाषा';

  @override
  String get settingPrintReceiptSize => 'रसीद का कागज़';

  @override
  String get settingNotifyWhatsappReceipts => 'WhatsApp पर रसीद भेजें';

  @override
  String get settingOptInterestRateUnitDisplayPa => '% सालाना';

  @override
  String get settingOptInterestRateUnitDisplayPer100PerMonth =>
      '₹ प्रति 100 प्रति माह';

  @override
  String get settingOptInterestMethodSimple => 'साधारण';

  @override
  String get settingOptInterestMethodCompound => 'चक्रवृद्धि';

  @override
  String get settingOptInterestCompoundingMonthly => 'मासिक';

  @override
  String get settingOptInterestCompoundingQuarterly => 'तिमाही';

  @override
  String get settingOptInterestCompoundingHalfyearly => 'छमाही';

  @override
  String get settingOptInterestCompoundingYearly => 'सालाना';

  @override
  String get settingOptInterestCompoundingOnFyClose => 'वित्त वर्ष के अंत में';

  @override
  String get settingOptInterestAppropriationInterestFirst => 'ब्याज';

  @override
  String get settingOptInterestAppropriationPrincipalFirst => 'मूलधन';

  @override
  String get settingOptInterestApplyOnNetUdhaar => 'सिर्फ़ शुद्ध उधार';

  @override
  String get settingOptInterestApplyOnLoansOnly => 'सिर्फ़ कर्ज़';

  @override
  String get settingOptInterestApplyOnNone => 'ब्याज नहीं';

  @override
  String get settingOptInterestRoundingPaise => 'पैसे';

  @override
  String get settingOptInterestRoundingRupee => 'रुपया';

  @override
  String get settingOptInterestRoundingTenRupee => '₹10';

  @override
  String get settingOptInterestPostFrequencyOnDemand => 'जब मैं चुनूँ';

  @override
  String get settingOptInterestPostFrequencyMonthly => 'मासिक';

  @override
  String get settingOptInterestPostFrequencyQuarterly => 'तिमाही';

  @override
  String get settingOptInterestPostFrequencyFyClose => 'वित्त वर्ष के अंत में';

  @override
  String get settingOptAppDefaultLanguageEn => 'English';

  @override
  String get settingOptAppDefaultLanguageHi => 'हिंदी';

  @override
  String get settingOptAppDefaultLanguagePa => 'ਪੰਜਾਬੀ';

  @override
  String get settingOptPrintReceiptSizeA5 => 'A5 कागज़';

  @override
  String get settingOptPrintReceiptSizeThermal80 => 'थर्मल 80 मिमी';

  @override
  String get settingOptPrintReceiptSizeThermal58 => 'थर्मल 58 मिमी';

  @override
  String get settingSuffixRoleFarmer => 'किसान';

  @override
  String get settingSuffixRoleCustomer => 'ग्राहक';

  @override
  String get settingSuffixRoleSupplier => 'सप्लायर';

  @override
  String get settingSuffixRoleVendor => 'वेंडर';

  @override
  String get settingSuffixRoleAgency => 'एजेंसी';

  @override
  String get settingSuffixRoleBuyer => 'खरीदार';

  @override
  String get settingSuffixDocReceipt => 'रसीदें';

  @override
  String get settingSuffixDocLot => 'लॉट';

  @override
  String get settingSuffixDocSalesInvoice => 'बिक्री बिल';

  @override
  String get settingSuffixDocPurchaseInvoice => 'खरीद बिल';

  @override
  String get settingSuffixDocKarza => 'कर्ज़';

  @override
  String get settingSuffixDocVoucher => 'वाउचर';

  @override
  String get settingSuffixModuleKhata => 'खाता';

  @override
  String get settingSuffixModuleArrivals => 'आवक और लॉट';

  @override
  String get settingSuffixModuleKarza => 'कर्ज़ और ब्याज';

  @override
  String get settingSuffixModuleAccounting => 'लेखा';

  @override
  String get settingSuffixModuleShop => 'खाद-बीज दुकान';

  @override
  String get settingsGroupInterest => 'ब्याज';

  @override
  String get settingsGroupMandi => 'मंडी खर्चे';

  @override
  String get settingsGroupShop => 'खाद-बीज दुकान';

  @override
  String get settingsGroupBusiness => 'व्यापार';

  @override
  String get settingsGroupModules => 'मॉड्यूल';

  @override
  String get settingsGroupApp => 'ऐप';

  @override
  String get settingsGroupPrint => 'प्रिंटिंग';

  @override
  String get settingsGroupNotify => 'संदेश';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsScopeLabel => 'सेटिंग्स किसके लिए';

  @override
  String get settingsScopeBusiness => 'पूरा व्यापार';

  @override
  String get settingsScopeHint =>
      'किसी पार्टी को चुनकर उसकी अलग दरें रखें। खाली मान व्यापार की सेटिंग मानते हैं।';

  @override
  String get settingsReset => 'पहले जैसा करें';

  @override
  String get settingsSave => 'सेव करें';

  @override
  String get settingsSaved => 'सेव हो गया';

  @override
  String get settingsReadOnly => 'इसकी अलग स्क्रीन पर बदलेगा (जल्द)।';

  @override
  String get settingsNoPermission => 'आपको इसे बदलने की अनुमति नहीं है।';

  @override
  String get settingsNoTenant => 'पहले व्यापार चुनें।';

  @override
  String get settingSetHere => 'यहाँ सेट है';

  @override
  String get settingFromDocument => 'इस दस्तावेज़ से';

  @override
  String get settingFromParty => 'पार्टी से';

  @override
  String get settingFromPartyGroup => 'पार्टी समूह से';

  @override
  String get settingFromBusiness => 'व्यापार की सेटिंग से';

  @override
  String get settingFromPlan => 'आपके प्लान से';

  @override
  String get settingFromDefault => 'ऐप डिफ़ॉल्ट';

  @override
  String get settingErrorWrongType => 'सही मान डालें';

  @override
  String settingErrorTooSmall(String min) {
    return 'बहुत कम (न्यूनतम $min)';
  }

  @override
  String settingErrorTooLarge(String max) {
    return 'बहुत ज़्यादा (अधिकतम $max)';
  }

  @override
  String get settingErrorNotAllowed => 'यह मान मान्य नहीं है';

  @override
  String get settingErrorInvalid => 'गलत मान';

  @override
  String get settingErrorNotHere => 'इसे यहाँ सेट नहीं किया जा सकता';

  @override
  String settingRatePerMonth(String amount) {
    return '= ₹$amount प्रति 100 प्रति माह';
  }

  @override
  String get accountLanguage => 'भाषा';

  @override
  String get accountDiagnostics => 'डायग्नोस्टिक्स';

  @override
  String get diagnosticsTitle => 'डायग्नोस्टिक्स';

  @override
  String get diagnosticsOwnerOnly =>
      'डायग्नोस्टिक्स सिर्फ़ मालिक खोल सकते हैं।';

  @override
  String get diagnosticsDatabase => 'यह डिवाइस';

  @override
  String get diagnosticsDeviceCode => 'डिवाइस कोड';

  @override
  String get diagnosticsConnection => 'सिंक कनेक्शन';

  @override
  String get diagnosticsOnline => 'जुड़ा है';

  @override
  String get diagnosticsOffline => 'जुड़ा नहीं';

  @override
  String get diagnosticsLastSync => 'आख़िरी सिंक';

  @override
  String get diagnosticsNever => 'कभी नहीं';

  @override
  String get diagnosticsQueued => 'अपलोड के लिए बचे बदलाव';

  @override
  String get diagnosticsDbSize => 'लोकल डेटाबेस का आकार';

  @override
  String get diagnosticsRefresh => 'रिफ़्रेश करें';

  @override
  String get diagnosticsRejected => 'सर्वर ने जो बदलाव नहीं माने';

  @override
  String get diagnosticsNoRejected => 'कोई बदलाव अस्वीकार नहीं हुआ।';

  @override
  String get diagnosticsRetry => 'फिर भेजें';

  @override
  String get diagnosticsDiscard => 'हटाएँ';

  @override
  String get diagnosticsRequeued => 'फिर से अपलोड के लिए रखा गया';

  @override
  String get diagnosticsNotRetryable =>
      'यह बदलाव दोबारा नहीं भेजा जा सकता। इसे हटा दें।';

  @override
  String get settingSuffixDocParty => 'पार्टी कोड';

  @override
  String get partiesTitle => 'पार्टियाँ';

  @override
  String get partiesSearchHint => 'नाम, गाँव, मोबाइल, कोड खोजें';

  @override
  String get partiesAll => 'सभी';

  @override
  String partiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पार्टियाँ',
      one: '1 पार्टी',
    );
    return '$_temp0';
  }

  @override
  String get partiesEmptyTitle => 'अभी कोई पार्टी नहीं';

  @override
  String get partiesEmptyBody =>
      'जिन किसानों, खरीदारों और सप्लायरों से काम होता है, उन्हें जोड़ें।';

  @override
  String get partiesNoMatch => 'खोज से कोई पार्टी नहीं मिली।';

  @override
  String get partiesAdd => 'पार्टी जोड़ें';

  @override
  String get partyEditTitle => 'पार्टी बदलें';

  @override
  String get partyFieldCode => 'कोड';

  @override
  String partyCodeAutoHint(String code) {
    return 'खाली छोड़ें तो $code';
  }

  @override
  String get partyFieldName => 'नाम';

  @override
  String get partyFieldRoles => 'भूमिका';

  @override
  String get partyFieldRelation => 'संबंध';

  @override
  String get partyRelationNone => 'कोई नहीं';

  @override
  String get partyRelationSonOf => 'पुत्र';

  @override
  String get partyRelationDaughterOf => 'पुत्री';

  @override
  String get partyRelationWifeOf => 'पत्नी';

  @override
  String get partyRelationProprietor => 'प्रोप्राइटर';

  @override
  String get partyFieldFatherOrHusband => 'पिता / पति का नाम';

  @override
  String get partyFieldMobile => 'मोबाइल';

  @override
  String get partyFieldAltMobile => 'दूसरा मोबाइल';

  @override
  String get partyFieldVillage => 'गाँव';

  @override
  String get partyFieldDistrict => 'ज़िला';

  @override
  String get partyFieldState => 'राज्य';

  @override
  String get partyFieldAadhaar => 'आधार (आख़िरी 4 अंक)';

  @override
  String get partyFieldBankName => 'बैंक';

  @override
  String get partyFieldBankAccount => 'खाता नंबर';

  @override
  String get partyBankAccountHint => 'सिर्फ़ आख़िरी 4 अंक रखे जाते हैं';

  @override
  String get partyFieldIfsc => 'IFSC';

  @override
  String get partyFieldGstin => 'GSTIN';

  @override
  String get partyFieldNotes => 'नोट';

  @override
  String get partySectionIdentity => 'पार्टी';

  @override
  String get partySectionContact => 'संपर्क और पता';

  @override
  String get partySectionBank => 'बैंक और टैक्स';

  @override
  String get partyErrorRequired => 'ज़रूरी';

  @override
  String get partyErrorRoles => 'कम से कम एक भूमिका चुनें';

  @override
  String get partyErrorMobile => '10 अंकों का मोबाइल नंबर डालें';

  @override
  String get partyErrorIfsc => 'सही IFSC डालें, जैसे SBIN0001234';

  @override
  String get partyErrorGstin => 'सही 15 अक्षरों का GSTIN डालें';

  @override
  String get partyErrorAadhaar => 'सिर्फ़ आख़िरी 4 अंक डालें';

  @override
  String get partyErrorCodeTaken => 'यह कोड किसी और पार्टी का है';

  @override
  String get partyNotFound => 'यह पार्टी हटा दी गई है।';

  @override
  String get partySave => 'पार्टी सेव करें';

  @override
  String get partySaved => 'पार्टी सेव हो गई';

  @override
  String get partyEdit => 'बदलें';

  @override
  String get partyDelete => 'हटाएँ';

  @override
  String partyDeleteTitle(String name) {
    return '$name को हटाएँ?';
  }

  @override
  String get partyDeleteBody =>
      'पार्टी सूची से छिप जाएगी। उसका इतिहास और ऑडिट लॉग बना रहेगा।';

  @override
  String get partyDeleted => 'पार्टी हटा दी गई';

  @override
  String get partyTabKhata => 'खाता';

  @override
  String get partyTabLots => 'लॉट';

  @override
  String get partyTabLoans => 'कर्ज़';

  @override
  String get partyTabShop => 'दुकान';

  @override
  String get partyTabDocuments => 'दस्तावेज़';

  @override
  String get partyTabNotes => 'नोट';

  @override
  String get partyTabComingSoon => 'यह हिस्सा अगले अपडेट में आएगा।';

  @override
  String get partyNoNotes => 'कोई नोट नहीं।';

  @override
  String get cropsTitle => 'फसलें';

  @override
  String get cropsAdd => 'फसल जोड़ें';

  @override
  String get cropsEmpty => 'अभी कोई फसल नहीं।';

  @override
  String get cropsShowInactive => 'बंद फसलें भी दिखाएँ';

  @override
  String get cropInactive => 'बंद';

  @override
  String cropRatePerQtl(String rate) {
    return '$rate/क्विंटल';
  }

  @override
  String get cropNoRate => 'MSP / आम भाव नहीं';

  @override
  String get cropEditTitle => 'फसल बदलें';

  @override
  String get cropFieldNameEn => 'नाम (अंग्रेज़ी)';

  @override
  String get cropFieldNameHi => 'नाम (हिंदी)';

  @override
  String get cropFieldNamePa => 'नाम (पंजाबी)';

  @override
  String get cropFieldCode => 'कोड';

  @override
  String get cropCodeHint =>
      'छोटे अंग्रेज़ी अक्षर, अंक और _। बाद में नहीं बदलेगा।';

  @override
  String get cropFieldStdRate => 'MSP / आम भाव प्रति क्विंटल';

  @override
  String get cropFieldActive => 'चालू';

  @override
  String get cropErrorCode =>
      'अक्षर से शुरू करें; छोटे अक्षर, अंक और _ (अधिकतम 24)।';

  @override
  String get cropErrorName => 'अंग्रेज़ी नाम लिखें।';

  @override
  String get cropErrorRate => 'सही रकम लिखें।';

  @override
  String get cropErrorCodeTaken => 'इस कोड की फसल पहले से है।';

  @override
  String get cropNotFound => 'यह फसल अब नहीं है।';

  @override
  String get cropChargesTitle => 'इस फसल के मंडी खर्चे';

  @override
  String get cropChargesHint =>
      'जो यहाँ सेट नहीं, वह व्यापार की सेटिंग से आएगा। किसान या लॉट के लिए सेट रेट फिर भी ऊपर रहेगा।';

  @override
  String cropExampleTitle(int bags, String qtl, String rate) {
    return 'उदाहरण: $bags बोरी · $qtl क्विंटल @ $rate/क्विंटल';
  }

  @override
  String get chargeCommission => 'आढ़त (कमीशन)';

  @override
  String get chargePalledari => 'पल्लेदारी';

  @override
  String get chargeBardana => 'बारदाना';

  @override
  String get chargeTulai => 'तुलाई';

  @override
  String get chargeMandiFee => 'मंडी फीस';

  @override
  String get chargeCess => 'सेस';

  @override
  String get payerFarmer => 'किसान';

  @override
  String get payerBuyer => 'खरीदार';

  @override
  String get payerArhtiya => 'आढ़ती (हम)';

  @override
  String get mandiGross => 'कुल रकम';

  @override
  String get mandiNetToFarmer => 'किसान को शुद्ध (जमा)';

  @override
  String get mandiBuyerTotal => 'खरीदार देगा (उधार)';

  @override
  String mandiPaidBy(String payer) {
    return '$payer देगा';
  }

  @override
  String get mandiWaived => 'माफ़';

  @override
  String get cessAdd => 'सेस जोड़ें';

  @override
  String get cessName => 'नाम (जैसे RDF)';

  @override
  String get cessPct => '%';

  @override
  String get cessRemove => 'हटाएँ';

  @override
  String get settingsEdit => 'बदलें';

  @override
  String get settingsCropsLink => 'फसलें और फसल-वार खर्चे';

  @override
  String get arrivalsTitle => 'आवक';

  @override
  String get arrivalsEmpty => 'इन फ़िल्टर में कोई लॉट नहीं';

  @override
  String get arrivalsSearchHint => 'किसान या लॉट नंबर खोजें';

  @override
  String get arrivalsAllCrops => 'सभी फ़सलें';

  @override
  String get arrivalsAllStatuses => 'सभी स्थिति';

  @override
  String get rangeToday => 'आज';

  @override
  String get rangeYesterday => 'कल';

  @override
  String get rangeWeek => 'पिछले 7 दिन';

  @override
  String get rangeAll => 'सभी तारीखें';

  @override
  String get rangeCustom => 'तारीखें चुनें…';

  @override
  String get lotNo => 'लॉट नं.';

  @override
  String get lotDate => 'तारीख';

  @override
  String get lotFarmer => 'किसान';

  @override
  String get lotCrop => 'फ़सल';

  @override
  String get lotBags => 'बोरी';

  @override
  String lotBagsCount(int count) {
    return '$count बोरी';
  }

  @override
  String get lotQtl => 'क्विंटल';

  @override
  String get lotQtlUnit => 'क्विंटल';

  @override
  String lotQtlFromBags(String kg) {
    return 'बोरी × $kg किलो से';
  }

  @override
  String get lotQtlFromBagsShort => 'बोरी से';

  @override
  String get lotRate => 'भाव';

  @override
  String get lotPerQtl => '/ क्विंटल';

  @override
  String get lotBuyer => 'खरीदार';

  @override
  String get lotBuyerHint => 'वैकल्पिक — 3 अक्षर लिखें';

  @override
  String get lotJForm => 'जे-फ़ॉर्म नं.';

  @override
  String get lotVehicle => 'वाहन नं.';

  @override
  String get lotNotes => 'टिप्पणी';

  @override
  String get lotStatusLabel => 'स्थिति';

  @override
  String get lotPostedAt => 'खाते में दर्ज';

  @override
  String get lotStatusArrived => 'आया';

  @override
  String get lotStatusWeighed => 'तुला';

  @override
  String get lotStatusSold => 'बिका';

  @override
  String get lotStatusPosted => 'खाते में';

  @override
  String get lotStatusReversed => 'उलटा गया';

  @override
  String get lotStatusCancelled => 'रद्द';

  @override
  String get lotProblemBags => 'बोरी ऋण में नहीं हो सकतीं';

  @override
  String get lotProblemWeight => 'वज़न लिखें';

  @override
  String get lotProblemRate => 'भाव शून्य से ज़्यादा हो';

  @override
  String get lotProblemBuyerIsFarmer => 'खरीदार और किसान एक नहीं हो सकते';

  @override
  String get lotProblemNoWeight => 'खाते में डालने के लिए वज़न चाहिए';

  @override
  String get lotProblemNoRate => 'खाते में डालने के लिए भाव चाहिए';

  @override
  String get lotProblemBuyerRequired =>
      'खरीदार चुनें: कुछ ख़र्चे खरीदार से लिए जाते हैं';

  @override
  String get lotProblemNetNotPositive =>
      'ख़र्चे बिक्री से ज़्यादा हैं; किसान को जमा करने को कुछ नहीं';

  @override
  String get lotErrorNotPermitted => 'आपको इसकी अनुमति नहीं है';

  @override
  String get lotErrorNotFound => 'लॉट, किसान, खरीदार या फ़सल नहीं मिली';

  @override
  String get lotErrorLocked =>
      'यह लॉट खाते में दर्ज या उलटा जा चुका है, बदला नहीं जा सकता';

  @override
  String get lotErrorPickFarmer => 'किसान चुनें';

  @override
  String get lotErrorPickCrop => 'फ़सल चुनें';

  @override
  String get lotNewTitle => 'नई आवक';

  @override
  String get lotEditTitle => 'लॉट बदलें';

  @override
  String lotNextNo(String number) {
    return 'लॉट $number';
  }

  @override
  String get lotSave => 'सेव करें (F10)';

  @override
  String get lotSavePost => 'सेव करें और खाते में डालें (F10)';

  @override
  String get lotSaveNew => 'सेव करें और नया (Shift+F10)';

  @override
  String get lotHold => 'रोकें — खाते में न डालें';

  @override
  String lotSavedToast(String lotNo) {
    return 'लॉट $lotNo सेव हुआ';
  }

  @override
  String lotPostedToast(String lotNo) {
    return 'लॉट $lotNo खाते में दर्ज';
  }

  @override
  String get lotPreviewTitle => 'हिसाब';

  @override
  String get lotPreviewEmpty =>
      'आढ़त, ख़र्चे और शुद्ध रकम देखने के लिए फ़सल, वज़न और भाव लिखें।';

  @override
  String get lotPostsTitle => 'खाते में यह दर्ज होगा:';

  @override
  String get lotPostsFarmer => 'किसान को जमा';

  @override
  String get lotPostsBuyer => 'खरीदार पर उधार';

  @override
  String get lotCancel => 'लॉट रद्द करें';

  @override
  String lotCancelTitle(String lotNo) {
    return 'लॉट $lotNo रद्द करें?';
  }

  @override
  String get lotCancelBody =>
      'जब फ़सल आई ही नहीं या ग़लती से दर्ज हुई हो। खाते में कुछ दर्ज नहीं हुआ था। यह वापस नहीं होगा।';

  @override
  String lotCancelledToast(String lotNo) {
    return 'लॉट $lotNo रद्द';
  }

  @override
  String get lotReverse => 'लॉट उलटें';

  @override
  String lotReverseTitle(String lotNo) {
    return 'लॉट $lotNo उलटें?';
  }

  @override
  String get lotReverseBody =>
      'इसकी खाता एंट्री (किसान का जमा, खरीदार का उधार) उसी तारीख पर उलटी होंगी। लॉट रिकॉर्ड में \'उलटा गया\' रहेगा। फिर आप इसे सही से दोबारा दर्ज कर सकते हैं।';

  @override
  String lotReversedToast(String lotNo) {
    return 'लॉट $lotNo उलटा गया';
  }

  @override
  String get lotReenter => 'दोबारा दर्ज करें';

  @override
  String get lotEdit => 'बदलें';

  @override
  String get lotAddWeightRate => 'वज़न और भाव डालें';

  @override
  String get lotDetailsTitle => 'लॉट';

  @override
  String get lotCalculationTitle => 'आढ़त और ख़र्चे';

  @override
  String get lotNotPostedYet =>
      'लॉट खाते में दर्ज होने पर दिखेगा (उस दिन के रेट से)।';

  @override
  String get lotEntriesTitle => 'खाता एंट्री';

  @override
  String get lotEntryArrival => 'फ़सल बिक्री';

  @override
  String get lotEntryReversal => 'उलट एंट्री';

  @override
  String get lotsTotalCount => 'लॉट';

  @override
  String get wizardStepFarmer => 'किसान';

  @override
  String get wizardStepCrop => 'फ़सल और बोरी';

  @override
  String get wizardStepConfirm => 'पुष्टि';

  @override
  String wizardStepOf(int step, int total, String title) {
    return 'चरण $step/$total: $title';
  }

  @override
  String get wizardBack => 'पीछे';

  @override
  String get wizardNext => 'आगे';

  @override
  String get wizardRateLater => 'वज़न और भाव काउंटर पर डाले जाएँगे।';

  @override
  String partyPickerHint(int count) {
    return 'खोजने के लिए $count अक्षर लिखें';
  }

  @override
  String get partyPickerChange => 'बदलें';

  @override
  String get khataRefArrival => 'फसल बिक्री';

  @override
  String get khataRefPayment => 'भुगतान';

  @override
  String get khataRefReceipt => 'रसीद';

  @override
  String get khataRefShopSale => 'दुकान बिक्री';

  @override
  String get khataRefShopReturn => 'दुकान वापसी';

  @override
  String get khataRefPurchase => 'खरीद';

  @override
  String get khataRefLoanDisbursal => 'कर्ज़ दिया';

  @override
  String get khataRefLoanRepayment => 'कर्ज़ वापसी';

  @override
  String get khataRefInterest => 'ब्याज';

  @override
  String get khataRefExpense => 'खर्च';

  @override
  String get khataRefJournal => 'खाता एंट्री';

  @override
  String get khataRefOpeningBalance => 'शुरुआती बाकी';

  @override
  String get khataRefReversal => 'उलट एंट्री';

  @override
  String get khataTagReversal => 'उलट';

  @override
  String get khataTagEdited => 'सुधारी गई';

  @override
  String get khataTagReversed => 'उलट दी गई';

  @override
  String khataErrorBackdated(int days) {
    return '$days दिन से पुरानी या आगे की तारीख की एंट्री के लिए मुनीम या मालिक चाहिए';
  }

  @override
  String get khataErrorNotPermitted => 'आपको इसकी अनुमति नहीं है';

  @override
  String get khataErrorNotFound => 'यह पार्टी या एंट्री अब मौजूद नहीं है';

  @override
  String get khataErrorAmount => 'शून्य से ज़्यादा रकम लिखें';

  @override
  String get khataErrorNothingChanged => 'कुछ भी नहीं बदला';

  @override
  String get khataErrorAlreadyReversed => 'यह एंट्री पहले ही उलट दी गई है';

  @override
  String get khataErrorIsReversal =>
      'उलट एंट्री बदली नहीं जा सकती; नई एंट्री डालें';

  @override
  String get khataColDate => 'तारीख';

  @override
  String get khataColDetails => 'विवरण';

  @override
  String get khataColPartyDetails => 'पार्टी · विवरण';

  @override
  String get khataColUdhaar => 'उधार';

  @override
  String get khataColJama => 'जमा';

  @override
  String get khataColBaki => 'बाकी';

  @override
  String get khataBalanceJama => 'जमा · हमें देना है';

  @override
  String get khataBalanceUdhaarFarmer => 'उधार · किसान को देना है';

  @override
  String get khataBalanceUdhaarParty => 'उधार · पार्टी को देना है';

  @override
  String get khataBalanceSettled => 'हिसाब बराबर';

  @override
  String get khataEntryTitle => 'खाता एंट्री';

  @override
  String get khataEditTitle => 'खाता एंट्री सुधारें';

  @override
  String get khataEditOriginal => 'मूल एंट्री (उलट दी जाएगी)';

  @override
  String get khataEditExplain =>
      'मूल एंट्री कटी हुई खाते में रहेगी और सही एंट्री जुड़ेगी।';

  @override
  String get khataFieldParty => 'पार्टी';

  @override
  String get khataFieldPartyHint => 'नाम, गाँव या कोड लिखें';

  @override
  String get khataSideUdhaar => 'उधार (पार्टी का देना बढ़ा)';

  @override
  String get khataSideJama => 'जमा (हमारा देना बढ़ा)';

  @override
  String get khataFieldAmount => 'रकम';

  @override
  String get khataFieldDate => 'तारीख';

  @override
  String get khataFieldNarration => 'विवरण';

  @override
  String get khataEntrySave => 'एंट्री डालें';

  @override
  String get khataEditSave => 'उलटकर दोबारा डालें';

  @override
  String get khataDayBookTitle => 'सभी एंट्री';

  @override
  String get khataDayBookEmpty => 'इस फ़िल्टर में कोई एंट्री नहीं';

  @override
  String get khataFilterParty => 'पार्टी से छाँटें';

  @override
  String get khataFilterAllTypes => 'सभी प्रकार';

  @override
  String khataEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count एंट्री',
      one: '1 एंट्री',
    );
    return '$_temp0';
  }

  @override
  String get khataReverseTitle => 'यह एंट्री उलटें?';

  @override
  String get khataReverseBody =>
      'उलट एंट्री जुड़ेगी और दोनों खाते में रहेंगी। इसे वापस नहीं किया जा सकता।';

  @override
  String get khataReverse => 'उलटें';

  @override
  String get khataReversed => 'एंट्री उलट दी गई';

  @override
  String get khataEntryActions => 'एंट्री विकल्प';

  @override
  String get khataEdit => 'सुधारें (उलटकर दोबारा)';

  @override
  String get khataStatementEmpty => 'इस अवधि में कोई एंट्री नहीं';

  @override
  String get statementTitle => 'खाता विवरण';

  @override
  String get statementOpening => 'शुरुआती बाकी';

  @override
  String get statementClosing => 'अंतिम बाकी';

  @override
  String get statementTotals => 'कुल';

  @override
  String statementPage(int page, int pages) {
    return 'पृष्ठ $page / $pages';
  }

  @override
  String get statementPrint => 'प्रिंट / PDF';

  @override
  String get statementShare => 'भेजें';

  @override
  String get paletteHint => 'कमांड लिखें…';

  @override
  String get paletteNoMatch => 'कोई कमांड नहीं मिली';

  @override
  String get settingBusinessBackdateDays => 'पिछली तारीख की छूट (दिन)';

  @override
  String get paymentsTitle => 'भुगतान';

  @override
  String get paymentRecordTitle => 'भुगतान दर्ज करें';

  @override
  String get paymentPay => 'भुगतान दें';

  @override
  String get paymentReceive => 'रकम लें';

  @override
  String get paymentDirectionTo => 'पार्टी को दिया';

  @override
  String get paymentDirectionFrom => 'पार्टी से मिला';

  @override
  String get paymentsEmpty => 'इस अवधि में कोई भुगतान नहीं';

  @override
  String get paymentsSearchHint => 'पार्टी, रसीद या चेक नंबर खोजें';

  @override
  String get paymentsAllModes => 'सभी तरीके';

  @override
  String get paymentsAllDirections => 'दिया और मिला';

  @override
  String get paymentsPendingCheques => 'लंबित चेक';

  @override
  String get paymentsTotalCount => 'भुगतान';

  @override
  String get paymentsTotalPaid => 'दिया';

  @override
  String get paymentsTotalReceived => 'मिला';

  @override
  String get paymentsColNo => 'नंबर';

  @override
  String get paymentsColDate => 'तारीख';

  @override
  String get paymentsColParty => 'पार्टी';

  @override
  String get paymentsColType => 'प्रकार';

  @override
  String get paymentsColMode => 'तरीका';

  @override
  String get paymentsColAmount => 'रकम';

  @override
  String get paymentsColStatus => 'स्थिति';

  @override
  String get paymentFieldAmount => 'रकम';

  @override
  String get paymentFieldDate => 'तारीख';

  @override
  String get paymentFieldMode => 'तरीका';

  @override
  String get paymentFieldAccount => 'बैंक खाता';

  @override
  String get paymentFieldReference => 'UTR / संदर्भ';

  @override
  String get paymentFieldChequeNo => 'चेक नंबर';

  @override
  String get paymentFieldChequeDate => 'चेक की तारीख';

  @override
  String get paymentFieldNarration => 'टिप्पणी';

  @override
  String get paymentModeCash => 'नकद';

  @override
  String get paymentModeBank => 'बैंक ट्रांसफर';

  @override
  String get paymentModeUpi => 'UPI';

  @override
  String get paymentModeCheque => 'चेक';

  @override
  String get paymentChequePending => 'लंबित';

  @override
  String get paymentChequeCleared => 'क्लियर';

  @override
  String get paymentChequeBounced => 'बाउंस';

  @override
  String get paymentStatusReversed => 'उलटा किया';

  @override
  String get paymentBakiNow => 'अभी बाकी';

  @override
  String get paymentBakiAfter => 'इस भुगतान के बाद';

  @override
  String get paymentFullBaki => 'पूरा बाकी';

  @override
  String get paymentSave => 'भुगतान सहेजें';

  @override
  String paymentSavedAs(String receiptNo) {
    return '$receiptNo के रूप में सहेजा';
  }

  @override
  String get paymentReceiptTitle => 'रसीद';

  @override
  String get paymentVoucherTitle => 'भुगतान वाउचर';

  @override
  String get paymentPrintReceipt => 'रसीद प्रिंट करें';

  @override
  String get paymentShareReceipt => 'रसीद भेजें';

  @override
  String get paymentDone => 'हो गया';

  @override
  String get paymentMarkCleared => 'क्लियर करें';

  @override
  String get paymentMarkBounced => 'बाउंस करें';

  @override
  String get paymentBounceTitle => 'चेक बाउंस हुआ?';

  @override
  String get paymentBounceBody =>
      'इससे खाता एंट्री और कैश बुक की लाइन उलट जाएगी, बाउंस की तारीख के साथ।';

  @override
  String get paymentBounceDate => 'बाउंस की तारीख';

  @override
  String get paymentReverse => 'भुगतान उलटें';

  @override
  String get paymentReverseTitle => 'यह भुगतान उलटें?';

  @override
  String get paymentReverseBody =>
      'खाता एंट्री और कैश बुक की लाइन उलट दी जाएगी। भुगतान \"उलटा किया\" के रूप में रिकॉर्ड में रहेगा।';

  @override
  String get paymentReversedToast => 'भुगतान उलटा गया';

  @override
  String get paymentClearedToast => 'चेक क्लियर किया गया';

  @override
  String get paymentBouncedToast => 'चेक बाउंस; एंट्री उलटी गई';

  @override
  String get paymentNotFound => 'यह भुगतान अब मौजूद नहीं';

  @override
  String get paymentErrorNotPermitted =>
      'आपको यह भुगतान दर्ज करने की अनुमति नहीं';

  @override
  String paymentErrorLimit(String limit) {
    return '$limit से ज़्यादा के भुगतान के लिए मुनीम या मालिक चाहिए';
  }

  @override
  String get paymentErrorFinance =>
      'बैंक, UPI और चेक भुगतान के लिए फाइनेंस अनुमति चाहिए';

  @override
  String get paymentErrorNotFound => 'पार्टी या बैंक खाता अब मौजूद नहीं';

  @override
  String get paymentErrorLocked => 'यह भुगतान या चेक अब नहीं बदल सकता';

  @override
  String get paymentErrorAmount => 'शून्य से ज़्यादा रकम लिखें';

  @override
  String get paymentErrorBank => 'बैंक खाता चुनें';

  @override
  String get paymentErrorChequeNo => 'चेक नंबर लिखें';

  @override
  String get paymentErrorChequeDate => 'चेक की तारीख लिखें';

  @override
  String get paymentErrorChequeDetails =>
      'चेक की जानकारी सिर्फ़ चेक के साथ दें';

  @override
  String get paymentNoBankAccounts =>
      'अभी कोई बैंक खाता नहीं। \"बैंक खाते\" में जोड़ें।';

  @override
  String get accountsTitle => 'बैंक खाते';

  @override
  String get accountsAdd => 'बैंक खाता जोड़ें';

  @override
  String get accountsEdit => 'बैंक खाता बदलें';

  @override
  String get accountsEmpty => 'अभी कोई बैंक खाता नहीं';

  @override
  String get accountCash => 'नकद';

  @override
  String get accountFieldName => 'खाते का नाम';

  @override
  String get accountFieldBank => 'बैंक का नाम';

  @override
  String get accountFieldLast4 => 'खाता नंबर के आखिरी 4 अंक';

  @override
  String get accountFieldIfsc => 'IFSC';

  @override
  String get accountBookBalance => 'बही शेष';

  @override
  String get accountSwitchOff => 'बंद करें';

  @override
  String get accountSwitchOn => 'चालू करें';

  @override
  String get accountInactive => 'बंद';

  @override
  String get accountErrorName => 'खाते का नाम लिखें';

  @override
  String get accountErrorLast4 => 'ठीक 4 अंक';

  @override
  String get accountErrorIfsc => 'सही IFSC नहीं (जैसे SBIN0001234)';

  @override
  String get accountErrorNotPermitted =>
      'बैंक खातों के लिए फाइनेंस अनुमति चाहिए';

  @override
  String get receiptReceivedFrom => 'प्राप्त किया';

  @override
  String get receiptPaidTo => 'भुगतान किया';

  @override
  String get receiptNo => 'नंबर';

  @override
  String get receiptDate => 'तारीख';

  @override
  String get receiptAmount => 'रकम';

  @override
  String get receiptMode => 'तरीका';

  @override
  String get receiptReference => 'संदर्भ';

  @override
  String get receiptChequeNo => 'चेक नं.';

  @override
  String get receiptChequeDate => 'चेक की तारीख';

  @override
  String get receiptBalanceAfter => 'इसके बाद बाकी';

  @override
  String get receiptSignature => 'हस्ताक्षर';

  @override
  String get receiptReversed => 'उलटा किया';

  @override
  String get settingBusinessMunshiPaymentLimit =>
      'मुनीम के लिए भुगतान सीमा (₹, 0 = कोई नहीं)';

  @override
  String dashHeroLots(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आज $count लॉट आए',
    );
    return '$_temp0 · $amount आढ़त कमाई';
  }

  @override
  String get dashHeroNoLots => 'आज अभी तक कोई लॉट नहीं आया';

  @override
  String get dashWeOweFarmers => 'हमें किसानों को देना है';

  @override
  String get dashOthersOweUs => 'दूसरों से हमें लेना है';

  @override
  String get dashActionAddFarmer => 'किसान जोड़ें';

  @override
  String get dashStatLots => 'आज के लॉट';

  @override
  String dashStatQtl(String qtl) {
    return '$qtl क्विंटल';
  }

  @override
  String get dashStatEarned => 'आज की आढ़त कमाई';

  @override
  String get dashStatPaid => 'आज दिया गया';

  @override
  String get dashStatReceipts => 'आज की प्राप्ति';

  @override
  String get dashChartTitle => 'आढ़त कमाई · पिछले 10 दिन';

  @override
  String get dashChartEmpty => 'इन दिनों में अभी कोई आढ़त कमाई नहीं';

  @override
  String dashCropMixTitle(String year) {
    return 'बिक्री मूल्य के अनुसार फ़सल · $year';
  }

  @override
  String get dashCropMixEmpty => 'इस सीज़न में अभी कोई बिक्री पोस्ट नहीं हुई';

  @override
  String dashCropMixLots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लॉट',
    );
    return '$_temp0';
  }

  @override
  String get dashMoneyTitle => 'पैसा कहाँ है';

  @override
  String get dashFarmersPayable => 'किसान खाता · हमें देना है';

  @override
  String get dashFarmersReceivable => 'किसान खाता · किसानों से लेना है';

  @override
  String get dashOthersReceivable => 'अन्य पार्टियों से लेना है';

  @override
  String get dashNeedsTitle => 'आज आपकी ज़रूरत है';

  @override
  String get dashNeedsNothing => 'अभी कुछ भी ज़रूरी नहीं';

  @override
  String dashNeedsSyncErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बदलाव सर्वर ने अस्वीकार किए',
    );
    return '$_temp0';
  }

  @override
  String dashNeedsCheques(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चेक की तारीख आ गई',
    );
    return '$_temp0 · $amount';
  }

  @override
  String dashNeedsStaff(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'पिछले 7 दिनों में मुंशी के $count बदलाव',
    );
    return '$_temp0';
  }

  @override
  String get dashStatEarnedSub => 'पोस्ट किए लॉट से';

  @override
  String get dashStatPaidSub => 'पार्टियों को';

  @override
  String get dashStatReceiptsSub => 'पार्टियों से';

  @override
  String get reportsTitle => 'रिपोर्ट';

  @override
  String get reportOutstanding => 'बकाया (बाकी)';

  @override
  String get reportArrivals => 'आवक रजिस्टर';

  @override
  String get reportCommission => 'आढ़त कमाई';

  @override
  String get reportPayments => 'भुगतान रजिस्टर';

  @override
  String get reportStatements => 'पार्टी विवरण';

  @override
  String get reportColCode => 'कोड';

  @override
  String get reportColParty => 'पार्टी';

  @override
  String get reportColVillage => 'गाँव';

  @override
  String get reportColWeOwe => 'हमें देना है';

  @override
  String get reportColTheyOwe => 'हमें लेना है';

  @override
  String get reportColLastEntry => 'आखिरी एंट्री';

  @override
  String get reportColDays => 'दिन';

  @override
  String get reportColAgeing => 'अवधि';

  @override
  String get reportColLot => 'लॉट';

  @override
  String get reportColDate => 'तारीख';

  @override
  String get reportColFarmer => 'किसान';

  @override
  String get reportColCrop => 'फ़सल';

  @override
  String get reportColBags => 'बोरी';

  @override
  String get reportColQtl => 'क्विंटल';

  @override
  String get reportColRate => 'भाव / क्विंटल';

  @override
  String get reportColGross => 'कुल बिक्री';

  @override
  String get reportColCharges => 'कटौती';

  @override
  String get reportColNet => 'किसान को शुद्ध';

  @override
  String get reportColBuyer => 'खरीदार';

  @override
  String get reportColStatus => 'स्थिति';

  @override
  String get reportColLots => 'लॉट';

  @override
  String get reportColSaleValue => 'बिक्री मूल्य';

  @override
  String get reportColArhat => 'आढ़त';

  @override
  String get reportColReceipt => 'रसीद नं.';

  @override
  String get reportColMode => 'तरीका';

  @override
  String get reportColReceived => 'प्राप्त';

  @override
  String get reportColPaid => 'दिया';

  @override
  String get reportColReference => 'संदर्भ';

  @override
  String get reportColOpening => 'शुरुआती';

  @override
  String get reportColUdhaar => 'उधार';

  @override
  String get reportColJama => 'जमा';

  @override
  String get reportColClosing => 'अंतिम बाकी';

  @override
  String get reportTotal => 'कुल';

  @override
  String get reportAgeUpTo30 => '0–30 दिन';

  @override
  String get reportAgeUpTo90 => '31–90 दिन';

  @override
  String get reportAgeUpTo180 => '91–180 दिन';

  @override
  String get reportAgeOver180 => '180 दिन से ज़्यादा';

  @override
  String get reportAgeingTitle => 'पुराना बकाया';

  @override
  String reportAsOf(String date) {
    return '$date तक';
  }

  @override
  String reportPeriod(String range) {
    return 'अवधि: $range';
  }

  @override
  String get reportSideAll => 'सभी';

  @override
  String get reportSidePayable => 'हमें देना है';

  @override
  String get reportSideReceivable => 'हमें लेना है';

  @override
  String get reportFilterAllCrops => 'सभी फ़सलें';

  @override
  String get reportFilterAllModes => 'सभी तरीके';

  @override
  String get reportFilterAllVillages => 'सभी गाँव';

  @override
  String get reportFilterAsOf => 'इस तारीख तक';

  @override
  String get reportExportPdf => 'PDF';

  @override
  String get reportExportExcel => 'Excel';

  @override
  String get reportExportCsv => 'CSV';

  @override
  String get reportPrint => 'प्रिंट';

  @override
  String get reportExportLocked => 'एक्सपोर्ट के लिए वित्त अनुमति चाहिए';

  @override
  String get reportRestricted => 'इस रिपोर्ट के लिए वित्त अनुमति चाहिए';

  @override
  String reportRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पंक्तियाँ',
    );
    return '$_temp0';
  }

  @override
  String get reportEmpty => 'इन फ़िल्टर के लिए कुछ नहीं है';

  @override
  String reportExportSaved(String name) {
    return '$name सेव हुई';
  }

  @override
  String reportExportFailed(String error) {
    return 'एक्सपोर्ट नहीं हुआ: $error';
  }

  @override
  String get reportStatementsHelp =>
      'गाँव के हर किसान का विवरण एक PDF में, हर एक नए पन्ने से शुरू।';

  @override
  String reportStatementsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किसान',
    );
    return '$_temp0';
  }

  @override
  String get reportStatementsPdf => 'विवरण PDF';

  @override
  String get teamTitle => 'यूज़र और अनुमतियाँ';

  @override
  String get teamTabPeople => 'लोग';

  @override
  String get teamTabDevices => 'डिवाइस';

  @override
  String get teamInvite => 'किसी को जोड़ें';

  @override
  String get teamNoAccess => 'यूज़र सिर्फ़ मालिक संभाल सकता है।';

  @override
  String get teamYou => 'आप';

  @override
  String get teamInactive => 'बंद किया गया';

  @override
  String teamDevicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count डिवाइस',
    );
    return '$_temp0';
  }

  @override
  String get teamPendingInvites => 'जुड़ने का इंतज़ार';

  @override
  String teamInviteExpires(String date) {
    return '$date को खत्म';
  }

  @override
  String get teamInviteExpired => 'खत्म हो गया';

  @override
  String get teamInviteCancel => 'न्योता रद्द करें';

  @override
  String get teamInviteCancelled => 'न्योता रद्द हुआ';

  @override
  String get teamEmptyPeople => 'अभी यहाँ कोई नहीं।';

  @override
  String get teamEmptyDevices => 'अभी कोई डिवाइस नहीं।';

  @override
  String get teamRole => 'भूमिका';

  @override
  String get teamPermissions => 'वे क्या कर सकते हैं';

  @override
  String get teamPermissionsHelp =>
      'इस व्यक्ति के लिए अनुमति चालू या बंद करें। बिंदु का मतलब भूमिका के डिफ़ॉल्ट से बदलाव है।';

  @override
  String get teamPermissionChanged => 'भूमिका के डिफ़ॉल्ट से अलग';

  @override
  String get teamPermissionSensitive => 'ताक़तवर: सोच-समझकर दें';

  @override
  String get teamOwnerAll => 'मालिक सब कुछ कर सकता है। इसे बदला नहीं जा सकता।';

  @override
  String get teamDeviceLimit => 'अनुमत डिवाइस';

  @override
  String get teamSave => 'बदलाव सेव करें';

  @override
  String get teamSaved => 'सेव हुआ';

  @override
  String get teamDeactivate => 'बंद करें';

  @override
  String get teamReactivate => 'फिर चालू करें';

  @override
  String teamDeactivateTitle(String name) {
    return '$name को बंद करें?';
  }

  @override
  String get teamDeactivateBody =>
      'वे इस कारोबार को नहीं खोल पाएँगे और उनके डिवाइस से डेटा हट जाएगा। उनकी पुरानी एंट्री बही में रहेगी।';

  @override
  String get teamDeactivated => 'बंद किया गया';

  @override
  String get teamReactivated => 'फिर चालू हुआ';

  @override
  String get teamErrLastOwner =>
      'कारोबार में कम से कम एक चालू मालिक रहना ज़रूरी है।';

  @override
  String get teamErrProtected =>
      'मालिक को सिर्फ़ मालिक बदल सकता है, और आप अपनी पहुँच खुद नहीं बदल सकते।';

  @override
  String get teamErrNotFound => 'यह व्यक्ति नहीं मिला।';

  @override
  String get teamDeviceThis => 'यह डिवाइस';

  @override
  String teamDeviceLastSeen(String when) {
    return 'आखिरी बार $when';
  }

  @override
  String get teamDeviceNeverSeen => 'अभी तक नहीं दिखा';

  @override
  String get teamDeviceRevoke => 'हटाएँ';

  @override
  String get teamDeviceRevoked => 'हटाया गया';

  @override
  String teamRevokeTitle(String code) {
    return 'डिवाइस $code हटाएँ?';
  }

  @override
  String get teamRevokeBody =>
      'यह सिंक करना बंद कर देगा और इसका ऐप बंद हो जाएगा। ऑफ़लाइन किए बदलाव अस्वीकार होंगे। इसे वापस नहीं किया जा सकता; व्यक्ति नया डिवाइस जोड़ सकता है।';

  @override
  String get teamRevokeDone => 'डिवाइस हटाया गया';

  @override
  String get teamErrThisDevice => 'जिस डिवाइस पर आप हैं उसे नहीं हटा सकते।';

  @override
  String get permission_partiesManage => 'पार्टी देखें और जोड़ें';

  @override
  String get permission_arrivalsManage => 'आवक और लॉट';

  @override
  String get permission_paymentsCreate => 'भुगतान दर्ज करें';

  @override
  String get permission_entriesReverse => 'पुरानी एंट्री बदलें या उलटें';

  @override
  String get permission_loansManage => 'कर्ज़ दें, ब्याज बदलें';

  @override
  String get permission_financeView => 'बैंक विवरण, मुनाफ़ा, रिपोर्ट एक्सपोर्ट';

  @override
  String get permission_adminManage => 'यूज़र, मॉड्यूल, सब्सक्रिप्शन';

  @override
  String get permission_masterDelete => 'पार्टी व अन्य मास्टर डेटा हटाएँ';

  @override
  String get permission_settingsManage => 'पूरे कारोबार की सेटिंग';

  @override
  String get permission_auditView => 'ऑडिट लॉग देखें';

  @override
  String get inviteTitle => 'किसी को जोड़ें';

  @override
  String get invitePhone => 'मोबाइल नंबर';

  @override
  String get inviteName => 'नाम (वैकल्पिक)';

  @override
  String get inviteChannel => 'भेजें';

  @override
  String get inviteChannelWhatsapp => 'व्हाट्सऐप';

  @override
  String get inviteChannelSms => 'SMS';

  @override
  String get inviteSend => 'न्योता भेजें';

  @override
  String get inviteErrPhone => 'सही 10 अंकों का मोबाइल नंबर डालें।';

  @override
  String get inviteErrRole =>
      'इस भूमिका को न्योता नहीं दिया जा सकता। मालिक न्योते से नहीं जुड़ते।';

  @override
  String get inviteErrAlreadyMember => 'यह व्यक्ति पहले से आपकी टीम में है।';

  @override
  String get inviteErrAlreadyInvited =>
      'इस नंबर को पहले से न्योता भेजा जा चुका है।';

  @override
  String get inviteErrNotAllowed => 'लोगों को सिर्फ़ मालिक जोड़ सकता है।';

  @override
  String get inviteErrOffline =>
      'न्योता भेजने के लिए इंटरनेट चाहिए। जुड़कर फिर कोशिश करें।';

  @override
  String get inviteErrFailed => 'न्योता नहीं बन सका। फिर कोशिश करें।';

  @override
  String inviteSentWhatsapp(String phone) {
    return '$phone को व्हाट्सऐप पर न्योता भेजा गया।';
  }

  @override
  String inviteSentSms(String phone) {
    return '$phone को SMS से न्योता भेजा गया।';
  }

  @override
  String get inviteNotSentTitle => 'न्योता सेव हुआ: खुद भेजें';

  @override
  String inviteNotSentBody(String phone) {
    return 'कोई मैसेज सेवा चालू नहीं है, इसलिए कुछ नहीं भेजा गया। यह संदेश कॉपी करके $phone को भेजें। उस नंबर से साइन इन करते ही वे जुड़ जाएँगे।';
  }

  @override
  String get inviteCopy => 'संदेश कॉपी करें';

  @override
  String get inviteCopied => 'कॉपी हुआ';

  @override
  String get deviceRevokedTitle => 'यह डिवाइस हटा दिया गया';

  @override
  String get deviceRevokedBody =>
      'मालिक ने इस डिवाइस को हटा दिया है। यहाँ से अब कुछ सेव नहीं हो सकता। ऑफ़लाइन किए बदलाव स्वीकार नहीं हुए।';

  @override
  String get deviceRevokedSetupAgain => 'इस डिवाइस को फिर से जोड़ें';

  @override
  String get tenantPickerCheckInvites => 'न्योते देखें';

  @override
  String get tenantPickerNoInvites =>
      'आपके नंबर के लिए अभी कोई न्योता नहीं मिला।';

  @override
  String get tenantPickerInvitesOffline =>
      'न्योते देखने के लिए इंटरनेट से जुड़ें।';

  @override
  String deviceSetupLimit(String business) {
    return 'इस अकाउंट के $business में सारे डिवाइस इस्तेमाल हो चुके हैं। मालिक से कहें कि कोई पुराना हटा दे।';
  }

  @override
  String deviceSetupRevoked(String business) {
    return 'इस डिवाइस को $business के मालिक ने हटा दिया है।';
  }

  @override
  String get auditTitle => 'ऑडिट लॉग';

  @override
  String get auditNoAccess => 'ऑडिट लॉग सिर्फ़ मालिक देख सकता है।';

  @override
  String get auditFilterUser => 'व्यक्ति';

  @override
  String get auditFilterTable => 'रिकॉर्ड का प्रकार';

  @override
  String get auditAllUsers => 'सब';

  @override
  String get auditAllTables => 'सब रिकॉर्ड';

  @override
  String get auditOnlyMoney => 'सिर्फ़ रकम के बदलाव और उलटाव';

  @override
  String get auditEmpty => 'कोई एंट्री नहीं मिली।';

  @override
  String get auditShowMore => 'और दिखाएँ';

  @override
  String get auditBadgeMoneyEdit => 'रकम बदली';

  @override
  String get auditBadgeReversal => 'उलटाव';

  @override
  String auditByUser(String name, String role) {
    return '$name · $role';
  }

  @override
  String auditOnDevice(String code) {
    return 'डिवाइस $code';
  }

  @override
  String get auditSystem => 'सिस्टम';

  @override
  String auditMoreFields(int count) {
    return '+$count और';
  }

  @override
  String get auditEmptyValue => '—';

  @override
  String get auditYes => 'हाँ';

  @override
  String get auditNo => 'नहीं';

  @override
  String get auditAction_insert => 'जोड़ा';

  @override
  String get auditAction_update => 'बदला';

  @override
  String get auditAction_reverse => 'उलटा';

  @override
  String get auditAction_soft_delete => 'हटाया';

  @override
  String get auditAction_restore => 'वापस लाया';

  @override
  String get auditTable_ledger_entries => 'खाता एंट्री';

  @override
  String get auditTable_payments => 'भुगतान';

  @override
  String get auditTable_cash_bank_entries => 'नकद / बैंक लाइन';

  @override
  String get auditTable_lots => 'लॉट';

  @override
  String get auditTable_parties => 'पार्टी';

  @override
  String get auditTable_party_roles => 'पार्टी की भूमिका';

  @override
  String get auditTable_crops => 'फसल';

  @override
  String get auditTable_bank_accounts => 'बैंक खाता';

  @override
  String get auditTable_settings => 'सेटिंग';

  @override
  String get auditTable_tenant_members => 'टीम सदस्य';

  @override
  String get auditTable_member_invites => 'न्योता';

  @override
  String get auditTable_devices => 'डिवाइस';

  @override
  String get auditField_amount_paise => 'रकम';

  @override
  String get auditField_gross => 'कुल मूल्य';

  @override
  String get auditField_commission => 'कमीशन';

  @override
  String get auditField_net_to_farmer => 'किसान को शुद्ध';

  @override
  String get auditField_buyer_total => 'खरीदार का कुल';

  @override
  String get auditField_rate_paise_per_qtl => 'भाव प्रति क्विंटल';

  @override
  String get auditField_qtl_milli => 'क्विंटल';

  @override
  String get auditField_status => 'स्थिति';

  @override
  String get auditField_role => 'भूमिका';

  @override
  String get auditField_is_active => 'चालू';

  @override
  String get auditField_device_limit => 'अनुमत डिवाइस';

  @override
  String get auditField_custom_permissions => 'अनुमति में बदलाव';

  @override
  String get auditField_revoked_at => 'हटाने का समय';

  @override
  String get auditField_phone => 'मोबाइल';

  @override
  String get auditField_name => 'नाम';

  @override
  String get auditField_cheque_status => 'चेक';

  @override
  String get auditField_entry_date => 'तारीख';

  @override
  String get auditField_side => 'पक्ष';

  @override
  String get auditField_direction => 'दिशा';
}
