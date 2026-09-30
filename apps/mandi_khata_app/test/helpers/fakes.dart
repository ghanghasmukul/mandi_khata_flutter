import 'dart:async';

import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/tenant/device_registrar.dart';
import 'package:shared_preferences/shared_preferences.dart';

const userA = AuthUser(id: 'user-a', phone: '919814022110');
const userB = AuthUser(id: 'user-b', phone: '919896033220');

/// In-memory auth: tests drive sign-in / sign-out with [emit].
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository([this._user]);

  AuthUser? _user;
  final _changes = StreamController<AuthUser?>.broadcast();
  final calls = <String>[];
  AuthFailure? failNext;

  void emit(AuthUser? user) {
    _user = user;
    _changes.add(user);
  }

  Future<void> _call(String name, [AuthUser? signsIn]) async {
    calls.add(name);
    final failure = failNext;
    failNext = null;
    if (failure != null) throw failure;
    if (signsIn != null) emit(signsIn);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get userChanges => _changes.stream;

  @override
  Future<void> sendOtp(String phone) => _call('sendOtp:$phone');

  @override
  Future<void> verifyOtp({required String phone, required String code}) =>
      _call('verifyOtp:$phone:$code', userA);

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => _call('email:$email', userA);

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    emit(null);
  }
}

class FakeRegistrar implements DeviceRegistrar {
  final calls = <({String deviceId, String tenantId, String platform})>[];
  DeviceRegistrationException? failWith;
  int _next = 1;

  @override
  Future<String> register({
    required String deviceId,
    required String tenantId,
    required String platform,
  }) async {
    calls.add((deviceId: deviceId, tenantId: tenantId, platform: platform));
    final failure = failWith;
    if (failure != null) throw failure;
    return 'A${_next++}';
  }
}

Future<AppPrefs> makePrefs([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return AppPrefs(await SharedPreferences.getInstance());
}
