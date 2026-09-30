import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

import '../../helpers/fakes.dart';

void main() {
  group('AppLanguage', () {
    late AppPrefs prefs;
    late StreamController<String?> profile;

    setUp(() async {
      prefs = await makePrefs();
      profile = StreamController.broadcast();
    });

    tearDown(() => profile.close());

    ProviderContainer container() => ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        appPrefsProvider.overrideWithValue(prefs),
        localDataWiperProvider.overrideWithValue(() async {}),
        profileLanguageProvider.overrideWith((ref) => profile.stream),
      ],
    )..listen(appLanguageProvider, (_, _) {});

    test('nothing chosen: follow the device (null)', () {
      expect(container().read(appLanguageProvider), isNull);
    });

    test("the profile's language follows the user to a new device", () async {
      final c = container();
      profile.add('pa');
      await pumpEventQueue();
      expect(c.read(appLanguageProvider), 'pa');
    });

    test('a choice made on this install wins and survives sign-out', () async {
      final c = container();
      await c.read(appLanguageProvider.notifier).set('hi');
      expect(c.read(appLanguageProvider), 'hi');
      profile.add('pa');
      await pumpEventQueue();
      expect(c.read(appLanguageProvider), 'hi');

      await prefs.clearAll(); // what sign-out does
      expect(prefs.uiLanguage, 'hi');
    });

    test('only en / hi / pa', () async {
      final c = container();
      expect(
        () => c.read(appLanguageProvider.notifier).set('ta'),
        throwsArgumentError,
      );
      profile.add('ta');
      await pumpEventQueue();
      expect(c.read(appLanguageProvider), isNull);
    });
  });

  group('AppFormat keeps Western digits', () {
    for (final lang in ['en', 'hi', 'pa']) {
      testWidgets(lang, (tester) async {
        late String text;
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(lang),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                text = AppFormat.dateTime(
                  context,
                  DateTime(2026, 9, 30, 14, 5),
                );
                return const SizedBox();
              },
            ),
          ),
        );
        expect(text, contains('2026'));
        expect(text, contains('30'));
        expect(text, isNot(matches(RegExp('[०-९੦-੯]'))));
      });
    }
  });
}
