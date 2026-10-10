import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  String aadhaarWith(String first11) =>
      '$first11${DocumentRules.verhoeffCheckDigit(first11)}';

  group('Verhoeff / Aadhaar', () {
    test('the textbook example 236 -> 2363', () {
      expect(DocumentRules.verhoeffCheckDigit('236'), 3);
    });

    test('a number with the right check digit is valid', () {
      final n = aadhaarWith('23456789012');
      expect(DocumentRules.isValidAadhaar(n), isTrue);
      expect(
        DocumentRules.isValidAadhaar(
          '${n.substring(0, 4)} ${n.substring(4, 8)} ${n.substring(8)}',
        ),
        isTrue,
        reason: 'spaces are ignored',
      );
    });

    test('a changed digit, a swapped pair or a wrong length is invalid', () {
      final n = aadhaarWith('23456789012');
      final last = int.parse(n[11]);
      expect(
        DocumentRules.isValidAadhaar('${n.substring(0, 11)}${(last + 1) % 10}'),
        isFalse,
      );
      final swapped = n.replaceRange(2, 4, '${n[3]}${n[2]}');
      expect(DocumentRules.isValidAadhaar(swapped), isFalse);
      expect(DocumentRules.isValidAadhaar(n.substring(1)), isFalse);
    });

    test('cannot start with 0 or 1', () {
      expect(DocumentRules.isValidAadhaar(aadhaarWith('13456789012')), isFalse);
      expect(DocumentRules.isValidAadhaar(aadhaarWith('03456789012')), isFalse);
    });
  });

  group('masking', () {
    test('Aadhaar keeps only the last four digits', () {
      final n = aadhaarWith('23456789012');
      expect(
        DocumentRules.maskIdentity(PartyDocumentType.aadhaar, n),
        'XXXX XXXX ${n.substring(8)}',
      );
    });

    test('an invalid number is not masked (and so never stored)', () {
      expect(
        DocumentRules.maskIdentity(PartyDocumentType.aadhaar, '234567890123'),
        isNull,
      );
      expect(
        DocumentRules.maskIdentity(PartyDocumentType.passbook, 'x'),
        isNull,
      );
    });

    test('PAN', () {
      expect(DocumentRules.isValidPan('abcde1234f'), isTrue);
      expect(DocumentRules.isValidPan('ABCDE12345'), isFalse);
      expect(
        DocumentRules.maskIdentity(PartyDocumentType.pan, 'abcde1234f'),
        'XXXXXX234F',
      );
    });

    test('Aadhaar-looking digits in free text are masked', () {
      expect(
        DocumentRules.maskAadhaarInText('Aadhaar 2345 6789 0123 ok'),
        'Aadhaar XXXX XXXX 0123 ok',
      );
      expect(
        DocumentRules.maskAadhaarInText('call 9876543210'),
        'call 9876543210',
        reason: 'a 10-digit mobile is not touched',
      );
    });
  });

  group('files and paths', () {
    test('content types', () {
      expect(DocumentRules.contentTypeOf('a.JPG'), 'image/jpeg');
      expect(DocumentRules.contentTypeOf('a.pdf'), 'application/pdf');
      expect(DocumentRules.contentTypeOf('a.exe'), isNull);
      expect(DocumentRules.contentTypeOf('noext'), isNull);
    });

    test('the first folder of the path is the business', () {
      final p = DocumentRules.storagePath(
        tenantId: 'T',
        partyId: 'P',
        documentId: 'D',
        fileName: 'my pic (1).jpg',
      );
      expect(p, 'T/P/D/my_pic__1_.jpg');
      expect(p.split('/').first, 'T');
      expect(DocumentRules.thumbPath(p), '$p.thumb.jpg');
    });

    test('type codes round trip', () {
      for (final t in PartyDocumentType.values) {
        expect(PartyDocumentType.fromCode(t.code), t);
      }
      expect(PartyDocumentType.fromCode('x'), isNull);
    });
  });
}
