import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/documents/domain/party_document.dart';

/// Shrinks a picked photo before it is stored and queued: longest side
/// [DocumentRules.maxImageSide], JPEG quality [DocumentRules.jpegQuality],
/// plus a [DocumentRules.thumbSide] thumbnail. PDFs pass through. A picture
/// that cannot be decoded (HEIC on some platforms) is kept as it is when it
/// is small enough, with no thumbnail.
///
/// Returns null when the file type is not accepted or the result is still
/// larger than [DocumentRules.maxBytes].
abstract final class DocumentCompressor {
  static Future<DocumentFile?> compress(
    String fileName,
    Uint8List bytes,
  ) async {
    final contentType = DocumentRules.contentTypeOf(fileName);
    if (contentType == null) return null;
    if (contentType == 'application/pdf') {
      return bytes.length > DocumentRules.maxBytes
          ? null
          : DocumentFile(
              fileName: fileName,
              bytes: bytes,
              contentType: contentType,
            );
    }
    final out = await compute(_shrink, bytes);
    if (out == null) {
      return bytes.length > DocumentRules.maxBytes
          ? null
          : DocumentFile(
              fileName: fileName,
              bytes: bytes,
              contentType: contentType,
            );
    }
    if (out.full.length > DocumentRules.maxBytes) return null;
    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;
    return DocumentFile(
      fileName: '$base.jpg',
      bytes: out.full,
      contentType: 'image/jpeg',
      thumb: out.thumb,
    );
  }

  /// Runs in an isolate; null when [bytes] is not a decodable picture.
  static ({Uint8List full, Uint8List thumb})? _shrink(Uint8List bytes) {
    final img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } on Object {
      // The decoder throws on truncated or foreign data.
      return null;
    }
    if (decoded == null) return null;
    final oriented = img.bakeOrientation(decoded);
    img.Image fit(int side) {
      final longest = math.max(oriented.width, oriented.height);
      if (longest <= side) return oriented;
      return oriented.width >= oriented.height
          ? img.copyResize(oriented, width: side)
          : img.copyResize(oriented, height: side);
    }

    return (
      full: Uint8List.fromList(
        img.encodeJpg(
          fit(DocumentRules.maxImageSide),
          quality: DocumentRules.jpegQuality,
        ),
      ),
      thumb: Uint8List.fromList(
        img.encodeJpg(fit(DocumentRules.thumbSide), quality: 70),
      ),
    );
  }
}
