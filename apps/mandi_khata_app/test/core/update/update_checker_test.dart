import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mandi_khata_app/core/update/app_version.dart';
import 'package:mandi_khata_app/core/update/update_checker.dart';

const url = 'https://example.test/latest.json';

Map<String, Object?> manifest({
  String version = '1.2.0',
  String? min = '1.0.0',
  Map<String, Object?>? downloads,
}) => {
  'version': version,
  'min_supported': ?min,
  'notes': 'Cheque reminders.',
  'downloads':
      downloads ??
      {
        'windows': 'https://example.test/MandiKhata-Setup-1.2.0.exe',
        'macos': 'https://example.test/MandiKhata-1.2.0.dmg',
        'android': 'https://play.google.com/store/apps/details?id=x',
      },
};

UpdateChecker checker(
  http.Client client, {
  String current = '1.0.0',
  String platform = 'windows',
  String manifestUrl = url,
  Duration timeout = const Duration(seconds: 8),
}) => UpdateChecker(
  client: client,
  manifestUrl: manifestUrl,
  platform: platform,
  current: AppVersion.tryParse(current)!,
  timeout: timeout,
);

http.Client serving(Object body, {int status = 200}) => MockClient(
  (_) async => http.Response.bytes(
    utf8.encode(body is String ? body : jsonEncode(body)),
    status,
  ),
);

void main() {
  group('AppVersion', () {
    test('parses, ignores v prefix and build number', () {
      expect(AppVersion.tryParse('1.4.2'), const AppVersion(1, 4, 2));
      expect(AppVersion.tryParse('v1.4.2+17'), const AppVersion(1, 4, 2));
      expect(AppVersion.tryParse('2'), const AppVersion(2, 0, 0));
      expect(AppVersion.tryParse('1.5'), const AppVersion(1, 5, 0));
      expect(AppVersion.tryParse('banana'), isNull);
      expect(AppVersion.tryParse(null), isNull);
    });

    test('compares numerically, not as text', () {
      expect(
        AppVersion.tryParse('1.10.0')! > AppVersion.tryParse('1.9.0')!,
        true,
      );
      expect(
        AppVersion.tryParse('2.0.0')! > AppVersion.tryParse('1.99.99')!,
        true,
      );
      expect(
        AppVersion.tryParse('1.0.1')! < AppVersion.tryParse('1.0.2')!,
        true,
      );
      expect(AppVersion.tryParse('1.0.0'), AppVersion.tryParse('v1.0.0+5'));
    });
  });

  group('UpdateManifest', () {
    test('reads a full manifest', () {
      final m = UpdateManifest.tryParse(manifest())!;
      expect(m.version, const AppVersion(1, 2, 0));
      expect(m.minSupported, const AppVersion(1, 0, 0));
      expect(m.notes, 'Cheque reminders.');
      expect(m.downloads.keys, ['windows', 'macos', 'android']);
    });

    test('min_supported is optional; blank links are dropped', () {
      final m = UpdateManifest.tryParse(
        manifest(min: null, downloads: {'windows': '', 'macos': 'https://x/y'}),
      )!;
      expect(m.minSupported, const AppVersion(0, 0, 0));
      expect(m.downloads.keys, ['macos']);
    });

    test('rejects things that are not manifests', () {
      expect(UpdateManifest.tryParse(null), isNull);
      expect(UpdateManifest.tryParse([1, 2]), isNull);
      expect(UpdateManifest.tryParse({'version': 'soon'}), isNull);
      expect(UpdateManifest.tryParse(<String, Object?>{}), isNull);
    });
  });

  group('check', () {
    test('a newer version is offered with this platforms link', () async {
      final status = await checker(serving(manifest())).check();
      expect(status, isA<UpdateAvailable>());
      final u = status as UpdateAvailable;
      expect(u.latest, const AppVersion(1, 2, 0));
      expect(u.url, 'https://example.test/MandiKhata-Setup-1.2.0.exe');
      expect(u.required, isFalse);
      expect(u.notes, 'Cheque reminders.');
    });

    test('picks the link of the running platform', () async {
      final mac = await checker(serving(manifest()), platform: 'macos').check();
      expect((mac as UpdateAvailable).url, endsWith('.dmg'));
    });

    test('below min_supported the update is required', () async {
      final status = await checker(serving(manifest(min: '1.1.0'))).check();
      expect((status as UpdateAvailable).required, isTrue);
      final fine = await checker(
        serving(manifest(min: '1.1.0')),
        current: '1.1.0',
      ).check();
      expect((fine as UpdateAvailable).required, isFalse);
    });

    test(
      'same or newer version, or no link for the platform: nothing',
      () async {
        expect(
          await checker(serving(manifest()), current: '1.2.0').check(),
          isA<UpdateNone>(),
        );
        expect(
          await checker(serving(manifest()), current: '1.3.0').check(),
          isA<UpdateNone>(),
        );
        expect(
          await checker(serving(manifest()), platform: 'web').check(),
          isA<UpdateNone>(),
        );
      },
    );

    test('no manifest URL: no request at all', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      });
      expect(await checker(client, manifestUrl: '').check(), isA<UpdateNone>());
      expect(calls, 0);
    });
  });

  group('offline and broken servers degrade quietly', () {
    test('no network', () async {
      final client = MockClient(
        (_) async => throw http.ClientException('offline'),
      );
      expect(await checker(client).check(), isA<UpdateCheckFailed>());
    });

    test('timeout', () async {
      final client = MockClient((_) => Completer<http.Response>().future);
      final status = await checker(
        client,
        timeout: const Duration(milliseconds: 20),
      ).check();
      expect(status, isA<UpdateCheckFailed>());
    });

    test('server error, not JSON, wrong shape', () async {
      expect(
        await checker(serving('oops', status: 503)).check(),
        isA<UpdateCheckFailed>(),
      );
      expect(
        await checker(serving('<html>')).check(),
        isA<UpdateCheckFailed>(),
      );
      expect(
        await checker(serving(<String, Object?>{'hello': 1})).check(),
        isA<UpdateCheckFailed>(),
      );
      expect(await checker(serving('[]')).check(), isA<UpdateCheckFailed>());
    });
  });
}
