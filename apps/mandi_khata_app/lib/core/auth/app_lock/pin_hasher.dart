import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// A stored app-lock PIN: salted PBKDF2-HMAC-SHA256, never the PIN itself.
class PinRecord {
  const PinRecord({
    required this.salt,
    required this.hash,
    required this.iterations,
    required this.length,
  });

  factory PinRecord.fromJson(Map<String, Object?> json) => PinRecord(
    salt: base64Decode(json['salt']! as String),
    hash: base64Decode(json['hash']! as String),
    iterations: json['iterations']! as int,
    length: json['length']! as int,
  );

  final List<int> salt;
  final List<int> hash;
  final int iterations;

  /// Digits in the PIN, so the lock screen can check as soon as the last
  /// digit is typed.
  final int length;

  Map<String, Object?> toJson() => {
    'salt': base64Encode(salt),
    'hash': base64Encode(hash),
    'iterations': iterations,
    'length': length,
  };
}

/// Hashes and checks app-lock PINs. Pure Dart so it can run in an isolate.
abstract final class PinHasher {
  /// Slows down guessing all 10⁶ PINs from a copied prefs file while keeping
  /// an unlock well under a second on a budget Android phone.
  static const defaultIterations = 20000;

  static bool isValidPin(String pin) => RegExp(r'^\d{4,6}$').hasMatch(pin);

  static PinRecord create(
    String pin, {
    Random? random,
    int iterations = defaultIterations,
  }) {
    if (!isValidPin(pin)) throw ArgumentError.value(pin, 'pin', '4–6 digits');
    final rng = random ?? Random.secure();
    final salt = List<int>.generate(16, (_) => rng.nextInt(256));
    return PinRecord(
      salt: salt,
      hash: pbkdf2Sha256(utf8.encode(pin), salt, iterations),
      iterations: iterations,
      length: pin.length,
    );
  }

  static bool verify(String pin, PinRecord record) {
    final hash = pbkdf2Sha256(utf8.encode(pin), record.salt, record.iterations);
    return _constantTimeEquals(hash, record.hash);
  }

  /// PBKDF2 (RFC 8018) with HMAC-SHA256, one 32-byte block.
  static List<int> pbkdf2Sha256(
    List<int> password,
    List<int> salt,
    int iterations,
  ) {
    final hmac = Hmac(sha256, password);
    var u = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
    final out = Uint8List.fromList(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < out.length; j++) {
        out[j] ^= u[j];
      }
    }
    return out;
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
