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
}
