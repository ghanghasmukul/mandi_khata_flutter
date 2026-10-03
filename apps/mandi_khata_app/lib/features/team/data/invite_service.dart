import 'package:flutter/foundation.dart' show immutable;
import 'package:mandi_khata_app/app/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'invite_service.g.dart';

/// How the invite reached the person.
enum InviteDelivery { whatsapp, sms, none }

enum InviteFailure {
  invalidPhone,
  invalidRole,
  alreadyMember,
  alreadyInvited,
  notAllowed,
  offline,
  failed,
}

sealed class InviteResult {
  const InviteResult();
}

/// The invite exists. When [delivery] is [InviteDelivery.none] nothing was
/// sent (no SMS / WhatsApp provider configured, or it refused): the owner
/// shares [message] by hand.
@immutable
class InviteSent extends InviteResult {
  const InviteSent({
    required this.delivery,
    required this.message,
    required this.phone,
  });

  final InviteDelivery delivery;
  final String message;

  /// `91` + 10 digits.
  final String phone;
}

@immutable
class InviteRejected extends InviteResult {
  const InviteRejected(this.reason);

  final InviteFailure reason;
}

/// Creating an invite needs the server (it sends the message), so it is the
/// one team action that does not work offline.
abstract interface class InviteService {
  Future<InviteResult> invite({
    required String tenantId,
    required String phone,
    required String role,
    required Map<String, bool> customPermissions,
    String? fullName,
    String? deviceId,
    String language = 'en',
    String channel = 'whatsapp',
  });
}

/// Calls the `invite-member` Edge Function with the signed-in user's session.
class SupabaseInviteService implements InviteService {
  SupabaseInviteService(this._client);

  final SupabaseClient _client;

  static InviteFailure _failure(String? code) => switch (code) {
    'invalid_phone' => InviteFailure.invalidPhone,
    'invalid_role' => InviteFailure.invalidRole,
    'already_member' => InviteFailure.alreadyMember,
    'already_invited' => InviteFailure.alreadyInvited,
    'not_allowed' => InviteFailure.notAllowed,
    _ => InviteFailure.failed,
  };

  @override
  Future<InviteResult> invite({
    required String tenantId,
    required String phone,
    required String role,
    required Map<String, bool> customPermissions,
    String? fullName,
    String? deviceId,
    String language = 'en',
    String channel = 'whatsapp',
  }) async {
    try {
      final res = await _client.functions.invoke(
        'invite-member',
        body: {
          'tenant_id': tenantId,
          'phone': phone,
          'role': role,
          'custom_permissions': customPermissions,
          'full_name': ?fullName,
          'device_id': ?deviceId,
          'language': language,
          'channel': channel,
        },
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        return const InviteRejected(InviteFailure.failed);
      }
      final invite = data['invite'] as Map<String, dynamic>?;
      return InviteSent(
        delivery: switch (data['delivery']) {
          'whatsapp' => InviteDelivery.whatsapp,
          'sms' => InviteDelivery.sms,
          _ => InviteDelivery.none,
        },
        message: data['message'] as String? ?? '',
        phone: invite?['phone'] as String? ?? phone,
      );
    } on FunctionException catch (e) {
      final details = e.details;
      final code = details is Map ? details['error'] as String? : null;
      return InviteRejected(_failure(code));
    } on Exception {
      // No connection, DNS, timeout…
      return const InviteRejected(InviteFailure.offline);
    }
  }
}

class _UnconfiguredInviteService implements InviteService {
  const _UnconfiguredInviteService();

  @override
  Future<InviteResult> invite({
    required String tenantId,
    required String phone,
    required String role,
    required Map<String, bool> customPermissions,
    String? fullName,
    String? deviceId,
    String language = 'en',
    String channel = 'whatsapp',
  }) async => const InviteRejected(InviteFailure.offline);
}

@Riverpod(keepAlive: true)
InviteService inviteService(Ref ref) {
  if (!Env.hasSupabase) return const _UnconfiguredInviteService();
  try {
    return SupabaseInviteService(Supabase.instance.client);
  } on Object {
    return const _UnconfiguredInviteService();
  }
}
