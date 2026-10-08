import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_scan.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

Widget host({bool web = false, TargetPlatform? platform}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: PosScanButton(onCode: (_) {}, web: web, platform: platform),
  ),
);

void main() {
  group('cameraScanSupported', () {
    test('only Android and iOS, never web', () {
      expect(
        cameraScanSupported(web: false, platform: TargetPlatform.android),
        isTrue,
      );
      expect(
        cameraScanSupported(web: false, platform: TargetPlatform.iOS),
        isTrue,
      );
      expect(
        cameraScanSupported(web: false, platform: TargetPlatform.windows),
        isFalse,
      );
      expect(
        cameraScanSupported(web: false, platform: TargetPlatform.macOS),
        isFalse,
      );
      expect(
        cameraScanSupported(web: false, platform: TargetPlatform.linux),
        isFalse,
      );
      expect(
        cameraScanSupported(web: true, platform: TargetPlatform.android),
        isFalse,
      );
    });
  });

  group('PosScanButton', () {
    testWidgets('hidden on desktop and web', (tester) async {
      for (final p in [TargetPlatform.windows, TargetPlatform.macOS]) {
        await tester.pumpWidget(host(platform: p));
        expect(find.byKey(const ValueKey('pos-scan')), findsNothing);
      }
      await tester.pumpWidget(
        host(web: true, platform: TargetPlatform.android),
      );
      expect(find.byKey(const ValueKey('pos-scan')), findsNothing);
    });

    testWidgets('shown on Android with a 48 px target', (tester) async {
      await tester.pumpWidget(host(platform: TargetPlatform.android));
      final f = find.byKey(const ValueKey('pos-scan'));
      expect(f, findsOneWidget);
      expect(tester.getSize(f).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(f).height, greaterThanOrEqualTo(48));
    });
  });

  group('ScanDebouncer', () {
    final t0 = DateTime(2026, 1, 1, 10);

    test('same code inside 1.5 s is ignored, after it is accepted', () {
      final d = ScanDebouncer();
      expect(d.accept('8901', t0), isTrue);
      expect(
        d.accept('8901', t0.add(const Duration(milliseconds: 1000))),
        isFalse,
      );
      expect(
        d.accept('8901', t0.add(const Duration(milliseconds: 1499))),
        isFalse,
      );
      expect(
        d.accept('8901', t0.add(const Duration(milliseconds: 1500))),
        isTrue,
      );
    });

    test('a different code is accepted immediately; blank is ignored', () {
      final d = ScanDebouncer();
      expect(d.accept('8901', t0), isTrue);
      expect(
        d.accept('8902', t0.add(const Duration(milliseconds: 100))),
        isTrue,
      );
      expect(d.accept('  ', t0), isFalse);
    });
  });
}
