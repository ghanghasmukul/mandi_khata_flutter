import 'dart:typed_data';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// A stored document of a party (`party_documents`).
@immutable
class PartyDocument {
  const PartyDocument({
    required this.id,
    required this.partyId,
    required this.type,
    required this.filePath,
    required this.contentType,
    required this.sizeBytes,
    this.title,
    this.idMasked,
    this.thumbPath,
    this.notes,
    this.createdAt,
  });

  factory PartyDocument.fromRow(Map<String, Object?> r) => PartyDocument(
    id: r['id']! as String,
    partyId: r['party_id']! as String,
    type:
        PartyDocumentType.fromCode(r['doc_type'] as String?) ??
        PartyDocumentType.other,
    title: r['title'] as String?,
    idMasked: r['id_masked'] as String?,
    filePath: r['file_path']! as String,
    thumbPath: r['thumb_path'] as String?,
    contentType: r['content_type']! as String,
    sizeBytes: r['size_bytes']! as int,
    notes: r['notes'] as String?,
    createdAt: DateTime.tryParse((r['created_at'] as String?) ?? ''),
  );

  final String id;
  final String partyId;
  final PartyDocumentType type;
  final String? title;

  /// `XXXX XXXX 1234` for Aadhaar, `XXXXXX234F` for PAN; never the full number.
  final String? idMasked;
  final String filePath;
  final String? thumbPath;
  final String contentType;
  final int sizeBytes;
  final String? notes;
  final DateTime? createdAt;

  bool get isPdf => contentType == 'application/pdf';

  /// Storage bucket of this document's files.
  String get bucket => DocumentBuckets.of(type);
}

/// Which bucket a document type lives in (identity = owner only).
abstract final class DocumentBuckets {
  static const kyc = 'kyc-docs';
  static const party = 'party-docs';

  static String of(PartyDocumentType type) => type.isIdentity ? kyc : party;
}

/// A file ready to be attached (already compressed).
@immutable
class DocumentFile {
  const DocumentFile({
    required this.fileName,
    required this.bytes,
    required this.contentType,
    this.thumb,
  });

  final String fileName;
  final Uint8List bytes;
  final String contentType;

  /// A small JPEG preview; null for PDFs and for pictures that could not be
  /// decoded (HEIC on some platforms).
  final Uint8List? thumb;
}

/// A document to add.
@immutable
class DocumentDraft {
  const DocumentDraft({
    required this.partyId,
    required this.type,
    required this.file,
    this.title,
    this.idNumber,
    this.notes,
  });

  final String partyId;
  final PartyDocumentType type;
  final DocumentFile file;
  final String? title;

  /// The full Aadhaar / PAN as typed. Only used to build the masked text and
  /// to check it; never stored.
  final String? idNumber;
  final String? notes;
}

/// Why adding a document was refused.
enum DocumentRefusal {
  /// Identity documents are owner only; the others need `parties.manage`.
  notAllowed,
  tooLarge,
  unsupportedType,
  badIdNumber,
}

/// Result of adding a document.
sealed class DocumentResult {
  const DocumentResult();
}

final class DocumentAdded extends DocumentResult {
  const DocumentAdded(this.id);
  final String id;
}

final class DocumentRefused extends DocumentResult {
  const DocumentRefused(this.reason);
  final DocumentRefusal reason;
}
