// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get syncOff => 'Sync off';

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String get syncSyncedJustNow => 'Synced · just now';

  @override
  String syncSyncedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Synced · $count min ago',
      one: 'Synced · 1 min ago',
    );
    return '$_temp0';
  }

  @override
  String syncSyncedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Synced · $count hr ago',
      one: 'Synced · 1 hr ago',
    );
    return '$_temp0';
  }

  @override
  String get syncOffline => 'Offline';

  @override
  String syncOfflineQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Offline · $count queued',
      one: 'Offline · 1 queued',
    );
    return '$_temp0';
  }

  @override
  String syncErrorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sync error · $count changes rejected',
      one: 'Sync error · 1 change rejected',
    );
    return '$_temp0';
  }

  @override
  String get syncErrorsTitle => 'Changes the server rejected';

  @override
  String get syncErrorsBody =>
      'These changes were not saved online. Everything else keeps syncing.';

  @override
  String get syncErrorsDismiss => 'Dismiss all';

  @override
  String get commonClose => 'Close';
}
