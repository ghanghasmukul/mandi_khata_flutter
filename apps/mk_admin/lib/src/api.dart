import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The `admin-api` Edge Function rejected the call.
class AdminApiException implements Exception {
  AdminApiException(this.code);

  /// A stable code such as `not_allowed`, `invalid`, `reason_required`.
  final String code;

  @override
  String toString() => switch (code) {
    'not_allowed' => 'This account is not a platform admin.',
    'not_signed_in' => 'Please sign in again.',
    'invalid' => 'The server refused one of the values.',
    'already_exists' => 'That already exists.',
    'reason_required' => 'A reason is required.',
    _ => 'Something went wrong ($code).',
  };
}

/// Everything the console does goes through this one call.
// A seam for tests.
abstract class AdminApi {
  Future<Object?> call(String action, [Map<String, Object?> params = const {}]);
}

class SupabaseAdminApi implements AdminApi {
  SupabaseAdminApi(this._client);

  final SupabaseClient _client;

  @override
  Future<Object?> call(
    String action, [
    Map<String, Object?> params = const {},
  ]) async {
    try {
      final res = await _client.functions.invoke(
        'admin-api',
        body: {'action': action, ...params},
      );
      final data = res.data;
      if (data is Map && data.containsKey('data')) return data['data'];
      throw AdminApiException('failed');
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map && details['error'] is String) {
        throw AdminApiException(details['error'] as String);
      }
      if (details is String) {
        try {
          final decoded = jsonDecode(details);
          if (decoded is Map && decoded['error'] is String) {
            throw AdminApiException(decoded['error'] as String);
          }
        } on FormatException {
          // fall through
        }
      }
      throw AdminApiException('failed');
    }
  }
}

final adminApiProvider = Provider<AdminApi>(
  (ref) => SupabaseAdminApi(Supabase.instance.client),
);

/// A list result as typed maps.
List<Map<String, Object?>> rows(Object? data) => [
  if (data is List)
    for (final r in data)
      if (r is Map) Map<String, Object?>.from(r),
];

Map<String, Object?> asMap(Object? data) =>
    data is Map ? Map<String, Object?>.from(data) : const {};
