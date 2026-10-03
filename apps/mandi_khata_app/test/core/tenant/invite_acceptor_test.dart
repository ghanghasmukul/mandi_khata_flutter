import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/tenant/invite_acceptor.dart';

import '../../helpers/fakes.dart';

class _FakeAcceptor implements InviteAcceptor {
  int calls = 0;
  List<String> joins = const [];
  Exception? failure;

  @override
  Future<List<String>> accept() async {
    calls++;
    final f = failure;
    if (f != null) throw f;
    return joins;
  }
}

void main() {
  late AppPrefs prefs;
  late FakeAuthRepository auth;
  late _FakeAcceptor acceptor;

  setUp(() async {
    prefs = await makePrefs();
    await prefs.setDataOwnerUserId(userA.id);
    auth = FakeAuthRepository();
    acceptor = _FakeAcceptor();
  });

  ProviderContainer container() => ProviderContainer.test(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      appPrefsProvider.overrideWithValue(prefs),
      localDataWiperProvider.overrideWithValue(() async {}),
      inviteAcceptorProvider.overrideWithValue(acceptor),
    ],
  );

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('signed out: nothing is asked of the server', () async {
    final c = container()..read(inviteSyncProvider);
    await settle();
    expect(acceptor.calls, 0);
    expect(await c.read(inviteSyncProvider.notifier).check(), isEmpty);
    expect(acceptor.calls, 0);
  });

  test('signing in accepts invitations once', () async {
    final c = container()..listen(inviteSyncProvider, (_, _) {});
    auth.emit(userA);
    await settle();
    await settle();
    expect(c.read(sessionProvider), isA<SignedIn>());
    expect(acceptor.calls, 1);
  });

  test('already signed in at launch: checked once at start', () async {
    auth = FakeAuthRepository(userA);
    container().listen(inviteSyncProvider, (_, _) {});
    await settle();
    expect(acceptor.calls, 1);
  });

  test('check() returns the businesses joined', () async {
    auth = FakeAuthRepository(userA);
    final c = container()..listen(inviteSyncProvider, (_, _) {});
    await settle();
    acceptor.joins = ['t1'];
    expect(await c.read(inviteSyncProvider.notifier).check(), ['t1']);
  });

  test('offline: check() says so (null) and never throws', () async {
    auth = FakeAuthRepository(userA);
    acceptor.failure = Exception('no network');
    final c = container()..listen(inviteSyncProvider, (_, _) {});
    await settle();
    expect(await c.read(inviteSyncProvider.notifier).check(), isNull);
  });
}
