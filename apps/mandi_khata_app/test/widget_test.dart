import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/auth/app_lock/app_lock.dart';
import 'package:mandi_khata_app/core/auth/app_lock/pin_hasher.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/auth/sign_out_service.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/device_registrar.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/main.dart';

import 'helpers/fakes.dart';

const gupta = Membership(
  tenantId: 't-gupta',
  tenantName: 'Gupta Trading Co.',
  mandiName: 'Sirsa',
  role: MemberRole.owner,
);
const sharma = Membership(
  tenantId: 't-sharma',
  tenantName: 'Sharma Arhat Agency',
  role: MemberRole.munshi,
);

void main() {
  late AppPrefs prefs;
  late FakeAuthRepository auth;
  late FakeRegistrar registrar;
  late List<Membership> memberships;
  late int queued;

  setUp(() async {
    prefs = await makePrefs();
    auth = FakeAuthRepository();
    registrar = FakeRegistrar();
    memberships = const [gupta];
    queued = 0;
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          appPrefsProvider.overrideWithValue(prefs),
          localDataWiperProvider.overrideWithValue(() async {}),
          deviceRegistrarProvider.overrideWithValue(registrar),
          myMembershipsProvider.overrideWith(
            (ref) => Stream.value(memberships),
          ),
          hasSyncedProvider.overrideWithValue(true),
          appLockSupportedProvider.overrideWithValue(true),
          signOutServiceProvider.overrideWith(
            (ref) => SignOutService(
              queueCount: () => Stream.value(queued),
              wipeLocalData: () async {},
              auth: auth,
              prefs: prefs,
            ),
          ),
        ],
        child: const MandiKhataApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// PIN checks run in an isolate (real async).
  Future<void> settleIsolate(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('first sign-in: phone OTP → business → PIN prompt → home', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Sign in to Mandi Khata'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('login-phone')), '12345');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a 10-digit Indian mobile number'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-phone')),
      '98140 22110',
    );
    await tester.tap(find.text('Send code'));
    await tester.pump();
    expect(auth.calls, ['sendOtp:+919814022110']);
    expect(find.text('Code sent to +91 98140 22110'), findsOneWidget);
    expect(find.text('Resend code in 30s'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('login-otp')), '123456');
    await tester.tap(find.text('Verify and sign in'));
    await tester.pumpAndSettle();

    // One business: picked automatically, device registered.
    expect(registrar.calls.single.tenantId, gupta.tenantId);
    expect(find.text('Set an app PIN'), findsOneWidget);

    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(find.text('Gupta Trading Co.'), findsOneWidget);
    expect(find.text('This device: A1'), findsOneWidget);
    expect(find.text('Sync off'), findsOneWidget);
  });

  testWidgets('wrong OTP shows the server reason', (tester) async {
    await pumpApp(tester);
    await tester.enterText(
      find.byKey(const ValueKey('login-phone')),
      '9814022110',
    );
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    auth.failNext = const AuthFailure(AuthFailureKind.invalidOtp);
    await tester.enterText(find.byKey(const ValueKey('login-otp')), '000000');
    await tester.tap(find.text('Verify and sign in'));
    await tester.pumpAndSettle();
    expect(find.text('That code is wrong or has expired.'), findsOneWidget);
    // Let the resend countdown finish so no timer is left pending.
    await tester.pump(const Duration(seconds: 31));
  });

  testWidgets('several businesses: the user picks one', (tester) async {
    memberships = const [gupta, sharma];
    await prefs.setDataOwnerUserId(userA.id);
    await prefs.setPinPromptSkipped(skipped: true);
    auth = FakeAuthRepository(userA);
    await pumpApp(tester);

    expect(find.text('Choose a business'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Munshi'), findsOneWidget);
    await tester.tap(find.text('Sharma Arhat Agency'));
    await tester.pumpAndSettle();

    expect(registrar.calls.single.tenantId, sharma.tenantId);
    expect(find.text('Sharma Arhat Agency'), findsOneWidget);
    expect(find.text('This device: A1'), findsOneWidget);
  });

  testWidgets('cold start with a PIN opens the lock screen', (tester) async {
    await prefs.setDataOwnerUserId(userA.id);
    await prefs.setLastTenantId(gupta.tenantId);
    await prefs.setDevice(gupta.tenantId, (id: 'dev-1', code: 'W1'));
    await prefs.setPin(PinHasher.create('2580', iterations: 10));
    auth = FakeAuthRepository(userA);
    await pumpApp(tester);
    expect(find.text('Enter your PIN'), findsOneWidget);

    for (final d in ['1', '1', '1', '1']) {
      await tester.tap(find.text(d));
    }
    await settleIsolate(tester);
    expect(find.text('Wrong PIN'), findsOneWidget);

    for (final d in ['2', '5', '8', '0']) {
      await tester.tap(find.text(d));
    }
    await settleIsolate(tester);
    expect(find.text('Gupta Trading Co.'), findsOneWidget);
    expect(find.text('This device: W1'), findsOneWidget);
  });

  testWidgets('sign-out warns about changes not uploaded yet', (tester) async {
    await prefs.setDataOwnerUserId(userA.id);
    await prefs.setLastTenantId(gupta.tenantId);
    await prefs.setDevice(gupta.tenantId, (id: 'dev-1', code: 'W1'));
    await prefs.setPinPromptSkipped(skipped: true);
    auth = FakeAuthRepository(userA);
    queued = 3;
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining("3 changes haven't been uploaded yet"),
      findsOneWidget,
    );

    await tester.tap(find.text('Sign out and delete them'));
    await tester.pumpAndSettle();
    expect(auth.calls, ['signOut']);
    expect(find.text('Sign in to Mandi Khata'), findsOneWidget);
    expect(prefs.lastTenantId, isNull);
  });
}
