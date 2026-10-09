import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// What the signed entitlement token says (Edge Function
/// `entitlement-token`; docs/domain/saas-rules.md section 3).
@immutable
class EntitlementClaims {
  const EntitlementClaims({
    required this.tenantId,
    required this.planCode,
    required this.terms,
    required this.entitlements,
    required this.issuedAt,
    required this.validUntil,
  });

  final String tenantId;
  final String planCode;
  final SubscriptionTerms terms;
  final Entitlements entitlements;
  final DateTime issuedAt;

  /// Period end plus grace (informational: the terms decide).
  final DateTime? validUntil;

  static DateTime? _time(Object? v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v)?.toUtc() : null;

  /// Reads verified token claims; null if a required claim is missing.
  static EntitlementClaims? fromPayload(Map<String, Object?> p) {
    final tid = p['tid'];
    final plan = p['plan'];
    final iat = p['iat'];
    if (tid is! String || plan is! String || iat is! int) return null;
    final t = p['terms'];
    if (t is! Map) return null;
    int intOf(String k, int d) => t[k] is int ? t[k] as int : d;
    return EntitlementClaims(
      tenantId: tid,
      planCode: plan,
      issuedAt: DateTime.fromMillisecondsSinceEpoch(iat * 1000, isUtc: true),
      validUntil: _time(p['valid_until']),
      terms: SubscriptionTerms(
        status: SubscriptionStatus.parse(t['status'] as String?),
        trialEndsAt: _time(t['trial_ends_at']),
        currentPeriodEnd: _time(t['current_period_end']),
        graceDays: intOf('grace_days', 7),
        graceUntil: _time(t['grace_until']),
        cancelledAt: _time(t['cancelled_at']),
        cancelledReadOnlyDays: intOf('cancelled_readonly_days', 90),
      ),
      entitlements: Entitlements.fromJson({
        'modules': p['modules'],
        'limits': p['limits'],
      }),
    );
  }
}

/// Checks the token's ES256 signature with the public key baked into the
/// build (`ENTITLEMENT_PUBLIC_KEY`).
abstract final class EntitlementTokenVerifier {
  /// The claims, or null when the key is empty, the signature is wrong or
  /// the token is malformed. Never throws.
  static EntitlementClaims? verify(String token, String publicKeyPem) {
    final pem = publicKeyPem.replaceAll(r'\n', '\n').trim();
    if (token.isEmpty || pem.isEmpty) return null;
    try {
      final jwt = JWT.verify(
        token,
        ECPublicKey(pem),
        checkExpiresIn: false,
        checkHeaderType: false,
        checkNotBefore: false,
      );
      final payload = jwt.payload;
      if (payload is! Map) return null;
      return EntitlementClaims.fromPayload(
        Map<String, Object?>.from(
          jsonDecode(jsonEncode(payload)) as Map<String, dynamic>,
        ),
      );
    } on Object {
      return null;
    }
  }
}
