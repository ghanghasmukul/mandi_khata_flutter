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
}
