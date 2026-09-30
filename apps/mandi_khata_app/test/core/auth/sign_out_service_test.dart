import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/auth/sign_out_service.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';

void main() {
  late AppPrefs prefs;
  late FakeAuthRepository auth;
  late StreamController<int> queue;
  late List<String> order;

  setUp(() async {
    prefs = await makePrefs();
    auth = FakeAuthRepository(userA);
    queue = StreamController.broadcast();
    order = [];
  });

  tearDown(() => queue.close());

  SignOutService service() => SignOutService(
    queueCount: () => queue.stream,
    wipeLocalData: () async => order.add('wipe'),
    auth: auth,
    prefs: prefs,
  );

  test('reports queued changes', () async {
    final pending = service().pendingChanges();
    queue.add(4);
    expect(await pending, 4);
  });

  test('waitForUpload returns true once the queue empties', () async {
    final done = service().waitForUpload();
    queue
      ..add(3)
      ..add(1)
      ..add(0);
    expect(await done, isTrue);
  });

  test('waitForUpload gives up after the timeout', () async {
    final done = service().waitForUpload(
      timeout: const Duration(milliseconds: 20),
    );
    queue.add(2);
    expect(await done, isFalse);
  });

  test('sign-out wipes local data and per-install values, then ends the '
      'session; the Supabase session key is left to the SDK', () async {
    SharedPreferences.setMockInitialValues({'sb-session': 'token'});
    prefs = AppPrefs(await SharedPreferences.getInstance());
    await prefs.setDataOwnerUserId(userA.id);
    await prefs.setLastTenantId('t1');
    await prefs.setDevice('t1', (id: 'd1', code: 'A1'));

    await service().signOut();

    expect(order, ['wipe']);
    expect(auth.calls, ['signOut']);
    expect(auth.currentUser, isNull);
    expect(prefs.dataOwnerUserId, isNull);
    expect(prefs.lastTenantId, isNull);
    expect(prefs.device('t1'), isNull);
    final raw = await SharedPreferences.getInstance();
    expect(raw.getString('sb-session'), 'token');
  });
}
