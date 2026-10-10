import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/features/settings/presentation/whats_new_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

void main() {
  for (final lang in ['en', 'hi', 'pa']) {
    testWidgets('release notes exist and show in $lang', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(lang),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WhatsNewScreen(),
        ),
      );
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)));
      final notes = changelog(l10n);
      expect(notes, isNotEmpty);
      expect(find.byKey(ValueKey('release-${notes.first.version}')), findsOne);
      expect(notes.first.notes.split('\n').length, greaterThan(2));
    });
  }

  test('the three languages differ (not an English copy)', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final hi = await AppLocalizations.delegate.load(const Locale('hi'));
    final pa = await AppLocalizations.delegate.load(const Locale('pa'));
    expect({
      en.changelogV100,
      hi.changelogV100,
      pa.changelogV100,
    }, hasLength(3));
  });
}
