import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_language.g.dart';

final _log = Logger('i18n');

/// The three UI languages, with the short labels the top bar shows.
const appLanguages = [
  MkLanguage(code: 'en', label: 'EN'),
  MkLanguage(code: 'hi', label: 'हिं'),
  MkLanguage(code: 'pa', label: 'ਪੰ'),
];

const _codes = {'en', 'hi', 'pa'};

/// The signed-in user's synced `app_users.preferred_language`.
@riverpod
Stream<String?> profileLanguage(Ref ref) async* {
  final session = ref.watch(sessionProvider);
  if (session is! SignedIn) {
    yield null;
    return;
  }
  final db = await ref.watch(powerSyncDatabaseProvider.future);
  yield* db
      .watch(
        'SELECT preferred_language FROM app_users WHERE id = ?',
        parameters: [session.user.id],
        triggerOnTables: const {'app_users'},
      )
      .map(
        (rows) =>
            rows.isEmpty ? null : rows.first['preferred_language'] as String?,
      );
}

/// Language code for the UI, or null to follow the device (MaterialApp then
/// picks the closest of en / hi / pa).
///
/// Order: the choice made on this install → the user's profile language
/// (so it follows them to a new phone) → the device.
@Riverpod(keepAlive: true)
class AppLanguage extends _$AppLanguage {
  @override
  String? build() {
    final explicit = ref.read(appPrefsProvider).uiLanguage;
    if (explicit != null && _codes.contains(explicit)) return explicit;
    final profile = ref.watch(profileLanguageProvider).value;
    return profile != null && _codes.contains(profile) ? profile : null;
  }

  /// Switches the UI now, remembers it on this install and, when signed
  /// in, saves it to the profile (synced; works offline).
  Future<void> set(String code) async {
    if (!_codes.contains(code)) throw ArgumentError.value(code, 'code');
    await ref.read(appPrefsProvider).setUiLanguage(code);
    state = code;
    final session = ref.read(sessionProvider);
    if (session is! SignedIn) return;
    try {
      final db = await ref.read(powerSyncDatabaseProvider.future);
      await db.execute(
        'UPDATE app_users SET preferred_language = ?, updated_at = ? '
        'WHERE id = ?',
        [code, DateTime.now().toUtc().toIso8601String(), session.user.id],
      );
    } on Object catch (e) {
      // The UI already switched; the profile catches up next time.
      _log.warning('Could not save profile language: $e');
    }
  }
}

/// Dates and times in the UI language, always with Western digits
/// (0–9), as mandi documents use them.
abstract final class AppFormat {
  static String dateTime(BuildContext context, DateTime t) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return (DateFormat.yMMMd(
      locale,
    ).add_jm()..useNativeDigits = false).format(t.toLocal());
  }

  static String date(BuildContext context, DateTime t) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return (DateFormat.yMMMd(
      locale,
    )..useNativeDigits = false).format(t.toLocal());
  }
}
