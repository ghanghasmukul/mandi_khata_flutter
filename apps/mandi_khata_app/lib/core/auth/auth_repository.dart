import 'dart:async';

import 'package:flutter/foundation.dart' show immutable;
import 'package:mandi_khata_app/app/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

/// The signed-in person, as far as the app needs to know.
@immutable
class AuthUser {
  const AuthUser({required this.id, this.phone, this.email});

  final String id;
  final String? phone;
  final String? email;

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.id == id &&
      other.phone == phone &&
      other.email == email;

  @override
  int get hashCode => Object.hash(id, phone, email);
}

enum AuthFailureKind {
  /// This build has no Supabase URL / key.
  notConfigured,

  /// No internet, or the server could not be reached.
  network,

  /// Wrong or expired OTP.
  invalidOtp,

  /// Wrong email or password.
  invalidCredentials,

  /// Too many OTPs / attempts; try again later.
  rateLimited,

  /// Phone sign-in is switched off or the SMS could not be sent.
  smsUnavailable,

  unknown,
}

/// Why a sign-in step failed. The UI turns [kind] into a localised message.
class AuthFailure implements Exception {
  const AuthFailure(this.kind, [this.detail]);

  final AuthFailureKind kind;

  /// Server message, for logs only.
  final String? detail;

  @override
  String toString() => 'AuthFailure($kind${detail == null ? '' : ': $detail'})';
}

/// Sign-in and sign-out. Auth is one of the few things allowed online
/// (CLAUDE.md rule 2); everything here fails with [AuthFailure].
abstract interface class AuthRepository {
  /// The cached user, even when their access token has expired offline.
  AuthUser? get currentUser;

  /// Emits whenever the signed-in user changes (null = signed out).
  Stream<AuthUser?> get userChanges;

  /// Sends a 6-digit SMS code to an E.164 number (`+91…`).
  Future<void> sendOtp(String phone);

  Future<void> verifyOtp({required String phone, required String code});

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// Ends the session on this device. Works offline.
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._auth);

  final GoTrueClient _auth;

  static AuthUser? _toUser(User? user) => user == null
      ? null
      : AuthUser(id: user.id, phone: user.phone, email: user.email);

  // `currentSession` (not `currentUser`) because supabase_flutter restores an
  // expired session from disk without clearing it; that must still count as
  // signed in so an offline launch opens the app.
  @override
  AuthUser? get currentUser => _toUser(_auth.currentSession?.user);

  @override
  Stream<AuthUser?> get userChanges => _auth.onAuthStateChange
      // Refresh failures (e.g. offline) arrive as stream errors; they do not
      // sign anyone out, so ignore them here.
      .handleError((Object _) {})
      .map((state) => _toUser(state.session?.user));

  @override
  Future<void> sendOtp(String phone) =>
      _guard(() => _auth.signInWithOtp(phone: phone));

  @override
  Future<void> verifyOtp({required String phone, required String code}) =>
      _guard(
        () => _auth.verifyOTP(phone: phone, token: code, type: OtpType.sms),
      );

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _guard(() => _auth.signInWithPassword(email: email, password: password));

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  static Future<void> _guard(Future<Object?> Function() action) async {
    try {
      await action();
    } on AuthRetryableFetchException catch (e) {
      throw AuthFailure(AuthFailureKind.network, e.message);
    } on AuthException catch (e) {
      throw AuthFailure(_kindFor(e), e.message);
    } on TimeoutException catch (e) {
      throw AuthFailure(AuthFailureKind.network, e.message);
    } on Exception catch (e) {
      // SocketException / ClientException when offline.
      throw AuthFailure(AuthFailureKind.network, '$e');
    }
  }

  static AuthFailureKind _kindFor(AuthException e) {
    switch (e.code) {
      case 'otp_expired':
        return AuthFailureKind.invalidOtp;
      case 'invalid_credentials':
        return AuthFailureKind.invalidCredentials;
      case 'over_request_rate_limit':
      case 'over_sms_send_rate_limit':
        return AuthFailureKind.rateLimited;
      case 'phone_provider_disabled':
      case 'sms_send_failed':
      case 'otp_disabled':
        return AuthFailureKind.smsUnavailable;
    }
    if (e.statusCode == '429') return AuthFailureKind.rateLimited;
    return AuthFailureKind.unknown;
  }
}

/// Used when the build has no Supabase configuration: nobody can sign in.
class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  static const _failure = AuthFailure(AuthFailureKind.notConfigured);

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get userChanges => const Stream.empty();

  @override
  Future<void> sendOtp(String phone) => Future.error(_failure);

  @override
  Future<void> verifyOtp({required String phone, required String code}) =>
      Future.error(_failure);

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => Future.error(_failure);

  @override
  Future<void> signOut() async {}
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  if (!Env.hasSupabase) return const UnconfiguredAuthRepository();
  try {
    return SupabaseAuthRepository(Supabase.instance.client.auth);
  } on Object {
    // Supabase.initialize failed at startup.
    return const UnconfiguredAuthRepository();
  }
}
