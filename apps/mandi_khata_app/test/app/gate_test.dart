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

    test('developer pages are never redirected', () {
      for (final step in GateStep.values) {
        expect(redirectFor(step, '/dev/sync'), isNull, reason: '$step');
      }
    });
  });
}
