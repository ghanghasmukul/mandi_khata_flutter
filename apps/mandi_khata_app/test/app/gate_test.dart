import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/app/gate.dart';

void main() {
  group('redirectFor', () {
    test('signed out: everything goes to /login', () {
      expect(redirectFor(GateStep.signedOut, '/'), '/login');
      expect(redirectFor(GateStep.signedOut, '/select-tenant'), '/login');
      expect(redirectFor(GateStep.signedOut, '/login'), isNull);
    });

    test('preparing a new user: splash', () {
      expect(redirectFor(GateStep.starting, '/login'), '/splash');
      expect(redirectFor(GateStep.starting, '/splash'), isNull);
    });

    test('locked: lock screen, whatever was open', () {
      expect(redirectFor(GateStep.locked, '/'), '/lock');
      expect(redirectFor(GateStep.locked, '/set-pin'), '/lock');
      expect(redirectFor(GateStep.locked, '/lock'), isNull);
    });

    test('no business yet: picker', () {
      expect(redirectFor(GateStep.chooseTenant, '/'), '/select-tenant');
      expect(redirectFor(GateStep.chooseTenant, '/login'), '/select-tenant');
      expect(redirectFor(GateStep.chooseTenant, '/select-tenant'), isNull);
    });

    test('device revoked by the owner: only the blocked page', () {
      expect(redirectFor(GateStep.deviceRevoked, '/'), '/device-revoked');
      expect(redirectFor(GateStep.deviceRevoked, '/team'), '/device-revoked');
      expect(redirectFor(GateStep.deviceRevoked, '/device-revoked'), isNull);
      // Once the device is set up again, the blocked page sends home.
      expect(redirectFor(GateStep.ready, '/device-revoked'), '/');
    });

    test('first run on a lockable device: PIN prompt', () {
      expect(redirectFor(GateStep.setupPin, '/'), '/set-pin');
      expect(redirectFor(GateStep.setupPin, '/set-pin'), isNull);
    });

    test('new business, owner: the setup wizard, then the app', () {
      expect(redirectFor(GateStep.onboarding, '/'), '/onboarding');
      expect(redirectFor(GateStep.onboarding, '/parties'), '/onboarding');
      expect(redirectFor(GateStep.onboarding, '/onboarding'), isNull);
      // Re-running the wizard later is an ordinary page.
      expect(redirectFor(GateStep.ready, '/onboarding'), isNull);
    });

    test('ready: gate pages send home, app pages stay', () {
      for (final page in ['/login', '/splash', '/lock', '/select-tenant']) {
        expect(redirectFor(GateStep.ready, page), '/', reason: page);
      }
      expect(redirectFor(GateStep.ready, '/'), isNull);
      // Changing the PIN from the account menu.
      expect(redirectFor(GateStep.ready, '/set-pin'), isNull);
    });

    test('debug-only developer pages are never redirected', () {
      for (final step in GateStep.values) {
        expect(redirectFor(step, '/dev/sync'), isNull, reason: '$step');
        expect(redirectFor(step, '/dev/gallery'), isNull, reason: '$step');
      }
    });

    test('ended subscription: only export, billing and the picker', () {
      for (final ok in [
        '/billing',
        '/reports',
        '/reports/outstanding',
        '/accounts/tally',
        '/select-tenant',
      ]) {
        expect(redirectFor(GateStep.exportOnly, ok), isNull, reason: ok);
      }
      for (final blocked in ['/', '/parties', '/accounts', '/khata', '/pos']) {
        expect(
          redirectFor(GateStep.exportOnly, blocked),
          '/billing',
          reason: blocked,
        );
      }
      // A look-alike prefix is not the export screen.
      expect(redirectFor(GateStep.exportOnly, '/reports-x'), '/billing');
    });

    test('signup is part of choosing a business, and only then', () {
      expect(redirectFor(GateStep.chooseTenant, '/signup'), isNull);
      expect(redirectFor(GateStep.signedOut, '/signup'), '/login');
      expect(redirectFor(GateStep.locked, '/signup'), '/lock');
    });

    test('a module that is off sends its screens home', () {
      expect(redirectFor(GateStep.ready, '/pos', moduleOff: true), '/');
      expect(redirectFor(GateStep.ready, '/pos'), isNull);
      // Other steps keep their own rule.
      expect(
        redirectFor(GateStep.signedOut, '/pos', moduleOff: true),
        '/login',
      );
    });

    test('diagnostics ships in release, so it is guarded', () {
      expect(redirectFor(GateStep.signedOut, '/dev/diagnostics'), '/login');
      expect(redirectFor(GateStep.locked, '/dev/diagnostics'), '/lock');
      expect(redirectFor(GateStep.ready, '/dev/diagnostics'), isNull);
    });
  });
}
