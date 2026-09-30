import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';

import '../../helpers/fakes.dart';

void main() {
  late AppPrefs prefs;
  late int wipes;
  StateError? wipeError;

  setUp(() async {
    prefs = await makePrefs();
    wipes = 0;
    wipeError = null;
  });

  ProviderContainer container(FakeAuthRepository auth) =>
      ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          appPrefsProvider.overrideWithValue(prefs),
          localDataWiperProvider.overrideWithValue(() async {
            wipes++;
            if (wipeError != null) throw wipeError!;
          }),
        ],
      );

  test('no cached session: signed out', () {
    final c = container(FakeAuthRepository());
    expect(c.read(sessionProvider), isA<SignedOut>());
  });

  test('cached session of the data owner opens without touching data '
      '(offline launch)', () async {
    await prefs.setDataOwnerUserId(userA.id);
    await prefs.setLastTenantId('t1');
    final c = container(FakeAuthRepository(userA));

    final state = c.read(sessionProvider);
    expect(state, isA<SignedIn>());
    expect((state as SignedIn).user, userA);
    await pumpEventQueue();
    expect(wipes, 0);
    expect(prefs.lastTenantId, 't1');
  });

  test('a different user clears the previous local data first', () async {
    await prefs.setDataOwnerUserId(userA.id);
    await prefs.setLastTenantId('t1');
    final auth = FakeAuthRepository();
    final c = container(auth);
    final seen = <SessionState>[];
    c.listen(sessionProvider, (_, s) => seen.add(s), fireImmediately: true);

    auth.emit(userB);
    await pumpEventQueue();

    expect(seen.map((s) => s.runtimeType), [
      SignedOut,
      SessionPreparing,
      SignedIn,
    ]);
    expect(wipes, 1);
    expect(prefs.lastTenantId, isNull);
    expect(prefs.dataOwnerUserId, userB.id);
  });

  test('first launch with an unknown owner also starts clean', () async {
    final c = container(FakeAuthRepository(userA));
    expect(c.read(sessionProvider), isA<SessionPreparing>());
    await pumpEventQueue();
    expect(c.read(sessionProvider), isA<SignedIn>());
    expect(wipes, 1);
    expect(prefs.dataOwnerUserId, userA.id);
  });

  test('the same user signing back in keeps their unsynced data', () async {
    await prefs.setDataOwnerUserId(userA.id);
    await prefs.setLastTenantId('t1');
    final auth = FakeAuthRepository(userA);
    final c = container(auth)..listen(sessionProvider, (_, _) {});

    auth.emit(null); // e.g. refresh token revoked
    await pumpEventQueue();
    expect(c.read(sessionProvider), isA<SignedOut>());
    auth.emit(userA);
    await pumpEventQueue();

    expect(c.read(sessionProvider), isA<SignedIn>());
    expect(wipes, 0);
    expect(prefs.lastTenantId, 't1');
  });

  test('if clearing fails the new user is signed out, never shown old '
      'data', () async {
    await prefs.setDataOwnerUserId(userA.id);
    wipeError = StateError('disk full');
    final auth = FakeAuthRepository();
    final c = container(auth)..listen(sessionProvider, (_, _) {});

    auth.emit(userB);
    await pumpEventQueue();

    expect(c.read(sessionProvider), isA<SignedOut>());
    expect(auth.calls, contains('signOut'));
    expect(prefs.dataOwnerUserId, userA.id);
  });
}
