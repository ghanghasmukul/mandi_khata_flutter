import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';

/// The backup file could not be read: not ours, cut short, or changed.
class BackupCorrupt implements Exception {
  const BackupCorrupt();
}

/// The passphrase does not open this backup.
class BackupWrongPassphrase implements Exception {
  const BackupWrongPassphrase();
}

/// The encrypted backup file format (`.mkbak`).
///
/// ```text
/// "MKBAK1" | iterations (uint32 BE) | salt (16) | nonce (12)
///   | ciphertext | mac (16)
/// ```
/// The plain text is the snapshot JSON, gzip-compressed, encrypted with
/// AES-256-GCM. The key is PBKDF2-HMAC-SHA256 of the passphrase and the salt.
/// GCM authenticates the whole file, so a wrong passphrase and a damaged
/// file are both detected before anything is read.
abstract final class BackupCodec {
  static const magic = 'MKBAK1';
  static const defaultIterations = 120000;
  static const _saltLength = 16;
  static const _nonceLength = 12;
  static const _macLength = 16;
  static const int _headerLength = 6 + 4 + _saltLength + _nonceLength;

  static final AesGcm _aes = AesGcm.with256bits();

  static Future<SecretKey> _key(String pass, List<int> salt, int iterations) =>
      Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: 256,
      ).deriveKeyFromPassword(password: pass, nonce: salt);

  static Future<Uint8List> encrypt(
    Map<String, Object?> snapshot,
    String passphrase, {
    int iterations = defaultIterations,
  }) async {
    final plain = const GZipEncoder().encode(utf8.encode(jsonEncode(snapshot)));
    final random = SecureRandom.defaultRandom;
    final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    final nonce = _aes.newNonce();
    final box = await _aes.encrypt(
      plain,
      secretKey: await _key(passphrase, salt, iterations),
      nonce: nonce,
    );
    final out = BytesBuilder()
      ..add(ascii.encode(magic))
      ..add((ByteData(4)..setUint32(0, iterations)).buffer.asUint8List())
      ..add(salt)
      ..add(nonce)
      ..add(box.cipherText)
      ..add(box.mac.bytes);
    return out.toBytes();
  }

  static Future<Map<String, Object?>> decrypt(
    Uint8List file,
    String passphrase,
  ) async {
    if (file.length < _headerLength + _macLength ||
        ascii.decode(file.sublist(0, 6), allowInvalid: true) != magic) {
      throw const BackupCorrupt();
    }
    final iterations = ByteData.sublistView(file, 6, 10).getUint32(0);
    if (iterations < 1 || iterations > 5000000) throw const BackupCorrupt();
    final salt = file.sublist(10, 10 + _saltLength);
    final nonce = file.sublist(10 + _saltLength, _headerLength);
    final cipher = file.sublist(_headerLength, file.length - _macLength);
    final mac = Mac(file.sublist(file.length - _macLength));
    final List<int> plain;
    try {
      plain = await _aes.decrypt(
        SecretBox(cipher, nonce: nonce, mac: mac),
        secretKey: await _key(passphrase, salt, iterations),
      );
    } on SecretBoxAuthenticationError {
      throw const BackupWrongPassphrase();
    }
    try {
      final json = jsonDecode(
        utf8.decode(const GZipDecoder().decodeBytes(plain)),
      );
      return (json as Map).cast<String, Object?>();
    } on Object {
      throw const BackupCorrupt();
    }
  }
}
