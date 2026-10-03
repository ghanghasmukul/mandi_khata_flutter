import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/update/app_version.dart';
import 'package:mandi_khata_app/core/update/update_banner.dart';
import 'package:mandi_khata_app/core/update/update_checker.dart';
import 'package:mandi_khata_app/core/update/update_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

import '../../helpers/fakes.dart';

Future<AppPrefs> pump(
  WidgetTester t,
  UpdateStatus status, {
  Map<String, Object> prefs = const {},
}) async {
  final appPrefs = await makePrefs(prefs);
  await t.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        appPrefsProvider.overrideWithValue(appPrefs),
        updateStatusProvider.overrideWith((ref) async => status),
      ],
      child: MaterialApp(
        theme: MkTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Column(children: [UpdateBanner()])),
      ),
    ),
  );
  await t.pumpAndSettle();
  return appPrefs;
}

const available = UpdateAvailable(
  latest: AppVersion(1, 2, 0),
  url: 'https://example.test/x.exe',
  required: false,
);

void main() {
  testWidgets('nothing is drawn when up to date or the check failed', (
    t,
  ) async {
    await pump(t, const UpdateNone());
    expect(find.byKey(const ValueKey('update-banner')), findsNothing);
    await pump(t, const UpdateCheckFailed('offline'));
    expect(find.byKey(const ValueKey('update-banner')), findsNothing);
  });

  testWidgets('an optional update can be put off, and stays off', (t) async {
    final prefs = await pump(t, available);
    expect(find.text('Mandi Khata 1.2.0 is available'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    await t.tap(find.text('Later'));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('update-banner')), findsNothing);
    expect(prefs.dismissedUpdate, '1.2.0');

    // Next start: still hidden for 1.2.0 ...
    await pump(t, available, prefs: {'ui.dismissedUpdate': '1.2.0'});
    expect(find.byKey(const ValueKey('update-banner')), findsNothing);
    // ... but a newer release shows it again.
    await pump(
      t,
      const UpdateAvailable(
        latest: AppVersion(1, 3, 0),
        url: 'https://example.test/y.exe',
        required: false,
      ),
      prefs: {'ui.dismissedUpdate': '1.2.0'},
    );
    expect(find.text('Mandi Khata 1.3.0 is available'), findsOneWidget);
  });

  testWidgets('a required update cannot be dismissed', (t) async {
    await pump(
      t,
      const UpdateAvailable(
        latest: AppVersion(1, 2, 0),
        url: 'https://example.test/x.exe',
        required: true,
      ),
      prefs: {'ui.dismissedUpdate': '1.2.0'},
    );
    expect(
      find.text(
        'Please update Mandi Khata to 1.2.0. '
        'This version is no longer supported.',
      ),
      findsOneWidget,
    );
    expect(find.text('Later'), findsNothing);
    expect(find.text('Download'), findsOneWidget);
  });
}
