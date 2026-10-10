import 'package:meta/meta.dart';

/// What a stored party document is (`party_documents.doc_type`).
enum PartyDocumentType {
  aadhaar('aadhaar', isIdentity: true),
  pan('pan', isIdentity: true),
  passbook('passbook'),
  cheque('cheque'),
  jForm('j_form'),
  loanAgreement('loan_agreement'),
  other('other');

  const PartyDocumentType(this.code, {this.isIdentity = false});

  /// Stored value.
  final String code;

  /// An identity document: its number is shown masked, never in full.
  final bool isIdentity;

  static PartyDocumentType? fromCode(String? code) {
    for (final t in values) {
      if (t.code == code) return t;
    }
    return null;
  }
}

/// Rules for party documents / KYC (step 6.3, docs/domain/documents-kyc.md).
abstract final class DocumentRules {
  /// Largest file kept after compression (the bucket allows 10 MB; base64
  /// in the local queue adds a third).
  static const int maxBytes = 6 * 1024 * 1024;

  /// Photos are scaled so that the longest side is at most this.
  static const maxImageSide = 1600;
  static const jpegQuality = 80;
  static const thumbSide = 240;

  static const allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'pdf',
  ];

  /// The MIME type from a file name; null when the type is not accepted.
  static String? contentTypeOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0) return null;
    return switch (fileName.substring(dot + 1).toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'pdf' => 'application/pdf',
      _ => null,
    };
  }

  /// A file name that is safe in a storage path.
  static String safeFileName(String name) {
    final cleaned = name.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_');
    final trimmed = cleaned.length > 60
        ? cleaned.substring(cleaned.length - 60)
        : cleaned;
    return trimmed.isEmpty ? 'document' : trimmed;
  }

  /// `<tenant>/<party>/<document>/<file>`: the first folder is the
  /// business, which is what the storage policy checks.
  static String storagePath({
    required String tenantId,
    required String partyId,
    required String documentId,
    required String fileName,
  }) => '$tenantId/$partyId/$documentId/${safeFileName(fileName)}';

  /// Where the thumbnail of the file at [path] lives.
  static String thumbPath(String path) => '$path.thumb.jpg';

  // -- identity numbers --------------------------------------------------

  static String _digits(String s) => s.replaceAll(RegExp(r'[\s-]'), '');

  /// Aadhaar: 12 digits, not starting 0 or 1, with a valid Verhoeff check
  /// digit. Spaces and dashes are ignored.
  static bool isValidAadhaar(String input) {
    final d = _digits(input);
    if (!RegExp(r'^[2-9][0-9]{11}$').hasMatch(d)) return false;
    return _verhoeffValid(d);
  }

  /// PAN: five letters, four digits, one letter (upper-cased).
  static bool isValidPan(String input) =>
      RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(input.trim().toUpperCase());

  /// The number as it may be shown and stored: Aadhaar `XXXX XXXX 1234`,
  /// PAN `XXXXXX234F` (last four characters). Null when [input] is not a
  /// valid number of that type. The full number is never kept.
  static String? maskIdentity(PartyDocumentType type, String input) {
    switch (type) {
      case PartyDocumentType.aadhaar:
        if (!isValidAadhaar(input)) return null;
        final d = _digits(input);
        return 'XXXX XXXX ${d.substring(8)}';
      case PartyDocumentType.pan:
        if (!isValidPan(input)) return null;
        final p = input.trim().toUpperCase();
        return 'XXXXXX${p.substring(6)}';
      case PartyDocumentType.passbook ||
          PartyDocumentType.cheque ||
          PartyDocumentType.jForm ||
          PartyDocumentType.loanAgreement ||
          PartyDocumentType.other:
        return null;
    }
  }

  /// Masks an Aadhaar-looking number in free text (a note a person typed),
  /// leaving the last four digits: `1234 5678 9012` -> `XXXX XXXX 9012`.
  static String maskAadhaarInText(String text) => text.replaceAllMapped(
    RegExp(r'(?<!\d)(\d{4})[\s-]?(\d{4})[\s-]?(\d{4})(?!\d)'),
    (m) => 'XXXX XXXX ${m[3]}',
  );

  // Verhoeff tables (multiplication, permutation).
  static const List<List<int>> _d = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
  ];
  static const List<List<int>> _p = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
  ];

  static bool _verhoeffValid(String digits) {
    var c = 0;
    final reversed = digits.split('').reversed.toList();
    for (var i = 0; i < reversed.length; i++) {
      c = _d[c][_p[i % 8][int.parse(reversed[i])]];
    }
    return c == 0;
  }

  /// A Verhoeff check digit for [payload] (used by tests to build numbers).
  @visibleForTesting
  static int verhoeffCheckDigit(String payload) {
    var c = 0;
    final reversed = payload.split('').reversed.toList();
    for (var i = 0; i < reversed.length; i++) {
      c = _d[c][_p[(i + 1) % 8][int.parse(reversed[i])]];
    }
    const inv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9];
    return inv[c];
  }
}
