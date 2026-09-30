import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/core/auth/app_lock/lock_policy.dart';
import 'package:mandi_khata_app/core/auth/app_lock/pin_hasher.dart';

String hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('pbkdf2Sha256', () {
    // Reference values from Python's hashlib.pbkdf2_hmac('sha256', …).
    test('password / salt / 1 iteration', () {
      expect(
        hex(
          PinHasher.pbkdf2Sha256(
            utf8.encode('password'),
            utf8.encode('salt'),
            1,
          ),
        ),
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
      );
    });

    test('password / salt / 4096 iterations (RFC 7914 §11)', () {
      expect(
        hex(
          PinHasher.pbkdf2Sha256(
            utf8.encode('password'),
            utf8.encode('salt'),
            4096,
          ),
        ),
        'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
      );
    });

    test('a PIN with the default iteration count', () {
      expect(
        hex(
          PinHasher.pbkdf2Sha256(
            utf8.encode('1234'),
            List.generate(16, (i) => i),
            PinHasher.defaultIterations,
          ),
        ),
        'dfada071ff247e6bec37736dbed1ba93a58af89aa081176a1a026cac038223be',
      );
    });
  });

  group('PinHasher', () {
    test('verifies the right PIN only', () {
      final record = PinHasher.create('482913', random: Random(1));
      expect(PinHasher.verify('482913', record), isTrue);
      expect(PinHasher.verify('482914', record), isFalse);
      expect(PinHasher.verify('48291', record), isFalse);
      expect(record.length, 6);
    });

    test('never stores the PIN and salts every record', () {
      final a = PinHasher.create('1234');
      final b = PinHasher.create('1234');
      expect(a.salt, isNot(b.salt));
      expect(a.hash, isNot(b.hash));
      expect(jsonEncode(a.toJson()), isNot(contains('1234')));
    });

    test('round-trips through JSON', () {
      final record = PinHasher.create('9876');
      final back = PinRecord.fromJson(
        jsonDecode(jsonEncode(record.toJson())) as Map<String, Object?>,
      );
      expect(PinHasher.verify('9876', back), isTrue);
      expect(back.length, 4);
    });

    test('accepts 4–6 digits only', () {
      expect(PinHasher.isValidPin('1234'), isTrue);
      expect(PinHasher.isValidPin('123456'), isTrue);
      expect(PinHasher.isValidPin('123'), isFalse);
      expect(PinHasher.isValidPin('1234567'), isFalse);
      expect(PinHasher.isValidPin('12a4'), isFalse);
      expect(() => PinHasher.create('12'), throwsArgumentError);
    });
  });

  group('LockPolicy', () {
    test('first five wrong PINs are free, then 30 s doubling to 15 min', () {
      expect(LockPolicy.cooldownAfter(4), Duration.zero);
      expect(LockPolicy.cooldownAfter(5), const Duration(seconds: 30));
      expect(LockPolicy.cooldownAfter(6), const Duration(minutes: 1));
      expect(LockPolicy.cooldownAfter(7), const Duration(minutes: 2));
      expect(LockPolicy.cooldownAfter(9), const Duration(minutes: 8));
      expect(LockPolicy.cooldownAfter(10), const Duration(minutes: 15));
      expect(LockPolicy.cooldownAfter(100), const Duration(minutes: 15));
    });

    test('locks after two minutes away', () {
      expect(LockPolicy.shouldLockAfter(const Duration(seconds: 119)), isFalse);
      expect(LockPolicy.shouldLockAfter(const Duration(minutes: 2)), isTrue);
    });
  });
}
