import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/subscription/entitlement_token.dart';

// A throw-away P-256 key pair made for these tests only.
const _privatePem = '''
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIDKC0Lx4OYyAyYSZfHIKy1f36dCYSQilj59Aqr8qDGGSoAoGCCqGSM49
AwEHoUQDQgAEnA+Tw2KjyIXvet03oVBAJ4BpyW/vKxs/5vdlz9Qe6hx8BDvmdcRh
oIePdggqrK+igC3wAYnKpBHqCyaxRKaW6Q==
-----END EC PRIVATE KEY-----''';
const _otherPrivatePem = '''
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIOnlElKB7zlNxIjtwSloHwmO4RVumxgv5hkSwTLEwkw/oAoGCCqGSM49
AwEHoUQDQgAEgr2lSWOUgkYDyGqoonRUJ38CD4PovHj0CA72gSzLt6aDupcpZb+b
ryxIq3MNwbnbubBNqK/4pAZt95DySVdiTA==
-----END EC PRIVATE KEY-----''';
const _publicPem = '''
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEnA+Tw2KjyIXvet03oVBAJ4BpyW/v
Kxs/5vdlz9Qe6hx8BDvmdcRhoIePdggqrK+igC3wAYnKpBHqCyaxRKaW6Q==
-----END PUBLIC KEY-----''';

String _token({
  String tid = 't1',
  String status = 'active',
  String? periodEnd = '2027-06-01T00:00:00.000Z',
  int iat = 1780000000,
  ECPrivateKey? key,
}) =>
    JWT({
      'tid': tid,
      'plan': 'mandi_pro',
      'iat': iat,
      'valid_until': '2027-06-08T00:00:00.000Z',
      'terms': {
        'status': status,
        'trial_ends_at': null,
        'current_period_end': periodEnd,
        'grace_days': 7,
        'grace_until': null,
        'cancelled_at': null,
        'cancelled_readonly_days': 90,
      },
      'modules': {'khata': true, 'karza': true},
      'limits': {'users': 5, 'parties': null},
    }).sign(
      key ?? ECPrivateKey(_privatePem),
      algorithm: JWTAlgorithm.ES256,
      noIssueAt: true,
    );

void main() {
  test('a token signed with the private key verifies', () {
    final c = EntitlementTokenVerifier.verify(_token(), _publicPem);
    expect(c, isNotNull);
    expect(c!.tenantId, 't1');
    expect(c.planCode, 'mandi_pro');
    expect(c.terms.status, SubscriptionStatus.active);
    expect(c.terms.currentPeriodEnd, DateTime.utc(2027, 6));
    expect(c.entitlements.module('karza'), isTrue);
    expect(c.entitlements.module('shop'), isFalse);
    expect(c.entitlements.limit('users'), 5);
    expect(c.entitlements.limit('parties'), isNull);
    expect(
      c.issuedAt,
      DateTime.fromMillisecondsSinceEpoch(1780000000 * 1000, isUtc: true),
    );
  });

  test(r'the PEM may be written with \n escapes (env file)', () {
    final oneLine = _publicPem.trim().replaceAll('\n', r'\n');
    expect(EntitlementTokenVerifier.verify(_token(), oneLine), isNotNull);
  });

  test('a token signed with another key is refused', () {
    expect(
      EntitlementTokenVerifier.verify(
        JWT({
          'tid': 't1',
          'plan': 'x',
          'iat': 1,
          'terms': <String, Object?>{},
        }).sign(ECPrivateKey(_otherPrivatePem), algorithm: JWTAlgorithm.ES256),
        _publicPem,
      ),
      isNull,
    );
  });

  test('a tampered payload is refused', () {
    final parts = _token().split('.');
    // Flip one character of the payload.
    final p = parts[1];
    final flipped = p.endsWith('A') ? 'B' : 'A';
    final tampered =
        '${parts[0]}.${p.substring(0, p.length - 2)}'
        '$flipped${p.substring(p.length - 1)}.${parts[2]}';
    expect(EntitlementTokenVerifier.verify(tampered, _publicPem), isNull);
  });

  test('no key, no token, or garbage never throws', () {
    expect(EntitlementTokenVerifier.verify(_token(), ''), isNull);
    expect(EntitlementTokenVerifier.verify('', _publicPem), isNull);
    expect(EntitlementTokenVerifier.verify('a.b.c', _publicPem), isNull);
    expect(EntitlementTokenVerifier.verify(_token(), 'not a pem'), isNull);
  });

  test('a token missing required claims is refused', () {
    final t = JWT({
      'plan': 'x',
    }).sign(ECPrivateKey(_privatePem), algorithm: JWTAlgorithm.ES256);
    expect(EntitlementTokenVerifier.verify(t, _publicPem), isNull);
  });
}
