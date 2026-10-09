import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Why creating a business failed.
enum SignupFailure { offline, closed, limitReached, invalid, other }

/// What the signup form collects.
@immutable
class SignupInput {
  const SignupInput({
    required this.name,
    required this.stateCode,
    required this.businessType,
    this.mandiName,
    this.phone,
    this.referralCode,
  });

  final String name;
  final String stateCode;

  /// `arhtiya`, `shop` or `both`.
  final String businessType;
  final String? mandiName;
  final String? phone;
  final String? referralCode;

  /// Null when the form is complete.
  String? get firstProblem {
    if (name.trim().isEmpty) return 'name';
    if (!RegExp(r'^\d{2}$').hasMatch(stateCode)) return 'state';
    if (!const {'arhtiya', 'shop', 'both'}.contains(businessType)) {
      return 'type';
    }
    return null;
  }
}

/// Creating a business is an account action, not business data, so it asks
/// the server directly (the one thing here that needs the internet). The new
/// business then arrives through sync like any other.
class SignupRepository {
  SignupRepository(this._client);

  final SupabaseClient? _client;

  /// The id is chosen here, so a retry after a dropped connection returns
  /// the same business instead of creating a second one.
  Future<({String? tenantId, SignupFailure? failure})> signUp(
    SignupInput input, {
    String? tenantId,
  }) async {
    final id = tenantId ?? const Uuid().v4();
    try {
      final client = _client;
      if (client == null) {
        return (tenantId: null, failure: SignupFailure.offline);
      }
      final res = await client.rpc<dynamic>(
        'signup_business',
        params: {
          'p_tenant_id': id,
          'p_name': input.name,
          'p_state_code': input.stateCode,
          'p_mandi_name': input.mandiName,
          'p_business_type': input.businessType,
          'p_phone': input.phone,
          'p_referral_code': input.referralCode,
        },
      );
      return (tenantId: res is String ? res : id, failure: null);
    } on PostgrestException catch (e) {
      final text = '${e.message} ${e.details ?? ''}';
      if (text.contains('signup_closed')) {
        return (tenantId: null, failure: SignupFailure.closed);
      }
      if (text.contains('signup_limit')) {
        return (tenantId: null, failure: SignupFailure.limitReached);
      }
      if (e.code == '22023') {
        return (tenantId: null, failure: SignupFailure.invalid);
      }
      return (tenantId: null, failure: SignupFailure.other);
    } on Object {
      return (tenantId: null, failure: SignupFailure.offline);
    }
  }
}

/// Overridden in tests.
final signupRepositoryProvider = Provider<SignupRepository>(
  (ref) => SignupRepository(Supabase.instance.client),
);
