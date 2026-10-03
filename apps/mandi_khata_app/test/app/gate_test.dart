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

    test('diagnostics ships in release, so it is guarded', () {
      expect(redirectFor(GateStep.signedOut, '/dev/diagnostics'), '/login');
      expect(redirectFor(GateStep.locked, '/dev/diagnostics'), '/lock');
      expect(redirectFor(GateStep.ready, '/dev/diagnostics'), isNull);
    });
  });
}
