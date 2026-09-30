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
}
